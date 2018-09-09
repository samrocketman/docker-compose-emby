# Emby Media Server Docker Service

<img
src="https://user-images.githubusercontent.com/875669/35621322-cf8ec752-0638-11e8-8dbc-72760b696d64.png"
height=48 width=48 alt="Red Hat Logo" /> <img
src="https://user-images.githubusercontent.com/875669/35621353-e78a6956-0638-11e8-8e07-3d96e9e91dd7.png"
height=48 width=72 alt="Docker Logo" /> <img
src="https://emby.media/resources/logowhite_1881.png" height=48 width=157
alt="Emby Logo" />

This is an easy to manage service which runs [Emby Media Server][emby] within
[Docker][docker].

By running Emby as a system service using Docker and docker-compose, this
ensures Emby can be portably run in any `X86_64` system which has systemd and
Docker available.

# Prerequisites

* [Docker][install-docker]
* [docker-compose][compose]

# Try out Emby

Trying out Emby is easy.  You can start Emby with the following command.

    docker-compose up -d

Then, visit `http://localhost:8096`.

To stop Emby without deleting Emby data run the following.

    docker-compose down

To stop Emby, delete all data, and the Emby image built run the following.

    docker-compose down -v --rmi all

# Running as a service

When you have Emby configured the way you want, you can easily install your
current Emby service as a systemd service.  This will use all existing
docker-compose configuration and Emby data configured within this service.  It
simply uses systemd to control docker-compose on start, stop, and restart.

> Note: Before controlling the Emby systemd service it is recommended to shut
> down Emby if you started it outside of systemd.  Simply run:
>
>     docker-compose down

### Install emby service

Install Emby as a service.

    ./install-emby-service.sh

### Control emby service

Start the service.

    systemctl start emby.service

Stop the service.

    systemctl stop emby.service

Ensure the service autostarts on reboot.

    systemctl enable emby.service

Stop the service from autostarting on reboot.

    systemctl disable emby.service

### Debug emby service

View the current service status.

    systemctl status emby.service

View the systemd logs for the service.

    journalctl -u emby.service

# Customizing Emby version

Modify the `emby` service in [`docker-compose.yml`](docker-compose.yml) with an
environment section to customize the version of Emby.

```yaml
services:
  emby:
    environment:
      EMBY_VERSION: 3.5.2.0
```

# Adding media to Emby

Modify the `emby` service in [`docker-compose.yml`](docker-compose.yml) and
update the `volumes` section.  **Do not delete the `emby-data` volume** or your
emby service will lose its configuration every time the service is restarted.

It is recommended to attach your media as read-only to Emby so that your media
isn't accidentally deleted through Emby.  Mounting as read-only adds an extra
layer of security.

```yaml
services:
  emby:
    volumes:
      - emby-data:/var/lib/emby
      - /path/to/Movies:/media/Movies:ro
      - /path/to/Music:/media/Music:ro
      - /path/to/Photos:/media/Photos:ro
```

You might want to still be able to upload photos to Emby.  For this, you can
mount a read-write photos directory in which Emby can access.

```yaml
- /path/to/Emby-Uploaded-Photos:/media/Emby-Uploaded-Photos
```

In the above example, Emby will need write access to
`/media/Emby-Uploaded-Photos`.  To grant Emby write access do the following:

```bash
# Enter the running Emby container as root
docker-compose exec -u root emby /bin/bash
# Now inside of the container change permissions
chown -R emby: /media/Emby-Uploaded-Photos
```

[compose]: https://github.com/docker/compose/releases
[emby]: https://emby.media/
[install-docker]: https://docs.docker.com/install/
[docker]: https://www.docker.com/
