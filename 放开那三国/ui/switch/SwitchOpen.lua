-- Filename: SwitchOpen.lua
-- Author: lichenyang
-- Date: 2013-09-2
-- Purpose: 功能节点开启

module ("SwitchOpen", package.seeall)


isFight 			= false				--现在玩家是否在战斗状态中
isHaveNotification	= false				--当前是否有开启功能推送
notificationEnum	= nil
local colorLayer	= nil
isTenLevelOpen		= false
isForthFormation    = false
isSwithPanelShow	= false

local openForthPositionLevel = 12 		--第四个上阵栏位开启等级

function create( switchEnum )
	colorLayer = CCLayerColor:create(ccc4(0, 0, 0, 200))
	colorLayer:setPosition(ccp(0, 0))
	colorLayer:setAnchorPoint(ccp(0, 0))
	colorLayer:setTouchEnabled(true)
	colorLayer:setTouchPriority(-512)
	colorLayer:registerScriptTouchHandler(function ( eventType,x,y )
		if(eventType == "began") then
			return true
		end
	end,false, - 512, true)

	local background = CCSprite:create("images/switch/dialog_background.png")
	background:setPosition(ccps(0.5, 0.5))
	background:setAnchorPoint(ccp(0.5, 0.5))
	colorLayer:addChild(background)
	--标题
	titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(background:getContentSize().width/2, background:getContentSize().height - 7 )
	background:addChild(titlePanel)

	--兼容东南亚英文版
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1839"), g_sFontPangWa, 30, 1, ccc3(0,0,0))
	else
		titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1839"), g_sFontPangWa, 35, 1, ccc3(0,0,0))
	end
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	local x = (titlePanel:getContentSize().width - titleLabel:getContentSize().width)/2
	local y = titlePanel:getContentSize().height - (titlePanel:getContentSize().height - titleLabel:getContentSize().height)/2
	titleLabel:setPosition(ccp(x , y))
	titlePanel:addChild(titleLabel)


	local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	menu:setTouchPriority(-1000)
	background:addChild(menu)

	local checkButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(189,73),GetLocalizeStringBy("key_1354"),ccc3(255,222,0))
    checkButton:setAnchorPoint(ccp(0.5, 0.5))
    checkButton:setPosition(ccpsprite( 0.5, 0.12, background))
	menu:addChild(checkButton)
	checkButton:registerScriptTapHandler(checkButtonCallback)
	checkButton:setTag(switchEnum)

	local yellowRound = CCSprite:create("images/switch/yellow_round.png")
	yellowRound:setAnchorPoint(ccp(0.5, 0.5))
	yellowRound:setPosition(background:getContentSize().width * 0.5, 355)


	local switchIcon = nil
	local systemName = ""
	--添加功能节点图标
	if(tonumber(switchEnum) == ksSwitchFormation) then
		--阵容
		systemName=GetLocalizeStringBy("key_1133")
		switchIcon = CCSprite:create("images/switch/formation.png")
		switchIcon:setAnchorPoint(ccp(0.5, 0.5))
		switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
		yellowRound:addChild(switchIcon)
		background:addChild(yellowRound)
	elseif(tonumber(switchEnum) == ksSwitchForge) then
		--强化所
		systemName=GetLocalizeStringBy("key_2887")
		switchIcon = CCSprite:create("images/switch/forge.png")
		switchIcon:setAnchorPoint(ccp(0.5, 0.5))
		switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
		yellowRound:addChild(switchIcon)
		background:addChild(yellowRound)
	elseif(tonumber(switchEnum) == ksSwitchShop) then
		--商店 		--error
		systemName=GetLocalizeStringBy("key_2950")
		switchIcon = CCSprite:create("images/switch/shop.png")

	elseif(tonumber(switchEnum) == ksSwitchEliteCopy) then
		--精英副本
		systemName=GetLocalizeStringBy("key_2748")
		switchIcon = CCSprite:create("images/switch/elite_copy.png")
		switchIcon:setAnchorPoint(ccp(0.5, 0.5))
		switchIcon:setPosition(background:getContentSize().width * 0.5, 355)
		background:addChild(switchIcon)
	elseif(tonumber(switchEnum) == ksSwitchActivity) then
		--活动 		--error
		switchIcon = CCSprite:create("images/switch/activity.png")

	elseif(tonumber(switchEnum) == ksSwitchGreatSoldier) then
		--名将
		systemName=GetLocalizeStringBy("key_1744")
		switchIcon = CCSprite:create("images/switch/great_soldier.png")
		switchIcon:setAnchorPoint(ccp(0.5, 0.5))
		switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
		yellowRound:addChild(switchIcon)
		background:addChild(yellowRound)

		--数据拉取
		require "script/network/PreRequest"
		PreRequest.preGetAllStarInfoRquest()

	elseif(tonumber(switchEnum) == ksSwitchContest) then
		--比武
		systemName=GetLocalizeStringBy("key_2182")
		switchIcon = CCSprite:create("images/switch/contest.png")
		switchIcon:setAnchorPoint(ccp(0.5, 0.5))
		switchIcon:setPosition(background:getContentSize().width * 0.5, 355)
		background:addChild(switchIcon)
	elseif(tonumber(switchEnum) == ksSwitchArena) then
		--竞技场
		systemName=GetLocalizeStringBy("key_2156")
		switchIcon = CCSprite:create("images/switch/arena.png")
		switchIcon:setAnchorPoint(ccp(0.5, 0.5))
		switchIcon:setPosition(background:getContentSize().width * 0.5, 355)
		background:addChild(switchIcon)
	elseif(tonumber(switchEnum) == ksSwitchActivityCopy) then
		--活动副本 	--error
		systemName=GetLocalizeStringBy("key_2380")
		switchIcon = CCSprite:create("images/switch/activity_copy.png")
		switchIcon:setAnchorPoint(ccp(0.5, 0.5))
		switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
		yellowRound:addChild(switchIcon)
		background:addChild(yellowRound)

	elseif(tonumber(switchEnum) == ksSwitchPet) then
		--宠物
		systemName=GetLocalizeStringBy("key_1893")
		switchIcon = CCSprite:create("images/switch/pet.png")
		switchIcon:setAnchorPoint(ccp(0.5, 0.5))
		switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
		yellowRound:addChild(switchIcon)
		background:addChild(yellowRound)
	elseif(tonumber(switchEnum) == ksSwitchResource) then
		--资源矿
		systemName=GetLocalizeStringBy("key_1890")
		switchIcon = CCSprite:create("images/switch/resource.png")
		switchIcon:setAnchorPoint(ccp(0.5, 0.5))
		switchIcon:setPosition(background:getContentSize().width * 0.5, 355)
		background:addChild(switchIcon)
 	elseif(tonumber(switchEnum) == ksSwitchStar) then
 		--占星
 		systemName=GetLocalizeStringBy("key_2964")
 		switchIcon = CCSprite:create("images/switch/star.png")
 		switchIcon:setAnchorPoint(ccp(0.5, 0.5))
		switchIcon:setPosition(background:getContentSize().width * 0.5, 355)
		background:addChild(switchIcon)

  	elseif(tonumber(switchEnum) == ksSwitchSignIn) then
 		--签到 		--error
 		systemName=GetLocalizeStringBy("key_2877")
 		switchIcon = CCSprite:create("images/switch/sign_in.png")
 		switchIcon = CCSprite:create("images/switch/sign_in.png")
 		switchIcon:setAnchorPoint(ccp(0.5, 0.5))
		switchIcon:setPosition(background:getContentSize().width * 0.5, 355)
		background:addChild(switchIcon)

		--数据拉取
		require "script/network/PreRequest"
		PreRequest.preGetSignInfo()
 	elseif(tonumber(switchEnum) == ksSwitchLevelGift) then
 		--等级礼包
 		systemName=GetLocalizeStringBy("key_2603")
 		switchIcon = CCSprite:create("images/switch/level_gift.png")
		switchIcon:setAnchorPoint(ccp(0.5, 0.5))
		switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
		yellowRound:addChild(switchIcon)
		background:addChild(yellowRound)
  	elseif(tonumber(switchEnum) == ksSwitchSmithy) then
 		--铁匠铺 	--error
 		systemName=GetLocalizeStringBy("key_3043")
 		-- switchIcon = CCSprite:create("images/switch/star.png")
 	elseif(tonumber(switchEnum) == ksSwitchWeaponForge) then
 		--装备强化 	--error
 		systemName=GetLocalizeStringBy("key_3074")
 		switchIcon = CCSprite:create("images/switch/weapon_forge.png")
 		switchIcon:setAnchorPoint(ccp(0.5, 0.5))
		switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
		yellowRound:addChild(switchIcon)
		background:addChild(yellowRound)
  	elseif(tonumber(switchEnum) == ksSwitchGeneralForge) then
 		--武将强化	--error
 		systemName=GetLocalizeStringBy("key_2912")
 		-- switchIcon = CCSprite:create("images/switch/star.png")
 	elseif(tonumber(switchEnum) == ksSwitchGeneralTransform) then
 		--武将进阶 	--error
 		systemName=GetLocalizeStringBy("key_1137")
 		switchIcon = CCSprite:create("images/main/sub_icons/hero_n.png")
 		switchIcon:setAnchorPoint(ccp(0.5, 0.5))
		switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
		yellowRound:addChild(switchIcon)
		background:addChild(yellowRound)

 	elseif(tonumber(switchEnum) == ksSwitchTreasureForge) then
 		--宝物强化系统
 		systemName=GetLocalizeStringBy("key_1159")

 		return CCNode:create()
 	elseif(tonumber(switchEnum) == ksSwitchRobTreasure  ) then
 		--夺宝系统
 		systemName=GetLocalizeStringBy("key_3089")
 		switchIcon = CCSprite:create("images/switch/rob_treasure.png")
		switchIcon:setAnchorPoint(ccp(0.5, 0.5))
		switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
		yellowRound:addChild(switchIcon)
		background:addChild(yellowRound)
	elseif(tonumber(switchEnum) == ksSwitchResolve) then
		--炼化炉
		systemName=GetLocalizeStringBy("key_1494")
		switchIcon = CCSprite:create("images/main/sub_icons/recycle_n.png")
		switchIcon:setAnchorPoint(ccp(0.5, 0.5))
		switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
		yellowRound:addChild(switchIcon)
		background:addChild(yellowRound)
 	elseif(tonumber(switchEnum) == ksSwitchDestiny) then
 		--天命系统
 		switchIcon = CCSprite:create("images/main/sub_icons/destiny_n.png")
		switchIcon:setAnchorPoint(ccp(0.5, 0.5))
		switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
		yellowRound:addChild(switchIcon)
		background:addChild(yellowRound)
	elseif(tonumber(switchEnum) == ksSwitchGuild) then
 		-- 军团系统
 		switchIcon = CCSprite:create("images/main/sub_icons/guild_n.png")
		switchIcon:setAnchorPoint(ccp(0.5, 0.5))
		switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
		yellowRound:addChild(switchIcon)
		background:addChild(yellowRound)
	elseif(tonumber(switchEnum) == ksSwitchEquipFixed) then
 		-- 洗练系统
 		switchIcon = CCSprite:create("images/switch/xilian.png")
		switchIcon:setAnchorPoint(ccp(0.5, 0.5))
		switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
		yellowRound:addChild(switchIcon)
		background:addChild(yellowRound)
 	elseif(tonumber(switchEnum) == ksSwitchTower) then
 		switchIcon = CCSprite:create("images/switch/tower.png")
		switchIcon:setAnchorPoint(ccp(0.5, 0.5))
		switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
		yellowRound:addChild(switchIcon)
		background:addChild(yellowRound)
 	elseif(tonumber(switchEnum) == ksSwitchWorldBoss) then
 		switchIcon = CCSprite:create("images/switch/world_boos.png")
		switchIcon:setAnchorPoint(ccp(0.5, 0.5))
		switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
		yellowRound:addChild(switchIcon)
		background:addChild(yellowRound)
	elseif(tonumber(switchEnum) == ksSwitchBattleSoul) then
		-- 战魂系统
 		switchIcon = CCSprite:create("images/main/sub_icons/fightSoul_n.png")
		switchIcon:setAnchorPoint(ccp(0.5, 0.5))
		switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
		yellowRound:addChild(switchIcon)
		background:addChild(yellowRound)
	elseif(tonumber(switchEnum) == ksSwitchEveryDayTask) then
		--每日任务
		switchIcon = CCSprite:create("images/main/sub_icons/everyday_n.png")
		switchIcon:setAnchorPoint(ccp(0.5, 0.5))
		switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
		yellowRound:addChild(switchIcon)
		background:addChild(yellowRound)
	elseif(tonumber(switchEnum) == ksHeroBiography) then
		--武将列传
		switchIcon = CCSprite:create("images/biography/bio_button_n.png")
		switchIcon:setAnchorPoint(ccp(0.5, 0.5))
		switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
		yellowRound:addChild(switchIcon)
		background:addChild(yellowRound)
	elseif(tonumber(switchEnum) == ksFindDragon) then
		--寻龙探宝
		switchIcon = CCSprite:create("images/switch/xunlong.png")
		switchIcon:setAnchorPoint(ccp(0.5, 0.5))
		switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
		yellowRound:addChild(switchIcon)
		background:addChild(yellowRound)
	elseif(tonumber(switchEnum) == ksOlympic) then
		-- 擂台争霸
		switchIcon = CCSprite:create("images/switch/olympic.png")
		switchIcon:setAnchorPoint(ccp(0.5, 0.5))
		switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
		yellowRound:addChild(switchIcon)
		background:addChild(yellowRound)
	elseif(tonumber(switchEnum) == ksChangeSkill) then
		-- 主角换技能
		switchIcon = CCSprite:create("images/replaceskill/learn_btn_n.png")
		switchIcon:setAnchorPoint(ccp(0.5, 0.5))
		switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
		yellowRound:addChild(switchIcon)
		background:addChild(yellowRound)
    elseif(tonumber(switchEnum) == ksTransfer) then
        -- 武将变身
        switchIcon = CCSprite:create("images/replaceskill/learn_btn_n.png")
        switchIcon:setAnchorPoint(ccp(0.5, 0.5))
        switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
        yellowRound:addChild(switchIcon)
        background:addChild(yellowRound)
    elseif(tonumber(switchEnum) == ksHeroDevelop ) then
        -- 武将进化
        switchIcon = CCSprite:create("images/develop/developup_btn_n.png")
        switchIcon:setAnchorPoint(ccp(0.5, 0.5))
        switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
        yellowRound:addChild(switchIcon)
        background:addChild(yellowRound)

    elseif(tonumber(switchEnum) == ksWeekendShop) then
     	switchIcon = CCSprite:create("images/weekendShop/weekend_btn_n.png")
        switchIcon:setAnchorPoint(ccp(0.5, 0.5))
        switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
        yellowRound:addChild(switchIcon)
        background:addChild(yellowRound)
    elseif(tonumber(switchEnum) == kMonthSignIn) then
    	-- 月签到
     	switchIcon = CCSprite:create("images/recharge/btn_monthsign_n.png")
        switchIcon:setAnchorPoint(ccp(0.5, 0.5))
        switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
        yellowRound:addChild(switchIcon)
        background:addChild(yellowRound)
    elseif(tonumber(switchEnum) == ksSwitchWarcraft) then
    	-- 阵法
     	switchIcon = CCSprite:create("images/warcraft/warcraft_icon2.png")
        switchIcon:setAnchorPoint(ccp(0.5, 0.5))
        switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
        yellowRound:addChild(switchIcon)
        background:addChild(yellowRound)
    elseif(tonumber(switchEnum) == ksSwitchGodWeapon) then
    	-- 神兵副本
     	switchIcon = CCSprite:create("images/switch/guoguanzhanjiang.png")
        switchIcon:setAnchorPoint(ccp(0.5, 0.5))
        switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
        yellowRound:addChild(switchIcon)
        background:addChild(yellowRound)
    elseif(tonumber(switchEnum) == ksSecondFriend) then
    	-- 助战军
     	switchIcon = CCSprite:create("images/formation/second_icon.png")
        switchIcon:setAnchorPoint(ccp(0.5, 0.5))
        switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
        yellowRound:addChild(switchIcon)
        background:addChild(yellowRound)
    elseif(tonumber(switchEnum) == ksSwitchStarSoul) then
    	-- 主角星魂
     	switchIcon = CCSprite:create("images/athena/enter_n.png")
        switchIcon:setAnchorPoint(ccp(0.5, 0.5))
        switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
        yellowRound:addChild(switchIcon)
        background:addChild(yellowRound)
    elseif(tonumber(switchEnum) == ksSwitchMoon) then
    	-- 水月之境 TODO bzx   换图片
     	switchIcon = CCSprite:create("images/switch/shuiyue.png")
        switchIcon:setAnchorPoint(ccp(0.5, 0.5))
        switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
        yellowRound:addChild(switchIcon)
        background:addChild(yellowRound)
    elseif(tonumber(switchEnum) == ksSwitchHellCopy) then
    	-- 炼狱副本 TODO llp   换图片
     	switchIcon = CCSprite:create("images/switch/purgatory.png")
        switchIcon:setAnchorPoint(ccp(0.5, 0.5))
        switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
        yellowRound:addChild(switchIcon)
        background:addChild(yellowRound)
    elseif(tonumber(switchEnum) == ksSwitchDrug) then
    	-- 丹药系统 TODO djn   换图片
     	switchIcon = CCSprite:create("images/switch/danyao.png")
        switchIcon:setAnchorPoint(ccp(0.5, 0.5))
        switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
        yellowRound:addChild(switchIcon)
        background:addChild(yellowRound)
    elseif(tonumber(switchEnum) == ksSwitchLoyal) then
    	-- 聚义厅 TODO djn   换图片
     	switchIcon = CCSprite:create("images/switch/loyal.png")
        switchIcon:setAnchorPoint(ccp(0.5, 0.5))
        switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
        yellowRound:addChild(switchIcon)
        background:addChild(yellowRound)
    elseif(tonumber(switchEnum) == ksSwitchKFBW) then
    	-- 跨服比武  yr
     	switchIcon = CCSprite:create("images/switch/kfbw.png")
        switchIcon:setAnchorPoint(ccp(0.5, 0.5))
        switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
        yellowRound:addChild(switchIcon)
        background:addChild(yellowRound)
 	end
 	local textInfo = {}
 	require "db/DB_Switch"
	local switchInfo = DB_Switch.getDataById(switchEnum)
 	systemName = switchInfo.name


	textInfo[1] = CCRenderLabel:create(GetLocalizeStringBy("key_2056"), g_sFontPangWa, 35, 1, ccc3(0,0,0) ,type_stroke)
	textInfo[1]:setColor(ccc3(0xff,0xe4,0x00))

	textInfo[2] = CCRenderLabel:create("【" .. systemName .. "】", g_sFontPangWa, 35, 1, ccc3(0,0,0) ,type_stroke)
	textInfo[2]:setColor(ccc3(65, 255, 185))

	textInfo[3] = CCRenderLabel:create(GetLocalizeStringBy("key_1774"), g_sFontPangWa, 35, 1, ccc3(0,0,0) ,type_stroke)
	textInfo[3]:setColor(ccc3(0xff,0xe4,0x00))

	local titleLable = BaseUI.createHorizontalNode(textInfo)
	titleLable:setAnchorPoint(ccp(0.5, 0.5))
	titleLable:setPosition(ccpsprite(0.5, 0.5, background))
	background:addChild(titleLable)

	--兼容东南亚英文版
	local alertContent = CCRenderLabel:create(switchInfo.alertContent, g_sFontPangWa, 35, 1, ccc3(0,0,0) ,type_stroke)
	alertContent:setColor(ccc3(0xff,0xe4,0x00))
	alertContent:setAnchorPoint(ccp(0.5, 0.5))
	alertContent:setPosition(ccpsprite(0.5, 0.36, background))
	background:addChild(alertContent)
	setAdaptNode(background)
	--标题过长兼容
	if titleLable:getContentSize().width > background:getContentSize().width then
		titleLable:setScale(background:getContentSize().width/titleLable:getContentSize().width - 0.03)
	end
	--内容过长兼容
	if alertContent:getContentSize().width > background:getContentSize().width then
		alertContent:setScale(background:getContentSize().width/alertContent:getContentSize().width - 0.03)
	end
 	return colorLayer
