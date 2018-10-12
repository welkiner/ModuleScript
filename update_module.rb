#!/usr/local/bin/ruby
require 'fileutils'
require 'date'
require 'json'
require 'cocoapods'
$projPath =  ARGV[0]
Dir::chdir("#{$projPath}")
if ARGV[1] == "--delete"
    FileUtils.rm_rf("moduleInfo.tmp")
    puts "success"
    return
end
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8
json = File.read('moduleInfo.tmp')
FileUtils.rm_rf("moduleInfo.tmp")
obj = JSON.parse(json)
if !obj
    puts "Error,invalid module"
    return
end
FileUtils.rm_rf("temp")
Dir.mkdir("temp")

File.open("#{obj["specName"]}.podspec","r+") do |oldf|
    File.open("temp/#{obj["specName"]}.podspec","w") do |f|
        oldf.read.split("\n").each { |l|
            if l.include?":svn"
                str = "#{l.split("=")[0]} = {:svn => '#{obj["svnURL"]}', :revision=>'#{obj["svnRev"]}'}"
                f.write("#{str}\n")
            else
                f.write("#{l}\n")
            end
        }
    end
end
Pod::Command.run(['repo-svn',"push","HETModuleSpecs","temp/#{obj["specName"]}.podspec"])
FileUtils.rm_rf("temp")
Pod::Command.run(['repo-svn',"update","HETModuleSpecs"])

puts "success"
