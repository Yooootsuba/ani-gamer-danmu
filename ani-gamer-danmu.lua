exe = "danmu-get"

function urldecode(url)
    url = url:gsub('+', ' ')
    url = url:gsub('%%(%x%x)', function(h)
        return string.char(tonumber(h, 16))
    end)
    return url
end

function danmu_get(sn)
    local handle = io.popen(exe .. " " .. sn)
    local output = handle:read("*a")
    handle:close()
    return output
end

function file_loaded()
    local path = mp.get_property("path")
    local is_bahamut = path:find("https://bahamut.akamaized.net/") ~= nil

    if is_bahamut then
        local sn = string.match(urldecode(path), ":(%d+):")
        danmu_get(sn)
    end
end

mp.register_event("file-loaded", file_loaded)
