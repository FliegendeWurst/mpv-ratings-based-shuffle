ratings-based-shuffle
=====================

Simple mpv script to easily customize random playlist song selection.

Usage
-----

Every file initially has a 'rating' of `1`. Using the upvote/downvote keybindings, the rating of the currently playing file can be multiplied by 1.1 or 0.9. In RBS mode (activated by another keybinding), a new file is randomly chosen (chance [rating]/[files in playlist]) after playback of any file is completed.

Installation and configuration
------------------------------

Place `ratings-based-shuffle.lua` in your `~/.config/mpv/scripts`.

Copy `ratings-based-shuffle.conf` into `~/.config/mpv/script-opts` and adjust the option values: set `directory` to the location of the files you want to play. Ratings will be saved in the file specified by `ratings_file`. Example:

```
directory=/home/username/Music/BigPlaylist
ratings_file=/home/username/.config/mpv/rbs-ratings.txt
```

Set up the keybindings in your `input.conf` (usually located in `~/.config/mpv`):

```
Alt+r script-message RBS-init
Alt+UP script-message RBS-upvote
Alt+DOWN script-message RBS-downvote
```

Technical details
-----------------

In the `ratings_file`, files and associated ratings are stored:

```json
{
	"/home/username/Music/BigPlaylist/Topic/Directory/Song Name.mp3":1.100000,
	"/home/username/Music/BigPlaylist/Another topic/LoremIpsum.mp3":0.810000
}
```

TODO
----

Add a mode where songs only repeat after playing ~75% of all available files (has to be persisted across mpv runs).
