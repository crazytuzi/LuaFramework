-- Filename: TitleEquipCell.lua
-- Author: lgx
-- Date: 2016-05-04
-- Purpose: 称号列表Cell

module("TitleEquipCell", package.seeall)
require "script/ui/title/TitleDef"
require "script/ui/title/TitleMainLayer"
require "script/ui/title/TitleData"
require "script/ui/title/TitleController"
require "script/ui/title/TitleUtil"
require "script/ui/item/ItemUtil"

--[[
	@desc 	: 创建称号Cell
	@param 	: pTitleData 称号信息 pIndex 索引
	@return : 
--]]
function createCell( pTitleData , pIndex )
	local cell = CCTableViewCell:create()

	-- 称号状态 1 已装备 2 已获得(待装备) 3 未获得(去获取)
	-- kTitleStatusEquiped = 1
	-- kTitleStatusIsGot   = 2
	-- kTitleStatusNotGot  = 3
	local titleStatus = TitleData.getTitleStatusById(pTitleData.signid)
	-- print("TitleEquipCell titleStatus",titleStatus)
	-- Cell背景
	local fullRect = CCRectMake(0,0,88,91)
	local insetRect = CCRectMake(40,42,6,4)
	local cellBgFile = "title_cell_bg_n.png"
	local curOpneIndex = TitleMainLayer.getOpenIndex()
	if (pIndex == curOpneIndex) then
		cellBgFile = "title_cell_bg_h.png"
	end
	local cellBg = CCScale9Sprite:create("images/common/bg/"..cellBgFile,fullRect, insetRect)
	cellBg:setContentSize(CCSizeMake(640,91))
	cellBg:setAnchorPoint(ccp(0,0))
	cellBg:setPosition(ccp(0,0))
	cell:addChild(cellBg)

	-- 称号特效
    local titleEffect = nil
    local timeColor = nil

    -- 未获得或失效 置灰
    if (titleStatus == TitleDef.kTitleStatusNotGot) then
    	titleEffect = TitleUtil.createTitleGraySpriteById(pTitleData.signid)
    	timeColor = ccc3(0x64,0x64,0x64)
    else
    	titleEffect = TitleUtil.createTitleNormalSpriteById(pTitleData.signid)
    	timeColor = ccc3(0x00,0xff,0x18)
   	end

    titleEffect:setPosition(ccp(105,cellBg:getContentSize().height*0.5))
    titleEffect:setAnchorPoint(ccp(0.5,0.5))
    cellBg:addChild(titleEffect)

    -- 称号获取途径
    local desLabel = CCLabelTTF:create(pTitleData.signdes,g_sFontPangWa,25)
    desLabel:setColor(ccc3(0x78,0x25,0x00))
    desLabel:setPosition(215,cellBg:getContentSize().height/2)
    desLabel:setAnchorPoint(ccp(0,0.5))
    cellBg:addChild(desLabel)

	-- 展开背景高度
	local openBgHeight = 107
	local addHeight = openBgHeight-10
	-- 展开按钮
	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setTouchPriority(-755)
	cellBg:addChild(menu)

	local normal = CCMenuItemImage:create("images/common/cell_pulldown_n.png", "images/common/cell_pulldown_h.png")
	local hight  = CCMenuItemImage:create("images/common/cell_pullup_n.png", "images/common/cell_pullup_h.png")
	hight:setAnchorPoint(ccp(0.5, 0.5))
	normal:setAnchorPoint(ccp(0.5, 0.5))
	local openMenuItem = CCMenuItemToggle:create(normal)
	openMenuItem:setAnchorPoint(ccp(0.5, 0.5))
	openMenuItem:addSubItem(hight)
	menu:addChild(openMenuItem)
	openMenuItem:setPosition(ccp(cellBg:getContentSize().width*0.88,cellBg:getContentSize().height*0.35))
	openMenuItem:setEnabled(false)

	-- 展开按钮
	local curOpneIndex = TitleMainLayer.getOpenIndex()
	if(pIndex == curOpneIndex)then
		openMenuItem:setSelectedIndex(1)
		local openBg = CCScale9Sprite:create("images/title/title_add_bg.png")
		openBg:setContentSize(CCSizeMake(636,openBgHeight))
        openBg:setAnchorPoint(ccp(0.5,0))
        openBg:setPosition(320,-5)
        cell:addChild(openBg)
        cellBg:setAnchorPoint(ccp(0.5,0))
		cellBg:setPosition(openBg:getPositionX(),addHeight)

		-- 称号属性
	    local attrLabel = CCRenderLabel:create(GetLocalizeStringBy("lgx_1035") , g_sFontName,22,1, ccc3(0x00,0x00,0x00), type_stroke)
	    attrLabel:setColor(ccc3(0xff,0xff,0xff))
	    attrLabel:setPosition(ccp(5, openBg:getContentSize().height-15))
	    attrLabel:setAnchorPoint(ccp(0,1))
	    openBg:addChild(attrLabel)
	    
	    -- 增加全体上阵武将的属性提示
	    local pYPos = 0.5 -- 装备/去获取 按钮的位置百分比
	    if (pTitleData.property_type == TitleDef.kTitleAttrAll) then
	    	local attrAllStrLabel = CCRenderLabel:create(GetLocalizeStringBy("lgx_1067"),g_sFontName,22,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			attrAllStrLabel:setColor(ccc3(0x00,0xff,0x18))
			attrAllStrLabel:setAnchorPoint(ccp(1,1))
			attrAllStrLabel:setPosition(ccp(openBg:getContentSize().width*0.98, openBg:getContentSize().height-10))
			openBg:addChild(attrAllStrLabel)
			pYPos = 0.4
	    end

	    -- 属性数值
	    local i = 0
	    local attrInfo = TitleData.getTitleEquipAttrInfoById(pTitleData.signid)
	    for k,v in pairs(attrInfo) do
	    	local row = math.floor(i/3)+1
 			local col = i%3+1
	    	local affixDesc, displayNum, realNum = ItemUtil.getAtrrNameAndNum(k,v)
	    	local attrStr = affixDesc.sigleName .. "+" .. displayNum
	    	local attrStrLabel = CCRenderLabel:create(attrStr,g_sFontName,22,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			attrStrLabel:setColor(ccc3(0xff,0xf6,0x00))
			attrStrLabel:setAnchorPoint(ccp(0,1))
			attrStrLabel:setPosition(ccp(125+110*(col-1), openBg:getContentSize().height-(15+25*(row-1))))
			openBg:addChild(attrStrLabel)
	    	i = i+1
	    end

	    -- 剩余时间
	    local timeLabel = CCRenderLabel:create(GetLocalizeStringBy("lgx_1036") , g_sFontName,22,1, ccc3(0x00,0x00,0x00), type_stroke)
	    timeLabel:setColor(ccc3(0xff,0xff,0xff))
	    timeLabel:setPosition(ccp(5, 10))
	    timeLabel:setAnchorPoint(ccp(0,0))
	    openBg:addChild(timeLabel)

	    local timeStr = GetLocalizeStringBy("lgx_1039")
	    local disappearTime = 0
	    if (pTitleData.time_type == TitleDef.kTimeTypeLimited) then
	    	disappearTime = tonumber(pTitleData.deadline)
	    	timeStr = TitleUtil.getRemainTime(disappearTime)
	    end

	    local cutTimeLabel = CCRenderLabel:create(timeStr , g_sFontName,22,1, ccc3(0x00,0x00,0x00), type_stroke)
	    cutTimeLabel:setColor(ccc3(0xff,0x00,0x00))
	    cutTimeLabel:setPosition(ccp(125,10))
	    cutTimeLabel:setAnchorPoint(ccp(0,0))
	    openBg:addChild(cutTimeLabel)

	    local serverTime = TimeUtil.getSvrTimeByOffset()
	    if ((disappearTime > serverTime) and (titleStatus ~= TitleDef.kTitleStatusNotGot)) then
	    	-- 起定时器
	    	schedule(openBg,function()
	    		cutTimeLabel:setString(TitleUtil.getRemainTime(disappearTime))
	    		-- 判断是否到失效时间
	    		local curServerTime = TimeUtil.getSvrTimeByOffset()
	    		if (disappearTime <= curServerTime) then
	    			-- 停定时器
	    			cutTimeLabel:stopAllActions()
	    			-- 刷新列表
	    			TitleMainLayer.updateTitleListWithIsOffset(true)
	    		end
	    	end,1)
	    end

		if (titleStatus == TitleDef.kTitleStatusEquiped) then
			-- 已装备
			local equipedSprite = CCSprite:create("images/common/had_equiped.png")
			equipedSprite:setAnchorPoint(ccp(0.5,0.5))
			equipedSprite:setPosition(ccp(openBg:getContentSize().width*0.85, openBg:getContentSize().height*pYPos))
			openBg:addChild(equipedSprite)
		else
			-- 按钮菜单
			local buttnMenu = CCMenu:create()
			buttnMenu:setPosition(ccp(0,0))
			buttnMenu:setTouchPriority(-788)
			openBg:addChild(buttnMenu)

			if (titleStatus == TitleDef.kTitleStatusIsGot) then
				-- 装备
				require "script/libs/LuaCC"
				local equipItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(120, 64), GetLocalizeStringBy("key_2025"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
				equipItem:setAnchorPoint(ccp(0.5, 0.5))
				equipItem:registerScriptTapHandler(equipItemCallback)
				buttnMenu:addChild(equipItem, 1, pTitleData.signid)
				equipItem:setPosition(ccp(openBg:getContentSize().width*0.85, openBg:getContentSize().height*pYPos))
			else
				if (tonumber(pTitleData.reachpath) == 3) then
					-- 3.活动/充值：不跳转 显示: "通过活动获取"
					local pathLabel = CCRenderLabel:create(GetLocalizeStringBy("lgx_1044") , g_sFontName,22,1, ccc3(0x00,0x00,0x00), type_stroke)
				    pathLabel:setColor(ccc3(0xff,0xff,0xff))
				    pathLabel:setPosition(ccp(openBg:getContentSize().width*0.95, openBg:getContentSize().height*pYPos))
				    pathLabel:setAnchorPoint(ccp(1,0.5))
				    openBg:addChild(pathLabel)
				else
					-- 去获得
				    local gotoItem = CCMenuItemImage:create("images/common/btn/btn_title_get_n.png", "images/common/btn/btn_title_get_h.png")
					gotoItem:setAnchorPoint(ccp(0.5, 0.5))
					gotoItem:registerScriptTapHandler(goToItemCallback)
					buttnMenu:addChild(gotoItem, 1, tonumber(pTitleData.reachpath))
					gotoItem:setPosition(ccp(openBg:getContentSize().width*0.85, openBg:getContentSize().height*pYPos))
				end
			end			
		end		
	else
		openMenuItem:setSelectedIndex(0)
	end

	return cell
end

--[[
	@desc 	: 装备按钮回调
	@param 	: 
	@return : 
--]]
function equipItemCallback( pTag , pItem)
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 设置称号
	TitleController.setTitle(nil,pTag)
end

--[[
	@desc 	: 去获取按钮回调
	@param 	: 
	@return : 
--]]
--[[
1.竞技场:跳转至竞技场界面
2.比武：跳转至比武界面
3.活动/充值：通过活动获取
4.跨服比武：跳转至跨服比武界面（未开启不跳转）
5.巅峰对决：跳转至巅峰对决界面（未开启不跳转）
6.群雄争霸：跳转至群雄争霸界面（未开启不跳转）
7.国战：跳转至国战界面（未开启不跳转）
8.道具商店：跳转至道具商店界面
9.军团商店：跳转至军团商店界面
10.竞技场商店：跳转至竞技场商店界面
11.比武商店：跳转至比武商店界面
12.炼狱挑战：跳转至炼狱挑战界面（未开启不跳转）
13.跨服军团战：跳转至跨服军团战界面（未开启不跳转）
14.擂台赛：跳转至擂台赛界面（未开启不跳转）
--]]
function goToItemCallback( pTag , pItem)
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	print("TitleEquipCell.goToItemCallback reachpath => ",pTag)
	require "script/ui/tip/AnimationTip"
	if (pTag == 1) then
		-- 1.竞技场:跳转至竞技场界面
		-- 判断物品背包
		if(ItemUtil.isBagFull() == true )then
			return
		end
		-- 判断武将背包
	    if (HeroPublicUI.showHeroIsLimitedUI()) then
	    	return
	    end
		if( not DataCache.getSwitchNodeState( ksSwitchArena ) ) then
			return
		end
		require "script/ui/arena/ArenaLayer"
		local arenaLayer = ArenaLayer.createArenaLayer()
		MainScene.changeLayer(arenaLayer, "arenaLayer")
	elseif (pTag == 2) then
		-- 2.比武：跳转至比武界面
		if not DataCache.getSwitchNodeState(ksSwitchContest) then
			return
		end
    	if(ItemUtil.isBagFull() == true )then
			return
		end
		-- 判断武将满了
		require "script/ui/hero/HeroPublicUI"
	    if HeroPublicUI.showHeroIsLimitedUI() then
	    	return
	    end
		require "script/ui/match/MatchLayer"
		local matchLayer = MatchLayer.createMatchLayer()
		MainScene.changeLayer(matchLayer, "matchLayer")
	elseif (pTag == 3) then
		-- 3.活动：不跳转
		AnimationTip.showTip(GetLocalizeStringBy("lgx_1044"))
	elseif (pTag == 4) then
		-- 4.跨服比武：跳转至跨服比武界面（未开启不跳转）
		-- 功能节点判断
		if not DataCache.getSwitchNodeState(ksSwitchKFBW) then
			return
		end
		require "script/ui/kfbw/KuafuLayer"
		KuafuLayer.showKFBWLayer()
	elseif (pTag == 5) then
		-- 5.巅峰对决：跳转至巅峰对决界面（未开启不跳转）
		require "script/ui/WorldArena/WorldArenaMainData"
		if WorldArenaMainData.isShowBtn() then
			require "script/ui/WorldArena/WorldArenaMainLayer"
    		WorldArenaMainLayer.showLayer()
		else
			AnimationTip.showTip(GetLocalizeStringBy("key_2586"))
		end
	elseif (pTag == 6) then
		-- 6.群雄争霸：跳转至群雄争霸界面（未开启不跳转）
		require "script/model/utils/ActivityConfigUtil"
		require "script/ui/lordWar/LordWarData"
		if(ActivityConfigUtil.isActivityOpen("lordwar") and LordWarData.getLordIsOk()) then
			require "script/ui/lordWar/LordWarMainLayer"
			LordWarMainLayer.show()
		else
			AnimationTip.showTip(GetLocalizeStringBy("key_2586"))
		end
	elseif (pTag == 7) then
		-- 7.国战：跳转至国战界面（未开启不跳转）
		require "script/ui/countryWar/CountryWarMainData"
		if CountryWarMainData.isShowQuickIcon() then
			require "script/ui/countryWar/CountryWarMainLayer"
    		CountryWarMainLayer.show()
		else
			AnimationTip.showTip(GetLocalizeStringBy("key_2586"))
		end
	elseif (pTag == 8) then
		-- 8.道具商店：跳转至道具商店界面
		-- 功能节点判断
		if not DataCache.getSwitchNodeState(ksSwitchShop) then
			return
		end
    	require "script/ui/shopall/ShoponeLayer"
        ShoponeLayer.show(ShoponeLayer.ksTagPropShop)
	elseif (pTag == 9) then
		-- 9.军团商店：跳转至军团商店界面
		-- 判断是否开启
		require "script/ui/guild/GuildDataCache"
		if (GuildDataCache.getMineSigleGuildId() ~= 0) then
			require "script/ui/shopall/ShoponeLayer"
        	ShoponeLayer.show(ShoponeLayer.ksTagLegionShop)
		else
			AnimationTip.showTip(GetLocalizeStringBy("key_1043"))
		end
	elseif (pTag == 10) then
		-- 10.竞技场商店：跳转至竞技场商店界面
		-- 功能节点判断
		if not DataCache.getSwitchNodeState(ksSwitchArena) then
			return
		end
		require "script/ui/shopall/ShoponeLayer"
        ShoponeLayer.show(ShoponeLayer.ksTagArenaShop)
	elseif (pTag == 11) then
		-- 11.比武商店：跳转至比武商店界面
		-- 功能节点判断
		if not DataCache.getSwitchNodeState(ksSwitchContest) then
			return
		end
		require "script/ui/shopall/ShoponeLayer"
        ShoponeLayer.show(ShoponeLayer.ksTagMatchShop)
    elseif (pTag == 12) then
    	-- 12.炼狱挑战：跳转至炼狱挑战界面（未开启不跳转）
    	-- 功能节点判断
		if not DataCache.getSwitchNodeState(ksSwitchHellCopy) then
			return
		end
		require "script/ui/purgatorychallenge/PurgatoryMainLayer"
		PurgatoryMainLayer.showLayer()
    elseif (pTag == 13) then
    	-- 13.跨服军团战：跳转至跨服军团战界面（未开启不跳转）
    	require "script/model/utils/ActivityConfigUtil"
    	require "script/ui/guildWar/GuildWarMainData"
    	if ( ActivityConfigUtil.isActivityOpen("guildwar") and GuildWarMainData.getIsOk() ) then
			require "script/ui/guildWar/GuildWarMainLayer"
			GuildWarMainLayer.show()
		else
			AnimationTip.showTip(GetLocalizeStringBy("key_2586"))
			return
		end
    elseif (pTag == 14) then
    	-- 14.擂台赛：跳转至擂台赛界面（未开启不跳转）
    	-- 功能节点判断
    	if not DataCache.getSwitchNodeState(ksOlympic) then
			return
		end
  		require "script/ui/olympic/OlympicPrepareLayer"
        OlympicPrepareLayer.enter()
	else
		print("TitleEquipCell.goToItemCallback reachpath error!")
	end
end
