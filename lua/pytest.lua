-- just for readablity I use this vars
local snippet = require("pytest.snippet")
local helper = require("pytest.helper")
local execute = require("pytest.execute")
local pytest = {}
local defualtOpts = {
  snippet = {
    doc_string = true,
    directory = "tests/",
    dir_not_exists_prompt = false,
  },
}

function pytest.setup(opts)
  if opts == nil then
    opts = defualtOpts
  end

  vim.api.nvim_create_user_command("PytestMkSnip", function(args)
    local bufnr = vim.api.nvim_get_current_buf()
    local tests_directory = opts["snippet"]["directory"]

    if vim.treesitter.language.get_lang("python") ~= "python" then
      helper.notify("python parser not found.\n :TSInstall python", "ERROR")
      return 0
    end

    if
      vim.tbl_isempty(
        vim.fs.find(
          tests_directory,
          { path = vim.loop.cwd(), type = "directory", stop = "yes" }
        )
      ) ~= true
    then
      snippet.insertSnippet(
        bufnr,
        tests_directory,
        "test_" .. vim.fn.expand("%"),
        args
      )
    else
      local createdDir =
        helper.createDir(tests_directory, opts["snippet"]["dir_not_exists_prompt"])
      snippet.insertSnippet(bufnr, createdDir, "test_" .. vim.fn.expand("%"), args)
    end
  end, { range = true, nargs = "*" })

  vim.api.nvim_create_user_command("PytestRun", function()
    local bufnr = vim.api.nvim_get_current_buf()
    if opts.execute and opts.execute.text and opts.execute.highlight then
      local text = vim.split(opts.execute.text, "/")
      local highlight = vim.split(opts.execute.highlight, "/")
      vim.cmd(
        string.format(
          "sign define PytestSucces text=%s texthl=%s",
          text[1],
          highlight[1]
        )
      )
      vim.cmd(
        string.format(
          "sign define PytestFailed text=%s texthl=%s",
          text[2],
          highlight[2]
        )
      )
    else
      vim.cmd("sign define PytestSucces text=S texthl=SignifySignAdd")
      vim.cmd("sign define PytestFailed text=F texthl=SignifySignDelete")
    end
    execute.executePytest(
      bufnr,
      string.format(
        "pytest -v --capture=no --no-summary --no-header --color=no  --disable-warnings %s| tr -d '='",
        vim.fn.expand("%p")
      ),
      vim.loop.cwd()
    )
  end, {})
end

return pytest
