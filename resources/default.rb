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

actions :add

attribute :name, :kind_of => String, :name_attribute => true
attribute :url, :kind_of => String, :required => true
attribute :version, :kind_of => String, :default => nil
attribute :owner, :kind_of => String, :default => 'root'
attribute :group, :kind_of => [String, Fixnum], :default => 0
attribute :umask, :kind_of => String, :default => nil

attribute :prefix, :kind_of => String, :default => nil
attribute :extract_action, :equal_to => ['unzip', 'unzip_and_strip_dir', nil], :default => nil
attribute :publish_container_dir_to, :kind_of => String, :default => nil
attribute :publish_artifact_location_to, :kind_of => String, :default => nil

default_action :add

def base_directory
  "#{(prefix || '/usr/local')}/#{name}"
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

