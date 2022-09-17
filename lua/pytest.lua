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

    if vim.tbl_isempty(vim.fs.find(opts['testDir'], {path=vim.loop.cwd(), type="direcotry", stop='yes'})) ~= true then
      snippet.insertSnippet(bufnr, "n", opts['testDir'], 'test_'..vim.fn.expand('%'))
    else
      local createdDir = helper.createDir(opts['testDir'], opts['dirExistancePrmopt'])
      snippet.insertSnippet(bufnr, "n", createdDir, 'test_'..vim.fn.expand('%'))
    end

  end, {})

  vim.api.nvim_create_user_command("PytestRun", function ()
    local bufnr = vim.api.nvim_get_current_buf()
    if opts.execute and opts.execute.text and opts.execute.highlight then
      local text = vim.split(opts.execute.text, "/")
      local highlight = vim.split(opts.execute.highlight, "/")
      vim.cmd(string.format('sign define PytestSucces text=%s texthl=%s', text[1], highlight[1]))
      vim.cmd(string.format('sign define PytestFailed text=%s texthl=%s', text[2], highlight[2]))
    else
      vim.cmd('sign define PytestSucces text=S texthl=SignifySignAdd')
      vim.cmd('sign define PytestFailed text=F texthl=SignifySignDelete')
    end
    execute.executePytest(bufnr,
      string.format("pytest -v --capture=no --no-summary --no-header --color=no  --disable-warnings %s| tr -d '='", vim.fn.expand('%p')),
      vim.loop.cwd(), true)
  end, {})

  -- vim.api.nvim_create_user_command("PytestMkSnipV", function ()
  -- end, { range=true })


end

return pytest