end

function showNewSwitch( switchEnum )
	isSwithPanelShow = true
	if(isFight == true) then
		isHaveNotification = true
		notificationEnum = switchEnum
	else
		-- 关闭跟新手引导冲突的 神秘商人板子
		require "script/ui/shopall/MysteryMerchant/MysteryMerchantDialog"
		MysteryMerchantDialog.setClosed(true)

		-- 关闭抢十次面板引起的冲突
		require "script/ui/treasure/QuickRobResultLayer"
		QuickRobResultLayer.closeMenuCallBack()

		local runningScene = CCDirector:sharedDirector():getRunningScene()
		runningScene:addChild(SwitchOpen.create(switchEnum), 2000)
	end
end

function checkButtonCallback( tag,sender )
	isSwithPanelShow = false
	--用于防止用户点的快
	require "script/guide/NewGuide"
	NewGuide.OpenNoTouchMode()
	local actionArray = CCArray:create()
	actionArray:addObject(CCDelayTime:create(0.5))
	actionArray:addObject(CCCallFunc:create(function ( ... )
		NewGuide.closeNoTouchMode()
	end))
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:runAction(CCSequence:create(actionArray))

	--前往功能节点
	colorLayer:removeFromParentAndCleanup(true)
	local switchEnum = sender:getTag()
	if(tonumber(switchEnum) == ksSwitchFormation) then
		local main_base_layer = MainBaseLayer.create()
		MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
		MainScene.setMainSceneViewsVisible(true,true,true)
  		-- 阵形
  		require "script/guide/NewGuide"
  		NewGuide.guideClass  = ksGuideFormation
  		BTUtil:setGuideState(true)
	    require "script/guide/FormationGuide"
	    if(NewGuide.guideClass ==  ksGuideFormation and FormationGuide.stepNum == 0) then
	        CCLuaLog("start fromation guide")
	        local formationButton = MenuLayer.getMenuItemNode(2)
	        local touchRect       = getSpriteScreenRect(formationButton)
	        FormationGuide.show(1, touchRect)
	        NewGuide.closeNoTouchMode()
	    end
	elseif(tonumber(switchEnum) == ksSwitchForge) then
		--强化所
		require "script/guide/NewGuide"
		NewGuide.guideClass  = ksGuideForge
		BTUtil:setGuideState(true)
		require "script/ui/main/MainBaseLayer"
		local main_base_layer = MainBaseLayer.create()
		MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
		MainScene.setMainSceneViewsVisible(true,true,true)
		print(GetLocalizeStringBy("key_2887"))

		local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			addStrengthenNewGuide()
		end))
		main_base_layer:runAction(seq)

	elseif(tonumber(switchEnum) == ksSwitchShop) then
		--商店
		require "script/ui/main/MainBaseLayer"
		local main_base_layer = MainBaseLayer.create()
		MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
		MainScene.setMainSceneViewsVisible(true,true,true)
	elseif(tonumber(switchEnum) == ksSwitchEliteCopy) then
		--精英副本
		require "script/ui/main/MainBaseLayer"
		local main_base_layer = MainBaseLayer.create()
		MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
		MainScene.setMainSceneViewsVisible(true,true,true)
		print(GetLocalizeStringBy("key_2748"))

		local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			addGuideEliteCopyGuide1()
		end))
		main_base_layer:runAction(seq)

	elseif(tonumber(switchEnum) == ksSwitchActivity) then
		--活动
		require "script/ui/active/ActiveList"
		local  activeList = ActiveList.createActiveListLayer()
		MainScene.changeLayer(activeList, "activeList")
	elseif(tonumber(switchEnum) == ksSwitchGreatSoldier) then
		--名将
		print(GetLocalizeStringBy("key_1744"))
		require "script/ui/main/MainBaseLayer"
		local main_base_layer = MainBaseLayer.create()
		MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
		MainScene.setMainSceneViewsVisible(true,true,true)
		local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
				addGuideStarHeroGuide1()
		end))
		main_base_layer:runAction(seq)
	elseif(tonumber(switchEnum) == ksSwitchContest) then
		--比武
		print("ksSwitchContest")
		require "script/ui/main/MainBaseLayer"
		local main_base_layer = MainBaseLayer.create()
		MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
		MainScene.setMainSceneViewsVisible(true,true,true)
		local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			addGuideMatchGuide1()
		end))
		main_base_layer:runAction(seq)
	elseif(tonumber(switchEnum) == ksSwitchArena) then
		--竞技场
		require "script/ui/main/MainBaseLayer"
		local main_base_layer = MainBaseLayer.create()
		MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
		MainScene.setMainSceneViewsVisible(true,true,true)
		print(GetLocalizeStringBy("key_2156"))

		local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			addGuideArenaGuide1()
		end))
		main_base_layer:runAction(seq)

	elseif(tonumber(switchEnum) == ksSwitchActivityCopy) then
		--活动副本
		print("ksSwitchActivityCopy")
		require "script/ui/copy/CopyLayer"
		local copyLayer = CopyLayer.createLayer(true, CopyLayer.Active_Copy_Tag)
		MainScene.changeLayer(copyLayer, "copyLayer")
	elseif(tonumber(switchEnum) == ksSwitchPet) then
		--宠物
		require "script/ui/main/MainBaseLayer"
		local main_base_layer = MainBaseLayer.create()
		MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
		MainScene.setMainSceneViewsVisible(true,true,true)
		print(GetLocalizeStringBy("key_1893"))

		local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
				addGuidePetGuide1()
		end))
		main_base_layer:runAction(seq)

	elseif(tonumber(switchEnum) == ksSwitchResource) then
		--资源矿
		require "script/ui/main/MainBaseLayer"
		local main_base_layer = MainBaseLayer.create()
		MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
		MainScene.setMainSceneViewsVisible(true,true,true)
		print(GetLocalizeStringBy("key_1890"))

		local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			addGuideMineralGuide1()
		end))
		main_base_layer:runAction(seq)
 	elseif(tonumber(switchEnum) == ksSwitchStar) then
 		--占星
 		print(GetLocalizeStringBy("key_2964"))
		require "script/ui/main/MainBaseLayer"
		local main_base_layer = MainBaseLayer.create()
		MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
		MainScene.setMainSceneViewsVisible(true,true,true)
		local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
				addGuideAstrologyGuide1()
		end))
		main_base_layer:runAction(seq)

 	elseif(tonumber(switchEnum) == ksSwitchSignIn) then
 		--签到
		require "script/ui/main/MainBaseLayer"
		local main_base_layer = MainBaseLayer.create()
		MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
		MainScene.setMainSceneViewsVisible(true,true,true)

		local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			addSignInGuide()
		end))
		main_base_layer:runAction(seq)

 	elseif(tonumber(switchEnum) == ksSwitchLevelGift) then
 		--等级礼包
 		require "script/ui/main/MainBaseLayer"
		local main_base_layer = MainBaseLayer.create()
		MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
		MainScene.setMainSceneViewsVisible(true,true,true)

		local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			addLevelGiftBagNewGuide()
		end))
		main_base_layer:runAction(seq)

  	elseif(tonumber(switchEnum) == ksSwitchSmithy) then
 		--铁匠铺
 	elseif(tonumber(switchEnum) == ksSwitchWeaponForge) then
 		--装备强化
 		require "script/ui/main/MainBaseLayer"
		local main_base_layer = MainBaseLayer.create()
		MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
		MainScene.setMainSceneViewsVisible(true,true,true)

		local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			addGuideEquipGuide1()
		end))
		main_base_layer:runAction(seq)

  	elseif(tonumber(switchEnum) == ksSwitchGeneralForge) then
 		--武将强化

 	elseif(tonumber(switchEnum) == ksSwitchGeneralTransform) then
 		--武将进阶
 		require "script/ui/main/MainBaseLayer"
		local main_base_layer = MainBaseLayer.create()
		MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
		MainScene.setMainSceneViewsVisible(true,true,true)

		local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			addGeneralUpgradeGuide()
		end))
		main_base_layer:runAction(seq)
 	 elseif(tonumber(switchEnum) == ksSwitchRobTreasure) then
 		--夺宝
 		require "script/guide/NewGuide"
		NewGuide.guideClass  = ksGuideRobTreasure
		BTUtil:setGuideState(true)
		require "script/ui/active/ActiveList"
		local  activeList = ActiveList.createActiveListLayer()
		MainScene.changeLayer(activeList, "activeList")
 	 elseif(tonumber(switchEnum) == ksSwitchResolve) then
 		--炼化炉
 		require "script/ui/main/MainBaseLayer"
		local main_base_layer = MainBaseLayer.create()
		MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
		MainScene.setMainSceneViewsVisible(true,true,true)

		local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			addResolveGuide()
		end))
		main_base_layer:runAction(seq)
 	elseif(tonumber(switchEnum) == ksSwitchDestiny) then
 		--天命系统
 		require "script/ui/main/MainBaseLayer"
		local main_base_layer = MainBaseLayer.create()
		MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
		MainScene.setMainSceneViewsVisible(true,true,true)

		local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			addGuideDestinyGuide1()
		end))
		main_base_layer:runAction(seq)
	elseif(tonumber(switchEnum) == ksSwitchGuild) then
 		-- 军团系统
 		require "script/ui/guild/GuildImpl"
		GuildImpl.showLayer()
	elseif(tonumber(switchEnum) == ksSwitchEquipFixed) then
		-- 装备洗练
		require "script/ui/bag/BagLayer"
		local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_Arming)
		MainScene.changeLayer(bagLayer, "bagLayer")
 	elseif(tonumber(switchEnum) == ksSwitchTower) then
		require "script/ui/active/ActiveList"
		local  activeList = ActiveList.createActiveListLayer()
		MainScene.changeLayer(activeList, "activeList")
 	elseif(tonumber(switchEnum) == ksSwitchWorldBoss) then
 		--世界boss
 	elseif(tonumber(switchEnum) == ksSwitchBattleSoul) then
 		-- 战魂系统
 		require "script/ui/huntSoul/HuntSoulLayer"
        local layer = HuntSoulLayer.createHuntSoulLayer()
        MainScene.changeLayer(layer, "huntSoulLayer")
    elseif(tonumber(switchEnum) == ksSwitchEveryDayTask) then
    	--每日任务

    	local runningScene = CCDirector:sharedDirector():getRunningScene()
    	require "script/utils/BaseUI"
    	local maskLayer = BaseUI.createMaskLayer()
    	runningScene:addChild(maskLayer,5000)

    	local actionArray = CCArray:create()
    	actionArray:addObject(CCCallFunc:create( function ( ... )
    		require "script/ui/main/MainBaseLayer"
			local main_base_layer = MainBaseLayer.create()
			MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
	        MainScene.setMainSceneViewsVisible(true,true,true)
    	end))
    	actionArray:addObject(CCDelayTime:create(0.2))
    	actionArray:addObject(CCCallFunc:create(function ( ... )
    		require "script/ui/everyday/EverydayLayer"
        	EverydayLayer.showEverydayLayer()
    	end))
    	actionArray:addObject(CCCallFunc:create(function ( ... )
    		maskLayer:removeFromParentAndCleanup(true)
    	end))

    	local seq = CCSequence:create(actionArray)
    	runningScene:runAction(seq)
    elseif(tonumber(switchEnum) == ksHeroBiography) then
 		-- 武将列传
 		require "script/ui/main/MainBaseLayer"
		local main_base_layer = MainBaseLayer.create()
		MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
		MainScene.setMainSceneViewsVisible(true,true,true)

		local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			addGuideLieZhuanGuide1()
		end))
		main_base_layer:runAction(seq)
	elseif(tonumber(switchEnum) == ksFindDragon) then
 		-- 寻龙探宝
 		require "script/ui/main/MainBaseLayer"
		local main_base_layer = MainBaseLayer.create()
		MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
		MainScene.setMainSceneViewsVisible(true,true,true)

		local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			addGuideXunLongGuide1()
		end))
		main_base_layer:runAction(seq)
	elseif(tonumber(switchEnum) == ksOlympic) then
 		-- 擂台争霸
 		addGuideOlympic()
 		require "script/ui/active/ActiveList"
		local  activeList = ActiveList.createActiveListLayer()
		MainScene.changeLayer(activeList, "activeList")
	elseif(tonumber(switchEnum) == ksChangeSkill) then
 		-- 主角换技能
 		require "script/ui/main/MainBaseLayer"
		local main_base_layer = MainBaseLayer.create()
		MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
		MainScene.setMainSceneViewsVisible(true,true,true)

		local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			addGuideChangeSkillGuide1()
		end))
		main_base_layer:runAction(seq)
    elseif(tonumber(switchEnum) == ksTransfer) then
 		-- 武将变身
        -- require "script/ui/rechargeActive/RechargeActiveMain"
        -- local layer = RechargeActiveMain.create(RechargeActiveMain._tagTransfer)
        -- MainScene.changeLayer(layer, "layer")
        require "script/ui/transform/TransformMainLayer"
        TransformMainLayer.showLayer()
    elseif(tonumber(switchEnum) == ksHeroDevelop ) then
 		-- 武将进化
 		require "script/ui/main/MainBaseLayer"
		local main_base_layer = MainBaseLayer.create()
		MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
		MainScene.setMainSceneViewsVisible(true,true,true)

		local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			addGuideHeroDevelopGuide1()
		end))
		main_base_layer:runAction(seq)

	elseif(tonumber(switchEnum) == ksWeekendShop) then
		--周末商店
		require "script/ui/shopall/ShoponeLayer"
		ShoponeLayer.show(ShoponeLayer.ksTagZhoumoPerson)
    elseif(tonumber(switchEnum) == kMonthSignIn) then
		-- 月签到
		require "script/ui/rechargeActive/RechargeActiveMain"
        local layer = RechargeActiveMain.create(RechargeActiveMain._tagMonthSign)
        MainScene.changeLayer(layer, "monthSign")
 	elseif(tonumber(switchEnum) == ksSwitchWarcraft) then
 		-- 阵法
 		require "script/ui/main/MainBaseLayer"
		local main_base_layer = MainBaseLayer.create()
		MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
		MainScene.setMainSceneViewsVisible(true,true,true)

		local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			addGuideWarcraftGuide1()
		end))
		main_base_layer:runAction(seq)
	elseif(tonumber(switchEnum) == ksSwitchGodWeapon) then
 		-- 神兵副本
 		require "script/ui/active/ActiveList"
		local  activeList = ActiveList.createActiveListLayer()
		MainScene.changeLayer(activeList, "activeList")
	elseif(tonumber(switchEnum) == ksSecondFriend) then
 		-- 助战军
 		require "script/ui/formation/FormationLayer"
        local formationLayer = FormationLayer.createLayer()
        MainScene.changeLayer(formationLayer, "formationLayer")
    elseif(tonumber(switchEnum) == ksSwitchStarSoul) then
    	-- 主角星魂
    	require "script/ui/destiny/DestinyLayer"
  		local destinyLayer = DestinyLayer.createLayer()
  		MainScene.changeLayer(destinyLayer, "destinyLayer")
  	elseif(tonumber(switchEnum) == ksSwitchMoon) then
  		-- 水月之镜
  		require "script/ui/moon/MoonLayer"
  		MoonLayer.show()
  	elseif(tonumber(switchEnum) == ksSwitchHellCopy) then
  		-- -- 炼狱副本 TODO llp   显示界面
  		require "script/ui/active/ActiveList"
		local  activeList = ActiveList.createActiveListLayer()
		MainScene.changeLayer(activeList, "activeList")
  	elseif(tonumber(switchEnum) == ksSwitchDrug) then
  		-- -- 丹药系统 TODO djn   显示界面
  		require "script/ui/formation/FormationLayer"
        local formationLayer = FormationLayer.createLayer()
        MainScene.changeLayer(formationLayer, "formationLayer")
    elseif(tonumber(switchEnum) == ksSwitchLoyal) then
  		-- -- 聚义厅系统 TODO djn   显示界面
        require "script/ui/star/loyalty/LoyaltyLayer"
        local loyalLayer = LoyaltyLayer.createLayer()
        MainScene.changeLayer(loyalLayer, "loyalLayer")
    elseif(tonumber(switchEnum) == ksSwitchKFBW) then
  		-- 跨服比武  yr  跳转到ActiveList   
 		require "script/ui/active/ActiveList"
		local  activeList = ActiveList.createActiveListLayer()
		MainScene.changeLayer(activeList, "activeList")
 	end
