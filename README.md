Minimalist emacs major mode for viewing and editing
[hg](http://mercurial.selenic.com) repo status for the current
directory.

![screenshot1](https://bitbucket.org/rnml/hg-status-mode/raw/tip/screenshot1.png)

The `Action` column shows the action we've marked down for the file in
question.  These are set with mnemonic keys (see below).  The `!`
command executes all pending marked actions, prompting for a commit
message if necessary.

The `B` column shows the status *B*efore any action is taken (i.e.,
the current status).  The `A` column shows the status *A*fter `Action`
is taken (i.e., the goal status).  The meaning of the status letters
come from hg itself, with the excepton of D which doesn't apply there:

    M = modified
    A = added
    R = removed
    C = clean
    ! = missing (deleted by non-hg command, but still tracked)
    ? = not tracked
    I = ignored
    D = deleted (using /bin/rm)

![screenshot2](https://bitbucket.org/rnml/hg-status-mode/raw/tip/screenshot2.png)
