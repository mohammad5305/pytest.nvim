local helper = {}

function helper.getQuery(pattern, bufnr, parser)
  if parser == nil then
    parser = vim.treesitter.get_parser(bufnr)
  end

  local matches = {}
  local syntax_tree = parser:parse()
  local root = syntax_tree[1]:root()

  local query = vim.treesitter.parse_query('python', pattern)

  for id, match, metadata in query:iter_matches(root, bufnr, root:start(), root:end_()) do
    table.insert(matches, match[1])
  end

  return matches

end

function helper.createDir(dirName, prompt)
  if prompt then
    vim.ui.select({string.format('Create %s', dirName), 'Custom dir name'},
      {
        prompt = string.format("%s: No such directory", dirName)
      }, function(choice, number)
        vim.cmd("redraw")

        if number == 1 then
          vim.fn.mkdir(dirName)
        elseif number == 2 then
          vim.ui.input({prompt = "directory name: "}, function(alterDir)
            vim.fn.mkdir(alterDir, 'p')
            dirName = string.find(alterDir, '/') and alterDir or alterDir .. '/'
          end)
        else
          vim.cmd('echoerr "Invalid choice"')
        end

      end)

    return dirName
  else
    vim.fn.mkdir(dirName, 'p')
    return dirName
  end

end




return helper
