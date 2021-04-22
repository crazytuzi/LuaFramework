local QRichText = import ".QRichText"
local QRichTypewriter = class("QRichTypewriter", QRichText)
--[[
	富文本打字机 与richtext用法一样,setString第二个参数为时间  用visit函数来更新
	有以下几个函数
	pause:暂停打字机
	resume:继续
	showAll:显示全部文本
--]]

--[[
utf8格式 
0xxxxxxx
110xxxxx 10xxxxxx 10xxxxxx
1110xxxx 10xxxxxx 10xxxxxx 10xxxxxx
11110xxx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
--]]

--将utf8字符串 解析为字符数组

local function utf8_chars(str)
	local idx = 1
	local len = string.len(str)
	local chars = {}
	while idx <= len do
		local byte = string.byte(str, idx)
		if byte == nil then
			break
		end
		if bit.rshift(byte, 7) == 0 then
			table.insert(chars, string.char(byte))
			idx = idx + 1
		elseif bit.rshift(byte,5) == 6  then
			table.insert(chars, string.char(byte, string.byte(str, idx + 1)))
			idx = idx + 2
		elseif bit.rshift(byte,4) == 14 then
			table.insert(chars, string.char(byte, string.byte(str, idx + 1), string.byte(str, idx + 2)))
			idx = idx + 3
		elseif bit.rshift(byte,3) == 30 then
			table.insert(chars, string.char(byte, string.byte(str, idx + 1), string.byte(str, idx + 2), string.byte(str, idx + 3)))
			idx = idx + 4
		else
			assert(false, str .. " is not a standard string")
		end
	end
	return chars
end

function QRichTypewriter:ctor(...)
	self.super.ctor(self,...)
	self._speed = 0
    self._time = 0
    self._typewriter_idx = 0
    self._stop = true
    self._configCache = {}
end

function QRichTypewriter:_parseTypewriterConfig()
	local old_config = self._parseConfig
	local new_config = {}
	for i,cfg in ipairs(old_config) do
		if cfg.oType == "font" or cfg.oType == "bmfont" then
			cfg.chars = utf8_chars(cfg.content)
			cfg.content = ""
			table.insert(new_config, cfg)
		else
			table.insert(new_config, cfg)
		end
	end
	self._configCache = new_config
	self._parseConfig = {}
end

function QRichTypewriter:restart(speed)
	self._speed = speed --打字机速度
	self._time = 0
	self:_parseTypewriterConfig()
	self._typewriter_idx = 0
	self._stop = false
end

function QRichTypewriter:setString(strOrTable, speed)
    -- body 
    self:clear()
    -- 清空打字机
    self._speed = 0
    self._time = 0
    self._typewriter_idx = 0
    self._stop = true
    self._configCache = {}

    self:parseConfigString(strOrTable)
    self._old_config = clone(self._parseConfig)
    if speed then
    	self:restart(speed)
   	else
   		self:renderString()    
   	end
end

--显示所有文本
function QRichTypewriter:showAll()
	self._stop = true
	self:clear()
	self._parseConfig = self._old_config

	self._configCache = {}
	self._speed = 0
	self._time = 0
	self._typewriter_idx = 0

	self:renderString()
end

function QRichTypewriter:pause()
	self._stop = true
end

function QRichTypewriter:resume()
	self._stop = false
end

function QRichTypewriter:loadConfig()
	local left = self._typewriter_idx
	self._parseConfig = {}
	for i,cfg in ipairs(self._configCache) do
		if left < 1 then
			return false
		end
		if cfg.oType == "font" or cfg.oType == "bmfont" then
			local chars = cfg.chars
			local read_num = math.min(#chars,left)
			cfg.content = table.concat(chars, nil, 1, read_num)
			table.insert(self._parseConfig, cfg)
			left = left - read_num
		else
			table.insert(self._parseConfig, cfg)
			left = left - 1
		end
	end  
	return left > 0
end

function QRichTypewriter:visit(dt)
	if self._stop ~= false then return end
	self._time = self._time + dt
	local cur_idx = math.floor(self._time / self._speed)
	if cur_idx ~= self._typewriter_idx then
 	    self:clear()
 	    self._typewriter_idx = cur_idx
 	    self._stop = self:loadConfig()
 	    self:renderString()
	end
end

function QRichTypewriter:isPlaying()
    return self._stop == false
end

return QRichTypewriter