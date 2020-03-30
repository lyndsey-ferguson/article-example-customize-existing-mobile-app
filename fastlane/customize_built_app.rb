require_relative 'binary_plist'

def customize_built_app(options)
  customer_assets = 'puppy'

  customer_appiconset_dirpath = File.absolute_path("../#{customer_assets}/#{customer_assets}.appiconset")

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
          # unlock keychain
          # get customer profile, code signing id, and team id
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
