## Copyright (C) 2013 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{text} = infogettimematrix (@var{infostr}, @var{key})
## @deftypefnx {Function File} @var{text} = infogettimematrix (@var{infostr}, @var{key}, @var{scell})
## Parse info string @var{infostr}, finds lines after line
## '#startmatrix:: key' and before '#endmatrix:: key', parse numbers from lines
## and returns the values as number of seconds since the epoch (as in function
## time()). Expected time format is ISO 8601: %Y-%m-%dT%H:%M:%S.SSSSSS. The number
## of digits in fraction of seconds is not limited.
##
## If @var{scell} is set, the key is searched in section(s) defined by string(s) in cell.
##
## Example:
## @example
## infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n"a";  "b"; "c" \n"d";"e";         "f"  \n#endmatrix:: simple matrix \n#startmatrix:: time matrix\n  2013-12-11T22:59:30.123456\n  2013-12-11T22:59:35.123456\n#endmatrix:: time matrix\nC:: c without section\n#startsection:: section 1 \n  C:: c in section 1 \n  #startsection:: subsection\n    C:: c in subsection\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: c in section 2\n#endsection:: section 2\n')
## infogettimematrix(infostr,'time matrix')
## @end example
## @end deftypefn

## Author: Martin Šíra <msiraATcmi.cz>
## Created: 2013
## Version: 4.0
## Script quality:
##   Tested: yes
##   Contains help: yes
##   Contains example in help: yes
##   Checks inputs: yes
##   Contains tests: yes
##   Contains demo: no
##   Optimized: no

function tmatrix = infogettimematrix(varargin) %<<<1
        % identify and check inputs %<<<2
        [printusage, infostr, key, scell] = get_id_check_inputs('infogettimematrix', varargin{:});
        if printusage
                print_usage()
        endif

        % get matrix %<<<2
        infostr = get_matrix('infogetmatrix', infostr, key, scell);
        % parse csv:
        smat = csv2cell(infostr);

        % convert to time data:
        for i = 1:size(smat, 1)
                for j = 1:size(smat, 2)
                        s = strtrim(smat{i, j});
                        tmatrix(i, j) = iso2posix_time(strtrim(smat{i, j}));
                endfor
        endfor
endfunction

function [printusage, infostr, key, scell, is_parsed] = get_id_check_inputs(functionname, varargin) %<<<1
        % function identifies and partially checks inputs used in infoget* functions 
        % if printusage is true, infoget* function should call print_usage()
        %
        % input possibilities:
        %       infostr, key,
        %       infostr, key, scell

        printusage = false;
        infostr='';
        key='';
        scell={};

        % check inputs %<<<2
        if (nargin < 2+1 || nargin > 3+1)
                printusage = true;
                return;
        endif
        infostr = varargin{1};
        key = varargin{2};
        % set default value
        % (this is because Matlab cannot assign default value in function definition)
        if nargin < 3+1
                scell = {};
        else
                scell = varargin{3};
        endif

        % input is parsed info string? 
        is_parsed = isstruct(infostr) && isfield(infostr,'this_is_infostring');

        % check values of inputs infostr, key, scell %<<<2
        if ~ischar(infostr) && ~is_parsed
                error([functionname ': infostr must be either string or structure generated by infoparse()'])
        endif
        if ~ischar(key) || isempty(key)
                error([functionname ': key must be non-empty string'])
        endif
        if (~iscell(scell))
                error([functionname ': scell must be a cell'])
        endif
        if (~all(cellfun(@ischar, scell)))
                error([functionname ': scell must be a cell of strings'])
        endif
endfunction

