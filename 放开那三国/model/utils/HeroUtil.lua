-- Filename: 	HeroUtil.lua
-- Author: 		chengliang
-- Date: 		2013-07-15
-- Purpose: 	hero工具方法


module ("HeroUtil", package.seeall)

require "script/model/hero/HeroModel"
require "script/model/DataCache"
require "script/ui/formation/LittleFriendData"

require "db/DB_Normal_config"


-- 根据hid获得英雄的相关信息 int
function getHeroInfoByHid( hid )
	local heroAllInfo = nil
	local allHeros = HeroModel.getAllHeroes()

	-- for t_hid, t_hero in pairs(allHeros) do

	-- 	if( tonumber(t_hid) ==  tonumber(hid)) then
	-- 		heroAllInfo = t_hero
	-- 		break
	-- 	end
	-- end

	--changed by Zhang Zihang
	heroAllInfo = allHeros[tostring(hid)]

	require "db/DB_Heroes"
	heroAllInfo.localInfo = DB_Heroes.getDataById(tonumber(heroAllInfo.htid))

	return heroAllInfo
end

-- 根据htid获得英雄DB信息
function getHeroLocalInfoByHtid( htid )
	require "db/DB_Heroes"
	return DB_Heroes.getDataById(htid)
end

-- 根据htid获得hero的头像 int (dressId,gender 可不传) genderId 1男，2女
-- 通过vip 来判断是否有光圈
function getHeroIconByHTID( htid, dressId , genderId,vip, turnedId)
	local heroInfo = getHeroLocalInfoByHtid(htid)
	local bgSprite = CCSprite:create("images/base/potential/officer_" .. heroInfo.potential .. ".png")
	local vip= vip or 0

	local headFile = getHeroIconImgByHTID( htid, dressId, turnedId )

	local iconSprite = CCSprite:create(headFile)
	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
	iconSprite:setPosition(ccp(bgSprite:getContentSize().width/2, bgSprite:getContentSize().height/2))
	bgSprite:addChild(iconSprite)

	local effectNeedVipLevel = DB_Normal_config.getDataById(1).vipEffect

	if( tonumber(vip) >= tonumber(effectNeedVipLevel) and HeroModel.isNecessaryHero(htid) ) then

	    local img_path=  CCString:create("images/base/effect/txlz/txlz")
        local openEffect=  CCLayerSprite:layerSpriteWithNameAndCount(img_path:getCString(), -1,CCString:create(""))
        openEffect:setPosition(bgSprite:getContentSize().width/2,bgSprite:getContentSize().width*0.5)
        openEffect:setAnchorPoint(ccp(0.5,0.5))
        bgSprite:addChild(openEffect,1,88888)
	end

	return bgSprite
end

-- 根据htid获得hero的灰色头像 int (dressId,gender 可不传) genderId 1男，2女
-- 通过vip 来判断是否有光圈
function getHeroGrayIconByHTID( htid, dressId , genderId,vip, turnedId)
	local heroInfo = getHeroLocalInfoByHtid(htid)
	local bgSprite = BTGraySprite:create("images/base/potential/officer_" .. heroInfo.potential .. ".png")
	local vip= vip or 0

	local headFile = getHeroIconImgByHTID( htid, dressId, turnedId )

	local iconSprite = BTGraySprite:create(headFile)
	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
	iconSprite:setPosition(ccp(bgSprite:getContentSize().width/2, bgSprite:getContentSize().height/2))
	bgSprite:addChild(iconSprite)

	local effectNeedVipLevel = DB_Normal_config.getDataById(1).vipEffect

	if( tonumber(vip) >= tonumber(effectNeedVipLevel) and HeroModel.isNecessaryHero(htid) ) then

	    local img_path=  CCString:create("images/base/effect/txlz/txlz")
        local openEffect=  CCLayerSprite:layerSpriteWithNameAndCount(img_path:getCString(), -1,CCString:create(""))
        openEffect:setPosition(bgSprite:getContentSize().width/2,bgSprite:getContentSize().width*0.5)
        openEffect:setAnchorPoint(ccp(0.5,0.5))
        bgSprite:addChild(openEffect,1,88888)
	end

	return bgSprite
end

