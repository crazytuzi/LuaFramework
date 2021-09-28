-- FileName: EverydayCell.lua 
-- Author: Li Cong 
-- Date: 14-3-19 
-- Purpose: function description of module 


module("EverydayCell", package.seeall)

require "script/ui/everyday/EverydayData"
require "script/ui/hero/HeroPublicUI"
require "script/ui/item/ItemUtil"

function createCell( tcellData )
	print("tcellData .. ")
	print_t(tcellData)

	local cell = CCTableViewCell:create()

	-- 背景
	local fullRect = CCRectMake(0,0,116,157)
	local insetRect = CCRectMake(50,43,16,6)
	local cellBg = CCScale9Sprite:create("images/everyday/cell_bg.png",fullRect, insetRect)
	cellBg:setContentSize(CCSizeMake(574,210))
	cellBg:setAnchorPoint(ccp(0,0))
	cellBg:setPosition(ccp(0,0))
	cell:addChild(cellBg)

	-- 图标
	local iconSpriteBg1 = CCSprite:create("images/everyday/headBg1.png")
	iconSpriteBg1:setAnchorPoint(ccp(0,0.5))
	iconSpriteBg1:setPosition(ccp(20,cellBg:getContentSize().height*0.5))
	cellBg:addChild(iconSpriteBg1)
	-- 图标底
	local iconSpriteBg2 = CCSprite:create("images/base/potential/props_" .. tcellData.dbData.quality .. ".png")
	iconSpriteBg2:setAnchorPoint(ccp(0.5,0.5))
	iconSpriteBg2:setPosition(ccp(iconSpriteBg1:getContentSize().width*0.5,iconSpriteBg1:getContentSize().height*0.5))
	iconSpriteBg1:addChild(iconSpriteBg2)
	-- 真正的图标
	local iconSprite = CCSprite:create("images/everyday/icon/".. tcellData.dbData.icon .. ".png")
	iconSprite:setAnchorPoint(ccp(0.5,0.5))
	iconSprite:setPosition(ccp(iconSpriteBg2:getContentSize().width*0.5,iconSpriteBg2:getContentSize().height*0.5))
	iconSpriteBg2:addChild(iconSprite)

	-- 名字背景
	local nameBg = CCScale9Sprite:create("images/common/bg/9s_5.png")
	nameBg:setContentSize(CCSizeMake(282,33))
	nameBg:setAnchorPoint(ccp(0,1))
	nameBg:setPosition(ccp(135,cellBg:getContentSize().height-40))
	cellBg:addChild(nameBg)
	-- 名字 进度
	local str = tcellData.dbData.name or GetLocalizeStringBy("key_3392")
	local name_font = CCLabelTTF:create(str,g_sFontPangWa,24)
 	name_font:setColor(ccc3(0xff,0xff,0xff))
 	name_font:setAnchorPoint(ccp(0,0.5))
 	name_font:setPosition(ccp(14,nameBg:getContentSize().height*0.5))
 	nameBg:addChild(name_font)

 	local str = GetLocalizeStringBy("key_1140") .. tcellData.curNum .. "/" .. tcellData.dbData.needNum
	local jindu_font = CCLabelTTF:create(str,g_sFontName,23)
 	jindu_font:setColor(ccc3(0x00,0xff,0x18))
 	jindu_font:setAnchorPoint(ccp(1,0.5))
    --兼容东南亚英文版
 	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
 		jindu_font:setPosition(ccp(cellBg:getContentSize().width - 80,35))
 		cellBg:addChild(jindu_font)
 	else
 		jindu_font:setPosition(ccp(nameBg:getContentSize().width-10,nameBg:getContentSize().height*0.5))
 		nameBg:addChild(jindu_font)
 	end

 	-- 任务描述
 	local str = tcellData.dbData.taskDes or GetLocalizeStringBy("key_3392")
 	local taskDes = CCLabelTTF:create(str,g_sFontName,23)
 	taskDes:setColor(ccc3(0x78,0x25,0x00))
 	taskDes:setAnchorPoint(ccp(0,1))
 	taskDes:setPosition(ccp(135,cellBg:getContentSize().height-105))
 	cellBg:addChild(taskDes)

 	-- 获得的积分
 	local scoreBg = CCSprite:create("images/everyday/score_bg.png")
 	scoreBg:setAnchorPoint(ccp(0,0))
 	scoreBg:setPosition(ccp(10,20))
 	cellBg:addChild(scoreBg)
 	local str = GetLocalizeStringBy("key_2545")
 	local hude_font = CCLabelTTF:create(str,g_sFontPangWa,18)
 	hude_font:setColor(ccc3(0xff,0xe4,0x00))
 	hude_font:setAnchorPoint(ccp(0,0.5))
 	hude_font:setPosition(ccp(25,scoreBg:getContentSize().height*0.5))
 	scoreBg:addChild(hude_font)

 	local str = tcellData.dbData.score or GetLocalizeStringBy("key_3392")
 	local hude_font = CCLabelTTF:create(str,g_sFontPangWa,18)
 	hude_font:setColor(ccc3(0x00,0xff,0x18))
 	hude_font:setAnchorPoint(ccp(0,0.5))
 	hude_font:setPosition(ccp(125,scoreBg:getContentSize().height*0.5))
 	scoreBg:addChild(hude_font)

 	-- 获得的奖励
 	local rewBg = CCScale9Sprite:create("images/common/bg/9s_purple.png")
 	rewBg:setContentSize(CCSizeMake(200,35))
 	rewBg:setAnchorPoint(ccp(0.5,0))
 	rewBg:setPosition(ccp(cellBg:getContentSize().width*0.5,20))
 	cellBg:addChild(rewBg)
 	local str = GetLocalizeStringBy("key_10025")
 	local desFont =CCRenderLabel:create(str,g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
 	desFont:setColor(ccc3(0xff,0xe4,0x00))
 	desFont:setAnchorPoint(ccp(0,0.5))
 	desFont:setPosition(ccp(10,rewBg:getContentSize().height*0.5))
 	rewBg:addChild(desFont)

 	local itemTab = ItemUtil.getItemsDataByStr(tcellData.dbData.reward)
 	local nameStr = itemTab[1].name
 	local nameColor = HeroPublicLua.getCCColorByStarLevel(5)
 	if( nameStr == nil)then
 		local itemData = ItemUtil.getItemById(itemTab[1].tid)
 		nameStr = itemData.name
 		nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
 	end
 	local nameFont = CCRenderLabel:create(nameStr .. "X" .. itemTab[1].num,g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
 	nameFont:setColor(nameColor)
 	nameFont:setAnchorPoint(ccp(0,0.5))
 	nameFont:setPosition(ccp(desFont:getPositionX()+desFont:getContentSize().width+3,desFont:getPositionY()))
 	rewBg:addChild(nameFont)

 	-- 是否已领奖
 	local isHave = EverydayData.isHaveReward( tonumber(tcellData.dbData.id) )

 	-- 按钮
 	if( tonumber(tcellData.curNum) >= tonumber(tcellData.dbData.needNum) and isHave == false )then
 		-- 领奖
		local rewardMenu = BTSensitiveMenu:create()
		rewardMenu:setTouchPriority(-422)
		rewardMenu:setPosition(ccp(0,0))
		cellBg:addChild(rewardMenu)
		local rewardMenuItem = CCMenuItemImage:create("images/common/btn/green01_n.png","images/common/btn/green01_h.png")
		rewardMenuItem:setAnchorPoint(ccp(1,0.5))
		rewardMenuItem:setPosition(ccp(cellBg:getContentSize().width-25, cellBg:getContentSize().height*0.5))
		rewardMenu:addChild(rewardMenuItem,1,tonumber(tcellData.dbData.id))
		rewardMenuItem:registerScriptTapHandler(rewardMenuItemCallFun)
		local item_font = CCRenderLabel:create( GetLocalizeStringBy("key_10129") , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
	    item_font:setAnchorPoint(ccp(0.5,0.5))
	    item_font:setPosition(ccp(rewardMenuItem:getContentSize().width*0.5,rewardMenuItem:getContentSize().height*0.5))
	   	rewardMenuItem:addChild(item_font)

 	elseif(isHave)then
 		-- 领完奖 已完成
 		local overSp = CCSprite:create("images/everyday/wancheng.png")
 		overSp:setAnchorPoint(ccp(1,0.5))
 		overSp:setPosition(ccp(cellBg:getContentSize().width-25,cellBg:getContentSize().height*0.5))
 		cellBg:addChild(overSp)
 	else
 		-- 前往按钮
		local skipMenu = BTSensitiveMenu:create()
		skipMenu:setTouchPriority(-422)
		skipMenu:setPosition(ccp(0,0))
		cellBg:addChild(skipMenu)
		local skipMenuItem = CCMenuItemImage:create("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png")
		skipMenuItem:setAnchorPoint(ccp(1,0.5))
		skipMenuItem:setPosition(ccp(cellBg:getContentSize().width-25, cellBg:getContentSize().height*0.5))
		skipMenu:addChild(skipMenuItem,1,tonumber(tcellData.dbData.type))
		skipMenuItem:registerScriptTapHandler(skipMenuItemCallFun)
		local item_font = CCRenderLabel:create( GetLocalizeStringBy("key_2807") , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
	    item_font:setAnchorPoint(ccp(0.5,0.5))
	    item_font:setPosition(ccp(skipMenuItem:getContentSize().width*0.5,skipMenuItem:getContentSize().height*0.5))
	   	skipMenuItem:addChild(item_font)
 	end

 	-- 显示完成时间
 	local timeNum1,timeNum2 = EverydayData.getShowTime( tcellData.dbData.id )
 	local str = timeNum2
 	if(tonumber(timeNum2) == 7)then
 		str = GetLocalizeStringBy("key_1557")
 	end
 	local timeFont = CCLabelTTF:create(GetLocalizeStringBy("lic_1770", tostring(timeNum1), str ) ,g_sFontName,18)
 	timeFont:setColor(ccc3(0x78,0x25,0x00))
 	timeFont:setAnchorPoint(ccp(1,0.5))
 	timeFont:setPosition(ccp(cellBg:getContentSize().width-25,cellBg:getContentSize().height*0.25))
 	cellBg:addChild(timeFont)

	return cell
end

--[[
	@des 	:领奖按钮回调
	@param 	:
	@return :
--]]
function rewardMenuItemCallFun( tag, itemBtn )
	require "script/ui/everyday/EverydayService"

	if(ItemUtil.isBagFull() == true )then
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()
		return
	end

	local nextCallFun = function ( p_retData )
		-- 弹提示
		require "db/DB_Daytask"
		local daData = DB_Daytask.getDataById(tag)
		local itemTab = ItemUtil.getItemsDataByStr(daData.reward)
	 	local nameStr = itemTab[1].name
	 	local nameColor = HeroPublicLua.getCCColorByStarLevel(5)
	 	if( nameStr == nil)then
	 		local itemData = ItemUtil.getItemById(itemTab[1].tid)
	 		nameStr = itemData.name
	 		nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
	 	end
	 	local textInfo= {
            {tipText=nameStr .. "X" .. itemTab[1].num, color=nameColor},
        }
       	AnimationTip.showRichTextTip(textInfo)
       	
       	ItemUtil.addRewardByTable(itemTab)
		EverydayData.addHaveReward( tag )
		EverydayLayer.refreshTasksTableView()
	end
	EverydayService.getTaskPrize( tag, nextCallFun)
end


-- 前往 按钮回调
function skipMenuItemCallFun( tag, itemBtn )
	if(tag == 1)then
		-- 普通副本
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()
		require "script/ui/copy/CopyLayer"
		local copyLayer = CopyLayer.createLayer()
		MainScene.changeLayer(copyLayer, "copyLayer")
	elseif(tag == 2)then
		-- 精英副本
		if not DataCache.getSwitchNodeState(ksSwitchEliteCopy) then
			return
		end
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()
		require "script/ui/copy/CopyLayer"
		local copyLayer = CopyLayer.createLayer(nil, CopyLayer.Elite_Copy_Tag)
		MainScene.changeLayer(copyLayer, "copyLayer")
	elseif(tag == 3)then
		-- 活动副本
		if not DataCache.getSwitchNodeState(ksSwitchActivityCopy) then
			return
		end
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()
		require "script/ui/copy/CopyLayer"
		local copyLayer = CopyLayer.createLayer(nil, CopyLayer.Active_Copy_Tag)
		MainScene.changeLayer(copyLayer, "copyLayer")
	elseif(tag == 4)then
		-- 占星坛
		if not DataCache.getSwitchNodeState(ksSwitchStar) then
			return
		end
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()
        require "script/ui/astrology/AstrologyLayer"
        local astrologyLayer = AstrologyLayer.createAstrologyLayer()
		MainScene.changeLayer(astrologyLayer, "AstrologyLayer",AstrologyLayer.exitAstro)
	elseif(tag == 5)then
		-- 战魂
		if not DataCache.getSwitchNodeState(ksSwitchBattleSoul) then
			return
		end
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()
		require "script/ui/huntSoul/HuntSoulLayer"
        local layer = HuntSoulLayer.createHuntSoulLayer()
        MainScene.changeLayer(layer, "huntSoulLayer")
	elseif(tag == 6)then
		-- 夺宝
		-- 判断物品背包
		if(ItemUtil.isBagFull() == true )then
			-- 关闭每日任务界面
			EverydayLayer.closeButtonCallback()
			return
		end
		-- 判断武将背包
	    if HeroPublicUI.showHeroIsLimitedUI() then
	    	-- 关闭每日任务界面
			EverydayLayer.closeButtonCallback()
	    	return
	    end
		if( not DataCache.getSwitchNodeState( ksSwitchRobTreasure )) then
			return
		end
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()
		require "script/ui/treasure/TreasureMainView"
		local treasureLayer = TreasureMainView.create()
		MainScene.changeLayer(treasureLayer,"treasureLayer")
	elseif(tag == 7)then
		-- 竞技场
		-- 判断物品背包
		if(ItemUtil.isBagFull() == true )then
			-- 关闭每日任务界面
			EverydayLayer.closeButtonCallback()
			return
		end
		-- 判断武将背包
	    if HeroPublicUI.showHeroIsLimitedUI() then
	    	-- 关闭每日任务界面
			EverydayLayer.closeButtonCallback()
	    	return
	    end
		if( not DataCache.getSwitchNodeState( ksSwitchArena ) ) then
			return
		end
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()
		require "script/ui/arena/ArenaLayer"
		local arenaLayer = ArenaLayer.createArenaLayer()
		MainScene.changeLayer(arenaLayer, "arenaLayer")
	elseif(tag == 8)then
		-- 试练塔
		-- 判断物品背包
		if(ItemUtil.isBagFull() == true )then
			-- 关闭每日任务界面
			EverydayLayer.closeButtonCallback()
			return
		end
		if( not DataCache.getSwitchNodeState( ksSwitchTower ) ) then
			return
		end
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()
		require "script/ui/tower/TowerMainLayer"
		local towerMainLayer = TowerMainLayer.createLayer()
		MainScene.changeLayer(towerMainLayer, "towerMainLayer")
	elseif(tag == 9)then
		-- 世界BOOS
		if( not DataCache.getSwitchNodeState( ksSwitchWorldBoss ) ) then
			return
		end
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()
		require "script/ui/boss/BossMainLayer"
		local bossLayer = BossMainLayer.createBoss()
		MainScene.changeLayer(bossLayer, "bossLayer")
	elseif(tag == 10)then
		-- 好友送体力
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()
		require "script/ui/friend/FriendLayer"
		local friendLayer = FriendLayer.creatFriendLayer()
		MainScene.changeLayer(friendLayer, "friendLayer")
	elseif(tag == 11)then
		-- 名将
		if not DataCache.getSwitchNodeState(ksSwitchGreatSoldier) then
			return
		end
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()
		require "script/ui/star/StarLayer"
		local starLayer = StarLayer.createLayer()
		MainScene.changeLayer(starLayer, "starLayer")
	elseif(tag == 12)then
		-- 装备洗练
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()
		require "script/ui/bag/BagLayer"
		local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_Arming)
		MainScene.changeLayer(bagLayer, "bagLayer")
	elseif(tag == 13 or tag == 17 or tag == 18 or tag == 19 or tag == 26 or tag == 29 or tag == 34)then
		-- 军团界面 13前往拜关公, 17军团建设, 18军团副本, 19军团任务, 26采集粮草 29攻城掠地
		if not DataCache.getSwitchNodeState(ksSwitchGuild) then
			return
		end
		-- 判断是否有军团
		require "script/ui/guild/GuildDataCache"
		local guildId = GuildDataCache.getMineSigleGuildId()
		if(guildId == 0)then
			require "script/ui/tip/AnimationTip"
			AnimationTip.showTip(GetLocalizeStringBy("lic_1344"))
			return
		end
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()
		require "script/ui/guild/GuildImpl"
		GuildImpl.showLayer()	
	elseif(tag == 14)then
		-- 签到
		if not DataCache.getSwitchNodeState(ksSwitchSignIn) then
			return
		end
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()
		require "script/ui/sign/SignRewardLayer"
   		SignRewardLayer.singBtnCallBack()
   	elseif(tag == 15)then
		-- 月签到
		if not DataCache.getSwitchNodeState(kMonthSignIn) then
			return
		end
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()
		require "script/ui/rechargeActive/RechargeActiveMain"
		local monthSignLayer = RechargeActiveMain.create(RechargeActiveMain._tagMonthSign)
    	MainScene.changeLayer(monthSignLayer,"monthSignLayer")
    elseif(tag == 16)then
		-- 学习技能 天命
		-- 天命入口
		if not DataCache.getSwitchNodeState(ksSwitchDestiny) then
			return
		end
		-- 学习技能功能节点
		if not DataCache.getSwitchNodeState(ksChangeSkill) then
			return
		end
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()
		require "script/ui/destiny/DestinyLayer"
		local destinyLayer = DestinyLayer.createLayer()
		MainScene.changeLayer(destinyLayer, "destinyLayer")
	elseif(tag == 20)then
		-- 商店招将
		if not DataCache.getSwitchNodeState(ksSwitchShop) then
			return
		end
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()
		require "script/ui/shop/ShopLayer"
		local  shopLayer = ShopLayer.createLayer()
		MainScene.changeLayer(shopLayer, "shopLayer", ShopLayer.layerWillDisappearDelegate)
	elseif(tag == 21)then
		-- 资源矿
		if not DataCache.getSwitchNodeState(ksSwitchResource) then
			return
		end
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()
		require "script/ui/active/mineral/MineralLayer"
		local mineralLayer = MineralLayer.createLayer()
		MainScene.changeLayer(mineralLayer, "mineralLayer")
	elseif(tag == 22)then
		-- 寻龙探宝
  		if not DataCache.getSwitchNodeState(ksFindDragon) then
			return
		end
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()
        require "script/ui/forge/FindTreasureLayer"
        FindTreasureLayer.show()
    elseif(tag == 23)then
    	-- 比武
	    if not DataCache.getSwitchNodeState(ksSwitchContest) then
			return
		end
    	if(ItemUtil.isBagFull() == true )then
    		-- 关闭每日任务界面
			EverydayLayer.closeButtonCallback()
			return
		end
		-- 判断武将满了
		require "script/ui/hero/HeroPublicUI"
	    if HeroPublicUI.showHeroIsLimitedUI() then
	    	-- 关闭每日任务界面
			EverydayLayer.closeButtonCallback()
	    	return
	    end
	    -- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()
		require "script/ui/match/MatchLayer"
		local matchLayer = MatchLayer.createMatchLayer()
		MainScene.changeLayer(matchLayer, "matchLayer")
	elseif(tag == 24)then
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()
		require "script/ui/shopall/ShoponeLayer"
		ShoponeLayer.show(ShoponeLayer.ksTagMysteryShop)
    elseif(tag == 25)then
		-- 吃烧鸡
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()
		require "script/ui/rechargeActive/RechargeActiveMain"
		local monthSignLayer = RechargeActiveMain.create(RechargeActiveMain._tagEatChieken)
    	MainScene.changeLayer(monthSignLayer,"monthSignLayer")
   	elseif(tag == 27)then
		-- 过关斩将
		-- 功能节点判断
		if not DataCache.getSwitchNodeState(ksSwitchGodWeapon) then
			return
		end
		-- 背包满了
		if(ItemUtil.isBagFull() == true )then
			-- 关闭每日任务界面
			EverydayLayer.closeButtonCallback()
			return
		end
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()
    	-- 神兵副本
  		require "script/ui/godweapon/godweaponcopy/GodWeaponCopyMainLayer"
		local pLayer = GodWeaponCopyMainLayer.createLayer()
		MainScene.setMainSceneViewsVisible(false,false,false)
		MainScene.changeLayer(pLayer,"GodWeaponCopyMainLayer")
	elseif(tag == 28)then
		-- 星魂
		-- 功能节点判断
		if not DataCache.getSwitchNodeState(ksSwitchStarSoul) then
			return
		end
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()
		-- 星魂界面
		require "script/ui/athena/AthenaMainLayer"
		AthenaMainLayer.createLayer()
	elseif( tag == 30 or tag == 32)then
		-- 水月之境
		-- 功能节点判断
		if not DataCache.getSwitchNodeState(ksSwitchMoon) then
			return
		end
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()
    	-- 水月之境
  		require "script/ui/moon/MoonLayer"
    	MoonLayer.show()
    elseif(tag == 31)then
		-- 水月之境
		-- 功能节点判断
		if not DataCache.getSwitchNodeState(ksSwitchMoon) then
			return
		end
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()
    	-- 水月之境
    	require "script/ui/shopall/ShoponeLayer"
		ShoponeLayer.show(ShoponeLayer.ksTagMoonShop)
	elseif(tag == 33)then
		-- 跨服比武
		-- 功能节点判断
		if not DataCache.getSwitchNodeState(ksSwitchKFBW) then
			return
		end
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()

		require "script/ui/kfbw/KuafuLayer"
		KuafuLayer.showKFBWLayer()
	elseif(tag == 35 or tag == 36)then
		-- 购买体力丹 购买耐力丹
		-- 功能节点判断
		if not DataCache.getSwitchNodeState(ksSwitchShop) then
			return
		end
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()

		require "script/ui/shopall/ShoponeLayer"
        ShoponeLayer.show(ShoponeLayer.ksTagPropShop)
    elseif (tag == 37) then
		-- 试练梦魇
		-- 判断物品背包
		if(ItemUtil.isBagFull() == true )then
			-- 关闭每日任务界面
			EverydayLayer.closeButtonCallback()
			return
		end
		-- 关闭每日任务界面
		EverydayLayer.closeButtonCallback()
		require "script/ui/deviltower/DevilTowerLayer"
		DevilTowerLayer.showLayer()
	else
		print(GetLocalizeStringBy("key_3239"))
	end
end























