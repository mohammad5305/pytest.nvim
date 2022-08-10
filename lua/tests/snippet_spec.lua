describe("snippet", function()
    local snippet = require("pytest.snippet")
    local helper = require("pytest.helper")

    describe("makeSnippet", function ()
        it("should return a function with docstring", function()
            assert.equals(snippet.makeSnippet("hello_world", 'hello world'), [[def test_hello_world():
    """ test hello world """
    pass

]])
        end)
        it("should return string", function ()
            assert.equals(type(snippet.makeSnippet('hello_world', "test")), 'string')
        end)

    end)

    describe("getQuery", function()
        it("checking function name and docstring query", function()
            vim.cmd('e test.py')
            local bufnr = vim.api.nvim_get_current_buf()
            vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, {"def testFunc():",'\t""" hello world"""',"\tpass" })
            local functioNameQuery = helper.getQuery('(function_definition name: (identifier)@capture)', bufnr)[1]
            local docstringQuery = helper.getQuery('(function_definition body: (block (expression_statement (string)@capture)))', bufnr)[1]
            assert.equals(vim.treesitter.get_node_text(functioNameQuery, bufnr), "testFunc")
            assert.equals(vim.treesitter.get_node_text(docstringQuery, bufnr), '""" hello world"""')
            vim.cmd("bd!")
        end)

        it("should get all function and docstring in file", function()
            vim.cmd('e test.py')
            local bufnr = vim.api.nvim_get_current_buf()
            local functionName = {"testFunc", "hello_world", }
            local docstring = {'""" testFunc docstring """', '""" hello world """'}

            for i=1,#functionName do
                vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, {string.format("def %s():", functionName[i]), "\t"..docstring[i], "\tpass"})
            end

            local functioNameQuery = helper.getQuery('(function_definition name: (identifier)@capture)', bufnr)
            local docstringQuery = helper.getQuery('(function_definition body: (block (expression_statement (string)@capture)))', bufnr)
            for i=1,#functioNameQuery do
                assert.equals(vim.treesitter.get_node_text(functioNameQuery[i], bufnr), functionName[i])
                assert.equals(vim.treesitter.get_node_text(docstringQuery[i], bufnr), docstring[i])
            end
            vim.cmd("bd!")
        end)

    end)

end)
