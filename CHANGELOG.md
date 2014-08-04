## v0.2.8:

## v0.2.6:

* Keep the latest 4 versions of file.
* Delete the oldest versions rather than the earliest.
* Avoid linking on windows at all until the link resource can correctly handle changes of the target.

## v0.2.4:

* Initial windows support. Does not yet handle rights controls, nor does it support specifying an
  extraction action.
* Recursively create the base directory.
* Remove the publish_container_dir_to and publish_artifact_location_to LWRP parameters in favour of explicitly
  retrieving the values through the methods on the resource.
* Keep two versions of the artifact in the versioned folder. Older artifacts, based on creation time are removed.
* Stop backing up deleted files.
* Support file:// urls.

## v0.2.1:

* Initial external release.
