Pod::Spec.new do |s|

  s.name         = "DNFoundation"
  s.version      = "0.0.1"
  s.summary      = "A short description of DNFoundation."
  s.description  = <<-DESC
                   A longer description of DNFoundation in Markdown format.
                   DESC
  s.homepage     = "https://gitlab.com/daniu/DNFoundation"
  s.license      = "MIT"
  s.author       = { "cjingzhou21" => "cjingzhou21@gmail.com" }
  s.source       = { :git => "git@gitlab.com:daniu/DNFoundation.git", :tag => "0.0.1" }
  s.exclude_files = "Classes/Exclude"
  s.frameworks = 'SystemConfiguration','MobileCoreServices','QuartzCore','CoreTelephony','OpenGLES','CoreLocation','GLKit', 'CoreGraphics', 'Security'
  s.libraries = 'crypto', 'ssl'
  s.source_files  = "**/*.{h,m,mm,cpp,c}"
  s.resources     = '**/*.{xib,bundle,caf}'
  s.vendored_libraries = '**/*.a'
  s.ios.vendored_frameworks = '**/*.framework'
  s.ios.deployment_target = "8.0"
  s.requires_arc = true

  # s.dependency 'OpenSSL', '~> 1.0.208'

  s.xcconfig = {
    'LIBRARY_SEARCH_PATHS'  => '${PODS_ROOT}/DNFoundation',
    'HEADER_SEARCH_PATHS'   => '"$(SDKROOT)/usr/include/libxml2"',
    'OTHER_LDFLAGS'         => '-ObjC -lxml2'
   }

end
