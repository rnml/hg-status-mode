Minimalist emacs major mode for viewing and editing
[hg](http://mercurial.selenic.com) repo status for the current
directory.

![screenshot1](https://bitbucket.org/rnml/hg-status-mode/raw/tip/screenshot1.png)

The `Action` column shows the action we've marked down for the file in
question.  These are set with mnemonic keys (see below).  The `!`
command executes all pending marked actions, prompting for a commit
message if necessary.

The `B` column shows the status `B`efore any action is taken (i.e.,
the current status).  The `A` column shows the status `A`fter `Action`
is taken (i.e., the goal status).  The status letters' meaning is as
in the output of hg status (with the excepton of D which doesn't apply
there):

  | Status code  | Meaning                                                   |
  | ------------ | --------------------------------------------------------- |
  |   M          | modified                                                  |
  |   A          | added                                                     |
  |   R          | removed                                                   |
  |   C          | clean                                                     |
  |   !          | missing (deleted by non-hg command, but still tracked)    |
  |   ?          | not tracked                                               |
  |   I          | ignored                                                   |
  |   D          | deleted (using /bin/rm)                                   |
  
Here's what it looks like after marking down some actions:
![screenshot2](https://bitbucket.org/rnml/hg-status-mode/raw/tip/screenshot2.png)

Finally, here are all the valid `Action` setting commands for each
state:

  | Initial state | Action (key)  | Final state  |
  | ------------- | ------------- | ------------ |
  |   M           | commit (`c`)  |   C          |
  |               | delete (`d`)  |   !          |
  |               | forget (`-`)  |   R          |
  |               | revert (`r`)  |   C          |
  |   A           | commit (`c`)  |   C          |
  |               | delete (`d`)  |   !          |
  |               | forget (`-`)  |   ?          |
  |               | revert (`r`)  |   ?          |
  |   R           | commit (`c`)  |   D          |
  |               | revert (`r`)  |   C          |
  |   !           | revert (`r`)  |   C          |
  |               | forget (`-`)  |   R          |
  |   ?           | add (`a`)     |   A          |
  |               | delete (`d`)  |   D          |
  |               | ignore (`i`)  |   I          |
  |   I           | add (`a`)     |   A          |
