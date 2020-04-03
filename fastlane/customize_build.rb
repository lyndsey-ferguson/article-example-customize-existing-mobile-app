
def customize_build(options)
  welcome_message = options[:welcome_message] || 'Hello World!'
  background_color = options[:background_color] || '#FFFFFFFF'

  update_plist(
    plist_path: './AppExample/AppExample/configurations.plist',
    block: proc do |plist|
      plist[:WelcomeMessage] = welcome_message
      plist[:BackgroundHexColor] = background_color
    end
  )
end
