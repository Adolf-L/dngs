
Pod::Spec.new do |s|

  s.name         = "DNFeature"
  s.version      = "0.0.1"
  s.summary      = "A short description of DNFeature."
  s.description  = <<-DESC
                   A longer description of DNFeature in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "https://gitlab.com/daniu/DNFeature"
  s.license      = "MIT"
  s.author       = { "cjingzhou21" => "cjingzhou21@gmail.com" }
  s.source       = { :git => "git@gitlab.com:daniu/DNFeature.git", :tag => "0.0.1" }
  s.source_files  = "**/*.{h,m,mm,pch}"
  s.exclude_files = "Classes/Exclude"
  s.resources     = '**/*.{xib,bundle}'
  s.ios.deployment_target = "8.0"
  s.requires_arc = true
  s.prefix_header_file = 'DNFeaturePrefix.pch'

  s.xcconfig = {
    'HEADER_SEARCH_PATHS'   => '"$(SRCROOT)/DNFoundation/DNThird/OpenSSL"'
   }

end

