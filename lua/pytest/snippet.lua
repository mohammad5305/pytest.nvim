require "helper"

local function getQuery(pattern, bufnum, parser)
    if parser == nil then
        parser = vim.treesitter.get_parser(bufnum)
    end

    local matches = {}
    local syntax_tree = parser:parse()
    local root = syntax_tree[1]:root()

    local query = vim.treesitter.parse_query('python', pattern)
    
    for id, match, metadata in query:iter_matches(root, bufnum, root:start(), root:end_()) do
        table.insert(matches, vim.treesitter.query.get_node_text(match[1], bufnum))
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

    ]], functionName, docstring)
end

snippet = M.split(makeSnippet(
    getQuery('(function_definition name: (identifier)@capture)', 4)[1],
    getQuery('(function_definition body: (block (expression_statement (string)@capture)))', 4)[1]
), "\n")


vim.api.nvim_buf_set_lines(0, -1, -1, false, snippet)
