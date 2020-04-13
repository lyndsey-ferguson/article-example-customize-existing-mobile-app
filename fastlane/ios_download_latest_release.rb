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
  browser_download_url = body["assets"].first["browser_download_url"]

  zipfile = Tempfile.new(['latest_release', 'zip'])
  zipfile.binmode
  open(browser_download_url) do |download|
    zipfile.write(download.read)
  end
  zipfile.close
  latest_release_dir = File.absolute_path('../latest_release')
  FileUtils.mkdir_p(latest_release_dir)
  zip_package_path = File.join(latest_release_dir, 'package.zip')
  FileUtils.rm_f(zip_package_path)
  FileUtils.cp(zipfile.path, zip_package_path)
  zip_package_path
end

