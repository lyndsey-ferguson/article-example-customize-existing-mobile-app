require 'open-uri'
require 'json'
require 'tempfile'

def download_latest_release(options)
  # use GitHub's REST endpoint to download the latest release
  result = github_api(
    http_method: 'GET',
    path: '/repos/lyndsey-ferguson/CustomizeExistingAppExample/releases/latest',
    api_token: File.read(File.absolute_path('../.github_token'))
  )
  body = JSON.parse(result[:body])

  # Set up the regex and name for Android or iOS
  asset_name_regex = //
  application_bundle_name = ''
  if ENV["FASTLANE_PLATFORM_NAME"] == "ios"
    asset_name_regex = %r{example_release_.+\.zip}
    application_bundle_name = 'package.zip'
  else
    asset_name_regex = %r{app-release-unsigned.apk}
    application_bundle_name = 'android.apk'
  end
  # Find the name of the Android or iOS released app
  platform_specific_assets = body['assets'].find do |asset|
    asset['name'] =~ asset_name_regex
  end
  browser_download_url = platform_specific_assets["browser_download_url"]

  # download the release to a temporary file
  zipfile = Tempfile.new(['latest_release', '.zip'])
  zipfile.binmode
  open(browser_download_url) do |download|
    zipfile.write(download.read)
  end
  zipfile.close
  latest_release_dir = File.absolute_path('../latest_release')
  FileUtils.mkdir_p(latest_release_dir)
  zip_package_path = File.join(latest_release_dir, application_bundle_name)

  # copy the downloaded release to a local directory
  FileUtils.rm_f(zip_package_path)
  FileUtils.cp(zipfile.path, zip_package_path)
  zip_package_path
end

