-- Filename: TreasureUtil.lua
-- Author: lichenyang
-- Date: 2013-11-5
-- Purpose: 宝物数据处理层

module("TreasureUtil", package.seeall)

require "script/model/utils/HeroUtil"


--[[
	@des:		得到碎片卡牌图片
	@param:		fragment_tid  碎片模板id
	@return:	图标sprite
]]
function getFragmentCardSprite( fragment_tid )
	require "db/DB_Item_treasure_fragment"
	local tableInfo = DB_Item_treasure_fragment.getDataById(fragment_tid)
	local bgSprite = CCSprite:create("images/item/equipinfo/card/equip_" .. tableInfo.quality .. ".png")
	return bgSprite
end

--[[
	@des:		得到碎片图片
	@param:		fragment_tid  碎片模板id
	@return:	图标sprite
]]
function getFragmentIcon( fragment_tid )
	local tableInfo = DB_Item_treasure_fragment.getDataById(fragment_tid)

	bgFile = "images/base/potential/props_" .. tableInfo.quality .. ".png"
	iconFile = "images/base/props/" .. tableInfo.icon_small
	local item_sprite = CCSprite:create(bgFile)
	local icon_sprite = CCSprite:create(iconFile)
	icon_sprite:setAnchorPoint(ccp(0.5, 0.5))
	icon_sprite:setPosition(ccp(item_sprite:getContentSize().width/2, item_sprite:getContentSize().height/2))	
	item_sprite:addChild(icon_sprite)

	return item_sprite
end

--[[
	@des:	创建一个碎片按钮
]]
function createFragmentItem( ... )
	-- body
end

--[[
	@des:		通过概率获得夺宝的成功的描述
	@param:		percent   
	@return:    GetLocalizeStringBy("key_3047") ...
	@author:	zhz
]]
function getFragmentPercentDesc(tPerct )
	-- local tableInfo = DB_Item_treasure_fragment.getDataById(fragment_tid)
	require "db/DB_Loot"
	tPerct = tonumber(tPerct)
	local lootInfo = DB_Loot.getDataById(1)
	local percents = lua_string_split(lootInfo.ratioArr,",")
	local descArr = lua_string_split(lootInfo.ratioDec, ",")
	for i=1, #percents do 
		if(tPerct <= tonumber(percents[i])) then
			return descArr[i]
		end
	end
	return GetLocalizeStringBy("key_1219")
end

--[[
	@des:		通过 isnpc 和 squad 获得 要抢夺的头像
	@param:		isnpc ,    item_temple_id
	@return:    对应的头像
]]
function getRobberHeadIcon( npc, squad, vip )
	require "script/ui/hero/HeroPublicCC"
	require "db/DB_Monsters_tmpl"
	npc = tonumber(npc)
	local headSprite
	if(npc==0 ) then
		local dressId= nil
		if(squad.dress and not table.isEmpty(squad.dress)) then
			dressId = tonumber(squad.dress["1"] )
		end
		print(" squad.htid is ", squad.htid , " dressId  is : ", dressId)
		headSprite= HeroUtil.getHeroIconByHTID(tonumber(squad.htid), dressId, nil,vip) ---HeroPublicCC.getCMISHeadIconByHtid(squad.htid)
	elseif(npc==1) then
		headSprite=  getMonsterHeadIconByHtid(squad)
	end

	return headSprite
	
end

-- 通过htid 获得monster_tmple表里的数据
function getMonsterHeadIconByHtid( htid )
	require "db/DB_Monsters_tmpl"
	local db_hero = DB_Monsters_tmpl.getDataById(htid)
	local sHeadIconImg="images/base/hero/head_icon/" .. db_hero.head_icon_id
	local sQualityBgImg="images/hero/quality/"..db_hero.star_lv .. ".png"
	local sQualityLightedImg="images/hero/quality/highlighted.png"

	local csQuality = CCSprite:create(sQualityBgImg)
	local csQualityLighted = CCSprite:create(sQualityBgImg)
	local csFrame = CCSprite:create(sQualityLightedImg)
	csFrame:setAnchorPoint(ccp(0.5, 0.5))
	csFrame:setPosition(csQualityLighted:getContentSize().width/2, csQualityLighted:getContentSize().height/2)
	csQualityLighted:addChild(csFrame)

	-- 武将头像图标，普通状态
	local csHeadIconNormal = CCSprite:create(sHeadIconImg)
	csHeadIconNormal:setPosition(ccp(9, 8))
	csQuality:addChild(csHeadIconNormal)
	-- 武将头像图标，高亮状态
	local csHeadIconHighlighted = CCSprite:create(sHeadIconImg)
	csHeadIconHighlighted:setPosition(ccp(9, 8))
	csQualityLighted:addChild(csHeadIconHighlighted)
	-- 武将头像图标，灰色状态
	local csHeadIconGray = BTGraySprite:create(sHeadIconImg)
	csHeadIconGray:setPosition(ccp(9, 8))
	local csDisabled = BTGraySprite:create(sQualityBgImg)
	csDisabled:addChild(csHeadIconGray)
	local cmisHeadIcon = CCMenuItemSprite:create(csQuality, csQualityLighted, csDisabled)

	return cmisHeadIcon
