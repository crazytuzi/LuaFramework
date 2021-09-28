-- Filename: HeroFightForce.lua
-- Author: fang
-- Date: 2013-09-13
-- Purpose: 该文件用于: 武将战斗力计算

module("HeroFightForce", package.seeall)

-- 0: 打开武将原始数据模块
require "script/model/hero/HeroModel"
-- 1: 打开武将属性数据表
require "db/DB_Heroes"
-- 2: 打开连携属性数据表
require "db/DB_Union_profit"
-- 3: 打开觉醒属性数据表
require "db/DB_Awake_ability"
-- 4: 打开装备属性数据表
require "db/DB_Item_arm"
-- 5: 打开名将属性数据表
require "script/ui/star/StarUtil"
-- 6: 打开宠物属性数据表
require "script/ui/pet/PetUtil"
-- 7: 打开宝物属性数据表
require "db/DB_Item_treasure"
-- 8: 套装数据表
require "db/DB_Suit"
-- 打开判断武将是否在阵上的方法库 HeroPublicLua
require "script/ui/hero/HeroPublicLua"

-- 天命系统
require "script/ui/destiny/DestinyData"

-- 攻防属性计算公式
-- 计算攻防属性值方法
local m_hp=1  				-- 生命
local m_physicalAttack=2 		-- 物理攻击(deprecated)
local m_magicAttack=3			-- 法术攻击(deprecated)
local m_physicalDefend=4		-- 物理防御
local m_magicDefend=5			-- 法术防御
local m_command=6				-- 统帅
local m_strength=7			-- 武力
local m_intelligence=8		-- 智力
local m_generalAttack=9		-- 通用攻击
-- 类型属性影射表
local _attributesMap = {
	{1, 11, "hp", "baseLife", "lifePL"},						
	{2, 12, "deprecated", "deprecated", "deprecated"},
	{3, 13, "deprecated", "deprecated", "deprecated"},
	{4, 14, "physical_defend", "basePhyDef", "phyDefPL"},	
	{5, 15, "magic_defend", "baseMagDef", "magDefPL"},	
	{6, 16, "command", "XXXXXX", "XXXXXX"},
	{7, 17, "strength", "XXXXXX", "XXXXXX"},
	{8, 18, "intelligence", "XXXXXX", "XXXXXX"},
	{9, 19, "general_attack", "baseGenAtt", "genAttPL"},
}

-- 武将本身基础值
function getHeroValue(tParam)
-- 返回值，初始化为0
	local nBaseValue=0
	local nPercentValue=0
	local db_hero = tParam.db_hero
	-- 武将进阶次数
	local evolve_level = tonumber(tParam.evolve_level)
	local nHeroLevel = tonumber(tParam.level)
-- 进阶基础值系数 advanced_base_coefficient
-- 武将基础通用攻击 base_general_attack
-- 进阶初始等级 advanced_begin_lv
-- 进阶间隔等级 advanced_interval_lv
	local map=tParam.map
	local base = 0
	if db_hero["base_"..map[3]] then
		base = db_hero["base_"..map[3]]
	end
	local grow=0
	if db_hero[map[3].."_grow"] then
		grow = db_hero[map[3].."_grow"]
	end
	nBaseValue = (base*(1+db_hero.advanced_base_coefficient*evolve_level/10000))
		+ grow*evolve_level/200*((db_hero.advanced_begin_lv-1)*2+ db_hero.advanced_interval_lv*(evolve_level-1))
		+ (nHeroLevel-1)*grow/100

	nBaseValue = math.floor(nBaseValue)

	return nBaseValue, nPercentValue
end

-- 装备，连携(必须在阵上才有加成), 其它系统都有加成
-- 连携属性(union_profit)提供的GetLocalizeStringBy("key_1241")，GetLocalizeStringBy("key_1700")
function getUnionProfitValue(tParam)
	local nBaseValue = 0
	local nPercentValue = 0
	
	local db_hero = DB_Heroes.getDataById(tParam.db_hero.id)
	local map = tParam.map
	-- 判断是否存在连携属性，如果不存在则直接返回0
	if db_hero.link_group1 == nil then
		return nBaseValue, nPercentValue
	end
	local arrUnionIds = string.split(db_hero.link_group1, ",")
	for i=1, #arrUnionIds do
		local unionId = arrUnionIds[i]
		local data = DB_Union_profit.getDataById(unionId)
		-- 判断生效条件
		local bIsValid = true
		-- 判断连携物品ID组
		local card_ids = string.split(data.union_card_ids, ",")
		for i=1, #card_ids do
			local type_htid = string.split(card_ids[i], "|")
			local eUnionType = tonumber(type_htid[1])
			-- 卡牌连携
			if eUnionType == 1 then
				-- 0默认为主角
				if tonumber(type_htid[2]) == 0 then
					if not (HeroPublicLua.isBusyWithHtid(20001) or HeroPublicLua.isBusyWithHtid(20002)) then
						bIsValid = false
						break
					end
				elseif not HeroPublicLua.isBusyWithHtid(type_htid[2]) and not HeroPublicLua.isOnLittleFriendBy(type_htid[2]) then
					bIsValid = false
					break
				end
			-- 物品连携
			elseif eUnionType == 2 then
				bIsValid = HeroModel.checkTreasureStatus(tParam.hid, type_htid[2])
				if not bIsValid then
					bIsValid = HeroModel.checkEquipStatus(tParam.hid, type_htid[2])
				end
				if not bIsValid then
					break
				end
			-- 战马连携
			elseif eUnionType == 3 then
				local heroHorseQuality = HeroModel.getHorseQuality(tParam.hid)
				if(tonumber(heroHorseQuality) ~= tonumber(type_htid[2])) then
					bIsValid = false
				end
			elseif eUnionType == 4 then
				local heroHorseQuality = HeroModel.getBookQuality(tParam.hid)
				if(tonumber(heroHorseQuality) ~= tonumber(type_htid[2])) then
					bIsValid = false
				end
			end
		end
		-- 判断名将的好感度条件
		if bIsValid then
			local sUnionAttrStarLv = data.union_arribute_starlv
			if sUnionAttrStarLv then
				local array = string.split(sUnionAttrStarLv, "|")
				local starId = array[1]
				local nNeedLv = array[2]
				require "script/ui/star/StarUtil"
				local nRealLv = StarUtil.getStarLevelBySid(starId)
				if tonumber(nRealLv) < tonumber(nNeedLv) then
					bIsValid = false
				end
			end
		end
		-- 如果生效条件成立，则读取相应基础值和加成值百分比
		if bIsValid then
			-- union_arribute_ids, union_arribute_nums(均为字符串数组, ","分隔)
			local ids = string.split(data.union_arribute_ids, ",")
			local nums = string.split(data.union_arribute_nums, ",")
			for i=1, #ids do
				if tonumber(ids[i]) == map[1] then
					nBaseValue = nBaseValue + tonumber(nums[i])
					break
				end
			end
			for i=1, #ids do
				if tonumber(ids[i]) == map[2] then
					nPercentValue = nPercentValue + tonumber(nums[i])
					break
				end
			end
		end
	end
