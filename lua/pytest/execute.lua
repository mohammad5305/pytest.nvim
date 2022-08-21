function setSignCol() end

function findStatus(report, regex, index)
  _, indexEnd, path, functionName, status = string.find(report, regex, index)
  if indexEnd then
    return {
      ['path'] = path,
      ['functionName'] = functionName,
      ['status'] = status
    }, indexEnd + 1
  else
    return nil
  end
end

function processReport(report, times)
  if times then
    -- TODO: combine these 2 varibale into one line
    local lastIndex = 0
    local reportTbl = {}
    local match = 0
    for i = 1, times do
      if lastIndex then
        match, lastIndex = findStatus(report, "([^%s]+)::([^%s]+)(%s%w+)",
          lastIndex)
        table.insert(reportTbl, match)
      end

    end
    return reportTbl
  else
    return findStatus(report, "([^%s]+)::([^%s]+)(%s%w+)")
  end
end

function executePytest(cmd, cwd, async)
  if async then
    local times = nil
    local function on_event(job_id, data, event)
      if event == "stdout" or event == "stderr" then
        if data then
          local stringData = table.concat(data, "\n")
          if times == nil then
            _, _, times = string.find(stringData, "collected (%d+)")
          end
          -- TODO: the the output of this function and pipe it to setSignCol also code base getting so complicated
          processReport(stringData, times)
        end
      end

    end

    local job_id = vim.fn.jobstart(cmd, {
      cwd = cwd,
      on_stdout = on_event,
      stdout_buffered = true,
      stderr_buffered = true
    })
  else
  end
end

executePytest(
  "pytest -v --capture=no --no-summary --no-header --color=no  --disable-warnings | tr -d '='",
  '/tmp/pytest-example/', true)