-- 根据htid获得hero的头像
function getHeroIconImgByHTID( htid, dressId, turnedId )
	local imgName = ""
	if(dressId and tonumber(dressId)>0)then
		-- 如果有时装
		require "db/DB_Item_dress"
		local dressInfo = DB_Item_dress.getDataById(dressId)

		if(dressInfo.changeHeadIcon~=nil)then
			genderId = HeroModel.getSex(htid)
			imgName =  getStringByFashionString(dressInfo.changeHeadIcon, genderId)
		else
			-- 隐藏时装
			require "db/DB_Heroes"
			local heroInfo = DB_Heroes.getDataById(htid)
			imgName =  heroInfo.head_icon_id
		end
	elseif(turnedId and tonumber(turnedId) >0) then
		require "script/ui/turnedSys/HeroTurnedData"
		local configInfo = HeroTurnedData.getTurnDBInfoById(turnedId)
		imgName = configInfo.head_icon_id
	else
		-- 没有时装
		require "db/DB_Heroes"
		local heroInfo = DB_Heroes.getDataById(htid)
		imgName =  heroInfo.head_icon_id
	end

	return "images/base/hero/head_icon/" .. imgName
end

-- 英雄的全身像图片地址 (dressId,gender 可不传) genderId 1男，2女
function getHeroBodyImgByHTID( htid, dressId, genderId, turnedId )

	local imgName = ""
	if(dressId and tonumber(dressId)>0)then
		-- 如果有时装
		require "db/DB_Item_dress"
		local dressInfo = DB_Item_dress.getDataById(dressId)
		if(dressInfo.changeBodyImg ~= nil)then
			genderId = HeroModel.getSex(htid)
			imgName =  getStringByFashionString(dressInfo.changeBodyImg, genderId)
		else
			-- 隐藏时装
			require "db/DB_Heroes"
			local heroInfo = DB_Heroes.getDataById(htid)
			imgName =  heroInfo.body_img_id
		end
	elseif(turnedId and tonumber(turnedId) >0) then
		require "script/ui/turnedSys/HeroTurnedData"
		local configInfo = HeroTurnedData.getTurnDBInfoById(turnedId)
		imgName = configInfo.body_img_id
	else
		-- 没有时装
		require "db/DB_Heroes"
		local heroInfo = DB_Heroes.getDataById(htid)
		if heroInfo == nil then
			--支持npc主角
			require "db/DB_Monsters"
			local monsterInfo = DB_Monsters.getDataById(htid)
			local npcHeroInfo = DB_Heroes.getDataById(monsterInfo.htid)
			imgName =  npcHeroInfo.body_img_id
		else
			imgName =  heroInfo.body_img_id
		end
	end

	return "images/base/hero/body_img/" .. imgName
end

-- 英雄的全身像图片地址 (dressId,gender 可不传) genderId 1男，2女
function getHeroBodySpriteByHTID( htid, dressId, genderId, turnedId )
	local iconFile =  getHeroBodyImgByHTID( htid, dressId, genderId, turnedId )

	return CCSprite:create(iconFile)
end

-- 得到时装全身像的偏移量 add by licong
function getHeroBodySpriteOffsetByHTID( htid, dressId, turnedId )
	local retOffset = 0
	if(dressId and tonumber(dressId)>0)then
		-- 如果有时装
		require "db/DB_Item_dress"
		local dressInfo = DB_Item_dress.getDataById(dressId)
		if(dressInfo.changeBodyImg ~= nil)then
			local genderId = HeroModel.getSex(htid)
			if( dressInfo.offset ~= nil)then
				local offsetTab = string.split(dressInfo.offset, "|")
				if(genderId == 1)then
					retOffset = tonumber(offsetTab[1])
				else
					retOffset = tonumber(offsetTab[2])
				end
			end
		else
			-- 隐藏时装
			require "db/DB_Heroes"
			local heroInfo = DB_Heroes.getDataById(htid)
			if( heroInfo.herosOffset ~= nil)then
				retOffset = tonumber(heroInfo.herosOffset)
			end
		end
	elseif turnedId and tonumber(turnedId)>0 then
		require "script/ui/turnedSys/HeroTurnedData"
		local configInfo = HeroTurnedData.getTurnDBInfoById(turnedId)
		if configInfo.herosOffset then
			retOffset = tonumber(configInfo.herosOffset)
		end
	else
		require "db/DB_Heroes"
		local heroInfo = DB_Heroes.getDataById(htid)
		if( heroInfo.herosOffset ~= nil)then
			retOffset = tonumber(heroInfo.herosOffset)
		end
	end
	return retOffset