end

function registerFighterNotification( ... )
	CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(fightNotificationCallback)
end

function fightNotificationCallback( notificationName )
	if(notificationName == "NC_BeginFight") then
		--进入战斗场景
		isFight = true
		print("fight notification NC_BeginFight")
	elseif(notificationName ==  "NC_FightOver") then
		--退出战斗场景
		isFight = false
		if(isHaveNotification == true) then
			local runningScene = CCDirector:sharedDirector():getRunningScene()
			runningScene:addChild(SwitchOpen.create(notificationEnum), 2000)
			isHaveNotification = false
			-- notificationEnum = nil
		end
		print("fight notification NC_FightOver")
	end

	---5级等级礼包
	require "script/guide/LevelGiftBagGuide"
	if(notificationName == "NC_BeginFight") then

	elseif(notificationName ==  "NC_FightOver") then
		--退出战斗场景
		require "script/guide/NewGuide"
		print ("LevelGiftBagGuide.fightTimes=", LevelGiftBagGuide.fightTimes)
		print("NewGuide.guideClass=",NewGuide.guideClass)
		if(NewGuide.guideClass ==  ksGuideFiveLevelGift)then
			LevelGiftBagGuide.fightTimes = LevelGiftBagGuide.fightTimes + 1
			print ("LevelGiftBagGuide.fightTimes=", LevelGiftBagGuide.fightTimes)
		end
	end

	--强化所
	require "script/guide/StrengthenGuide"
	if(notificationName == "NC_BeginFight") then

	elseif(notificationName ==  "NC_FightOver") then
		--退出战斗场景
		require "script/guide/NewGuide"
		print ("fightTimes=", StrengthenGuide.fightTimes)
		print("NewGuide.guideClass=",NewGuide.guideClass)
		if(NewGuide.guideClass ==  ksGuideForge)then
			StrengthenGuide.fightTimes = StrengthenGuide.fightTimes + 1
			print ("fightTimes=", StrengthenGuide.fightTimes)
		end
	end

	--10级等级礼包
	--[[
	--去掉十级等级礼包
	if(notificationName ==  "NC_FightOver") then
		print("10级等级礼包 isTenLevelOpen=", isTenLevelOpen)
		if(isTenLevelOpen == true) then
			local runningScene = CCDirector:sharedDirector():getRunningScene()
			runningScene:addChild(createTenLevelAlter(), 2000)
		end
	end
	]]--
	-- 第四个栏位开启
	if(notificationName ==  "NC_FightOver") then
		print("第四个栏位开启 isForthFormation=", isForthFormation)
		if(isForthFormation == true) then
			local runningScene = CCDirector:sharedDirector():getRunningScene()
			runningScene:addChild(createForthFormationAlter(), 2000)
		end
	end

