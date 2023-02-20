#!/bin/sh

# set -e Exit the script if an error happens
set -e
PUID=${PUID=1001}
PGID=${PGID=1001}

files_ownership () {
    # -h Changes the ownership of an encountered symbolic link and not that of the file or directory pointed to by the symbolic link.
    # -R Recursively descends the specified directories
    # -c Like verbose but report only when a change is made
    chown -hRc "$PUID":"$PGID" /app/data
}

#echo "==> Performing startup jobs and maintenance tasks"
#files_ownership

echo "==> Starting the application"
exec "$@"