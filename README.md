# whatever

Whatever is a simple script that automates the commands I usually want to run when returning to a repository or codebase.

It runs in the current directory and starts by fetching and pulling from git. It then restores packages for various package managers, depending on the presence of known files, such as `package.json` or `Gemfile`.
The intent is to get the working copy into a ready-to-code state without thinking too much about it. _Just do whatever._

| Condition                                            | Command                                                      |
| ---------------------------------------------------- | ------------------------------------------------------------ |
| Inside git working copy                              | `git fetch --all --prune --tags --force`                     |
| Inside git working copy and current branch is behind | `git pull --rebase` (automatic stash if uncommitted changes) |
| `package.json` and `yarn.lock`                       | `yarn install`                                               |
| `package.json` (without `yarn.lock`)                 | `npm install`                                                |
| `bower.json`                                         | `bower install`                                              |
| `Pipfile`                                            | `pipenv install --dev`                                       |
| `requirements.txt` (without `Pipfile`)               | `pip3 install -r requirements.txt`                           |
| `Gemfile`                                            | `bundle install`                                             |
| `*.sln` or `*.csproj`                                | `dotnet restore`                                             |
| `gradlew`                                            | `./gradlew`                                                  |
