#!/usr/local/bin/ruby

require 'xcodeproj'
require 'fileutils'
require 'cocoapods'
require 'mini_magick'
ENV["PATH"] = "#{ENV["PATH"]}:/usr/local/bin"
$projPath =  ARGV[0]
$moduleName = ARGV[1]
$moduleDemoName = ARGV[2]
$classPrefix = ARGV[3]

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
FileUtils.cp "#{__dir__}/templates/pod.podspec", "#{$moduleName}.podspec"
FileUtils.mv "#{$moduleName}/ModuleFramework.h", "#{$moduleName}/#{$moduleName}.h"

Xcodeproj::Project.new("#{$moduleName}.xcodeproj").save
proj = Xcodeproj::Project.open("#{$moduleName}.xcodeproj")
proj.main_group.new_group("ModuleCode","./ModuleCode")
proj.root_object.attributes["CLASSPREFIX"] = "#{$classPrefix}"
group = proj.main_group.new_group($moduleName,"./#{$moduleName}")
moduleHeaderRef = proj.main_group.new_file("#{$moduleName}/#{$moduleName}.h")
podspecRef = proj.main_group.new_file("#{$moduleName}.podspec")
podspecRef.xc_language_specification_identifier = 'xcode.lang.ruby'
podspecRef.set_last_known_file_type("text")
proj.main_group.children.reverse!

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

target = proj.new_target(:application,$moduleDemoName,:ios)
target.build_configuration_list.set_setting('INFOPLIST_FILE', "#{$moduleName}/Info.plist")
target.add_resources([sourceRef1,sourceRef2,sourceRef3])
target.add_file_references([ref1,ref2,ref10])
target.build_configurations.each do |config|
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "com.het.#{$moduleDemoName.gsub(/_/, '-')}"
    config.build_settings['CODE_SIGN_IDENTITY[sdk=iphoneos*]'] = "iPhone Developer"
    config.build_settings['CODE_SIGN_STYLE[sdk=iphoneos*]'] = "Manual"
    config.build_settings['DEVELOPMENT_TEAM[sdk=iphoneos*]'] = "WU2WFZ2B66"
    config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = "developAll"
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = "9.0"
    config.build_settings['TARGETED_DEVICE_FAMILY'] = "1"
end
moduleTarget = proj.new_target(:framework,$moduleName,:ios)
moduleTarget.add_file_references([moduleHeaderRef])
moduleTarget.build_configuration_list.set_setting('INFOPLIST_FILE', "#{$moduleName}/ModuleFrameworkInfo.plist")
moduleTarget.build_configurations.each do |config|
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "com.het.#{$moduleName.gsub(/_/, '-')}"
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = "9.0"
    config.build_settings['TARGETED_DEVICE_FAMILY'] = "1"
    config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
    config.build_settings['CLANG_WARN_STRICT_PROTOTYPES'] = 'NO'
    config.build_settings['MACH_O_TYPE'] = "staticlib"
end

target.add_dependency(moduleTarget)
proj.files.each{| reference|
    if reference.path == "#{$moduleName}.framework"
        embedPhase = target.new_copy_files_build_phase("Embed Frameworks")
        embedPhase.symbol_dst_subfolder_spec = :frameworks
        bf = embedPhase.add_file_reference(reference)
        bf.settings = { "ATTRIBUTES" => ["CodeSignOnCopy"] }
        target.frameworks_build_phases.add_file_reference(reference)
    end
}
proj.save


File.open("Podfile","r:utf-8") do |lines|
    buffer = lines.read.gsub("__ProjectName__",$moduleName).gsub("__ProjectDemoName__",$moduleDemoName)
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

def drawIcon(imgName, size)
    img = MiniMagick::Image.new(imgName)  
    img.combine_options do |c|
        c.fill 'black'
        c.gravity 'center' 
        c.pointsize size
        c.draw "text 0,0 '#{$moduleName.scan(/.{1,8}/).join("\n")}'"
    end
end

Dir::chdir("#{$moduleName}/Assets.xcassets/AppIcon.appiconset")
drawIcon "icon3.png",33
drawIcon "icon2.png",22

Dir::chdir("#{$projPath}/#{$moduleName}")
Pod::Command.run(['install'])
puts "success"
