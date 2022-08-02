[hub]: https://hub.docker.com/r/spritsail/prowlarr
[git]: https://github.com/spritsail/prowlarr
[drone]: https://drone.spritsail.io/spritsail/prowlarr
[mbdg]: https://microbadger.com/images/spritsail/prowlarr

# [Spritsail/Prowlarr][hub]

[![Layers](https://images.microbadger.com/badges/image/spritsail/prowlarr.svg)][mbdg]
[![Latest Version](https://images.microbadger.com/badges/version/spritsail/prowlarr.svg)][hub]
[![Git Commit](https://images.microbadger.com/badges/commit/spritsail/prowlarr.svg)][git]
[![Docker Pulls](https://img.shields.io/docker/pulls/spritsail/prowlarr.svg)][hub]
[![Docker Stars](https://img.shields.io/docker/stars/spritsail/prowlarr.svg)][hub]
[![Build Status](https://drone.spritsail.io/api/badges/spritsail/prowlarr/status.svg)][drone]


[Prowlarr](https://github.com/Prowlarr/Prowlarr) running in Alpine Linux. This container provides some simple initial configuration scripts to set some runtime variables (see [#Configuration](#configuration) for details)

## Usage

Basic usage with default configuration:
```bash
docker run -d
    --name=prowlarr
    --restart=always
    -v $PWD/config:/config
    -p 9696:9696
    spritsail/prowlarr
```

Advanced usage with custom configuration:
```bash
docker run -d
    --name=prowlarr
    --restart=always
    -v $PWD/config:/config
    -p 9696:9696
    -e URL_BASE=/prowlarr
    -e ANALYTICS=false
    -e ...
    spritsail/prowlar
```

### Volumes

* `/config` - Prowlarr configuration file and database storage. Should be readable and writeable by `$SUID`

`$SUID` defaults to 908

### Configuration

These configuration options set the respective options in `config.xml` and are provided as a Docker convenience.

* `LOG_LEVEL` - Options are:  `Trace`, `Debug`, `Info`. Default is `Info`
* `URL_BASE`  - Configurable by the user. Default is _empty_
* `BRANCH`    - Upstream tracking branch for updates. Options are: `master`, `develop`, _other_. Default is `develop`
* `ANALYTICS` - Truthy or falsy value `true`, `false` or similar. Default is `true`
