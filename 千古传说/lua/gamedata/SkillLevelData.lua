
local SkillLevelData = class("SkillLevelData")

function SkillLevelData:ctor()
	self.skill_list = MEMapArray:new()
end

function SkillLevelData:restart( )
	self.skill_list.clear()
end

function SkillLevelData:objectByID( spellId)
	return SkillLevelData:getInfoBySkillAndLevel( spellId.skillId , spellId.level)
end

function splitLevelAttrAdd( str ,level)
	local tbl = {}
	local level_info = SkillAttributeData:objectByID(level)
	if level_info == nil then
		print("level_info = nil  level == ",level)
	end
	local temptbl = string.split(str,'|')			--分解"|"
	for k,v in pairs(temptbl) do
		local temp = string.split(v,'_')				--分解'_',集合为 key，vaule 2个元素
		local key = tonumber(temp[1])
		if tonumber(temp[1]) <= 15 then
			tbl[key] = math.floor(tonumber(temp[2]) * tonumber(level_info["attr_add_"..key]))
		else
			local value = tonumber(temp[2])
			local value_add = tonumber(temp[3] or 0)
			tbl[key] = value + value_add*level
		end
	end
	return tbl
end

function splitImmuneAttr( str ,level)
	local tbl = {}
	local temptbl = string.split(str,'|')			--分解"|"
	for k,v in pairs(temptbl) do
		local temp = string.split(v,'_')				--分解'_',集合为 key，vaule 2个元素
		local key = tonumber(temp[1])
		local value = tonumber(temp[2])
		local value_add = tonumber(temp[3] or 0)
		tbl[key] = value + value_add*level
	end
	return tbl
end

function splitLevelValue( str ,level)
	local temp = string.split(str,'_')				--分解'_',集合为 key，vaule 2个元素
	local value = tonumber(temp[1])
	local value_add = tonumber(temp[2] or 0)
	local num = value + value_add*level
	return num
end

function SkillLevelData:findInfo( skillID , level )
	local spellInfo = SkillBaseData:objectByID(skillID)
	if spellInfo == nil then
		print("技能信息有误 skillID ,level == ",skillID,level)
		return nil
	end
	if level >= 150 then
		level = 150
	end
	local level_info = SkillAttributeData:objectByID(level)
	local tbl = clone(spellInfo)
	tbl.level = level
	tbl.uplevel_cost = level_info.uplevel_cost
	if type(tbl.target_num ) == "string" then
		tbl.target_num = GetVauleByStringRange( tbl.target_num , level)
	end
	if tbl.attr_add ~= "" then
		tbl.attr_add = splitLevelAttrAdd(tbl.attr_add , level)
	else
		tbl.attr_add = {}
	end

	if tbl.attr_add_absolute ~= "" then
		local attr_add_absolute = GetAttrByString(tbl.attr_add_absolute)
		for k,v in pairs(attr_add_absolute) do
			tbl.attr_add[k] = tbl.attr_add[k] or 0
			-- if k > 15 then
			-- 	tbl.attr_add[k] = tbl.attr_add[k] + v/100
			-- else
				tbl.attr_add[k] = tbl.attr_add[k] + v
			-- end
			-- print("tbl.attr_add[k] ======> ",tbl.attr_add[k])
		end
	end

	if tbl.type == 2 then
		tbl.effect_value = math.floor(tonumber(tbl.effect_value) * tonumber(level_info.attr_add_1))
	else
		if tbl.effect_value ~= "" then
			tbl.effect_value = splitLevelValue(tbl.effect_value ,level )
		else
			tbl.effect_value = 0
		end
	end
	if tbl.effect_rate ~= "" then
		tbl.effect_rate = splitLevelValue(tbl.effect_rate ,level)
	else
		tbl.effect_rate = 0
	end
	if tbl.triggerSkill_rate ~= "" then
		tbl.triggerSkill_rate = splitLevelValue(tbl.triggerSkill_rate ,level)
	else
		tbl.triggerSkill_rate = 0
	end
	if tbl.trigger_hp ~= "" then
		tbl.trigger_hp = splitLevelValue(tbl.trigger_hp ,level)/100
	else
		tbl.trigger_hp = 0
	end

	if tbl.extra_hurt ~= 0 then
		tbl.extra_hurt = math.floor(tbl.extra_hurt * level_info.extra_hurt)
	end
	if tbl.buff_targetnum ~= "" then
		tbl.buff_targetnum = GetVauleByStringRange( tbl.buff_targetnum , level)
	else
		tbl.buff_targetnum = 0
	end
	if tbl.buff_rate ~= "" then
		tbl.buff_rate = splitLevelValue(tbl.buff_rate ,level)
	else
		tbl.buff_rate = 0
	end

	--extra_buffid = 0,extra_targe_type = 1,extra_buff_targetnum = 1,extra_buff_rate="10000_0",extra_buff_formula = 1
	if tbl.extra_buff_targetnum ~= "" then
		tbl.extra_buff_targetnum = GetVauleByStringRange( tbl.extra_buff_targetnum , level)
	else
		tbl.extra_buff_targetnum = 0
	end
	if tbl.extra_buff_rate ~= "" then
		tbl.extra_buff_rate = splitLevelValue(tbl.extra_buff_rate ,level)
	else
		tbl.extra_buff_rate = 0
	end
	-----------------------

	if tbl.immune ~= "" then
		tbl.immune = splitImmuneAttr(tbl.immune , level)
	else
		tbl.immune = {}
	end

	if tbl.effect_extra ~= "" then
		tbl.effect_extra = splitImmuneAttr(tbl.effect_extra , level)
	else
		tbl.effect_extra = {}
	end

	if tbl.be_effect_extra ~= "" then
		tbl.be_effect_extra = splitImmuneAttr(tbl.be_effect_extra , level)
	else
		tbl.be_effect_extra = {}
	end

	-- if tbl.power_zhanli ~= 0 then
	tbl.power = math.floor(tbl.power_zhanli * level_info.power)
	-- end
	return tbl;
