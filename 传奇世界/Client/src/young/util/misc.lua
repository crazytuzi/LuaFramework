local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)

-- 读取原始的配置表， 返回一个按关键字分层的新表
readConfig = function(self, cfg, keys, traverse)
	local tOriginal = require(cfg)
	local ret = {}
	-----------------------------------
	local fields = {}
	if type(keys) == "string" then
		fields[1] = keys
	elseif type(keys) == "table" then
		fields = keys
	end
	-----------------------------------
	local numOfKeys = #fields
	-----------------------------------
	for i, v in ipairs(tOriginal) do
		
		local dst = ret
		local key = nil
		local cur = nil
		
		for i = 1, (numOfKeys-1) do
			key = v[ fields[i] ]
			if key then
				cur = dst[key]
				if not cur then
					cur = {}
					dst[key] = cur
				end
				dst = cur
			else
				dump(v, "配置表[" .. cfg .. "]发现一条记录关键字[" .. fields[i] .. "]" .. "不存在, 请修改")
			end
		end
		
		-- 最后一个key不存在则默认以自然数作为key
		local lastKey = v[ fields[numOfKeys] ]
		if lastKey then
			dst[lastKey] = v
		else
			dst[#dst + 1] = v
		end
	end
	-----------------------------------
	-- dump(ret, "ret")
	-----------------------------------
	if not traverse then 
		package.loaded[cfg] = nil
		return ret
	else
		return ret, tOriginal
	end
	-----------------------------------
end
----------------------------------------------
isDefaultValue = function(self, t, key, default, opponent)
	local ret = false
	local value = t[key]
	if value ~= opponent then
		value = default
		t[key] = value
		ret = true
	end
	return ret
end

-----------------------------------------------------------
-- 从一个 table 中读取值, 如果为 nil, 则返回默认值
getValue = function(self, t, key, default, readonly)
	local value = t[key]
	if value == nil then
		value = default
		if not readonly then t[key] = value end
	end
	return value
end
----------------------------------------------