end

--[[
	@des:		根据star_lv 来排序阵容
	@param:		squad
	@return :
--]]
function sortQuad( squad, npc)
	require "db/DB_Monsters_tmpl"
	require "db/DB_Heroes"
	npc= tonumber(npc)
	local sortQuad= {}
	if(1==npc) then
		local function keySort ( w1 , w2 )
			local  dataW1 = DB_Monsters_tmpl.getDataById(w1) 
			local dataW2 = DB_Monsters_tmpl.getDataById(w2)
     		-- return tonumber(dataW1.star_lv) > tonumber(dataW2.star_lv) 
     		if(tonumber(dataW1.star_lv) > tonumber(dataW2.star_lv)) then
     			return true 
     		elseif(tonumber(dataW1.star_lv) == tonumber(dataW2.star_lv) and tonumber(dataW1.id) > tonumber( dataW2.id)) then
     			return true
     		else
     			return false
     		end
    	end
    	table.sort( squad, keySort )
	else
		local function keySort ( w1 , w2 )
			local  dataW1 = DB_Heroes.getDataById(w1.htid) 
			local dataW2 = DB_Heroes.getDataById(w2.htid)
     		-- return tonumber(dataW1.star_lv) > tonumber(dataW2.star_lv)
     		if(tonumber(dataW1.star_lv) > tonumber(dataW2.star_lv)) then
     			return true 
     		elseif(tonumber(dataW1.star_lv) == tonumber(dataW2.star_lv) and tonumber(dataW1.id) > tonumber( dataW2.id)) then
     			return true
     		else
     			return false
     		end
    	end
    	table.sort( squad, keySort)

	end
	return squad
end

--[[
	@des:		得到宝物大图标
]]
function getTreasureBigIcon( treasure_id )
	local treasureInfo 	= DB_Item_treasure.getDataById(treasure_id)
	local sprite 		= CCSprite:create("images/base/treas/big/" .. treasureInfo.icon_big)
	return sprite
end


--[[
	@des:		得到品质颜色
]]
function getTreasureColor( treasure_id )
	require "script/ui/hero/HeroPublicLua"
	local treasureInfo 	= DB_Item_treasure.getDataById(treasure_id)
	local nameColor = HeroPublicLua.getCCColorByStarLevel(treasureInfo.quality)
	return nameColor
end

-- 
function getPercentColorByName(desc  )
	require "db/DB_Loot"
	local lootInfo = DB_Loot.getDataById(1)
	local percents = lua_string_split(lootInfo.ratioArr,",")
	local descArr = lua_string_split(lootInfo.ratioDec, ",")
	if(desc== descArr[1] or desc ==descArr[2] or  desc ==descArr[3] ) then
		return ccc3(0x36,0xff,0x00)
	elseif(desc == descArr[4]or desc== descArr[5] ) then
		return 	ccc3(0x51, 0xfb, 0xff)
		--{0x51, 0xfb, 0xff},
	elseif(  desc== descArr[6] or desc== descArr[7]) then
		return ccc3(255, 0, 0xe1)
	else
		return ccc3(0x36,0xff,0x00)
	end	
end

--[[
	@des:得到宝物精炼等级图标
	@ret:sprite
--]]
function getFixedLevelSprite( pItemLevel )
	local icons = {
		[-1] = "images/common/big_gem.png",
		[0] = "images/common/big_gem.png",
		[1] = "images/common/effect/diamond"
	}
	local level = math.floor(tonumber(pItemLevel-1)/10) 
	local path = icons[level]
	local sprite = XMLSprite:create(path)
	print("itemLevel", pItemLevel)
	print("path", path)
	return sprite
end

