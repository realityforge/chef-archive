# Description

[![Build Status](https://secure.travis-ci.org/realityforge/chef-archive.png?branch=master)](http://travis-ci.org/realityforge/chef-archive)

Provides a utility LWRP to retrieve versioned archives and unpack them in a local versioned directory.

# Requirements

## Platform:

* Ubuntu
* Windows

## Cookbooks:

* cutlery

# Attributes

*No attributes defined*

# Recipes

*No recipes defined*

# Resources

* [archive](#archive) - The LWRP retrieves an artifact of particular version from a url.

## archive

The LWRP retrieves an artifact of particular version from a url. The artifact is
placed in a versioned directory and then a symlink is created from current version
of the artifact to the retrieved version.

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
- mode: The permissions on the container directory and created artifacts. Defaults to <code>"0700"</code>.
- umask: The umask used when setting up the archive. Defaults to <code>nil</code>.
- prefix: The directory in which the archive is unpacked. Defaults to <code>nil</code>.
- extract_action: The action to take with the downloaded archive. Defaults to leaving the archive un-extracted but can also unzip or unzip and strip the first directory. Defaults to <code>nil</code>.

### Examples

    # Download the myapp.zip archive, extract the archive, strip the
    # top level dir and place results into /usr/local/myapp/versions/1.0
    # and symlink /usr/local/myapp/versions/current to /usr/local/myapp/versions/1.0
    archive 'myapp' do
      url "http://example.com/myapp.zip"
      version '1.0'
      owner 'myapp'
      group 'myapp'
      extract_action 'unzip_and_strip_dir'
    end

    # Download the myapp.zip archive, extract the archive, strip the
    # top level dir and place results into /usr/loca/myapp/versions/1.0
    # and symlink /usr/local/myapp/versions/current to /usr/local/myapp/versions/1.0
    # and set the permissions of /usr/local/myapp to 0755
    archive 'myapp' do
      url "http://example.com/myapp.zip"
      version '1.0'
      owner 'myapp'
      group 'myapp'
      mode '0755'
      extract_action 'unzip_and_strip_dir'
    end

    # Download the myapp.jar and place set the attribute
    # myapp.home_dir to the container dir (i.e. /usr/local/myapp) and
    # myapp.jar_location to the downloaded jar. (i.e. /usr/local/myapp/pkg/current/myapp-1.0.jar)
    archive 'myapp' do
      url "http://example.com/myapp.jar"
      version '1.0'
      owner 'myapp'
      group 'myapp'
    end

# License and Maintainer

Maintainer:: Peter Donald (<peter@realityforge.org>)

License:: Apache 2.0
