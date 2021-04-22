
local QEHelper = class("QEHelper")

local QStaticDatabase = import("...controllers.QStaticDatabase")

function QEHelper:ctor()
	
end

function QEHelper:getHeroIds()
	local characterIds = QStaticDatabase:sharedDatabase():getCharacterIDs()
	local heroIds = {}
	for _, characterId in ipairs(characterIds) do
		local character = QStaticDatabase:sharedDatabase():getCharacterByID(characterId)
		if character ~= nil and character.talent ~= nil then
			local strId = tostring(character.id)
			if strId ~= "20001" 
				and strId ~= "20002" 
				and strId ~= "20003" 
			then
				table.insert(heroIds, character.id)
			end
		end
	end
	
	return heroIds
end

function QEHelper:getHeroItems(heroId, breakthrough, enchant)
	local items = {}
	if heroId == nil or breakthrough == nil then
		return items
	end

	local characterInfo = QStaticDatabase:sharedDatabase():getCharacterByID(heroId)
	if characterInfo == nil then
		return items
	end

	local breakThroughInfo = QStaticDatabase:sharedDatabase():getBreakthroughByTalentLevel(characterInfo.talent, breakthrough + 1)
	if breakThroughInfo == nil then
		if breakthrough > 0 then
			for i = breakthrough, 1, -1 do
				breakThroughInfo = QStaticDatabase:sharedDatabase():getBreakthroughByTalentLevel(characterInfo.talent, i)
				if breakThroughInfo ~= nil then
					break
				end
			end
		end
		
		if breakThroughInfo == nil then
			return items
		end
	end

	enchant = enchant or 0

	if breakThroughInfo.weapon then
		table.insert(items, {itemId = breakThroughInfo.weapon, level = 0, enchants = enchant, enhance_exp = 0})
	end
	if breakThroughInfo.hat then
		table.insert(items, {itemId = breakThroughInfo.hat, level = 0, enchants = enchant, enhance_exp = 0})
	end
	if breakThroughInfo.clothes then
		table.insert(items, {itemId = breakThroughInfo.clothes, level = 0, enchants = enchant, enhance_exp = 0})
	end
	if breakThroughInfo.bracelet then
		table.insert(items, {itemId = breakThroughInfo.bracelet, level = 0, enchants = enchant, enhance_exp = 0})
	end
	if breakThroughInfo.shoes then
		table.insert(items, {itemId = breakThroughInfo.shoes, level = 0, enchants = enchant, enhance_exp = 0})
	end
	if breakThroughInfo.jewelry then
		table.insert(items, {itemId = breakThroughInfo.jewelry, level = 0, enchants = enchant, enhance_exp = 0})
	end

	return items
end

function QEHelper:getHeroGemstones(setId, breakthrough, strength)
	if setId == nil then
		return {}
	else
		local db = QStaticDatabase:sharedDatabase()
		local config = db:getGemstoneSuitEffectBySuitId(setId)
		local items = db:filterNoneArrayTableByProperty("item", "gemstone_set_index", setId)
		local gems = {}
		for _, item in ipairs(items) do
			gems[#gems + 1] = {itemId = item.id, level = math.max(strength, 1), craftLevel = math.max(breakthrough, 0)}
		end
		return gems
	end
end

function QEHelper:getHeroSkills(heroId, heroLevel, breakthrough, isMaxLevel)
	local skills = {}
	if heroId == nil or breakthrough == nil then
		return skills
	end

	local db = QStaticDatabase:sharedDatabase()

	local breakThroughHeroInfo = db:getBreakthroughHeroByActorId(heroId)
	if breakThroughHeroInfo == nil then
		return skills
	end

	if heroLevel == nil or heroLevel < 1 then
		heroLevel = 1
	end

	if isMaxLevel == nil then
		isMaxLevel = true 
	end

	if breakthrough < 0 then
		breakthrough = 0
	end

	local skillIds = {}
	for i = 0, breakthrough do
		local info = db:getBreakthroughHeroByHeroActorLevel(heroId, i)
		local skill_id
		if info.skill_id_1 ~= nil then
			skill_id = db:getSkillByActorAndSlot(heroId, info.skill_id_1)
			if skill_id then
				table.insert(skillIds, skill_id)
			end
		end
		if info.skill_id_2 ~= nil then
			skill_id = db:getSkillByActorAndSlot(heroId, info.skill_id_2)
			if skill_id then
				table.insert(skillIds, skill_id)
			end
		end
		if info.skill_id_3 ~= nil then
			skill_id = db:getSkillByActorAndSlot(heroId, info.skill_id_3)
			if skill_id then
				table.insert(skillIds, skill_id)
			end
		end
		if info.skill_id_4 ~= nil then
			skill_id = db:getSkillByActorAndSlot(heroId, info.skill_id_4)
			if skill_id then
				table.insert(skillIds, skill_id)
			end
		end
	end

	for _, skillId in pairs(skillIds) do
		local level = 1
		local available_level = nil
		while true do
			local skill_data = db:getSkillDataByIdAndLevel_Strict(skillId, level)
			if skill_data == nil or skill_data.hero_level > heroLevel then
				if skill_data == nil and level == 1 then
					assert(false, "invalid skill id:" .. skillId)
				end
				break
			else
				available_level = level
				level = level + 1
			end
		end
		level = available_level
		if level ~= nil then
			if level > 1 and isMaxLevel ~= true then
				level = math.ceil(level * 0.5)
			end

			local skill_data = db:getSkillDataByIdAndLevel_Strict(skillId, level)
			if skill_data ~= nil then
				table.insert(skills, tostring(skillId) .. "," .. tostring(level))
			end
		end
	end

	return skills
end

return QEHelper