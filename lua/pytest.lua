-- just for readablity I use this var
local snippet = require("pytest.snippet")
local pytest = {}
local defualtOpts = {
    testDir="tests/"
}

function is_dir(path)
  return os.execute(('[ -d "%s" ]'):format(path))
end

function pytest.setup(opts)
    if opts == nil then
        opts = defualtOpts
    end

        vim.api.nvim_create_user_command("PytestMkSnip", function ()
            if is_dir(vim.loop.cwd()..'/'..opts['testDir']) == 0 then
                local bufnr = vim.api.nvim_buf_get_number(0)
                snippet.insertSnippet(bufnr, "n", opts['testDir'], string.gsub(vim.api.nvim_buf_get_name(0), vim.loop.cwd()..'/', ''))
            else
                -- TODO: getting answar from user
                print(string.format("%s direcotry not exists in current path should I make?", opts['testDir']))
            end

        end, {})

        vim.api.nvim_create_user_command("PytestMkSnipV", function ()
            if is_dir(vim.loop.cwd()..'/'..opts['testDir']) == 1 then
                local bufnr = vim.api.nvim_buf_get_number(0)
                snippet.insertSnippet(bufnr, "v", opts['testDir'], string.gsub(vim.api.nvim_buf_get_name(0), vim.loop.cwd()..'/', ''))
            else
                -- TODO: getting answar from user
                print(string.format("%s direcotry not exists in current path should I make?", opts['testDir']))
            end
        end, { range=true })


    end

    return pytest
