local snippet = {}

local treesitter = vim.treesitter

local function getQuery(pattern, bufnr, parser)
    if parser == nil then
        parser = treesitter.get_parser(bufnr)
    end

    local matches = {}
    local syntax_tree = parser:parse()
    local root = syntax_tree[1]:root()

    local query = treesitter.parse_query('python', pattern)
    
    for id, match, metadata in query:iter_matches(root, bufnr, root:start(), root:end_()) do
        table.insert(matches, match[1])
    end

    return matches

end

local function makeSnippet(functionName, docstring)
    docstring = string.gsub(docstring, '[\n|\t|"""]', "")
    -- TODO: combin these regex
    docstring = string.gsub(docstring, '(%s+)(%s*)(%s+)', "")
    return string.format([[ 
    def test_%s():
        """ test %s """
        pass

    ]], functionName, docstring)
end

function snippet.insertSnippet(bufnr, mode, testDir, filename)
    local functionNames =  getQuery('(function_definition name: (identifier)@capture)', bufnr)
    local docstrings = getQuery('(function_definition body: (block (expression_statement (string)@capture)))', bufnr)

    for i=1,#functionNames do
        local functionName = functionNames[i]
        local docstring = docstrings[i]

        -- TODO: weird but working :)
        if tonumber(tostring(functionName:start()))+1 == tonumber(tostring(docstring:start())) then
            snippetStringTable = vim.split(makeSnippet(
                treesitter.get_node_text(functionName, bufnr),
                treesitter.get_node_text(docstring, bufnr)
            ), "\n")
        else
            repeat 
                k = i + 1
                docstring = docstrings[k]
            until rowFuncName+1 >= tonumber(tostring(docstring:start()))

            snippetStringTable = vim.split(makeSnippet(
                treesitter.get_node_text(functionName, bufnr),
                treesitter.get_node_text(docstring, bufnr)
            ), "\n")
        end
        vim.cmd('e '..testDir..filename)
        vim.api.nvim_buf_set_lines(vim.api.nvim_buf_get_number(0), -1, -1, false, snippetStringTable)
    end
end

return snippet
