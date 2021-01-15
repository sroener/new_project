
rule createRandomIntervals:
    input:
        genome=lambda wc: config["assembly"][wc.assembly]["genome"],
    output:
        "results/workflow/{assembly}/{sample}.bed.gz"
    params:
        l=config["intervals"]["length"],
        n=lambda wc: samples.loc[wc.sample]["size"],
        seed=lambda wc: samples.loc[wc.sample].seed,
    conda:
        "../envs/myenv.yaml"
    log:
        "results/logs/createRandomIntervals.{assembly}.{sample}.log"
    shell:
        """
        bedtools random -l {params.l} -n {params.n} -seed {params.seed} -g {input.genome} | bgzip -c > {output}
        """


rule extendInterval:
    input:
        region="results/workflow/{assembly}/{sample}.bed.gz",
        genome=lambda wc: config["assembly"][wc.assembly]["genome"],
    output:
        "results/workflow/{assembly}/{sample}.extended.bed"
    params:
        genome=lambda wc: config["assembly"][wc.assembly]["genome"],
        extra="-l 21 -r 20",
    log:
        "results/logs/extendInterval.{assembly}.{sample}.log"
    wrapper:
        "v0.69.0/bio/bedtools/slop"

rule getSequence:
    input:
        bed="results/workflow/{assembly}/{sample}.extended.bed",
        fasta=lambda wc: config["assembly"][wc.assembly]["fasta"],
    output:
        "results/workflow/{assembly}/{sample}.fa.gz"
    conda:
        "../envs/myenv.yaml"
    log:
        "results/logs/getSequence.{assembly}.{sample}.log"
    shell:
        """
        bedtools getfasta -fi {input.fasta} -bed {input.bed} | bgzip -c > {output}
        """
