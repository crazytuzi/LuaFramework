--[[--

Split a string by string.

@param string str
@param string delimiter
@return table

]]
function string.mysplit(str, delimiter)
    assert(type(str) == "string" and type(delimiter) == "string" and delimiter ~= "")

    local pos, ret = 1, { }

    local iterator = function(delimiter)
        return string.find(str, delimiter, pos, true)
    end

    for sp, ep in iterator, delimiter do
        if pos <= sp-1 then
            table.insert(ret, string.sub(str, pos, sp-1))
        end
        pos = ep + 1
    end

    if pos <= string.len(str) then
        table.insert(ret, string.sub(str, pos))
    end

    return ret
end

--[[
Strip whitespace (or other characters) from the beginning and end of a string.

@param string str
@return string
--]]

function string.mytrim(str)
    assert(type(str) == "string")
    str = string.gsub(str, "^[ \t\n\r]+", "")
    return string.gsub(str, "[ \t\n\r]+$", "")
end

-- 计算一个table的条目数量
function table.size(t)
	if type(t) == "table" then
		local ret = 0
		for k, v in pairs(t) do
			ret = ret + 1
		end
		return ret
	end
end

function table.clear(t)
	if type(t) == "table" then
		for k, v in pairs(t) do
			t[k] = nil
		end
	end
end

function table.scopy(t)
	if type(t) == "table" then
		local ret = {}
		for k, v in pairs(t) do
			ret[k] = v
		end
		return ret
	end
end

-- 数组化
function table.toarray(t)
	if type(t) == "table" then
		local ret = {}
		for k, v in pairs(t) do
			ret[#ret+1] = v
		end
		return ret
	end
end

createReloadBtn = function(...)
    local args = {...}
	local MMenuButton = require "src/component/button/MenuButton"
	local Director = cc.Director:getInstance()
	local WinSize = Director:getWinSize()
	local scene = Director:getRunningScene()
	local tag = 99999
	if scene:getChildByTag(tag) then return end
	MMenuButton.new(
	{
		src = "res/component/button/51_sel.png",
		parent = scene,
		pos = cc.p(WinSize.width/2, WinSize.height/2),
		zOrder = 100000000,
		tag = tag,
		scale = 0.3,
		label = {
			src = "",
			size = 22,
			color = MColor.lable_yellow,
		},
		
		cb = function(tag, node)
            for k, v in ipairs(args) do
                package.loaded[v] = nil
            end
		end,
	})
end
