-- Filename: RefiningPreviewUtil.lua
-- Author: lgx
-- Date: 2016-05-12
-- Purpose: 炼化/重生预览工具类

module("RefiningPreviewUtil", package.seeall)
require "script/libs/LuaCC"
require "script/model/utils/HeroUtil"
require "db/DB_Heroes"
require "script/ui/hero/HeroPublicLua"

--[[
	@desc 	: 创建 武将/物品 图标/按钮
	@param 	: pItemInfo 	 武将/物品信息
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZOrder 		 显示层级
	@return : sprite/item    图标/按钮
--]]
function createRewardItem( pItemInfo, pTouchPriority, pZOrder )

	local touchPriority = pTouchPriority or -1000
	local zOrder = pZorder or 1000

	local iconBg = nil
	local iconName = nil
	local nameColor = nil

	if(pItemInfo.type == "silver") then
		-- 银币
		iconBg= ItemSprite.getSiliverIconSprite()
		iconName = GetLocalizeStringBy("key_1687")
		local quality = ItemSprite.getSilverQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	elseif(pItemInfo.type == "soul") then
		-- 将魂
		iconBg= ItemSprite.getSoulIconSprite()
		iconName = GetLocalizeStringBy("key_1616")
		local quality = ItemSprite.getSoulQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	elseif(pItemInfo.type == "gold") then
		-- 金币
		iconBg= ItemSprite.getGoldIconSprite()
		iconName = GetLocalizeStringBy("key_1491")
		local quality = ItemSprite.getGoldQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	elseif(pItemInfo.type == "item") then
		-- 物品
		if (tonumber(pItemInfo.tid) >= 400001 and tonumber(pItemInfo.tid) <= 500000) then
			-- 特殊需求 点击武魂图标查看武将信息
			iconBg = ItemSprite.getHeroSoulSprite(tonumber(pItemInfo.tid),touchPriority-35,zOrder+1,touchPriority-40)
			local itemData = ItemUtil.getItemById(pItemInfo.tid)
	        iconName = itemData.name
	        nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
	    else
			-- 物品
			iconBg =  ItemSprite.getItemSpriteById(tonumber(pItemInfo.tid),nil, nil, nil, touchPriority-35,zOrder+1,touchPriority-40)
			local itemData = ItemUtil.getItemById(pItemInfo.tid)
	        iconName = ItemUtil.getItemNameByTid(pItemInfo.tid)
	        nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
	    end
	elseif(pItemInfo.type == "hero") then
		-- 英雄
		
		iconBg = ItemSprite.getHeroIconItemByhtid(pItemInfo.tid,touchPriority-35,zOrder+1,touchPriority-40)
		local heroData = DB_Heroes.getDataById(pItemInfo.tid)
		iconName = heroData.name
		nameColor = HeroPublicLua.getCCColorByStarLevel(heroData.star_lv)
	elseif(pItemInfo.type == "prestige") then
		-- 声望
		iconBg= ItemSprite.getPrestigeSprite()
		iconName = GetLocalizeStringBy("key_2231")
		local quality = ItemSprite.getPrestigeQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(pItemInfo.type == "jewel") then
		-- 魂玉
		iconBg= ItemSprite.getJewelSprite()
		iconName = GetLocalizeStringBy("key_1510")
		local quality = ItemSprite.getJewelQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(pItemInfo.type == "execution") then
		-- 体力
		iconBg= ItemSprite.getExecutionSprite()
		iconName = GetLocalizeStringBy("key_1032")
		local quality = ItemSprite.getExecutionQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(pItemInfo.type == "stamina") then
		-- 耐力
		iconBg= ItemSprite.getStaminaSprite()
		iconName = GetLocalizeStringBy("key_2021")
		local quality = ItemSprite.getStaminaQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(pItemInfo.type == "honor") then
		-- 荣誉
		iconBg= ItemSprite.getHonorIconSprite()
		iconName = GetLocalizeStringBy("lcy_10040")
		local quality = ItemSprite.getHonorQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(pItemInfo.type == "contri") then
		-- 贡献
		iconBg= ItemSprite.getContriIconSprite()
		iconName = GetLocalizeStringBy("lcy_10041")
		local quality = ItemSprite.getContriQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(pItemInfo.type == "grain") then
		-- 贡献
		iconBg= ItemSprite.getGrainSprite()
		iconName = GetLocalizeStringBy("lcyx_101")
		local quality = ItemSprite.getGrainQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(pItemInfo.type == "coin") then
		-- 神兵令
		iconBg= ItemSprite.getGodWeaponTokenSprite()
		iconName = GetLocalizeStringBy("lcyx_149")
		local quality = ItemSprite.getGodWeaponTokenSpriteQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(pItemInfo.type == "zg") then
		-- 战功
		iconBg= ItemSprite.getBattleAchieIcon()
		iconName = GetLocalizeStringBy("lcyx_1819")
		local quality = ItemSprite.getBattleAchieQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(pItemInfo.type == "tg_num") then
		-- 天工令
		iconBg= ItemSprite.getTianGongLingIcon()
		iconName = GetLocalizeStringBy("lic_1561")
		local quality = ItemSprite.getTianGongLingQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(pItemInfo.type == "wm_num") then
		-- 争霸令
		iconBg= ItemSprite.getWmIcon()
		iconName = GetLocalizeStringBy("lcyx_1912")
		local quality = ItemSprite.getWmQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(pItemInfo.type == "hellPoint") then
		-- 炼狱令
		iconBg= ItemSprite.getHellPointIcon()
		iconName = GetLocalizeStringBy("lcyx_1917")
		local quality = ItemSprite.getHellPointQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif (pItemInfo.type == "cross_honor" ) then
		-- 跨服比武  add by yangrui 15-10-13
		iconBg = ItemSprite.getKFBWHonorIcon()
		iconName = GetLocalizeStringBy("yr_2002")
		local quality = ItemSprite.getKFBWHonorQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif (pItemInfo.type == "fs_exp" ) then
    	-- 战魂经验
		iconBg = ItemSprite.getFSExpIconSprite()
		iconName = GetLocalizeStringBy("lic_1736")
		local quality = ItemSprite.getFSExpQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif (pItemInfo.type == "jh") then
    	-- 将星
    	iconBg = ItemSprite.getHeroJhIcon()
		iconName = GetLocalizeStringBy("syx_1053")
		local quality = ItemSprite.getHeroJhQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif (pItemInfo.type == "copoint") then
    	-- 国战积分
    	iconBg = ItemSprite.getCopointIcon()
		iconName = GetLocalizeStringBy("fqq_015")
		local quality = ItemSprite.getCopointQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
     elseif (pItemInfo.type == "tally_point" ) then 
    	-- 兵符积分
		iconBg = ItemSprite.getTallyPointIcon()
		iconName = GetLocalizeStringBy("syx_1072")
		local quality = ItemSprite.getTallyPointQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif (pItemInfo.type == "book_num" ) then 
    	-- 科技图纸
		iconBg = ItemSprite.getBookIcon()
		iconName = GetLocalizeStringBy("lic_1812")
		local quality = ItemSprite.getBookQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    else

	end

	-- 物品数量 34 或 0~75
	local numStr = nil
	if( pItemInfo.num ~= nil and tonumber(pItemInfo.num) > 0 )then
		numStr = tostring(pItemInfo.num)
	elseif (pItemInfo.numStr ~= nil) then
		numStr = pItemInfo.numStr
	end

	if (numStr ~= nil) then
		local numberLabel = CCRenderLabel:create(numStr,g_sFontName,21,2,ccc3(0x00,0x00,0x00),type_stroke)
		numberLabel:setColor(ccc3(0x00,0xff,0x18))
		numberLabel:setAnchorPoint(ccp(0,0))
		local width = iconBg:getContentSize().width - numberLabel:getContentSize().width - 6
		numberLabel:setPosition(ccp(width,5))
		iconBg:addChild(numberLabel,100)
	end

	-- 武将进阶等级
	if( pItemInfo.evolveLevel ~= nil and tonumber(pItemInfo.evolveLevel) > 0 )then
		createHeroEvolveLevelSprite(pItemInfo.evolveLevel, pItemInfo.tid, iconBg)
	end

	--- 物品名字
	local descLabel = CCRenderLabel:create("" .. iconName , g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	descLabel:setColor(nameColor)
	descLabel:setAnchorPoint(ccp(0.5,0.5))
	descLabel:setPosition(ccp(iconBg:getContentSize().width*0.5 ,-iconBg:getContentSize().height*0.2))
	iconBg:addChild(descLabel)

	return iconBg
end

--[[
	@desc	: 创建武将进阶等级Sprite
	@param 	: pEvolveLevel 	武将进阶等级
	@param 	: pHtid 		武将模板ID
	@param 	: pParentNode 	要添加到的父节点
	@return : 
--]]
function createHeroEvolveLevelSprite( pEvolveLevel, pHtid, pParentNode )
	local evolveLevel = pEvolveLevel or 0
	local htid = pHtid or 0
	if ( tonumber(evolveLevel) < 1 or tonumber(htid) < 1 or pParentNode == nil ) then
		return
	end

	local tEvolveSize = {width=0, height=0}
	local tElements = {
 		{ctype = LuaCC.m_ksTypeSprite, file = "images/hero/transfer/numbers/add.png", hOffset = 0},
 	}
 	local heroDB = HeroUtil.getHeroLocalInfoByHtid(tonumber(htid) )
	if heroDB.star_lv >=6 then
		tElements = {}
	end
 	local sEvolveLevel = tostring(evolveLevel)
	for i=1, #sEvolveLevel do
	 	local sImageFile = "images/hero/transfer/numbers/"..(string.byte(sEvolveLevel, i)-48)..".png"
		table.insert(tElements, {ctype=LuaCC.m_ksTypeSprite, file=sImageFile, hOffset=0} )
	end

	--橙卡显示“？阶”
	if heroDB.star_lv >=6 then
		table.insert(tElements,{ctype=LuaCC.m_ksTypeRenderLabel, text=GetLocalizeStringBy("zz_100"), strokeSize=1, color = ccc3(0x00,0xff,0x00), fontname=g_sFontPangWa, strokeColor=ccc3(0x00,0x00,0x00), vOffset=32})
	end
	tObjs = LuaCC.createCCNodesOnHorizontalLine(tElements)
	tObjs[1]:setAnchorPoint(ccp(0, 0))
	for i=1, #tObjs do
		tEvolveSize.width = tEvolveSize.width + tObjs[i]:getContentSize().width
	end
	local tParentSize = pParentNode:getContentSize()
	tObjs[1]:setPosition((tParentSize.width- tEvolveSize.width)/2, -4)

	pParentNode:addChild(tObjs[1])
end