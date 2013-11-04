## Rdio collection grabber ##
Find the latest additions to your Rdio collection,
see if they're on your hard drive, assuming you use iTunes folder structure,
and use the `whatcdsearch` script to download the goodies. (pass its path to this script)
So I can automagically keep my iTunes library up-to-date with my new Rdio finds.
Now you can stop feeling like you're neglecting your REAL library!

## Requires ##
- Ruby, gems:
 - mechanize

## Setup ##

1. Get my fork of whatcdsearch
2. Go to http://developer.rdio.com/ and get an API key/secret.
3. Rename `config.rb.example` to `config.rb` and fill it out!

## Usage ##

`./rdio_collection_grabber.rb "PATH_TO_WHATCDSEARCH"`
(and once you see it works, set that up in cron so it's set and forget-ed)