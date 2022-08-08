local helper = {}

function helper.is_dir(path)
    return os.execute(('[ -d "%s" ]'):format(path))
end

function helper.getQuery(pattern, bufnr, parser)
    if parser == nil then
        parser = vim.treesitter.get_parser(bufnr)
    end

    local matches = {}
    local syntax_tree = parser:parse()
    local root = syntax_tree[1]:root()

    local query = vim.treesitter.parse_query('python', pattern)
    
    for id, match, metadata in query:iter_matches(root, bufnr, root:start(), root:end_()) do
        table.insert(matches, match[1])
    end

    return matches

end



return helper
