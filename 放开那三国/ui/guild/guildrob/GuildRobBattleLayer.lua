-- FileName: GuildRobBattleLayer.lua
-- Author: lichenyang
-- Date: 14-11-5
-- Purpose: 军团抢粮pvp战
-- @module GuildRobBattleLayer

module("GuildRobBattleLayer",package.seeall)
require "script/ui/guild/guildrob/GuildRobBattleData"
require "script/ui/guild/guildrob/GuildRobBattleService"
require "script/ui/guild/guildrob/GuildAfterRobBattleLayer"
require "script/ui/guild/guildrob/GuildRobRankList"
require "script/utils/TimeUtil"
require "script/utils/BaseUI"
require "script/ui/guild/guildRobList/GuildRobData"
require "script/ui/guild/GuildDataCache"
require "script/utils/extern"
------------------------------[[ 模块常量 ]]------------------------------
local kPlayerBloodTag        = 101
local kPlayerNameTag         = 102

local kKillType              = 1 	--击杀获得
local kRobTyp                = 2 	--抢夺获

local kStreakWin             = 101	--连续击杀
local kStreakLose            = 102	--连续击杀被终结

local kRomveTouchDown        = 103 	-- 达阵离场
local kRomveLose             = 104 	-- 死亡离场
local kRomveLeave            = 105 	-- 主动离场或者断线离场

local kButtonAttackerType    = 0 	--显示攻击方按钮
local kButtondefenderType    = 1	--显示防御方按钮

local kBranMenuTag           = 100
local kBranAttackerButtonTag = 101
local kBranDefenderButtonTag = 102
local kBranAttackerFlagTag   = 103
local kBranDefenderFlagTag   = 104

local kDirectUp				 = 100
local kDirectDown			 = 101

local kMaxZ  			     = 10000000 

--定义三条路的路径，次路线以攻防路线为准，守方逆推即可
-- x 方向偏移量 y 方向偏移量
local ROAD_DATA = {
	{
		{dir = "y", value = 190},
		{dir = "x", value = -80},
		{dir = "y", value = 305},
		{dir = "x", value = 80},
		{dir = "y", value = 48},
	},
	{
		{dir = "y", value = 541},
	},
	{
		{dir = "y", value = 190},
		{dir = "x", value = 80},
		{dir = "y", value = 305},
		{dir = "x", value = -80},
		{dir = "y", value = 48},
	},
}

local BRON_POS = {
	{x =110, y=20},{x=30, y=20},{x=30, y=20},
	{x =110, y=530},{x=30, y=530},{x=30, y=530},
}

------------------------------[[ 模块变量 ]]------------------------------
local _bgLayer                = nil
local _layerSize              = nil
local _touchPriority          = nil
local _zOrder                 = nil
local _bgSprite               = nil
local _leftRoad               = nil
local _centerRoad             = nil
local _rightRoad              = nil
local _joinButtonArray        = nil
local _playerArray            = nil
local _failedPlayerArray      = nil
local _roadArray              = nil
local _timeLabel              = nil
local _passTime               = 0
local _readyTime              = 0
local _updateTimeScheduler    = nil
local _timer                  = 0
local _tranferNumLabelArray   = {}
local _losePlayer             = {}						--已经死亡的玩家对象
local _branContainer          = {}
local _branPlayer             = {}
local _defendGrainNumLabel    = nil
local _defendMeritNumLabel    = nil
local _attackerGrainNumLabel  = nil
local _attackerMeritNumLabel  = nil
local _defendGuiildNumLabel   = nil
local _defendRobGrainNumLabel = nil
local _attackerGuiildNumLabel = nil
local _goBattleRoadTime       = 0
local _joinCDTime             = 0
local _occupyTime 			  = {}						--蹲点粮草倒计时
local _tranferEffects 		  = {}						--出战按钮数组
local _tranferBgArray		  = {}						--传送阵人数
local _removeCdGoldLabel	  = nil
local _nowDefenderZorder	  = 0
local _nowAttackerZorder	  = 0
local _isJoinButtonShow		  = nil
local _moralLabel			  = nil
local _readyTimePass 		  = nil
local _isBattleOver 		  = nil						--是否战斗结束
local _isJionBattle 		  = nil 					--玩家是否已经加入战场
local _isAutoEnter			  = nil						--玩家是否开启自动抢粮模式
local _isJoining 			  = nil						--正在加入战斗
function init( ... )
	_bgLayer                  = nil
	_layerSize                = nil
	_touchPriority            = nil
	_zOrder                   = nil
	_bgSprite                 = nil
	_leftRoad                 = nil
	_centerRoad               = nil
	_rightRoad                = nil
	_joinButtonArray          = {}
	_failedPlayerArray        = {}
	_playerArray              = {}
	_roadArray                = {}
	_defendGuiildNumLabel     = nil
	_defendRobGrainNumLabel   = nil
	_defendAddGrainNumLabel   = nil
	_attackerGuiildNumLabel   = nil
	_attackerAddGrainNumLabel = nil
	_attackerAddGrainNumLabel = nil
	_timeLabel                = nil
	_passTime                 = 0
	_timer                    = 0
	_readyTime                = 0
	_tranferNumLabelArray     = {}
	_updateTimeScheduler      = 0
	_container                = {}
	_branPlayer               = {}
	_defendGrainNumLabel      = nil
	_defendMeritNumLabel      = nil
	_attackerGrainNumLabel    = nil
	_attackerMeritNumLabel    = nil
	_goBattleRoadTime         = 0
	_joinCDTime               = 0
	_occupyTime 			  = {}
	_tranferEffects 		  = {}
	_tranferBgArray		 	  = {}
	_losePlayer               = {}						--已经死亡的玩家对象
	_removeCdGoldLabel	  	  = nil
	_nowDefenderZorder		  = kMaxZ
	_nowAttackerZorder	  	  = kMaxZ
	_isJoinButtonShow		  = true
	_moralLabel				  = nil
	_readyTimePass 		  	  = 0
	_isBattleOver 		  	  = nil						--是否战斗结束
	_isJionBattle 		  	  = nil 
	_isJoining 				  = nil
end
-----------------------------------[[ 节点事件 ]]------------------------------
function registerNodeEvent( ... )
	_bgLayer:registerScriptHandler(function ( nodeType )
		if (event == "enter") then
			GuildDataCache.setIsInGuildFunc(true)
		elseif(nodeType == "exit") then
			_bgLayer = nil
			GuildDataCache.setIsInGuildFunc(false)
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimeScheduler)
		end
	end)
end

-------------------------------[[ ui 创建方法 ]]---------------------------
function show(  p_touchPriority, p_zOrder )
	local robInfo = GuildRobData.getMyGuildRobInfo()
	GuildRobBattleService.enter(robInfo.robId, function ( ... )
		local layer = createLayer()
		MainScene.changeLayer(layer, "GuildRobBattleLayer")
	end)
	
end

function createLayer( p_touchPriority,  p_zOrder)
	init()
	_touchPriority 	= p_touchPriority or -400
	_zOrder			= p_zOrder or 1
	_bgLayer 		= CCLayer:create()
	_layerSize  	= CCDirector:sharedDirector():getWinSize()
	MainScene.setMainSceneViewsVisible(false, false, false)
	GuildRobBattleData.init()

	--背景
	_bgSprite = CCSprite:create("images/guild_rob/bg.jpg")
	_bgSprite:setPosition(ccps(0.5, 0.1))
	_bgSprite:setAnchorPoint(ccp(0.5, 0.1))
	_bgLayer:addChild(_bgSprite)
	_bgSprite:setScale(g_fBgScaleRatio)
	--标题
	local titleSprite = CCSprite:create("images/guild_rob/title_word.png")
	titleSprite:setPosition(ccps(0, 1))
	titleSprite:setAnchorPoint(ccp(0, 1))
	_bgLayer:addChild(titleSprite)

	--播放背景音乐
	AudioUtil.playBgm("audio/bgm/music12.mp3")

	--数据
	local requestCallback = function ( ... )
		--拉入场数据
		GuildRobBattleService.getRankByKill(function ( ... )
			--拉取排行榜数据
			GuildRobRankList.show(-400, 10, _bgLayer)

			createBattlePlace()
			createButtons()
			createGuildInfoPanel()
			showReadLayer()
			--刷新第二条路的显示
			showSecondRoad()
			_updateTimeScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(refreshTimer, 0.01, false)
			schedule(_bgLayer, updateLabels, 1)
			
			GuildRobBattleService.registerPushReckon(reckonPushCallback)				--结算推送推送
			GuildRobBattleService.registerPushRefresh(refreshPushCallback)				--数据刷新回调
			GuildRobBattleService.registerPushFightWin(fightWinPushCallback)			--玩家战斗胜利推送
			GuildRobBattleService.registerPushFightLose(fightLosePushCallback)			--玩家战败推送
			GuildRobBattleService.registerPushTouchDown(touchDownPushCallback)			--达阵事件推送
			GuildRobBattleService.registerPushBattleEnd(battleEndPushCallback)			--军团pvp战斗结束推送
			GuildRobBattleService.registerPushFightResult(fightResultPushCallback)
			--检测自动加入
			checkAutoJoin()
		end)
	end
	LoginScene.addObserverForNetBroken("guild_rob",networkBreakCallback)	--网络断开回调
	if LoginScene.addObserverForReconnect then
		LoginScene.addObserverForReconnect("guild_rob",networkReconnectCallback)
	end
	GuildRobBattleService.getEnterInfo(requestCallback)
	return _bgLayer
end


