-- just for readablity I use this vars
local snippet = require("pytest.snippet")
local helper = require("pytest.helper")
local execute = require("pytest.execute")
local pytest = {}
local defualtOpts = {
  testDir="tests/",
  dirExistancePrmopt=nil,
}


function pytest.setup(opts)
  if opts == nil then
    opts = defualtOpts
  end

  vim.api.nvim_create_user_command("PytestMkSnip", function ()
    local bufnr = vim.api.nvim_get_current_buf()
    if next(vim.fs.find(opts['testDir'], {path=vim.loop.cwd(), type="direcotry", stop='yes'})) then
      snippet.insertSnippet(bufnr, "n", opts['testDir'], 'test_'..vim.fn.expand('%'))
    else
      local createdDir = helper.createDir(opts['testDir'], opts['dirExistancePrmopt'])
      snippet.insertSnippet(bufnr, "n", createdDir, 'test_'..vim.fn.expand('%'))
    end

  end, {})

  vim.api.nvim_create_user_command("PytestRun", function ()
    local bufnr = vim.api.nvim_get_current_buf()
    execute.executePytest(bufnr,
      string.format("pytest -v --capture=no --no-summary --no-header --color=no  --disable-warnings %s| tr -d '='", vim.fn.expand('%p')),
      vim.loop.cwd(), true)
  end, {})

  -- vim.api.nvim_create_user_command("PytestMkSnipV", function ()
  -- end, { range=true })


end

return pytest
