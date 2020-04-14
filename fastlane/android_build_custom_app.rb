require 'pry-byebug'

def build_custom_app(options)
  unsigned_unaligned_apk_path = "../AndroidExample/app/build/outputs/apk/release/app-release-unsigned.apk"
  unsigned_aligned_apk_path = "../AndroidExample/app/build/outputs/apk/release/app-release-unsigned-aligned.apk"
  signed_apk_path = "../AndroidExample/app/build/outputs/apk/release/app-release.apk"
  FileUtils.rm_rf([unsigned_aligned_apk_path, signed_apk_path])
  keystore_data = get_keystore_from_vault(
    vault_addr: 'http://127.0.0.1:8200',
    keystore_name: 'lyndsey'
  )
  keystore_path = keystore_data[:keystore_path]
  keystore_password = keystore_data[:keystore_password]
  sh("zipalign -v -p 4 #{unsigned_unaligned_apk_path} #{unsigned_aligned_apk_path}")
  sh("apksigner sign --ks #{keystore_path} --ks-pass pass:'#{keystore_password}' --out #{signed_apk_path} #{unsigned_aligned_apk_path}")
end
