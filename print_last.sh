#! /bin/bash
cat $(ls -Art | grep ".*\.o.*" | tail -n 1)
