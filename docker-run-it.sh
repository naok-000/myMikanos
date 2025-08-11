xhost + 127.0.0.1
docker run --privileged --user vscode -v .:/home/vscode/mikanos -it --rm ghcr.io/sarisia/mikanos /bin/bash
