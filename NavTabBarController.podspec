Pod::Spec.new do |s|
  s.name         = "NavTabBarController"
  s.version      = "0.0.1"
  s.summary      = "A news client NavTabBarController."
  s.description  = <<-DESC
  A news client NavTabBarController.一个新闻客户端的NavTabBarController.
                   DESC
  s.homepage     = "https://github.com/Jvaeyhcd/NavTabBarController"
  # s.screenshots  = "https://raw.githubusercontent.com/Jvaeyhcd/NavTabBarController/master/1.gif"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Jvaeyhcd" => "chedahuang@icloud.com" }
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/Jvaeyhcd/NavTabBarController.git", :tag => s.version.to_s }
  s.source_files = "NavTabBarController/**/*.{swift}"
  s.requires_arc = true
end