end

function registerLevelUpNotification(  )
	require "script/model/user/UserModel"
	UserModel.addObserverForLevelUp("switchOpenTenLevel", levelUpCallback )
end

function levelUpCallback( p_level )

	--[[
	--去掉十级等级礼包引导
	print("player level up to " .. p_level)
	if(tonumber(p_level) == 10) then
		if(isFight == true ) then
			print("player level up to and is fight == true")
			isTenLevelOpen = true
		else
			local runningScene = CCDirector:sharedDirector():getRunningScene()
			runningScene:addChild(createTenLevelAlter() , 2000)
		end
	end
	]]--
	-- 11级开启第四个上阵栏位
	if(tonumber(p_level) == openForthPositionLevel) then
		if(isFight == true ) then
			print("player level up to and is fight == true")
			isForthFormation = true
		else
			local runningScene = CCDirector:sharedDirector():getRunningScene()
			runningScene:addChild(createForthFormationAlter() , 2000)
		end
	end
end


-- 十级等级礼包弹出面板
function createTenLevelAlter( ... )

	print("SwitchOpen createTenLevelAlter")
	isTenLevelOpen = false
	colorLayer = CCLayerColor:create(ccc4(0, 0, 0, 200))
	colorLayer:setPosition(ccp(0, 0))
	colorLayer:setAnchorPoint(ccp(0, 0))
	colorLayer:setTouchEnabled(true)
	colorLayer:setTouchPriority(-512)
	colorLayer:registerScriptTouchHandler(function ( eventType,x,y )
		if(eventType == "began") then
			return true
		end
	end,false, - 512, true)

	local background = CCSprite:create("images/switch/dialog_background.png")
	background:setPosition(ccps(0.5, 0.5))
	background:setAnchorPoint(ccp(0.5, 0.5))
	colorLayer:addChild(background)
	--标题
	titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(background:getContentSize().width/2, background:getContentSize().height - 7 )
	background:addChild(titlePanel)

	titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1839"), g_sFontPangWa, 35, 1, ccc3(0,0,0))
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	local x = (titlePanel:getContentSize().width - titleLabel:getContentSize().width)/2
	local y = titlePanel:getContentSize().height - (titlePanel:getContentSize().height - titleLabel:getContentSize().height)/2
	titleLabel:setPosition(ccp(x , y))
	titlePanel:addChild(titleLabel)


	local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	menu:setTouchPriority(-1000)
	background:addChild(menu)

	local checkButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(189,73),GetLocalizeStringBy("key_1354"),ccc3(255,222,0))
    checkButton:setAnchorPoint(ccp(0.5, 0.5))
    checkButton:setPosition(ccpsprite( 0.5, 0.12, background))
	menu:addChild(checkButton)
	checkButton:registerScriptTapHandler(tenLevelOpenCallback)

	local yellowRound = CCSprite:create("images/switch/yellow_round.png")
	yellowRound:setAnchorPoint(ccp(0.5, 0.5))
	yellowRound:setPosition(background:getContentSize().width * 0.5, 355)


	local switchIcon = nil
	local systemName = ""

	systemName=GetLocalizeStringBy("key_2603")
	switchIcon = CCSprite:create("images/switch/level_gift.png")
	switchIcon:setAnchorPoint(ccp(0.5, 0.5))
	switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
	yellowRound:addChild(switchIcon)
	background:addChild(yellowRound)

	local textInfo = {}
	textInfo[1] = CCRenderLabel:create(GetLocalizeStringBy("key_2967"), g_sFontPangWa, 35, 1, ccc3(0,0,0) ,type_stroke)
	textInfo[2] = CCRenderLabel:create(GetLocalizeStringBy("key_3313"), g_sFontPangWa, 35, 1, ccc3(0,0,0) ,type_stroke)

	local textDes = BaseUI.createHorizontalNode(textInfo)
	textDes:setPosition(ccpsprite(0.5, 0.55, background))
	textDes:setAnchorPoint(ccp(0.5, 0.5))
	background:addChild(textDes)

	local alertContent = CCRenderLabel:create(GetLocalizeStringBy("key_1939"), g_sFontPangWa, 35, 1, ccc3(0,0,0) ,type_stroke)
	alertContent:setColor(ccc3(0xff,0xe4,0x00))
	local x = background:getContentSize().width*0.5 - alertContent:getContentSize().width*0.5
	local y = background:getContentSize().height *  0.4
	alertContent:setPosition(x, y)
	background:addChild(alertContent)
	setAdaptNode(background)

	-- return colorLayer
	return CCNode:create() -- 去掉10级等级礼包引导

