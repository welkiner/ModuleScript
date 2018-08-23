#!/usr/local/bin/ruby

require 'xcodeproj'
require 'fileutils'
require 'cocoapods'


$projPath =  ARGV[0]
$moduleName = ARGV[1]
$classPrefix = ARGV[2]

if Dir.exist?("#{$projPath}/#{$moduleName}")
    FileUtils.rm_r "#{$projPath}/#{$moduleName}"
end

Dir::mkdir("#{$projPath}/#{$moduleName}")
Dir::chdir("#{$projPath}/#{$moduleName}")
Dir::mkdir("#{$moduleName}")
Dir::mkdir("ModuleCode")

FileUtils.cp_r Dir["#{__dir__}/templates/TemplateApp/**"], "#{$moduleName}/"
FileUtils.cp_r Dir["#{__dir__}/templates/Podfile"], "./"
FileUtils.cp_r Dir["#{__dir__}/templates/README.md"], "./"
FileUtils.cp "#{__dir__}/templates/pod.podspec", "./#{$moduleName}.podspec"

Xcodeproj::Project.new("#{$moduleName}.xcodeproj").save
proj = Xcodeproj::Project.open("#{$moduleName}.xcodeproj")
proj.main_group.new_group("ModuleCode","./ModuleCode")
group = proj.main_group.new_group($moduleName,"./#{$moduleName}")


group.new_reference("AppDelegate.h")
ref1 = group.new_reference("AppDelegate.m")
sourceRef1 = group.new_reference("Assets.xcassets")
group.new_reference("ViewController.h")
ref2 = group.new_reference("ViewController.m")
sourceRef2 = group.new_reference("Base.lproj/LaunchScreen.storyboard")
sourceRef3 =group.new_reference("Base.lproj/Main.storyboard")
supportingGroup = group.new_group("Supporting Files")
ref10 = supportingGroup.new_reference("main.m")
supportingGroup.new_reference("Info.plist")

target = proj.new_target(:application,$moduleName,:ios)
target.build_configuration_list.set_setting('INFOPLIST_FILE', "$(SRCROOT)/#{$moduleName}/Info.plist")
target.add_resources([sourceRef1,sourceRef2,sourceRef3])
target.add_file_references([ref1,ref2,ref10])
target.build_configurations.each do |config|
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "com.het.#{$moduleName}"
    config.build_settings['CODE_SIGN_IDENTITY[sdk=iphoneos*]'] = "iPhone Developer"
    config.build_settings['CODE_SIGN_STYLE[sdk=iphoneos*]'] = "Manual"
    config.build_settings['DEVELOPMENT_TEAM[sdk=iphoneos*]'] = "WU2WFZ2B66"
    config.build_settings['PROVISIONING_PROFILE'] = "5974953f-9180-4a3e-bf3e-744ffc5bed16"
    config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = "developAll"
end
proj.save
File.open("Podfile","r:utf-8") do |lines|
    buffer = lines.read.gsub("__ProjectName__",$moduleName)
    File.open("Podfile","w"){|l|
        l.write(buffer)
        break
    }
end
File.open("#{$moduleName}.podspec","r:utf-8") do |lines|
    buffer = lines.read.gsub("__ProjectName__",$moduleName)
    File.open("#{$moduleName}.podspec","w"){|l|
        l.write(buffer)
        break
    }
end

Pod::Command.run(['install'])
puts "success"