end

-- 分男女 解析时装的字段
function getStringByFashionString( fashion_str, genderId)
	genderId = tonumber(genderId)
	local t_fashion = splitFashionString(fashion_str)
	if(genderId == 1)then
		return t_fashion["20001"]
	else
		return t_fashion["20002"]
	end

end

--
function splitFashionString( fashion_str )
	local fashion_t = {}
	local f_t = string.split(fashion_str, ",")
	for k,ff_t in pairs(f_t) do
		local s_t = string.split(ff_t, "|")
		fashion_t[s_t[1]] = s_t[2]
	end

	return fashion_t
end


-- 根据htid获得hero的半身像 int
-- 金城确认无半身像，返回全身像 2013.08.14
-- k 2013.8.2
function getHeroHalfLenImageStringByHTID( htid )
	require "db/DB_Heroes"
	local heroInfo = DB_Heroes.getDataById(htid)


    if(heroInfo==nil)then
        print(GetLocalizeStringBy("key_2685"))
        return nil
    end
    ---[[
    if(heroInfo.body_img_id==nil)then
        print(GetLocalizeStringBy("key_2666"))
        return nil
    end
    --]]
    --暂无半身资源，使用全身资源
    --local str = "images/base/hero/body_img/" .. heroInfo.body_img_id
    local str = "images/base/hero/body_img/" .. heroInfo.body_img_id

	return str
end

-- 按强化等级由高到低排序
local function fnCompareWithLevel(h1, h2)
	return h1.level > h2.level
end
-- 按进阶次数排序
local function fnCompareWithEvolveLevel(h1, h2)
	if tonumber(h1.evolve_level) == tonumber(h2.evolve_level) then
		return fnCompareWithLevel(h1, h2)
	else
		return tonumber(h1.evolve_level) > tonumber(h2.evolve_level)
	end
end
-- 按星级高低排序
local function fnCompareWithStarLevel(h1, h2)
	if h1.star_lv == h2.star_lv then
		return fnCompareWithEvolveLevel(h1, h2)
	else
		return h1.star_lv > h2.star_lv
	end
end

-- 将领的排序
function heroSort( hero_1, hero_2 )
	local isPre = false
	if(hero_1.heroDesc.potential>hero_2.heroDesc.potential) then
		isPre = true
	elseif(hero_1.heroDesc.potential==hero_2.heroDesc.potential)then
		require "script/ui/hero/HeroPublicLua"
		local h1 = HeroPublicLua.getHeroDataByHid02(hero_1.hid)
		local h2 = HeroPublicLua.getHeroDataByHid02(hero_2.hid)

		-- if(hero_1.fightDict.vitalStat > hero_2.fightDict.vitalStat)then
		-- 	isPre = true
		-- end
		isPre = fnCompareWithEvolveLevel(h1, h2)
	end
	return isPre
end


-- 获得空闲的将领
function getFreeHerosInfo( )
	local freeHerosInfo = {}
	local allHeros = HeroModel.getAllHeroes()
	local formationInfos = DataCache.getFormationInfo()
	require "script/ui/formation/LittleFriendData"
	local littleFriendInfo = LittleFriendData.getLittleFriendeData()

	require "script/ui/formation/secondfriend/SecondFriendData"
	local secFriendInfo = SecondFriendData.getSecondFriendInfo()

	for t_hid, t_hero in pairs(allHeros) do
		local isFree = true
		for k,  f_hid in pairs(formationInfos) do
			if( tonumber(t_hid) ==  tonumber(f_hid)) then
				isFree = false
				break
			end
		end

		-- 小伙伴
		for k,  f_hid in pairs(littleFriendInfo) do
			if( tonumber(t_hid) ==  tonumber(f_hid)) then
				isFree = false
				break
			end
		end

		-- 第二套小伙伴
		for k,  f_hid in pairs(secFriendInfo) do
			if( tonumber(t_hid) ==  tonumber(f_hid)) then
				isFree = false
				break
			end
		end

		if(isFree)then
			require "db/DB_Heroes"
			t_hero.heroDesc = DB_Heroes.getDataById(t_hero.htid)

			table.insert(freeHerosInfo, t_hero)
		end
	end
	table.sort( freeHerosInfo, heroSort )

	return freeHerosInfo