end

function tenLevelOpenCallback( tag, sender)

	colorLayer:removeFromParentAndCleanup(true)
	--10等级礼包
	require "script/ui/main/MainBaseLayer"
	local main_base_layer = MainBaseLayer.create()
	MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
	MainScene.setMainSceneViewsVisible(true,true,true)

	local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			addTenLevelGiftNewGuide()
		end))
	main_base_layer:runAction(seq)

end


-- 十级等级礼包第一步
function addTenLevelGiftNewGuide( ... )
	require "script/guide/NewGuide"
	require "script/guide/TenLevelGiftGuide"
	NewGuide.guideClass =  ksGuideTenLevelGift
	BTUtil:setGuideState(true)
	if(NewGuide.guideClass ==  ksGuideTenLevelGift and TenLevelGiftGuide.stepNum == 0) then
        local formationButton = LevelRewardBtn.getReardBtn()
        local touchRect       = getSpriteScreenRect(formationButton)
        TenLevelGiftGuide.show(1, touchRect)
    end
end


----------------------new player gudie------------------
-- add by lichenyang
function addStrengthenNewGuide( ... )

   	---[==[ 第一步主界面强化所按钮
    ---------------------新手引导---------------------------------
        --add by licong 2013.09.06
        print("start StrengthenGuide")
        require "script/guide/NewGuide"
        require "script/guide/StrengthenGuide"
        if(NewGuide.guideClass ==  ksGuideForge and StrengthenGuide.stepNum == 0) then
        	BTUtil:setGuideState(true)

            require "script/ui/main/MainBaseLayer"
            local strengthenButton = MainBaseLayer.getMainMenuItem(MainBaseLayer._ksTagHero)
            local touchRect = getSpriteScreenRect(strengthenButton)
            StrengthenGuide.show(1, touchRect)
        end
     ---------------------end-------------------------------------
    --]==]
