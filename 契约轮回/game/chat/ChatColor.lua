ChatColor = {}

--标准值对应主面板颜色值
local color_2_main = {
	["ffffff"] = "acacac",
	["6ce19b"] = "76e153",
	["3ec5fe"] = "2cc1ff",
	["9c48f2"] = "cc42ff",
	["e08225"] = "e46328",
	["e63232"] = "f53b3b",
	["d622e6"] = "df05e7",
}

--标准值对应聊天面板颜色值
local color_2_panel = {
	["ffffff"] = "444444",  --白色
	["6ce19b"] = "248a00",  --绿色
	["3ec5fe"] = "009cdd",  --蓝色
	["9c48f2"] = "a128e0",  --紫色
	["e08225"] = "df4600",  --橙色
	["e63232"] = "eb0000",  --红色
	["d622e6"] = "df05e7",  --粉色
	["ff3112"] = "cd1b1b",
	["50ddea"] = "2758b3",
	["84fe5a"] = "248a00",
	["ff9600"] = "b23200",	--人名
}

--标准颜色值
local colors = {
    white = "#ffffff",
    green = "#6ce19b", 
    blue = "#3ec5fe", 
    purple = "#9c48f2", 
    orage = "#e08225", 
    red = "#e63232", 
    pink = "#d622e6",
    yellow = "#ffcc00",
    redtrue = "#ff3112",
    bluetrue = "#50ddea",
    greentrue = "#84fe5a",
	yellowname = "#ff9600",
}

--替换主界面颜色
function ChatColor.ReplaceMainColor(msg)
	for k, v in pairs(color_2_main) do
		msg = string.gsub(msg, k, v)
	end
	return msg
end

--替换聊天界面颜色
function ChatColor.ReplaceChatPanelColor(msg)
	for k, v in pairs(color_2_panel) do
		msg = string.gsub(msg, k, v)
	end
	return msg
end

function ChatColor.get_colors()
	return colors
end

local specail = {"%%","%^", "%$", "%(", "%)", "%.", "%[","%]","%*","%+","%-","%?"}
local sepcial2 = {"%%%","%%^", "%%$", "%%(", "%%)", "%%.", "%%[","%%]","%%*","%%+","%%-","%%?"}
--替换特殊字符
function ChatColor.replace_special(message)
    for i=1, #specail do
        message = string.gsub(message, specail[i], sepcial2[i])
    end
    return message
end

function ChatColor.format_color2(message, patten, patten2, color)
    local new_message = message
    for w in string.gmatch(message, patten) do
        local tmp = ""
        for w2 in string.gmatch(w, patten2) do
            tmp = string.format(color,w2)
        end
        new_message = string.gsub(new_message, ChatColor.replace_special(w), tmp)
    end
    return new_message
end

function ChatColor.format_color(message)
    local colors = ChatColor.get_colors()
    for color, value in pairs(colors) do
        local patten = string.format("(%s{.-}}?)", color)
        local patten2 = string.format("%s{(.-}?)}}?", color)
        local color_value = string.format("<color=%s>%s</color>", value, "%s")
        message = ChatColor.format_color2(message, patten, patten2, color_value)
    end
    return message
end

function ChatColor.format_panel(message)
    local new_message = message
    for w in string.gmatch(message, "(panel{.-}}?)") do
        local tmp = ""
        for w2 in string.gmatch(w, "panel{(.-}?)}}?") do
            tmp = w2
        end
        for w3 in string.gmatch(tmp, "'value=(.*)'") do
            tmp = string.gsub(tmp, "'value=.*'", string.format("<a href=panel_%s>content</a>", w3))
        end
        local tmp2 = tmp
        tmp2 = string.gsub(tmp2, "<.->", "")
        tmp2 = string.gsub(tmp2, "content", "")
        tmp = string.gsub(tmp, ChatColor.replace_special(tmp2), "")
        tmp = string.gsub(tmp, "content", tmp2)
        new_message = string.gsub(new_message, w, tmp)
    end
    return new_message
end

local format_funs = {}
local function format1(k, v)
    return v
end
format_funs["general"] = format1
local function format2(k, v)
    return string.format("<a href=panel_%s>content</a>", v)
end
format_funs["panel"] = format2
local function format3(k, v)
    local arr = string.split(v, "|")
    if #arr == 2 then
        return string.format("<color=#ff9600><a href=role_%s>【%s】</a></color>", arr[1], arr[2])
    else
        return string.format("<color=#ff9600>【%s】</color>", v)
    end
end
format_funs["rolename"] = format3

local function format_items(items)
    local result = {}
    for k, v in pairs(items) do
        local item = Config.db_item[k]
        if not item then
            print2("叫杰林查一下这个物品ID" .. tostring(k));
            return;
        end
        local color = item.color
        local name = item.name
        local msg = ""
        if v > 0 then
            msg = string.format("<color=#%s><a href=item_%s>%s*%s</a></color>", ColorUtil.GetColor(color), k, name, v)
        else
            msg = string.format("<color=#%s><a href=item_%s>%s</a></color>", ColorUtil.GetColor(color), k, name)
        end
        result[#result+1] = msg
    end
    return table.concat(result, ",")
end

--带超链接的真实道具
local function format_pitems(pitems)
    local result = {}
    for k, v in pairs(pitems) do
        local item = Config.db_item[v]
        local color = item.color
        local name = item.name
        local msg = string.format("<color=#%s><a href=cache_%s>%s</a></color>", ColorUtil.GetColor(color), k, name)
        result[#result+1] = msg
    end
    return table.concat(result, ",")
end

function ChatColor.FormatMsg(message, args)
    local r = {}
    args = args or {}
    for i=1, #args do
        local arg = args[i]
        local result = {}
        for k, v in pairs(arg.props) do
            local handle = format_funs[k]
            if handle then
                result[#result+1] = handle(k, v)
            else
                result[#result+1] = v
            end
        end
        if not table.isempty(arg.items) then
            local items = format_items(arg.items)
            result[#result+1] = items
        end
        if not table.isempty(arg.pitems) then
            local pitems = format_pitems(arg.pitems)
            result[#result+1] = pitems
        end
        r[#r+1] = table.concat(result, ",")
    end
    message = string.format(message, unpack(r))
    message = ChatColor.format_color(message)
    message = ChatColor.format_panel(message)
    return message
end
