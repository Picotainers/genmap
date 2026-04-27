# genmap
Minimal container for 
auto-generated wrapper around the upstream genmap tool.

## Quick Usage
```bash
docker run --rm docker.io/picotainers/genmap:latest --help
```

## Usage
```bash
# Run in current directory
docker run --rm -v "$(pwd):/data" -w /data docker.io/picotainers/genmap:latest --help
```

## Building
```bash
docker build -t docker.io/picotainers/genmap:latest .
```
