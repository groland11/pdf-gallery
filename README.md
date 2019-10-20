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

## Screenshots

