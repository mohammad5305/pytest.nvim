local helper = require("pytest.helper")
local snippet = {}

local treesitter = vim.treesitter

function snippet.makeTemplate(functionName, docstring, insertClass, className)
  if docstring then
    docstring = string.gsub(docstring, '[\n|\t|"""]', "")
    -- TODO: combin these regex
    docstring = string.gsub(docstring, "(%s+)(%s*)(%s+)", "")
    docstring = '\n""" test ' .. docstring .. '"""'
  end
  if insertClass then
    return string.format(
      [[class %s:
          def test_%s():
      """ test %s """
      pass

]],
      className,
      functionName,
      docstring
    )
  end

  return string.format(
    [[def test_%s():%s
    pass

]],
    functionName,
    docstring and docstring or ""
  )
end

function snippet.makeSnippet(bufnr, args)
  local queryFunction = "(function_definition name: (identifier)@capture)"
  local queryDocstring =
    "(function_definition body: (block (expression_statement (string)@capture)))"

  if vim.tbl_contains(args.fargs, "class") then
    local classPart = "(class_definition body: (block"
    queryFunction = classPart .. queryFunction .. "))"
    queryDocstring = classPart .. queryDocstring .. "))"
  end

  local functionNames = helper.getQuery(queryFunction, bufnr)
  local docstrings = helper.getQuery(queryDocstring, bufnr)
  local snippetTables = {}

  for i = 1, #functionNames do
    local functionName = functionNames[i]
    local docstring = docstrings[i]

    -- TODO: weird but working :)
    if docstring then
      if
        tonumber(tostring(functionName:start())) + 1
        == tonumber(tostring(docstring:start()))
      then
        table.insert(
          snippetTables,
          vim.split(
            snippet.makeTemplate(
              treesitter.get_node_text(functionName, bufnr),
              treesitter.get_node_text(docstring, bufnr)
            ),
            "\n"
          )
        )
      else
        repeat
          k = i + 1
          docstring = docstrings[k]
        -- TODO: solve mystery of rowFuncName how does this works even man :)
        until rowFuncName + 1 >= tonumber(tostring(docstring:start()))

        table.insert(
          snippetTables,
          vim.split(
            snippet.makeTemplate(
              treesitter.get_node_text(functionName, bufnr),
              treesitter.get_node_text(docstring, bufnr)
            ),
            "\n"
          )
        )
      end
    else
      table.insert(
        snippetTables,
        vim.split(
          snippet.makeTemplate(treesitter.get_node_text(functionName, bufnr)),
          "\n"
        )
      )
    end
  end
  return snippetTables
end

function snippet.insertSnippet(bufnr, testDir, filename, args)
  vim.cmd("e " .. testDir .. filename)
  local snippetTables = snippet.makeSnippet(bufnr, args)
  local testFile = table.concat(
    vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), 0, -1, false),
    "\n"
  )

  for _, snippet in ipairs(snippetTables) do
    local functionPattern = "def %w+_(.+):"
    local _, _, snippetMatch =
      string.find(table.concat(snippet, "\n"), functionPattern)

    if string.match(testFile, snippetMatch) == nil then
      vim.api.nvim_buf_set_lines(
        vim.api.nvim_get_current_buf(),
        -1,
        -1,
        false,
        snippet
      )
    end
  end
end

return snippet
