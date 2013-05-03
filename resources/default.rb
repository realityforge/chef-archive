#
# Copyright 2011, Peter Donald
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

=begin
#<
The LWRP downloads an archive and places in a local versioned directory and
symlinks the current version.

The LWRP first creates a container directory based on the name and the prefix. Under the
container directory, there is a directory in which all the versions of the artifact are
stored. The LWRP will download the artifact and place it in this directory and then symlink
the "current" directory to the downloaded artifact.

By default the LWRP will retain the directory for the last artifact downloaded.

@action add Download and extract archive.

@section Examples

    # Download the myapp.zip archive, extract, strip the
    # top level dir and place results into /usr/loca/myapp/pkg/1.0
    # and symlink /usr/loca/myapp/pkg/current to /usr/loca/myapp/pkg/1.0
    archive 'myapp' do
      url "http://example.com/myapp.zip"
      version '1.0'
      owner 'myapp'
      group 'myapp'
      extract_action 'unzip_and_strip_dir'
    end

    # Download the myapp.jar and place set the attribute
    # myapp.home_dir to the container dir (i.e. /usr/local/myapp) and
    # myapp.jar_location to the downloaded jar. (i.e. /usr/loca/myapp/pkg/current/myapp-1.0.jar)
    archive 'myapp' do
      url "http://example.com/myapp.jar"
      version '1.0'
      owner 'myapp'
      group 'myapp'
      publish_container_dir_to 'myapp.home_dir'
      publish_artifact_location_to 'myapp.jar_location'
    end

#>
=end

actions :add

#<> @attribute name The logical name of the artifact. Used when creating the container directory.
attribute :name, :kind_of => String, :name_attribute => true
#<> @attribute url The url from which to download the resource.
attribute :url, :kind_of => String, :required => true
#<> @attribute version The version of the archive. Should be set, otherwise will be derived as a hash of the url parameter.
attribute :version, :kind_of => String, :default => nil
#<> @attribute owner The owner of the container directory and created artifacts.
attribute :owner, :kind_of => String, :default => 'root'
#<> @attribute group The group of the container directory and created artifacts.
attribute :group, :kind_of => [String, Fixnum], :default => 0
#<> @attribute umask The umask used when setting up the archive.
attribute :umask, :kind_of => String, :default => nil

#<> @attribute prefix The directory in which the archive is unpacked.
attribute :prefix, :kind_of => String, :default => '/usr/local'
#<> @attribute extract_action The action to take with the downloaded archive. Defaults to leaving the archive un-extracted but can also unzip or unzip and stript the first directory.
attribute :extract_action, :equal_to => ['unzip', 'unzip_and_strip_dir', nil], :default => nil

#<> @attribute publish_container_dir_to The dot separated node attribute to set to the container directory. This occurs at resource definition time.
attribute :publish_container_dir_to, :kind_of => String, :default => nil
#<> @attribute publish_artifact_location_to The dot separated node attribute to set to the artifact location. This occurs at resource definition time.
attribute :publish_artifact_location_to, :kind_of => String, :default => nil

default_action :add

def base_directory
  "#{prefix}/#{name}"
end

def derived_version
  require 'digest/sha1'

  version || Digest::SHA1.hexdigest(url)
end

def package_directory
  "#{base_directory}/pkg"
end

def target_directory
  "#{package_directory}/#{name}-#{derived_version}"
end

def target_artifact
  if 'unzip_and_strip_dir' == extract_action || 'unzip' == extract_action
    target_directory
  else
    "#{target_directory}/#{local_filename}"
  end
end

def local_filename
  "#{name}-#{derived_version}#{::File.extname(url)}"
end

def after_created
  if publish_container_dir_to
    Chef::AttributeBlender.blend_attribute_into_node(node, publish_container_dir_to, base_directory)
  end
  if publish_artifact_location_to
    Chef::AttributeBlender.blend_attribute_into_node(node, publish_artifact_location_to, target_artifact)
  end
end

