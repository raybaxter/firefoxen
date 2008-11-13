#! /usr/local/bin/ruby

# These are your multiple installations of Firefox, each with a different profile.
# Add an entry to this hash corresponding to each of the versions of Firefox that 
# you plan to use simultaneously. In order to use two versions of Firefox simultaneously,
# they must have separate profiles. 
#
# For reference, here is the default Firefox:
#
# VERSIONS = [
#  { :path => "/Applications", :name => "Firefox", :profile => "default" }
# ]
#
# Thanks to Jonathan Barnes and Joe Moore, you can also call Firefoxen from the command 
# line, passing in a name and a profile to configure one version of Firefox at a time. 
# See below.
#

class Firefoxen
  
  DEFAULTS =  { :path => "/Applications", 
                :name => "Firefox" , 
                :profile => "default"
  }

  def self.install(versions)
    self.new(versions).run
  end
  
  def self.remove(versions)
    self.new(versions,false).run
  end

  attr_accessor :installing
    
  def initialize(versions, installing=true)
    @installing = installing
    @versions = versions
  end
  
  def set_defaults(bundle_path, executable="firefox-bin")
    plist = "#{bundle_path}/Contents/Info"
    system "defaults write #{plist} CFBundleExecutable '" + "#{executable}" +"'"
  end

  def installing?
    @installing 
  end

  def add_executable(bundle_path, profile="default")
    local_path = "#{bundle_path}/Contents/MacOS"
    path_to_executable = "#{local_path}/launch-ff"
  
    contents = "#!/bin/sh\n#{local_path}/firefox-bin -P #{profile}"
    File.open(path_to_executable, "w") do |f| 
      f.puts(contents) 
      f.chmod(0755)
    end
  end
  
  def remove_executable(bundle_path)
    local_path = "#{bundle_path}/Contents/MacOS"
    path_to_executable = "#{local_path}/launch-ff"
    `rm -f #{path_to_executable}`
  end

  def ls_register
    # @first = @first.nil? ? true : false
    command = "/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister "
    # command += @first ? "{command -kill }" : ""
    command
  end

  def register_command(bundle)
    `#{ls_register} -f #{bundle} -apps -u`
  end

  def run()
    results = []
    @versions.each do |values|
      version = DEFAULTS.merge(values)
    
      bundle_path = "#{version[:path]}/#{version[:name]}.app"
      executable_name = version[:executable_name]

      if installing?
        add_executable(bundle_path, version[:profile])
        set_defaults(bundle_path,"launch-ff") 
      else
        remove_executable(bundle_path)        
        set_defaults(bundle_path) 
      end

      result = register_command(bundle_path)
      results <<  result if results.size > 0
    end
    (results.size > 0) ? results : 0
  end
end

def usage
  puts <<-end
    Usage: #{__FILE__} - modify all versions of Firefox
       or: #{__FILE__} AppName ProfileName - modfiy a single Firefox instance
       or: #{__FILE__} -r - revert all versions of Firefox to default

    end
  exit(0)
end

if $0 == __FILE__

  VERSIONS = [
     { :name => "Firefox2",      :profile => "firefox-2"  },
     { :name => "Firefox3",                               },
     { :name => "Firefox3.1b1",  :profile => "firefox-3b" },
     { :name => "Minefield",     :profile => "minefield"  },
   ]
  
  installing = true
  versions = VERSIONS  

  case ARGV.length
  when 0
  when 1 
    if ARGV[0].chomp == "-r"
      installing = false
    else
      usage
    end
  when 2
    versions = [{:name => ARGV[0], :profile => ARGV[1]}]
  else
    usage
  end
  
  if installing
    Firefoxen.install(versions)
  else
    Firefoxen.remove(versions)
  end
end