end

-- 获得空闲的将领
function getFreeBenchHerosInfo( )
	local freeHerosInfo = {}
	local allHeros = HeroModel.getAllHeroes()
	local formationInfos = DataCache.getFormationInfo()
	require "script/ui/godweapon/godweaponcopy/GodWeaponCopyData"
	local copyInfo = GodWeaponCopyData.getChooseHeroData()
	for t_hid, t_hero in pairs(allHeros) do
		local isFree = true
		for k,  f_hid in pairs(formationInfos) do
			if( tonumber(t_hid) ==  tonumber(f_hid)) then
				isFree = false
				break
			end
		end

		-- 副将

			if(not table.isEmpty(copyInfo))then
				for k,  f_hid in pairs(copyInfo) do
					if( tonumber(t_hid) ==  tonumber(f_hid)) then
						isFree = false
						break
					end
				end
			end


		if(isFree)then
			require "db/DB_Heroes"
			t_hero.heroDesc = DB_Heroes.getDataById(t_hero.htid)
			table.insert(freeHerosInfo, t_hero)
		end
	end
	table.sort( freeHerosInfo, heroSort )

	return freeHerosInfo
end

-- 获得武将身上的装备信息
function getEquipsOnHeros()
	local equipsOnHeros = {}
	local allHeros = HeroModel.getAllHeroes()
	for t_hid, t_hero in pairs(allHeros) do
		for equip_pos, equipInfo in pairs(t_hero.equip.arming) do
			if( not table.isEmpty(equipInfo) ) then
				equipInfo.pos = equip_pos
				equipInfo.hid = t_hid
				equipInfo.equip_hid = t_hid
				equipsOnHeros[equipInfo.item_id] = equipInfo
			end
		end
	end

	return equipsOnHeros
end

-- 获得主角身上的时装信息
function getFashionOnHeros()
	local fashionOnHeros = {}
	local allHeros = HeroModel.getAllHeroes()
	for t_hid, t_hero in pairs(allHeros) do
		for fashion_pos, fashionInfo in pairs(t_hero.equip.dress) do
			if( not table.isEmpty(fashionInfo) ) then
				fashionInfo.pos = fashion_pos
				fashionInfo.hid = t_hid
				fashionInfo.fashion_hid = t_hid
				fashionOnHeros[fashionInfo.item_id] = fashionInfo
			end
		end
	end
	return fashionOnHeros
end

-- 获得某个武将身上的装备
function getEquipsByHid( hid )
	local allHeros = HeroModel.getAllHeroes()
	for t_hid, t_hero in pairs(allHeros) do
		if(tonumber(t_hid) == tonumber(hid))then
			return t_hero.equip.arming
		end
	end
	return nil
end

-- add by chengliang
-- 获得武将身上的所有宝物
function getTreasOnHeros()
	local treasOnHeros = {}
	local allHeros = HeroModel.getAllHeroes()
	for t_hid, t_hero in pairs(allHeros) do
		for treas_pos, treasInfo in pairs(t_hero.equip.treasure) do
			if( not table.isEmpty(treasInfo) ) then
				treasInfo.pos = treas_pos
				treasInfo.hid = t_hid
				treasInfo.equip_hid = t_hid
				treasOnHeros[treasInfo.item_id] = treasInfo
			end
		end
	end
	return treasOnHeros
end

-- add by chengliang
-- 获得某个武将身上的宝物
function getTreasByHid( hid )
	local allHeros = HeroModel.getAllHeroes()
	for t_hid, t_hero in pairs(allHeros) do
		if(tonumber(t_hid) == tonumber(hid))then
			return t_hero.equip.treasure
		end
	end
	return nil
end

