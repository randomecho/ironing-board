# Chat transcript ironing board

Reads in a username file and a transcript, (or a folder full of transcripts)  
and renders the alignment in a pleasant fashion.

## Usage

If you only have a single transcript to parse

    $ chatscript-iron.rb path/to/usernames path/to/transcript

Or if there's a whole batch sitting in a folder

    $ chatscript-iron.rb path/to/usernames path/to/transcript-folder

The usernames file can be in the same folder as the transcript folder.

When it's done go check the exported folder specified in the preferences.

### Example

From this mess:

    Amelia Mintz  Guess what we're having for dinner?
    Tony Chu  Don't tell me.
    Amelia Mintz  You eat and I'll write.
    Colby    Well, the both of you can dine on beets, but I'm out for some steak
    Poyo bok bok
    Tony Chu  Who invited him?
    Poyo bok bok
    bok

The ironing board will render this:

    Amelia Mintz   Guess what we're having for dinner?
    Tony Chu       Don't tell me.
    Amelia Mintz   You eat and I'll write.
    Colby          Well, the both of you can dine on beets, but I'm out
                   for some steak
    Poyo           bok bok
    Tony Chu       Who invited him?
    Poyo           bok bok
                   bok

## License

[BSD 3-Clause License](http://opensource.org/licenses/BSD-3-Clause).

### License for demo files

Demo Campfire chat transcripts and list of users come from the class notes of GitHub's
[teach.github.com](https://github.com/github/teach.github.com) and are licensed under
[Creative Commons Attribution 3.0 Unported](http://creativecommons.org/licenses/by/3.0/deed.en_US).