end

function SkillLevelData:getInfoBySkillAndLevel( skillID , level)
	if skillID == 0 or level == 0 then
		return nil
	end
	if level >= 150 then
		level = 150
	end
	-- print("SkillLevelData:getInfoBySkillAndLevel( skillID , level) = ",skillID , level)
	self.skill_list = self.skill_list or {}
	self.skill_list[skillID] = self.skill_list[skillID] or {}
	if self.skill_list[skillID][level] == nil then
		self.skill_list[skillID][level] = self:findInfo( skillID , level )
	end
	return self.skill_list[skillID][level]
end

-- function splitBuffValue( str ,level)
-- 	local tbl = {}
-- 	local level_info = SkillAttributeData:objectByID(level)
-- 	local temptbl = string.split(str,'|')			--分解"|"
-- 	for k,v in pairs(temptbl) do
-- 		local temp = string.split(v,'_')				--分解'_',集合为 key，vaule 2个元素
-- 		local key = tonumber(temp[1])
-- 		if key <= 15 then
-- 			tbl[key] = tonumber(temp[2]) * tonumber(level_info["attr_add_"..key])
-- 		elseif key <= 28 then
-- 			local value = tonumber(temp[2])
-- 			local value_add = tonumber(temp[3] or 0)
-- 			tbl[key] = value + value_add*level
-- 		else
-- 			return key , tonumber(temp[2])
-- 		end
-- 	end
-- 	return tbl
-- end
function splitBuffValue( str ,level)
	local tbl = {}
	local level_info = SkillAttributeData:objectByID(level)
	local temptbl = string.split(str,'|')			--分解"|"
	for k,v in pairs(temptbl) do
		local temp = string.split(v,'_')				--分解'_',集合为 key，vaule 2个元素
		local key = tonumber(temp[1])
		if temp[3] then
			local value = tonumber(temp[2])
			local value_add = tonumber(temp[3] or 0)
			tbl[key] = value + value_add*level
		elseif key > 10000 then
			return key , tonumber(temp[2])
		else
			local value_add = tonumber(temp[2] or 0)
			local value = key + value_add*level
			return value
		end
	end
	return tbl
end

function SkillLevelData:findBuffInfo( buffId , level )
	local buffInfo = SkillBufferData:objectByID(buffId)
	if buffInfo == nil then
		print("buff信息有误 buff ,level == ",buffId,level)
		return nil
	end
	if level >= 150 then
		level = 150
	end
	local level_info = SkillAttributeData:objectByID(level)
	local tbl = clone(buffInfo)
	
	tbl.level = level
	if tbl.attr_change ~= "" then
		local attr_change = splitLevelAttrAdd(tbl.attr_change , level)
		if tbl.attr_change_absolute ~= "" then
			local attr_change_absolute = GetAttrByString(tbl.attr_change_absolute)
			for k,v in pairs(attr_change_absolute) do
				attr_change[k] = attr_change[k] or 0
				if k > 15 then
					attr_change[k] = attr_change[k] + v/100
				else
					attr_change[k] = attr_change[k] + v
				end
			end
		end
		tbl.attr_change = GetStringByTbl(attr_change)
	end
	if tbl.value ~= "" then
		local value , buff_level = splitBuffValue(tbl.value , level)
		if type(value) == "number" then
			tbl.value = value..""
			if buff_level == 0 then
				tbl.buff_level = 1
			else
				tbl.buff_level = tbl.level
			end
		else
			tbl.value = GetStringByTbl(value)
		end
	end

	if tbl.params ~= "" then
		if tbl.type == 50 then
			-- tbl.params = tbl.params
		else
			tbl.params = splitLevelValue(tbl.params ,level)
		end
	else
		tbl.params = 0
	end

	if tbl.buff_rate ~= "" then
		tbl.buff_rate = splitLevelValue(tbl.buff_rate ,level)
	else
		tbl.buff_rate = 0
	end


	if tbl.immune ~= "" then
		tbl.immune = splitImmuneAttr(tbl.immune , level)
	else
		tbl.immune = {}
	end

	if tbl.effect_extra ~= "" then
		tbl.effect_extra = splitImmuneAttr(tbl.effect_extra , level)
	else
		tbl.effect_extra = {}
	end

	if tbl.be_effect_extra ~= "" then
		tbl.be_effect_extra = splitImmuneAttr(tbl.be_effect_extra , level)
	else
		tbl.be_effect_extra = {}
	end


	return tbl;
end
function SkillLevelData:getBuffInfo( buffId , level)
	if buffId ==0 or level == 0 then
		return nil
	end
	if level >= 150 then
		level = 150
	end
	self.buff_list = self.buff_list or {}
	self.buff_list[buffId] = self.buff_list[buffId] or {}
	if self.buff_list[buffId][level] == nil then
		self.buff_list[buffId][level] = self:findBuffInfo( buffId , level )
	end
	return self.buff_list[buffId][level]
end

return SkillLevelData:new()