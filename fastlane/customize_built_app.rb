require_relative 'binary_plist'

def customize_built_app(options)
  customer_assets = 'puppy'

  customer_appiconset_dirpath = File.absolute_path("../#{customer_assets}/#{customer_assets}.appiconset")
  customer_profile_pathname = File.absolute_path("../#{customer_assets}/#{customer_assets}.mobileprovision")

  zip_package_path = download_latest_release
  # unzip the ipa/images package into a tmp directory
  Dir.mktmpdir("latest_release_pkg") do |latest_release_pkg_path|
    Dir.chdir(latest_release_pkg_path) do
      sh("unzip -o -q #{zip_package_path}")

      example_ipa_filepath = File.absolute_path('example.ipa')
      app_iconset_dirpath = File.absolute_path('AppIcon.appiconset')

      # now that we have the package unzipped into a temporary folder, lets unzip the ipa so we can operate inside of it
      Dir.mktmpdir("customize_built_app") do |unzipped_ipa_path|
        Dir.chdir(unzipped_ipa_path) do
          sh("unzip -o -q #{example_ipa_filepath}")
          example_ipa_payload_dir = File.join(unzipped_ipa_path, "Payload")
          byebug
          copy_customer_images(customer_appiconset_dirpath, latest_release_pkg_path)
          compile_images(latest_release_pkg_path, example_ipa_payload_dir)

          # use the 'lyndsey' keychain for now
          keychain_data = get_keychain_from_vault(vault_addr: 'http://127.0.0.1:8200', keychain_name: 'lyndsey', keychain_path: '/Users/lyndsey.ferguson/Library/Keychains/lyndsey.keychain-db')
          unlock_keychain(path: keychain_data[:keychain_path], password: keychain_data[:keychain_password], set_default: true)
          # get customer profile, code signing id, and team id
          cert = '' # find the cert!
          sign_frameworks(cert, keychain_data[:keychain_path])
          bundle_path = 'Payload/AppExample.app'
          prepare_bundle(bundle_path, customer_profile_pathname)
	  # code sign
          puts Dir.pwd
        end
      end
    end
  end
end

APP_ICON_ASSET_DIR = 'AppIcon.appiconset'

def app_icon_asset_path(latest_release_pkg_path)
  File.join(latest_release_pkg_path, APP_ICON_ASSET_DIR)
end

def copy_customer_images(customer_appiconset_dirpath, latest_release_pkg_path)
  remove_app_icon_assets(latest_release_pkg_path)
  FileUtils.cp_r("#{customer_appiconset_dirpath}/.", app_icon_asset_path(latest_release_pkg_path))
end

def remove_app_icon_assets(latest_release_pkg_path)
   FileUtils.rm_r(Dir.glob("#{app_icon_asset_path(latest_release_pkg_path)}/*.png"))
end

def minimum_deployment_target
  plist_filepath = 'Payload/AppExample.app/Info.plist'
  temporary_plist_file = Tempfile.new
  FileUtils.cp(plist_filepath, temporary_plist_file.path)
  info_plist = Plist.parse_binary_xml(temporary_plist_file.path)
  info_plist.fetch('MinimumOSVersion', '10.0')
end

def compile_images(latest_release_pkg_path, example_ipa_payload_dir)
  FileUtils.mkdir_p("#{latest_release_pkg_path}/build")
  command = "xcrun actool #{latest_release_pkg_path} "
  command += "--compile #{example_ipa_payload_dir}/AppExample.app "
  command += "--minimum-deployment-target #{minimum_deployment_target} "
  command += '--app-icon AppIcon --platform iphoneos '
  command += "--output-partial-info-plist #{latest_release_pkg_path}/build/partial.plist "
  byebug
  sh(command)
end

def sign_frameworks(cert, keychain_filepath)
  frameworks = Dir.glob('Payload/AppExample.app/Frameworks/*.dylib').map { |s| "'#{s}'" }.join(' ')
  sh("/usr/bin/codesign -f --keychain \"#{keychain_filepath.shellescape}\"  -s \"#{cert}\" #{frameworks}")
end

def prepare_bundle(bundle_path, profile_pathname)
  # Remove existing signature file
  FileUtils.rm_rf("Payload/#{bundle_path}/_CodeSignature")

  # Copy associated provisioning profile to app
  FileUtils.cp(profile_pathname, "Payload/#{bundle_path}/embedded.mobileprovision")
end

def prepare_entitlements(cert, bundle_path, keychain_filepath)
  app_path = "Payload/#{bundle_path}"
  # File exists in builds that were created with xcode versions < 10.
  # Entitlements are now embedded in the app binary which are read and manipulated before signing them back into the binary.
  FileUtils.rm_f("Payload/#{bundle_path}/#{File.basename(bundle_path, '.*')}.entitlements")
  entitlements = Tempfile.new()
  sh("/usr/bin/codesign -d --entitlements :\"#{entitlements.path}\" \"#{app_path}\"")
  customize_xml_bundle_id(entitlements.path)
  sh("/usr/bin/codesign -f --keychain \"#{keychain_filepath.shellescape}\" -s \"#{cert}\" --entitlements \"#{entitlements.path}\" \"#{app_path}\"")
end

def customize_xml_bundle_id(xml_path, customer_app_id, customer_team_id)
  xml_hash = Plist.parse_xml(xml_path)

  xml_hash['application-identifier'] = customer_app_id
  xml_hash['com.apple.developer.team-identifier'] = customer_team_id if xml_hash.key?('com.apple.developer.team-identifier')

  entitlement_ids.each { |key, value| xml_hash[key] = value if xml_hash.key?(key) }

  xml_hash.save_plist(xml_path)
end
