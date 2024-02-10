local utils = require "mp.utils"
local options = require "mp.options"

local opts = {}

opts["color"] = true
opts["font-size"] = 16
opts["danmu-duration"] = 10000
opts["danmu-gap"] = 0
opts["anchor"] = 1
opts["danmu-hidden-default"] = false

options.read_options(opts)
options.read_options(opts, "ani-gamer-danmu")


local danmus = {}
local danmu_hidden = opts["danmu-hidden-default"]
local danmu_overlay = mp.create_osd_overlay("ass-events")


-- Auto generation by ChatGPT
function urldecode(url)
    url = url:gsub("+", " ")
    url = url:gsub("%%(%x%x)", function(h)
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
        local color = "{\\1c&H" .. danmu.color .. "&}"
        local formatting = "{\\an" .. opts["anchor"] .. "}" .. "{\\fs" .. opts["font-size"] .. "}"
        local danmu_string = opts["color"] and color .. formatting .. line or formatting .. line

        if result == nil then
            result = danmu_string
        else
            if opts["anchor"] <= 3 then
                result = danmu_string .. "\n" .. result
            else
                result = result .. "\n" .. danmu_string
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

    danmu_overlay.data = ""
    for i=1,#danmus do
        local danmu = danmus[i]
        if danmu.time > msec then
            break
        elseif msec <= danmu.time + opts["danmu-duration"] then
            local danmu_string = format_danmu(danmu)
            if opts["anchor"] <= 3 then
                danmu_overlay.data =    danmu_string
                                    .. "\n"
                                    .. "{\\fscy" .. opts["danmu-gap"] .. "}{\\fscx0}\\h{\fscy\fscx}"
                                    .. danmu_overlay.data
            else
                danmu_overlay.data =    danmu_overlay.data
                                    .. "{\\fscy" .. opts["danmu-gap"] .. "}{\\fscx0}\\h{\fscy\fscx}"
                                    .. "\n"
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
            text = danmu_json[i].text,
            color = danmu_json[i].color:sub(2)
        }
    end
end

function danmus_get(sn)
    -- Define the API endpoint, content type, and user agent for making requests
    local api = "https://ani.gamer.com.tw/ajax/danmuGet.php"
    local content_type = "Content-Type: application/x-www-form-urlencoded"
    local user_agent = "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/114.0"

    -- Command to execute CURL with POST request to the API
    local command = string.format('curl -X "POST" -d "sn=%s" -H "%s" -H "%s" "%s"', sn, content_type, user_agent, api)

    local handle = io.popen(command)
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

function set_danmu_hidden(state)
    if state == nil then
        danmu_hidden = not danmu_hidden
    else
        danmu_hidden = state == "yes"
    end

    if danmu_overlay ~= nil then
        if danmu_hidden then
            mp.command("show-text '隱藏彈幕'")
            danmu_overlay:remove()
        else
            mp.command("show-text '顯示彈幕'")
            update_danmu_overlay(mp.get_property_native("time-pos"))
        end
    end
end

function set_danmu_anchor(anchor)
    if anchor == nil then
        opts["anchor"] = (opts["anchor"] % 9) + 1
    else
        opts["anchor"] = tonumber(anchor)
    end
    if danmu_overlay then
        update_danmu_overlay(mp.get_property_native("time-pos"))
    end
end

mp.add_key_binding(nil, "danmu-hidden", set_danmu_hidden)
mp.add_key_binding(nil, "danmu-anchor", set_danmu_anchor)

mp.register_event("file-loaded", file_loaded)
mp.observe_property("time-pos", "native", update_danmu_overlay)
