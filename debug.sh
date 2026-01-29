#!/usr/bin/env bash
valgrind -s                    \
  --log-file=logs/valgrind.log \
  --leak-check=full            \
  --show-leak-kinds=all        \
  --track-origins=yes          \
  ./dist/tAutoFisher/tAutoFisher
