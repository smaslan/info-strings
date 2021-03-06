function matrix = infogettextmatrix(varargin) %<<<1
        
        if nargin == 3
            % fake sections cells because otherwise the parameter checker won't parse them correctly
            % for the val being a cell array!
            varargin{end+1} = {};
        endif
        
        % identify and check inputs %<<<2
        [printusage, infostr, key, scell] = get_id_check_inputs('infogettextmatrix', varargin{:});
        if printusage
                print_usage()
        endif

        % get matrix %<<<2
        infostr = get_matrix('infogettextmatrix', infostr, key, scell);
        % parse csv:
        matrix = csv2cell(infostr);
endfunction

