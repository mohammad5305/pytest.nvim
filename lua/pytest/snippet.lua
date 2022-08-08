local helper = require("pytest.helper")
local snippet = {}

local treesitter = vim.treesitter

function snippet.makeSnippet(functionName, docstring)
    docstring = string.gsub(docstring, '[\n|\t|"""]', "")
    -- TODO: combin these regex
    docstring = string.gsub(docstring, '(%s+)(%s*)(%s+)', "")
    return string.format([[def test_%s():
    """ test %s """
    pass

]], functionName, docstring)
end

function snippet.insertSnippet(bufnr, mode, testDir, filename)
    local functionNames =  helper.getQuery('(function_definition name: (identifier)@capture)', bufnr)
    local docstrings = helper.getQuery('(function_definition body: (block (expression_statement (string)@capture)))', bufnr)
    local snippetTables = {}

    for i=1,#functionNames do
        local functionName = functionNames[i]
        local docstring = docstrings[i]

        -- TODO: weird but working :)
        if tonumber(tostring(functionName:start()))+1 == tonumber(tostring(docstring:start())) then
            table.insert(snippetTables, vim.split(snippet.makeSnippet(
                treesitter.get_node_text(functionName, bufnr),
                treesitter.get_node_text(docstring, bufnr)
            ), "\n"))
        else
            repeat 
                k = i + 1
                docstring = docstrings[k]
            until rowFuncName+1 >= tonumber(tostring(docstring:start()))

            table.insert(snippetTables, vim.split(snippet.makeSnippet(
                treesitter.get_node_text(functionName, bufnr),
                treesitter.get_node_text(docstring, bufnr)
            ), "\n"))
        end
    end
    vim.cmd('e '..testDir..filename)
    local testFile = table.concat(vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), 0, -1, false), "\n")

    for index, snippet in ipairs(snippetTables) do
        local functionPattern = "def %w+_(.+):"
        local _, _, snippetMatch = string.find(table.concat(snippet, "\n"), functionPattern)

        if string.match(testFile, snippetMatch) == nil then
            vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), -1, -1, false, snippet)
        end
    end

end

return snippet
