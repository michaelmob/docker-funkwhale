---
name: Bug report
about: Create a report to help us improve this container
title: ''
labels: ''
assignees: ''

---

**Describe the bug**
A clear and concise description of what the bug is.

**Logs**
Please submit relevant logs between three backticks.

```
# Stdout
docker logs ${CONTAINER_ID}

# Logs are located in the `/var/log/funkwhale/` directory.
docker exec -it ${CONTAINER_ID} cat /var/log/funkwhale/{daphne,celery-worker,celery-beat}.log
```

**Options**
Submit your command options and arguments like volumes, environment variables, and ports.

**System information**
 - OS: (Ubuntu 18.10, Unraid 6, ...)
 - Run tool: (just Dockerfile, docker-compose, web GUI, ...)
 - Docker version: ...
 - Tag: (master, latest, 0.17, ...)

**Additional context**
Add any other context about the problem here.
