#!/usr/local/bin/ruby
#encoding: utf-8
require 'fileutils'
require 'date'
require 'json'
require 'cocoapods-core'
$projPath =  ARGV[0]
$CodeFolder = "ModuleCode"
if (!File::directory?($projPath) ||
    !File::exist?("#{$projPath}/#{$CodeFolder}")||
    Dir["#{$projPath}/*.podspec"].count != 1)
    puts "Error,invalid module"
    return
end

$fileLayers = 0
def svnUpgrade(path)
    Dir::chdir("#{path}")
    if !File::exist?(".svn")    
        if ($fileLayers += 1) > 2
            return
        end
        svnUpgrade("#{path}/..")
    end
    `svn upgrade`
end

svnUpgrade("#{$projPath}")
Dir::chdir("#{$projPath}/#{$CodeFolder}")
svnInfoArray = `svn info`.split("\n")
if (svnInfoArray.count < 5)
    puts "Error,unversioned module"
    return
end

$author
$svnRev
$svnDate
$specName
$svnLog
$moduleVersion
$svnURL
$internalDependency=Hash.new
$externalDependency=Hash.new
Dir::chdir("#{$projPath}")

svnInfoArray.each { |line|
    if line.include?"Last Changed Author: "
        $author = line.sub!("Last Changed Author: ", "") 
        next
    end
    if line.include?"Last Changed Rev: "
        $svnRev = line.sub!("Last Changed Rev: ", "") 
        next
    end
    if line.include?"Last Changed Date: "
        $svnDate =  DateTime.parse(line.sub!("Last Changed Date: ", "").split(" (")[0])
        next
    end
    if line[0,5] == "URL: "
        $svnURL = "http://#{line.split("URL: ")[1].split("@")[1]}"
        next
    end
}
Dir::entries($projPath).each{ |fileName|
    if fileName.include?".podspec"
        $specName = fileName.sub!(".podspec", "")
        break
    end
}
Dir::chdir("#{$projPath}/#{$CodeFolder}")
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8
$svnLog = `env LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 svn log -r #{$svnRev}`
puts $svnLog
$svnLog = $svnLog.split("line\n\n")[1].split("\n------")[0]


Dir::chdir("#{$projPath}")
IO.foreach("#{$specName}.podspec"){ |line|
    if line.include?".version"
        $moduleVersion = line.split("\"")[1]
        break
    end
}


podfile = Pod::Podfile.from_file("#{$projPath}/Podfile")
podfile.target_definitions["ModuleFramework"].dependencies.each{ |dependencie|
    $internalDependency[dependencie.name] = dependencie.requirement.requirements[0][1]
}

 


fileHash = Hash[
    "author" => $author, 
    "svnRev" => $svnRev,
    "svnDate" => $svnDate,
    "specName" => $specName,
    "svnLog" => $svnLog,
    "moduleVersion" => $moduleVersion,
    "svnURL" => $svnURL,
    "internalDependency" => $internalDependency,
    "externalDependency" => $externalDependency
]
file = File.new("moduleInfo.tmp","w")
file.syswrite("#{fileHash.to_json}")
file.close

puts "success"












