-- Filename：	DevelopData.lua
-- Author：		Zhang Zihang
-- Date：		2014-9-9
-- Purpose：		武将进化数据层

module ("DevelopData", package.seeall)
require "script/model/hero/FightForceModel"
-------------------------------------[[ 进化界面 ]] ----------------------------------------
kItemTag = 1
kHeroTag = 2

local _curHeroInfo = nil
local _curDevelopInfo = nil
local _curCostResource = nil
local _openOrangeHeroIds = nil
local _openRedHeroIds = nil

-------------------------------------[[ 进化预览 ]] ----------------------------------------
--[[
	@des 	:根据国家返回橙将信息
	@param 	:国家id
			 魏1 蜀2 吴3 群4
	@return :该国的武将数据
--]]
function getOrangeHeroByCountry(p_countryId)
	require "db/DB_Normal_config"

	--配置信息
	local configInfo = DB_Normal_config.getDataById(1)
	--下标信息
	local keyString = "star6heroesPreviewCard" .. p_countryId
	local heroIdString = configInfo[keyString]

	return string.split(heroIdString,",")
end
--[[
	@des 	:根据国家返回红信息
	@param 	:国家id
			 魏1 蜀2 吴3 群4
	@return :该国的武将数据
--]]
function getRedHeroByCountry(p_countryId)
	require "db/DB_Normal_config"

	--配置信息
	local configInfo = DB_Normal_config.getDataById(1)
	--下标信息
	local keyString = "star7heroesPreviewCard" .. p_countryId
	local heroIdString = configInfo[keyString]

	return string.split(heroIdString,",")
end
-------------------------------------[[ 消耗预览 ]] ----------------------------------------
--[[
	@des 	:根据国家和武将星级信息
	@param 	:国家id
			 魏1 蜀2 吴3 群4
	@return :该国的武将数据
--]]
function getCostHeroByCountry(p_countryId)
	require "db/DB_Normal_config"

	--配置信息
	local configInfo = DB_Normal_config.getDataById(1)
	--下标信息
	local keyString = "star6heroesPreviewCard" .. p_countryId
	local heroIdString = configInfo[keyString]

	return string.split(heroIdString,",")
end
-------------------------------------[[ 进化界面 ]] ----------------------------------------
--[[
	@des 	:初始化进化界面数据
	@param 	:
	@return :
--]]
function initDevelopData( p_hid )
	_curHeroInfo = nil
	_curDevelopInfo = nil
	_curCostResource = nil
	
	if p_hid == nil then
		return
	end
	setDevelopData(p_hid)
end

--[[
	@des 	:设置进化界面数据
	@param 	:
	@return :
--]]
function setDevelopData( p_hid )
	setCurHeroInfo(p_hid)

	setCurDevelopInfo(p_hid)

	setCurCostResource(_curHeroInfo.htid)
end

--[[
	@des 	:根据hid设置当前英雄信息
	@param 	:
	@return :
--]]
function setCurHeroInfo( p_hid )
	p_hid = tonumber(p_hid)
	if _curHeroInfo ~= nil and tonumber(_curHeroInfo.hid) == p_hid then
		return
	end

	_curHeroInfo = getHeroInfo(p_hid)
end

--[[
	@des 	:获取当前英雄信息
	@param 	:
	@return :
--]]
function getCurHeroInfo( ... )
	return _curHeroInfo
end

--[[
	@des 	:根据hid获取英雄信息
	@param 	:
	@return :返回英雄的详细信息
	{
		hid = int
		htid = int
		--dressId = int
		aptitude = int
		heroName = string
		evolveLevel = int
		heroLevel = int
		normalSkill = {
			skillName = string
			skillDesc = string
		}
		angerSkill = {
			skillName = string
			skillDesc = string
		}
		command = int
		strength = int
		intelligence = int
	}
--]]
require "script/model/utils/HeroUtil"

require "db/skill"
function getHeroInfo( p_hid )
	p_hid = tonumber(p_hid)

	local heroData = HeroUtil.getHeroInfoByHid(p_hid)
	if heroData == nil then
		return nil
	end

	local heroInfo = {}
	--hid
	heroInfo.hid = p_hid
	--htid
	heroInfo.htid = tonumber(heroData.htid)
	-- --dressId
	-- heroInfo.dressId = tonumber(heroData.dress[1])
	--名字
	heroInfo.heroName = heroData.localInfo.name
	--星级
	heroInfo.star_lv = heroData.localInfo.star_lv
	--资质
	heroInfo.aptitude = heroData.localInfo.heroQuality
	--进阶等级
	heroInfo.evolveLevel = tonumber(heroData.evolve_level)
	--英雄等级
	heroInfo.heroLevel = tonumber(heroData.level)
	--普通技能
	local normalSkill = skill.getDataById(heroData.localInfo.normal_attack)
	heroInfo.normalSkill = {}
	heroInfo.normalSkill.skillName = normalSkill.name
	heroInfo.normalSkill.skillDesc = normalSkill.des
	--怒气技能
	local angerSkill = skill.getDataById(heroData.localInfo.rage_skill_attack)
	heroInfo.angerSkill = {}
	heroInfo.angerSkill.skillName = angerSkill.name
	heroInfo.angerSkill.skillDesc = angerSkill.des

	-- local fightForceData = HeroFightForce.getAllForceValuesByHid(p_hid)
	-- --统帅
	-- heroInfo.command = tonumber(fightForceData.command)
	-- --武力
	-- heroInfo.strength = tonumber(fightForceData.strength)
	-- --智慧  
	-- heroInfo.intelligence = tonumber(fightForceData.intelligence)

	local fightForceData = FightForceModel.getHeroDisplayAffix(p_hid)
	--统帅
	heroInfo.command = tonumber(fightForceData[6])
	--武力
	heroInfo.strength = tonumber(fightForceData[7])
	--智慧
	heroInfo.intelligence = tonumber(fightForceData[8])

	return heroInfo
