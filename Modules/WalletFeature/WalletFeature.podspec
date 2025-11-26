Pod::Spec.new do |s|

  s.name           = 'WalletFeature'
  s.version        = '0.1.0'
  s.summary        = 'Home screen and wallet UI for PaymentWallet.'
  s.description    = 'A modular SwiftUI feature with Home screen and wallet UI.'
  s.homepage       = 'https://github.com/marcellochuahy/PaymentWallet'
  s.license        = { :type => 'MIT', :file => 'LICENSE' }
  s.author         = { 'Marcello Chuahy' => 'marcellochuahy@icloud.com' }
  s.platform       = :ios, '15.0'
  s.swift_versions = ['6.0']
  s.source         = { :path => '.' }

  s.source_files   = 'Sources/WalletFeature/**/*.{swift}'
  s.exclude_files  = 'Tests/**/*'
  
end
