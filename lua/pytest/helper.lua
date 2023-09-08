local helper = {}

function helper.getQuery(bufnr, pattern, exclude, startln, endln)
  local parser = vim.treesitter.get_parser(bufnr)

  if not exclude then
    exclude = {}
  end

  local matches = {}
  local root = parser:parse()[1]:root()

  if not startln and not endln then
    startln = root:start()
    endln = root:end_()
  end

  local query = vim.treesitter.query.parse("python", pattern)

  for _, match, _ in query:iter_matches(root, bufnr, startln, endln) do
    local tmp_table = {}

    for id, node in pairs(match) do
      local cap_name = query.captures[id]
      if not vim.tbl_contains(exclude, cap_name) then
        table.insert(tmp_table, node)
      end
    end
    table.insert(matches, tmp_table)
  end

  return matches
end

function helper.createDir(dirName, prompt)
  if prompt then
    helper.notify(string.format('echo "%s: No such directory"', dirName), "ERROR")

    vim.ui.select(
      { string.format("Create %s", dirName), "Custom dir name" },
      {},
      function(_, number)
        vim.cmd("redraw")

        if number == 1 then
          vim.fn.mkdir(dirName)
        elseif number == 2 then
          vim.ui.input({ prompt = "directory name: " }, function(alterDir)
            vim.fn.mkdir(alterDir, "p")
            dirName = string.find(alterDir, "/") and alterDir or alterDir .. "/"
          end)
        else
          vim.cmd('echoerr "Invalid choice"')
        end
      end
    )

    return dirName
  else
    vim.fn.mkdir(dirName, "p")
    return dirName
  end
end

function helper.merge_tbl(...)
  local tables_to_merge = { ... }
  assert(#tables_to_merge > 1, "There should be at least two tables to merge them")

  for k, t in ipairs(tables_to_merge) do
    assert(
      type(t) == "table",
      string.format("Expected a table as function parameter %d", k)
    )
  end

  local result = tables_to_merge[1]

  for i = 2, #tables_to_merge do
    local from = tables_to_merge[i]
    for k, v in pairs(from) do
      if type(k) == "number" then
        table.insert(result, v)
      elseif type(k) == "string" then
        result[k] = v
      end
    end
  end

  return result
end
function helper.notify(msg, lvl)
  local level = vim.log.levels[lvl]
  if not level then
    error("Invalid error level", 2)
  end
  vim.notify("[Pytest.nvim]: " .. msg, level)
end

return helper
