require 'yaml'
require_relative 'binary_plist'
require_relative 'android_customize_build'
require 'pry-byebug'

def customize_built_app(options)
  sh('which apktool')
  # we expect that apktool is installed, `brew install apktool`

  # a handy default for quick iterations
  customer_assets = options[:customer_assets] || ENV['APPIAN_CUSTOMER_ASSETS'] || 'puppy'
  customer_config_filepath = File.absolute_path("../#{customer_assets}/#{customer_assets}.yaml")
  if File.exist?(customer_config_filepath)
    customer_config_file = YAML.load_file(customer_config_filepath)
    welcome_message = customer_config_file['WelcomeMessage'] || 'Hello World!'
    background_color = customer_config_file['BackgroundHexColor'] || '#FFFFFFFF'
  end
  welcome_message = options[:welcome_message] unless options[:welcome_message].nil?
  background_color = options[:background_color] unless options[:background_color].nil?

  example_apk_path = download_latest_release
  # unzip the apk into a tmp directory

  custom_built_app_path = File.expand_path(File.join('~/Desktop', "#{customer_assets}.apk"))

  Dir.mktmpdir("customize_built_app") do |unzipped_apk_path|
    Dir.chdir(unzipped_apk_path) do
      apktool(
        apk: example_apk_path,
        build: false
      )
      byebug
      apktool(
	apk: custom_built_app_path,
        build: true
      )
    end
  end
  puts "Built mobile app: #{custom_built_app_path}"
end

def apktool(params)
  unzip_command = "d #{params[:apk]} -o . -f"
  zip_command = "b . -o #{params[:apk]}"
  sh("apktool #{params[:build] ? zip_command : unzip_command}")
end
