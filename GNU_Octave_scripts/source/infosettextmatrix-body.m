function infostr = infosettextmatrix(varargin) %<<<1
        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

        if nargin == 3
            % fake sections cells because otherwise the parameter checker won't parse them correctly
            % for the val being a cell array!
            varargin{end+1} = {};
        endif

        % identify and check inputs %<<<2
        [printusage, infostr, key, val, scell] = set_id_check_inputs('infosettextmatrix', varargin{:});
        if printusage
                print_usage()
        endif
        % check content of val:
        if (~iscell(val))
                error('infosettextmatrix: val must be a cell of strings')
        endif
        if (~all(cellfun(@ischar, val)))
                error('infosettextmatrix: val must be a cell of strings')
        endif

        % make infostr %<<<2
        % convert matrix into text:
        % merge cells:
        str = [val{:}];
        
        % contains linebreaks:
        has_nlns = any(find(str == char(10) | str == char(13)));
        
        % contains semicolons:
        has_semicol = any(find(str == ';'));
        
        
        if has_semicol || has_nlns        
                % go line per line (thus semicolons and end of lines can be managed):
                matastext = '';                
                for i = 1:size(val,1)
                        % for every row make a line:
                        line = sprintf('"%s"; ', val{i,:});
                        % indentation inserts spaces into cells with newline characters!
                        % join with previous lines, add indentation, add line without last semicolon and space, add end of line:
                        matastext = [matastext line(1:end-2) NL];
                endfor
                
                % remove last end of line:
                matastext = matastext(1:end-length(NL));

        else
                % no protected symbols, don't use "":
                
                % input data size
                [R,C] = size(val);  
                                
                rowss = {};
                for r = 1:R
                        % cat columns    
                        row = cat(1,val(r,:),repmat({'; '},[1 C]));
                        row = [row{:}];
                        rowss{r,1} = row(1:end-2);
                endfor
                
                % cat rows
                if R
                        matastext = cat(2,rowss,repmat({NL},[R 1]))';
                        matastext = [matastext{:}];
                        matastext = matastext(1:end-length(NL));
                else
                        matastext = '';
                end
                
        endif      
        % add matrix to infostr:
        infostr = set_matrix('infosettextmatrix', infostr, key, matastext, scell, ~has_nlns);
endfunction

