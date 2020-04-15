require 'open-uri'
require 'json'
require 'tempfile'

def download_latest_release(options)
  result = github_api(
    http_method: 'GET',
    path: '/repos/lyndsey-ferguson/CustomizeExistingAppExample/releases/latest',
    api_token: File.read(File.absolute_path('../.github_token'))
  )
  body = JSON.parse(result[:body])

  asset_name_regex = //
  application_bundle_name = ''
  if ENV["FASTLANE_PLATFORM_NAME"] == "ios"
    asset_name_regex = %r{example_release_.+\.zip}
    application_bundle_name = 'package.zip'
  else
    asset_name_regex = %r{app-release-unsigned.apk}
    application_bundle_name = 'android.apk'
  end
  platform_specific_assets = body['assets'].find do |asset|
    asset['name'] =~ asset_name_regex
  end
  browser_download_url = platform_specific_assets["browser_download_url"]

  zipfile = Tempfile.new(['latest_release', '.zip'])
  zipfile.binmode
  open(browser_download_url) do |download|
    zipfile.write(download.read)
  end
  zipfile.close
  latest_release_dir = File.absolute_path('../latest_release')
  FileUtils.mkdir_p(latest_release_dir)
  zip_package_path = File.join(latest_release_dir, application_bundle_name)
  FileUtils.rm_f(zip_package_path)
  FileUtils.cp(zipfile.path, zip_package_path)
  zip_package_path
end