end

--[[
	@des 	:根据htid设置对应的进化配置信息
	@param 	:
	@return :
--]]
function setCurDevelopInfo( p_hid )
	p_hid = tonumber(p_hid)
	if _curDevelopInfo ~= nil and tonumber(_curDevelopInfo.hid) == p_hid then
		return
	end
	_curDevelopInfo = getDevelopInfo(p_hid)
end

--[[
	@des 	:获取当前的进化配置信息
	@param 	:
	@return :
--]]
function getCurDevelopInfo( ... )
	return _curDevelopInfo
end

--[[
	@des 	:根据htid获取对应的进化配置信息
	@param 	:
	@return :返回进化后英雄的详细信息
	{
		hid = int
		htid = int
		--dressId = int
		aptitude = int
		heroName = string
		evolveLevel = int
		heroLevel = int
		normalSkill = {
			skillName = string
			skillDesc = string
		}
		angerSkill = {
			skillName = string
			skillDesc = string
		}
		command = int
		strength = int
		intelligence = int
	}
--]]
require "db/DB_Heroes"
function getDevelopInfo( p_hid )
	p_hid = tonumber(p_hid)
	
	local beforeDevelopHeroData = _curHeroInfo or getHeroInfo(p_hid)
	--英雄背包中没有该英雄
	if beforeDevelopHeroData == nil then
		return nil
	end
	-- print("getDevelopInfo")
	-- print_t(beforeDevelopHeroData)

	local developConfig = getConfigInfo(beforeDevelopHeroData.htid)
	--该英雄没有开启进化橙卡功能
	if developConfig == nil then
		return nil
	end

	local afterDevelopHeroData = DB_Heroes.getDataById(developConfig.afteRevolveTid)

	local developInfo = {}
	--进化前的hid
	developInfo.hid = beforeDevelopHeroData.hid
	--进化后的htid
	developInfo.htid = developConfig.afteRevolveTid
	-- --进化后的dressId
	-- developInfo.dressId = beforeDevelopHeroData.dressId
	--进化后的名字
	developInfo.heroName = afterDevelopHeroData.name
	--进化后的星级
	developInfo.star_lv = afterDevelopHeroData.star_lv
	--进化后的资质
	developInfo.aptitude = afterDevelopHeroData.heroQuality
	--进化后的进阶等级
	--developInfo.evolveLevel = beforeDevelopHeroData.evolveLevel
	developInfo.evolveLevel = 0
	--进化后的英雄等级
	developInfo.heroLevel = beforeDevelopHeroData.heroLevel
	--进化后的普通技能
	local normalSkill = skill.getDataById(afterDevelopHeroData.normal_attack)
	developInfo.normalSkill = {}
	developInfo.normalSkill.skillName = normalSkill.name
	developInfo.normalSkill.skillDesc = normalSkill.des
	--进化后的怒气技能
	local angerSkill = skill.getDataById(afterDevelopHeroData.rage_skill_attack)
	developInfo.angerSkill = {}
	developInfo.angerSkill.skillName = angerSkill.name
	developInfo.angerSkill.skillDesc = angerSkill.des

	local heroData = {}
	table.hcopy(HeroModel.getHeroByHid(developInfo.hid), heroData)
	heroData.htid = developInfo.htid
	heroData.evolveLevel = 0
	local fightForceData = FightForceModel.getHeroDisplayAffixByHeroInfo(heroData)
	--统帅
	developInfo.command = tonumber(fightForceData[6])
	--武力
	developInfo.strength = tonumber(fightForceData[7])
	--智慧
	developInfo.intelligence = tonumber(fightForceData[8])
	-- print("afterDevelopHeroData")
	-- print_t(developInfo)
	return developInfo
end

--[[
	@des 	:根据进化前htid获取对应的进化配置信息
	@param 	:
	@return :
--]]
require "db/DB_Hero_evolve"
-- function getConfigInfo( p_htid )
-- 	p_htid = tonumber(p_htid)
-- 	local data = nil
-- 	local temp = nil
-- 	for k,v in pairs(DB_Hero_evolve.Hero_evolve) do
-- 		temp = DB_Hero_evolve.getDataById(v[1])
-- 		if p_htid == temp.needHeroId then
-- 			data = temp
-- 			break
-- 		end
-- 	end
-- 	return data
-- end
function getConfigInfo( p_htid )
	p_htid = tonumber(p_htid)
	local data = nil
	print("getConfigInfo p_htid",p_htid)
	local temp = DB_Heroes.getDataById(p_htid)
	print("temp.evolveId",temp.evolveId)
	if temp ~= nil and temp.evolveId ~= nil then
		data = DB_Hero_evolve.getDataById(temp.evolveId)
	end
	return data
