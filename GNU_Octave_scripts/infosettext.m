## Copyright (C) 2014 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{infostr} = infosettext (@var{key}, @var{val})
## @deftypefnx {Function File} @var{infostr} = infosettext (@var{key}, @var{val}, @var{scell})
## @deftypefnx {Function File} @var{infostr} = infosettext (@var{infostr}, @var{key}, @var{val})
## @deftypefnx {Function File} @var{infostr} = infosettext (@var{infostr}, @var{key}, @var{val}, @var{scell})
## Returns info string with key @var{key} and text @var{val} in following format:
## @example
## key:: val
##
## @end example
## If @var{scell} is set, the key/value is enclosed by section(s) according @var{scell}.
##
## If @var{infostr} is set, the key/value is put into existing @var{infostr} 
## sections, or sections are generated if needed and properly appended/inserted 
## into @var{infostr}.
##
## Example:
## @example
## infosettext('key', 'value')
## infostr = infosettext('key', 'value', @{'section key', 'subsection key'@})
## infosettext(infostr, 'other key', 'other value', @{'section key', 'subsection key'@})
## @end example
## @end deftypefn

## Author: Martin Šíra <msiraATcmi.cz>
## Created: 2014
## Version: 4.0
## Script quality:
##   Tested: yes
##   Contains help: yes
##   Contains example in help: yes
##   Checks inputs: yes
##   Contains tests: yes
##   Contains demo: no
##   Optimized: no

function infostr = infosettext(varargin) %<<<1
        % input possibilities:
        %       key, val
        %       key, val, scell
        %       infostr, key, val
        %       infostr, key, val, scell

        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

        % identify and check inputs %<<<2
        [printusage, infostr, key, val, scell] = set_id_check_inputs('infosettext', varargin{:}); %<<<1
        if printusage
                print_usage()
        endif
        % check content of val:
        if ~ischar(val)
                error('infosettext: val must be string')
        endif

        % make infostr %<<<2
        % generate new line with key and val:
        newline = sprintf('%s:: %s', key, val);
        % add new line to infostr according scell
        if isempty(scell)
                if isempty(infostr)
                        before = '';
                else
                        before = [deblank(infostr) NL];
                endif
                infostr = [before newline];
        else
                infostr = infosetsection(infostr, newline, scell);
        endif
endfunction

function [printusage, infostr, key, val, scell] = set_id_check_inputs(functionname, varargin) %<<<1
        % function identifies and partially checks inputs used in infoset* functions 
        % if printusage is true, infoset* function should call print_usage()
        %
        % input possibilities:
        %       key, val
        %       key, val, scell
        %       infostr, key, val
        %       infostr, key, val, scell

        printusage = false;
        infostr='';
        key='';
        val='';
        scell={};

        % check inputs %<<<2
        % (one input is functionname - in infoset* functions is not)
        if (nargin < 2+1 || nargin > 4+1)
                printusage = true;
                return
        endif
        % identify inputs
        if nargin == 4+1
                infostr = varargin{1};
                key = varargin{2};
                val = varargin{3};
                scell = varargin{4};
        elseif nargin == 2+1;
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

        % check values of inputs infostr, key, scell %<<<2
        % input val have to be checked by infoset* function!
        if (~ischar(infostr) || ~ischar(key))
                error([functionname ': infostr and key must be strings'])
        endif
        if isempty(key)
                error([functionname ': key is empty string'])
        endif
        if (~iscell(scell))
                error([functionname ': scell must be a cell'])
        endif
        if (~all(cellfun(@ischar, scell)))
                error([functionname ': scell must be a cell of strings'])
        endif
endfunction
% --------------------------- tests: %<<<1
%!shared istxt, iskey, iskeydbl
%! istxt = 'key:: val';
%! iskey = sprintf('#startsection:: skey\n        key:: val\n#endsection:: skey');
%! iskeydbl = sprintf('#startsection:: skey\n        key:: val\n        key:: val\n#endsection:: skey');
%!assert(strcmp(infosettext( 'key', 'val'                               ), istxt));
%!assert(strcmp(infosettext( 'key', 'val', {'skey'}                     ), iskey));
%!assert(strcmp(infosettext( iskey, 'key', 'val'                        ), [iskey sprintf('\n') istxt]));
%!assert(strcmp(infosettext( iskey, 'key', 'val', {'skey'}              ), iskeydbl));
%!error(infosettext('a'))
%!error(infosettext(5, 'a'))
%!error(infosettext('a', 5))
%!error(infosettext('a', 'b', 5))
%!error(infosettext('a', 'b', {5}))
%!error(infosettext('a', 'b', 'c', 'd'))
%!error(infosettext('a', 'b', 'c', {5}))
