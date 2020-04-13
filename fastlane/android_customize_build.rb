
def customize_build(options)
  welcome_message = options[:welcome_message] || 'Hello World!'
  background_color = options[:background_color] || '#FFFFFFFF'
  strings_filepath = options[:config_filepath] || '../AndroidExample/app/src/main/res/values/strings.xml'

  byebug
  strings_file = REXML::Document.new(File.read(strings_filepath))
  background_color_element = REXML::XPath.first(strings_file, "//color[@name='background']")
  background_color_element.text = background_color

  hello_first_fragment_element = REXML::XPath.first(strings_file, "//string[@name='hello_first_fragment']")
  hello_first_fragment_element.text = welcome_message

  File.open(strings_filepath, 'w') { |file| strings_file.write file }
end
