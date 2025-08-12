xhost + 127.0.0.1
docker run --privileged --user vscode -it -v .:/home/vscode/mikanos --rm mikanos-container:latest /bin/bash
