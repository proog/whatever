#!/usr/bin/env bash

set -o nounset
prefix=$'\n$'
executed=0

# git
if git rev-parse --is-inside-work-tree 1> /dev/null 2>&1 ; then
  echo "$prefix git fetch --all --prune --tags --force"
  git fetch --all --prune --tags --force

  # if the current branch has an upstream and differs from the local branch
  if git rev-parse '@{u}' 1> /dev/null 2>&1 && [ "$(git rev-parse HEAD)" != "$(git rev-parse '@{u}')" ]; then
    git diff-index --quiet HEAD --
    stash=$?

    if (( stash == 1 )); then
      utcnow=$(date -u)
      echo "$prefix git stash push -m \"whatever.sh auto-stash at $utcnow\""
      git stash push -m "whatever.sh auto-stash at $utcnow"
    fi

    echo "$prefix git pull --rebase"
    git pull --rebase

    if (( stash == 1 )); then
      echo "$prefix git stash pop"
      git stash pop
    fi
  fi

  executed=1
fi

# npm/yarn
if [ -f "package.json" ]; then
  if [ -f "yarn.lock" ]; then
    echo "$prefix yarn install"
    yarn install
  else
    echo "$prefix npm install"
    npm install
  fi

  executed=1
fi

# bower
if [ -f "bower.json" ]; then
  echo "$prefix bower install"
  bower install
  executed=1
fi

# python
if [ -f "Pipfile" ]; then
  echo "$prefix pipenv install --dev"
  pipenv install --dev
  executed=1
elif [ -f "requirements.txt" ]; then
  echo "$prefix pip3 install -r requirements.txt"
  pip3 install -r requirements.txt
  executed=1
fi

# ruby
if [ -f "Gemfile" ]; then
  echo "$prefix bundle install"
  bundle install
  executed=1
fi

# msbuild
if ls ./*.sln 1> /dev/null 2>&1 || ls ./*.csproj 1> /dev/null 2>&1; then
  echo "$prefix dotnet restore"
  dotnet restore
  executed=1
fi

# gradle
if [ -f "gradlew" ]; then
  echo "$prefix ./gradlew"
  ./gradlew
  executed=1
fi

if (( executed == 0 )); then
  echo "Found nothing to run."
  exit 1
fi