-- 获得所有武将身上镶嵌在宝物上的所有符印
function getAllRuneOnHeros()
	local allRune = {}
	local treasureArr = getTreasOnHeros()
	if(table.isEmpty(treasureArr))then
		return allRune
	end
	for item_id, itemInfo in pairs(treasureArr) do
		if( itemInfo.va_item_text and itemInfo.va_item_text.treasureInlay )then
			for k,v in pairs(itemInfo.va_item_text.treasureInlay) do
				if( not table.isEmpty(v) ) then
					allRune[v.item_id] = v
					allRune[v.item_id].pos = k
					allRune[v.item_id].treasureItemId = itemInfo.item_id
					allRune[v.item_id].hid = itemInfo.hid
					allRune[v.item_id].itemDesc = ItemUtil.getItemById(v.item_template_id)
				end
			end
		end
	end
	return allRune
end

-- 获得所有武将身上的战魂
function getAllFightSoulOnHeros()
	local allFightSoul = {}

	local formation = DataCache.getFormationInfo()
	for f_pos, f_hid in pairs(formation) do
		if( tonumber(f_hid)>0 )then
			local tempFightSoul = getFightSoulByHid( f_hid )
			for k,v in pairs(tempFightSoul) do
				if(not table.isEmpty(v))then
					allFightSoul[k] = v
					allFightSoul[k].itemDesc = ItemUtil.getItemById(v.item_template_id)
				end
			end
		end
	end
	return allFightSoul
end

-- 获得某个武将身上的战魂
function getFightSoulByHid( hid )
	local fightSoulTemp = {}
	local allHeros = HeroModel.getAllHeroes()
	if( (not table.isEmpty(allHeros["" .. hid].equip)) and   (not table.isEmpty(allHeros["" .. hid].equip.fightSoul)) )then
		local fightSoulTemp_t = allHeros["" .. hid].equip.fightSoul
		for t_pos, t_fightSoul in pairs(fightSoulTemp_t) do
			if( not table.isEmpty(t_fightSoul) ) then
				t_fightSoul.hid = hid
				t_fightSoul.equip_hid = hid
				t_fightSoul.pos = t_pos
				fightSoulTemp[t_fightSoul.item_id] = t_fightSoul
			end
		end
	end
	return fightSoulTemp
end

-- 获得所有武将身上的神兵
function getAllGodWeaponOnHeros()
	local allGodWeapon = {}
	local formation = DataCache.getFormationInfo()
	if(formation == nil)then
		return allGodWeapon
	end
	for f_pos, f_hid in pairs(formation) do
		if( tonumber(f_hid)>0 )then
			local tempGodWeapon = getGodWeaponByHid( f_hid )
			for k,v in pairs(tempGodWeapon) do
				if(not table.isEmpty(v))then
					allGodWeapon[k] = v
				end
			end
		end
	end
	return allGodWeapon
end

-- 获得某个武将身上的神兵
function getGodWeaponByHid( hid )
	local godWeaponTemp = {}
	local allHeros = HeroModel.getAllHeroes()
	if( (not table.isEmpty(allHeros)) and (not table.isEmpty(allHeros["" .. hid].equip)) and   (not table.isEmpty(allHeros["" .. hid].equip.godWeapon)) )then
		local godWeaponTemp_t = allHeros["" .. hid].equip.godWeapon
		for t_pos, t_god in pairs(godWeaponTemp_t) do
			if( not table.isEmpty(t_god) ) then
				t_god.hid = hid
				t_god.equip_hid = hid
				t_god.pos = t_pos
				godWeaponTemp[t_god.item_id] = t_god
				godWeaponTemp[t_god.item_id].itemDesc = ItemUtil.getItemById(t_god.item_template_id)
			end
		end
	end
	return godWeaponTemp
end

-- 获得所有武将身上的锦囊
function getAllPocketOnHeros()
	local allPocket = {}
	local formation = DataCache.getFormationInfo()
	if(formation == nil)then
		return allPocket
	end
	for f_pos, f_hid in pairs(formation) do
		if( tonumber(f_hid)>0 )then
			local tempPocket = getPocketByHid( f_hid )
			for k,v in pairs(tempPocket) do
				if(not table.isEmpty(v))then
					allPocket[k] = v
				end
			end
		end
	end
	return allPocket
end