function [section, endposition] = get_section(functionname, infostr, scell) %<<<1
        % finds content of a section (and subsections according scell)
        %
        % functionname - name of the main function for proper error generation after concatenating
        % infostr - info string with all data (raw string or parsed struct)
        % scell - cell of strings with name of section and subsections
        %
        % function suppose all inputs are ok!

        if isstruct(infostr)
                % --- PARSED INFO-STRING ---
                
                % recoursive section search:
                for s = 1:numel(scell)
                
                        % look for subsection:
                        sid = find(strcmp(infostr.sec_names,scell{s}),1);
                        if isempty(sid)
                                error(sprintf('%s: subsection ''%s'' not found',functionname,scell{s}));
                        endif
                        
                        % go deeper:
                        infostr = infostr.sections{sid};
                endfor
                
                % assing result
                section = infostr;
                
        else
                % --- RAW INFO-STRING ---                
                section = '';
                endposition = 0;
                if isempty(scell)
                        % scell is empty thus current infostr is required:
                        section = infostr;
                else
                        while (~isempty(infostr))
                                % search sections one by one from start of infostr to end
                                [S, E, TE, M, T, NM] = regexpi(infostr, ['#startsection\s*::\s*(.*)\s*\n(.*)\n\s*#endsection\s*::\s*\1'], 'once');
                                if isempty(T)
                                        % no section found
                                        section = '';
                                        break
                                else
                                        % some section found
                                        if strcmp(strtrim(T{1}), scell{1})
                                                % wanted section found
                                                section = strtrim(T{2});
                                                endposition = endposition + TE(end,end);
                                                break
                                        else
                                                % found section is not the one wanted
                                                if E < 2
                                                        % danger of infinite loop! this should never happen
                                                        error([functionname ': infinite loop happened!'])
                                                endif
                                                % remove previous parts of infostr to start looking for 
                                                % wanted section after the end of found section:
                                                infostr = infostr(E+1:end);
                                                % calculate correct position that will be returned to user:
                                                endposition = endposition + E;
                                        endif
                                endif
                        endwhile
                        % if nothing found:
                        if isempty(section)
                                error([functionname ': section `' scell{1} '` not found'])
                        endif
                        % some result was obtained. if subsections are required, do recursion:
                        if length(scell) > 1
                                % recursively call for subsections:
                                tmplength = length(section);
                                [section, tmppos] = get_section(functionname, section, scell(2:end));
                                endposition = endposition - (tmplength - tmppos);
                        endif
                endif
        endif        
endfunction

function [infostr] = rem_subsections(functionname, infostr) %<<<1
        % remove all other sections in infostr
        % used to prevent finding key or matrix inside of some section
        %
        % functionname - name of the main function for proper error generation after concatenating
        % infostr - info string with all data
        %
        % function suppose all inputs are ok!

        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        
        if ~isstruct(infostr)
                % --- only in raw text mode, ignore for parsed infostring ---
                NL = sprintf('\n');
        
                % remove unwanted sections:
                while (~isempty(infostr))
                        % search sections one by one from start of infostr to end
                        [S, E, TE, M, T, NM] = regexpi(infostr, ['#startsection\s*::\s*(.*)\s*\n(.*)\n\s*#endsection\s*::\s*\1'], 'once');
                        if isempty(T)
                                % no section found, quit:
                                break
                        else
                                % some section found, remove it from infostr:
                                infostr = [deblank(infostr(1:S-1)) NL fliplr(deblank(fliplr(infostr(E+1:end))))];
                                if S-1 >= E+1
                                        % danger of infinite loop! this should never happen
                                        error([functionname ': infinite loop happened!'])
                                endif
                        endif
                endwhile
        endif
endfunction

function [val] = get_matrix(functionname, infostr, key, scell) %<<<1
        % returns content of matrix as text from infostr in section/subsections according scell
        %
        % functionname - name of the main function for proper error generation after concatenating
        % infostr - info string with all data
        % key - name of matrix for which val is searched
        % scell - cell of strings with name of section and subsections
        %
        % function suppose all inputs are ok!

        val = '';
        % get section:
        [infostr] = get_section(functionname, infostr, scell);
        % remove unwanted subsections:
        [infostr] = rem_subsections(functionname, infostr);

        % get matrix:
        % prepare regexp:
        key = strtrim(key);
        
        if isstruct(infostr)
                % --- PARSED INFO-STRING ---
                
                % search the matrix in the parsed list:
                mid = find(strcmp(infostr.matrix_names,key),1);
                if isempty(mid)
                        error([functionname ': matrix named `' key '` not found'])
                endif
                % return its content:
                val = infostr.matrix{mid};                
        else
                % --- RAW INFO-STRING --- 
                % escape characters of regular expression special meaning:
                key = regexpescape(key);
                % find matrix:
                [S, E, TE, M, T, NM] = regexpi (infostr,['#startmatrix\s*::\s*' key '(.*)' '#endmatrix\s*::\s*' key], 'once');
                if isempty(T)
                        error([functionname ': matrix named `' key '` not found'])
                endif
                val=strtrim(T{1});
        endif
endfunction

