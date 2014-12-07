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

use_inline_resources

action :add do
  current_directory = "#{new_resource.package_directory}/current"
  archive_exists = ::File.exists?(new_resource.target_artifact)

  Chef::Log.info "Archive #{new_resource.name} => #{new_resource.target_artifact} Exists? #{archive_exists}"

  unless archive_exists

    cached_package_filename = nil
    delete_cached_package = true
    if new_resource.url =~ /^file\:\/\//
      cached_package_filename = new_resource.url[7, new_resource.url.length]
      delete_cached_package = false
    else
      cached_package_filename = "#{Chef::Config[:file_cache_path]}/#{new_resource.local_filename}"

      remote_file cached_package_filename do
        not_if { archive_exists }
        source new_resource.url
        unless node['platform'] == 'windows'
          owner new_resource.owner
          group new_resource.group
          mode '0600'
        end
        action :create_if_missing
      end
    end

    [new_resource.base_directory, new_resource.package_directory, new_resource.target_directory].each do |dir|
      directory dir do
        unless node['platform'] == 'windows'
          owner new_resource.owner
          group new_resource.group
          mode new_resource.mode
        end
        recursive (new_resource.base_directory == dir)
        action :create
        not_if { ::File.exists?(new_resource.base_directory) && dir == new_resource.base_directory }
      end
    end

    if 'unzip_and_strip_dir' == new_resource.extract_action
      temp_dir = "/tmp/install-#{new_resource.name}-#{new_resource.derived_version}"

      package 'unzip'

      bash 'unzip_package' do
        not_if { archive_exists }
        user new_resource.owner
        group new_resource.group
        umask new_resource.umask if new_resource.umask
        code <<-CMD
          set -e
          mkdir #{temp_dir}
          unzip -q -u -o #{cached_package_filename} -d #{temp_dir}
          if [ `ls -1 #{temp_dir} |wc -l` -gt 1 ] ; then
            echo More than one directory found
            exit 37
          fi
          mv #{temp_dir}/*/* #{new_resource.target_artifact} && rm -rf #{temp_dir} && test -d #{new_resource.target_artifact}
        CMD
      end
    elsif 'unzip' == new_resource.extract_action
      package 'unzip'

      bash 'unzip_package' do
        not_if { archive_exists }
        user new_resource.owner
        group new_resource.group
        umask new_resource.umask if new_resource.umask
        code "unzip -q -u -o #{cached_package_filename} -d #{new_resource.target_artifact}"
      end
    elsif new_resource.extract_action.nil?
      if node['platform'] == 'windows'
        windows_batch 'move_package' do
          not_if { archive_exists }
          code "cp #{cached_package_filename} #{new_resource.target_artifact}"
        end
      else
        bash 'move_package' do
          not_if { archive_exists }
          user new_resource.owner
          group new_resource.group
          umask new_resource.umask if new_resource.umask
          code "cp #{cached_package_filename} #{new_resource.target_artifact}"
        end
      end
    else
      raise "Unsupported extract_action #{new_resource.extract_action}"
    end

    if delete_cached_package
      file cached_package_filename do
        backup false
        action :delete
      end
    end
  end

  last_version = nil

  # TODO: linking should be configurable
  unless node['platform'] == 'windows'
    last_version = ::File.exist?(current_directory) ? ::File.readlink(current_directory) : nil
    link current_directory do
      to new_resource.target_directory
      owner new_resource.owner
      group new_resource.group
    end
  end

  existing_files = Dir["#{new_resource.package_directory}/#{new_resource.name}-*"].
    select { |file| ::File.directory?(file) }.
    select { |file| file != last_version }.
    select { |file| file != new_resource.target_directory }.
    sort { |file| -::File.ctime(file).to_i }

  versions_to_keep = 4
  files_to_delete = existing_files[versions_to_keep...existing_files.length]

  files_to_delete.each do |filename|
    directory filename do
      action :delete
      recursive true
    end
  end if files_to_delete
end
