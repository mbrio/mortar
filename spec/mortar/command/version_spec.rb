#
# Copyright 2014 Mortar Data Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
require "spec_helper"
require "mortar/command/version"
require "launchy"

module Mortar::Command
  describe Version do

    before(:each) do
      stub_core
    end
    
    base_url  = "http://install.mortardata.com"
    base_version = "1.0"
    curl_command = "curl -sL -o /tmp/install.sh #{base_url} && sudo bash /tmp/install.sh"

    context("version in prod") do
      it "makes a curl request to download default version" do
        mock(Kernel).system (curl_command)
        
        execute("version:upgrade");
      end
      
      it "makes curl request for different versions when requested" do
        mortar_version = "1.0"
        curl_command_with_version = curl_command +  " -v " + mortar_version
        mock(Kernel).system( curl_command_with_version)
        mock(Kernel).system( curl_command_with_version)
        execute( "version:upgrade -v #{mortar_version}");
        execute( "version:upgrade --version #{mortar_version}");
      end
      
    end

    context("version dev") do
      dev_url = "dev_url.com"
      dev_curl =  "curl -sL -o /tmp/install.sh #{dev_url} && sudo bash /tmp/install.sh" 
      before(:each) do
        ENV['MORTAR_INSTALL'] = dev_url
      end

      it "makes a curl request to download default version on dev" do
        mock(Kernel).system(dev_curl)
        execute("version:upgrade");
      end

    end

    context("version not Mac OSX") do
      it "throws error when not on mac" do
        any_instance_of(Mortar::Command::Version) do |base|
          mock(base).running_on_a_mac? {false} # troubles in mocking this function
          stderr, stdout = execute("version:upgrade");
          stderr.should == <<-STDERR
 !    mortar version:upgrade is currently only supported for OSX.
STDERR

        end
      end
    end
  end
    
end
