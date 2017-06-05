# wolfman [![CircleCI](https://circleci.com/gh/wealthsimple/wolfman.svg?style=svg)](https://circleci.com/gh/wealthsimple/wolfman)

CLI for Rundeck and AWS EC2.

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

TODO: Write instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
