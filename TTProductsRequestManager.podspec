Pod::Spec.new do |s|
  s.name             = "TTProductsRequestManager"
  s.version          = "0.1.0"
  s.summary          = "To manage your in-app purchase store."
  s.description      = <<-DESC
                       <p>Sometimes it's a pain to manage a set of store items. This should help.</p>
                       <p>but don't expect much from it. It just does non-consumable one time things.</p>
                       DESC
  s.homepage         = "https://github.com/mmislam101/TTProductsRequestManager"
  s.license          = { :type => "The MIT License (MIT)", :file => "LICENSE" }
  s.author           = { "Mohammed Islam" => "ksitech101@gmail.com" }
  s.source           = { :git => "https://github.com/mmislam101/TTProductsRequestManager.git", :tag => s.version.to_s }

  s.platform         = :ios, '7.0'
  s.requires_arc     = true

  s.source_files     = 'Classes'

  s.frameworks       = 'StoreKit'
end
