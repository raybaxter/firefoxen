#! /usr/local/bin/ruby

# These are your multiple installations of Firefox, each with a different profile.
# Add an entry to this hash corresponding to each of the versions of Firefox that 
# you plan to use simultaneously. The profiles must
# For reference, here is the default Firefox:
#
# VERSIONS = [
#     :path => "/Applications",
#     :name => "Firefox",
#     :profile => "default"   
# ]

VERSIONS = [
  { :name => "Firefox2",     :profile => "firefox-2" },
  { :name => "Firefox3"   },
  { :name => "Firefox3.1b1", :profile => "firefox-3b" }, 
  { :name => "Minefield",    :profile => "minefield" },
]

# You don't need to change anything below this line.

DEFAULTS =  { :path => "/Applications", 
              :name => "Firefox" , 
              :executable_name => "firefox-bin",
              :profile => "default"
}

INSTALL_DEFAULTS = {
  :executable_name => "launch-ff"
}

def set_defaults(bundle_path, executable)
  plist = "#{bundle_path}/Contents/Info"
  system "defaults write #{plist} CFBundleExecutable '" + "#{executable}" +"'"
end

def installing?
  @installing = @installing.nil? ? true : @installing
end

def add_executable(executable, bundle_path, profile="default")
  local_path = "#{bundle_path}/Contents/MacOS"
  path_to_executable = "#{local_path}/#{executable}"
  
  contents = "#!/bin/sh\n#{local_path}/firefox-bin -P #{profile}"
  File.open(path_to_executable, "w").puts(contents)
  File.chmod(0755, path_to_executable)
end

def ls_register
  @first = @first.nil? ? true : false
  command = "/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister "
  command += @first ? "{command -kill }" : ""
  command
end

def register_command(bundle)
  `#{ls_register} -f #{bundle} -apps -u`
end

def install_or_remove(versions)
  results = []
  versions.each do |values|
    version = DEFAULTS.merge(values)
    version = version.merge(INSTALL_DEFAULTS) if installing?
    
    bundle_path = "#{version[:path]}/#{version[:name]}.app"
    executable_name = version[:executable_name]

    add_executable(executable_name, bundle_path, version[:profile]) if installing?
    set_defaults(bundle_path, executable_name) 

    result = register_command(bundle_path)
    results <<  result if results.size > 0
  end
  (results.size > 0) ? results : 0
end

def set_local_defaults()
  @installing = true
  @versions = VERSIONS
end

if $0 == __FILE__
  
  set_local_defaults()
  install_or_remove(@versions)
  
end

