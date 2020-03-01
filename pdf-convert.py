#!/usr/bin/env python3
# coding: UTF-8
#
# Copyright (c) 2019
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom
# the Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall
# be included in all copies or substantial portions of the
# Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#

import argparse
import logging
from os import access, W_OK
import PyPDF2
import sys
import time

args = None


def get_commandline() -> argparse.Namespace:
    '''Parse command line arguments

    Parameters
    ----------

    Returns
    -------
    Object with attributes for all comand line parameters : argparse.Namespace
    '''

    ap = argparse.ArgumentParser()

    ap.add_argument(
        '-v', '--version', action='version', version='%(prog)s 0.1a',
        help='Show program\'s version and exit.')
    ap.add_argument(
        '-l', '--loglevel', default='INFO',
        help='Loglevel: DEBUG, INFO (default), WARNING, ERROR, CRITICAL')
    ap.add_argument('srcFile', nargs=1)
    ap.add_argument('dstFile', nargs=1)

    return ap.parse_args()


def do_convert(source, target):
    '''Extract first page from file and generate thumbnail

    Parameters
    ----------
    source : string
        Full path of source file

    target: string
        Full path of target thumbnail

    Returns
    -------
    '''

    pdf1File = open(source, 'rb')
    pdf2File = open(target, 'wb')

    pdfReader = PyPDF2.PdfFileReader(pdf1File)
    pdfWriter = PyPDF2.PdfFileWriter()

    pageObj = pdfReader.getPage(0)
    pdfWriter.addPage(pageObj)
    pdfWriter.write(pdf2File)

    pdf1File.close()
    pdf2File.close()


def main():
    # Retrieve command line arguments
    args = get_commandline()

    # Initialize logging
    numeric_loglevel = getattr(logging, args.loglevel.upper(), None)
    if not isinstance(numeric_loglevel, int):
        raise ValueError('Invalid log level: %s' % args.loglevel)

    logformat = "%(asctime)s %(levelname)-8s %(message)s"
    logging.basicConfig(format=logformat,
                        level=numeric_loglevel,
                        datefmt="%Y-%m-%d %H:%M:%S")

    logging.debug('Source: %s', args.srcFile[0])
    logging.debug('Destination: %s', args.dstFile[0])

    start_time = time.time()

    do_convert(args.srcFile[0], args.dstFile[0])

    elapsed_time = time.time() - start_time
    logging.info('Ok (%.2f sec)', elapsed_time)


if __name__ == '__main__':
    main()