end

--[[
	@des 	:获取开放的所有橙卡tid对应的紫卡tid
	@param 	:
	@return :
--]]
function getOpenOrangeHtid( ... )
	if _openOrangeHeroIds ~= nil then
		return _openOrangeHeroIds
	end
	_openOrangeHeroIds = {}
	for countryId = 1,4 do
		_openOrangeHeroIds[countryId] = getOrangeHeroByCountry(countryId)
	end
	return _openOrangeHeroIds
end
--[[
	@des 	:获取开放的所有红卡tid对应的橙卡tid
	@param 	:
	@return :
--]]
function getOpenRedHtid( ... )
	if _openRedHeroIds ~= nil then
		return _openRedHeroIds
	end
	_openRedHeroIds = {}
	for countryId = 1,4 do
		_openRedHeroIds[countryId] = getRedHeroByCountry(countryId)
	end
	return _openRedHeroIds
end
--[[
	@des 	:根据htid判断是否开启进化
	@param 	:
	@return :
--]]
function doOpenDevelopByHtid( p_htid )
	local openRedHeroIds = getOpenRedHtid()
	local openOrangeHeroIds = getOpenOrangeHtid()
	local configInfo = getConfigInfo( p_htid )
	local temp = DB_Heroes.getDataById(p_htid)
	local ret = false
	if(temp.star_lv == 5)then
	   if not table.isEmpty(openOrangeHeroIds) and not table.isEmpty(openOrangeHeroIds[temp.country]) and
		   not table.isEmpty(configInfo) then
			for k,v in ipairs(openOrangeHeroIds[temp.country]) do
				if tonumber(v) == tonumber(configInfo.afteRevolveTid) then
					ret = true
					break
				end
			end
		end
		--上面是判断紫卡
	elseif (temp.star_lv == 6)then
	   if not table.isEmpty(openRedHeroIds) and not table.isEmpty(openRedHeroIds[temp.country]) and
		   not table.isEmpty(configInfo) then
		   --print("configInfo.afteRevolveTid",configInfo.afteRevolveTid)
			for k,v in ipairs(openRedHeroIds[temp.country]) do
				if tonumber(v) == tonumber(configInfo.afteRevolveTid) then
					ret = true
					break
				end
			end
		end
		--上面是判断橙卡
	end

	-- local ret = false
	-- if getConfigInfo( p_htid ) ~= nil then
	-- 	ret = true
	-- end
	return ret
end

--[[
	@des 	:根据hid判断是否开启进化
	@param 	:
	@return :
--]]
require "script/ui/rechargeActive/ActiveCache"
function doOpenDevelopByHid( p_hid )
	local heroData = HeroUtil.getHeroInfoByHid(p_hid)
	local ret = false
	--当未取消或者替换变身的武将时不能进化
	if DataCache.getSwitchNodeState(ksHeroDevelop,false) and heroData.localInfo.star_lv == 5 and tonumber(heroData.evolve_level) == 7
		and doOpenDevelopByHtid(heroData.htid) and not ActiveCache.isUnhandleTransfer(p_hid) then
		ret =true
		--这是紫卡的条件
	elseif DataCache.getSwitchNodeState(ksSwitchRedHero,false) and heroData.localInfo.star_lv == 6 and tonumber(heroData.evolve_level) == 5
		and doOpenDevelopByHtid(heroData.htid) and not ActiveCache.isUnhandleTransfer(p_hid) then
		ret =true
		--这是橙卡的条件
	end
	return ret
end

--[[
	@des 	:根据htid设置当前进化需要消耗的资源信息
	@param 	:
	@return :
--]]
function setCurCostResource( p_htid )
	p_htid = tonumber(p_htid)
	if _curCostResource ~= nil and _curCostResource.template.needHeroId == p_htid then
		return
	end

	_curCostResource = getCostResource(p_htid)
end

--[[
	@des 	:获取当前进化需要消耗的资源信息
	@param 	:
	@return :
--]]
function getCurCostResource( ... )
	return _curCostResource
end

