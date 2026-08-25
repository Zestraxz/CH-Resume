# Rendered C4 Diagrams

These SVGs are auto-rendered from `../workspace.dsl` by `.github/workflows/docs.yml` on every push.

Don't edit them by hand - edit `workspace.dsl` instead.

## Manual render

```bash
docker run --rm -v $(pwd)/docs/architecture:/usr/local/structurizr structurizr/cli export -workspace /usr/local/structurizr/workspace.dsl -format mermaid -output /usr/local/structurizr
```
