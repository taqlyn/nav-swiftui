Pod::Spec.new do |s|
  s.name             = 'TaqlynNavSwiftUI'
  s.version          = '0.1.0'
  s.summary          = 'SwiftUI navigation stack binding for Taqlyn deep links'
  s.description      = <<-DESC
TaqlynNavSwiftUI provides typed DeepLinkNavigator and NavigationStack bindings
for mapping Taqlyn deferred and universal deep links onto SwiftUI navigation flows.
                       DESC
  s.homepage         = 'https://taqlyn.com'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Taqlyn' => 'dev@taqlyn.com' }
  s.source           = { :git => 'https://github.com/taqlyn/nav-swiftui.git', :tag => "v#{s.version}" }

  s.ios.deployment_target = '16.0'
  s.swift_version    = '5.9'

  s.source_files     = 'Sources/TaqlynNavSwiftUI/**/*.{swift}'
  s.frameworks       = 'SwiftUI'
end