end

function addLevelGiftBagNewGuide( ... )
    ---[==[ 第一步主界面等级礼包按钮
    ---------------------新手引导---------------------------------
        --add by licong 2013.09.09
        require "script/guide/NewGuide"
        NewGuide.guideClass  = ksGuideFiveLevelGift
        BTUtil:setGuideState(true)
        if(NewGuide.guideClass ==  ksGuideFiveLevelGift) then
            print("start LevelGiftBagGuide guide")
            require "script/guide/LevelGiftBagGuide"
            require "script/ui/level_reward/LevelRewardBtn"
            local levelGiftBagGuide_button = LevelRewardBtn.getReardBtn()
            local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
            LevelGiftBagGuide.show(1, touchRect)
        end
     ---------------------end-------------------------------------
    --]==]
end


-- 签到第一步
function addSignInGuide( ... )
	require "script/guide/NewGuide"
	NewGuide.guideClass = ksGuideSignIn
	BTUtil:setGuideState(true)
	require "script/guide/SignInGuide"
    if(NewGuide.guideClass ==  ksGuideSignIn and SignInGuide.stepNum == 0) then
        require "script/guide/FormationGuide"
        require "script/ui/sign/SignRewardLayer"
        local formationButton = SignRewardLayer.getSignBtn()
        local touchRect       = getSpriteScreenRect(formationButton)
        SignInGuide.show(1, touchRect)
    end
