#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include "rascal.h"

static void remove_gaps(ALNPTR mult_aln);

int main(int argc,char **argv)
{
	int i,nseqs;
	char infile[FILENAMELEN+1];
	char outfile[FILENAMELEN+1];
	ALN mult_aln;
	OPT opt;

	if(argc!=3) {
		fprintf(stderr,"Usage: %s input_aln output_aln\n",argv[0]);
		exit(1);
	}
	strcpy(infile,argv[1]);
	strcpy(outfile,argv[2]);

        init_options(&opt);

	(*opt.alnout_opt).output_clustal=FALSE;
	(*opt.alnout_opt).output_tfa=TRUE;

/* read in the sequences */
	seq_input(infile,opt.explicit_type,FALSE,&mult_aln);
	if(mult_aln.nseqs<=0) {
		fprintf(stderr,"ERROR: No sequences in %s\n",infile);
		exit(1);
	}
	nseqs=mult_aln.nseqs;

/* remove the gaps */
	remove_gaps(&mult_aln);

/* write out the sequences */
	strcpy((*opt.alnout_opt).tfa_outname, outfile);
	for (i=0;i<mult_aln.nseqs;i++) mult_aln.seqs[i].output_index = i;

	if(!open_alignment_output(infile,opt.alnout_opt)) exit(1);
        create_alignment_output(mult_aln,*opt.alnout_opt);
}

static void remove_gaps(ALNPTR mult_aln)
{
        int i,j,k,ngaps;
	char seq[10000];

        for (i=0;i<mult_aln->nseqs;i++)
        {
                for (j=0,k=0;j<mult_aln->seqs[0].len;j++)
                        if(isalpha(mult_aln->seqs[i].data[j])) seq[k++]=mult_aln->seqs[i].data[j];
		seq[k]='\0';
		strcpy(mult_aln->seqs[i].data,seq);
        }
}

