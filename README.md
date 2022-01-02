# Purpose

This is a demo repository that showcases the 1-1-1 setup, which I introduced on my blog [here](https://lietzau-consulting.de/2020/05/source-management-sfdx-part-1/).
Cleanup checklist after using this template

- modify scratch org definition file to your requirements
- modify CI config to your likings
- add more meaningful test data
- rework `sfdx-project.json` (package name, dependencies, aliases, etc)
- add npm dependencies (like newman, eslint, local dev server, etc)
- remove demo source and replace with actual package contents.
- modify setup script with your requirements (install dependencies, assign package permission sets, test data scripts, etc)
- remove this section from README ;).

# Repository Structure

The repository is meant to contain a single SFDX project. The SFDX project contains only a single 2nd gen package.
Why? So we have better control over permissions and can easily replicate all scripts and folders. See my blog post for more details.

- [config](config): contains scratch org definition files.
- [data](data): test data for scratch org setup.
- [scripts](scripts): anonymous apex and org setup scripts
- [src](src): packaged source, unpackaged source and deployable source
- [force-app](force-app): the default folder for sfdx CLI. Use as temporary target for source push/pull and organize to src.

## Source Structure

Source is organized in four sub directories. Sub-directories are handled differently during org setup, package build and deployment.

- [packaged](src/packaged): Pushed to Scratch Org. Added to package contents. Deployed on persistent orgs with `force:package:install`.
- [unpackaged](src/unpackaged): Pushed to Scratch Org. Not added to package contents. Not deployed on persistent orgs.
- [deploy](src/deploy): Not pushed to Scratch Org. Not added to package contents. Deployed on persistent orgs with `force:source:deploy`.
- [unpackaged-deploy](src/unpackaged-deploy): Pushed to Scratch Org. Not added to package contents. Deployed on persistent orgs with `force:source:deploy`

### Packaged

Use this directory to organize all 2nd gen packaging compatible source, that is part of this package **and** can be deployed as package install.
As a best practice, avoid layouts, paths, profiles, communities and anything that changes too frequently.
Organize source within this directory like this:

```
-- packaged
 |-- main           # your main application
   |-- default      # core code like data model, labels, core libs, etc
   |-- test         # tests of core application like e2e tests, unit tests, fixtures
   |-- utils        # anything you want to have organized neatly in a different directory
 |-- feature-one    # an isolated feature that builds on the main application, that is too small (yet) for an independent package
   |-- default
   |-- test
 |-- feature-two    # an isolated feature that builds on the main application, that is too small (yet) for an independent package
   ...
```

### Unpackaged

Source in this directory does not has to be compatible with 2nd gen packaging. As long as the source can be deployed with `force:source:push`, it can be put in this directory.
Use this directory for source, that should be available on your dev environment (layouts, profiles, applications) but should not end up on a persistent org (Integration, Staging, Production).

### Deploy

Source in this directory is not part of the development process (hence, not on dev environment), but used to override packaged source on a persistent org.
Use this for 2nd gen packaging incompatible metadata such as workflow rules with organization-wide email addresses, auto-response rules, etc.

### Unpackaged Deploy

This directory is a hybrid of unpackaged and deploy: The source is pushed to the scratch org (available in dev environment), but also deployed on the persistent org.
It is not part of the package, typically because of incompatibility with packaging or bugs in SFDX (like translations, standard value sets, etc). Try to avoid this as good as possible.

# Dev Environment Setup

This package uses a setup script that automatically creates a scratch org, installs all dependencies, pushes the source and imports test data.
You can export all installation keys, so the script does not prompt for the keys. For convenience, make sure that your CLI has a DevHub enabled production org set as `defaultusername`

```bash
export INSTALLATION_KEY_ONE=
export INSTALLATION_KEY_TWO=
```

Run the script to setup a dev environment

```bash
# default scratch org alias
bash scripts/setup/macOS.sh
# manually override scratch org alias
bash scripts/setup/macOS.sh -a MyCustomAlias
# manually override alias and devhub
bash scripts/setup/macOS.sh -a MyCustomAlias -v MyDevhubAlias
```

# Prettier

This repo uses [Prettier](https://prettier.io/). Use the npm scripts to format all compatible source.
Formatting XML (and therefore, all \*-meta.xml files) is deliberatly not supported, because the SFDX CLI generates an incompatible formatting that would result in continuous overrides.
Install the [Prettier Extension](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode) to make use of meaningful autoformatting on save and type.

```bash
# format all source, including jsons, visualforce, lwc, apex, etc
npm run prettier:format
# format only apex
npm run prettier:format:apex
# format only LWC
npm run prettier:format:lwc
```
