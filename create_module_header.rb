#!/usr/local/bin/ruby
#encoding: utf-8
require 'xcodeproj'
require 'fileutils'

$projPath =  ARGV[0]
$moduleName = ARGV[1]
$target
Dir::chdir("#{$projPath}")

if (!File::directory?($projPath) ||
    Dir["#{$projPath}/#{$moduleName}/ModuleFramework.h"].count != 1)
    puts "Error,invalid module"
    return
end

proj = Xcodeproj::Project.open("#{$moduleName}.xcodeproj")

$target =proj.targets.detect{|e|
    e.name == "ModuleFramework"
}

files =  $target.headers_build_phase.files

# files = files.map {|file|
#     "#import \"#{file.display_name}\""
# }


File.open("#{$projPath}/#{$moduleName}/ModuleFramework.h", "w+") do |aFile|
    aFile.syswrite("//
//  ModuleFramework.h
//
//  Created by HET on 2018/5/31.
//  Copyright © 2018年 HET. All rights reserved.
//

#import <UIKit/UIKit.h>
        
//! Project version number for ModuleFramework.
FOUNDATION_EXPORT double ModuleFrameworkVersionNumber;

//! Project version string for ModuleFramework.
FOUNDATION_EXPORT const unsigned char ModuleFrameworkVersionString[];
        
// In this header, you should import all the public headers of your framework using statements like #import <ModuleFramework/PublicHeader.h>
")
    files.each {|file|
        aFile.syswrite("#import \"#{file.display_name}\"\n")
    }
end
