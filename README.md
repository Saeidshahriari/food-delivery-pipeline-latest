# Food Delivery Pipeline (Latest stack)

See `docker/docker-compose.yml` and `scripts/get_flink_jars.sh` to fetch Flink connectors.
Start: `docker compose -f docker/docker-compose.yml up -d --build`
Then: `bash scripts/get_flink_jars.sh && bash scripts/sql_submit.sh && bash scripts/register_connectors.sh`

---

## GitHub setup

1) Create a new repo on GitHub (empty).  
2) From the project root:

```bash
git init
git add .
git commit -m "feat: initial CDC -> Kafka -> Flink -> Redis + OpenSearch + Delta pipeline"
git branch -M main
git remote add origin https://github.com/<USER>/<REPO>.git
git push -u origin main
```

### CI status
A simple GitHub Actions CI is provided:
- `ruff` lint on Python files
- `docker compose config` validation
- build Dockerfiles for API and Redis consumer

Add a badge to the top of `README.md` once you create the repo:

```
![CI](https://github.com/<USER>/<REPO>/actions/workflows/ci.yml/badge.svg)
```