-- 获得某个武将身上的锦囊
function getPocketByHid( hid )
	local pocketTemp = {}
	local allHeros = HeroModel.getAllHeroes()
	if( (not table.isEmpty(allHeros)) and (not table.isEmpty(allHeros["" .. hid].equip)) and   (not table.isEmpty(allHeros["" .. hid].equip.pocket)))then
		local pocketTemp_t = allHeros["" .. hid].equip.pocket
		for t_pos, t_pocket in pairs(pocketTemp_t) do
			if( not table.isEmpty(t_pocket) ) then
				t_pocket.hid = hid
				t_pocket.equip_hid = hid
				t_pocket.pos = t_pos
				pocketTemp[t_pocket.item_id] = t_pocket
				pocketTemp[t_pocket.item_id].itemDesc = ItemUtil.getItemById(t_pocket.item_template_id)
			end
		end
	end
	return pocketTemp
end

--[[
	@des 	: 获取武将身上所有的兵符
	@param 	: 
	@return : 
--]]
function getAllTallyOnHeros( ... )
	local allTally = {}
	local formation = DataCache.getFormationInfo()
	if(formation == nil)then
		return allTally
	end
	for f_pos, f_hid in pairs(formation) do
		if( tonumber(f_hid)>0 )then
			local tempTally = getTallyByHid( f_hid )
			for k,v in pairs(tempTally) do
				if(not table.isEmpty(v))then
					allTally[k] = v
				end
			end
		end
	end
	return allTally
end

--[[
	@des 	: 获取单个武将身上的所有兵符
	@param 	: 
	@return : 
--]]
function getTallyByHid( p_hid )
	local hid = p_hid
	local tallyTemp = {}
	local allHeros = HeroModel.getAllHeroes()
	if( (not table.isEmpty(allHeros)) and (not table.isEmpty(allHeros["" .. hid].equip)) and   (not table.isEmpty(allHeros["" .. hid].equip.tally)) )then
		local tallyTemp_t = allHeros["" .. hid].equip.tally
		for t_pos, v_info in pairs(tallyTemp_t) do
			if( not table.isEmpty(v_info) ) then
				v_info.hid = hid
				v_info.equip_hid = hid
				v_info.pos = t_pos
				tallyTemp[v_info.item_id] = v_info
				tallyTemp[v_info.item_id].itemDesc = ItemUtil.getItemById(v_info.item_template_id)
			end
		end
	end
	return tallyTemp
end

-- 计算某个htid的武将有多少个
function getHeroNumByHtid( h_tid )
	h_tid = tonumber(h_tid)
	local allHeros = HeroModel.getAllHeroes()
	local number = 0

	for k,v in pairs(allHeros) do
		if(tonumber(v.htid) == h_tid)then
			number = number + 1
		end
	end

	return number
end

--[[
    @des: 得到武将列表里所有与传入的htid相同的武将
--]]
function getHerosByHtid(htid)
	local allHeros = HeroModel.getAllHeroes()
	local heros = {}
	for hid, hero in pairs(allHeros) do
		if hero.htid == htid then
			table.insert(heros, hero)
		end
	end
	return heros
end

--[[
    @des: 对应的武将有没有可激活的觉醒能力
    @htid: 武将的htid
    @heroCopyId: 武将列传的ID 1简单 2普通 3困难
--]]
function couldActivateTalent(htid, heroCopyId)
    local allHeros = HeroModel.getAllHeroes()
    local heros = getHerosByHtid(htid)
    local heroDb = parseDB(DB_Heroes.getDataById(tonumber(htid)))
    for i = 1, #heros do
        local hero = heros[i]
        for talentIndex = 1, 2 do
            local sealedTalentId = hero.talent ~= nil and (hero.talent.sealed ~= nil and hero.talent.sealed[ tostring(talentIndex)] or nil) or nil
            -- 去掉武将列传Id判断，heroes表修改 20160407 lgx
            if sealedTalentId ~= nil and sealedTalentId ~= "0" and tonumber(hero.evolve_level) >= heroDb.hero_copy_id[heroCopyId][2] then
                return true
            end
        end
    end
    return false
end

