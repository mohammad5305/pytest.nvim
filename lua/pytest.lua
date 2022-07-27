-- just for readablity I use this var
local snippet = require("pytest.snippet")

vim.api.nvim_create_user_command("PytestMkSnip", function ()
    local bufnum = vim.api.nvim_buf_get_number(0)
    snippet.insertSnippet(bufnum, "n")
end,{})

vim.api.nvim_create_user_command("PytestMkSnip", function ()
    local bufnum = vim.api.nvim_buf_get_number(0)
    snippet.insertSnippet(bufnum, "v")
end, { range=true })
