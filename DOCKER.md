# Docker sample uses


## Basic stuff 


Build image from Dockerfile in current directory, tag it with a specific name and label:
```
docker build . -t my-image:v2
```

Run nginx container with port mapping (host:container):
```
docker run -p 8091:80  nginx
```

Run nginx container with volume mapping (hostdir/containterdir):
```
docker run -v /some/local/dir/:/usr/share/nginx/html:ro nginx
```

Run container interactively:
```
# hostname
my_docker_host

# docker run -it alpine
/ # hostname
f1de6589e1ad
```

Run a command on the container, then exit:
```
docker run alpine cat /etc/alpine-release
3.8.0
```

Bypass `CMD` or `ENTRYPOINT` (see below how to get them):
```
# docker run -it nginx bash
root@0aa132d3241b:/#
```
or
```
docker run -it --entrypoint bash nginx
root@9c36f4645b92:/#
```


## Output formatting

Docker commandline supports Go template formatting, the placeholder for each subcommand can be found on its documentation page.

For example:
- https://docs.docker.com/engine/reference/commandline/images/#formatting
- https://docs.docker.com/engine/reference/commandline/ps/#formatting
etc.

Generic formatting guide:
- https://docs.docker.com/config/formatting/


Examples:

```
# docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
REPOSITORY                   TAG                 SIZE
trello-vue-report            latest              11.1MB
alpine                       latest              4.41MB
node                         8.6-alpine          67.2MB
```

```
# docker ps --format "table {{.ID}}\t{{.Status}}\t{{.Image}}\t{{.Size}}\t{{.Labels}}"
CONTAINER ID        STATUS              IMAGE               SIZE                  LABELS
8cbb526aeb93        Up 40 seconds       alpine              0B (virtual 4.41MB)
0ae0aba9e053        Up 2 minutes        trello-vue-report   2B (virtual 11.1MB)   description=Test
```

```
# docker inspect --format='{{.State.Status}}' 8cbb526aeb93
running

# docker inspect --format='{{.State.StartedAt}}' 8cbb526aeb93
2018-08-22T10:48:17.343581763Z
```

Get  `CMD` and `ENTRYPOINT` for a specific image:
```
# docker image inspect --format='CMD={{.Config.Cmd}}{{println}}ENTRYPOINT={{.Config.Entrypoint}}' nginx
CMD=[nginx -g daemon off;]
ENTRYPOINT=[]
```



