-- FileName: MissonTaskCell.lua
-- Author: shengyixian
-- Date: 2015-08-28
-- Purpose: 悬赏榜任务表单元

module("MissionTaskCell",package.seeall)

local _touchPriority = nil
--[[
	@des 	: 初始化视图
	@param 	: 
	@return : 
--]]
function initView(cell,taskInfo)
	-- 背景
	local fullRect = CCRectMake(0,0,116,157)
	local insetRect = CCRectMake(50,43,16,6)
	local cellBg = CCScale9Sprite:create("images/everyday/cell_bg.png",fullRect, insetRect)
	cellBg:setContentSize(CCSizeMake(574,157))
	cellBg:setAnchorPoint(ccp(0,0))
	cellBg:setPosition(ccp(0,0))
	cell:addChild(cellBg)
	-- 图标背景
	local iconSpriteBg1 = CCSprite:create("images/everyday/headBg1.png")
	iconSpriteBg1:setAnchorPoint(ccp(0,0.5))
	iconSpriteBg1:setPosition(ccp(20,cellBg:getContentSize().height*0.5))
	cellBg:addChild(iconSpriteBg1)
	-- 图标底
	local iconSpriteBg2 = CCSprite:create("images/base/potential/props_" .. taskInfo.quality .. ".png")
	iconSpriteBg2:setAnchorPoint(ccp(0.5,0.5))
	iconSpriteBg2:setPosition(ccp(iconSpriteBg1:getContentSize().width*0.5,iconSpriteBg1:getContentSize().height*0.5))
	iconSpriteBg1:addChild(iconSpriteBg2)
	-- 图标
	local iconPath = "images/everyday/icon/".. taskInfo.icon .. ".png"
	local iconSp = CCSprite:create(iconPath)
	iconSp:setAnchorPoint(ccp(0.5,0.5))
	iconSp:setPosition(ccp(iconSpriteBg1:getContentSize().width*0.5,iconSpriteBg1:getContentSize().height*0.5))
	iconSpriteBg1:addChild(iconSp)
	-- 名字背景
	local nameBg = CCScale9Sprite:create("images/common/bg/9s_5.png")
	nameBg:setContentSize(CCSizeMake(282,33))
	nameBg:setAnchorPoint(ccp(0,1))
	nameBg:setPosition(ccp(135,cellBg:getContentSize().height-20))
	cellBg:addChild(nameBg)
	-- 名字
	local str = taskInfo.name or GetLocalizeStringBy("key_3392")
	local nameLabel = CCRenderLabel:create(str,g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_shadow)
 	nameLabel:setColor(ccc3(0xff,0xff,0xff))
 	nameLabel:setAnchorPoint(ccp(0,0.5))
 	nameLabel:setPosition(ccp(14,nameBg:getContentSize().height*0.5))
 	nameBg:addChild(nameLabel)
 	-- 任务进度
 	local times = tonumber(taskInfo.maxNum) - tonumber(taskInfo[#taskInfo])
 	if(times < 0) then
 		times = 0
 	end
 	str = GetLocalizeStringBy("syx_1003",times)
	local progressLabel = CCRenderLabel:create(str,g_sFontBold,18,1,ccc3(0x00,0x00,0x00),type_shadow)
 	progressLabel:setColor(ccc3(0x00,0xff,0x18))
 	progressLabel:setAnchorPoint(ccp(1,0.5))
 	progressLabel:setPosition(ccp(nameBg:getContentSize().width-10,nameBg:getContentSize().height*0.5))
 	nameBg:addChild(progressLabel)
 	-- 任务描述
 	local str = taskInfo.taskDes or GetLocalizeStringBy("key_3392")
 	local taskDes = CCLabelTTF:create(str,g_sFontBold,23)
 	taskDes:setColor(ccc3(0x78,0x25,0x00))
 	taskDes:setAnchorPoint(ccp(0,1))
 	taskDes:setPosition(ccp(135,cellBg:getContentSize().height-65))
 	cellBg:addChild(taskDes)
	-- 名望背景
 	local fameBg = CCSprite:create("images/everyday/score_bg.png")
 	fameBg:setAnchorPoint(ccp(0,0))
 	fameBg:setPosition(ccp(135,20))
 	cellBg:addChild(fameBg)
 	--名望
 	local str = GetLocalizeStringBy("syx_1004",taskInfo.fame)
 	local fameLabel = CCRenderLabel:create(str,g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_shadow)
 	fameLabel:setColor(ccc3(0xff,0xe4,0x00))
 	fameLabel:setAnchorPoint(ccp(0,0.5))
 	fameLabel:setPosition(ccp(14,fameBg:getContentSize().height*0.5))
 	fameBg:addChild(fameLabel)
 	--判断任务是否完成
 	if (taskInfo[#taskInfo] < taskInfo.maxNum) then
 		-- 前往按钮
 		local skipMenu = CCMenu:create()
		skipMenu:setPosition(ccp(0,0))
		skipMenu:setTouchPriority(_touchPriority)
		cellBg:addChild(skipMenu)
		local skipMenuItem = CCMenuItemImage:create("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png")
		skipMenuItem:setAnchorPoint(ccp(1,0.5))
		skipMenuItem:setPosition(ccp(cellBg:getContentSize().width-25, cellBg:getContentSize().height*0.5))
		skipMenuItem:registerScriptTapHandler(skipHandler)
		skipMenu:addChild(skipMenuItem,1,tonumber(taskInfo.icon))
		local item_font = CCRenderLabel:create( GetLocalizeStringBy("key_2807") , g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
	    item_font:setAnchorPoint(ccp(0.5,0.5))
	    item_font:setPosition(ccp(skipMenuItem:getContentSize().width*0.5,skipMenuItem:getContentSize().height*0.5))
	   	skipMenuItem:addChild(item_font)
	else
 		-- 已完成
 		local overSp = CCSprite:create("images/everyday/wancheng.png")
 		overSp:setAnchorPoint(ccp(1,0.5))
 		overSp:setPosition(ccp(cellBg:getContentSize().width-25,cellBg:getContentSize().height*0.5))
 		cellBg:addChild(overSp)
 	end
end
--[[
	@des 	: 创建表单元
	@param 	: 
	@return : 
--]]
function createCell(taskInfo)
	_touchPriority = -4100
	local cell = CCTableViewCell:create()
	initView(cell,taskInfo)
	return cell
end

--[[
	@des 	: 前往副本
	@param 	: 
	@return : 
--]]
function skipHandler(tag,item)
	--关闭任务界面
	MissionTaskDialog.closeButtonCallback()
	if(tag == 1)then
		-- 普通副本
		require "script/ui/copy/CopyLayer"
		local copyLayer = CopyLayer.createLayer()
		MainScene.changeLayer(copyLayer, "copyLayer")
	elseif(tag == 2)then
		-- 精英副本
		if not DataCache.getSwitchNodeState(ksSwitchEliteCopy) then
			return
		end
		require "script/ui/copy/CopyLayer"
		local copyLayer = CopyLayer.createLayer(nil, CopyLayer.Elite_Copy_Tag)
		MainScene.changeLayer(copyLayer, "copyLayer")
	elseif(tag == 3)then
		-- 活动副本
		if not DataCache.getSwitchNodeState(ksSwitchActivityCopy) then
			return
		end
		require "script/ui/copy/CopyLayer"
		local copyLayer = CopyLayer.createLayer(nil, CopyLayer.Active_Copy_Tag)
		MainScene.changeLayer(copyLayer, "copyLayer")
	elseif(tag == 4)then
		-- 占星坛
		if not DataCache.getSwitchNodeState(ksSwitchStar) then
			return
		end
        require "script/ui/astrology/AstrologyLayer"
        local astrologyLayer = AstrologyLayer.createAstrologyLayer()
		MainScene.changeLayer(astrologyLayer, "AstrologyLayer",AstrologyLayer.exitAstro)
	elseif(tag == 5)then
		-- 战魂
		if not DataCache.getSwitchNodeState(ksSwitchBattleSoul) then
			return
		end
		require "script/ui/huntSoul/HuntSoulLayer"
        local layer = HuntSoulLayer.createHuntSoulLayer()
        MainScene.changeLayer(layer, "huntSoulLayer")
	elseif(tag == 6)then
		-- 夺宝
		-- 判断物品背包
		if(ItemUtil.isBagFull() == true )then
			return
		end
		-- 判断武将背包
	    if HeroPublicUI.showHeroIsLimitedUI() then
	    	return
	    end
		if( not DataCache.getSwitchNodeState( ksSwitchRobTreasure )) then
			return
		end
		require "script/ui/treasure/TreasureMainView"
		local treasureLayer = TreasureMainView.create()
		MainScene.changeLayer(treasureLayer,"treasureLayer")
	elseif(tag == 7)then
		-- 竞技场
		-- 判断物品背包
		if(ItemUtil.isBagFull() == true )then
			return
		end
		-- 判断武将背包
	    if HeroPublicUI.showHeroIsLimitedUI() then
	    	return
	    end
		if( not DataCache.getSwitchNodeState( ksSwitchArena ) ) then
			return
		end
		require "script/ui/arena/ArenaLayer"
		local arenaLayer = ArenaLayer.createArenaLayer()
		MainScene.changeLayer(arenaLayer, "arenaLayer")
	elseif(tag == 8)then
		-- 试练塔
		-- 判断物品背包
		if(ItemUtil.isBagFull() == true )then
			return
		end
		if( not DataCache.getSwitchNodeState( ksSwitchTower ) ) then
			return
		end
		require "script/ui/tower/TowerMainLayer"
		local towerMainLayer = TowerMainLayer.createLayer()
		MainScene.changeLayer(towerMainLayer, "towerMainLayer")
	elseif(tag == 9)then
		-- 世界BOOS
		if( not DataCache.getSwitchNodeState( ksSwitchWorldBoss ) ) then
			return
		end
		require "script/ui/boss/BossMainLayer"
		local bossLayer = BossMainLayer.createBoss()
		MainScene.changeLayer(bossLayer, "bossLayer")
	elseif(tag == 10)then
		-- 好友送体力
		require "script/ui/friend/FriendLayer"
		local friendLayer = FriendLayer.creatFriendLayer()
		MainScene.changeLayer(friendLayer, "friendLayer")
	elseif(tag == 11)then
		-- 名将
		if not DataCache.getSwitchNodeState(ksSwitchGreatSoldier) then
			return
		end
		require "script/ui/star/StarLayer"
		local starLayer = StarLayer.createLayer()
		MainScene.changeLayer(starLayer, "starLayer")
	elseif(tag == 12)then
		-- 装备洗练
		require "script/ui/bag/BagLayer"
		local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_Arming)
		MainScene.changeLayer(bagLayer, "bagLayer")
	elseif(tag == 13 or tag == 17 or tag == 18 or tag == 19 or tag == 26 or tag == 29)then
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
		require "script/ui/guild/GuildImpl"
		GuildImpl.showLayer()	
	elseif(tag == 14)then
		-- 签到
		if not DataCache.getSwitchNodeState(ksSwitchSignIn) then
			return
		end
		require "script/ui/sign/SignRewardLayer"
   		SignRewardLayer.singBtnCallBack()
   	elseif(tag == 15)then
		-- 月签到
		if not DataCache.getSwitchNodeState(kMonthSignIn) then
			return
		end
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
		require "script/ui/destiny/DestinyLayer"
		local destinyLayer = DestinyLayer.createLayer()
		MainScene.changeLayer(destinyLayer, "destinyLayer")
	elseif(tag == 20)then
		-- 商店招将
		if not DataCache.getSwitchNodeState(ksSwitchShop) then
			return
		end
		require "script/ui/shop/ShopLayer"
		local  shopLayer = ShopLayer.createLayer()
		MainScene.changeLayer(shopLayer, "shopLayer", ShopLayer.layerWillDisappearDelegate)
	elseif(tag == 21)then
		-- 资源矿
		if not DataCache.getSwitchNodeState(ksSwitchResource) then
			return
		end
		require "script/ui/active/mineral/MineralLayer"
		local mineralLayer = MineralLayer.createLayer()
		MainScene.changeLayer(mineralLayer, "mineralLayer")
	elseif(tag == 22)then
		-- 寻龙探宝
  		if not DataCache.getSwitchNodeState(ksFindDragon) then
			return
		end
        require "script/ui/forge/FindTreasureLayer"
        FindTreasureLayer.show()
    elseif(tag == 23)then
    	-- 比武
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
	elseif(tag == 24)then
		require "script/ui/shopall/ShoponeLayer"
		ShoponeLayer.show(ShoponeLayer.ksTagMysteryShop)
    elseif(tag == 25)then
		-- 吃烧鸡
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
			return
		end
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
		-- 星魂界面
		require "script/ui/athena/AthenaMainLayer"
		AthenaMainLayer.createLayer()
	elseif( tag == 30 )then
		-- 水月之境
		-- 功能节点判断
		if not DataCache.getSwitchNodeState(ksSwitchMoon) then
			return
		end
    	-- 水月之境
  		require "script/ui/moon/MoonLayer"
    	MoonLayer.show()
    elseif(tag == 31)then
		-- 水月之境
		-- 功能节点判断
		if not DataCache.getSwitchNodeState(ksSwitchMoon) then
			return
		end
    	-- 水月之境
    	require "script/ui/moon/MoonShopLayer"
		MoonShopLayer.show()
	else
		print(GetLocalizeStringBy("key_3239"))
	end
end