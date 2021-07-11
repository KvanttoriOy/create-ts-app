#!/bin/bash

# NOTE: These scripts have only been tested on the latest macOS.
# Not sure if these will work with linux for example.
# If this does not work on your machine, make a pr with fixes :)

# Check argument
if [ $# -lt 1 ]; then
  echo 1>&2 "$0: not enough arguments!"
  exit 2
fi

# Check 
if [ -d "$1" ]; then
  echo "$0: '$1' already exists!"
  exit 2
fi

mkdir $1
cd $1

# Project init
npm init
npm install --save-dev typescript eslint @typescript-eslint/eslint-plugin @typescript-eslint/parser ts-node-dev jest @types/jest ts-jest

# Delete useless test script
sed -i.bak '7d' package.json

# Add necessary scripts
sed -i.bak '/"scripts":/a \
    "tsc": "tsc",\
    "dev": "ts-node-dev ./index.ts",\
    "lint": "eslint --ext .ts .",\
    "start": "node build/index.js",\
    "test": "jest --verbose --runInBand"\
' package.json

npm run tsc -- --init
npx ts-jest config:init

# tsconfig.json outDir
sed -i.bak '17d' tsconfig.json
sed -i.bak '/"module": "commonjs",/a \
    "outDir": "./build/",                           /* Redirect output structure to the directory. */\
' tsconfig.json

# Remove sed backups
rm package.json.bak
rm tsconfig.json.bak

# ESlint
npx eslint --init
touch .eslintignore
echo "jest.config.js
build
node_modules" >> .eslintignore

# Placeholder index.ts
touch index.ts
echo "console.log('Hello World')" >> index.ts

# Placeholder test
mkdir tests
touch tests/dummy.test.ts
echo "test('Dummy test', () => {
  const one = 1;
  expect(one).toBe(1);
});" >> tests/dummy.test.ts

# Git
touch .gitignore
echo "node_modules
build" >> .gitignore

# https://stackoverflow.com/a/38088814
inside_git_repo="$(git rev-parse --is-inside-work-tree 2>/dev/null)"

if [ "$inside_git_repo" ]; then
  echo "inside git repo, skipping init..."
  git add .
  git commit -m "initial commit"
else
  echo "not in git repo, initializing..."
  git init
  git add .
  git commit -m "initial commit"
fi