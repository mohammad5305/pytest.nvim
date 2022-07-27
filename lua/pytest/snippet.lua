require "pytest.helper"

local treesitter = vim.treesitter

local function getQuery(pattern, bufnum, parser)
    if parser == nil then
        parser = treesitter.get_parser(bufnum)
    end

    local matches = {}
    local syntax_tree = parser:parse()
    local root = syntax_tree[1]:root()

    local query = treesitter.parse_query('python', pattern)
    
    for id, match, metadata in query:iter_matches(root, bufnum, root:start(), root:end_()) do
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

    ]], functionName, docstring)
end

local function insertSnippet(bufnum, mode)
    local functionNames =  getQuery('(function_definition name: (identifier)@capture)', bufnum)
    local docstrings = getQuery('(function_definition body: (block (expression_statement (string)@capture)))', bufnum)

    for i=1,#functionNames do
        local functionName = functionNames[i]
        local docstring = docstrings[i]

        -- TODO: weird but working :)
        if tonumber(tostring(functionName:start()))+1 == tonumber(tostring(docstring:start())) then
            snippet = M.split(makeSnippet(
                treesitter.get_node_text(functionName, bufnum),
                treesitter.get_node_text(docstring, bufnum)
            ), "\n")
        else
            repeat 
                k = i + 1
                docstring = docstrings[k]
            until rowFuncName+1 >= tonumber(tostring(docstring:start()))

            snippet = split(makeSnippet(
                treesitter.get_node_text(functionName, bufnum),
                treesitter.get_node_text(docstring, bufnum)
            ), "\n")
        end

        vim.api.nvim_buf_set_lines(bufnum, -1, -1, false, snippet)
    end

end