-- 返回连携属性加成的基础值、百分比值
	return nBaseValue, nPercentValue
end

function getArmValue(tParam)
	local nRetValue = 0
	local nPercentValue = 0
	local tArrHeroes = HeroModel.getAllHeroes()

	local map=tParam.map
	local arms = tArrHeroes[tostring(tParam.hid)].equip.arming
	local bArrSuitStatus={}
	for k, v in pairs(arms) do
		local equiqAttackValue = 0
		if (type(v) == "table") then
			-- 武将装备(item_arm).基础法术攻击
			local equiqAttr = DB_Item_arm.getDataById(v.item_template_id)
			-- 装备”基础通用攻击“
			if equiqAttr[map[4]] then
				equiqAttackValue = equiqAttr[map[4]]
			end
			-- 装备等级
			local level = tonumber(v.va_item_text.armReinforceLevel)
			local percent = 0
			if equiqAttr[map[5]] then
				percent = equiqAttr[map[5]]
			end
			equiqAttackValue = equiqAttackValue + level * percent/100
			-- 套装处理
			if equiqAttr.jobLimit and equiqAttr.jobLimit>0 and bArrSuitStatus[equiqAttr.jobLimit] == nil then
				local db_suit = DB_Suit.getDataById(equiqAttr.jobLimit)
				local arrSuitItems = string.split(db_suit.suit_items, ",")
				local lock_num=1
				for i=1, #arrSuitItems do
					if v.item_template_id ~= arrSuitItems[i] then
						for kk, vv in pairs(arms) do
							if vv.item_template_id == arrSuitItems[i] then
								lock_num = lock_num + 1
							end
						end
					end
				end
				for ii=2, lock_num do 
					local astAttr = db_suit["astAttr"..(ii-1)]
					if astAttr then
						local typeValues = string.split(astAttr, ",")
						for i=1, #typeValues do
							local data = string.split(typeValues[i], "|")
							local nType = tonumber(data[1])
							local nValue = tonumber(data[2])
							if map[1] == nType then
								nRetValue = nRetValue + nValue 
							elseif map[2] == nType then
								nPercentValue = nPercentValue + nValue
							end

						end
					end
				end
				bArrSuitStatus[equiqAttr.jobLimit] = true
			end
			-- 装备潜能加成值
			local armPotence = v.va_item_text.armPotence
			if armPotence ~= nil then
				local base = armPotence[tostring(map[1])]
				if base ~= nil then
					nRetValue = nRetValue + tonumber(base)
				end
				local percent = armPotence[tostring(map[2])]
				if percent ~= nil then
					nPercentValue = nPercentValue + tonumber(percent)
				end
			end
		end
		nRetValue = nRetValue + equiqAttackValue
	end
	-- 时装系统战斗力加成
	local dress = tArrHeroes[tostring(tParam.hid)].equip.dress
	for k, v in pairs(dress) do
		if type(v) =="table" then
			require "db/DB_Item_dress"
			local db = DB_Item_dress.getDataById(v.item_template_id)
			if db then
				local baseAffixes = string.split(db.baseAffix, ",")
				for i=1, #baseAffixes do
					local item = string.split(baseAffixes[i], "|")
					if tonumber(item[1]) == map[1] then
						nRetValue = nRetValue + tonumber(item[2])
					end
				end
				local growAffixes = string.split(db.growAffix, ",")
				for i=1, #growAffixes do
					local item = string.split(growAffixes[i], "|")
					if tonumber(item[1]) == map[1] then
						nRetValue = nRetValue + tonumber(item[2]) * tonumber(v.va_item_text.dressLevel)
					end
				end
			end
		end
	end
	-- 战魂系统战斗力加成
	local nTmpRetValue, nTmpPercentValue = getFightSoulValue(tParam)
	nRetValue = nRetValue + nTmpRetValue
	nPercentValue = nPercentValue + nTmpPercentValue

	return nRetValue, nPercentValue
end