end






-- 第四个上阵栏位开启面板
function createForthFormationAlter( ... )

	print("SwitchOpen createForthFormationAlter")
	isForthFormation = false
	colorLayer = CCLayerColor:create(ccc4(0, 0, 0, 200))
	colorLayer:setPosition(ccp(0, 0))
	colorLayer:setAnchorPoint(ccp(0, 0))
	colorLayer:setTouchEnabled(true)
	colorLayer:setTouchPriority(-512)
	colorLayer:registerScriptTouchHandler(function ( eventType,x,y )
		if(eventType == "began") then
			return true
		end
	end,false, - 512, true)

	local background = CCSprite:create("images/switch/dialog_background.png")
	background:setPosition(ccps(0.5, 0.5))
	background:setAnchorPoint(ccp(0.5, 0.5))
	colorLayer:addChild(background)
	--标题
	titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(background:getContentSize().width/2, background:getContentSize().height - 7 )
	background:addChild(titlePanel)

	titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1839"), g_sFontPangWa, 35, 1, ccc3(0,0,0))
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	local x = (titlePanel:getContentSize().width - titleLabel:getContentSize().width)/2
	local y = titlePanel:getContentSize().height - (titlePanel:getContentSize().height - titleLabel:getContentSize().height)/2
	titleLabel:setPosition(ccp(x , y))
	titlePanel:addChild(titleLabel)


	local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	menu:setTouchPriority(-1000)
	background:addChild(menu)

	local checkButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(189,73),GetLocalizeStringBy("key_1354"),ccc3(255,222,0))
    checkButton:setAnchorPoint(ccp(0.5, 0.5))
    checkButton:setPosition(ccpsprite( 0.5, 0.12, background))
	menu:addChild(checkButton)
	checkButton:registerScriptTapHandler(forthFormationOpenCallback)

	local yellowRound = CCSprite:create("images/switch/yellow_round.png")
	yellowRound:setAnchorPoint(ccp(0.5, 0.5))
	yellowRound:setPosition(background:getContentSize().width * 0.5, 355)


	local switchIcon = nil
	local systemName = ""

	systemName=GetLocalizeStringBy("key_2492")
	switchIcon = CCSprite:create("images/switch/formation.png")
	switchIcon:setAnchorPoint(ccp(0.5, 0.5))
	switchIcon:setPosition(ccpsprite(0.5, 0.5, yellowRound))
	yellowRound:addChild(switchIcon)
	background:addChild(yellowRound)

	local textInfo = {}
	textInfo[1] = CCRenderLabel:create(GetLocalizeStringBy("key_3114"), g_sFontPangWa, 35, 1, ccc3(0,0,0) ,type_stroke)
	textInfo[1]:setColor(ccc3(0xff, 0xe4, 0x00))
	local textDes = BaseUI.createHorizontalNode(textInfo)
	textDes:setPosition(ccpsprite(0.5, 0.55, background))
	textDes:setAnchorPoint(ccp(0.5, 0.5))
	background:addChild(textDes)
	setAdaptNode(background)
	return colorLayer

end

function forthFormationOpenCallback( tag, sender)

	colorLayer:removeFromParentAndCleanup(true)
	--10等级礼包
	require "script/ui/main/MainBaseLayer"
	local main_base_layer = MainBaseLayer.create()
	MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
	MainScene.setMainSceneViewsVisible(true,true,true)

    ---[==[ 第4个上阵栏位开启 阵容
        --add by licong 2013.09.09
        print("start ForthFormationGuide guide")
        require "script/guide/NewGuide"
        NewGuide.guideClass  = ksGuideForthFormation
        BTUtil:setGuideState(true)
        if(NewGuide.guideClass ==  ksGuideForthFormation) then
            require "script/guide/ForthFormationGuide"
            require "script/ui/main/MenuLayer"
            local forthFormationGuide_button = MenuLayer.getMenuItemNode(2)
            local touchRect = getSpriteScreenRect(forthFormationGuide_button)
            ForthFormationGuide.show(1, touchRect)
        end
    --]==]
end

-- 精英副本 第一步
function addGuideEliteCopyGuide1( ... )
	require "script/guide/NewGuide"
	NewGuide.guideClass  = ksGuideEliteCopy
	BTUtil:setGuideState(true)
	require "script/guide/EliteCopyGuide"
    if(NewGuide.guideClass ==  ksGuideEliteCopy and EliteCopyGuide.stepNum == 0) then
       	require "script/ui/main/MenuLayer"
        local eliteButton = MenuLayer.getMenuItemNode(3)
        local touchRect   = getSpriteScreenRect(eliteButton)
        EliteCopyGuide.show(1, touchRect)
    end
end


---[==[竞技场 第一步
function addGuideArenaGuide1( ... )
	require "script/guide/NewGuide"
	NewGuide.guideClass  = ksGuideArena
	BTUtil:setGuideState(true)
	require "script/guide/ArenaGuide"
    if(NewGuide.guideClass ==  ksGuideArena and ArenaGuide.stepNum == 0) then
       	require "script/ui/main/MenuLayer"
        local arenaButton = MenuLayer.getMenuItemNode(4)
        local touchRect   = getSpriteScreenRect(arenaButton)
        ArenaGuide.show(1, touchRect)
    end
end
--]==]

---[==[宠物 第一步
function addGuidePetGuide1( ... )
	require "script/guide/NewGuide"
	NewGuide.guideClass  = ksGuidePet
	BTUtil:setGuideState(true)
	require "script/guide/PetGuide"
    if(NewGuide.guideClass ==  ksGuidePet and PetGuide.stepNum == 0) then
       	require "script/ui/main/MainBaseLayer"
        local petButton = MainBaseLayer.getMainMenuItem(MainBaseLayer._ksTagPet)
        local touchRect   = getSpriteScreenRect(petButton)
        PetGuide.show(1, touchRect)
    end
end
--]==]


---[==[资源矿 第一步
function addGuideMineralGuide1( ... )
	require "script/guide/NewGuide"
	NewGuide.guideClass  = ksGuideResource
	BTUtil:setGuideState(true)
	require "script/guide/MineralGuide"
    if(NewGuide.guideClass ==  ksGuideResource and MineralGuide.stepNum == 0) then
       	require "script/ui/main/MenuLayer"
        local mineralButton = MenuLayer.getMenuItemNode(4)
        local touchRect   = getSpriteScreenRect(mineralButton)
        MineralGuide.show(1, touchRect)
    end
end
--]==]

---[==[名将 第一步
function addGuideStarHeroGuide1( ... )
	require "script/guide/NewGuide"
	NewGuide.guideClass  = ksGuideGreatSoldier
	BTUtil:setGuideState(true)
	require "script/guide/StarHeroGuide"
    if(NewGuide.guideClass ==  ksGuideGreatSoldier and StarHeroGuide.stepNum == 0) then
       	require "script/ui/main/MainBaseLayer"
        local starHeroButton = MainBaseLayer.getMainMenuItem(MainBaseLayer._ksTagFair)
        local touchRect   = getSpriteScreenRect(starHeroButton)
        StarHeroGuide.show(1, touchRect)
    end
end
--]==]

