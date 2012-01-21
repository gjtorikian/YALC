# Introduction

I got tired of looking for a broken link checker for my HTML files that existed locally. After two bourbon manhattans, I decided to write one.

# Usage

Super simple: just run

	perl yalc.pl _input_dir_ _[caseCheck]_

And that's it. YALC will recurse through all _.html_ and _.htm_ files in _[input_dir]_ and subdirectories, examining any anchor tag (`<a>`) that doesn't go out to the web (therefore, local files only). If the file doesn't exist, it'll print a message.

If you want to check case-sensitivity with the links, just pass the letter `y` as a second argument. I tested that this works even on a case-insensitive system like Mac OS X.

The link checker also checks hash references; for example, `<a href="foo.html#bar">`. Even if _foo.html_ exists, if the `bar` reference does not, there will be a complaint.