--[[
	@desc :	根据htid获取进化需要消耗的资源信息
	@param:	
	@ret  :	{
		template = table
		cost = {
			{
				type = kItemTag   --物品
				id = int
				needNum = int
				hasNum = int
				name = string
				nameColor = ccc3
			}
			{
				type = kItemTag   --英雄
				id = int
				needNum = int
				hasNum = int
				name = string
				nameColor = ccc3

				needLevel = int
				heroes = table
			}
		}
	}
--]]
require "script/ui/item/ItemUtil"
function getCostResource( p_htid )
	p_htid = tonumber(p_htid)
	local template = getConfigInfo(p_htid)
	local resource = {}
	resource.template = template
	resource.cost = {}

	--物品
	local data = nil
	local temp = nil
	if(template.costItems)then
		local itemStr = lua_string_split(template.costItems, ",")
		for k,v in pairs(itemStr) do
			data = lua_string_split(v, "|")
			temp = {}
			temp.type = kItemTag
			temp.id = tonumber(data[1])
			temp.needNum = tonumber(data[2])

			--local hasItemInfo = ItemUtil.getItemInfoByItemId(temp.id)
			temp.hasNum = ItemUtil.getCacheItemNumBy(temp.id)
			-- if hasItemInfo ~= nil then
			-- 	temp.hasNum = tonumber(hasItemInfo.item_num)
			-- else
			-- 	temp.hasNum = 0
			-- end

			local itemData = ItemUtil.getItemById(temp.id)
			temp.name = itemData.name
			temp.nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)

			table.insert(resource.cost, temp)
		end
	end
	if(template.costHeros)then
		--英雄
		local heroStr = lua_string_split(template.costHeros, ",")
		for k,v in pairs(heroStr) do
			data = lua_string_split(v, "|")
			temp = {}
			temp.type = kHeroTag
			temp.id = tonumber(data[1])
			temp.needLevel = tonumber(data[2])
			temp.needNum = tonumber(data[3])

			--temp.hasNum = HeroUtil.getHeroNumByHtid(temp.id)
			--获取可作为进化材料的英雄数量和集合（为指定模版id，等级大于needLevel）
			temp.hasNum, temp.heroes = getHeroesByHtid(_curHeroInfo.hid, temp.id, temp.needLevel)

			local heroData = HeroUtil.getHeroLocalInfoByHtid(temp.id)
			temp.name = heroData.name
			temp.nameColor = HeroPublicLua.getCCColorByStarLevel(heroData.star_lv)

			table.insert(resource.cost, temp)
		end
	end

	return resource
end
function getPreviewCostResource( p_htid )
	p_htid = tonumber(p_htid)
	local template = getConfigInfo(p_htid)
	local resource = {}
	resource.template = template
	resource.cost = {}

	--物品
	local data = nil
	local temp = nil
	if(template.costItems)then
		local itemStr = lua_string_split(template.costItems, ",")
		for k,v in pairs(itemStr) do
			data = lua_string_split(v, "|")
			temp = {}
			temp.type = kItemTag
			temp.id = tonumber(data[1])
			temp.needNum = tonumber(data[2])

			--local hasItemInfo = ItemUtil.getItemInfoByItemId(temp.id)
			temp.hasNum = ItemUtil.getCacheItemNumBy(temp.id)
			-- if hasItemInfo ~= nil then
			-- 	temp.hasNum = tonumber(hasItemInfo.item_num)
			-- else
			-- 	temp.hasNum = 0
			-- end

			local itemData = ItemUtil.getItemById(temp.id)
			temp.name = itemData.name
			temp.nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)

			table.insert(resource.cost, temp)
		end
	end

	--英雄
	if(template.costHeros)then
		local heroStr = lua_string_split(template.costHeros, ",")
		for k,v in pairs(heroStr) do
			data = lua_string_split(v, "|")
			temp = {}
			temp.type = kHeroTag
			temp.id = tonumber(data[1])
			temp.needLevel = tonumber(data[2])
			temp.needNum = tonumber(data[3])

			--temp.hasNum = HeroUtil.getHeroNumByHtid(temp.id)
			--获取可作为进化材料的英雄数量和集合（为指定模版id，等级大于needLevel）
			temp.hasNum, temp.heroes = getHeroesByHtid(p_htid, temp.id, temp.needLevel)

			local heroData = HeroUtil.getHeroLocalInfoByHtid(temp.id)
			temp.name = heroData.name
			temp.nameColor = HeroPublicLua.getCCColorByStarLevel(heroData.star_lv)

			table.insert(resource.cost, temp)
		end
	end

	return resource
end
--[[
	@des 	:在拥有的武将中根据p_htid筛选不大于等级p_level的英雄  
			 1. 不能包含被进化的英雄
			 2. 英雄模版为材料模版
			 3. 英雄等级不小于要求等级
			 4. 英雄进阶等级不能大于0
	@param 	:
	@return :
--]]
function getHeroesByHtid( p_hid, p_htid, p_level )
	require "script/ui/godweapon/godweaponcopy/GodWeaponCopyData"
	require "script/ui/godweapon/godweaponcopy/GodCopyUtil"
	require "script/ui/formation/secondfriend/SecondFriendData"
	p_hid = tonumber(p_hid)
	p_htid = tonumber(p_htid)
	p_level = tonumber(p_level)
	local allHeroes = HeroModel.getAllHeroes()
	local heroes = {}
	local num = 0
	for k,v in pairs(allHeroes) do
		--print("getHeroesByHtid",v.htid ,HeroPublicLua.isBusyWithHid(v.hid), HeroPublicLua.isOnFormation(v.hid))
		if  tonumber(v.hid) ~= p_hid and tonumber(v.htid) == p_htid and
		    tonumber(v.level) <= p_level and tonumber(v.evolve_level) == 0 and 	--是否再阵上或小伙伴中 HeroPublicLua.isBusyWithHid(v.hid)
		    not HeroPublicLua.isInFormationByHid(v.hid) and		--判断是否是小伙伴 LittleFriendData.isInLittleFriend(v.hid) 
		    GodWeaponCopyData.isOnCopyFormationBy(v.hid) == false and --判断是否是神兵副本里面的武将  add by DJN 2015/1/6
		    SecondFriendData.isInSecondFriendByHid(v.hid) == false then -- 判断这个将领是否在第二套小伙伴上add by DJN 2015/3/12
		    --GodCopyUtil.isBenchId(v.hid) == false then --判断是否在副将 add by DJN 2015/2/6 
		    table.insert(heroes, v) 
			num = num + 1
		end
	end

	return num,heroes
