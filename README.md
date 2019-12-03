# ShellB

`ShellB` (pronounced Shelby) is a shell script builder.  The goal is to be a (near) drop-in replacement for Ruby's `Shell` class


## FAQ

### Wha?  Why?

I've long loved Ruby's `Shell` class, essentially a DSL for building a shell script.

Imagine my dismay when I realized that piping information between commands in `Shell` is done _through_ Ruby, making my beautiful shell scripts _slow_ and _hungry_ for memory.

I wanted something that would build out my shell scripts like `Shell`, but would _stay_ in the shell where commands and pipes work quickly and smoothly.

### I used `ShellB` in place of `Shell` and it didn't work

Yikes.  I'm not surprised. The library Works For Me in that the few places I use it and I haven't really developed it beyond my own needs.

Also, there are some differences I can't figure out how to avoid.

### Why are there so many \\\\\\\\'s in my script?

Ruby's `Shellwords` library does that.  If you know of a better library for properly escaping shell-related strings, let me know!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'shellb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shellb

## Usage

`ShellB` is intended to work similarly to Shell.  There are a few differences:

1. All commands you intend to use must be defined via `ShellB.def_system_command`
2. Unlike `Shell`, `ShellB` will not run any commands on its own.  You must either
  - Call `#run` on a `ShellB::Shell` instance
  - Call `ShellB::Shell#run { <commands here> }` which will immediately execute the script

See the examples below.

## Examples

```
%w[a b c d e f g].each do |cmd|
  ShellB.def_system_command(cmd)
end

# Support Shell's #transact method -- my favorite way to build a script
shb = ShellB.new
script = shb.transact do
  a | b | c("--last", "--delimiter", "\t")
end
puts script # a | b | c --last --delimiter "\t"

# Invoke methods directly on ShellB::Shell instance
shb = ShellB.new
shb.a("--help") | shb.e("last")
puts shb.to_sh # => a --help | e last

# Run a script
shb = ShellB.new
shb.a("--help") | shb.e("last")
shb.run # creates a temporary script file and invokes it using Bash

# Immediately run a script after building it
ShellB.new.run do
  a | b
  c
end

# Support `cd` ala Shell
# NOT YET IMPLEMENTED
shb.cd("/tmp") do
  pwd
end # => (cd /tmp ; pwd)

# Handle Multiple Inputs into a Command
# Allow variable names as arguments
# NOT YET IMPLEMENTED
file1_csv = "/tmp/file1.csv"
file2_csv = "/tmp/file2.csv"
shb.transact do
  diff \
    < transact(do
        xsv("sort", file1_csv) | head
      end) \
    < transact({
        xsv("sort", file2_csv) | tail
      })
end # => diff <(xsv sort /tmp/file1.csv | head) <(xsv sort /tmp/file2.csv | tail)
```

## Future Ideas

Some ideas I'm toying with:

### Support for hash => switches

It might be handy to feed a hash to a command and have that generate the appropriate switches for a command.

Something like:

```
shb = ShellB.new
shb.transact do
  e(long_switch: "value", s: true)
end
puts shb.to_sh # => e --long-switch value -s
```

However, how do we handle some of the following?

- Underscore vs dash in long names?
  - E.g. does `long_switch_name` become `--long-switch-name` or `--long_switch_name`
- For long switches, do we include an equals sign if a value is included?
  - E.g. does `long_switch_name: "value"` become `--long-switch-name=value` or `--long-switch-name value`
- For switches without arguments, do we relegate those to an array only, or allow them in the hash?
  - E.g. does `s: true` become `-s`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Similar Projects

As any good programmer, I wrote first and googled later.  Here are some other projects that seem very similar to ShellB:

- https://github.com/jgoizueta/sys_cmd
- https://github.com/duncanbeevers/sheller
- https://github.com/fetlife/scallop
- https://github.com/quark-zju/easysh
- https://github.com/eropple/shellator
- https://github.com/petyosi/shellshot
- https://github.com/taccon/eksek

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aguynamedryan/shellb.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
