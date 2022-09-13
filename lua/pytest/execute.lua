local execute = {}
local helper = require('pytest.helper')

vim.cmd('sign define PytestSucces text=S')
vim.cmd('sign define PytestFailed text=F')
function execute.setSignCol(id, state, bufnr, line)
  if vim.trim(state) == "PASSED" then
    vim.cmd(string.format('sign place %s group=pytest name=PytestSucces line=%s', id, line))
  else
    vim.cmd(string.format('sign place %s group=pytest name=PytestFailed line=%s', id, line))
  end
end

function execute.processReport(report)
  -- TODO: distinct the report
  local reportTbl = {}
  for _, line in ipairs(report)  do
    if string.find(line, ':') then
      local reportResult = vim.split(line, ':')
      local functionName, status = unpack(vim.split(reportResult[#reportResult], " "))
      table.insert(reportTbl, {['functionName'] = string.match(functionName, "[A-Za-z_]+"), ['status'] = status})
    end
  end
  return reportTbl
end

function execute.executePytest(bufnr, cmd, cwd)
  local function on_event(job_id, data, event)
    if event == "stdout" or event == "stderr" then
      if data then

        local report = execute.processReport(data)
        
        local functionNames = helper.getQuery("(function_definition name: (identifier)@capture)", bufnr)

        for _, case in ipairs(report) do
          for _, query in ipairs(functionNames) do
            if vim.treesitter.get_node_text(query, bufnr) == case.functionName  then
              local lnum, _ = query:start()
              execute.setSignCol(math.random(0, 50), case.status, bufnr, lnum+1)
            end

          end
        end
      end
    end

  end

  local job_id = vim.fn.jobstart(cmd, {
    cwd = cwd,
    on_stdout = on_event,
    stdout_buffered = true,
    stderr_buffered = true,
  })

end


return execute
