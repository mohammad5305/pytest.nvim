local helper = {}

function helper.is_dir(path)
    return os.execute(('[ -d "%s" ]'):format(path))
end


return helper
