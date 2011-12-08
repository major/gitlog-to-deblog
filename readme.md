WORK IN PROGRESS.

This script converts a git log to a debian changelog suitable for use with deb packaging.  I'm not a DD and I can't verify that the changelog will work for all use cases.

If your repo has no tags, the script will make a temporary tag on your first
commit, output the changelog, and then remove the temporary tag.  To avoid this functionality, add some tags to your repository.

To use the script, simply drop it into the base directory of your favorite git repository and run it.  It pulls 25 commit messages by default.