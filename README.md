# WallCalendar project

## Project goal

To have a toolkit to print the high-quality yearly wall calendars in a reasonably fast way.

Original publishing target for this project was lulu.com but it can be used as a general-purpose tool.

Output pdf has:

- Cover ready to be sent to the publisher
- Interior ready to be sent to the publisher
- Integration with web site through QR web codes

Web site example (using txt2site) is also supplied with the sources.

## Source tree structure

### Folder "templates"

Contains the calendar templates. Name of the template is the name of the directory.  Template is a set of TeX files and Makefile to build pdfs out of them

### Folder "calendars"

Contains calendars which are built on top of any templates. These calendars contain the template parameters such as photos, holidays, website URL etc. The set of parameters depends on the
template.

### Folder "resources"

Contains resources which can be commonly used by different templates (e.g., flags and other graphical resources).

### Tools used

- Primary tool is LaTeX (_pdflatex_).
  - _TikZ_ is used to draw the calendar grid in the templates. This is the recommended way to go for the creators of the new templates.
  - _pst-barcode_ is used to draw QR codes
  - _latexmk_ is used to launch pdflatex
- _convert_ utility from the package _ImageMagick_ is used for converting files between different graphical formats.
- _exiv2_ utility is used to embed licensing metadata into the images (optional, useful if you are going to distribute images separately from the calendar itself)
- _GNU make_ is used to build pdf files from LaTeX sources
- _txt2site_ utility to build static web sites (optional)
- _perl_ to manage templates

## How to Start

### Understanding how it all works

The sources contain two examples of the calendar: real-life example _FourSeasons2014_ and trivial example _Trivial2014_.
Both examples use the same calendar template: _RuEnPhoto2014_.

Trivial example could be useful if you modify the template and want to increase the compilation speed. The resulting files are also quite compact and it could make sense
to send the pdf output of the trivial example to the customers or other team members when the work is focused on calendar grid design itself.

Start from looking into an example calendar: calendars/FourSeasons2014/

Build the calendar there by following the steps below:

1. Synchronize calendar with the template: `./CalManage.pl --sync-cal FourSeasons2014 RuEnPhoto2014` (you can check all the supported options of this script by launching it without arguments).
1. Make sure you have all the non-optional tools installed (see the section "Tools used")
1. Build the project: `make all`. It should generate the following files:
  - _2014.pdf_ Calendar suitable for viewing (horizontal orientation)
  - _2014-lanscape.pdf_ Calendar suitable to sending to the publisher (90 degrees rotated)
  - _front.pdf_ Front cover suitable for viewing (horizontal orientation)
  - _back.pdf_  Back cover suitable for viewing (horizontal orientation)
1. Change the customization settings in customization.tex and re-build the project to see the effect of your changes
1. Go the "web" sub-folder of the example. You will see how the web site is created using txt2site utility.
1. In order to generate web site launch `make web` from the folder calendars/FourSeasons2014/

### Creating new Calendar based on existing template

We will use RuEnPhoto2014 as an example of the template below.

1. Launch `./CalManage.pl --new-cal NewCal RuEnPhoto2014` (_NewCal_ will be the name of your new calendar)
1. Edit customization files _customization.tex_ and _custom.mk_ in the clendar directory. Put the required images into the subfolder required by the template (typically, _photos_)
1. Build your project using `make all`

### Creating new template

1. Create new sub-folder in the directory _templates_. Name of this subfolder will be the name of the template (used by CalManage.pl script)
2. Create Makefile and TeX files needed for your template. It is strongly advised to use the template RuEnPhoto2014 as an example.