function key = regexpescape(key) %<<<1
        % Translate all special characters (e.g., '$', '.', '?', '[') in
        % key so that they are treated as literal characters when used
        % in the regexp and regexprep functions. The translation inserts
        % an escape character ('\') before each special character.
        % additional characters are translated, this fixes error in octave
        % function regexptranslate.

        key = regexptranslate('escape', key);
        % test if octave error present:
        if strcmp(regexptranslate('escape','*(['), '*([')
                % fix octave error not replacing other special meaning characters:
                key = regexprep(key, '\*', '\*');
                key = regexprep(key, '\(', '\(');
                key = regexprep(key, '\)', '\)');
        endif
endfunction

function data = csv2cell(s) %<<<1
% Reads string with csv sheet according RFC4180 (with minor modifications, see last three
% properties) and returns cell of strings.
%
% Properties:
% - quoted fields are properly parsed,
% - escaped quotes in quoted fields are properly parsed,
% - newline characters are correctly understood in quoted fields,
% - spaces in quotes are preserved,
% - works for CR, LF, CRLF, LFCR newline markers,
% - if field is not quoted, leading and trailing spaces are intentionally removed,
% - sheet delimiter is ';',
% - if not same number of fields on every row, sheet is padded by empty strings as needed.

% Script first tries to find out if quotes are used. If not, fast method is used. If yes, slower
% method is used.

CELLSEP = ';';          % separator of fields
CELLSTR = '"';          % quoted fields character
LF = char(10);          % line feed
CR = char(13);          % carriage return

if isempty(strfind(s, CELLSTR)) %<<<2
% no quotes, simple method will be used

        % methods converts all end of lines to LF, split by LF,
        % and two methods to parse lines

        % replace all CRLF to LF:
        s = strrep(s, [CR LF], LF);
        % replace all LFCR to LF:
        s = strrep(s, [LF CR], LF);
        % replace all CR to LF:
        s = strrep(s, CR, LF);
        % split by LF:
        s = strsplit(s, LF);
        % remove trailing empty lines which can happen in the case of last LF
        % (this would prevent using fast cellfun method)
        if length(s) > 1 && isempty(strtrim(s{end}))
                s = s(1:end-1);
        endif
        % strsplit by separators on all lines:
        s = cellfun(@strsplit, s, repmat({CELLSEP}, size(s)), 'UniformOutput', false);
        try %<<<3
                % faster method - use vertcat, only possible if all lines have the same number of fields:
                data = vertcat(s{:});
        catch %<<<3
                % slower method - build sheet line by line.
                % if number of fields on some line is larger or smaller, padding by empty string
                % occur:
                data = {};
                for i = 1:length(s)
                        c = s{i};
                        if i > 1
                                if size(c,2) < size(data,2)
                                        % new line is too short, must be padded:
                                        c = [c repmat({''}, 1, size(data,2) - size(c,2))];
                                elseif size(c,2) > size(data,2)
                                        % new line is too long, whole matrix must be padded:
                                        data = [data, repmat({''}, size(c,2) - size(data,2), 1)];
                                endif
                        endif
                        % add new line of sheet:
                        data = [data; c];
                endfor
        end_try_catch
else %<<<2
        % quotes are inside of sheet, very slow method will be used
        % this method parse character by character

        Field = '';             % content of currently processed field
        FieldEnd = false;       % flag if field ended by ; or some newline
        LineEnd = false;        % flag if line ended
        inQuoteField = false;   % flag if now processing inside of quoted field
        wasQuotedField = false; % flag if current field is quoted
        curChar = '';           % currently processed character
        nextChar = '';          % character next after currently processed one
        curCol = 1;             % current collumn
        curRow = 1;             % current row
        i = 0;                  % loop index
        while i < length(s)
                i = i + 1;
                % get current character:
                curChar = s(i);
                % get next character
                if i < length(s)
                        nextChar = s(i+1);
                else
                        % if at end of string, just add line feed, no harm to do this:
                        nextChar = LF;
                        % and mark all ends:
                        FieldEnd = true;
                        LineEnd = true;
                endif
                if inQuoteField %<<<3
                        % we are inside quotes of field
                        if curChar == CELLSTR
                                if nextChar == CELLSTR
                                        % found escaped quotes ("")
                                        i = i + 1;      % increment counter to skip next character, which is already part of escaped "
                                        Field = [Field CELLSTR];
                                else
                                        % going out of quotes
                                        inQuoteField = false;
                                        Field = [Field curChar];
                                endif
                        else
                                Field = [Field curChar];
                        endif
                else %<<<3
                        % we are not inside quotes of field
                        if curChar == CELLSTR
                                inQuoteField = true;
                                wasQuotedField = true;
                                Field = [Field curChar];
                                % endif
                        elseif curChar == CELLSEP
                                % found end of field
                                FieldEnd = true;
                        elseif curChar == CR
                                % found end of line (this also ends field)
                                FieldEnd = true;
                                LineEnd = true;
                                if nextChar == LF
                                        i = i + 1;      % increment counter to skip next character, which is already part of CRLF newline
                                endif
                        elseif curChar == LF
                                % found end of line (this also ends field)
                                FieldEnd = true;
                                LineEnd = true;
                                if nextChar == CR
                                        i = i + 1;      % increment counter to skip next character, which is already part of LFCR newline
                                endif
                        else
                                Field = [Field curChar];
                        endif
                endif
                if FieldEnd == true %<<<3
                        % add field to sheet:
                        Field = strtrim(Field);
                        if wasQuotedField
                                wasQuotedField = false;
                                % remove quotes if it is first and last character (spaces are already removed)
                                % if it is not so, the field is bad (not according RFC), something like:
                                % aaa; bb"bbb"bb; ccc
                                % and whole non modified field will be returned
                                if (strcmp(Field(1), '"') && strcmp(Field(end), '"'))
                                        Field = Field(2:end-1);
                                endif
                        endif
                        data(curCol, curRow) = {Field};
                        Field = '';
                        FieldEnd = false;
                        if LineEnd == true;
                                curRow = curRow + 1;
                                curCol = 1;
                                LineEnd = false;
                        else
                                curCol = curCol + 1;
                        endif
                endif
        endwhile
        data = data';
endif

endfunction

function posixnumber = iso2posix_time(isostring)
        % converts ISO8601 time to posix time both for GNU Octave and Matlab
        % posix time is number of seconds since the epoch, the epoch is referenced to 00:00:00 CUT
        % (Coordinated Universal Time) 1 Jan 1970, for example, on Monday February 17, 1997 at 07:15:06 CUT,
        % the value returned by 'time' was 856163706.)
        % ISO 8601
        % %Y-%m-%dT%H:%M:%S%20u
        % 2013-12-11T22:59:30.15648946

        isostring = strtrim(isostring);
        if isOctave
                % Octave version:
                % parse of time data:
                posixnumber = mktime(strptime(isostring, '%Y-%m-%dT%H:%M:%S'));
                if ~isempty(posixnumber)
                        % I do not know how to read fractions of second by strptime, so this line fix it:
                        posixnumber = posixnumber + str2num(isostring(20:end));
                endif
        else
                % Matlab version:
                posixnumber = posixtime(datetime(isostring(1:19), 'TimeZone', 'local', 'Format', 'yyyy-MM-dd''T''HH:mm:ss'));
                % I do not know how to read fractions of second by datetime, so this line fix it:
                posixnumber = posixnumber + str2num(isostring(20:end));
        endif
