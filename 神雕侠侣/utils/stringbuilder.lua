StringBuilder = {}
StringBuilder.__index = StringBuilder


function StringBuilder:new()
	print("string builder new")
	local self = {}
	setmetatable(self, StringBuilder)
	self.rules = {}
	return self
end

function StringBuilder:delete()
	print("string builder delete")
	self = nil
end

--change $str1$ with str2
function StringBuilder:Set(str1, str2)
	self.rules["%$" .. str1 .. "%$"] = str2
end

--change $str$ with num
function StringBuilder:SetNum(str, num)
	self.rules["%$" .. str .. "%$"] = tostring(num)
end

function StringBuilder:GetString(str)
	local resultStr = str
	for i,v in pairs(self.rules) do
		resultStr = string.gsub(resultStr, i, v)
	end
	return resultStr
end

function StringBuilder.Split(astr, bstr)
	local t = {}
	local index_l = 0
	local index_r = 0
	while true do
		index_r = string.find(astr, bstr, index_l)
		if not index_r then
			table.insert(t, string.sub(astr, index_l, string.len(astr)))
			break
		end
		table.insert(t, string.sub(astr, index_l, index_r-1))
		index_l = index_r + string.len(bstr)
	end
	return t
end

return StringBuilder