end

--[[
	@des 	:在拥有的武将中筛选出能够进化的武将(紫卡＋7) （新增橙卡+5 进化红卡）
	@param 	:
	@return :
	{	
		{
			hid = int
			htid = int
			country_icon =string
			level = int
			name = string
			star_lv = int
			strength = int
		}
	}
--]]
function getSelectList( ... )
	local allHero = HeroModel.getAllHeroes()
	local selectList = {}
	if not table.isEmpty(allHero) then
		for k,v in pairs(allHero) do
			local template = HeroUtil.getHeroLocalInfoByHtid(tonumber(v.htid))
			if doOpenDevelopByHid(tonumber(v.hid)) then
				local temp = {}
				temp.hid = tonumber(v.hid)
				temp.htid = tonumber(v.htid)
				temp.heroQuality = template.heroQuality
				temp.country_icon = HeroModel.getCiconByCidAndlevel(template.country, template.star_lv)
				temp.level = tonumber(v.level)
				temp.name = template.name
				temp.star_lv = tonumber(template.star_lv)

				-- local fightForceData = HeroFightForce.getAllForceValuesByHid(v.hid)
				-- temp.generalAttack = tonumber(fightForceData.generalAttack)
				table.insert(selectList, temp)
			end
		end
	end
	--重新排序 红卡在上
	table.sort(selectList,sortCards)
	return selectList
end
function sortCards( p_1,p_2 )
	return p_1.star_lv > p_2.star_lv
end
--[[
	@des 	:获取进化配置信息
	@param 	:
	@return :
--]]
function getCostSilver( ... )
	if _curCostResource == nil or _curCostResource.template == nil then
		return 0
	end
	return _curCostResource.template.costSilver
end

--[[
	@des 	:判断是否满足进化条件
	@param 	:
	@return :
--]]
function meetCondition( ... )
	if _curHeroInfo == nil or _curCostResource == nil then
		return false,"choose hero first"
	end

	local status = true
	local tipStr = "ok"

	--判断是否为紫卡
	local heroTemplate = HeroUtil.getHeroLocalInfoByHtid( _curHeroInfo.htid )
	-- if heroTemplate.star_lv ~= 5 then
	-- 	status = false
	-- 	tipStr = GetLocalizeStringBy("zz_96")
	-- 	return status,tipStr
	-- end

	--判断进化前英雄的进阶等级是否满足
	if _curHeroInfo.evolveLevel < _curCostResource.template.needHeroRebirth then
		status = false
		tipStr = GetLocalizeStringBy("zz_94")
		return status,tipStr
	end

	--判断英雄等级是否满足
	if _curHeroInfo.heroLevel < _curCostResource.template.needHeroLevel then
		status = false
		tipStr = GetLocalizeStringBy("zz_95",_curCostResource.template.needHeroLevel)
		return status,tipStr
	end

	--判断物品、英雄数量是否满足
	local data = nil
	for k,v in ipairs(_curCostResource.cost) do
		if v.needNum > v.hasNum then
			data = v
			status = false
			break
		end
	end

	if status == false then
		-- if data.type == kItemTag then
		-- 	tipStr = GetLocalizeStringBy("zz_91", data.name)
		-- elseif data.type == kHeroTag then
		-- 	tipStr = GetLocalizeStringBy("zz_92", data.name)
		-- else
		-- 	tipStr = "cost miss type"
		-- end
		tipStr = GetLocalizeStringBy("zz_101")
		return status,tipStr
	end

	--判断用于进化的英雄材料中是否含有小伙伴
	local argsTable, hasLittleFriend = DevelopData.getArgsTable()
	if hasLittleFriend == true then
		status = false
		tipStr = GetLocalizeStringBy("zz_125")
		return status, tipStr
	end

	--判断银币是否足够
	local userSilver = UserModel.getSilverNumber()
	if userSilver == 0 or userSilver < getCostSilver() then
		status = false
		tipStr = GetLocalizeStringBy("zz_93")
		return status,tipStr
	end

	return status,tipStr
end