endfunction

function isostring = posix2iso_time(posixnumber)
        % posix time to ISO8601 time both for GNU Octave and Matlab
        % posix time is number of seconds since the epoch, the epoch is referenced to 00:00:00 CUT
        % (Coordinated Universal Time) 1 Jan 1970, for example, on Monday February 17, 1997 at 07:15:06 CUT,
        % the value returned by 'time' was 856163706.)
        % ISO 8601
        % %Y-%m-%dT%H:%M:%S%20u
        % 2013-12-11T22:59:30.15648946

        if isOctave
                % Octave version:
                isostring = strftime('%Y-%m-%dT%H:%M:%S', localtime(posixnumber));
                % add decimal dot and microseconds:
                isostring = [isostring '.' num2str(localtime(posixnumber).usec, '%0.6d')];
        else
                % Matlab version:
                isostring = datestr(datetime(posixnumber, 'TimeZone', 'local', 'ConvertFrom', 'posixtime'), 'yyyy-mm-ddTHH:MM:SS');
                % add decimal dot and microseconds:
                isostring = [isostring '.' num2str(mod(posixnumber, 1), '%0.6d')];
        endif
endfunction

function retval = isOctave
% checks if GNU Octave or Matlab
% according https://www.gnu.org/software/octave/doc/v4.0.1/How-to-distinguish-between-Octave-and-Matlab_003f.html

  persistent cacheval;  % speeds up repeated calls

  if isempty (cacheval)
    cacheval = (exist ("OCTAVE_VERSION", "builtin") > 0);
  end

  retval = cacheval;
end

% --------------------------- tests: %<<<1
%!shared infostr
%! infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n"a";  "b"; "c" \n"d";"e";         "f"  \n#endmatrix:: simple matrix \n#startmatrix:: time matrix\n  2013-12-11T22:59:30.123456\n  2013-12-11T22:59:35.123456\n#endmatrix:: time matrix\nC:: c without section\n#startsection:: section 1 \n  C:: c in section 1 \n  #startsection:: subsection\n    C:: c in subsection\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: c in section 2\n#endsection:: section 2\n');
%!assert(all(all( abs(infogettimematrix(infostr,'time matrix') - [1386799170.12346; 1386799175.12346]) < 6e-6 )))
%!error(infogettimematrix('', ''));
%!error(infogettimematrix('', infostr));
%!error(infogettimematrix(infostr, ''));
%!error(infogettimematrix(infostr, 'A', {'section 1'}));
