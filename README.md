# Info strings

A human-readable brain-dead simple data format with saving and loading scripts and VIs.

This data format aims for:
1, human readability;
1, easy manual editing;
1, easy manual creating;
1, easy storage of text data, numeric data and matrices.

## Format
Format consists of system of keys and values separated by double colon.

    some key :: some value
    other key :: other value
    A:: 1
    B([V?*.])::    !$^&*()[];::,.

Keys can contain any character but newline (and probably shouldn't contain double colon).
White characters can be before key, after key, before or after delimiter (::) or after key.
Value can be anything but newline.

Any text can be inserted in between lines.

    some key :: some value
    something totally not related to anything
    other key :: other value

Matrices are stored as semicolon delimited values, space characters are not important,
however semicolon must be right after a numeric value. Matrices starts by keyword #startmatrix::
NameOfMatrix and ends by keyword #endmatrix:: NameOfMatrix.

    #startmatrix:: simple matrix 
    1;  2; 3; 
    4;5;         6;  
    #endmatrix:: simple matrix


Sections are used for multiple keys with same values or multiline content. Sections starts by keyword #startsection::
NameOfSection and ends by keyword #endsection:: NameOfSection.

    #startsection:: section 1 
        C:: c in section 1 
        #startsection:: subsection
            C:: c in subsection
        #endsection:: subsection
    #endsection:: section 1
    #startsection:: section 2
        C:: c in section 2
    #endsection:: section 2
    #startsection:: multiline content
        abcdefgh
        ijklmnopqrstuv
        wxyz
    #endsection:: multiline content

Number precision is determined by the programming language. The aim of scripts and vis was to keep
at least 12 digits of precision (really needed for some scientific calculations, some times even
more is required).

The time is saved by scripts and vis according ISO 8601 format, i.e.:

    yyyy-mm-ddThh-mm-ss.ssssss

## GNU Octave scripts
Scripts for saving and loading:
1, text data -- infosettext.m, infogettext.m;
1, scalar numeric data -- infosetnumber.m, infogetnumber.m;
1, vector and matrix numeric data -- infosetmatrix.m, infogetmatrix.m;
1, time data -- infosettime.m, infogettime.m;
1, sections -- infosetsection.m, infogetsection.m.

All scripts contains also:
1, help in texinfo format;
1, examples in help;
1, tests;

## GNU Octave package

## Matlab scripts
I try to keep Matlab compatibility, however it irritates me quite a lot. Matlab language is superior
to GNU Octave possibilities.

Scripts for Matlab are generated from GNU Octave scripts using _octave2matlab_ by _thierr26_.
See [octave2matlab github webpage](https://github.com/thierr26/octave2matlab "octave2matlab"). 
Run script XXX to convert Matlab scripts from GNU Octave scripts.

Currently the conversion have some bugs and must be fixed manually.
XXX
chyba v example \n se prevadi na opravdovou novou radku
v regexp vyrazu se \1 prevede na trojuhelnik

## LabVIEW VIs


## Why yet another data format?
There are other data serialization formats. However these formats were usually developed by
programmers. Arrays are not the most typical thing to write down into human readable format. However
during measurements I needed to store matrices with few elements as well as large series of measured
data. Follows basic list of existing formats and reasons why I do not use it for measurement data.

(Maybe there is some ideal data format but I couldn't find it.)

###XML
Format appears to be human readable but really it is too talkative and too cluttered. And try to
write down a matrix in this format. See a simple vector stored in XML:

    <Matrix>
        <Element>-0.281325798</Element>
        <Element>0.0291150014</Element>
        <Element>0.00121234399</Element>
        <Element>-0.000140823665</Element>
        <Element>0.154861424</Element>
    </Matrix>

###JSON
It is definitely _not_ human readable format.

###INI
Nice and human readable, but vectors or matrices are not implemented by any library.

###YAML
Generally nice and human readable format but matrices are not easily readable and editable:

    -
      - 1
      - 2
    -
      - 3
      - 4

###TOML
Similar to INI, however matrices are not easily readable and editable:

    matrix = [ [1, 2], [3, 4] ]

###GNU Octave text format
GNU Octave use simple and powerful format for data saving, the problem is it is too talkative and
hard to write manually. See example of a matrix:

    # Created by Octave 3.8.1, Thu Jun 29 21:13:18 2017 CEST <some_user@some_server>
    # name: a
    # type: matrix
    # rows: 2
    # columns: 2
     1 2
     3 4