function showReadLayer()
	_readyTime = GuildRobBattleData.getReadyTime() - 1
	if(_readyTime <= 0) then
		return
	end

	local alertBg = CCScale9Sprite:create("images/tip/animate_tip_bg.png")
	alertBg:setContentSize(CCSizeMake(340, 105))
	alertBg:setPosition(ccps(0.5, 0.5))
	alertBg:setAnchorPoint(ccp(0.5, 0.5))
	_bgLayer:addChild(alertBg, 1000)
	alertBg:setScale(MainScene.elementScale)

	local readTimeTitle = CCRenderLabel:create( GetLocalizeStringBy("lcyx_114") , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	readTimeTitle:setColor(ccc3(0xff, 0xf6, 0x00))
	readTimeTitle:setAnchorPoint(ccp(0.5, 1))
	readTimeTitle:setPosition(ccpsprite(0.5, 0.9, alertBg))
	alertBg:addChild(readTimeTitle)

	local readTimeLabel = CCRenderLabel:create(TimeUtil.getTimeString(_readyTime), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	readTimeLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	readTimeLabel:setAnchorPoint(ccp(0.5, 0))
	readTimeLabel:setPosition(ccpsprite(0.5, 0.1, alertBg))
	alertBg:addChild(readTimeLabel)
	-- 准备时间刷新
	schedule(alertBg, function ( ... )
		_readyTime = _readyTime -1
		readTimeLabel:setString(TimeUtil.getTimeString(_readyTime))
		if(_readyTime < 1) then
			alertBg:removeFromParentAndCleanup(true)
			alertBg = nil
			playerBattleStartEffect()
		end
		print("_readyTime", _readyTime)
	end, 1)
end

function createBattlePlace( ... )

	--抢夺时间
	local timeSprite = CCSprite:create("images/guild_rob/rob_time.png")
	timeSprite:setPosition(ccps(0.43, 0.98))
	timeSprite:setAnchorPoint(ccp(0, 1))
	_bgLayer:addChild(timeSprite)
	timeSprite:setScale(MainScene.elementScale)

	_passTime = GuildRobBattleData.getPastTime()
	_timeLabel = CCRenderLabel:create( TimeUtil.getTimeString(_passTime) , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_timeLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	_timeLabel:setAnchorPoint(ccp(0.5, 0.5))
	
	local labelNode = CCSprite:create()
	labelNode:setContentSize(_timeLabel:getContentSize())
	labelNode:setAnchorPoint(ccp(0, 0.5))
	labelNode:setPosition(ccp(timeSprite:getPositionX()+timeSprite:getContentSize().width*MainScene.elementScale + 10*MainScene.elementScale, timeSprite:getPositionY() - timeSprite:getContentSize().height*MainScene.elementScale/2))
	labelNode:addChild(_timeLabel)
	_timeLabel:setPosition(ccpsprite(0.5, 0.5, labelNode))
	_bgLayer:addChild(labelNode)
	labelNode:setScale(MainScene.elementScale)
	--抢夺时间刷新
	schedule(_bgSprite, function ( ... )
		-- _passTime = _passTime - 1
		if _passTime <0 then
			_passTime = 0
		end
		_timeLabel:setString(TimeUtil.getTimeString(_passTime))
	end, 1)

	--创建路线
	_leftRoad = CCSprite:create("images/guild_rob/left_road.png")
	_leftRoad:setPosition(ccpsprite(0.25, 0.43, _bgSprite))
	_leftRoad:setAnchorPoint(ccp(0.5, 0.5))
	_bgSprite:addChild(_leftRoad)
	table.insert(_roadArray, _leftRoad)

	_centerRoad = CCSprite:create("images/guild_rob/center_road.png")
	_centerRoad:setPosition(ccpsprite(0.5, 0.43, _bgSprite))
	_centerRoad:setAnchorPoint(ccp(0.5, 0.5))
	_bgSprite:addChild(_centerRoad)
	table.insert(_roadArray, _centerRoad)

	_rightRoad = CCSprite:create("images/guild_rob/right_road.png")
	_rightRoad:setPosition(ccpsprite(0.75, 0.43, _bgSprite))
	_rightRoad:setAnchorPoint(ccp(0.5, 0.5))
	_bgSprite:addChild(_rightRoad)
	table.insert(_roadArray, _rightRoad)

	--出战按钮
	local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0,0))
	menu:setTouchPriority(_touchPriority - 20)
	_bgSprite:addChild(menu, 2)

	--攻防是红方，守方是蓝方
	--攻防
	local pst = {
		ccpsprite(0.3, 0.12, _bgSprite),ccpsprite(0.5, 0.12, _bgSprite),ccpsprite(0.7, 0.12, _bgSprite),
		ccpsprite(0.3, 0.75, _bgSprite),ccpsprite(0.5, 0.75, _bgSprite),ccpsprite(0.7, 0.75, _bgSprite),
	}
	for i=1,3 do
		-- 加入按钮
		local redLeftJoinButton = CCMenuItemImage:create("images/guild_rob/attack_btn_n.png","images/guild_rob/attack_btn_h.png")
		redLeftJoinButton:setAnchorPoint(ccp(0.5, 0))
		redLeftJoinButton:setPosition(pst[i])
		redLeftJoinButton:registerScriptTapHandler(joinButtonCallback)
		menu:addChild(redLeftJoinButton,1, i)
		_joinButtonArray[i] = redLeftJoinButton
		if not GuildRobBattleData.isUserAttackerGuild() then
			redLeftJoinButton:setVisible(false)
		end

		local btnEffect = CCLayerSprite:layerSpriteWithName(CCString:create("images/guild_rob/effect/jinggong/jinggong"), -1,CCString:create(""))
		btnEffect:setPosition(ccpsprite(0.5, 0.5, redLeftJoinButton))
		redLeftJoinButton:addChild(btnEffect, 100)

		--进攻方有传送阵
		local tranformSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/guild_rob/effect/csm/csm"), -1,CCString:create(""))
		tranformSprite:setAnchorPoint(ccp(0.5, 0))
		tranformSprite:setPosition(pst[i].x, pst[i].y - 37)
		_bgSprite:addChild(tranformSprite)
		_tranferEffects[i] = tranformSprite

		--传送阵人数
		local roleNumBg = CCSprite:create("images/guild_rob/role_num_bg.png")
		roleNumBg:setAnchorPoint(ccp(0.5, 0))
		roleNumBg:setPosition(pst[i].x, pst[i].y - 100)
		_bgSprite:addChild(roleNumBg)
		_tranferBgArray[i] = roleNumBg

		local tranferNum = GuildRobBattleData.getTranferPlayerNum(i)
		local tranferNumLabel = CCRenderLabel:create( GetLocalizeStringBy("lcyx_115", tranferNum), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		tranferNumLabel:setColor(ccc3(0x00, 0xff, 0x18))
		tranferNumLabel:setAnchorPoint(ccp(0.5, 0.5))
		tranferNumLabel:setPosition(ccpsprite(0.5, 0.5, roleNumBg))
		roleNumBg:addChild(tranferNumLabel)
		_tranferNumLabelArray[i] = tranferNumLabel
	end
	--守方
	for i=4,6 do
		local rightLeftJoinButton = CCMenuItemImage:create("images/guild_rob/defend_btn_n.png","images/guild_rob/defend_btn_h.png")
		rightLeftJoinButton:setAnchorPoint(ccp(0.5, 1))
		rightLeftJoinButton:setPosition(pst[i])
		rightLeftJoinButton:registerScriptTapHandler(joinButtonCallback)
		menu:addChild(rightLeftJoinButton, 1, i)
		_joinButtonArray[i] = rightLeftJoinButton
		if GuildRobBattleData.isUserAttackerGuild() then
			rightLeftJoinButton:setVisible(false)
		end

		local btnEffect = CCLayerSprite:layerSpriteWithName(CCString:create("images/guild_rob/effect/fangshou/fangshou"), -1,CCString:create(""))
		btnEffect:setPosition(ccpsprite(0.5, 0.5, rightLeftJoinButton))
		rightLeftJoinButton:addChild(btnEffect,10)

		--传送阵人数
		local roleNumBg = CCSprite:create("images/guild_rob/role_num_bg.png")
		roleNumBg:setAnchorPoint(ccp(0.5, 0))
		roleNumBg:setPosition(pst[i].x, pst[i].y + 120)
		_bgSprite:addChild(roleNumBg)
		_tranferBgArray[i] = roleNumBg

		local tranferNum = GuildRobBattleData.getTranferPlayerNum(i)
		local tranferNumLabel = CCRenderLabel:create( GetLocalizeStringBy("lcyx_116", tranferNum), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		tranferNumLabel:setColor(ccc3(0x00, 0xff, 0x18))
		tranferNumLabel:setAnchorPoint(ccp(0.5, 0.5))
		tranferNumLabel:setPosition(ccpsprite(0.5, 0.5, roleNumBg))
		roleNumBg:addChild(tranferNumLabel)
		_tranferNumLabelArray[i] = tranferNumLabel
	end
end

function createButtons( ... )
	local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0,0))
	menu:setTouchPriority(_touchPriority - 20)
	_bgLayer:addChild(menu)

	--
	--------------[[ 关闭按钮 ]]--------------
	local closeButton = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeButton:setAnchorPoint(ccp(1, 0.5))
	closeButton:setPosition(ccps(1, 0.96))
	closeButton:registerScriptTapHandler(closeCallback)
	menu:addChild(closeButton)
	closeButton:setScale(MainScene.elementScale)

	--------------[[ 阵型按钮 ]]--------------
	if(DataCache.getSwitchNodeState(ksSwitchWarcraft, false) == true )then
		local deployButton = CCMenuItemImage:create("images/copy/array_n.png","images/copy/array_h.png")
		deployButton:setAnchorPoint(ccp(1, 0.5))
		deployButton:setPosition(ccps(1, 0.85))
		deployButton:registerScriptTapHandler(deployButtonCallback)
		menu:addChild(deployButton)
		deployButton:setScale(MainScene.elementScale)
	else
		local deployButton = CCMenuItemImage:create("images/copy/arraybu_n.png","images/copy/arraybu_h.png")
		deployButton:setAnchorPoint(ccp(1, 0.5))
		deployButton:setPosition(ccps(1, 0.85))
		deployButton:registerScriptTapHandler(deployButtonCallback)
		menu:addChild(deployButton)
		deployButton:setScale(MainScene.elementScale)
	end

	--------------[[ 战报按钮 ]]--------------
	local reportButton = CCMenuItemImage:create("images/guild_rob/report_btn_n.png","images/guild_rob/report_btn_h.png")
	reportButton:setAnchorPoint(ccp(0, 0.5))
	reportButton:setPosition(ccps(0, 0.27))
	reportButton:registerScriptTapHandler(reportButtonCallback)
	menu:addChild(reportButton)
	reportButton:setScale(MainScene.elementScale)

	--------------[[ 清楚cd按钮 ]]--------------
	_joinCDTime =GuildRobBattleData.getCanJoinTime() - TimeUtil.getSvrTimeByOffset(0)
	local removeJoinCd = CCMenuItemImage:create("images/guild_rob/joincd_btn_n.png","images/guild_rob/joincd_btn_h.png")
	removeJoinCd:setAnchorPoint(ccp(1, 0.5))
	removeJoinCd:setPosition(ccps(1, 0.28))
	removeJoinCd:registerScriptTapHandler(removeJoinCdCallback)
	menu:addChild(removeJoinCd)
	removeJoinCd:setScale(MainScene.elementScale)

	_removeCdGoldLabel = CCRenderLabel:create(GuildRobBattleData.getRemoveCDCost() .. "", g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_removeCdGoldLabel:setColor(ccc3(0x00, 0xff, 0x18))
	_removeCdGoldLabel:setAnchorPoint(ccp(0.35, 0.5))
	_removeCdGoldLabel:setPosition(ccpsprite(0.3, -0.18, removeJoinCd))
	removeJoinCd:addChild(_removeCdGoldLabel)

	local cdGoldSprite = CCSprite:create("images/common/gold.png")
	cdGoldSprite:setAnchorPoint(ccp(0.5, 0.5))
	cdGoldSprite:setPosition(ccpsprite(0.6, -0.18, removeJoinCd))
	removeJoinCd:addChild(cdGoldSprite)

	--cdTime
	local cdTimeLabel = CCRenderLabel:create( TimeUtil.getTimeHHSSByString(_joinCDTime), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	cdTimeLabel:setColor(ccc3(0x00, 0xff, 0x18))
	cdTimeLabel:setAnchorPoint(ccp(0.5, 0.5))
	cdTimeLabel:setPosition(ccpsprite(0.5, 0.3, removeJoinCd))
	removeJoinCd:addChild(cdTimeLabel)

	if(tonumber(_joinCDTime) <= 0) then
		cdTimeLabel:setVisible(false)
		_removeCdGoldLabel:setVisible(true)
	end
	schedule(cdTimeLabel, function ( ... )
		_joinCDTime = _joinCDTime - 1
		if(_joinCDTime <= 0) then
			_joinCDTime = 0
			cdTimeLabel:setVisible(false)
			checkAutoJoin()
		else
			cdTimeLabel:setVisible(true)
			cdTimeLabel:setString(TimeUtil.getTimeHHSSByString(_joinCDTime))
		end
	end, 1)

	--------------[[ 说明按钮 ]]--------------
	local explanationButton = CCMenuItemImage:create("images/recycle/btn/btn_explanation_h.png", "images/recycle/btn/btn_explanation_n.png")
	explanationButton:registerScriptTapHandler(explanationButtonCallback)
	explanationButton:setAnchorPoint(ccp(1, 0.5))
	explanationButton:setPosition(ccps(0.96, 0.73))
	menu:addChild(explanationButton)
	explanationButton:setScale(MainScene.elementScale)

	--士气相关
	local moralSprite = CCSprite:create("images/guild_rob/moral.png")
	moralSprite:setAnchorPoint(ccp(0, 0.5))
	moralSprite:setPosition(ccps(0, 0.2))
	_bgLayer:addChild(moralSprite)
	moralSprite:setScale(MainScene.elementScale)

	_moralLabel = CCRenderLabel:create(GetLocalizeStringBy("lcyx_117") .. GuildRobBattleData.getMorale() .. "/" .. GuildRobBattleData.getMaxMoral(), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_moralLabel:setColor(ccc3(0x00, 0xff, 0x18))
	_moralLabel:setAnchorPoint(ccp(0, 0.5))
	_moralLabel:setPosition(ccpsprite(0.01, -0.18, moralSprite))
	moralSprite:addChild(_moralLabel)

	--[[ 自动出战选项 ]]--

	local checkBgSprite = CCScale9Sprite:create("images/guild_rob/info_panel.png")
	checkBgSprite:setContentSize(CCSizeMake(100, 90))
	checkBgSprite:setAnchorPoint(ccp(1, 0))
	checkBgSprite:setPosition(ccps(1,0))
	_bgLayer:addChild(checkBgSprite)
	checkBgSprite:setScale(MainScene.elementScale)

	local aotoLabel = CCRenderLabel:create(GetLocalizeStringBy("lcyx_153"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	aotoLabel:setColor(ccc3(0x00, 0xff, 0x18))
	aotoLabel:setAnchorPoint(ccp(0.5, 0))
	aotoLabel:setPosition(ccpsprite(0.5, 0.05, checkBgSprite))
	checkBgSprite:addChild(aotoLabel)

	local checkMenu = CCMenu:create()
	checkMenu:setAnchorPoint(ccp(0, 0))
	checkMenu:setPosition(ccp(0,0))
	checkMenu:setTouchPriority(_touchPriority - 20)
	checkBgSprite:addChild(checkMenu)

	local checkBg 		= CCMenuItemImage:create("images/common/check_bg.png","images/common/check_bg.png")
	local checkBtnCheck = CCMenuItemImage:create("images/common/check_selected.png","images/common/check_selected.png")
	checkBg:setAnchorPoint(ccp(0.5, 0.5))
	checkBtnCheck:setAnchorPoint(ccp(0.5, 0.5))
	local aotoEnterButton = CCMenuItemToggle:create(checkBg)
	aotoEnterButton:addSubItem(checkBtnCheck)
	aotoEnterButton:setAnchorPoint(ccp(0.5, 0.5))
	aotoEnterButton:setPosition(ccpsprite(0.5, 0.7, checkBgSprite))
	aotoEnterButton:registerScriptTapHandler(aotoEnterButtonCallback)
	checkMenu:addChild(aotoEnterButton)

	if _isAutoEnter then
		aotoEnterButton:setSelectedIndex(1)
	else
		aotoEnterButton:setSelectedIndex(0)
	end

	--弹幕
	require "script/ui/bulletLayer/BulletUtil"
	require "script/ui/bulletLayer/BulletDef"
	local bulletButton = BulletUtil.createItem(BulletType.SCREEN_TYPE_ROBL)
	bulletButton:setAnchorPoint(ccp(1, 0.5))
	bulletButton:setPosition(ccps(1, 0.15))
	menu:addChild(bulletButton)
	bulletButton:setScale(MainScene.elementScale)
end

--[[
	@des:创建双方军团信息面板
--]]
function createGuildInfoPanel( ... )
	--创建守方信息
	local defenderInfo = GuildRobBattleData.getDefenderGuildInfo()
	local defendPanel = CCScale9Sprite:create("images/guild_rob/info_panel.png")
	defendPanel:setContentSize(CCSizeMake(138, 126))
	defendPanel:setAnchorPoint(ccp(0, 1))
	defendPanel:setPosition(ccps(0,0.92))
	_bgLayer:addChild(defendPanel)
	defendPanel:setScale(MainScene.elementScale)

	local defendIcon = CCSprite:create("images/readybattle/defPoint.png")
	defendIcon:setAnchorPoint(ccp(0, 1))
	defendIcon:setPosition(ccpsprite(0, 1, defendPanel))
	defendPanel:addChild(defendIcon)
	defendIcon:setScale(0.5)

	local defendName = CCRenderLabel:create( defenderInfo.guildName, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	defendName:setColor(ccc3(0xff, 0xf6, 0x00))
	defendName:setAnchorPoint(ccp(0, 0.25))
	defendName:setPosition(ccpsprite(0.5, 0.85, defendPanel))
	defendPanel:addChild(defendName)

	--参战人数
	local hw,oh = 0.15,0.56
	local defendGuiildNumTitle = CCRenderLabel:create( GetLocalizeStringBy("lcyx_118"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	defendGuiildNumTitle:setColor(ccc3(0xff, 0xff, 0xff))
	defendGuiildNumTitle:setAnchorPoint(ccp(0, 0.5))
	defendGuiildNumTitle:setPosition(ccpsprite(0, oh, defendPanel))
	defendPanel:addChild(defendGuiildNumTitle)

	_defendGuiildNumLabel = CCRenderLabel:create( defenderInfo.inBattle.."/"..defenderInfo.guildNum, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_defendGuiildNumLabel:setColor(ccc3(0xff, 0xff, 0xff))
	_defendGuiildNumLabel:setAnchorPoint(ccp(0, 0.5))
	_defendGuiildNumLabel:setPosition(ccpsprite(0.62, oh, defendPanel))
	defendPanel:addChild(_defendGuiildNumLabel)

	--可抢粮草
	local defendRobGrainTitle = CCRenderLabel:create( GetLocalizeStringBy("lcyx_119"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	defendRobGrainTitle:setColor(ccc3(0xff, 0xff, 0x00))
	defendRobGrainTitle:setAnchorPoint(ccp(0, 0.5))
	defendRobGrainTitle:setPosition(ccpsprite(0, oh - hw*1, defendPanel))
	defendPanel:addChild(defendRobGrainTitle)

	_defendRobGrainNumLabel = CCRenderLabel:create( defenderInfo.robGrain, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_defendRobGrainNumLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	_defendRobGrainNumLabel:setAnchorPoint(ccp(0, 0.5))
	_defendRobGrainNumLabel:setPosition(ccpsprite(0.62, oh - hw*1, defendPanel))
	defendPanel:addChild(_defendRobGrainNumLabel)

	--获得功勋
	local defendMeritTitle = CCRenderLabel:create( GetLocalizeStringBy("lcyx_120"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	defendMeritTitle:setColor(ccc3(0xff, 0xff, 0x00))
	defendMeritTitle:setAnchorPoint(ccp(0, 0.5))
	defendMeritTitle:setPosition(ccpsprite(0, oh - hw*2, defendPanel))
	defendPanel:addChild(defendMeritTitle)

	_defendMeritNumLabel = CCRenderLabel:create( defenderInfo.merit, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_defendMeritNumLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	_defendMeritNumLabel:setAnchorPoint(ccp(0, 0.5))
	_defendMeritNumLabel:setPosition(ccpsprite(0.62, oh - hw*2, defendPanel))
	defendPanel:addChild(_defendMeritNumLabel)

	--创建攻防信息
	local attackerInfo = GuildRobBattleData.getAttackerGuildInfo()
	local attackerPanel = CCScale9Sprite:create("images/guild_rob/info_panel.png")
	attackerPanel:setContentSize(CCSizeMake(138, 126))
	attackerPanel:setAnchorPoint(ccp(0, 0))
	attackerPanel:setPosition(ccps(0,0))
	_bgLayer:addChild(attackerPanel)
	attackerPanel:setScale(MainScene.elementScale)

	local attackerIcon = CCSprite:create("images/readybattle/attPoint.png")
	attackerIcon:setAnchorPoint(ccp(0, 1))
	attackerIcon:setPosition(ccpsprite(0, 1, attackerPanel))
	attackerPanel:addChild(attackerIcon)
	attackerIcon:setScale(0.5)

	local attackerName = CCRenderLabel:create( attackerInfo.guildName, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	attackerName:setColor(ccc3(0xff, 0xf6, 0x00))
	attackerName:setAnchorPoint(ccp(0, 0.25))
	attackerName:setPosition(ccpsprite(0.5, 0.85, attackerPanel))
	attackerPanel:addChild(attackerName)

	--参战人数
	local attackerGuiildNumTitle = CCRenderLabel:create( GetLocalizeStringBy("lcyx_118"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	attackerGuiildNumTitle:setColor(ccc3(0xff, 0xff, 0xff))
	attackerGuiildNumTitle:setAnchorPoint(ccp(0, 0.5))
	attackerGuiildNumTitle:setPosition(ccpsprite(0, oh, attackerPanel))
	attackerPanel:addChild(attackerGuiildNumTitle)

	_attackerGuiildNumLabel = CCRenderLabel:create( attackerInfo.inBattle.."/"..attackerInfo.guildNum, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_attackerGuiildNumLabel:setColor(ccc3(0xff, 0xff, 0xff))
	_attackerGuiildNumLabel:setAnchorPoint(ccp(0, 0.5))
	_attackerGuiildNumLabel:setPosition(ccpsprite(0.62, oh, attackerPanel))
	attackerPanel:addChild(_attackerGuiildNumLabel)

	--抢到粮草
	local attackerAddGrainTitle = CCRenderLabel:create( GetLocalizeStringBy("lcyx_121"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	attackerAddGrainTitle:setColor(ccc3(0xff, 0xff, 0x00))
	attackerAddGrainTitle:setAnchorPoint(ccp(0, 0.5))
	attackerAddGrainTitle:setPosition(ccpsprite(0, oh - hw*1, attackerPanel))
	attackerPanel:addChild(attackerAddGrainTitle)

	_attackerGrainNumLabel = CCRenderLabel:create( attackerInfo.grain, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_attackerGrainNumLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	_attackerGrainNumLabel:setAnchorPoint(ccp(0, 0.5))
	_attackerGrainNumLabel:setPosition(ccpsprite(0.62, oh - hw*1, attackerPanel))
	attackerPanel:addChild(_attackerGrainNumLabel)

	--获得功勋
	local attackerMeritTitle = CCRenderLabel:create( GetLocalizeStringBy("lcyx_122"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	attackerMeritTitle:setColor(ccc3(0xff, 0xff, 0x00))
	attackerMeritTitle:setAnchorPoint(ccp(0, 0.5))
	attackerMeritTitle:setPosition(ccpsprite(0, oh - hw*2, attackerPanel))
	attackerPanel:addChild(attackerMeritTitle)

	_attackerMeritNumLabel = CCRenderLabel:create( attackerInfo.merit, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_attackerMeritNumLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	_attackerMeritNumLabel:setAnchorPoint(ccp(0, 0.5))
	_attackerMeritNumLabel:setPosition(ccpsprite(0.62, oh - hw*2, attackerPanel))
	attackerPanel:addChild(_attackerMeritNumLabel)

	if GuildRobBattleData.isUserAttackerGuild() then
		defendMeritTitle:setVisible(false)
		_defendMeritNumLabel:setVisible(false)
	else
		attackerAddGrainTitle:setVisible(false)
		attackerMeritTitle:setVisible(false)
		_attackerMeritNumLabel:setVisible(false)
		_attackerGrainNumLabel:setVisible(false)
	end
end
--[[
	@des: 添加出场cd 时间
--]]
function addJoinBattleCDTime( p_cdTimer, p_tranferId )

	local pst = {
		ccpsprite(0.3, 0.12, _bgSprite),ccpsprite(0.5, 0.12, _bgSprite),ccpsprite(0.7, 0.12, _bgSprite),
		ccpsprite(0.3, 0.75, _bgSprite),ccpsprite(0.5, 0.75, _bgSprite),ccpsprite(0.7, 0.75, _bgSprite),
	}

	local tranferId = p_tranferId + 1
	local pos = nil
	if(tranferId > 3) then
		pos = ccp(pst[tonumber(tranferId)].x, pst[tonumber(tranferId)].y - 40)
	else
		pos = ccp(pst[tonumber(tranferId)].x, pst[tonumber(tranferId)].y + 40)
	end

	_goBattleRoadTime = p_cdTimer - TimeUtil.getSvrTimeByOffset(1)
	local cdTitleLabel = CCRenderLabel:create( GetLocalizeStringBy("lcyx_123"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	cdTitleLabel:setColor(ccc3(0x00, 0xff, 0x18))

	local cdTimeLabel = CCRenderLabel:create(TimeUtil.getTimeString(_goBattleRoadTime), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	cdTimeLabel:setColor(ccc3(0x00, 0xff, 0x18))

	local cdInfoNode = BaseUI.createVerticalNode({cdTitleLabel,cdTimeLabel})
	cdInfoNode:setAnchorPoint(ccp(0.5, 0))
	cdInfoNode:setPosition(pos)
	_bgSprite:addChild(cdInfoNode)

	if(tonumber(_goBattleRoadTime) <= 0) then
		cdInfoNode:setVisible(false)
	end
	schedule(cdInfoNode, function ( ... )
		_goBattleRoadTime = _goBattleRoadTime  - 1
		if(_goBattleRoadTime <= 0) then
			_goBattleRoadTime = 0
			cdInfoNode:removeFromParentAndCleanup(true)
			cdInfoNode = nil
		else
			cdTimeLabel:setString(TimeUtil.getTimeString(_goBattleRoadTime))
			cdInfoNode:setVisible(true)
		end
	end, 1)
end

--------------------------[[  刷新定时器 ]] --------------------------------
--[[
	@des:刷新ui显示数据
--]]
function updateLabels( ... )
	_readyTimePass = _readyTimePass + 1
	_passTime = GuildRobBattleData.getPastTime()
	--刷新传送阵人数
	local fieldInfos = GuildRobBattleData.getRobBattleInfo().field
	for i=1,#fieldInfos.transfer do
		if _tranferNumLabelArray[i] == nil then
			break
		end
		local v = fieldInfos.transfer[i]
		if(i < 4) then
			_tranferNumLabelArray[i]:setString(GetLocalizeStringBy("lcyx_124",v))
		else
			_tranferNumLabelArray[i]:setString(GetLocalizeStringBy("lcyx_125",v))
		end
	end

	local isSet = false
	if _defendGuiildNumLabel and 
	   _defendRobGrainNumLabel and
	   -- _defendGrainNumLabel and
	   _defendMeritNumLabel and
	   _attackerGuiildNumLabel and
	   _attackerGrainNumLabel and
	   _moralLabel and
	   _attackerMeritNumLabel then
	   isSet = true
	end
	if isSet == false then
		return
	end
	--刷新己方玩家信息和对方玩家信息
	local defenderInfo = GuildRobBattleData.getDefenderGuildInfo()	--守方军团信息
	defenderInfo.robGrain = (tonumber(defenderInfo.robGrain) < 0 and 0) or defenderInfo.robGrain
	_defendGuiildNumLabel:setString(defenderInfo.inBattle.."/"..defenderInfo.guildNum)
	_defendRobGrainNumLabel:setString(defenderInfo.robGrain)
	-- _defendGrainNumLabel:setString(defenderInfo.grain .. "")
	_defendMeritNumLabel:setString(defenderInfo.merit .. "")
	--刷新攻防玩家信息
	local attackerInfo = GuildRobBattleData.getAttackerGuildInfo()
	_attackerGuiildNumLabel:setString(attackerInfo.inBattle.."/"..attackerInfo.guildNum)
	_attackerGrainNumLabel:setString(attackerInfo.grain .. "")
	_attackerMeritNumLabel:setString(attackerInfo.merit .. "")

	--更新士气
	_moralLabel:setString(GetLocalizeStringBy("lcyx_126") .. GuildRobBattleData.getMorale() .. "/" .. GuildRobBattleData.getMaxMoral())
end

--[[
	@de: 战斗玩家位置刷新定时器
--]]
function refreshTimer( p_timer )
	-- print("p_timer:",p_timer)
	_timer = p_timer
	local fieldInfos = GuildRobBattleData.getRobBattleInfo().field
	if table.isEmpty(fieldInfos) then
		return
	end 
	--刷新战场玩家数据
	local roadInfos  = fieldInfos.road
	for k,v in pairs(roadInfos) do
		if(v.transferId ~= nil) then
			local roadId = tonumber(v.transferId)%3 + 1
			updatePlayerInfo(roadId, v)
		end
	end

	--更新场上玩家
	for k,v in pairs(_playerArray) do
		updatePlayer(v.roadId, v.info)
	end
	
	--清除达阵玩家
	fieldInfos.touchdown = fieldInfos.touchdown or {}
	for k,v in pairs(fieldInfos.touchdown) do
		if(_playerArray[v]) then
			performWithDelay(_bgSprite, function ( ... )
				removePlayer(v, kRomveTouchDown)
				print("清除达阵玩家")
			end,1)
		end
	end
	fieldInfos.touchdown = {}

	--清除掉线玩家
	fieldInfos.leave = fieldInfos.leave or {}
	for k,v in pairs(fieldInfos.leave) do
		if(_playerArray[v]) then
			removePlayer(v, kRomveLeave)
			print("清除达阵玩家")
		end
	end
	fieldInfos.leave = {}

	--清除战败玩家
	for k,v in pairs(_failedPlayerArray) do
		if(_playerArray[v]) then
			removeByAction(v, kRomveLose)
			print("remove from _failedPlayerArray id=", v)
		end
	end
	_failedPlayerArray = {}
end
-----------------------------------[[ 信息刷新方法 ]] ---------------------------------------------
function updatePlayerInfo( p_roadId, p_playerInfo )
	--[[
		如果玩家没有在_playerArray 中则玩家不在屏幕上，那么就创建一个新的玩家出来，再把他添加到_playerArray里面，
		如果玩家已达阵，掉下，退出战场，那么就把这个玩家从屏幕上删除掉。
	]]--
	if(_playerArray[p_playerInfo.id] == nil and p_playerInfo.exit == nil) then
		--创建新玩家
		_nowDefenderZorder = _nowDefenderZorder - 1
		_nowAttackerZorder = _nowAttackerZorder + 1
		_playerArray[p_playerInfo.id] = createPlayer(p_playerInfo)
		_playerArray[p_playerInfo.id]:setPosition(BRON_POS[tonumber(p_playerInfo.transferId)%3 + 1].x, BRON_POS[tonumber(p_playerInfo.transferId)%3 + 1].y)
		_roadArray[tonumber(p_playerInfo.transferId)%3+1]:addChild(_playerArray[p_playerInfo.id], 0)
		
		_playerArray[p_playerInfo.id].roadX = p_playerInfo.roadX
		_playerArray[p_playerInfo.id].info = p_playerInfo
		_playerArray[p_playerInfo.id].roadId = p_roadId
		if(tonumber(p_playerInfo.transferId) > 2) then
			_playerArray[p_playerInfo.id].rTime = 1
			_roadArray[tonumber(p_playerInfo.transferId)%3+1]:reorderChild(_playerArray[p_playerInfo.id],_nowDefenderZorder)
		else
			_playerArray[p_playerInfo.id].rTime = -1
			_roadArray[tonumber(p_playerInfo.transferId)%3+1]:reorderChild(_playerArray[p_playerInfo.id],_nowAttackerZorder)
		end
	else
		if(_playerArray[p_playerInfo.id] ~= nil and _playerArray[p_playerInfo.id].isLose == nil) then
			_playerArray[p_playerInfo.id].info = p_playerInfo
		end
	end
end

--[[
	@des: 创建战场玩家
--]]
function createPlayer(p_playerInfo )
	local iconPath = 1
	-- p_playerInfo.tid = p_playerInfo.tid or 20105
	-- p_playerInfo.curHp = p_playerInfo.curHp or 50
	if(HeroModel.getSex(p_playerInfo.tid) == 1) then
		--男
		if tonumber(p_playerInfo.transferId) > 2 then
			--守方玩家
			iconPath =	"images/guild_rob/role/lcdh_a1/lcdh_a1"
		else
			--攻方玩家
			iconPath = "images/guild_rob/role/lcdh_a2/lcdh_a2"
		end
	else
		--女
		if tonumber(p_playerInfo.transferId) > 2 then
			--守方玩家
			iconPath = "images/guild_rob/role/lcdh_b2/lcdh_b2"
		else
			--攻方玩家
			iconPath = "images/guild_rob/role/lcdh_b1/lcdh_b1"
		end
	end
	--人物
	local playerSprite = nil
	playerSprite = CCLayerSprite:layerSpriteWithName(CCString:create(iconPath), -1,CCString:create(""))
	playerSprite:setContentSize(CCSizeMake(67, 200))
	playerSprite:setScale(0.6)
	--血量背景
	local bloodBg = CCSprite:create("images/guild_rob/blod_bg.png")
	bloodBg:setAnchorPoint(ccp(0.5, 0.5))
	bloodBg:setPosition(ccpsprite(0.5 , 0.85, playerSprite))
	playerSprite:addChild(bloodBg)

	--血量
	local bloodSprite = CCSprite:create("images/guild_rob/blod.png")
	bloodSprite:setPosition(ccpsprite(0 , 0.5, bloodBg))
	bloodSprite:setAnchorPoint(ccp(0, 0.5))
	bloodBg:addChild(bloodSprite, 1, kPlayerBloodTag)
    bloodSprite:setScaleX(tonumber(p_playerInfo.curHp)/tonumber(p_playerInfo.maxHp))
    playerSprite.blood = bloodSprite

    --名称
    local nameLabel = CCRenderLabel:create(p_playerInfo.name, g_sFontName, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(ccc3(0x00, 0xff, 0x18))
    nameLabel:setAnchorPoint(ccp(0.5, 0.5))
    nameLabel:setPosition(ccpsprite(0.5, 1, playerSprite))
    playerSprite:addChild(nameLabel, 1, kPlayerNameTag)
    return playerSprite
end

--[[
	@des: 更新单个玩家信息
--]]
function updatePlayer(p_roadId, p_playerInfo )

	local playerSprite = _playerArray[p_playerInfo.id]
	if playerSprite == nil then
		return
	end
	--更新位置
	local Lc = 0 	-- 前端路线总长度
	for k,v in pairs(ROAD_DATA[p_roadId]) do
		Lc = Lc + math.abs(v.value)
	end

	local Lh = GuildRobBattleData.getServerRoadLength(p_roadId)
	local Vh = tonumber(p_playerInfo.speed) * 1000
	local Ph = tonumber(playerSprite.roadX)

	--判断守方和攻方
	local roadPathData = ROAD_DATA[p_roadId]
	if(tonumber(p_playerInfo.transferId) < 3) then
		playerSprite.rTime = playerSprite.rTime + _timer
	else
		-- 守方反向行走
		playerSprite.rTime = playerSprite.rTime - _timer
	end

	local Vc = Lc/(Lh/Vh)
	local t = Ph/Vh + playerSprite.rTime
	local Pc = Vc * t
	local stX = tonumber(p_playerInfo.stopX)/Vh * Vc  -- 前端stopx


	local Sx,Sy,sign = 0,0,1 --分别为出生点到玩家位置x,y的位移量 ,sign是位移方向
	if(Pc < 0) then
		playerSprite:setVisible(false)
	else
		playerSprite:setVisible(true)
	end
	--计算位移量
	local lastW = Pc  -- 最后一段位移
	for i=1, #roadPathData do
		local v = roadPathData[i]
		if(lastW - math.abs(v.value) > 0) then
			if(v.dir == "x") then
				Sx = Sx + v.value
			elseif(v.dir == "y") then
				Sy = Sy + v.value
			else
				error("error dir for ROAD_DATA")
			end
			lastW = lastW - math.abs(v.value)
		else
			if(v.dir == "x") then
				Sx = Sx + lastW * v.value * (1/math.abs(v.value))
			elseif(v.dir == "y") then
				Sy = Sy + lastW * v.value * (1/math.abs(v.value))
			else
				error("error dir for ROAD_DATA")
			end
			break
		end
	end
	Sx,Sy = Sx*sign, Sy*sign
	-- print(string.format("Sx=%f,Sy=%f,Vh=%f,Ph=%f,Lh=%f,Lc=%f,Pc=%f,t=%f,sign=%f,lastW=%f", Sx,Sy,Vh,Ph,Lh,Lc,Pc,t,sign,lastW))
	local bronPos = BRON_POS[tonumber(p_playerInfo.transferId)%3 + 1]
	playerSprite:setPosition(ccp(bronPos.x + Sx, bronPos.y + Sy))
	playerSprite.pos = ccp(playerSprite:getPositionX(), playerSprite:getPositionY())
	--更新血量
	local bloodSprite = playerSprite.blood --tolua.cast(playerSprite:getChildByTag(kPlayerBloodTag), "CCProgressTimer")
	bloodSprite:setScaleX(tonumber(p_playerInfo.curHp)/tonumber(p_playerInfo.maxHp))
	--更新名称颜色
	local nameLabel = tolua.cast(playerSprite:getChildByTag(kPlayerNameTag), "CCRenderLabel")
	nameLabel:setColor(getNameColorByStreak(p_playerInfo.winStreak))
end

---------------------------[[ 回调事件处理 ]] -------------------------------
--[[
	@des :关闭按钮回调
--]]
function closeCallback( tag, sender )
	local exitBattleScene = function ( isConfirm )
		if isConfirm then
			local requestCallback = function ( ... )
				closeBattle()
			end
			GuildRobBattleService.leave(requestCallback)
			AudioUtil.playMainBgm()
		end
	end
	if _isJionBattle == true then
		AlertTip.showAlert(GetLocalizeStringBy("lcyx_128", GuildRobBattleData.getCooldownTime()) ,exitBattleScene, true)
	else
		exitBattleScene(true)
	end
end

--[[
	@des:closeBattle 关闭战斗回调
--]]
function closeBattle()
	CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimeScheduler)
	_bgLayer = nil
	--删除网络断开回调
	LoginScene.removeObserverForNetBroken("guild_rob")
	--删除重新连接回调
	if LoginScene.removeObserverForReconnect then
		LoginScene.removeObserverForReconnect("guild_rob")
	end
	--关闭弹幕层
	BulletLayer.closeLayer()
	--关闭弹幕输入框
	InputChatLayer.closeButtonCallback()
	require "script/ui/guild/guildRobList/GuildRobListLayer"
	GuildRobListLayer.show()
end


--[[
	@des :战报按钮回调
--]]
function reportButtonCallback( tag, sender )
	print("reportButtonCallback")
	require "script/ui/guild/guildrob/GuildRobBattleReportDialog"
	GuildRobBattleReportDialog.show(_touchPriority - 200, _zOrder + 100 )
end

--[[
	@des :布阵按钮回调
--]]
function deployButtonCallback( tag, sender )
	print("deployButtonCallback")
	if(DataCache.getSwitchNodeState(ksSwitchWarcraft, false) == true)then
		require "script/ui/warcraft/WarcraftLayer"
		WarcraftLayer.show()
	else
		require "script/ui/formation/MakeUpFormationLayer"
		MakeUpFormationLayer.showLayer()
	end
end

--[[
	@des :清除参赛cd时间按钮
--]]
function removeJoinCdCallback( tag, sender )
	
	if UserModel.getGoldNumber() < GuildRobBattleData.getRemoveCDCost() then
		--金币不足判断
		require "script/ui/tip/LackGoldTip"
		LackGoldTip.showTip()
		return
	end
	if TimeUtil.getSvrTimeByOffset(0) < GuildRobBattleData.getQuitReadyTime() then
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_129"))
		return
	end
	--判断是否参战处于cd状态
	if TimeUtil.getSvrTimeByOffset(0) > GuildRobBattleData.getCanJoinTime() then
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_130"))
		return
	end
	if _isBattleOver == true then
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_131"))
		return
	end

	print("removeJoinCdCallback", tag)
	local requestCallback = function ( p_speedGold )
		print("removeJoinCd")
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_132"))
		--更新加入cd
		_joinCDTime =GuildRobBattleData.getCanJoinTime() - TimeUtil.getSvrTimeByOffset(0)
		--清除cd 花费显示更新
		_removeCdGoldLabel:setString(GuildRobBattleData.getRemoveCDCost() .. "")
		--自动参战检查
		checkAutoJoin()
	end

	local tipFont = {}
 	tipFont[1] = CCLabelTTF:create(GetLocalizeStringBy("lcyx_133") .. GuildRobBattleData.getRemoveCDCost() ,g_sFontName,25)
    tipFont[1]:setColor(ccc3(0x78,0x25,0x00))
    tipFont[2] = CCSprite:create("images/common/gold.png")
    tipFont[3] = CCLabelTTF:create(GetLocalizeStringBy("lcyx_134"), g_sFontName,25)
    tipFont[3]:setColor(ccc3(0x78,0x25,0x00))
	GuildRobBattleService.removeJoinCd(requestCallback)
end

--[[
	@des :上阵按钮回调
--]]
function joinButtonCallback( tag, sender )
	print("joinButtonCallback", tag)

	--判断是否参战处于cd状态
	if _joinCDTime > 0 then
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_136"))
		return
	end
	if TimeUtil.getSvrTimeByOffset(0) < GuildRobBattleData.getQuitReadyTime() then
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_137"))
		return
	end
	if _isBattleOver == true then
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_138"))
		return
	end
	if _isJoining == true then
		-- AnimationTip.showTip("_isJoining")
		return
	end
	_isJoining = true
	print("now is join", _isJoining)
	local tranfromId = tag - 1
	local requestCallback = function ( p_merit, p_outTime, p_isCDTime )
		print("join tranform")
		_isJoining = false
		if p_isCDTime then
			return
		end
		showJoinButtons(false)
		addJoinBattleCDTime(p_outTime, tranfromId)
		_isJionBattle = true

		--加入战场提示
		local contentInfo = {}
	    contentInfo.labelDefaultColor = ccc3(0xff, 0xf6, 0x00)
	    contentInfo.labelDefaultSize = 18
	    contentInfo.defaultType = "CCRenderLabel"
	    contentInfo.lineAlignment = 1
	    contentInfo.labelDefaultFont = g_sFontPangWa
	    contentInfo.elements = {
	    	{
	    		type = "CCNode",
	    		create = function ( ... )
	    			local node = CCSprite:create("images/common/gongxun.png")
	    			return node
	    		end
	    	},
	    	{
    			text = "+" .. GuildRobBattleData.getJoinMerit(),
    			color = ccc3(0x00, 0xff, 0x18)
    		},
		}
		local pst = {
			ccpsprite(0.3, 0.12, _bgSprite),ccpsprite(0.5, 0.12, _bgSprite),ccpsprite(0.7, 0.12, _bgSprite),
			ccpsprite(0.3, 0.75, _bgSprite),ccpsprite(0.5, 0.75, _bgSprite),ccpsprite(0.7, 0.75, _bgSprite),
		}
		local pos = _bgSprite:convertToWorldSpace(pst[tranfromId + 1])
		showAlertByRichInfo(GetLocalizeStringBy("lcyx_139"),contentInfo, pos)
	end
	GuildRobBattleService.join(tranfromId, requestCallback)
end

--[[
	@des:说明按钮回调事件
--]]
function explanationButtonCallback( tag, sender )
	print("explanationButtonCallback")
	require "script/ui/guild/guildrob/GuildRobExplainDialog"
	GuildRobExplainDialog.show()
end

--[[
	@des: 自动加入赛场选择按钮
	@parm:
	@ret:
--]]
function aotoEnterButtonCallback( tag, sender )
	local button = tolua.cast(sender, "CCMenuItemToggle")
	--玩家vip等级是否达到要求
	if UserModel.getVipLevel() < GuildRobBattleData.getAotuBattleVipLevel() then
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_154", GuildRobBattleData.getAotuBattleVipLevel()))
		button:setSelectedIndex(0)
		return
	end
	
	local selectedIndex = button:getSelectedIndex()
	if selectedIndex == 0 then
		--关闭自动参战
		_isAutoEnter = false
	else
		--开启自动参战
		_isAutoEnter = true
		checkAutoJoin()
	end
end

--[[
	@des: 检查是否可以加入战场，如果可以，自动加入
--]]
function checkAutoJoin( ... )

	if _isAutoEnter ~= true then
		-- AnimationTip.showTip("_isAutoEnter .........")
		return
	end
	if _isJionBattle then
		-- AnimationTip.showTip("_isJionBattle .........")
		return
	end
	if _isBattleOver == true then
		--AnimationTip.showTip(GetLocalizeStringBy("lcyx_138"))
		return
	end

	--找到等待人数最少的传送阵
	local roadState = GuildRobBattleData.getReadState()
	local minRoadNum = 1
	for i=1,1000 do
		if GuildRobBattleData.isUserAttackerGuild() == false then
			minRoadNum = math.random(3) + 3
		else
			minRoadNum = math.random(3)
		end
		if GuildRobBattleData.getReadState() == 1 then
			if minRoadNum%3 ~= 2 then
				break
			end
		end
	end
	joinButtonCallback(minRoadNum, nil)
end

--[[
	@des:网络断开回调
--]]
function networkBreakCallback()
	CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimeScheduler)
end
--[[
	@des:重新连接回调
--]]
function networkReconnectCallback( ... )
	local callback = function ( ... )
		closeBattle()
	end
	AlertTip.showAlert(GetLocalizeStringBy("lcyx_1916"),callback,nil,nil,nil,nil,nil,nil,false)
end

---------------------------[[ 推送事件回调 ]]-------------------------------------
--[[
	@des :结算信息推送回调
--]]
function reckonPushCallback( ... )
	if(_bgLayer) then
		--关闭弹幕层
		BulletLayer.closeLayer()
		--关闭弹幕输入框
		InputChatLayer.closeButtonCallback()
		GuildAfterRobBattleLayer.show(_touchPriority - 100, _zOrder + 800)
	end
end

--[[
	@des :数据刷新回调
--]]
function refreshPushCallback( ... )
	--刷新ui显示数据
	-- updateLabels()
	--刷新第二条路的显示
	if(_bgLayer) then
		showSecondRoad()
	end
end
--[[
	@des :玩家战斗胜利推送
--]]
function fightWinPushCallback( p_info )
	local isOut = false
	if p_info.extra.winnerOut == "true" then
		isOut = true
	end
	performWithDelay(_bgLayer, function ( ... )
		local userId = UserModel.getUserUid()
		if isOut == false and _playerArray[tostring(userId)] then
			local pos = _playerArray[tostring(userId)]:convertToWorldSpace(ccp(0, 0))
			-- showAddGrain(kKillType, p_info.reward.userGrain, p_info.reward.merit, pos)
			local contentInfo = {}
		    contentInfo.labelDefaultColor = ccc3(0xff, 0xf6, 0x00)
		    contentInfo.labelDefaultSize = 18
		    contentInfo.defaultType = "CCRenderLabel"
		    contentInfo.lineAlignment = 1
		    contentInfo.labelDefaultFont = g_sFontPangWa
		    contentInfo.elements = {
		    	{
		    		type = "CCNode",
		    		create = function ( ... )
		    			local node = CCSprite:create("images/common/gongxun.png")
		    			return node
		    		end
		    	},
		    	{
	    			text = "+" .. p_info.reward.merit,
	    			color = ccc3(0x00, 0xff, 0x18)
	    		},
			}
			showAlertByRichInfo(GetLocalizeStringBy("lcyx_140"),contentInfo, pos)
		end
	end,1)
	--如果同归于尽那么也删除掉自己
	performWithDelay(_bgLayer, function ( ... )
		if isOut ==  true  then
			fightLosePushCallback()
		end
	end,0.5)
end
--[[
	@des :玩家战败推送
--]]
function fightLosePushCallback( ... )
	if _bgLayer == nil then
		return
	end
	showJoinButtons(true)
	_isJionBattle = false
	local userId = UserModel.getUserUid()
	if(_playerArray[tostring(userId)]) then
		_playerArray[tostring(userId)]:removeFromParentAndCleanup(true)
		_playerArray[tostring(userId)] = nil
		print("fightLosePushCallback")
	end
	--更新加入cd
	_joinCDTime =GuildRobBattleData.getCanJoinTime() - TimeUtil.getSvrTimeByOffset(0)
end
--[[
	@des :达阵事件推送
--]]
function touchDownPushCallback( p_info )
	if _bgLayer == nil then
		return
	end
	performWithDelay(_bgSprite, function ( ... )
		showJoinButtons(true)
		_isJionBattle = false
		local userId = UserModel.getUserUid()
		print("userId", userId)
		local pos = _playerArray[tostring(userId)]:convertToWorldSpace(ccp(0, 0))
		-- showAddGrain(kRobTyp, p_info.reward.userGrain, p_info.reward.merit, pos)
		if GuildRobBattleData.isUserAttackerGuild() then
			local contentInfo = {}
		    contentInfo.labelDefaultColor = ccc3(0xff, 0xf6, 0x00)
		    contentInfo.labelDefaultSize = 18
		    contentInfo.defaultType = "CCRenderLabel"
		    contentInfo.lineAlignment = 1
		    contentInfo.labelDefaultFont = g_sFontPangWa
		    contentInfo.elements = {
		    	{
		    		type = "CCNode",
		    		create = function ( ... )
		    			local node = CCSprite:create("images/common/liangcao.png")
		    			return node
		    		end
		    	},
		    	{
	    			text = "+" .. p_info.reward.guildGrain,
	    			color = ccc3(0x00, 0xff, 0x18)
	    		},
	    		{
		    		type = "CCNode",
		    		create = function ( ... )
		    			local node = CCSprite:create("images/common/xiaomai.png")
		    			return node
		    		end
		    	},
		    	{
	    			text = "+" .. p_info.reward.userGrain,
	    			color = ccc3(0x00, 0xff, 0x18)
	    		},
	    		{
		    		type = "CCNode",
		    		create = function ( ... )
		    			local node = CCSprite:create("images/common/gongxun.png")
		    			return node
		    		end
		    	},
		    	{
	    			text = "+" .. p_info.reward.merit,
	    			color = ccc3(0x00, 0xff, 0x18)
	    		},
			}
			showAlertByRichInfo(GetLocalizeStringBy("lcyx_141"),contentInfo, ccp(g_winSize.width*0.5, pos.y))
		else
			local contentInfo = {}
		    contentInfo.labelDefaultColor = ccc3(0xff, 0xf6, 0x00)
		    contentInfo.labelDefaultSize = 18
		    contentInfo.defaultType = "CCRenderLabel"
		    contentInfo.lineAlignment = 1
		    contentInfo.labelDefaultFont = g_sFontPangWa
		    contentInfo.elements = {
		    	{
		    		type = "CCNode",
		    		create = function ( ... )
		    			local node = CCSprite:create("images/common/gongxun.png")
		    			return node
		    		end
		    	},
		    	{
		    		text = "+"..GuildRobBattleData.getDefenderTouchdownMerit(),
		    		color = ccc3(0x00, 0xff, 0x18)
		    	},
		    	{
		    		type = "CCNode",
		    		create = function ( ... )
		    			local node = CCSprite:create("images/guild_rob/moral.png")
		    			node:setScale(0.4)
		    			return node
		    		end
		    	},
		    	{
		    		text = "-" .. GuildRobBattleData.getReduceRage(),
		    		color = ccc3(0x00, 0xff, 0x18)
		    	},
		    	{
		    		text = GuildRobBattleData.getReduceTime(),
		    		color = ccc3(0x00, 0xff, 0x18)
		  		}
			}
			showAlertByRichInfo(GetLocalizeStringBy("lcyx_142"),contentInfo, ccp(g_winSize.width*0.5, pos.y))
		end

		_playerArray[tostring(userId)]:removeFromParentAndCleanup(true)
		_playerArray[tostring(userId)] = nil
		--更新加入cd
		_joinCDTime = GuildRobBattleData.getCanJoinTime() - TimeUtil.getSvrTimeByOffset(0)
	end, 1)
end
--[[
	@des :军团pvp战斗结束推送
--]]
function battleEndPushCallback( ... )
	_isBattleOver = true
	BulletLayer.closeLayer()
end
--[[
	@des :战报推送回调
--]]
function fightResultPushCallback( p_resultInfo )
	print("add lose player id=", p_resultInfo.loserId)
	performCallfunc(function ( ... )
		if _bgLayer == nil then
			return
		end
		--播放战斗特效
		local winPlayerInfo = GuildRobBattleData.getRoadPlayerInfo(p_resultInfo.winnerId)
		local losePlayerInfo = GuildRobBattleData.getRoadPlayerInfo(p_resultInfo.loserId)
		if winPlayerInfo ~= nil and  losePlayerInfo and winPlayerInfo.transferId then
			local transferId = tonumber(winPlayerInfo.transferId)
			local roadId  = transferId%3 + 1
			local winSprite = _playerArray[p_resultInfo.winnerId]
			local loseSprite = _playerArray[p_resultInfo.loserId]
			if winSprite ~= nil and loseSprite ~= nil then
				local maxY = math.max(winSprite:getPositionY(), loseSprite:getPositionY())
				local minY = math.min(winSprite:getPositionY(), loseSprite:getPositionY())
				local posY = minY + (maxY - minY)/2
				local posX = winSprite:getPositionX()
				playBattleEffect(_roadArray[roadId], ccp(posX, posY))
			end
		end
		table.insert(_failedPlayerArray, p_resultInfo.loserId)
		if p_resultInfo.winnerOut == "true" then
			table.insert(_failedPlayerArray, p_resultInfo.winnerId)
		end
		require "script/ui/guild/guildrob/GuildRobBattleReportDialog"
		GuildRobBattleReportDialog.updateReportScrollview()
		--连杀提示
		showStreak(p_resultInfo)
	end, 0.5)
end

---------------------------[[ 工具方法 ]]-----------------------------
--[[
	@des:是否显示第二条路
--]]
function showSecondRoad( ... )
	local roadState = GuildRobBattleData.getReadState()
	if  _roadArray[2] == nil or
		_joinButtonArray[2] == nil or
		_joinButtonArray[5] == nil or
		_tranferEffects[2] == nil or
		_tranferBgArray[2] == nil or
		_tranferBgArray[5] == nil then
		return
    end

	if roadState == 1 then
		_roadArray[2]:setVisible(false)
		_joinButtonArray[2]:setVisible(false)
		_joinButtonArray[5]:setVisible(false)
		_tranferEffects[2]:setVisible(false)
		_tranferBgArray[2]:setVisible(false)
		_tranferBgArray[5]:setVisible(false)
	else
		_roadArray[2]:setVisible(true)
		if GuildRobBattleData.isUserAttackerGuild()  then
			_joinButtonArray[2]:setVisible(_isJoinButtonShow)
			_tranferEffects[2]:setVisible(true)
			_tranferBgArray[2]:setVisible(true)
		else
			_joinButtonArray[5]:setVisible(_isJoinButtonShow)
			_tranferBgArray[5]:setVisible(true)
		end
	end
end

--[[
	@des: 显示或者隐藏join按钮
--]]
function showJoinButtons( p_isShow )
	_isJoinButtonShow = p_isShow
	if GuildRobBattleData.isUserAttackerGuild() then
		for i=1,3 do
			_joinButtonArray[i]:setVisible(p_isShow)
		end
		for i=4,6 do
			_joinButtonArray[i]:setVisible(false)
		end
	else
		for i=1,3 do
			_joinButtonArray[i]:setVisible(false)
		end
		for i=4,6 do
			_joinButtonArray[i]:setVisible(p_isShow)
		end
	end
	showSecondRoad()
end

--[[
	@des:删除玩家
--]]
function removePlayer( p_playerId, kType )
	if(tonumber(p_playerId) ~= UserModel.getUserUid() ) then
		if kType == kRomveTouchDown then
			--守方玩家达阵玩家士气处理
			local transferId = _playerArray[p_playerId].info.transferId
			if tonumber(transferId) > 2 then
				showSubMoralTip(transferId)
			end
		end
		_playerArray[p_playerId]:removeFromParentAndCleanup(true)
		_playerArray[p_playerId] = nil
	end
end

--[[
	@des:踢飞特效
--]]
function removeByAction( p_playerId, kType )
	local nodeSprite = _playerArray[p_playerId]
	local pos = nodeSprite:convertToWorldSpace(ccpsprite(0.5, 0.5, nodeSprite))
	nodeSprite:retain()
	nodeSprite:removeFromParentAndCleanup(false)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(nodeSprite, 500)
	nodeSprite:release()
	_playerArray[p_playerId] = nil
	nodeSprite:setScale(MainScene.elementScale * 0.6)
	nodeSprite:setPosition(pos)

	local moveX = 600*MainScene.elementScale
	local moveY = 600*MainScene.elementScale
	if(tonumber(nodeSprite.info.transferId) < 3) then
		moveY = -moveY
	end
	local spwan = CCSpawn:createWithTwoActions(CCRotateTo:create(1,360*20), CCMoveBy:create(1,ccp(moveX,moveY)))
	local callFunc = CCCallFuncN:create(function ( p_actionNode )
		p_actionNode:removeFromParentAndCleanup(true)
		_playerArray[p_playerId] = nil
	end)
	local actionArray = CCArray:create()
	actionArray:addObject(spwan)
	actionArray:addObject(callFunc)
	local seq = CCSequence:create(actionArray)
	nodeSprite:runAction(seq)
end




--------------------------------------[[ 提示处理 ]] --------------------------------------


--[[
	@des: 显示获得功勋和粮草
--]]
function showAddGrain( p_showType, p_grain, p_merit, p_pos )
	local alertBg = CCScale9Sprite:create("images/common/bg/9s_guild.png")
	alertBg:setPosition(p_pos)
	alertBg:setAnchorPoint(ccp(0.5, 0.5))
	_bgLayer:addChild(alertBg, 300)

	local titleName = nil
	local showType = p_showType or kKillType
	if p_showType == kKillType then
		titleName = GetLocalizeStringBy("key_10174")
	else
		titleName = GetLocalizeStringBy("key_10175")
	end

	local titleNameLabel = CCRenderLabel:create(titleName, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	titleNameLabel:setColor(ccc3(0xff, 0xf6, 0x00))

	local meritSprite = CCSprite:create("images/common/gongxun.png")
	local meritLabel = CCRenderLabel:create(tostring(p_merit), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	meritLabel:setColor(ccc3(0x00, 0xff, 0x18))

	local grainSprite = CCSprite:create("images/common/xiaomai.png")
	local grainLabel = CCRenderLabel:create(tostring(p_grain), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	grainLabel:setColor(ccc3(0x00, 0xff, 0x18))

	local contentInfo = nil
	if tonumber(p_grain) > 0 then
		contentInfo = {titleNameLabel, meritSprite, meritLabel, grainSprite, grainLabel}
	else
		contentInfo = {titleNameLabel, meritSprite, meritLabel}
	end

	local contentNode = BaseUI.createHorizontalNode(contentInfo)
	alertBg:setContentSize(CCSizeMake(contentNode:getContentSize().width + 20, contentNode:getContentSize().height + 10))
	contentNode:setAnchorPoint(ccp(0.5, 0.5))
	contentNode:setPosition(ccpsprite(0.5, 0.5, alertBg))
	alertBg:addChild(contentNode)

	local actionArray = CCArray:create()
	actionArray:addObject(CCMoveBy:create(3, ccp(0, 80)))
	actionArray:addObject(CCCallFunc:create(function ( ... )
		alertBg:removeFromParentAndCleanup(true)
		alertBg = nil
	end))
	local seqAction = CCSequence:create(actionArray)
	alertBg:runAction(seqAction)
end

--[[
	@des: 连胜和连胜被终结
--]]
function showStreak( p_resultInfo  )
	print("showStreak")
	printTable("p_resultInfo", p_resultInfo)
	
	local showAlert = function ( p_stringTable, p_colorTable )
		local showLabels = {}
		for i=1,#p_stringTable do
			local label = CCRenderLabel:create(p_stringTable[i], g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			p_colorTable[i] = p_colorTable[i] or ccc3(0xff, 0xff,0xff)
			label:setColor(p_colorTable[i])
			table.insert(showLabels, label)
		end

		local alertBg = CCScale9Sprite:create("images/guild_rob/s_bg.png")
		alertBg:setAnchorPoint(ccp(0.5, 0.5))
		alertBg:setPosition(ccps(0.5, 0.3))
		_bgLayer:addChild(alertBg, 300)

		local contentNode = BaseUI.createHorizontalNode(showLabels)

		alertBg:setContentSize(CCSizeMake(contentNode:getContentSize().width + 20, contentNode:getContentSize().height + 10))
		contentNode:setAnchorPoint(ccp(0.5, 0.5))
		contentNode:setPosition(ccpsprite(0.5, 0.5, alertBg))
		alertBg:addChild(contentNode)
		alertBg:setScale(MainScene.elementScale)

		local actionArray = CCArray:create()
		actionArray:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(5),CCMoveBy:create(5, ccp(0, 40))))
		actionArray:addObject(CCCallFunc:create(function ( ... )
			alertBg:removeFromParentAndCleanup(true)
			alertBg = nil
		end))
		local seqAction = CCSequence:create(actionArray)
		alertBg:runAction(seqAction)

		contentNode:setCascadeOpacityEnabled(true)
		contentNode:runAction(CCFadeOut:create(5))
	end

	local showString = nil
	
	local colors 	 = nil
	require "db/DB_Guild_rob_win"
	--连胜提示
	for i=1,50 do
		local dataInfo = DB_Guild_rob_win.getDataById(i)
		if(dataInfo == nil) then
			break
		end
		if tonumber(dataInfo.number) == tonumber(p_resultInfo.winStreak) then
			showString = dataInfo.winspeak
			break
		end
	end
	if showString then
		showString = string.gsub(showString, "xxx", p_resultInfo.winnerName)
		print("showString",showString)
		showString = string.split(showString, "{1}")
		colors = {ccc3(0x00, 0xe4, 0xff),ccc3(0xff, 0xff, 0xff),ccc3(0xff, 0x00, 0x00),ccc3(0xff, 0xff, 0xff)}
		showAlert(showString, colors)
		print("连胜提示")
		printTable("showString", showString)
	end
	showString = nil
	--连胜被终结
	local baseWinNum = tonumber(DB_Guild_rob_win.getDataById(1).endwinnumber)
	for i=1,50 do
		local dataInfo = DB_Guild_rob_win.getDataById(i)
		if(dataInfo == nil) then
			break
		end
		if tonumber(dataInfo.endwinnumber) <= tonumber(p_resultInfo.terminalStreak) and tonumber(p_resultInfo.terminalStreak) >= baseWinNum then
			showString = dataInfo.endwin
			break
		end
	end
	if showString then
		showString = string.gsub(showString, "xxx", p_resultInfo.winnerName)
		showString = string.gsub(showString, "yyy", p_resultInfo.loserName)
		showString = string.gsub(showString, "{n}", p_resultInfo.terminalStreak)
		print("showString",showString)
		showString = string.split(showString, "{1}")
		colors = {
			ccc3(0x00, 0xff, 0x18),ccc3(0xff, 0xff, 0xff),ccc3(0x00, 0xff, 0x18),ccc3(0xff, 0xff, 0xff),ccc3(0xff, 0x00, 0x00),
			ccc3(0xff, 0xff, 0xff),ccc3(0x00, 0xe4, 0xff),ccc3(0xff, 0xff, 0xff),ccc3(0x00, 0xe4, 0xff),ccc3(0xff, 0xff, 0xff),
		}
		showAlert(showString, colors)
		print("连胜被终结")
		printTable("showString", showString)
	end
end

--[[
	@des: 攻防减士气
--]]
function showSubMoralTip(p_tranferId)
	if tolua.cast(_bgSprite, "CCSprite") == nil then
		return
	end

	if GuildRobBattleData.getMorale() <= 0 then
		return
	end

	local pst = {
		ccpsprite(0.3, 0.12, _bgSprite),ccpsprite(0.5, 0.12, _bgSprite),ccpsprite(0.7, 0.12, _bgSprite),
		ccpsprite(0.3, 0.75, _bgSprite),ccpsprite(0.5, 0.75, _bgSprite),ccpsprite(0.7, 0.75, _bgSprite),
	}
	local transferId = tonumber(p_tranferId)%3 + 1
	local alertBg = CCScale9Sprite:create("images/common/bg/9s_guild.png")
	alertBg:setContentSize(CCSizeMake(320, 35))
	
	local contentArray = {}
	local contentNode = nil
	if  GuildRobBattleData.isUserAttackerGuild() then
		--攻防显示
		local contentInfo = {}
	    contentInfo.labelDefaultColor = ccc3(0xff, 0xf6, 0x00)
	    contentInfo.labelDefaultSize = 18
	    contentInfo.defaultType = "CCRenderLabel"
	    contentInfo.lineAlignment = 1
	    contentInfo.labelDefaultFont = g_sFontPangWa
	    contentInfo.elements = {
	    	{
	    		type = "CCNode",
	    		create = function ( ... )
	    			local node = CCSprite:create("images/guild_rob/moral.png")
	    			node:setScale(0.4)
	    			return node
	    		end
	    	},
	    	{
	    		text = "-" .. GuildRobBattleData.getReduceRage() ,
	    		color = ccc3(0x00, 0xff, 0x18)
	    	},
	    	{
	    		text = GuildRobBattleData.getReduceTime(),
	    		color = ccc3(0x00, 0xff, 0x18)
	  		}
		}
		contentNode = GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("lcyx_143"), contentInfo)
		contentNode:setAnchorPoint(ccp(0.5,0.5))
		contentNode:setPosition(ccpsprite(0.5, 0.5, alertBg))
		alertBg:addChild(contentNode)

		alertBg:setPosition(ccps(0, 0.2))
		alertBg:setAnchorPoint(ccp(0.05, 0.5))
		_bgLayer:addChild(alertBg, 300)
		alertBg:setScale(MainScene.elementScale)
	else
		--防守方显示
		local contentInfo = {}
	    contentInfo.labelDefaultColor = ccc3(0xff, 0xf6, 0x00)
	    contentInfo.labelDefaultSize = 18
	    contentInfo.defaultType = "CCRenderLabel"
	    contentInfo.lineAlignment = 1
	    contentInfo.labelDefaultFont = g_sFontPangWa
	    contentInfo.elements = {
	    	{
	    		type = "CCNode",
	    		create = function ( ... )
	    			local node = CCSprite:create("images/guild_rob/moral.png")
	    			node:setScale(0.4)
	    			return node
	    		end
	    	},
	    	{
	    		text = "-" .. GuildRobBattleData.getReduceRage(),
	    		color = ccc3(0x00, 0xff, 0x18)
	    	},
	    	{
	    		text = GuildRobBattleData.getReduceTime(),
	    		color = ccc3(0x00, 0xff, 0x18)
	  		}
		}
		-- contentNode = GetLocalizeLabelSpriteBy_2("攻防%s%s,抢夺时间减少%s秒", contentInfo)
		contentNode = GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("lcyx_144"), contentInfo)
		contentNode:setAnchorPoint(ccp(0.5,0.5))
		contentNode:setPosition(ccpsprite(0.5, 0.5, alertBg))
		alertBg:addChild(contentNode)

		local road = _roadArray[transferId]
		local pos  = road:convertToWorldSpace(ccp(BRON_POS[transferId].x, BRON_POS[transferId].y))
		alertBg:setPosition(pos)
		alertBg:setAnchorPoint(ccp(0.5, 0.5))
		_bgLayer:addChild(alertBg, 300)
		alertBg:setScale(MainScene.elementScale)
	end
	local actionArray = CCArray:create()
	actionArray:addObject(CCMoveBy:create(3, ccp(0, 80)))
	actionArray:addObject(CCCallFunc:create(function ( ... )
		alertBg:removeFromParentAndCleanup(true)
		alertBg = nil
	end))
	local seqAction = CCSequence:create(actionArray)
	alertBg:runAction(seqAction)
end

--[[
	@:显示消息提示
--]]
function showAlertByRichInfo( p_richString, p_richInfo, p_pos)
	local richInfo = p_richInfo or {}
	local richString = p_richString or ""
	local pos = p_pos or ccps(0.5, 0.8)
	local alertBg = CCScale9Sprite:create("images/common/bg/9s_guild.png")
	alertBg:setAnchorPoint(ccp(0.5, 0.5))
	alertBg:setPosition(pos)
	_bgLayer:addChild(alertBg, 300)
	alertBg:setScale(MainScene.elementScale)
	
	contentNode = GetLocalizeLabelSpriteBy_2(richString, richInfo)
	alertBg:setContentSize(CCSizeMake(contentNode:getContentSize().width + 20, contentNode:getContentSize().height + 10))
	contentNode:setAnchorPoint(ccp(0.5, 0.5))
	contentNode:setPosition(ccpsprite(0.5, 0.5, alertBg))
	alertBg:addChild(contentNode)

	local actionArray = CCArray:create()
	actionArray:addObject(CCMoveBy:create(3, ccp(0, 80)))
	actionArray:addObject(CCCallFunc:create(function ( ... )
		alertBg:removeFromParentAndCleanup(true)
		alertBg = nil
	end))
	local seqAction = CCSequence:create(actionArray)
	alertBg:runAction(seqAction)
end


--[[
	@des: 根据连胜次数得到玩家名称颜色
--]]
function getNameColorByStreak( p_streakNum )
	 -- 5、10、15、25、50 5档颜色分别对应 白色、绿色、蓝色、紫色、橙色
	local streakNum = p_streakNum or 0
	if tonumber(streakNum) <5 then
		return ccc3(0xff, 0xff, 0xff)
	elseif tonumber(streakNum) < 10 then
		return ccc3(42, 255, 9)
	elseif tonumber(streakNum) < 15 then
		return ccc3(36, 255, 255)
	elseif tonumber(streakNum) < 25 then
		return ccc3(249, 0, 254)
	else
		return ccc3(0xff,0x93,0x00)
	end
end

-----------------------------------------[[ 播放特效 ]]------------------------------------
--[[
	@des: 战斗开始特效
--]]
function playerBattleStartEffect( ... )
	local scene = CCDirector:sharedDirector():getRunningScene()
	local effect =  CCLayerSprite:layerSpriteWithName(CCString:create("images/guild_rob/effect/zhandoukaishi/zhandoukaishi"), -1,CCString:create(""))
	effect:setPosition(ccps(0.5, 0.5))
	scene:addChild(effect, 100)
	effect:setScale(MainScene.elementScale)
	local animationDelegate = BTAnimationEventDelegate:create()
    animationDelegate:registerLayerEndedHandler(function ( ... )
    	effect:removeFromParentAndCleanup(true)
    	effect = nil
    end)
    effect:setDelegate(animationDelegate)
end


--[[
	@des: 播放战斗碰撞特效
--]]
function playBattleEffect( p_baseNode, p_pos )
	print("playBattleEffect")
	AudioUtil.playEffect("audio/effect/pengzhuang.mp3")
	local effect =  CCLayerSprite:layerSpriteWithName(CCString:create("images/guild_rob/effect/pengzhuang/pengzhuang"), -1,CCString:create(""))
	effect:setPosition(p_pos)
	p_baseNode:addChild(effect, 100)

	local animationDelegate = BTAnimationEventDelegate:create()
    animationDelegate:registerLayerEndedHandler(function ( ... )
    	effect:removeFromParentAndCleanup(true)
    	effect = nil
    end)
    effect:setDelegate(animationDelegate)
end



