## Copyright (C) 2017 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{infostr} = infosettextmatrix (@var{key}, @var{val})
## @deftypefnx {Function File} @var{infostr} = infosettextmatrix (@var{key}, @var{val}, @var{scell})
## @deftypefnx {Function File} @var{infostr} = infosettextmatrix (@var{infostr}, @var{key}, @var{val})
## @deftypefnx {Function File} @var{infostr} = infosettextmatrix (@var{infostr}, @var{key}, @var{val}, @var{scell})
## Returns info string with a text matrix formatted in following format:
## @example
## #startmatrix:: key
##      "val(1,1)"; "val(1,2)"; "val(1,3)";
##      "val(2,1)"; "val(2,2)"; "val(2,3)";
## #endmatrix:: key
##
## @end example
## If @var{scell} is set, the section is put into subsections according @var{scell}. 
##
## If @var{infostr} is set, the section is put into existing @var{infostr} 
## sections, or sections are generated if needed and properly appended/inserted
## into @var{infostr}.
##
## Example:
## @example
## infosettextmatrix('colours', @{'black'; 'blue'@})
## @end example
## @end deftypefn

## Author: Martin Šíra <msiraATcmi.cz>
## Created: 2017
## Version: 1.0
## Script quality:
##   Tested: yes
##   Contains help: yes
##   Contains example in help: yes
##   Checks inputs: yes
##   Contains tests: yes
##   Contains demo: no
##   Optimized: no

function infostr = infosettextmatrix(varargin) %<<<1
        % input possibilities:
        %       key, val
        %       key, val, scell
        %       infostr, key, val
        %       infostr, key, val, scell

        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

        % constant - number of spaces in indented section:
        INDENT_LEN = 8;

        % check inputs %<<<2
        if (nargin < 2 || nargin > 4)
                print_usage()
        endif
        % identify inputs
        if nargin == 4
                infostr = varargin{1};
                key = varargin{2};
                val = varargin{3};
                scell = varargin{4};
        elseif nargin == 2;
                infostr = '';
                key = varargin{1};
                val = varargin{2};
                scell = {};
        else
                if iscell(varargin{3})
                        infostr = '';
                        key = varargin{1};
                        val = varargin{2};
                        scell = varargin{3};
                else
                        infostr = varargin{1};
                        key = varargin{2};
                        val = varargin{3};
                        scell = {};
                endif
        endif
        % check values of inputs
        if (~ischar(infostr) || ~ischar(key))
                error('infosetmatrix: infostr and key must be strings')
        endif
        if (~iscell(val))
                error('infosetmatrix: val must be a cell of strings')
        endif
        if (~all(cellfun(@ischar, val)))
                error('infosetmatrix: val must be a cell of strings')
        endif
        if (~iscell(scell))
                error('infosetmatrix: scell must be a cell')
        endif
        if (~all(cellfun(@ischar, scell)))
                error('infosetmatrix: scell must be a cell of strings')
        endif

        % make infostr %<<<2
        % go line per line (thus semicolons and end of lines can be managed):
        newlines = '';
        for i = 1:size(val,1)
                % for every row make a line:
                newline = sprintf('"%s"; ', val{i,:});
                % join with previous lines, add indentation, add line without last semicolon and space, add end of line:
                newlines = [newlines repmat(' ', 1, INDENT_LEN) newline(1:end-2) NL];
        endfor

        % put matrix values between keys:
        newlines = sprintf('#startmatrix:: %s%s%s#endmatrix:: %s', key, NL, newlines, key);

        % add new line to infostr according scell
        if isempty(scell)
                if isempty(infostr)
                        before = '';
                else
                        before = [deblank(infostr) NL];
                endif
                infostr = [before newlines];
        else
                infostr = infosetsection(infostr, newlines, scell);
        endif
endfunction

% --------------------------- tests: %<<<1
%!shared ismat, ismatsec
%! ismat = sprintf('#startmatrix:: mat\n        "a"; "b"; "c"\n        "d"; "e"; "f"\n#endmatrix:: mat');
%! ismatsec = sprintf('#startsection:: skey\n        #startmatrix:: mat\n                "a"; "b"; "c"\n                "d"; "e"; "f"\n        #endmatrix:: mat\n#endsection:: skey');
%!assert(strcmp(infosettextmatrix( 'mat', {"a", "b", "c"; "d", "e", "f"}                ), ismat));
%!assert(strcmp(infosettextmatrix( 'mat', {"a", "b", "c"; "d", "e", "f"}, {'skey'}      ), ismatsec));
%!assert(strcmp(infosettextmatrix( 'testtext', 'mat', {"a", "b", "c"; "d", "e", "f"}, {'skey'}     ), ['testtext' sprintf('\n') ismatsec]));
%!error(infosettextmatrix('a'))
%!error(infosettextmatrix({'a'}, 'a'))
%!error(infosettextmatrix('a', 'b'))
%!error(infosettextmatrix('a', {'a'}, 'd'))
%!error(infosettextmatrix('a', {'a'}, {5}))
%!error(infosettextmatrix('a', 'b', {'a'}, 'd'))
%!error(infosettextmatrix('a', 'b', {'a'}, {5}))

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000