-- 战魂系统战斗力加成
function getFightSoulValue( tParam )
	local nRetValue = 0
	local nPercentValue = 0
	local tArrHeroes = HeroModel.getAllHeroes()

	local map=tParam.map

	local tFightSoul = tArrHeroes[tostring(tParam.hid)].equip.fightSoul
	if tFightSoul == nil then
		tFightSoul = {}
	end
	for k, v in pairs(tFightSoul) do
		if type(v) =="table" then
			require "db/DB_Item_fightsoul"
			local db = DB_Item_fightsoul.getDataById(v.item_template_id)
			local baseAtts = string.split(db.baseAtt, ",")
			local growAtts = string.split(db.growAtt, ",")
			for i=1, #baseAtts do
				local baseItems = string.split(baseAtts[i], "|")
				local growItems = string.split(growAtts[i], "|")
				if tonumber(baseItems[1]) == map[1] then
					nRetValue = nRetValue + tonumber(baseItems[2]) + tonumber(growItems[2]) * tonumber(v.va_item_text.fsLevel)
				end
			end
		end
	end
	return nRetValue, nPercentValue
end

-- 唤醒加成
function getAwakeValue(tParam)
	local nBaseValue=0
	local nPercentValue=0
	local db_hero = tParam.db_hero
	local map = tParam.map

	local arrAwakeId = nil
	if db_hero.awake_id then
		arrAwakeId = string.split(db_hero.awake_id, ",")
	end
	local arrGrowAwakeId = nil
	if db_hero.grow_awake_id then
		arrGrowAwakeId = string.split(db_hero.grow_awake_id, ",")
	end
