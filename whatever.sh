#!/usr/bin/env bash

set -o nounset
prefix=$'\n$'
executed=false
nopull=false
noinstall=false
unknownflag=false

# parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    "-p"|"--no-pull")
    nopull=true
    shift # shift once since flags have no values
    ;;
    "-i"|"--no-install")
    noinstall=true
    shift # shift once since flags have no values
    ;;
    *) # unknown flag/switch
    unknownflag=true
    shift
    ;;
  esac
done

if [ "$unknownflag" = true ]; then
  echo "Unknown flag"
  exit 1
fi

# git
if git rev-parse --is-inside-work-tree 1> /dev/null 2>&1 ; then
  echo "$prefix git fetch --all --prune --tags --force"
  git fetch --all --prune --tags --force

  # if the current branch has an upstream and differs from the local branch
  if [ "$nopull" = false ] && git rev-parse '@{u}' 1> /dev/null 2>&1 && [ "$(git rev-parse HEAD)" != "$(git rev-parse '@{u}')" ]; then
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

  executed=true
fi

if [ "$noinstall" = false ]; then
  # npm/yarn
  if [ -f "package.json" ]; then
    if [ -f "yarn.lock" ]; then
      echo "$prefix yarn install"
      yarn install
    else
      echo "$prefix npm install"
      npm install
    fi

    executed=true
  fi

  # bower
  if [ -f "bower.json" ]; then
    echo "$prefix bower install"
    bower install
    executed=true
  fi

  # python
  if [ -f "Pipfile" ]; then
    echo "$prefix pipenv install --dev"
    pipenv install --dev
    executed=true
  elif [ -f "requirements.txt" ]; then
    echo "$prefix pip3 install -r requirements.txt"
    pip3 install -r requirements.txt
    executed=true
  fi

  # ruby
  if [ -f "Gemfile" ]; then
    echo "$prefix bundle install"
    bundle install
    executed=true
  fi

  # msbuild
  if ls ./*.sln 1> /dev/null 2>&1 || ls ./*.csproj 1> /dev/null 2>&1; then
    echo "$prefix dotnet restore"
    dotnet restore
    executed=true
  fi

  # gradle
  if [ -f "gradlew" ]; then
    echo "$prefix ./gradlew"
    ./gradlew
    executed=true
  fi
fi

if [ "$executed" = false ]; then
  echo "Found nothing to run."
  exit 1
fi
