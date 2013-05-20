## v0.2.4:

* Remove the publish_container_dir_to and publish_artifact_location_to LWRP parameters in favour of explicitly
  retrieving the values through the methods on the resource.
* Keep two versions of the artifact in the versioned folder. Older artifacts, based on creation time are removed.
* Stop backing up deleted files.
* Support file:// urls.

## v0.2.1:

* Initial external release.