--[[
    @des: 			合服后，主角名字是    原本的名字 + .s + 数字    的格式
                    这里做的是返回原本的名字
    @param:			合服后主角的名字
    @return:        原本的名字
--]]
function getOriginalName(p_name)
	--因为正规的名字字符串中没有空格，所以在末尾加入空格方便判断字符串结束，方便正则表达式匹配
	local tempName = p_name .. " "
	--要返回的名字
	local returnName = p_name

	--找到以.s开头后跟数字最后以空格结尾的字符串的开始位置
	local pos = string.find(tempName,"%.s%d+%s")
	--如果找到了
	if pos ~= nil then
		--返回子串前面的内容
		local subString = string.sub(p_name,1,pos - 1)
		returnName = subString
	end

	return returnName
end

--[[
    @des: 			判断是否是合服后的名字
    @param:			合服后主角的名字
    @return:        如果是合服后的名字 true
    				否则 false
--]]
function isMergeName(p_name)
	local isMerge = false
	local tempName = p_name .. " "
	--如果是合服后的名字
	if string.find(tempName,"%.s%d+%s") ~= nil then
		isMerge = true
	end

	return isMerge
end


--[[
    @des: 			根据htid判断是否曾经拥有过该英雄
    @param:
    @return:        拥有过 true
    				否则 false
--]]
function doOnceHasHero( pHtid )
	require "script/ui/menu/IllustratUtil"
	local heroIllustrateData = IllustratUtil.getHeroBook()
	--判断是否拥有过
	local ret = false
	if pHtid ~= nil and not table.isEmpty(heroIllustrateData) then
		for k,v in pairs(heroIllustrateData) do
			if tonumber(v) == tonumber(pHtid) then
				ret = true
				break
			end
		end
	end
	return ret
end

--[[
    @des: 			根据htid判断是否曾经进化过为橙卡(进化程卡后被炼化)
    @param:
    @return:        进化过 橙卡htid
    				否则 当前htid
--]]
function getOnceOrangeHtid( pHtid )
	pHtid = tonumber(pHtid)
	local localInfo = getHeroLocalInfoByHtid(pHtid)
	if localInfo == nil or localInfo.evolveId == nil then
		return pHtid
	end
	require "db/DB_Hero_evolve"
	local orangeInfo = DB_Hero_evolve.getDataById(localInfo.evolveId)
	if orangeInfo ~= nil and doOnceHasHero(orangeInfo.afteRevolveTid) then
		--return orangeInfo.afteRevolveTid
		return getOnceRedHtid( orangeInfo.afteRevolveTid )
	end
	return pHtid
end
--[[
    @des: 			根据htid判断是否曾经进化过为橙卡(进化程卡后被炼化)
    @param:
    @return:        进化过 橙卡htid
    				否则 当前htid
--]]
function getOnceRedHtid( pHtid )
	pHtid = tonumber(pHtid)
	local localInfo = getHeroLocalInfoByHtid(pHtid)
	if localInfo == nil or localInfo.evolveId == nil then
		return pHtid
	end
	require "db/DB_Hero_evolve"
	local redInfo = DB_Hero_evolve.getDataById(localInfo.evolveId)
	if redInfo ~= nil and doOnceHasHero(redInfo.afteRevolveTid) then
		return redInfo.afteRevolveTid
	end
	return pHtid
