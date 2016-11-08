#!/bin/sh

exec docker-machine --storage-path $(pwd)/.docker $@
