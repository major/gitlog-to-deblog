WORK IN PROGRESS.

This script converts a git log to a debian changelog suitable for use with deb packaging.  I'm not a DD and I can't verify that the changelog will work for all use cases.

**Your git repo must have at least one tag for this script to work.**  Customize the :tag symbol if you go without tags.

To use the script, simply drop it into the base directory of your favorite git repository and run it.  It pulls 25 commit messages by default.