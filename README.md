# Shellb

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/shellb`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

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

TODO: Write usage instructions here

## Examples

```
%w[a b c d e f g].each do |cmd|
  ShellB.def_system_command(cmd)
end

shb = ShellB.new
script = shb.transact do
  a | b | c("--last", "--delimiter", "\t")
end
puts script # a | b | c --last --delimiter "\t"

shb = ShellB.new
script2 = shb.a("--help") | shb.e("last")
puts shb.to_script # => a --help | e last

shb.cd("/tmp") do
  pwd
end # => (cd /tmp ; pwd)

# Handle Multiple Inputs into a Command
# Allow variable names as arguments
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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aguynamedryan/shellb.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