---[==[占星 第一步
function addGuideAstrologyGuide1( ... )
	require "script/guide/NewGuide"
	NewGuide.guideClass  = ksGuideAstrology
	BTUtil:setGuideState(true)
	require "script/guide/AstrologyGuide"
    if(NewGuide.guideClass ==  ksGuideAstrology and AstrologyGuide.stepNum == 0) then
       	require "script/ui/main/MainBaseLayer"
        local astrologyButton = MainBaseLayer.getMainMenuItem(MainBaseLayer._ksTagHoroscope)
        local touchRect   = getSpriteScreenRect(astrologyButton)
        AstrologyGuide.show(1, touchRect)
    end
end
--]==]

---[==[比武 第一步
---------------------新手引导---------------------------------
function addGuideMatchGuide1( ... )
	require "script/guide/NewGuide"
	NewGuide.guideClass  = ksGuideContest
	BTUtil:setGuideState(true)
	require "script/guide/MatchGuide"
    if(NewGuide.guideClass ==  ksGuideContest and MatchGuide.stepNum == 0) then
       	require "script/ui/main/MenuLayer"
        local matchGuidButton = MenuLayer.getMenuItemNode(4)
        local touchRect   = getSpriteScreenRect(matchGuidButton)
        MatchGuide.show(1, touchRect)
    end
end
---------------------end-------------------------------------
--]==]

-- 铁匠铺引导第一步
---[==[铁匠铺 第一步
---------------------新手引导---------------------------------
function addGuideEquipGuide1( ... )
	require "script/guide/NewGuide"
	NewGuide.guideClass  = ksGuideSmithy
	require "script/guide/EquipGuide"
    if(NewGuide.guideClass ==  ksGuideSmithy and EquipGuide.stepNum == 0) then
		BTUtil:setGuideState(true)
		require "script/guide/EquipGuide"
       	require "script/ui/main/MenuLayer"
     	local equipButton = MenuLayer.getMenuItemNode(2)
        local touchRect   = getSpriteScreenRect(equipButton)
        EquipGuide.show(1, touchRect)
    end
end
---------------------end-------------------------------------
--]==]

--[[
	@des: 		武将进阶新手引导
]]
function addGeneralUpgradeGuide( ... )
	require "script/guide/NewGuide"
	NewGuide.guideClass  = ksGuideGeneralUpgrade
	require "script/guide/GeneralUpgradeGuide"
    if(NewGuide.guideClass ==  ksGuideGeneralUpgrade and GeneralUpgradeGuide.stepNum == 0) then
		BTUtil:setGuideState(true)
       	require "script/ui/main/MainBaseLayer"
     	local equipButton = MainBaseLayer.getMainMenuItem(MainBaseLayer._ksTagHero)
        local touchRect   = getSpriteScreenRect(equipButton)
        GeneralUpgradeGuide.show(1,touchRect)
    end
end

--[[
	@des:	炼化炉引导开启
]]
function addResolveGuide( ... )
	addGuideResolveGuide1()
end

---[==[炼化炉 第一步
---------------------新手引导---------------------------------
function addGuideResolveGuide1( ... )
	require "script/guide/NewGuide"
	NewGuide.guideClass  = ksGuideResolve
	require "script/guide/ResolveGuide"
    if(NewGuide.guideClass ==  ksGuideResolve and ResolveGuide.stepNum == 0) then
       	require "script/ui/main/MainBaseLayer"
	    local resolveButton = MainBaseLayer.getMainMenuItem(MainBaseLayer._ksTagRecycle)
        local touchRect   = getSpriteScreenRect(resolveButton)
        ResolveGuide.show(1, touchRect)
    end
end
---------------------end-------------------------------------
--]==]

---[==[天命 第一步
---------------------新手引导---------------------------------
function addGuideDestinyGuide1( ... )
	require "script/guide/NewGuide"
	NewGuide.guideClass  = ksGuideDestiny
	require "script/guide/DestinyGuide"
    if(NewGuide.guideClass ==  ksGuideDestiny and DestinyGuide.stepNum == 0) then
       	require "script/ui/main/MainBaseLayer"
        local destinyButton = MainBaseLayer.getMainMenuItem(MainBaseLayer._ksTagDestiny)
        local touchRect   = getSpriteScreenRect(destinyButton)
        DestinyGuide.show(1, touchRect)
    end
end
---------------------end-------------------------------------
--]==]

---[==[武将列传 第一步
---------------------新手引导---------------------------------
function addGuideLieZhuanGuide1( ... )
	require "script/guide/NewGuide"
	NewGuide.guideClass  = ksGuideHeroBiography
	require "script/guide/LieZhuanGuide"
    if(NewGuide.guideClass ==  ksGuideHeroBiography and LieZhuanGuide.stepNum == 0) then
        require "script/ui/main/MainBaseLayer"
        local starHeroButton = MainBaseLayer.getMainMenuItem(MainBaseLayer._ksTagFair)
        local touchRect   = getSpriteScreenRect(starHeroButton)
        LieZhuanGuide.show(1, touchRect)
    end
end
---------------------end-------------------------------------
--]==]

---[==[寻龙 第一步
---------------------新手引导---------------------------------
function addGuideXunLongGuide1( ... )
	require "script/guide/NewGuide"
	NewGuide.guideClass  = ksGuideFindDragon
	require "script/guide/XunLongGuide"
    if(NewGuide.guideClass ==  ksGuideFindDragon and XunLongGuide.stepNum == 0) then
       	require "script/ui/main/MenuLayer"
        local button = MenuLayer.getMenuItemNode(4)
        local touchRect   = getSpriteScreenRect(button)
        XunLongGuide.show(1, touchRect)
    end
end
---------------------end-------------------------------------
--]==]

function addGuideOlympic( ... )
	NewGuide.guideClass = ksGuideOlympic
	BTUtil:setGuideState(true)
end

---[==[主角换技能 第一步
---------------------新手引导---------------------------------
function addGuideChangeSkillGuide1( ... )
	require "script/guide/NewGuide"
	NewGuide.guideClass  = ksGuideChangeSkill
	require "script/guide/ChangeSkillGuide"
    if(NewGuide.guideClass ==  ksGuideChangeSkill and ChangeSkillGuide.stepNum == 0) then
    	BTUtil:setGuideState(true)
       	require "script/ui/main/MainBaseLayer"
        local button = MainBaseLayer.getMainMenuItem(MainBaseLayer._ksTagDestiny)
        local touchRect   = getSpriteScreenRect(button)
        ChangeSkillGuide.show(1, touchRect)
    end
end
---------------------end-------------------------------------
--]==]

---[==[武将进化 第一步
---------------------新手引导---------------------------------
function addGuideHeroDevelopGuide1( ... )
	require "script/guide/NewGuide"
	NewGuide.guideClass  = ksGuideHeroDevelop
	require "script/guide/HeroDevelopGuide"
    if(NewGuide.guideClass ==  ksGuideHeroDevelop and HeroDevelopGuide.stepNum == 0) then
       	require "script/ui/main/MainBaseLayer"
     	local button = MainBaseLayer.getMainMenuItem(MainBaseLayer._ksTagHero)
        local touchRect   = getSpriteScreenRect(button)
        HeroDevelopGuide.show(1, touchRect)
    end
end
---------------------end-------------------------------------
--]==]

---[==[阵法 第一步
---------------------新手引导---------------------------------
function addGuideWarcraftGuide1( ... )
	require "script/guide/NewGuide"
	NewGuide.guideClass  = ksGuideWarcraft
	require "script/guide/WarcraftGuide"
    if(NewGuide.guideClass ==  ksGuideWarcraft and WarcraftGuide.stepNum == 0) then
    	BTUtil:setGuideState(true)
       	require "script/ui/main/MenuLayer"
        local button = MenuLayer.getMenuItemNode(2)
        local touchRect   = getSpriteScreenRect(button)
        WarcraftGuide.show(1, touchRect)
    end
end
---------------------end-------------------------------------
--]==]
