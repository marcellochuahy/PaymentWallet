platform :ios, '15.0'

use_frameworks! :linkage => :static
inhibit_all_warnings!

target 'PaymentWallet' do
  
  # Main sources
  pod 'WalletFeature', :path => './Modules/WalletFeatureModule/WalletFeature'
  
  # Unit tests
  target 'PaymentWalletTests' do
    inherit! :search_paths
  end

  # UI tests
  target 'PaymentWalletUITests' do
    inherit! :search_paths
  end
  
end
