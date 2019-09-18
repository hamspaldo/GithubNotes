Using Github, R, Spark with RStudio on Azure Databricks
================

Intro
-----

The purpose of this repo is to record how to replicate **Programs** and **Data** with git/github on a cloud instance of **RStudio**.
- For **Programs**: will use Github. (haven't used Bitbucket yet, git/github appear to be more popular, but the documentation on Bitbucket website on using git at the command line is quite excellent.)
- For **Data**: will use Azure blob storage. Github has a limit on size of 100mb or so so if you want to use the same data each time in your RStudio instance for a project, it is best to link to some form of cloud storage like Azure blob or AWS S3.

When using git with Azure Databricks, the Terminal built into RStudio is unavailable and I don't know how to get to gitbash cli....- therefore Method 1 is easiest vs using Databricks CLI, which is more about uploading data to the cluster than making SSH connection to a node on the Databricks cluster.

These notes are here to practice my markdown, remind me of what to do and are mostly gleaned from various internet sources. I have tried my best to attribute these sources with links pasted under the **Links** Section below.

Using Git/GIthub to save Programs
---------------------------------

Method 1: https
---------------

\_https seems to work on Azure Databricks but not on Cloudera. For Cloudera have uesed SSH.

#### Step 1. Configure your git details:

Spin up your RStudio instance then run this in R

``` r
usethis::use_git_config(user.name = "hamspaldo", user.email = "your@email.com")
```

#### Step 2. Connect RStudio to Github by pasting https link in a new R project

In RStudio.
File -&gt; New Project -&gt; Version Control -&gt; Git -&gt; paste the https link from the green repo button into the RStudio "repository URL", *something similar to*:
Git https link from the repo e.g. "<https://github.com/hamspaldo/project.git>"

enter github username

enter github password

Method 2: SSH
-------------

-   It looks like SSH isn't well supported by the Azure Databricks instance of RStudio. For a start, the Terminal window in RStudio doesn't work as there is no terminal session loaded. You can generate the SSH key in RStudio instance.

-   SSH does work on cloudera/Taysols, where you can create an RSA key on cluster, as the terminal in RStudio is working. (The Terminal in RStudio for Azure Databricks is blank, so SSH setup doesn't look to be possible.)

1.  Spin up your RStudio instance. Configure your git environment in that instance:

usethis::use\_git\_config(user.name = "hamspaldo", user.email = "<hamish.spalding@hotmail.com>")

1.  create SSH key using Tools -&gt; GLobal Options -&gt; Git/SVN -&gt; create RSA Key -&gt; put in a passphrase for your SSH key -&gt; view public key copy the public key

2.  in R check that you have an SSH key set up.

``` r
file.exists("~/.ssh/id_rsa.pub")
```

1.  go to git -&gt; settings copy and past the SSH key - give it a name like databricksinstance so you know to delete it later

2.  In RStudio. File -&gt; New Project -&gt; Version Control -&gt; Git -&gt; paste into repository URL the following:

Git SSH link from the Repo e.g. "<git@github.com>:hamspaldo/project.git"

1.  warning message pops up, say yes

2.  enter your passphrase

Method 3 using Personal Access Tokens
-------------------------------------

1.  generate PAT in git. Login ot git -&gt; settings -&gt; developer settings -&gt; personal access tokens -&gt; Generate New token 21254bd4NotaRealPatToken2ebNeverDisclose007c6700

2.  usethis::edit\_r\_environ() to create .Renviron
    paste in your GITHUB\_PAT =21254bd4NotaRealPatToken2ebNeverDisclose007c6700
    save and restart R by Session -&gt; restart R

3.  .....??

Connect your instance of R to Spark cluster on Azure Databricks
---------------------------------------------------------------

1.  in Databricks notbook running on the cluster you need to run:

``` r
## source: https://docs.databricks.com/spark/latest/sparkr/sparklyr.html
# Install latest version of Rcpp
install.packages("Rcpp")

# Install sparklyr. It can take a few minutes, because it installs +10 dependencies.
install.packages("sparklyr")

# Load sparklyr package.
library(sparklyr)
spark_connect(method = "databricks")
```

1.  then in R you need to run

Connect RStudio to Spark session:

``` r
library(SparkR) # SparkR library is contained in Databricks Runtime, but you must load it into RStudio. 
sparkR.session()

library(sparklyr)
sc <- spark_connect(method = "databricks") # to initialize a sparklyr session.
# spark_disconnect(sc) # don't forget to close session afterwards
```

Import some data into the Spark cluster on Azure Databricks
-----------------------------------------------------------

See 18092019 spark queries using sparklyr.R file

-   so far have success uploading to RStudio and then sparklyr::copy\_to the cluster.
-   preference is to ingest directly from blog storage rather than via the single R node..

Links
-----

<https://docs.databricks.com/user-guide/clusters/ssh.html>

testing your SSH key connection
<https://help.github.com/en/articles/testing-your-ssh-connection>

Spark
<https://docs.databricks.com/spark/latest/sparkr/sparklyr.html#connect-sparklyr-to-databricks-clusters> <https://databricks.com/blog/2017/05/25/using-sparklyr-databricks.html> <https://docs.databricks.com/spark/latest/sparkr/rstudio.html#get-started-with-rstudio-server-open-source>

Other
-----

### Make sure SSH Authentication Agent is running on local machine

At Git Bash:
1. start up the agent
$ eval `ssh-agent -s`

1.  add the ssh key
    $ssh-add ~/.ssh/id\_rsa
    and then enter the passphrase from when you set up the key
