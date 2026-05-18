

epiinfo is public repo in both acc tin6150 and sn12650


## github stuff

started this repo under my traditional tin6150 github acc.
also wanted to have a copy under the github acc with berkeley.edu to use copilot.  that acc name is sn12650



thus, 

on web, create a repo, but don't add any file, not even readme.

on laptop, push to new repo.
                                                       VVVVVVV--- instead of typical "origin" 
**^ tin Weasel ~/tin-g2005/epiinfo ^**> git remote add sn12650 https://github.com/sn12650/epiinfo.git


this add another remote clause in .git/config



hmmm...
when adding ssh key, complained key already in use.
so same ssh key can't be used on multiple github acc.  kinda strange.
and they don't allow for password.  
gonna have to do another ssh key.



then need to push with:

# Source - https://stackoverflow.com/a/65206448
# Posted by Lukas Lukac
# Retrieved 2026-05-04, License - CC BY-SA 4.0

GIT_SSH_COMMAND='ssh -i $HOME/.ssh/id_ecdsa.pub -o IdentitiesOnly=yes -F /dev/null' git push sn12650 main
// this works for now, but gosh what if they enforce 2FA?





