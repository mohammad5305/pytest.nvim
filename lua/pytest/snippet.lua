local helper = require("pytest.helper")
local snippet = {}

local treesitter = vim.treesitter

function snippet.makeTemplate(functionName, docstring, insertClass, className)
  if docstring and #docstring ~= 0 then
    docstring = string.gsub(docstring, '[\n|\t|"""]', "")
    -- TODO: combin these regex
    docstring = string.gsub(docstring, "(%s+)(%s*)(%s+)", "")
    docstring = '\n\t""" test ' .. docstring .. '"""'
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

local function findSnippetData(
  bufnr,
  with_docs_pattern,
  without_docs_pattern,
  visual
)
  local start, end_ = nil, nil

  if visual then
    start, end_ = unpack(visual)
  end

  local with_docstring = helper.getQuery(bufnr, with_docs_pattern, {}, start, end_)
  local without_docstring =
    helper.getQuery(bufnr, without_docs_pattern, { "body" }, start, end_)

  local snippetTables = {}
  local matches = helper.merge_tbl(with_docstring, without_docstring)

  for _, match in ipairs(matches) do
    if #match == 2 then
      table.insert(
        snippetTables,
        vim.split(
          snippet.makeTemplate(
            treesitter.get_node_text(match[1], bufnr),
            treesitter.get_node_text(match[2], bufnr)
          ),
          "\n"
        )
      )
    else
      table.insert(
        snippetTables,
        vim.split(
          snippet.makeTemplate(treesitter.get_node_text(match[1], bufnr)),
          "\n"
        )
      )
    end
  end

  return snippetTables
end

function snippet.makeSnippet(bufnr, args)
  local with_docstring =
    "(function_definition name: (identifier) @funcname body: (block (expression_statement (string)@doc)))"
  local without_docstring =
    '(function_definition name: (identifier) @funcname body: (block)@body (#not-lua-match? @body "\\"\\"\\"%s+.+%s+\\"\\"\\""))'

  local visual = args.range ~= 0 and { args.line1, args.line2 } or false

  -- TODO: inserting class keyword when its class and not simple function
  if vim.tbl_contains(args.fargs, "class") then
    -- local classPart = '(class_definition name: (identifier) @class (#eq? @class "%s") body: (block'

    -- local result = {}
    -- for _, className in ipairs(classNames) do
    --   className = vim.treesitter.get_node_text(className, bufnr)
    --   table.insert(
    --     result,
    --     unpack(
    --       findSnippetData(
    --         bufnr,
    --         string.format(queryFunction, className),
    --         string.format(queryDocstring, className)
    --       )
    --     )
    --   )
  end

  -- return result
  -- end

  return findSnippetData(bufnr, with_docstring, without_docstring, visual)
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
