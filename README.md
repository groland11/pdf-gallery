# pdf-gallery
Create HTML gallery from PDF files

This is a very simple bash script that creates a single HTML file from all PDF documents in the current directory. The HTML file contains a gallery with thumbnails of the first page of all PDF documents. If you click on a thumbnail, the corresponding PDF file will be opened in a new browser window.

All thumbnails are stored in a subdirectory called idx. This is the overall directory structure:
```
 ├-- my_book1.pdf
 ├-- my_book2.pdf
 ├-- my_book3.pdf
 ├-- idx.html
 ├-- idx/
     ├-- idx-my_book1.jpg
     ├-- idx-my_book2.jpg
     ├-- idx-my_book3.jpg
```

## Features
- Sort by name or modification date
- Reverse sort order
- Only create thumbnails of new PDF documents (saves time), or force to overwrite old thumbnails
- Delete old thumbnails of PDF documents that no longer exist
- Abort operation if there are too many conversion errors
- Test dependencies and display result in help output
- Output debug messages to analyze errors
- Quiet run, suppress any output or error messages

## Requirements
- **pdftk** (extract first page from PDF file)
- **ImageMagick** (convert extracted first PDF page to thumbnail)

## Installation
1. Just copy the the script somewhere in your path, e.g. /home/user/bin .
2. Run "pdf-gallery.sh -h". It will tell you if there are any problems with the installation (missing dependencies, etc.).
3. Enable PDF file conversion for ImageMagick. Many Linux distributions disable this function for security reasons by default. If you are confident that PDF file conversion does not impose any security threats to your system, comment the following line in /etc/ImageMagick-6/policy.xml by enclosing it with "<!--" and "-->" markers:
<!-- <policy domain="coder" rights="none" pattern="PDF" /> -->

## Usage
```
Usage: pdf-gallery.sh [-m] [-r] [-f] [-k] [-e <max_errors>] [-q] [-d] [-h]
        -m: Sort by pdf file modification date (newest first)
        -r: Reverse sort order
        -f: Force creation of thumbnails even if they already exist
        -e <max_errors>: Maximum number of errors for creating thumbnails
        -k: Keep old thumbnails that are associated to vanished pdf files
        -q: Quiet, suppress output (no warning or error messages)
        -d: Output debug messages
        -h: Display usage, check requirements and exit
```

## Example
```
$ pdf-gallery.sh -m -r
ERROR: Unable to convert file "myfile1.pdf" (pdftk=2)
ERROR: Unable to convert file "myfile2.pdf" (pdftk=2)
$ ls
idx
idx.html
myfile1.pdf
myfile2.pdf
myfile3.pdf
...
```

## Screenshots
<div align="center">
    <img src="/screenshots/screen1.png" width="400px"</img>
</div>
