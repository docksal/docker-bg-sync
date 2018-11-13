# Docksal Unison

Unison container suited for Docksal needs. Continuously syncs files between two directories. 

## Usage

1. Add to the `docksal.env`:

    ```
    DOCKER_VOLUMES=unison
    ```

1. If your project was running before, then remove old containers and volumes with `fin project remove`

    NOTE: `fin project reset` will **not** work here, as it does not remove named volumes
1. `fin project start`

## Additional environment variables

You do not need to set any additional variables for the container to work,
but you can override them if you understand what you are doing.

This container uses values from a handful of environment variables. These are
documented below.

  * **`SYNC_SOURCE`** (default: `/source`): The path inside the container which
    will be used as the source of the file sync. Most of the time, you probably
    shouldn't change the value of this variable. Instead, just bind-mount your
    files into the container at `/source` and call it a day.
  * **`SYNC_DESTINATION`** (default: `/destination`): When files are changed in
    `SYNC_SOURCE`, they will be copied over to the equivalent paths in `SYNC_DESTINATION`.
    If you are using bg-sync to avoid filesystem slowness, you should set this
    path to whatever path the volume is at in your application container. In the
    example above, for instance, this would be `/var/www/myapp`.
  * **`SYNC_PREFER`** (default in image: `/source`, default in Docksal: `newer`):
  Control the conflict strategy to apply when there are conflicts. The "newer"
  option will pick up the most recent files.
  * **`SYNC_MAX_INOTIFY_WATCHES`** (default in image: '', default in Docksal: '524288'): If set, the sync script will
    attempt to increase the value of `fs.inotify.max_user_watches`. **IMPORTANT**:
    This requires that you run this container as a privileged container. Otherwise,
    the inotify limit increase *will not work*. As always, when running a third
    party container as a privileged container, look through the source thoroughly
    first to make sure it won't do anything nefarious. `sync.sh` should be pretty
    understandable. Go on - read it. I'll wait.
  * **`SYNC_EXTRA_UNISON_PROFILE_OPTS`** (default: ''): The value of this variable
    will be appended to the end of the Unison profile that's automatically generated
    when this container is started. Ensure that the syntax is valid. If you have
    more than one option that you want to add, simply make this a multiline string.
    **IMPORTANT**: The *ability* to add extra lines to your Unison profile is
    supported by the bg-sync project. The *results* of what might happen because
    of this configuration is *not*. Use this option at your own risk.
  * **`SYNC_NODELETE_SOURCE`** (default in image: '1', default in Docksal: '0'): Set this variable to "0" to allow
    Unison to sync deletions to the source directory. This could cause unpredictable
    behavior with your source files.
  * **`UNISON_USER`** (default: 'root'): The user running Unison. When this value
    is customized it's also possible to specify UNISON_UID, UNISON_GROUP and
    UNISON_GID to ensure that unison has the correct permissions to manage files
    under SYNC_SOURCE and SYNC_DESTINATION.
  * **`UNISON_UID`** (default: '0'): See UNISON_USER.
  * **`UNISON_GROUP`** (default: 'root'): See UNISON_USER.
  * **`UNISON_GID`** (default: '0'): See UNISON_USER.

## Credits

* Cameron Eagans - [docker-bg-sync](https://github.com/cweagans/docker-bg-sync)
