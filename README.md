# FMLForms

Render [FML form documents](https://docs.google.com/a/adhocteam.us/document/d/1GBfEEJ48grDz0qwK-Tjppdmpp6mDBCND0UfrA0u1WF4/edit) into other formats.

## Usage

To run the tests just run `bundle install` then `rake`

## Installation

Add this line to your application's Gemfile:

    gem 'fmlforms'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fmlforms

## Deploying

To deploy to our geminabox server, you first need to increment the version of
the gem, which is in lib/fml/version.rb. Then:

    # if you don't have the source added, add it. After you've done this once,
    # you shouldn't need to do it again
    $ gem sources -a http://107.170.81.161:9292/
    $ rake deploy
