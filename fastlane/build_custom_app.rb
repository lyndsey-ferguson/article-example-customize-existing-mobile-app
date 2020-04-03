
def build_custom_app(options)
  customize_build options
  keychain_data = get_keychain_from_vault(vault_addr: 'http://127.0.0.1:8200', keychain_name: 'lyndsey', keychain_path: '/Users/lyndsey.ferguson/Library/Keychains/lyndsey.keychain-db')
  unlock_keychain(path: keychain_data[:keychain_path], password: keychain_data[:keychain_password], set_default: true)
  disable_automatic_code_signing(path: './AppExample/AppExample.xcodeproj')
  update_project_provisioning(
    xcodeproj: './AppExample/AppExample.xcodeproj',
    profile: "./AppExample/Yillyyally.mobileprovision",
    build_configuration: "Release",
    code_signing_identity: "Apple Distribution: Jedidiah Fonner (57738V598V)"
  )
  update_project_team(
    path: './AppExample/AppExample.xcodeproj',
    teamid: '57738V598V'
  )
  build_app(
      scheme: 'AppExample',
      project: './AppExample/AppExample.xcodeproj',
      output_directory: 'test_output',
      output_name: 'example.ipa',
      export_options: {
        method: "app-store",
        provisioningProfiles: {
          "com.yilly.yally" => "359e767c-5f71-4b2e-aedd-17645f951e02"
        }
      },
      export_team_id: '57738V598V',
      xcargs: 'CODE_SIGN_IDENTITY="Apple Distribution: Jedidiah Fonner (57738V598V)"'
  )
end

