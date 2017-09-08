#!/bin/bash
#$ -N makedb
#$ -l h_rt=72:00:00
#$ -l h_vmem=50G
#$ -pe threaded 39
#$ -m beas
#$ -M j.c.wolthuis-2@umcutrecht.nl

TMPDIR=/hpc/cog_bioinf/ridder/users/jwolthuis/MetaboShiny/backend/db/tmp /home/cog/jwolthuis/R-3.4.0/bin/Rscript --no-save /hpc/cog_bioinf/ridder/users/jwolthuis/MetaboShiny/backend/scripts/db.make.hpc.R
