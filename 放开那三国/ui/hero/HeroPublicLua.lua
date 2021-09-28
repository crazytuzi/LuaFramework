-- Filename: HeroPublicLua.lua
-- Author: fang
-- Date: 2013-08-23
-- Purpose: 该文件用于: 武将系统lua公用方法

module("HeroPublicLua", package.seeall)

require "script/ui/formation/LittleFriendData"

-- 获得所有英雄信息数组
-- tAppend，期望附加进数据结构的信息table
function getAllHeroValues(tAppend)
	require "script/model/hero/HeroModel"
	require "db/DB_Heroes"
	require "script/ui/hero/HeroFightForce"

	local hids = HeroModel.getAllHeroesHid()
	local heroesValue = {}
	for i=1, #hids do
		local value = {}
		value.hid = hids[i]
		local hero = HeroModel.getHeroByHid(hids[i])
        value.soul = tonumber(hero.soul)
		value.htid = hero.htid
		value.level = tonumber(hero.level)
		
		local db_hero = DB_Heroes.getDataById(hero.htid)
		local bIsFiltered = false
		if tAppend.filters then
			for i=1, #tAppend.filters do
				if tonumber(value.htid) == tAppend.filters[i] then
					bIsFiltered = true
				end
			end
		end
		if not bIsFiltered then
			value.country_icon = HeroModel.getCiconByCidAndlevel(db_hero.country, db_hero.star_lv)
			value.name = db_hero.name
			
	        value.decompos_soul = db_hero.decompos_soul
	        value.lv_up_soul_coin_ratio = db_hero.lv_up_soul_coin_ratio
			value.evolve_level = tonumber(hero.evolve_level)
			value.star_lv = db_hero.star_lv
			value.awake_id = db_hero.awake_id
			value.grow_awake_id = db_hero.grow_awake_id
			value.exp_id = db_hero.exp
			-- 如果存
			if tAppend.heroTagBegin then
			 	value.tag_hero = tAppend.heroTagBegin+i
			end
			value.head_icon = "images/base/hero/head_icon/" .. db_hero.head_icon_id
			value.quality_bg = "images/hero/quality/"..value.star_lv..".png"
			value.quality_h = "images/hero/quality/highlighted.png"
			-- 还需要什么数据信息都可以在这里加
			value.fight_value = 0
			value.isBusy = HeroPublicLua.isBusyWithHid(value.hid)
			
			heroesValue[#heroesValue+1] = value
		end
	end

	return heroesValue
end

-- 通过武将hid获得其属性相关数据
function getHeroDataByHid(hid)
-- 以下引用导致"stack overflow"
	require "script/model/hero/HeroModel"
	require "db/DB_Heroes"
	local tHeroData = {}
	local hero = HeroModel.getHeroByHid(hid)
	if hero then
		tHeroData.hid = hid
		tHeroData.soul = tonumber(hero.soul)
		tHeroData.htid = hero.htid
        tHeroData.level = tonumber(hero.level)
		tHeroData.evolve_level = tonumber(hero.evolve_level)
		
		local db_hero = DB_Heroes.getDataById(hero.htid)
		tHeroData.country_icon = HeroModel.getCiconByCidAndlevel(db_hero.country, db_hero.star_lv)
		local bIsAvatar = HeroModel.isNecessaryHero(tHeroData.htid)
		if bIsAvatar then
			tHeroData.name = UserModel.getUserName()
		else
			tHeroData.name = db_hero.name
		end
		tHeroData.decompos_soul = db_hero.decompos_soul
		tHeroData.lv_up_soul_coin_ratio = db_hero.lv_up_soul_coin_ratio
		tHeroData.star_lv = db_hero.star_lv
		tHeroData.head_icon = "images/base/hero/head_icon/" .. db_hero.head_icon_id
		tHeroData.quality_bg = "images/hero/quality/"..db_hero.star_lv .. ".png"
		tHeroData.quality_h = "images/hero/quality/highlighted.png"
        tHeroData.awake_id = db_hero.awake_id
		tHeroData.grow_awake_id = db_hero.grow_awake_id
		tHeroData.exp_id = db_hero.exp
		-- 还需要什么数据信息都可以在这里加
		tHeroData.turned_id = hero.turned_id
	end
	
	return tHeroData
end

-- 通过武将hid获得其属性相关数据
function getHeroDataByHid02(hid)
-- 以下引用导致"stack overflow"
	require "script/model/hero/HeroModel"
	require "db/DB_Heroes"
	local tHeroData = {}
	local hero = HeroModel.getHeroByHid(hid)
	if hero then
		tHeroData.hid = hid
		tHeroData.soul = tonumber(hero.soul)
		tHeroData.htid = hero.htid
        tHeroData.level = tonumber(hero.level)
		tHeroData.evolve_level = tonumber(hero.evolve_level)
		
		local db_hero = DB_Heroes.getDataById(hero.htid)
		tHeroData.country_icon = HeroModel.getCiconByCidAndlevel(db_hero.country, db_hero.star_lv)
		local bIsAvatar = HeroModel.isNecessaryHero(tHeroData.htid)
		if bIsAvatar then
			tHeroData.name = UserModel.getUserName()
		else
			tHeroData.name = db_hero.name
		end
		tHeroData.decompos_soul = db_hero.decompos_soul
		tHeroData.lv_up_soul_coin_ratio = db_hero.lv_up_soul_coin_ratio
		tHeroData.star_lv = db_hero.star_lv
		tHeroData.head_icon = "images/base/hero/head_icon/" .. db_hero.head_icon_id
		tHeroData.quality_bg = "images/hero/quality/"..db_hero.star_lv .. ".png"
		tHeroData.quality_h = "images/hero/quality/highlighted.png"
        tHeroData.awake_id = db_hero.awake_id
		tHeroData.grow_awake_id = db_hero.grow_awake_id
		tHeroData.exp_id = db_hero.exp
		-- 还需要什么数据信息都可以在这里加
	end
	
	return tHeroData
end

-- 通过hid判断一个武将是否在阵上
function isBusyWithHid(hid)
	local bStatus = false
	require "script/model/DataCache"
	local formationInfo = DataCache.getFormationInfo()
	if not formationInfo then
		return bStatus
	end
	-- 从阵容信息中获取该武将是否已上阵
	for k, v in pairs(formationInfo) do
		if (tostring(v) == tostring(hid)) then
			bStatus=true
			break
		end
	end
	-- 判断是否在小伙伴阵容里
	require "script/ui/formation/LittleFriendData"
	if not bStatus then
		bStatus = LittleFriendData.isInLittleFriend(hid)
	end

	return bStatus
end

-- 通过htid判断阵容中是否存在某一类武将
function isBusyWithHtid(p_htid)
    local bStatus = false
    local htid = tonumber(DB_Heroes.getDataById(p_htid).model_id)
	require "script/model/DataCache"
	local formationInfo = DataCache.getFormationInfo()
    local tAllHeroes = HeroModel.getAllHeroes()
    if not formationInfo then
    	return false
    end

	for k, v in pairs(formationInfo) do
		if tonumber(v) > 0 then
			local modelId = DB_Heroes.getDataById(tonumber(tAllHeroes[tostring(v)].htid)).model_id
			if tonumber(modelId) == tonumber(htid) then
				bStatus=true
				break
			end
		end
	end
    
	return bStatus
end

-- addBy chengliang
-- 通过htid判断小伙伴中是否存在某一类武将
function isOnLittleFriendBy(p_htid)
    local bStatus = false
    local htid = tonumber(DB_Heroes.getDataById(p_htid).model_id)
	local littleFriendInfo = LittleFriendData.getLittleFriendeData()
    local tAllHeroes = HeroModel.getAllHeroes()
    if table.isEmpty( littleFriendInfo) then
    	return false
    end
	for k, v in pairs(littleFriendInfo) do
		if tonumber(v) > 0 then
			local modelId = DB_Heroes.getDataById(tonumber(tAllHeroes[tostring(v)].htid)).model_id
			if(tonumber(modelId) == tonumber(htid)) then
				bStatus=true
				break
			end
		end
	end
	return bStatus
end

--[[
	@des: 判断武将在阵容上
--]]
function isOnFormation( p_hid )
	local formationInfo = DataCache.getFormationInfo()
	local isBusy = false
	for k, v in pairs(formationInfo) do
		if (tonumber(v) == tonumber(p_hid)) then
			isBusy=true
			break
		end
	end
	return isBusy
end


local tColorsOfQulity = {
 	{0xff, 0xff, 0xff},
 	{0xff, 0xff, 0xff},
 	{0, 0xeb, 0x21},
 	{0x51, 0xfb, 0xff},
 	{255, 0, 0xe1},
 	{255, 0x84, 0},
 	{255, 0x27, 0x27},
 	{0xff, 0xf6, 0x00},
}
-- 获得星级对应的品质颜色
function getCCColorByStarLevel(nStarLevel)
	local color = tColorsOfQulity[nStarLevel]
	if not color then
		color = {255, 255, 255}
	end
	return ccc3(color[1], color[2], color[3])
end

local tColorsOfQulityDes = {
 	GetLocalizeStringBy("lic_1461"), -- 白色
 	GetLocalizeStringBy("lic_1462"), -- 白色
 	GetLocalizeStringBy("lic_1463"), -- 绿色
 	GetLocalizeStringBy("lic_1464"), -- 蓝色
 	GetLocalizeStringBy("lic_1465"), -- 紫色
 	GetLocalizeStringBy("lic_1466"), -- 橙色
 	GetLocalizeStringBy("lic_1467"), -- 红色
}
-- 获得星级对应的品质颜色描述
function getCCColorDesByStarLevel(nStarLevel)
	local colorDes = tColorsOfQulityDes[nStarLevel]
	if not colorDes then
		colorDes = GetLocalizeStringBy("lic_1461")
	end
	return colorDes
end

-- 武将增加经验后对应的级别
function getHeroLevelByAddSoul(tParam)
	require "db/DB_Level_up_exp"
	local db_level = DB_Level_up_exp.getDataById(tParam.exp_id)
	local nTotalSoul = tonumber(tParam.soul) + tonumber(tParam.added_soul)
	-- 目前武将级别最高为199，为了以后扩展暂用999级
	local nSoulOfLevel = 0
	local nLevelToSoul = 1
	for i=2, 999 do
		local nSoul = db_level["lv_"..i]
		if not nSoul then
			break
		end
		nSoulOfLevel = nSoulOfLevel + nSoul
		if nSoulOfLevel > nTotalSoul then
			nLevelToSoul = i-1
			break
		end
	end

	return nLevelToSoul
end

-- 武将升至下一级需要的经验
function getSoulToNextLevel(tParam)
	require "db/DB_Level_up_exp"
	local db_level = DB_Level_up_exp.getDataById(tParam.exp_id)
	local nNextLevelSoul = 0
	for i=2, tParam.level+1 do
		local nSoul = db_level["lv_"..i]
		if not nSoul then
			break
		end
		nNextLevelSoul = nNextLevelSoul + tonumber(nSoul)
	end
	local nSoulNeeded = nNextLevelSoul - tonumber(tParam.soul)
	if nSoulNeeded < 0 then
		nSoulNeeded = 0
	end

	return nSoulNeeded
end
-- 武将等级对应的武魂数量
function getSoulOnLevel(tParam)
	require "db/DB_Level_up_exp"
	local db_level = DB_Level_up_exp.getDataById(tParam.exp_id)
	local nTotalSoul = 0
	for i=2, tParam.level do
		local nSoul = db_level["lv_"..i]
		if not nSoul then
			break
		end 
		nTotalSoul = nTotalSoul + tonumber(nSoul)
	end

	return nTotalSoul
end

--判断武将是否在阵上，小伙伴不包括在内
function isInFormationByHid( hid )
	local bStatus = false
	require "script/model/DataCache"
	local formationInfo = DataCache.getFormationInfo()
	if not formationInfo then
		return bStatus
	end
	-- 从阵容信息中获取该武将是否已上阵
	for k, v in pairs(formationInfo) do
		if (tostring(v) == tostring(hid)) then
			bStatus=true
			break
		end
	end
	return bStatus
end
