# Contributing to AirConnect

First off, thank you for considering contributing to AirConnect! It's people like you that make AirConnect such a great tool.

## Where do I go from here?

If you've noticed a bug or have a feature request, make one! It's generally best if you get confirmation of your bug or approval for your feature request this way before starting to code.

## Fork & create a branch

If this is something you think you can fix, then fork AirConnect and create a branch with a descriptive name.

## Get the test suite running

Make sure you're able to run tests and compile before you make changes.

## Implement your fix or feature

At this point, you're ready to make your changes! Feel free to ask for help; everyone is a beginner at first.

## Make a Pull Request

At this point, you should switch back to your master branch and make sure it's up to date with AirConnect's master branch:

```bash
git remote add upstream git@github.com:jossehuybrechts/AirConnect.git
git checkout master
git pull upstream master
```

Then update your feature branch from your local copy of master, and push it!

```bash
git checkout 325-add-japanese-translations
git rebase master
git push --set-upstream origin 325-add-japanese-translations
```

Finally, go to GitHub and make a Pull Request!
