--[[StringBuffer.lua
描述：
	提供了StringBuffer类,用于优化小字符串的拼接操作
--]]

--@note：追加字符串
local function sb_append(sb, s)
	table.insert(sb, tostring(s))
	for i = #sb-1, 1, -1 do
		if #(sb[i]) > #(sb[i+1]) then
			break
		end
		sb[i] = sb[i] .. table.remove(sb)
	end
	return sb
end

local classMT = {
	__add = sb_append,
	__concat = sb_append,
	__tostring = table.concat
}

--@note：构造函数
local function sb_new(_, s)
	local sb = define(classMT, {
		append = function(self, s)
			self = self .. s
			return self
		end
	})
	table.insert(sb, s and tostring(s) or "")
	return sb
end

StringBuffer = define { __call = sb_new }