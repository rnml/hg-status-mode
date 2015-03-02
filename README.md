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

  | State change | Action / key  |
  | ------------ | ------------- |
  |   M -> C     | commit / `c`  |
  |   M -> !     | delete / `d`  |
  |   M -> R     | forget / `-`  |
  |   M -> C     | revert / `r`  |
  |   A -> C     | commit / `c`  |
  |   A -> !     | delete / `d`  |
  |   A -> ?     | forget / `-`  |
  |   A -> ?     | revert / `r`  |
  |   R -> D     | commit / `c`  |
  |   R -> C     | revert / `r`  |
  |   ! -> C     | revert / `r`  |
  |   ! -> R     | forget / `-`  |
  |   ? -> A     | add / `a`     |
  |   ? -> D     | delete / `d`  |
  |   ? -> I     | ignore / `i`  |
  |   I -> A     | add / `a`     |
