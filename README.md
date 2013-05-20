# Description

[![Build Status](https://secure.travis-ci.org/realityforge/chef-archive.png?branch=master)](http://travis-ci.org/realityforge/chef-archive)

Provides a utility LWRP to download and unpack archives.

# Requirements

## Platform:

* Ubuntu

## Cookbooks:

* cutlery (>= 0.2.0)

# Attributes

*No attributes defined*

# Recipes

*No recipes defined*

# Resources

* [archive](#archive) - The LWRP downloads an archive and places in a local versioned directory and symlinks the current version.

## archive

The LWRP downloads an archive and places in a local versioned directory and
symlinks the current version.

The LWRP first creates a container directory based on the name and the prefix. Under the
container directory, there is a directory in which all the versions of the artifact are
stored. The LWRP will download the artifact and place it in this directory and then symlink
the "current" directory to the downloaded artifact.

By default the LWRP will retain the directory for the last artifact downloaded.

### Actions

- add: Download and extract archive. Default action.

### Attribute Parameters

- name: The logical name of the artifact. Used when creating the container directory.
- url: The url from which to download the resource.
- version: The version of the archive. Should be set, otherwise will be derived as a hash of the url parameter. Defaults to <code>nil</code>.
- owner: The owner of the container directory and created artifacts. Defaults to <code>"root"</code>.
- group: The group of the container directory and created artifacts. Defaults to <code>0</code>.
- umask: The umask used when setting up the archive. Defaults to <code>nil</code>.
- prefix: The directory in which the archive is unpacked. Defaults to <code>"/usr/local"</code>.
- extract_action: The action to take with the downloaded archive. Defaults to leaving the archive un-extracted but can also unzip or unzip and stript the first directory. Defaults to <code>nil</code>.

### Examples

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
    end

# License and Maintainer

Maintainer:: Peter Donald (<peter@realityforge.org>)

License:: Apache 2.0
