FROM ubuntu:20.04

MAINTAINER yuhao<yqyuhao@outlook.com>

RUN sed -i 's/http:\/\/archive\.ubuntu\.com\/ubuntu\//http:\/\/mirrors\.aliyun\.com\/ubuntu\//g' /etc/apt/sources.list

# set timezone
RUN set -x \
&& export DEBIAN_FRONTEND=noninteractive \
&& apt-get update \
&& apt-get install -y tzdata \
&& ln -sf /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime \
&& echo "Asia/Shanghai" > /etc/timezone

# install packages
RUN apt-get update \

&& apt-get install -y less curl apt-utils vim wget gcc-7 g++-7 make cmake git unzip dos2unix libncurses5 gzip \

# lib
&& apt-get install -y zlib1g-dev libjpeg-dev libncurses5-dev libbz2-dev liblzma-dev libcurl4-gnutls-dev libssl-dev libxml2-dev \
 
# python3 perl java r-base
&& apt-get install -y python3 python3-dev python3-pip python perl openjdk-8-jdk r-base r-base-dev

ENV software /yqyuhao

# create software folder

RUN mkdir -p /data /data/RightonAuto/fastq /data/RightonAuto/analysis $software/database $software/source $software/bin

# conda v4.12
WORKDIR $software/source
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py37_4.12.0-Linux-x86_64.sh -O $software/source/Miniconda3-py37_4.12.0-Linux-x86_64.sh \
&& sh $software/source/Miniconda3-py37_4.12.0-Linux-x86_64.sh -b -p $software/bin/conda-v4.12 \
&& $software/bin/conda-v4.12/bin/conda config --add channels conda-forge \
&& $software/bin/conda-v4.12/bin/conda config --add channels r \
&& $software/bin/conda-v4.12/bin/conda config --add channels bioconda

# install cutadapt fastp flash megahit vsearch blat mafft seqkit blastn
WORKDIR $software/source
RUN $software/bin/conda-v4.12/bin/conda install -y cutadapt fastp flash megahit vsearch blat mafft seqkit blast parallel -c bioconda

# install ncbi-igblast-1.17.1
WORKDIR $software/bin
RUN wget ftp://ftp.ncbi.nih.gov/blast/executables/igblast/release/1.17.1/ncbi-igblast-1.17.1-x64-linux.tar.gz -O $software/bin/ncbi-igblast-1.17.1-x64-linux.tar.gz \
&& tar -xf $software/bin/ncbi-igblast-1.17.1-x64-linux.tar.gz && rm -f $software/bin/ncbi-igblast-1.17.1-x64-linux.tar.gz

# copy esssential files
WORKDIR $software
RUN Rscript -e "install.packages(c('ggplot2','tidyverse'))"
RUN git clone https://github.com/yqyuhao/BCR_v3.git && cd BCR_v3 && cp -f Rplot_line.R BCR_analysis_v3.0 $software/bin/ && cp -Rf database $software/
RUN cd $software && rm -Rf BCR_v3

# chown root:root
WORKDIR $software/source
RUN chown root:root -R $software/source
RUN chown root:root -R $software/bin
RUN chmod 644 $software/bin/BCR_analysis_v3.0

# mkdir fastq directory and analysis directory
WORKDIR /data/RightonAuto/analysis