--[[
	@des:	通过模板tid得到背包里面将要消耗的物品格子id和对应的消耗数量
	@parm:	item_tid:消耗物品的模板id count:当前物品的数量
	@ret:	
	{
		{
			itemId = int
			itemNum = int
		}
	}
--]]
function getCostItemId( item_tid, count )
	item_tid = tonumber(item_tid)
	count = tonumber(count)

	local num = 0
	local ids = {}
	local allBagInfo = DataCache.getRemoteBagInfo()

	if( not table.isEmpty(allBagInfo)) then
		if( not table.isEmpty( allBagInfo.props)) then
			for k,item_info in pairs( allBagInfo.props) do
				if(tonumber(item_info.item_template_id) == item_tid) then
					-- print("getCostItemId")
					-- print_t(item_info)
					local temp = {}
					temp.itemId = tonumber(item_info.item_id)

					local tempNum = num + tonumber(item_info.item_num)
					if(tempNum < count) then
						temp.itemNum = tonumber(item_info.item_num)
						table.insert(ids, temp)
						num = tempNum
					else
						temp.itemNum = count - num
						table.insert(ids, temp)
						break
					end
				end
			end
		end
		if(not table.isEmpty( allBagInfo.arm)) then
			for k,item_info in pairs( allBagInfo.arm) do
				if(tonumber(item_info.item_template_id) == item_tid
					and tonumber(item_info.va_item_text.armReinforceLevel) == 0) then
					local temp = {}
					temp.itemId = tonumber(item_info.item_id)
					
					local tempNum = num + tonumber(item_info.item_num)
					if(tempNum < count) then
						temp.itemNum = tonumber(item_info.item_num)
						table.insert(ids, temp)
						num = tempNum
					else
						temp.itemNum = count - num
						table.insert(ids, temp)
						break
					end
				end
			end
		end

		if(not table.isEmpty( allBagInfo.heroFrag)) then
			for k,item_info in pairs( allBagInfo.heroFrag) do
				if(tonumber(item_info.item_template_id) == item_tid) then
					local temp = {}
					temp.itemId = tonumber(item_info.item_id)
					
					local tempNum = num + tonumber(item_info.item_num)
					if(tempNum < count) then
						temp.itemNum = tonumber(item_info.item_num)
						table.insert(ids, temp)
						num = tempNum
					else
						temp.itemNum = count - num
						table.insert(ids, temp)
						break
					end
				end
			end
		end

		if(not table.isEmpty( allBagInfo.treas)) then
			for k,item_info in pairs( allBagInfo.treas) do
				if(tonumber(item_info.item_template_id) == item_tid) then
					local temp = {}
					temp.itemId = tonumber(item_info.item_id)
					
					local tempNum = num + tonumber(item_info.item_num)
					if(tempNum < count) then
						temp.itemNum = tonumber(item_info.item_num)
						table.insert(ids, temp)
						num = tempNum
					else
						temp.itemNum = count - num
						table.insert(ids, temp)
						break
					end
				end
			end
		end
	end
	return ids
end

--[[
	@des 	:进化材料满足条件下，用于后端接口参数，消耗的武将hid组和物品字典
	@param 	:
	@return :
--]]
function getArgsTable( ... )
	local argsTable = {
		hidArr = {},
		itemArr = {}
	}

	-- local sortFunc = function ( p_element1, p_element2 )
	-- 	return tonumber(p_element1.level) < tonumber(p_element2.level)
	-- end
	local sortFunc = function ( p_element1, p_element2 )
		-- 判断是否在阵上：HeroPublicLua.isBusyWithHid(v.hid) 判断是否在小伙伴中：LittleFriendData.isInLittleFriend(v.hid)
		if LittleFriendData.isInLittleFriend(p_element1.hid) then
			if LittleFriendData.isInLittleFriend(p_element2.hid) then
				--两个都是小伙伴时，按等级排序
				return tonumber(p_element1.level) < tonumber(p_element2.level)
			else
				return false
			end
		else
			if LittleFriendData.isInLittleFriend(p_element2.hid) then
				return true
			else
				--两个都不是小伙伴时，按等级排序
				return tonumber(p_element1.level) < tonumber(p_element2.level)
			end
		end
	end

	local hasLittleFriend = false
	for k,v in ipairs(_curCostResource.cost) do
		if v.type == kItemTag then
			local temp = getCostItemId(v.id, v.needNum)
			for k,v in ipairs(temp) do
				table.insert(argsTable.itemArr, v)
			end
		elseif v.type == kHeroTag then
			table.sort(v.heroes, sortFunc)
			for i = 1,v.needNum do
				--判断用于进化的英雄材料是否包含了小伙伴
				if LittleFriendData.isInLittleFriend(v.heroes[i].hid) then
					hasLittleFriend = true
				end
				table.insert(argsTable.hidArr, v.heroes[i].hid)
			end
		else

		end
	end
	return argsTable, hasLittleFriend
end

--[[
	@des 	:用于进化橙卡成功后处理本地数据（消耗资源）
	@param 	:
	@return :
--]]
require "script/model/user/UserModel"
function consumeResource( p_hidArr, p_silverNum )
	p_silverNum = tonumber(p_silverNum)
	--消耗银币
	UserModel.addSilverNumber(-p_silverNum)

	--消耗英雄
	for _,v in ipairs(p_hidArr) do
		HeroModel.deleteHeroByHid(v)
	end

	--修改被进化英雄的缓存
	HeroModel.setHtidByHid(_curHeroInfo.hid, _curDevelopInfo.htid)
	HeroModel.setHeroEvolveLevelByHid(_curHeroInfo.hid, 0)

	--修改武将图鉴中的数据
	require "script/ui/menu/IllustratUtil"
	local heroBookData = IllustratUtil.getHeroBook()
	table.insert(heroBookData, tostring(_curDevelopInfo.htid))

	-- --更新数据
	-- _curHeroInfo = _curDevelopInfo
	-- _curDevelopInfo = getCurDevelopInfo(_curHeroInfo.hid)
	-- _curCostResource = getCurCostResource(_curHeroInfo.htid)
