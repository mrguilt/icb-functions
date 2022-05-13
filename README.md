# icb-functions

`icb-functions` is a collection of elisp functions I've created to support my EMACS environment. Most (but not all) are designed to use [Pandoc](https://pandoc.org/) to convert things written in [Markdown](https://daringfireball.net/projects/markdown/) to other formats. I use these functions, for instnace, as a first draft of [Microsoft Word](https://www.microsoft.com/en-us/microsoft-365/word) documents. 

## Overview

| Function             | Description                                                                                                                                               |
|----------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|
| sign-it              | Insert a signature at the bottom of the buffer                                                                                                            |
| mark-all             | Marks the buffer top to bottom                                                                                                                            |
| insert-date          | Inserts the current date.                                                                                                                                 |
| add-PDF-YAML-header  | Inserts code into buffer to tell pandoc margins and paper size when converting Markdown to PDF.                                                           |
| tempword-buffer      | Runs pandoc on a Markdown buffer, and writes to a designated Microsoft Word file.                                                                         |
| xkcd-it              | Sets the font to xkcd script                                                                                                                              |
| use-machine-font     | Restores typeface to the font designated in the machine-font variable in .emacs                                                                     |
| tempodt-buffer       | Runs pandoc on a Markdown buffer, and writes to a designated OpenText file.                                                                               |
| jekyll-post-header   | Adds YAML information fora post to my blog in the jekyll management system.                                                                               |
| mdcopy               | Copies buffer to clipboard, converting from markdown to RTF.                                                                                              |
| md-to-html-copy      | Copies buffer to clipboard, coverting from markdown to HTML.                                                                                              |
| md-to-plain-copy     | Copies buffer to clipboard, coverting from markdown to plain text.                                                                                        |
| delete-buffer        | Deletes a buffer                                                                                                                                          |
| html-for-metafilter  | Convert Pandoced HTML to something better for pasting at MetaFilter.                                                                                      |
| save-as-word         | Prompts for a file name, and runs pandoc on the text in the buffer to output to a Microsoft Word file of that name. Assumes buffer is in Markdown format. |
| md-region-to-html-co | Same as md-to-html-copy, but for a region.                                                                                                                |
## Details

*This may not be exhaustive now (or ever), but will capture some of the ones that aren't as obvious. I hate to say "read the code," but read the code.*

### insert-date

Just like the name implies, it will insert a date. Three formats to choose from:

|Invocation |Format  |Example     |
|-----------|--------|------------|
|`M-x insert-date`|[ISO 8601](https://en.wikipedia.org/wiki/ISO_8601): YYYY-MM-DD|2022-05-13|
|`C-u M-x insert-date`|US Date: MM/YY/DDDD|05/13/2022
|`C-u C-u M-x insert-date`|Long Date: DoY, Month Day, Year|Friday, May 13, 2022|

### tempword-buffer

Using Pandoc, it will take a buffer written in Markdown, and save it as a Microsoft Word document. It will always save to the file name and location defined in the variable `tempword`, which you can then rename.

If the `C-u` prefix is used on invocation, it will use a template defined in the `tempword-template` variable.

### save-as-word

This is similar to `tempword-buffer`, in that it will save a Markdown-formatted buffer as a Microsoft Word file. However, this version will prompt for a file name to save as, rather than a defined default. This currently does **not** support using a template. 


