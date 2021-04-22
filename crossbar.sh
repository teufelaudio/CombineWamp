#!/bin/sh
docker run -v  $PWD:/node -u 0 --rm --name=crossbar -it -p 8080:8080 crossbario/crossbar