end

--[[
	@des 	:获得英雄的信息,用于英雄信息展示
	@param 	:
	@return :
--]]
function getHeroData( htid )
    value = {}

    value.htid = htid
    local db_hero = DB_Heroes.getDataById(htid)
    value.country_icon = HeroModel.getCiconByCidAndlevel(db_hero.country, db_hero.star_lv)
    value.name = db_hero.name
    value.level = db_hero.lv
    value.star_lv = db_hero.star_lv
    value.hero_cb = menu_item_tap_handler
    value.head_icon = "images/base/hero/head_icon/" .. db_hero.head_icon_id
    value.quality_bg = "images/hero/quality/"..value.star_lv .. ".png"
    value.quality_h = "images/hero/quality/highlighted.png"
    value.type = "HeroFragment"
    value.isRecruited = false
    value.evolve_level = 0

    return value
end

--[[
	--方法原形：HeroLayer.getArrHeroesValue()
	@des 	:根据hid获得英雄的信息,用于英雄信息展示
	@param 	:
	@return :
--]]
function getHeroDataByHid( p_hid )
	require "script/model/hero/HeroModel"
	require "db/DB_Heroes"
	require "script/ui/hero/HeroPublicLua"
		
	local hero = HeroModel.getHeroByHid(p_hid)
	
	local value = {}
	value.hid = p_hid
	value.soul = tonumber(hero.soul)
	value.level = tonumber(hero.level)
	value.lock= hero.lock		--  如果武将没有锁定  此字段没有  如果锁定 值为1
	local db_hero = DB_Heroes.getDataById(hero.htid)
	value.isAvatar = HeroModel.isNecessaryHero(hero.htid)
	if value.isAvatar then
		value.name = UserModel.getUserName()
		--print("主角htid1:", hero.htid)
		value.htid = UserModel.getAvatarHtid()
		--print("主角htid2:", value.htid)
	else
		value.name = db_hero.name
		value.htid = hero.htid
	end
	
	value.country_icon = HeroModel.getCiconByCidAndlevel(db_hero.country, db_hero.star_lv)
    value.decompos_soul = db_hero.decompos_soul
    value.lv_up_soul_coin_ratio = db_hero.lv_up_soul_coin_ratio
    value.awake_id = db_hero.awake_id
	value.grow_awake_id = db_hero.grow_awake_id
	value.heroQuality = db_hero.heroQuality
	
	value.star_lv = db_hero.star_lv
	value.exp_id = db_hero.exp
	-- 武将是否在阵上
	value.isBusy=HeroPublicLua.isInFormationByHid(p_hid)
	value.evolve_level = tonumber(hero.evolve_level)
	value.db_hero = db_hero
	value.fight_value = 0
	return value
end

--[[
	--方法原形：HeroLayer.getArrHeroesValue()
	@des 	:根据hid获得英雄的信息,用于英雄信息展示
	@param 	:
	@return :
--]]
function getDevelopHeroData( )
	require "script/model/hero/HeroModel"
	require "db/DB_Heroes"
	require "script/ui/hero/HeroPublicLua"
		
	local hero = HeroModel.getHeroByHid(_curHeroInfo.hid)
	
	local value = {}
	value.hid = p_hid
	value.soul = tonumber(hero.soul)
	value.level = tonumber(hero.level)
	value.lock= hero.lock		--  如果武将没有锁定  此字段没有  如果锁定 值为1
	value.htid = _curDevelopInfo.htid
	local db_hero = DB_Heroes.getDataById(value.htid)
	value.isAvatar = HeroModel.isNecessaryHero(value.htid)
	if value.isAvatar then
		value.name = UserModel.getUserName()
	else
		value.name = db_hero.name
	end
	--db_hero = DB_Heroes.getDataById(value.htid)
	value.country_icon = HeroModel.getCiconByCidAndlevel(db_hero.country, db_hero.star_lv)
    value.decompos_soul = db_hero.decompos_soul
    value.lv_up_soul_coin_ratio = db_hero.lv_up_soul_coin_ratio
    value.awake_id = db_hero.awake_id
	value.grow_awake_id = db_hero.grow_awake_id
	value.heroQuality = db_hero.heroQuality
	
	value.star_lv = db_hero.star_lv
	value.exp_id = db_hero.exp
	-- 武将是否在阵上
	value.isBusy=HeroPublicLua.isInFormationByHid(_curHeroInfo.hid)
	value.evolve_level = tonumber(0)
	value.db_hero = db_hero
	value.fight_value = 0
	-- print("getDevelopHeroData")
	-- print_t(value)
	return value
end
--------------------------------------add by DJN ------------------------------
--[[
	@des 	:根据htid获取卡牌展示信息 （橙卡紫卡）
	@param 	:
	@return :返回英雄的详细信息
	{

		htid = int
		--dressId = int
		aptitude = int
		heroName = string
		evolveLevel = int
		heroLevel = int
		normalSkill = {
			skillName = string
			skillDesc = string
		}
		angerSkill = {
			skillName = string
			skillDesc = string
		}
		command = int
		strength = int
		intelligence = int
	}
--]]

