# Okkama

Script for Natasha


## Deploy using Heroku Git

Use git in the command line or a GUI tool to deploy this app.

### Install the Heroku CLI

Download and install the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli).

If you haven't already, log in to your Heroku account and follow the prompts to create a new SSH public key.

```
heroku login
```

### Add remote source heroku for repository

If you have already created your Heroku app, you can easily add a remote to your local repository with the
`heroku git:remote` command. All you need is your Heroku app’s name:

```
heroku git:remote -a okkama
```

### Deploying code

To deploy your app to Heroku, you typically use the git push command to push the code from your local repository’s
master branch to your heroku remote, like so:

```
git push heroku master
```

or if have conflicts

```
git push heroku master --force
```

Use this same command whenever you want to deploy the latest committed version of your code to Heroku.

Note that Heroku only deploys code that you push to the `master` branch of the `heroku` remote. Pushing code to
another branch of the remote has no effect.

### Deploying from a branch besides master

If you want to deploy code to Heroku from a non-`master` branch of your local repository (for example, `testbranch`),
use the following syntax to ensure it is pushed to the remote’s `master` branch:

```
git push heroku testbranch:master
```

or if have conflicts

```
git push heroku testbranch:master --force
```
