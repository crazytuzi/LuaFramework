local property = {}
local careerProp = {
	[0] = {
		"攻击下限",
		"攻击上限",
		"战士生命值",
		"战士强攻概率",
		"战士强攻伤害",
		"战士暴击概率",
		"战士暴击系数",
		"战士回血上限",
		"战士回魔上限",
		"战士回血速度",
		"战士守护减免",
		"战士守护概率"
	},
	{
		"魔法下限",
		"魔法上限",
		"法师生命值",
		"法师强攻概率",
		"法师强攻伤害",
		"法师暴击概率",
		"法师暴击系数",
		"法师回血上限",
		"法师回魔上限",
		"法师回血速度",
		"法师守护减免",
		"法师守护概率"
	},
	{
		"道术下限",
		"道术上限",
		"道士生命值",
		"道士强攻概率",
		"道士强攻伤害",
		"道士暴击概率",
		"道士暴击系数",
		"道士回血上限",
		"道士回魔上限",
		"道士回血速度",
		"道士守护减免",
		"道士守护概率"
	}
}
local career = {
	[0] = "攻击",
	"魔法",
	"道术"
}
local mulit_prop = {
	"防御",
	"魔御",
	"攻击",
	"魔法",
	"道术"
}
local job_prop = {
	"生命值",
	"强攻概率",
	"强攻伤害",
	"暴击概率",
	"暴击系数",
	"回血上限",
	"回魔上限",
	"回血速度",
	"守护减免",
	"守护概率",
	"神圣伤害"
}
local job_name = {
	[0] = "战士",
	"法师",
	"道士"
}
local base_prop = {
	[0] = "攻击",
	"魔法",
	"道术"
}
local PropertyClass = class("property")
PropertyClass.ctor = function (self)
	self.props = {}

	return 
end
PropertyClass.set = function (self, name, value1, value2)
	local exist = false

	for i, v in ipairs(self.props) do
		if v[1] == name then
			v[2] = value1
			v[3] = value2
			exist = true

			break
		end
	end

	if not exist then
		self.props[#self.props + 1] = {
			name,
			value1,
			value2
		}
	end

	return self
end
PropertyClass.get = function (self, name)
	for i, v in ipairs(self.props) do
		if v[1] == name then
			return v[2], v[3]
		end
	end

	return nil, nil
end
PropertyClass.del = function (self, name)
	for i, v in ipairs(self.props) do
		if v[1] == name then
			table.remove(self.props, i)

			return 
		end
	end

	return 
end
PropertyClass.merge = function (self, name, value1, value2)
	local v1, v2 = self.get(self, name)

	if v1 or v2 then
		if v1 or value1 then
			v1 = (v1 or 0) + (value1 or 0)
		end

		if v2 or value2 then
			v2 = (v2 or 0) + (value2 or 0)
		end

		self.set(self, name, v1, v2)
	else
		self.set(self, name, value1, value2)
	end

	return self
end
PropertyClass.clearZero = function (self)
	local i = 1

	while true do
		local v = self.props[i]

		if v then
			if v[2] == 0 then
				table.remove(self.props, i)
			else
				i = i + 1
			end
		else
			break
		end
	end

	return self
end
PropertyClass.mergeProp = function (self, prop)
	for i, v in ipairs(prop.props) do
		self.merge(self, v[1], v[2])
	end

	return self
end
PropertyClass.toStdProp = function (self)
	local tmpProp = PropertyClass.new()

	for i, v in ipairs(self.props) do
		local len = string.utf8len(v[1])
		local first = string.utf8sub(v[1], 1, len - 2)
		local last = string.utf8sub(v[1], len - 1, len)

		if self.isMulitProp(self, first, last) then
			local oldv1 = self.get(self, first .. "下限") or 0
			local oldv2 = self.get(self, first .. "上限") or 0
			local v1 = (last == "下限" and v[2]) or oldv1
			local v2 = (last == "上限" and v[3]) or oldv2

			tmpProp.set(tmpProp, first, v1, v2)
		else
			tmpProp.set(tmpProp, v[1], v[2])
		end
	end

	self.props = tmpProp.props

	return self
end
PropertyClass.grepJob = function (self, jobIdx)
	local p = self.props
	self.props = {}

	for i, v in ipairs(p) do
		local job = self.isJobProp(self, v[1])

		if job == 99 then
			self.set(self, v[1], v[2], v[3])
		elseif job == jobIdx then
			local len = string.utf8len(v[1])
			local newName = string.utf8sub(v[1], 3, len)

			self.set(self, newName, v[2], v[3])
		end
	end

	return self
end
PropertyClass.isMulitProp = function (self, propName, propLast)
	if propLast and propLast ~= "下限" and propLast ~= "上限" then
		return false
	end

	for i, v in ipairs(mulit_prop) do
		if propName == v then
			return true
		end
	end

	return false
end
PropertyClass.isJobProp = function (self, propName)
	for i, v in pairs(base_prop) do
		if v == propName then
			return i
		end
	end

	local len = string.utf8len(propName)
	local first = string.utf8sub(propName, 1, 2)
	local last = string.utf8sub(propName, 3, len)

	for i, v in ipairs(job_prop) do
		if v == last then
			for j, k in pairs(job_name) do
				if k == first then
					return j
				end
			end

			print("转换时，发现未知职业！！！ " .. v[1])

			return 99
		end
	end

	return 99
end
PropertyClass.getPropStrings = function (self, propName)
	local v1, v2 = self.get(self, propName)

	if v1 and tonumber(v1) then
		v1 = math.floor(v1)
	end

	if v2 and tonumber(v2) then
		v2 = math.floor(v2)
	end

	if propName == "伤害加深" or propName == "伤害减免" or propName == "怒之烈火几率" or propName == "怒之火雨几率" or propName == "怒之噬血几率" or propName == "物理闪避" or propName == "魔法闪避" or propName == "命中" then
		v1 = (v1 and v1 .. "%") or nil
		v2 = (v2 and v2 .. "%") or nil
	else
		v1 = (v1 and v1 .. "") or nil
		v2 = (v2 and v2 .. "") or nil
	end

	return {
		propName,
		v1,
		v2
	}
end
PropertyClass.formatPropString = function (self, propName, format1, format2)
	local format1 = format1 or "%s +%s"
	local format2 = format2 or "%s %s-%s"
	local ss = self.getPropStrings(self, propName)

	if #ss == 2 then
		return string.format(format1, ss[1], ss[2])
	elseif #ss == 3 then
		return string.format(format2, ss[1], ss[2], ss[3])
	end

	return ""
end
property.dumpPropertyStr = function (propStr)
	local propResult = PropertyClass.new()
	local sp1 = string.split(propStr, ";")

	for i, v in ipairs(sp1) do
		local sp2 = string.split(v, "=")
		local name = sp2[1]
		local value = tonumber(sp2[2])

		if value then
			propResult.set(propResult, name, value)
		end
	end

	return propResult
end

return property
