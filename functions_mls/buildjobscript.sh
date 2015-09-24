#------------------------------------------------------------------------------
cp ${home}/job_run_templet ${expid}.run
ed -s ${expid}.run <<EOFrun
1,100s/JobName/${expid}/
g/#HOMEDIR/s/#HOMEDIR/${hometarget}/
g/#WORKDIR/s/#WORKDIR/${worktarget}/
g/#mMoCoef/s/#mMoCoef/${PmMoCoef}/g
g/#mMaCoef/s/#mMaCoef/${PmMaCoef}/g
g/#mMeCoef/s/#mMeCoef/${PmMeCoef}/g
w
q
EOFrun
#------------------------------------------------------------------------------
cp ${home}/job_post_templet ${expid}.post
ed -s ${expid}.post <<EOFpost
1,100s/JobName/${expid}/
g/#HOMEDIR/s/#HOMEDIR/${hometarget}/
g/#WORKDIR/s/#WORKDIR/${worktarget}/
w
q
EOFpost
#------------------------------------------------------------------------------
