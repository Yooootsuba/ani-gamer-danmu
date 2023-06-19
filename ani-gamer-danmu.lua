local utils = require 'mp.utils'
local options = require 'mp.options'


local exe = "danmu-get"

local danmus = {}
local danmu_overlay = mp.create_osd_overlay("ass-events")
local danmu_hidden = false

local opts = {}
opts['auto-load'] = false
opts['color'] = 'random'
opts['font-size'] = 16
opts['danmu-duration'] = 10000
opts['danmu-gap'] = 0
opts['anchor'] = 1

-- Auto generation by ChatGPT
function urldecode(url)
    url = url:gsub('+', ' ')
    url = url:gsub('%%(%x%x)', function(h)
        return string.char(tonumber(h, 16))
    end)
    return url
end

-- Reference to https://i2.bahamut.com.tw/js/anime.js?v=1683082395
function formattime(time)
    local time = math.floor(time / 10)
    local h = math.floor(time / 3600)
    local m = math.floor((time - h * 3600) / 60)
    local s = math.floor(time - h * 3600 - m * 60)

    return (h * 60 * 60 + m * 60 + s) * 1000
end

function format_danmu(danmu)
    local danmu_string = danmu.text
    local result = nil
    local lines = danmu_string:gsub("^[%s　]+", ""):gmatch("([^\n]*)\n?")

    for line in lines do
        local formatting = '{\\an' .. opts['anchor'] .. '}' .. '{\\fs' .. opts['font-size'] .. '}'
        local danmu_string = formatting .. line
        if result == nil then
            result = danmu_string
        else
            if opts['anchor'] <= 3 then
                result = danmu_string .. '\n' .. result
            else
                result = result .. '\n' .. danmu_string
            end
        end
    end
    return result
end

function update_danmu_overlay(_, time)
    if danmu_hidden or danmu_overlay == nil or danmus == nil or time == nil then
        return
    end

    local msec = time * 1000

    danmu_overlay.data = ''
    for i=1,#danmus do
        local danmu = danmus[i]
        if danmu.time > msec then
            break
        elseif msec <= danmu.time + opts['danmu-duration'] then
            local danmu_string = format_danmu(danmu)
            if opts['anchor'] <= 3 then
                danmu_overlay.data =    danmu_string
                                    .. '\n'
                                    .. '{\\fscy' .. opts['danmu-gap'] .. '}{\\fscx0}\\h{\fscy\fscx}'
                                    .. danmu_overlay.data
            else
                danmu_overlay.data =    danmu_overlay.data
                                    .. '{\\fscy' .. opts['danmu-gap'] .. '}{\\fscx0}\\h{\fscy\fscx}'
                                    .. '\n'
                                    .. danmu_string
            end
        end
    end
    danmu_overlay:update()
end

function generate_danmus(danmu_json_strings)
    local danmu_json = utils.parse_json(danmu_json_strings)

    for i=1,#danmu_json do
        danmus[#danmus+1] = {
            time = formattime(tonumber(danmu_json[i].time)),
            text = danmu_json[i].text
        }
    end
end

function danmus_get(sn)
    local handle = io.popen(exe .. " " .. sn)
    local output = handle:read("*a")
    handle:close()
    return output
end

function file_loaded()
    -- Get media path
    local path = mp.get_property("path")
    local is_bahamut = path:find("https://bahamut.akamaized.net/") ~= nil

    -- Check if path starts with "bahamut.akamaized.net"
    if is_bahamut then
        local sn = string.match(urldecode(path), ":(%d+):")
        local danmu_json_strings = danmus_get(sn)
        generate_danmus(danmu_json_strings)
    end
end

mp.register_event("file-loaded", file_loaded)
mp.observe_property("time-pos", "native", update_danmu_overlay)
