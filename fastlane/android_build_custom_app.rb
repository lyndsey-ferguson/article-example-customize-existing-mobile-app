require 'pry-byebug'

def build_custom_app(options)
  unsigned_unaligned_apk_path = "../AndroidExample/app/build/outputs/apk/release/app-release-unsigned.apk"
  unsigned_aligned_apk_path = "../AndroidExample/app/build/outputs/apk/release/app-release-unsigned-aligned.apk"
  signed_apk_path = "../AndroidExample/app/build/outputs/apk/release/app-release.apk"
  FileUtils.rm_rf([unsigned_aligned_apk_path, signed_apk_path])
  keystore_path = prompt(
    text: "Keystore: "
  )
  keystore_password = prompt(
    text: "Keystore password: ",
    secure_text: true
  )
  sh("zipalign -v -p 4 #{unsigned_unaligned_apk_path} #{unsigned_aligned_apk_path}")
  sh("apksigner sign --ks #{keystore_path} --ks-pass pass:'#{keystore_password}' --out #{signed_apk_path} #{unsigned_aligned_apk_path}")
end
