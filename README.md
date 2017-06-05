# wolfman [![CircleCI](https://circleci.com/gh/wealthsimple/wolfman.svg?style=svg)](https://circleci.com/gh/wealthsimple/wolfman)

CLI for Rundeck, CircleCI, and AWS EC2.

<img width="817" src="https://cloud.githubusercontent.com/assets/158675/26771562/1ef1d640-498d-11e7-8b3e-289df492672d.png">

## Installation

Clone the git repository and install gems:

```
git clone git@github.com:wealthsimple/wolfman.git
cd wolfman
bundle install
```

Finally, add an alias so that you can easily execute it:

```
# Insert into ~/.bashrc or equivalent
alias wolfman="/path/to/wolfman-repo/bin/wolfman"
```

## Usage

Run `wolfman` and it will give you an overview of possible commands:

```
NAME
    wolfman - CLI for Rundeck, CircleCI, and AWS EC2

DESCRIPTION
    Run a command: wolfman COMMAND [command-specific-options]

    Get help for a specific command: wolfman help COMMAND

COMMANDS
    builds      manage circleci builds
    config      configure connection settings for AWS, Rundeck, and more
    console     open a console on an EC2 machine
    help        show help
    jobs        manage rundeck jobs
    open        open an app/service in your web browser
```

On first use, you'll have to run `wolfman config` to configure your AWS and Rundeck connection settings.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.
