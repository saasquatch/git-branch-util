git-kanban-helper
=================

![Screenshot](http://yupiq.github.com/git-branch-util/images/Screenshot.png)


## Goals
* Allow multiple features to proceed through development in parallel
* Stage any features which are ready for *beta* release to be built from a *staging* branch
* Allow any staged features which are ready for *prod* release to be released independently of each other
    * *staging* cannot simply be merged to prod, otherwise all staged features would be blocked by any single broken staged feature.

##Git Structure
* master: The 'production' released code
* staging: The 'beta' released code for the staging server
* feature-####: Unique branch for each feature (tightly coupled to task tracking issue)

*Note: master contains a subset of staging*

## Process
The actions which a human needs to take in this process are as follows:
* A new feature branch is branched from master. Branching from master (rather than staging) means that this branch could be merged back onto *staging*, or *master* seamlessly without requiring cherry-picking of specific commits. Leakage of non-production-ready code is blocked by this.
* Feature branches which reach a staging-ready level can be merged to the *staging* branch and released to a beta server.
* Feature branches which reach a production-ready level can be merged to the *master* branch and released to production.

## Automated Process
The following part of the process should be done automatically:
* Any time a commit is made to *master*, it should be merged onto every other branch. This ensures that branches are up to date with any production released features and can be more safely merged into production later on.

# git-kanban-helper Tools
The tools in this repository provide functionality to support the process outlined above.
* merge-master-out.rb: Performs the second task under *Automated Process* by merging *master* out to all branches
* status.rb: Reports on the current merge state of all feature branches. This indicates for each branch whether it is merged into any of *master*, or *staging*. Also reports on the current commit state of all branches (how many commits ahead or behind each branch is).
* synchronize.rb: This is automatically run by any of the other scripts and synchronizes the local repository state with that of the remote repository (fetching and merging changes, and purging any defunct local branches).
* all.rb: Runs in order *synchronize*, *merge-master-out*, *status*

## Usage
The simplest usage is to simply run *all.rb*, check that the status output at the end seems correct, then *git push --all* to push the changes.
This should be done in an automatic trigger any time a git commit is made.
