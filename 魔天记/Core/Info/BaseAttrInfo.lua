-- 基础属性(适用范围:全部带属性的Object)
BaseAttrInfo = class("BaseAttrInfo");

function BaseAttrInfo:New()
	self = {};
	setmetatable(self, {__index = BaseAttrInfo});
	self:_InitProperty()
	return self;
end

function BaseAttrInfo:_InitProperty()
	local p = self:GetProperty()
	for k, v in ipairs(p) do
		self[v] = 0
	end
end

function BaseAttrInfo:Init(data)
	
	if data == nil then
		return;
	end
	
	local p = self:GetProperty()
	
	for k, v in ipairs(p) do
		if(data[v]) then		
			self[v] = data[v]
		else
			self[v] = 0
		end
	end
end

function BaseAttrInfo:Reset()
	local p = self:GetProperty()
	
	for k, v in ipairs(p) do
		if(self[v]) then
			self[v] = 0
		end
	end
end


local insert = table.insert
function BaseAttrInfo:Sub1(data)
	local p = self:GetProperty()
	local result = {}
	for k, v in pairs(p) do
		if(self[v] - data[v] > 0) then
			local item = {}
			item.k = LanguageMgr.Get("attr/" .. v)
			item.v = self[v] - data[v]
			insert(result, item)
		end
	end
	
	return result
end

function BaseAttrInfo:Sub(data)
	if(data) then
		local p = self:GetProperty()
		
		for k, v in pairs(p) do
			if(data[v]) then
				if(self[v]) then
					self[v] = self[v] - data[v]
				end
			end
		end
	end	
end

function BaseAttrInfo:Add(data)
	if(data) then
		local p = self:GetProperty()
		
		for k, v in pairs(p) do
			if(data[v]) then
				if(self[v]) then
					self[v] = self[v] + data[v]
				else
					self[v] = data[v]
				end
			end
		end
	end	
end

function BaseAttrInfo:Mul(rate)	
	local p = self:GetProperty()
	
	for k, v in pairs(p) do
		if(self[v] ~= 0) then
			self[v] = self[v] * rate
		end
	end	
end

function BaseAttrInfo:MulByTable(t)	
	local p = self:GetProperty()
	
	for k, v in pairs(p) do
		if(self[v] ~= 0 and t[v]) then
			self[v] = self[v] * t[v]
		end
	end	
end

local property = {
	'hp_max',
	'mp_max',
	'phy_att',
	-- 'mag_att',
	'phy_def',
	-- 'mag_def',
	'hit',
	'eva',
	'crit',
	'tough',
	'fatal',
	'block'
}

function BaseAttrInfo.GetAttKeys()
	return property
end

function BaseAttrInfo:GetProperty()
	return property
end

local attrDes = {}

function BaseAttrInfo.GetDes(name)
	if(attrDes[name] == nil) then
		attrDes[name] = LanguageMgr.Get(name)
	end
	return attrDes[name]
end

function BaseAttrInfo:GetPropertyByKeys(keys)
	local data = {}
	for k, v in ipairs(keys) do
		local temp = self:_CreatePropertyAndDesItem(v)
		insert(data, temp)
	end
	return data
end

function BaseAttrInfo:GetPropertyAndDes()
	local data = {}
	local p = self:GetProperty()
	for k, v in ipairs(p) do
		if(self[v] and self[v] ~= 0) then
			-- local temp = {key = v, des = BaseAttrInfo.GetDes("attr/" .. v), property = self[v], sign = ""}
			-- if(v == "dmg_rate" or v == "att_dmg_rate") then
			-- 	temp.property = self[v] / 10
			-- end
			-- if((string.sub(v, - 3) == "per") or(string.sub(v, - 4) == "rate")) then
			-- 	temp.sign = "%"
			-- end
			local temp = self:_CreatePropertyAndDesItem(v)
			insert(data, temp)
		end
	end
	return data
end

function BaseAttrInfo:_CreatePropertyAndDesItem(v)
	local temp = {key = v, des = BaseAttrInfo.GetDes("attr/" .. v), property = self[v], sign = ""}
	if(v == "dmg_rate" or v == "att_dmg_rate" or v == "exp_per" or v == "crit_bonus" or v == "fatal_bonus") then
		temp.property = self[v] / 10
	end
	
	if((string.sub(v, - 3) == "per") or(string.sub(v, - 4) == "rate") or v == "crit_bonus" or v == "fatal_bonus") then
		temp.sign = "%"
	end
	return temp
end

function BaseAttrInfo:GetAllPropertyAndDes()
	local data = {}
	local p = self:GetProperty()
	for k, v in ipairs(p) do
		if(self[v]) then
			-- local temp = {key = v, des = BaseAttrInfo.GetDes("attr/" .. v), property = self[v], sign = ""}
			-- if(v == "dmg_rate" or v == "att_dmg_rate") then
			-- 	temp.property = self[v] / 10
			-- end
			-- if((string.sub(v, - 3) == "per") or(string.sub(v, - 4) == "rate")) then
			-- 	temp.sign = "%"
			-- end
			local temp = self:_CreatePropertyAndDesItem(v)
			insert(data, temp)
		end
	end
	return data
end

function BaseAttrInfo:GetAttr()
	local data = {}
	local p = self:GetProperty()
	for k, v in ipairs(p) do
		if(self[v] and self[v] ~= 0) then
			local temp = {key = v, property = self[v]}			
			insert(data, temp)
		end
	end
	return data
end 