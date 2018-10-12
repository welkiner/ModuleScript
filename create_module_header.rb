#!/usr/local/bin/ruby
#encoding: utf-8
require 'xcodeproj'
require 'fileutils'

$projPath =  ARGV[0]
$moduleName
$target
Dir::chdir("#{$projPath}")

if (!File::directory?($projPath) ||
    Dir["#{$projPath}/*.podspec"].count != 1)
    puts "Error,invalid module"
    return
end
$moduleName = File.basename(Dir["#{$projPath}/*.podspec"][0]).match(/(.*).podspec/)[1]

if Dir["#{$projPath}/#{$moduleName}/#{$moduleName}.h"].count != 1
    puts "Error,invalid module"
    return
end




proj = Xcodeproj::Project.open("#{$moduleName}.xcodeproj")

$target =proj.targets.detect{|e|
    e.name == "#{$moduleName}"
}

files =  $target.headers_build_phase.files

# files = files.map {|file|
#     "#import \"#{file.display_name}\""
# }


File.open("#{$projPath}/#{$moduleName}/#{$moduleName}.h", "w+") do |aFile|
    aFile.syswrite("//
//  #{$moduleName}.h
//
//  Created by HET on 2018/5/31.
//  Copyright © 2018年 HET. All rights reserved.
//

#import <UIKit/UIKit.h>
        
//! Project version number for #{$moduleName}.
FOUNDATION_EXPORT double #{$moduleName}VersionNumber;

//! Project version string for #{$moduleName}.
FOUNDATION_EXPORT const unsigned char #{$moduleName}VersionString[];
        
// In this header, you should import all the public headers of your framework using statements like #import <#{$moduleName}/PublicHeader.h>
")
    files.each {|file|
        aFile.syswrite("#import \"#{file.display_name}\"\n")
    }
end
