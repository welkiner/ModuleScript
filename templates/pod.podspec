Pod::Spec.new do |s|

  s.name         = "__ProjectName__"
  s.version      = "1.0.0"
  s.summary      = "__ProjectName__."
  s.requires_arc = true
  s.description  = <<-DESC
                    this is DESC
                   DESC
  s.author = { "HET" => "HET" }
  s.ios.deployment_target = '8.0'
  s.source       = { :svn => "" }

  s.source_files  = "./**/*.{h,m}"
  s.resources = "./**/*.{xcassets,strings,xml,storyboard,xib,xcdatamodeld}"
  s.vendored_libraries = "./**/*.{a}"

end