end
--[[
    @des: 			得到武将类型的Sprite
    @param:			武将类型
    				1 为 物攻型
    				2 为 法攻型
    @return:        创建好的Sprite
--]]
function createHeroTypeSprite(p_heroType)
	local typeSprite = CCSprite:create("images/formation/newType.png")

    local typeStr = ""
    local typeColor = nil
    if(p_heroType == 1)then
    	typeColor = ccc3(0xf0,0x4a,0x3c)
    	typeStr = GetLocalizeStringBy("djn_91")
    elseif(p_heroType == 2)then
    	typeStr = GetLocalizeStringBy("djn_92")
    	typeColor = ccc3(0x00,0xe4,0xff)
    end

    local typeLabel = CCRenderLabel:create(typeStr, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    typeLabel:setColor(typeColor)
    typeLabel:setAnchorPoint(ccp(0.5,0.5))
    typeLabel:setPosition(typeSprite:getContentSize().width *0.5,typeSprite:getContentSize().height *0.55)
    typeSprite:addChild(typeLabel)

    return typeSprite
end

--[[
    @des                    : 得到新的玩家信息条

    @param:	$ p_level 		: 玩家等级
    @param:	$ p_name 		: 玩家名字
    @param:	$ p_vipLv 		: 玩家vip级别
    @param:	$ p_silver 		: 银币数量
    @param:	$ p_gold 		: 金币数量

    @return                 : 背景sprite
    @return                 : 银币label （返回银币和金币label是为了可以更改金银币的值）
    @return                 : 金币label
--]]
function createNewAttrBgSprite(p_level,p_name,p_vipLv,p_silver,p_gold)
	local topBgSprite = CCSprite:create("images/hero/another_attr_bg.png")

	local topBgSize = topBgSprite:getContentSize()

	local lvSp = CCSprite:create("images/common/lv.png")
    lvSp:setAnchorPoint(ccp(0.5,0.5))
    lvSp:setPosition(topBgSize.width*0.07,topBgSize.height*0.43)
    topBgSprite:addChild(lvSp)

    local lvLabel = CCLabelTTF:create(p_level,g_sFontName,23)
    lvLabel:setColor(ccc3(0xff,0xf6,0x00))
    lvLabel:setAnchorPoint(ccp(0.5,0.5))
    lvLabel:setPosition(topBgSize.width*0.07+lvSp:getContentSize().width,topBgSize.height*0.43)
    topBgSprite:addChild(lvLabel)

    local nameLabel= CCLabelTTF:create(p_name,g_sFontName,23)
    nameLabel:setPosition(topBgSize.width*0.17,topBgSize.height*0.43)
    nameLabel:setAnchorPoint(ccp(0,0.5))
    nameLabel:setColor(ccc3(0x70,0xff,0x18))
    topBgSprite:addChild(nameLabel)

    local vipSp = CCSprite:create ("images/common/vip.png")
	vipSp:setPosition(topBgSize.width*0.44,topBgSize.height*0.43)
	vipSp:setAnchorPoint(ccp(0,0.5))
	topBgSprite:addChild(vipSp)

	require "script/libs/LuaCC"
    local vipNumSp = LuaCC.createSpriteOfNumbers("images/main/vip",p_vipLv,15)
    vipNumSp:setPosition(topBgSize.width*0.44+vipSp:getContentSize().width,topBgSize.height*0.43)
    vipNumSp:setAnchorPoint(ccp(0,0.5))
    topBgSprite:addChild(vipNumSp)

    local silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(p_silver),g_sFontName,18)  -- modified by yangrui at 2015-12-03
    silverLabel:setColor(ccc3(0xe5,0xf9,0xff))
    silverLabel:setAnchorPoint(ccp(0,0.5))
    silverLabel:setPosition(topBgSize.width*0.62,topBgSize.height*0.43)
    topBgSprite:addChild(silverLabel)

    local goldLabel = CCLabelTTF:create(p_gold,g_sFontName,18)
    goldLabel:setColor(ccc3(0xff,0xe2,0x44))
    goldLabel:setAnchorPoint(ccp(0,0.5))
    goldLabel:setPosition(topBgSize.width*0.84,topBgSize.height*0.43)
    topBgSprite:addChild(goldLabel)

    return topBgSprite,silverLabel,goldLabel
end

--[[
	@des: 得到指定部队id的boss 数据信息
--]]
function getBossInfoByArmyId( p_armyId )
	require "db/DB_Army"
	require "db/DB_Team"
	local armyInfo = DB_Army.getDataById(p_armyId)
	local teamId   = armyInfo.monster_group
	local teamInfo = DB_Team.getDataById(teamId)
	local bossId   = teamInfo.bossID or teamInfo.outlineId or teamInfo.demonLoadId
	if DB_Heroes.getDataById(bossId) then
		return DB_Heroes.getDataById(bossId)
	else
		require "db/DB_Monsters"
		require "db/DB_Monsters_tmpl"
		local monsterId = DB_Monsters.getDataById(bossId).htid
		local monsertInfo = DB_Monsters_tmpl.getDataById(monsterId)
		return monsertInfo
	end
end

--[[
	@des: 得到指定部队的boss 全身像
--]]
function getBossBoyImgByArmyId( p_armyId )
	local monserInfo = getBossInfoByArmyId(p_armyId)
	local sprite = CCSprite:create("images/base/hero/body_img/" .. monserInfo.body_img_id)
	return sprite
end

