require 'firefoxen'

describe Firefoxen do
  
  before(:all) do
    @versions = [
      {:path => "/tmp", :name => "F1", :profile => "pf1"},
      {:path => "/tmp", :name => "F2", :profile => "pf2"}
    ]
    
    @versions.each do |v|
      path_name = "#{v[:path]}/#{v[:name]}.app"
      `rm -rf #{path_name}`
      `mkdir -p #{path_name}/Contents/MacOS`
    end
    
    @ff = Firefoxen.new(@versions)
  end
  
  describe "run" do
    it "should not raise" do
      begin
        @ff.run()  
        true
      rescue Exception
        fail
      end.should be_true
    end
  end
  
  describe "add_executable, default profile name" do
    before(:all) do
      @ff.add_executable("/tmp/F1")
      @executable_file_path = "/tmp/F1/Contents/MacOS/launch-ff"
      @contents = File.read(@executable_file_path)
    end
      
    it "should write an executable file when installing" do
      File.exists?(@executable_file_path).should be_true
      File.executable?(@executable_file_path).should be_true
    end

    it "should have the correct default profile" do
      @contents.split(/\n/)[1].gsub(/^.* /, "").should == "default"
    end
    
    it "should should have the correct path in the executable file" do
      @contents.split(/\n/)[1].gsub(/ .*/, "") == @executable_file_path
    end
    
  end

  describe "add_excutable, custom profile name" do
    it "should have the custom profile name" do
      @ff.add_executable("/tmp/F1", "custom")
      executable_file_path = "/tmp/F1/Contents/MacOS/launch-ff"
      contents = File.read(executable_file_path)
      contents.split(/\n/)[1].gsub(/^.* /, "").should == "custom"
    end
  end

  describe "set_defaults" do
    it "should write the name of the executable file to the Info.plist" do
      @ff.set_defaults("/tmp/F1", "fake_exe")
      `defaults read /tmp/F1/Contents/Info CFBundleExecutable`.chomp.should == "fake_exe"
    end
    
    it "should restore the name of the executable file to the defalult in the Info.plist" do
      @ff.set_defaults("/tmp/F1", "fake_exe")
      @ff.set_defaults("/tmp/F1")
      `defaults read /tmp/F1/Contents/Info CFBundleExecutable`.chomp.should == "firefox-bin"
    end
    
  end
  
  describe "command line" do
    it "should work" do
      result = system "./firefoxen.rb"
      result.should == true
    end
    
    it "should be reversible" do
      write_test_results = "bash ./spec/test.sh 2>&1 1> /dev/null"

      `./firefoxen.rb -r`
      out1 = `#{write_test_results}`
      `./firefoxen.rb`
      out2 = `#{write_test_results}`
      
      `./firefoxen.rb -r`
      out3 = `#{write_test_results}`
      `./firefoxen.rb`
      out4 = `#{write_test_results}`
      
      out1.should_not == out2
      out1.should == out3
      out2.should == out4
    end
    
  end
  
end