function getPreviewHeroInfo( p_htid,p_envolveLevel)
	p_htid = tonumber(p_htid)

	local heroData = HeroUtil.getHeroLocalInfoByHtid(p_htid)
	if heroData == nil then
		return nil
	end

	local heroInfo = {}
	--htid
	heroInfo.htid = tonumber(heroData.htid)
	-- --dressId
	-- heroInfo.dressId = tonumber(heroData.dress[1])
	--名字
	heroInfo.heroName = heroData.name
	--星级
	heroInfo.star_lv = heroData.star_lv
	--资质
	heroInfo.aptitude = heroData.heroQuality
	--进阶等级
	heroInfo.evolveLevel = p_envolveLevel 
	--英雄等级
	--heroInfo.heroLevel = tonumber(heroData.level)
	--普通技能
	local normalSkill = skill.getDataById(heroData.normal_attack)
	heroInfo.normalSkill = {}
	heroInfo.normalSkill.skillName = normalSkill.name
	heroInfo.normalSkill.skillDesc = normalSkill.des
	--怒气技能
	local angerSkill = skill.getDataById(heroData.rage_skill_attack)
	heroInfo.angerSkill = {}
	heroInfo.angerSkill.skillName = angerSkill.name
	heroInfo.angerSkill.skillDesc = angerSkill.des


	local fightForceData = FightForceModel.getHeroBaseDisplayAffix(p_htid)
	--统帅
	heroInfo.command = tonumber(fightForceData[6])
	--武力
	heroInfo.strength = tonumber(fightForceData[7])
	--智慧
	heroInfo.intelligence = tonumber(fightForceData[8])

	return heroInfo
end
-- --[[
-- 	@des 	:根据htid获取对应的进化配置信息
-- 	@param 	:
-- 	@return :返回进化后英雄的详细信息
-- 	{
-- 		hid = int
-- 		htid = int
-- 		--dressId = int
-- 		aptitude = int
-- 		heroName = string
-- 		evolveLevel = int
-- 		heroLevel = int
-- 		normalSkill = {
-- 			skillName = string
-- 			skillDesc = string
-- 		}
-- 		angerSkill = {
-- 			skillName = string
-- 			skillDesc = string
-- 		}
-- 		command = int
-- 		strength = int
-- 		intelligence = int
-- 	}
-- --]]

-- function getPreviewDevelopInfo( p_hid )
-- 	p_hid = tonumber(p_hid)
	
-- 	local beforeDevelopHeroData = _curHeroInfo or getHeroInfo(p_hid)
-- 	--英雄背包中没有该英雄
-- 	if beforeDevelopHeroData == nil then
-- 		return nil
-- 	end
-- 	print("getDevelopInfo")
-- 	print_t(beforeDevelopHeroData)

-- 	local developConfig = getConfigInfo(beforeDevelopHeroData.htid)
-- 	--该英雄没有开启进化橙卡功能
-- 	if developConfig == nil then
-- 		return nil
-- 	end

-- 	local afterDevelopHeroData = DB_Heroes.getDataById(developConfig.afteRevolveTid)

-- 	local developInfo = {}
-- 	--进化前的hid
-- 	developInfo.hid = beforeDevelopHeroData.hid
-- 	--进化后的htid
-- 	developInfo.htid = developConfig.afteRevolveTid
-- 	-- --进化后的dressId
-- 	-- developInfo.dressId = beforeDevelopHeroData.dressId
-- 	--进化后的名字
-- 	developInfo.heroName = afterDevelopHeroData.name
-- 	--进化后的星级
-- 	developInfo.star_lv = afterDevelopHeroData.star_lv
-- 	--进化后的资质
-- 	developInfo.aptitude = afterDevelopHeroData.heroQuality
-- 	--进化后的进阶等级
-- 	--developInfo.evolveLevel = beforeDevelopHeroData.evolveLevel
-- 	developInfo.evolveLevel = 0
-- 	--进化后的英雄等级
-- 	developInfo.heroLevel = beforeDevelopHeroData.heroLevel
-- 	--进化后的普通技能
-- 	local normalSkill = skill.getDataById(afterDevelopHeroData.normal_attack)
-- 	developInfo.normalSkill = {}
-- 	developInfo.normalSkill.skillName = normalSkill.name
-- 	developInfo.normalSkill.skillDesc = normalSkill.des
-- 	--进化后的怒气技能
-- 	local angerSkill = skill.getDataById(afterDevelopHeroData.rage_skill_attack)
-- 	developInfo.angerSkill = {}
-- 	developInfo.angerSkill.skillName = angerSkill.name
-- 	developInfo.angerSkill.skillDesc = angerSkill.des

-- 	local heroData = {}
-- 	table.hcopy(HeroModel.getHeroByHid(developInfo.hid), heroData)
-- 	heroData.htid = developInfo.htid
-- 	local fightForceData = HeroFightForce.getAllForceValues(heroData)
-- 	--进化后的统帅
-- 	developInfo.command = fightForceData.command
-- 	--进化后的武力
-- 	developInfo.strength = fightForceData.strength
-- 	--进化后的智慧
-- 	developInfo.intelligence = fightForceData.intelligence
-- 	print("afterDevelopHeroData")
-- 	print_t(developInfo)
-- 	return developInfo
-- end
--------------------------------------add by DJN  end------------------------------
