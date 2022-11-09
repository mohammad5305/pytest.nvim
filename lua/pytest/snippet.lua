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

local function checkLn(functionln, linenumbers)
  return vim.tbl_isempty(linenumbers) ~= true
    and functionln:start() + 1 >= visual["start"]
    and functionln:start() + 1 <= visual["end"]
end

local function findSnippetData(bufnr, functionPattern, docstringPattern, visual)
  local functionNames = helper.getQuery(functionPattern, bufnr)
  local docstrings = helper.getQuery(docstringPattern, bufnr)
  local snippetTables = {}

  for i = 1, #functionNames do
    local functionName = functionNames[i]
    local docstring = docstrings[i]

    -- TODO: weird but working :)
    if docstring then
      if
        checkLn(functionName, visual)
        or tonumber(tostring(functionName:start())) + 1
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
        -- local docstring = pairFuncs(functionName, functionNames) or pairFuncs(docstring, docstrings)
        -- print(treesitter.get_node_text(docstring, bufnr))
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
      if checkLn(functionName, visual) then
        table.insert(
          snippetTables,
          vim.split(
            snippet.makeTemplate(treesitter.get_node_text(functionName, bufnr)),
            "\n"
          )
        )
      end
    end
  end

  return snippetTables
end

function snippet.makeSnippet(bufnr, args)
  local queryFunction = "(function_definition name: (identifier)@capture)"
  local queryDocstring =
    "(function_definition body: (block (expression_statement (string)@capture)))"

  -- TODO: inserting class keyword when its class and not simple function
  if args.range ~= 0 then
    visual = { ["start"] = args.line1, ["end"] = args.line2 }
  end
  if vim.tbl_contains(args.fargs, "class") then
    local classPart =
      '(class_definition name: (identifier) @class (#eq? @class "%s") body: (block'
    local classNames =
      helper.getQuery("(class_definition name: (identifier)@capture)", bufnr)
    queryFunction = classPart .. queryFunction .. "))"
    queryDocstring = classPart .. queryDocstring .. "))"

    local result = {}
    for _, className in ipairs(classNames) do
      className = vim.treesitter.get_node_text(className, bufnr)
      table.insert(
        result,
        unpack(
          findSnippetData(
            bufnr,
            string.format(queryFunction, className),
            string.format(queryDocstring, className)
          )
        )
      )
    end

    return result
  end

  return findSnippetData(bufnr, queryFunction, queryDocstring, visual)
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