-- 如果存在天赋ID
	local tAwakes = {}
	if arrAwakeId then
		for i=1, #arrAwakeId do
			tAwakes[#tAwakes+1] = {}
			local awake =  tAwakes[#tAwakes]
			awake.id = arrAwakeId[i]
			awake.level = 0
			awake.evolve_level = 0
		end
	end
	printTable("arrGrowAwakeId", arrGrowAwakeId)
	if arrGrowAwakeId then
		for i=1, #arrGrowAwakeId do
			
			tAwakes[#tAwakes+1] = {}
			local awake =  tAwakes[#tAwakes]
			local levelAndId = string.split(arrGrowAwakeId[i], "|")
			local awkae_type = tonumber(levelAndId[1])
			
			if awkae_type == 1 then
				awake.id = tonumber(levelAndId[3])
				awake.level = tonumber(levelAndId[2])
				awake.evolve_level = 0
			elseif awkae_type == 2 then
				awake.id = tonumber(levelAndId[3])
				awake.evolve_level = tonumber(levelAndId[2])
				awake.level = 0
			else

			end
			printTable("levelAndId", levelAndId)
			printTable("arrGrowAwakeId[" .. i .. "]", arrGrowAwakeId[i])
		end
	end
	printTable("tAwakes", tAwakes)
	for i=1, #tAwakes do
		local v = tAwakes[i]
		local nMaxLevel = tonumber(tParam.level)
		local evolve_level = tonumber(tParam.evolve_level)
		if nMaxLevel >= v.level and evolve_level >= v.evolve_level then
			local db_awake=DB_Awake_ability.getDataById(v.id)
			-- attri_ids, attri_values 属性为数组
			local arrAttriIds = {}
			local arrAttriValues = {}
			if db_awake.attri_ids then
				arrAttriIds = string.split(db_awake.attri_ids, ",")
				arrAttriValues = string.split(db_awake.attri_values, ",")
			end
			for i=1, #arrAttriIds do
				local id = tonumber(arrAttriIds[i])
				if id == map[1] then
					nBaseValue = nBaseValue + tonumber(arrAttriValues[i])
				elseif id == map[2] then
					nPercentValue = nPercentValue + tonumber(arrAttriValues[i])
				end
			end
		end
	end

	return nBaseValue, nPercentValue
end

-- + 名将系统(star)提供的通用攻击基础值
function getStarValue(tParam)
	local nBaseValue=0
	local nPercentValue=0
	local tStarValue = StarUtil.getStarValueForSumFight()
	if not tStarValue then
		return 0, 0
	end
	local map = tParam.map
	if tStarValue[map[1]] then
		nBaseValue = tonumber(tStarValue[map[1]])
	end

	return nBaseValue, nPercentValue
end

-- + 名将成就系统提供的战斗力加成
function getSingleStarValue(tParam)
	local nBaseValue=0
	local nPercentValue=0
	local tStarValue = StarUtil.getSingleStarAddAbilityBy(tParam.htid)
	if not tStarValue then
		return 0, 0
	end
	local map = tParam.map
	if tStarValue[map[1]] then
		nBaseValue = tonumber(tStarValue[map[1]])
	end

	return nBaseValue, nPercentValue
end

 -- + 宠物系统(pet)提供的通用攻击基础值
 function getPetValue(tParam)
 	local nBaseValue=0
 	local nPercentValue=0

 	local tPetValue = PetUtil.getAllPetProperty()
 	local map = tParam.map
 	if map[1] == _attributesMap[1][1] then
 		nBaseValue = tPetValue.life
 	elseif map[1] == _attributesMap[4][1] then
 		nBaseValue = tPetValue.phyDef
 	elseif map[1] == _attributesMap[5][1] then
 		nBaseValue = tPetValue.magDef
 	elseif map[1] == _attributesMap[9][1] then
 		nBaseValue = tPetValue.att
 	end

 	return nBaseValue, nPercentValue
 end

-- + 宝物系统(treasure)提供的通用攻击基础值及百分比加成
function getTreasureValue(tParam)
	local nBaseValue=0
	local nPercentValue=0
	if not tParam.hid then
		return nBaseValue, nPercentValue
	end
	local map = tParam.map
	local hero_data = HeroModel.getHeroByHid(tParam.hid)
	local treasure = hero_data.equip.treasure

	if treasure and table.count(treasure) > 0 then
		for k, v in pairs(treasure) do
			if v.item_template_id then
				local db_data = DB_Item_treasure.getDataById(v.item_template_id)
				-- 宝物基础加成值 
				for i=1, 5 do
					local base = db_data["base_attr"..i]
					local typeValue = string.split(base, "|")
					local attrType = tonumber(typeValue[1])
					if attrType == map[1] then
						nBaseValue = nBaseValue + tonumber(typeValue[2])
						local grow = db_data["increase_attr"..i]
						local arr = string.split(grow, "|")
						nBaseValue = nBaseValue + tonumber(arr[2])*tonumber(v.va_item_text.treasureLevel)
						break
					elseif attrType == map[2] then
						nPercentValue = nPercentValue + tonumber(typeValue[2])
						local grow = db_data["increase_attr"..i]
						local arr = string.split(grow, "|")
						nPercentValue = nPercentValue + tonumber(arr[2])*tonumber(v.va_item_text.treasureLevel)
					end
				end
				-- 宝物等级解锁加成值
				local ext_active_arr = db_data.ext_active_arr
				local arrAttr = string.split(ext_active_arr, ",")
				for i=1, #arrAttr do
					local arrLevelMapValue = string.split(arrAttr[i], "|")
					local tmpMap = tonumber(arrLevelMapValue[2])
					if tonumber(v.va_item_text.treasureLevel) >= tonumber(arrLevelMapValue[1]) then
						if tmpMap == map[1] then
							nBaseValue = nBaseValue + tonumber(arrLevelMapValue[3])
						elseif tmpMap == map[2] then
							nPercentValue = nPercentValue + tonumber(arrLevelMapValue[3])
						end
					end
				end
				-- 计算宝物精炼系统加成值
				if v.va_item_text and v.va_item_text.treasureEvolve and tonumber(v.va_item_text.treasureEvolve) > 0 then
					require "script/ui/treasure/evolve/TreasureEvolveUtil"
					local daffix = TreasureEvolveUtil.getOldAffix(v.item_id)
					if daffix and daffix.affix then
						for i=1, #daffix.affix do
							if tonumber(daffix.affix[i].id) == map[1] then
								nBaseValue = nBaseValue + tonumber(daffix.affix[i].num)
							elseif tonumber(daffix.affix[i].id) == map[2] then
								nPercentValue = nPercentValue + tonumber(daffix.affix[i].num)
							end
						end
					end
				end
			end
		end
	end

	return nBaseValue, nPercentValue
end

-- 天命系统加成
function getDestinyAppend(tParam)
	return DestinyData.getDestinyAppend(tonumber(tParam.hid))
end

function getBaseValue(tParam)
	local nRetValue, nPercentValue
	local nTmpBaseValue, nTmpPercentValue

	nRetValue, nPercentValue = getHeroValue(tParam)
-- 	不在阵上的武将不存连携属性一说
	if tParam.isBusy then
		-- 2: 连携属性(union_profit)提供的（通用攻击基础值）
		nTmpBaseValue, nTmpPercentValue = getUnionProfitValue(tParam)
		nRetValue = nRetValue + nTmpBaseValue
		nPercentValue = nPercentValue + nTmpPercentValue
		-- 只有在阵上的武将才可能有装备基础攻击加成
		nTmpBaseValue, nTmpPercentValue = getArmValue(tParam)
		nRetValue = nRetValue + nTmpBaseValue
		nPercentValue = nPercentValue + nTmpPercentValue
	end
	-- 觉醒能力基础值及加成
	nTmpBaseValue, nTmpPercentValue = getAwakeValue(tParam)
	nRetValue = nRetValue + nTmpBaseValue
	nPercentValue = nPercentValue + nTmpPercentValue
	-- 名将基础值及加成
	nTmpBaseValue, nTmpPercentValue = getStarValue(tParam)
	nRetValue = nRetValue + nTmpBaseValue
	nPercentValue = nPercentValue + nTmpPercentValue
	-- 单个名将基础值及加成
	nTmpBaseValue, nTmpPercentValue = getSingleStarValue(tParam)
	nRetValue = nRetValue + nTmpBaseValue
	nPercentValue = nPercentValue + nTmpPercentValue
	-- -- 宠物基础值及加成
	-- nTmpBaseValue, nTmpPercentValue = getPetValue(tParam)
	-- nRetValue = nRetValue + nTmpBaseValue
	-- nPercentValue = nPercentValue + nTmpPercentValue

	-- 宝物基础值及加成
	nTmpBaseValue, nTmpPercentValue = getTreasureValue(tParam)
	nRetValue = nRetValue + nTmpBaseValue
	nPercentValue = nPercentValue + nTmpPercentValue

	return nRetValue, nPercentValue
end


function getAllForceValuesByHid(hid)
	require "script/model/hero/HeroModel"
	local hero_data = HeroModel.getHeroByHid(hid)

	return getAllForceValues(hero_data)
end

function getAllForceValues(tParam)
	local nAttackValue = 0
	local nBaseValue, nPercentValue

	if not (tParam and tParam.htid) then
		return {}
	end

	local b_awake_arg, p_awake_arg = awakeFight(tParam)
	--增加宠物战斗力计算
	local b_pet_arg, p_pet_arg= petFight(tRetValue)
	-- 天命系统加成
	local tDestinyValue = { lifeAppend=0, commandAppend=0, strengthAppend=0, intelligenceAppend=0, generalAttackAppend=0, magicDefendAppend=0, physicalDefendAppend=0, physicalAttackAppend=0, magicAttackAppend=0}
	if tParam and tParam.hid and HeroModel.isNecessaryHeroByHid(tParam.hid) then
		tDestinyValue = getDestinyAppend(tParam)
		if tDestinyValue.physicalAttackAppend == nil then
			tDestinyValue.physicalAttackAppend = 0
		end
		if tDestinyValue.magicAttackAppend == nil then
			tDestinyValue.magicAttackAppend = 0
		end
	end

	-- 增加时装属性，给所有武将都加
	local b_dress_arg,p_dress_arg = dressAffix(tRetValue)
	for k,v in pairs(b_dress_arg) do
		b_awake_arg[k] = b_awake_arg[k] or 0
		b_awake_arg[k] = b_awake_arg[k] + v
	end
	for k,v in pairs(p_dress_arg) do
		p_awake_arg[k] = p_awake_arg[k] or 0
		p_awake_arg[k] = p_awake_arg[k] + v
	end

	--阵法战斗力
	local b_warf_arg,p_warf_arg = getWarfAffix(tParam)
	for k,v in pairs(b_warf_arg) do
		b_pet_arg[k] = b_pet_arg[k] or 0
		b_pet_arg[k] = b_pet_arg[k] + v
	end
	for k,v in pairs(p_warf_arg) do
		p_pet_arg[k] = p_pet_arg[k] or 0
		p_pet_arg[k] = p_pet_arg[k] + v
	end

	--神兵属性
	local b_godWeapon_arg,p_godWeapon_arg = getGodWeaponAffix(tParam)
	for k,v in pairs(b_godWeapon_arg) do
		b_pet_arg[k] = b_pet_arg[k] or 0
		b_pet_arg[k] = b_pet_arg[k] + v
	end
	for k,v in pairs(p_godWeapon_arg) do
		p_pet_arg[k] = p_pet_arg[k] or 0
		p_pet_arg[k] = p_pet_arg[k] + v
	end
	--神兵羁绊属性
	local b_godWeapon_union_arg,p_godWeapon_union_arg = getGodWeaponUnionAffix(tParam)
	for k,v in pairs(b_godWeapon_union_arg) do
		b_pet_arg[k] = b_pet_arg[k] or 0
		b_pet_arg[k] = b_pet_arg[k] + v
	end
	for k,v in pairs(p_godWeapon_union_arg) do
		p_pet_arg[k] = p_pet_arg[k] or 0
		p_pet_arg[k] = p_pet_arg[k] + v
	end
	--神兵录属性
	local b_godBook_union_arg,p_godBook_union_arg = getGodBookAffix(tParam)
	for k,v in pairs(b_godBook_union_arg) do
		b_pet_arg[k] = b_pet_arg[k] or 0
		b_pet_arg[k] = b_pet_arg[k] + v
	end
	for k,v in pairs(p_godBook_union_arg) do
		p_pet_arg[k] = p_pet_arg[k] or 0
		p_pet_arg[k] = p_pet_arg[k] + v
	end
	--第二套小伙伴
	local b_secFriend_arg, p_secFriend_arg = getSecondFriendAffix(tParam)
	for k,v in pairs(b_secFriend_arg) do
		b_pet_arg[k] = b_pet_arg[k] or 0
		b_pet_arg[k] = b_pet_arg[k] + v
	end
	for k,v in pairs(p_secFriend_arg) do
		p_pet_arg[k] = p_pet_arg[k] or 0
		p_pet_arg[k] = p_pet_arg[k] + v
	end
	-- printTable("b_pet_arg", b_warf_arg)
	-- printTable("b_pet_arg", p_warf_arg)

	-- printTable("b_pet_arg", b_pet_arg)
	-- printTable("b_pet_arg", p_warf_arg)

	local tArgs = {}
	tArgs = table.hcopy(tParam, tArgs)
	tArgs.db_hero = DB_Heroes.getDataById(tParam.htid)
	-- 判断该武将是否在阵上
	tArgs.isBusy = HeroPublicLua.isBusyWithHid(tParam.hid)
	local tRetValue={}

	-- 生命
	tArgs.map = _attributesMap[m_hp]
	nBaseValue, nPercentValue = getBaseValue(tArgs)
	nPercentValue = nPercentValue + p_awake_arg.life + p_pet_arg.life
	tRetValue.life = (nBaseValue + tDestinyValue.lifeAppend + (b_pet_arg.life or 0) + (b_awake_arg.life or 0))* (1+nPercentValue/10000)
	-- 统帅
	tArgs.map = _attributesMap[m_command]

	nBaseValue, nPercentValue =  getBaseValue(tArgs)
	nPercentValue = nPercentValue + p_awake_arg.command  + p_pet_arg.command
	tRetValue.command = math.floor((nBaseValue + tDestinyValue.commandAppend + (b_pet_arg.command or 0) + (b_awake_arg.command or 0))*(1+nPercentValue/10000))/100
	-- 武力
	tArgs.map = _attributesMap[m_strength]
	nBaseValue, nPercentValue =  getBaseValue(tArgs)
	nPercentValue = nPercentValue + p_awake_arg.strength + p_pet_arg.strength
	tRetValue.strength = math.floor((nBaseValue + tDestinyValue.strengthAppend + (b_pet_arg.strength or 0)+ (b_awake_arg.strength or 0))*(1+nPercentValue/10000))/100
	-- 智力
	tArgs.map = _attributesMap[m_intelligence]
	nBaseValue, nPercentValue =  getBaseValue(tArgs)
	nPercentValue = nPercentValue + p_awake_arg.intelligence + p_pet_arg.intelligence
	tRetValue.intelligence = math.floor((nBaseValue + tDestinyValue.intelligenceAppend + (b_pet_arg.intelligence or 0) + (b_awake_arg.intelligence or 0))*(1+nPercentValue/10000))/100
	-- 通用攻击
	tArgs.map = _attributesMap[m_generalAttack]
	nBaseValue, nPercentValue =  getBaseValue(tArgs)
	nPercentValue = nPercentValue + p_awake_arg.generalAttack + p_pet_arg.generalAttack
	tRetValue.generalAttack = math.floor((nBaseValue + tDestinyValue.generalAttackAppend + (b_pet_arg.generalAttack or 0) + (b_awake_arg.generalAttack or 0))*(1+nPercentValue/10000))
	-- 法防
	tArgs.map = _attributesMap[m_magicDefend]
	nBaseValue, nPercentValue =  getBaseValue(tArgs)
	nPercentValue = nPercentValue + p_awake_arg.magicDefend  + p_pet_arg.magicDefend
	tRetValue.magicDefend = math.floor((nBaseValue + tDestinyValue.magicDefendAppend + (b_pet_arg.magicDefend or 0) + (b_awake_arg.magicDefend or 0))*(1+nPercentValue/10000))
	-- 物防
	tArgs.map = _attributesMap[m_physicalDefend]
	nBaseValue, nPercentValue =  getBaseValue(tArgs)
	nPercentValue = nPercentValue + p_awake_arg.physicalDefend + p_pet_arg.physicalDefend
	tRetValue.physicalDefend = math.floor((nBaseValue + tDestinyValue.physicalDefendAppend + (b_pet_arg.physicalDefend or 0) + (b_awake_arg.physicalDefend or 0))*(1+nPercentValue/10000))
	-- 物攻
	tArgs.map = _attributesMap[m_physicalAttack]
	nBaseValue, nPercentValue =  getFightSoulValue(tArgs)
	nPercentValue = nPercentValue + p_awake_arg.physicalAttack + p_pet_arg.physicalAttack
	tRetValue.physicalAttack = math.floor((nBaseValue + tDestinyValue.physicalAttackAppend + (b_pet_arg.physicalAttack or 0) + (b_awake_arg.physicalAttack or 0))*(1+nPercentValue/10000))
	-- 法攻
	tArgs.map = _attributesMap[m_magicAttack]
	nBaseValue, nPercentValue =  getFightSoulValue(tArgs)
	nPercentValue = nPercentValue + p_awake_arg.magicAttack + p_pet_arg.magicAttack
	tRetValue.magicAttack = math.floor((nBaseValue + tDestinyValue.magicAttackAppend + (b_pet_arg.magicAttack or 0) + (b_awake_arg.magicAttack or 0))*(1+nPercentValue/10000))


	-- tRetValue = awakeFight(tRetValue, tParam)
	-- for k,v in pairs(b_awake_arg) do
	-- 	if(tRetValue[k] == nil)then
	-- 		tRetValue[k] = v
	-- 	else
	-- 		tRetValue[k] = tRetValue[k] + v
	-- 	end
	-- end

	tRetValue.life = math.floor(tRetValue.life*(1+(tRetValue.command-50)/100))
	-- 计算战斗力
	tRetValue.fightForce=tRetValue.generalAttack + tRetValue.magicDefend + tRetValue.physicalDefend + tRetValue.physicalAttack + tRetValue.magicAttack
	tRetValue.fightForce=tRetValue.fightForce + tRetValue.life/5 

	local vitalSum = (tRetValue.command+tRetValue.strength+tRetValue.intelligence)-150
	if vitalSum < 0 then
		vitalSum = 0
	end
	tRetValue.fightForce=tRetValue.fightForce+ vitalSum*10

	if tRetValue.fightForce < 5 then
		tRetValue.fightForce = 5
	end
	tRetValue.fightForce = tRetValue.fightForce
	tRetValue.vitalStat = tRetValue.fightForce

	for k, v in pairs(tRetValue) do
		tRetValue[k] = math.floor(v)
	end


	printTable("tRetValue", tRetValue)

	return tRetValue
end


local affix_map = {}
affix_map[1] = "life"
affix_map[2] = "physicalAttack"
affix_map[3] = "magicAttack"
affix_map[4] = "physicalDefend"
affix_map[5] = "magicDefend"
affix_map[6] = "command"
affix_map[7] = "strength"
affix_map[8] = "intelligence"
affix_map[9] = "generalAttack"


--add by lichenyang
function petFight( tAgrs )

	local b_args = {}
	local p_args = {life=0, command = 0, strength=0, intelligence=0, physicalAttack=0, magicAttack=0, physicalDefend=0, magicDefend=0, generalAttack=0}
	require "script/ui/pet/PetData"
	local affixs = PetData.getPetAffixValue()

	for k,v in pairs(affixs) do
		if(affix_map[tonumber(k)] ~= nil) then
			b_args[affix_map[tonumber(k)]] = tonumber(v)
		else
			if(tonumber(k) == 11)then
				p_args.life = tonumber(v)
			elseif(tonumber(k) == 12)then
				p_args.physicalAttack = tonumber(v)
			elseif(tonumber(k) == 13)then
				p_args.magicAttack = tonumber(v)
			elseif(tonumber(k) == 14)then
				p_args.physicalDefend = tonumber(v)
			elseif(tonumber(k) == 15)then
				p_args.magicDefend = tonumber(v)
			elseif(tonumber(k) == 19)then
				p_args.generalAttack = tonumber(v)
			end
		end
	end
	return b_args, p_args 

end


function awakeFight( tParam )

	local b_args = {}
	local p_args = {life=0, command = 0, strength=0, intelligence=0, physicalAttack=0, magicAttack=0, physicalDefend=0, magicDefend=0, generalAttack=0}
	require "script/model/hero/HeroModel"
	require "script/model/affix/HeroAffixModel"
	local affixs = HeroAffixModel.getHeroAwakenAffix(tParam.hid)

	for k,v in pairs(affixs) do
		if(affix_map[tonumber(k)] ~= nil) then
			b_args[affix_map[tonumber(k)]] = tonumber(v)
		else
			if(tonumber(k) == 11)then
				p_args.life = tonumber(v)
			elseif(tonumber(k) == 12)then
				p_args.physicalAttack = tonumber(v)
			elseif(tonumber(k) == 13)then
				p_args.magicAttack = tonumber(v)
			elseif(tonumber(k) == 14)then
				p_args.physicalDefend = tonumber(v)
			elseif(tonumber(k) == 15)then
				p_args.magicDefend = tonumber(v)
			elseif(tonumber(k) == 19)then
				p_args.generalAttack = tonumber(v)
			end
		end
	end
	return b_args, p_args 
end


function dressAffix( tParam )
	local b_args = {}
	local p_args = {life=0, command = 0, strength=0, intelligence=0, physicalAttack=0, magicAttack=0, physicalDefend=0, magicDefend=0, generalAttack=0}
	require "script/ui/dressRoom/DressRoomCache"
	local affixs = DressRoomCache.getExtenseAffixes()
	p_args.life = 0
	p_args.physicalAttack = 0
	p_args.magicAttack = 0
	p_args.physicalDefend = 0
	p_args.generalAttack = 0
	for k,v in pairs(affixs) do
		if(affix_map[tonumber(k)] ~= nil) then
			b_args[affix_map[tonumber(k)]] = (b_args[affix_map[tonumber(k)]]) or "0"
			v = v or "0"
			print("affix_map[tonumber(k)]", affix_map[tonumber(k)])
			print("b_args[affix_map[tonumber(k)]]", b_args[affix_map[tonumber(k)]])
			print("v ", v)
			b_args[affix_map[tonumber(k)]] =b_args[affix_map[tonumber(k)]] + tonumber(v)
		else
			if(tonumber(k) == 11)then
				p_args.life = p_args.life + tonumber(v)
			elseif(tonumber(k) == 12)then
				p_args.physicalAttack = p_args.physicalAttack + tonumber(v)
			elseif(tonumber(k) == 13)then
				p_args.magicAttack = p_args.magicAttack + tonumber(v)
			elseif(tonumber(k) == 14)then
				p_args.physicalDefend = p_args.physicalDefend + tonumber(v)
			elseif(tonumber(k) == 15)then
				p_args.magicDefend = p_args.magicDefend + tonumber(v)
			elseif(tonumber(k) == 19)then
				p_args.generalAttack = p_args.generalAttack + tonumber(v)
			end
		end
	end
	return b_args, p_args
end

--[[
	@des: 得到阵法属性
--]]
function getWarfAffix( tParam )
	local b_args = {}
	local p_args = {life=0, command = 0, strength=0, intelligence=0, physicalAttack=0, magicAttack=0, physicalDefend=0, magicDefend=0, generalAttack=0}

	--增加阵法属性
	require "script/ui/warcraft/WarcraftData"
	local warcraftAffix = WarcraftData.getAffixes()[tonumber(tParam.hid)] or {}
	for k,v in pairs(warcraftAffix) do
		if(affix_map[tonumber(k)] ~= nil) then
			b_args[affix_map[tonumber(k)]] = (b_args[affix_map[tonumber(k)]]) or "0"
			v = v or "0"
			print("affix_map[tonumber(k)]", affix_map[tonumber(k)])
			print("b_args[affix_map[tonumber(k)]]", b_args[affix_map[tonumber(k)]])
			print("v ", v)
			b_args[affix_map[tonumber(k)]] =b_args[affix_map[tonumber(k)]] + tonumber(v)
		else
			if(tonumber(k) == 11)then
				p_args.life = p_args.life + tonumber(v)
			elseif(tonumber(k) == 12)then
				p_args.physicalAttack = p_args.physicalAttack + tonumber(v)
			elseif(tonumber(k) == 13)then
				p_args.magicAttack = p_args.magicAttack + tonumber(v)
			elseif(tonumber(k) == 14)then
				p_args.physicalDefend = p_args.physicalDefend + tonumber(v)
			elseif(tonumber(k) == 15)then
				p_args.magicDefend = p_args.magicDefend + tonumber(v)
			elseif(tonumber(k) == 19)then
				p_args.generalAttack = p_args.generalAttack + tonumber(v)
			end
		end
	end
	return b_args, p_args 
end

--[[
	@des:神兵属性
--]]
function getGodWeaponAffix( tParam )
	local b_args = {}
	local p_args = {life=0, command = 0, strength=0, intelligence=0, physicalAttack=0, magicAttack=0, physicalDefend=0, magicDefend=0, generalAttack=0}

	require "script/ui/item/GodWeaponItemUtil"
	local godWeaponAffix = GodWeaponItemUtil.getGodWeaponFightScore(tonumber(tParam.hid))
	for k,v in pairs(godWeaponAffix) do
		if(affix_map[tonumber(k)] ~= nil) then
			b_args[affix_map[tonumber(k)]] = (b_args[affix_map[tonumber(k)]]) or "0"
			v = v or "0"
			b_args[affix_map[tonumber(k)]] =b_args[affix_map[tonumber(k)]] + tonumber(v)
		else
			if(tonumber(k) == 11)then
				p_args.life = p_args.life + tonumber(v)
			elseif(tonumber(k) == 12)then
				p_args.physicalAttack = p_args.physicalAttack + tonumber(v)
			elseif(tonumber(k) == 13)then
				p_args.magicAttack = p_args.magicAttack + tonumber(v)
			elseif(tonumber(k) == 14)then
				p_args.physicalDefend = p_args.physicalDefend + tonumber(v)
			elseif(tonumber(k) == 15)then
				p_args.magicDefend = p_args.magicDefend + tonumber(v)
			elseif(tonumber(k) == 19)then
				p_args.generalAttack = p_args.generalAttack + tonumber(v)
			end
		end
	end
	return b_args, p_args 
end

--[[
	@des:得到神兵羁绊属性
--]]
function getGodWeaponUnionAffix( tParam )
	local b_args = {}
	local p_args = {life=0, command = 0, strength=0, intelligence=0, physicalAttack=0, magicAttack=0, physicalDefend=0, magicDefend=0, generalAttack=0}

	require "script/ui/item/GodWeaponItemUtil"
	local godWeaponAffix = GodWeaponItemUtil.getGodWeaponUnionFightScore()[tonumber(tParam.hid)] or {}
	for k,v in pairs(godWeaponAffix) do
		if(affix_map[tonumber(k)] ~= nil) then
			b_args[affix_map[tonumber(k)]] = (b_args[affix_map[tonumber(k)]]) or "0"
			v = v or "0"
			b_args[affix_map[tonumber(k)]] =b_args[affix_map[tonumber(k)]] + tonumber(v)
		else
			if(tonumber(k) == 11)then
				p_args.life = p_args.life + tonumber(v)
			elseif(tonumber(k) == 12)then
				p_args.physicalAttack = p_args.physicalAttack + tonumber(v)
			elseif(tonumber(k) == 13)then
				p_args.magicAttack = p_args.magicAttack + tonumber(v)
			elseif(tonumber(k) == 14)then
				p_args.physicalDefend = p_args.physicalDefend + tonumber(v)
			elseif(tonumber(k) == 15)then
				p_args.magicDefend = p_args.magicDefend + tonumber(v)
			elseif(tonumber(k) == 19)then
				p_args.generalAttack = p_args.generalAttack + tonumber(v)
			end
		end
	end
	return b_args, p_args 
end

--[[
	@des:得到神兵录
--]]
function getGodBookAffix( tParam )
	local b_args = {}
	local p_args = {life=0, command = 0, strength=0, intelligence=0, physicalAttack=0, magicAttack=0, physicalDefend=0, magicDefend=0, generalAttack=0}

	require "script/ui/godweapon/GodWeaponData"
	local godWeaponAffix = GodWeaponData.getWeaponBookAtrr(tonumber(tParam.hid)) or {}
	printTable("getGodBookAffix", godWeaponAffix)
	for k,v in pairs(godWeaponAffix) do
		if(affix_map[tonumber(k)] ~= nil) then
			b_args[affix_map[tonumber(k)]] = (b_args[affix_map[tonumber(k)]]) or "0"
			v = v or "0"
			b_args[affix_map[tonumber(k)]] =b_args[affix_map[tonumber(k)]] + tonumber(v)
		else
			if(tonumber(k) == 11)then
				p_args.life = p_args.life + tonumber(v)
			elseif(tonumber(k) == 12)then
				p_args.physicalAttack = p_args.physicalAttack + tonumber(v)
			elseif(tonumber(k) == 13)then
				p_args.magicAttack = p_args.magicAttack + tonumber(v)
			elseif(tonumber(k) == 14)then
				p_args.physicalDefend = p_args.physicalDefend + tonumber(v)
			elseif(tonumber(k) == 15)then
				p_args.magicDefend = p_args.magicDefend + tonumber(v)
			elseif(tonumber(k) == 19)then
				p_args.generalAttack = p_args.generalAttack + tonumber(v)
			end
		end
	end
	return b_args, p_args 
end

--[[
	@des ：第二套小伙伴
--]]
function getSecondFriendAffix( tParam )
		--第二套小伙伴
	require "script/model/affix/SecondFriendAffixModel"
	local secondFriendAffix = SecondFriendAffixModel.getAffixByHid(tonumber(tParam.hid)) or {}

	local b_args = {}
	local p_args = {life=0, command = 0, strength=0, intelligence=0, physicalAttack=0, magicAttack=0, physicalDefend=0, magicDefend=0, generalAttack=0}
	for k,v in pairs(secondFriendAffix) do
		if(affix_map[tonumber(k)] ~= nil) then
			b_args[affix_map[tonumber(k)]] = (b_args[affix_map[tonumber(k)]]) or "0"
			v = v or "0"
			b_args[affix_map[tonumber(k)]] =b_args[affix_map[tonumber(k)]] + tonumber(v)
		else
			if(tonumber(k) == 11)then
				p_args.life = p_args.life + tonumber(v)
			elseif(tonumber(k) == 12)then
				p_args.physicalAttack = p_args.physicalAttack + tonumber(v)
			elseif(tonumber(k) == 13)then
				p_args.magicAttack = p_args.magicAttack + tonumber(v)
			elseif(tonumber(k) == 14)then
				p_args.physicalDefend = p_args.physicalDefend + tonumber(v)
			elseif(tonumber(k) == 15)then
				p_args.magicDefend = p_args.magicDefend + tonumber(v)
			elseif(tonumber(k) == 19)then
				p_args.generalAttack = p_args.generalAttack + tonumber(v)
			end
		end
	end
	return b_args, p_args 
end






