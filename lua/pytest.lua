-- just for readablity I use this var
local snippet = require("pytest.snippet")
local pytest = {}
local defualtOpts = {}

function pytest.setup(opts)
    if opts ~= nil then
        opts = defualtOpts
    end

    vim.api.nvim_create_user_command("PytestMkSnip", function ()
        local bufnr = vim.api.nvim_buf_get_number(0)
        snippet.insertSnippet(bufnr, "n")
    end,{})

    vim.api.nvim_create_user_command("PytestMkSnipV", function ()
        local bufnr = vim.api.nvim_buf_get_number(0)
        snippet.insertSnippet(bufnr, "v")
    end, { range=true })
end

return pytest
