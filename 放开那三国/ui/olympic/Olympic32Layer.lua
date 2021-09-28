-- Filename: OlympicService.lua
-- Author: zhangqiang
-- Date: 2014-07-14
-- Purpose: 擂台争霸32强场景

require "script/ui/olympic/OlympicData"
require "script/ui/olympic/OlympicService"
require "script/utils/TimeUtil"

module("Olympic32Layer",package.seeall)

local kTopUINodeContentSize = CCSizeMake(640, 300)
local kBottomUINodeContentSize = CCSizeMake(630, 80)
local kBottomMenuTouchPriority = -480
local kBattleReportPanelTouchPriority = -481
local kStageChangeAnimationLayerZOrder = 999

local kRankFinal32 = 32
local kRankFinal16 = 16
local kRankFinal8 = 8
local kRankFinal4 = 4

local kGroupAId = 1
local kGroupBId = 2
local kGroupCId = 3
local kGroupDId = 4

local kGroupAButtonTag = 10
local kGroupBButtonTag = 11
local kGroupCButtonTag = 12
local kGroupDButtonTag = 13

local kHeadIconBgNumber = 11
local kCheckBtnNumber = 7

local kTopLeftCheckBtnTag = 1
local kTopRightCheckBtnTag = 2
local kBottomLeftCheckBtnTag = 3
local kBottomRightCheckBtnTag = 4
local kMiddleLeftCheckBtnTag = 5
local kMiddleRightCheckBtnTag = 6
local kMiddleCenterCheckBtnTag = 7

local kOlympicMapContentSize = CCSizeMake(619,560)
--[[
	head icon position index:	1   2   3   4
					              9   11  10 
					            5   6   7   8
--]]
local kHeadIconBgPositionTable = {
									position1  = ccp(52, 482),  position2  = ccp(214, 482),
									position3  = ccp(405, 482), position4  = ccp(567, 482),
									position5  = ccp(52, 88),   position6  = ccp(214, 88),
									position7  = ccp(405, 88),  position8  = ccp(567, 88),
									position9  = ccp(133, 285), position10 = ccp(486, 285),
									position11 = ccp(310, 285),
								 }

--[[
	check buttom position index:	1       2
						              5 7 6 
						            3       4
--]]
local kCheckBtnPositionTable = {
									position1 = ccp(133,392), position2 = ccp(486,392),
									position3 = ccp(133,179), position4 = ccp(486,179),
									position5 = ccp(45,285), position6 = ccp(571,285),
									position7 = ccp(312,190),
						       }

local kEnermyMapTable = {[1]=2, [2]=1, [3]=4, [4]=3, [5]=6, [6]=5, [7]=8, [8]=7, [9]=10, [10]=9, [11]=11}

local _bgLayer            = nil
local _bgLayerContentSize = nil
local _bottomPanel 		  = nil
local _headIconBgTable    = nil
local _checkBtnTable      = nil

local _currentStageEndTimeStamp = nil
local _timeLabel = nil
local _timeBgSprite = nil
local _timeDescLabel = nil

-- local _descSprite16 = nil
-- local _descSprite8 = nil
-- local _descSprite4 = nil
local _descSpriteInTopUI = nil

function init( ... )
	OlympicData.olympic32DataInit()
	_bgLayer                  = nil
	_bgLayerContentSize       = nil
	_bottomPanel 		  	  = nil
	_headIconBgTable          = nil
	_checkBtnTable            = nil
	_currentStageEndTimeStamp = nil
	_timeLabel = nil
	_timeBgSprite = nil
	_timeDescLabel = nil
	-- _descSprite16             = nil
	-- _descSprite8              = nil
	-- _descSprite4              = nil
	_descSpriteInTopUI = nil
end

------------------------------------[[ ui 创建方法 ]]-----------------------------------------

--[[
	@des : 显示擂台争霸场景
--]]
function show( ... )
    local layer = Olympic32Layer.createLayer()
    MainScene.changeLayer(layer, "Olympic32Layer")
end


--[[
	@des : 创建擂台争霸准备场景
--]]
function createLayer( ... )
	init()
	_bgLayer = CCLayer:create()
	MainScene.setMainSceneViewsVisible(false, false, false)
	_bgLayerContentSize              = CCSizeMake(g_winSize.width,g_winSize.height)
	_bgLayer:setContentSize(_bgLayerContentSize)

	local bgSprite = CCSprite:create("images/olympic/playoff_bg.jpg")
	bgSprite:setAnchorPoint(ccp(0.5,0))
	bgSprite:setPosition(_bgLayerContentSize.width/2,0)
	_bgLayer:addChild(bgSprite)
	bgSprite:setScale(MainScene.bgScale)

	OlympicService.getInfo(function ( ... )
		crateTopUI()
		createBottomUI()
		createCenterUI()
		OlympicService.regisgerStagechangePush(stageChangePushCallback)
		--推送注册
		OlympicService.registerBattleRecordPush(refreshUIByOlympicIndexTable)
		--比赛阶段变化动画
		if OlympicData.getStage() == OlympicData.kSixteenStage then
			runStageChangeAnimationByOlympicStage(OlympicData.kSixteenStage, kStageChangeAnimationLayerZOrder)
		end
	end)

	return _bgLayer
end

--[[

--]]
function createMenuItemWithLabel(p_normalImagePath, p_highlightImagePath, p_labelStr)
	local normalSprite = CCSprite:create(p_normalImagePath)
	local normalLabel = CCLabelTTF:create(p_labelStr, g_sFontPangWa, 33)
	normalLabel:setColor(ccc3(0xff,0xff,0xff))
	normalLabel:setAnchorPoint(ccp(0.5,0.5))
	normalLabel:setPosition(normalSprite:getContentSize().width*0.5,normalSprite:getContentSize().height*0.5)
	normalSprite:addChild(normalLabel)

	local highlightSprite = CCSprite:create(p_highlightImagePath)
	local highlightLabel = CCLabelTTF:create(p_labelStr, g_sFontPangWa, 33*0.85)
	highlightLabel:setColor(ccc3(0xff,0xff,0xff))
	highlightLabel:setAnchorPoint(ccp(0.5,0.5))
	highlightLabel:setPosition(highlightSprite:getContentSize().width*0.5,highlightSprite:getContentSize().height*0.5)
	highlightSprite:addChild(highlightLabel)

	return CCMenuItemSprite:create(normalSprite, highlightSprite)
end

--[[
	@des :	创建倒计时
--]]
function runTimeCountDownAction()
	if _currentStageEndTimeStamp == nil then
		_currentStageEndTimeStamp = OlympicData.getStageNowEndTime()
		_timeBgSprite:setVisible(true)
		_timeDescLabel:setVisible(true)
		_timeLabel:setPosition(385,134)
	end
	
	local timeStr = nil
	local currentStageRemainingTime = nil
	--剩余时间
	currentStageRemainingTime = _currentStageEndTimeStamp - BTUtil:getSvrTimeInterval()
	if currentStageRemainingTime <= 0 or OlympicData.getStage() > 5 then
		_currentStageEndTimeStamp = nil
		currentStageRemainingTime = 0
		if OlympicData.getStage() == OlympicData.kAfterStage then
			--"今日擂台争霸已结束"
			timeStr = GetLocalizeStringBy("zz_15")
		else
			--"比赛结果计算中"
			timeStr = GetLocalizeStringBy("zz_16")
		end
		_timeLabel:setString(timeStr)
		_timeLabel:setPosition(320,_timeLabel:getPositionY())
		_timeLabel:stopAllActions()
		_timeBgSprite:setVisible(false)
		_timeDescLabel:setVisible(false)
		return
	end
	timeStr = OlympicPrepareLayer.getTimeDes(currentStageRemainingTime)
	_timeLabel:setString(timeStr)
	local actionSequence = CCSequence:createWithTwoActions(CCDelayTime:create(1),CCCallFunc:create(runTimeCountDownAction))
	_timeLabel:runAction(actionSequence)
end

--[[
	@des : 	创建顶部ui
--]]
function crateTopUI( ... )
	local topNode = CCNode:create()
	topNode:setAnchorPoint(ccp(0.5,1))
	topNode:setContentSize(kTopUINodeContentSize)
	topNode:setPosition(ccp(_bgLayerContentSize.width*0.5, _bgLayerContentSize.height))
	_bgLayer:addChild(topNode)
	topNode:setScale(g_fScaleX)

	local lineSprite = CCSprite:create("images/copy/fort/top_cutline.png")
	lineSprite:setPosition(ccp(topNode:getContentSize().width * 0.5, 0))
	lineSprite:setAnchorPoint(ccp(0.5, 0))
	topNode:addChild(lineSprite)
	
	local titleBgSprite = CCSprite:create("images/olympic/title_bg.png")
	titleBgSprite:setAnchorPoint(ccp(0.5, 1))
	titleBgSprite:setPosition(kTopUINodeContentSize.width*0.5,kTopUINodeContentSize.height-20)
	topNode:addChild(titleBgSprite)

	local titleDescSprite = CCSprite:create("images/olympic/title.png")
	titleDescSprite:setAnchorPoint(ccp(0.5,1))
	titleDescSprite:setPosition(ccpsprite(0.5, 1, topNode))
	topNode:addChild(titleDescSprite)

	--“x强晋级赛”
	_descSpriteInTopUI = CCSprite:create()
	_descSpriteInTopUI:setAnchorPoint(ccp(0.5,1))
	_descSpriteInTopUI:setPosition(topNode:getContentSize().width*0.5,topNode:getContentSize().height-120)
	topNode:addChild(_descSpriteInTopUI)

	--倒计时
	_timeDescLabel = CCRenderLabel:create(GetLocalizeStringBy("zz_17"), g_sFontPangWa, 21, 1, ccc3(0x00,0x00,0x00), type_shadow)
	_timeDescLabel:setColor(ccc3(0x00, 0xff, 0x18))
	_timeDescLabel:setAnchorPoint(ccp(1,0))
	_timeDescLabel:setPosition(296,121)
	topNode:addChild(_timeDescLabel)

	_timeBgSprite = CCSprite:create("images/olympic/time_bg.png")
	_timeBgSprite:setAnchorPoint(ccp(0.5,0.5))
	_timeBgSprite:setPosition(385,134)
	topNode:addChild(_timeBgSprite)

	require "script/ui/olympic/OlympicPrepareLayer"
	_timeLabel = CCLabelTTF:create(OlympicPrepareLayer.getTimeDes(0),g_sFontPangWa,21)
	_timeLabel:setColor(ccc3(0xff,0xff,0xff))
	_timeLabel:setAnchorPoint(ccp(0.5,0.5))
	_timeLabel:setPosition(385,134)
	topNode:addChild(_timeLabel)
	runTimeCountDownAction()


	local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	topNode:addChild(menu)

	-- --奖池按钮
	local rewardPoolButton = CCMenuItemImage:create("images/olympic/reward_pool_n.png","images/olympic/reward_pool_h.png")
	rewardPoolButton:setAnchorPoint(ccp(0, 0))
	rewardPoolButton:registerScriptTapHandler(rewardPoolButtonCallback)
	rewardPoolButton:setPosition(ccp(2 ,113))
	menu:addChild(rewardPoolButton)

	--擂台争霸奖励
	local olympicRewardButton = CCMenuItemImage:create("images/olympic/olympic_reward_n.png","images/olympic/olympic_reward_h.png")
	olympicRewardButton:setAnchorPoint(ccp(1, 0))
	olympicRewardButton:registerScriptTapHandler(olympicRewardButtonCallback)
	olympicRewardButton:setPosition(ccp(topNode:getContentSize().width - 2 ,123))
	menu:addChild(olympicRewardButton)

	--返回按钮
	local closeButton = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeButton:setAnchorPoint(ccp(1, 1))
	closeButton:registerScriptTapHandler(closeButtonCallFunc)
	closeButton:setPosition(ccp(topNode:getContentSize().width * 0.99 ,topNode:getContentSize().height * 0.99))
	menu:addChild(closeButton)

	local btMenu = BTMenu:create()
	btMenu:setPosition(0,0)
	btMenu:setStyle(kMenuRadio)
	topNode:addChild(btMenu)

	--A组按钮
	--local teamAButton = CCMenuItemImage:create("images/olympic/team_btn_n.png","images/olympic/team_btn_h.png")
	local teamAButton = createMenuItemWithLabel("images/olympic/team_btn_n.png","images/olympic/team_btn_h.png", GetLocalizeStringBy("zz_13",'A'))
	teamAButton:setAnchorPoint(ccp(0.5,0))
	teamAButton:setPosition(topNode:getContentSize().width*0.125, 20)
	teamAButton:registerScriptTapHandler(tapTeamBottonCb)
	btMenu:addChild(teamAButton,1,kGroupAButtonTag)

	--B组按钮
	local teamBButton = createMenuItemWithLabel("images/olympic/team_btn_n.png","images/olympic/team_btn_h.png", GetLocalizeStringBy("zz_13",'B'))
	teamBButton:setAnchorPoint(ccp(0.5,0))
	teamBButton:setPosition(topNode:getContentSize().width*0.375, 20)
	teamBButton:registerScriptTapHandler(tapTeamBottonCb)
	btMenu:addChild(teamBButton,1,kGroupBButtonTag)

	--C组按钮
	local teamCButton = createMenuItemWithLabel("images/olympic/team_btn_n.png","images/olympic/team_btn_h.png", GetLocalizeStringBy("zz_13",'C'))
	teamCButton:setAnchorPoint(ccp(0.5,0))
	teamCButton:setPosition(topNode:getContentSize().width*0.625, 20)
	teamCButton:registerScriptTapHandler(tapTeamBottonCb)
	btMenu:addChild(teamCButton,1,kGroupCButtonTag)

	--D组按钮
	local teamDButton = createMenuItemWithLabel("images/olympic/team_btn_n.png","images/olympic/team_btn_h.png", GetLocalizeStringBy("zz_13",'D'))
	teamDButton:setAnchorPoint(ccp(0.5,0))
	teamDButton:setPosition(topNode:getContentSize().width*0.875, 20)
	teamDButton:registerScriptTapHandler(tapTeamBottonCb)
	btMenu:addChild(teamDButton,1,kGroupDButtonTag)

	--选择默认按钮并获取该组所有参赛成员数据
	local olympicIndexOfCurrentUser = OlympicData.getOlympicIndexByUid(UserModel.getUserUid())
	print("olympicIndexOfCurrentUser", olympicIndexOfCurrentUser)
	--如果用户不在比赛中
	if olympicIndexOfCurrentUser == -1 then
		btMenu:setMenuSelected(teamAButton)
		OlympicData.setCurrentGroupId(kGroupAId)
	else
		local tempGroupId,tempHeadIconIndexTable = OlympicData.convertToUIIndex(olympicIndexOfCurrentUser)
		print("tempHeadIconIndexTable", tempGroupId)
		if tempGroupId == kGroupAId then
			btMenu:setMenuSelected(teamAButton)
			OlympicData.setCurrentGroupId(kGroupAId)
		elseif tempGroupId == kGroupBId then
			btMenu:setMenuSelected(teamBButton)
			OlympicData.setCurrentGroupId(kGroupBId)
		elseif tempGroupId == kGroupCId then
			btMenu:setMenuSelected(teamCButton)
			OlympicData.setCurrentGroupId(kGroupCId)
		elseif tempGroupId == kGroupDId then
			btMenu:setMenuSelected(teamDButton)
			OlympicData.setCurrentGroupId(kGroupDId)
		else
			error(string.format("Out of range [kGroupAId, kGroupDId], current team group id is %d",tempGroupId))
		end
	end

	--刷新顶部标识sprite
	-- refreshDescSpriteInTopUIByOlympicStage(OlympicData.getStage())
	if OlympicData.getStage() >= OlympicData.kSixteenStage and OlympicData.getStage() < OlympicData.kTwoStage then
		runDescSpriteEffectInTopUIByOlympicStage(OlympicData.getStage())
	end
end

--[[
	@des :	创建头像图标背景及对应晋级线集合
--]]
function createHeadIconBgTable()
	_headIconBgTable = {}
	for i = 1,kHeadIconBgNumber do
		local tempTable = {}
		tempTable.id = i

		--与服务器数据接口对应
		tempTable.uid = nil
		tempTable.uname = nil
		tempTable.htid = nil
		tempTable.dress = nil
		tempTable.vip = nil
		tempTable.olympicIndex = nil
		tempTable.promotionLevel = nil

		tempTable.headIconBg = CCSprite:create("images/everyday/headBg1.png")
		--背景方格中的文字("32强","8强"...)
		tempTable.headIconBgLabel = CCLabelTTF:create("",g_sFontPangWa,27)
		tempTable.headIconBgLabel:setColor(ccc3(0xd2,0xd2,0xcf))
		--参赛者名字
		tempTable.nameLabel = CCRenderLabel:create("", g_sFontPangWa, 18, 1, ccc3(0x00,0x00,0x00), type_shadow)
		tempTable.nameLabel:setColor(ccc3(0xff,0xff,0xff))
		tempTable.winSprite = CCSprite:create("images/olympic/win.png")
		tempTable.lostSprite = CCSprite:create("images/olympic/lost.png")
		
		if i <= 8 then
			--每组(ABCD)的八强
			tempTable.grayLine = CCSprite:create("images/olympic/line/downRightLine_gray.png")
			tempTable.lightLine = CCSprite:create("images/olympic/line/downRightLine_light.png")
			if i == 1 or i == 3 then
				--转线方向:下右
				tempTable.grayLine:setScaleY(0.6)
				tempTable.lightLine:setScaleY(0.6)
			elseif i == 2 or i == 4 then
				--转线方向:下左
				tempTable.grayLine:setScaleX(-1)
				tempTable.grayLine:setScaleY(0.6)
				tempTable.lightLine:setScaleX(-1)
				tempTable.lightLine:setScaleY(0.6)
			elseif i == 5 or i == 7 then
				--转线方向:上右
				tempTable.grayLine:setScaleY(-0.6)
				tempTable.lightLine:setScaleY(-0.6)
			else
				--转线方向:上左 (i = 6 or i = 8)
				tempTable.grayLine:setScaleX(-1)
				tempTable.grayLine:setScaleY(-0.6)
				tempTable.lightLine:setScaleX(-1)
				tempTable.lightLine:setScaleY(-0.6)
			end
		elseif i == 9 or i == 10 then
			--每组(ABCD)的二强
			tempTable.topGrayLine = CCSprite:create("images/olympic/line/horizontalLine_gray.png")
			tempTable.topGrayLine:setRotation(90)
			tempTable.topGrayLine:setScaleX(0.6)
			tempTable.topLightLine = CCSprite:create("images/olympic/line/horizontalLine_light.png")
			tempTable.topLightLine:setRotation(90)
			tempTable.topLightLine:setScaleX(0.6)

			tempTable.bottomGrayLine = CCSprite:create("images/olympic/line/horizontalLine_gray.png")
			tempTable.bottomGrayLine:setRotation(90)
			tempTable.bottomGrayLine:setScaleX(0.6)
			tempTable.bottomLightLine = CCSprite:create("images/olympic/line/horizontalLine_light.png")
			tempTable.bottomLightLine:setRotation(90)
			tempTable.bottomLightLine:setScaleX(0.6)

			tempTable.horizontalGrayLine = CCSprite:create("images/olympic/line/horizontalLine_gray.png")
			tempTable.horizontalLightLine = CCSprite:create("images/olympic/line/horizontalLine_light.png")
		else
			--每组冠军(i = 11)
			tempTable.descSprite = CCSprite:create("images/olympic/final4.png")
		end
		table.insert(_headIconBgTable, tempTable)
	end

	local function sortFunc(p_obj1, p_obj2)
		return p_obj1.id < p_obj2.id
	end
	table.sort(_headIconBgTable, sortFunc)
end

--[[
	@des :	根据指定索引初始化headIconBg中的状态数据
--]]
function initHeadiConBgTableByIndex(p_index)
	--与服务器数据接口对应
	_headIconBgTable[p_index].uid = nil
	_headIconBgTable[p_index].uname = nil
	_headIconBgTable[p_index].htid = nil
	_headIconBgTable[p_index].dress = nil
	_headIconBgTable[p_index].promotionLevel = nil
	_headIconBgTable[p_index].olympicIndex = nil
	_headIconBgTable[p_index].vip = nil
end

--[[
	@des :	初始化_headIconBgTable中的状态数据
--]]
function initHeadIconBgTableAll()
	for i = 1,kHeadIconBgNumber do 
		initHeadiConBgTableByIndex(i)
	end
end

--[[
	@des :	创建中部ui
--]]
function createCenterUI( teamBottonTag )
	local olympicMapNode = CCNode:create()
	olympicMapNode:setScale(MainScene.elementScale)
	olympicMapNode:setContentSize(kOlympicMapContentSize)
	olympicMapNode:setAnchorPoint(ccp(0.5,0.5))
	olympicMapNode:setPosition(_bgLayerContentSize.width/2, (_bgLayerContentSize.height-kTopUINodeContentSize.height*MainScene.elementScale-kBottomUINodeContentSize.height*MainScene.elementScale)/2+kBottomUINodeContentSize.height*MainScene.elementScale)
	_bgLayer:addChild(olympicMapNode)

	--创建headicon集合
	createHeadIconBgTable()

	--设置头像图标和晋级线的位置
	local tempTable = nil
	local tempPosition = nil
	for i = 1,kHeadIconBgNumber do
		tempTable = _headIconBgTable[i]
		tempPosition = kHeadIconBgPositionTable["position" .. i]

		--头像图标背景方格
		tempTable.headIconBg:setAnchorPoint(ccp(0.5,0.5))
		tempTable.headIconBg:setPosition(tempPosition)
		olympicMapNode:addChild(tempTable.headIconBg)

		--头像背景方格中的文字
		tempTable.headIconBgLabel:setAnchorPoint(ccp(0.5,0.5))
		tempTable.headIconBgLabel:setPosition(tempTable.headIconBg:getContentSize().width/2, tempTable.headIconBg:getContentSize().height/2)
		tempTable.headIconBg:addChild(tempTable.headIconBgLabel)

		--名字
		tempTable.nameLabel:setAnchorPoint(ccp(0.5,1))
		tempTable.nameLabel:setPosition(tempTable.headIconBg:getContentSize().width/2,5)
		tempTable.headIconBg:addChild(tempTable.nameLabel,1)

		--胜利图标
		tempTable.winSprite:setAnchorPoint(ccp(0,1))
		tempTable.winSprite:setPosition(0,tempTable.headIconBg:getContentSize().height)
		tempTable.headIconBg:addChild(tempTable.winSprite,1)

		--失败图标
		tempTable.lostSprite:setAnchorPoint(ccp(0,1))
		tempTable.lostSprite:setPosition(0,tempTable.headIconBg:getContentSize().height)
		tempTable.headIconBg:addChild(tempTable.lostSprite,1)


		if i <= 8 then
			tempTable.grayLine:setAnchorPoint(ccp(0,1))
			tempTable.headIconBg:addChild(tempTable.grayLine)
			tempTable.lightLine:setAnchorPoint(ccp(0,1))
			tempTable.headIconBg:addChild(tempTable.lightLine)
			if i <= 4 then
				tempTable.grayLine:setPosition(tempTable.headIconBg:getContentSize().width/2, 0)
				tempTable.lightLine:setPosition(tempTable.headIconBg:getContentSize().width/2, 0)
			else
				tempTable.grayLine:setPosition(tempTable.headIconBg:getContentSize().width/2, tempTable.headIconBg:getContentSize().height)
				tempTable.lightLine:setPosition(tempTable.headIconBg:getContentSize().width/2, tempTable.headIconBg:getContentSize().height)
			end
			--设置头像背景方格中的文字“32强”
			tempTable.headIconBgLabel:setString(GetLocalizeStringBy("zz_14",32))
		elseif i == 9 or i == 10 then
			tempTable.topGrayLine:setAnchorPoint(ccp(1,0.5))
			tempTable.topGrayLine:setPosition(tempTable.headIconBg:getContentSize().width/2, tempTable.headIconBg:getContentSize().height)
			tempTable.headIconBg:addChild(tempTable.topGrayLine)

			tempTable.topLightLine:setAnchorPoint(ccp(1,0.5))
			tempTable.topLightLine:setPosition(tempTable.headIconBg:getContentSize().width/2, tempTable.headIconBg:getContentSize().height)
			tempTable.headIconBg:addChild(tempTable.topLightLine)

			tempTable.bottomGrayLine:setAnchorPoint(ccp(0,0.5))
			tempTable.bottomGrayLine:setPosition(tempTable.headIconBg:getContentSize().width/2, 0)
			tempTable.headIconBg:addChild(tempTable.bottomGrayLine)

			tempTable.bottomLightLine:setAnchorPoint(ccp(0,0.5))
			tempTable.bottomLightLine:setPosition(tempTable.headIconBg:getContentSize().width/2,0)
			tempTable.headIconBg:addChild(tempTable.bottomLightLine)

			if i == 9 then
				tempTable.horizontalGrayLine:setAnchorPoint(ccp(0,0.5))
				tempTable.horizontalGrayLine:setPosition(tempTable.headIconBg:getContentSize().width, tempTable.headIconBg:getContentSize().height/2)
				tempTable.headIconBg:addChild(tempTable.horizontalGrayLine)

				tempTable.horizontalLightLine:setAnchorPoint(ccp(0,0.5))
				tempTable.horizontalLightLine:setPosition(tempTable.headIconBg:getContentSize().width, tempTable.headIconBg:getContentSize().height/2)
				tempTable.headIconBg:addChild(tempTable.horizontalLightLine)
			else
				tempTable.horizontalGrayLine:setAnchorPoint(ccp(1,0.5))
				tempTable.horizontalGrayLine:setPosition(0, tempTable.headIconBg:getContentSize().height/2)
				tempTable.headIconBg:addChild(tempTable.horizontalGrayLine)

				tempTable.horizontalLightLine:setAnchorPoint(ccp(1,0.5))
				tempTable.horizontalLightLine:setPosition(0, tempTable.headIconBg:getContentSize().height/2)
				tempTable.headIconBg:addChild(tempTable.horizontalLightLine)
			end
			--设置头像背景方格中的文字“8强”
			tempTable.headIconBgLabel:setString(GetLocalizeStringBy("zz_14",8))
		else
			-- i = 11
			tempTable.descSprite:setAnchorPoint(ccp(0.5,0.5))
			tempTable.descSprite:setPosition(tempTable.headIconBg:getContentSize().width/2, tempTable.headIconBg:getContentSize().height+25)
			tempTable.headIconBg:addChild(tempTable.descSprite)
			--设置头像背景方格中的文字“4强”
			tempTable.headIconBgLabel:setString(GetLocalizeStringBy("zz_14",4))
		end
	end

	--创建查看按钮
	local checkBtnMenu = CCMenu:create()
	checkBtnMenu:setPosition(0,0)
	olympicMapNode:addChild(checkBtnMenu)

	local tempTagTable = {
							kTopLeftCheckBtnTag, kTopRightCheckBtnTag, kBottomLeftCheckBtnTag, kBottomRightCheckBtnTag,
							kMiddleLeftCheckBtnTag, kMiddleRightCheckBtnTag, kMiddleCenterCheckBtnTag,
						 }
	_checkBtnTable = {}
	local nomalSprite = nil
	local selectedSprite = nil
	local disabledSprite = nil
	local checkMenuItem = nil
	for i = 1,kCheckBtnNumber do
		normalSprite = CCSprite:create("images/olympic/checkbutton/check_btn_n.png")
		selectedSprite = CCSprite:create("images/olympic/checkbutton/check_btn_h.png")
		disabledSprite = BTGraySprite:create("images/olympic/checkbutton/check_btn_n.png")
		checkMenuItem = CCMenuItemSprite:create(normalSprite,selectedSprite,disabledSprite)
		--checkMenuItem:setEnabled(false)
		checkMenuItem:registerScriptTapHandler(tapCheckBtnCb)
		checkMenuItem:setAnchorPoint(ccp(0.5,0.5))
		checkMenuItem:setPosition(kCheckBtnPositionTable["position" .. i])
		checkBtnMenu:addChild(checkMenuItem,1,tempTagTable[i])
		_checkBtnTable[i] = checkMenuItem
	end

	--刷新界面前将OlympicData中的数据更新到_headIconBgTable中
	updateHeadIconBgTableAll()

	refreshHeadIconBgAndPromotionLineAll()
	refreshCheckBtnAll()
end

--[[
	@des :	创建底部ui
--]]
function createBottomUI( ... )
	
	_bottomPanel = CCNode:create()
	_bottomPanel:setPosition(0.5 * _bgLayerContentSize.width, 0)
	_bottomPanel:setAnchorPoint(ccp(0.5, 0))
	_bottomPanel:setContentSize(kBottomUINodeContentSize)
	_bottomPanel:setScale(g_fScaleX)
	_bgLayer:addChild(_bottomPanel)


	local lineSprite = CCSprite:create("images/common/separator_bottom.png")
	lineSprite:setPosition(ccp(_bottomPanel:getContentSize().width * 0.5, _bottomPanel:getContentSize().height))
	lineSprite:setAnchorPoint(ccp(0.5, 0))
	_bottomPanel:addChild(lineSprite)

	local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	menu:setTouchPriority(kBottomMenuTouchPriority)
	_bottomPanel:addChild(menu)

	--活动说明按钮
	local explainButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(180,73), GetLocalizeStringBy("lcy_10048"), ccc3(255,222,0))
	explainButton:setAnchorPoint(ccp(0.5, 0.5))
	explainButton:registerScriptTapHandler(explainButtonCallback)
	explainButton:setPosition(ccp(_bottomPanel:getContentSize().width * 0.25 , _bottomPanel:getContentSize().height * 0.55))
	menu:addChild(explainButton)

	--战报按钮
	local battleReportButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(180,73), GetLocalizeStringBy("lcy_10052"), ccc3(255,222,0))
	battleReportButton:setAnchorPoint(ccp(0.5, 0.5))
	battleReportButton:registerScriptTapHandler(battleReportButtonCallback)
	battleReportButton:setPosition(ccp(_bottomPanel:getContentSize().width * 0.75 , _bottomPanel:getContentSize().height * 0.55))
	menu:addChild(battleReportButton)
end

--[[
	@des:	根据头像图标的位置索引刷新晋级线和左上角的胜负图标
	@param:
	@ret:
--]]
function refreshPromotionLineByIndex(p_headIconBgIndex)
	assert(p_headIconBgIndex > 0 and p_headIconBgIndex <= kHeadIconBgNumber)

	local tempTable = _headIconBgTable[p_headIconBgIndex]
	local enermyTable = _headIconBgTable[kEnermyMapTable[p_headIconBgIndex]]
	local tempOlympicStage = OlympicData.getStage()
	if p_headIconBgIndex <= 8 then
		if tempTable.uid ~= nil and tempTable.promotionLevel < kRankFinal32 then
				tempTable.grayLine:setVisible(false)
				tempTable.lightLine:setVisible(true)		
		else
			tempTable.grayLine:setVisible(true)
			tempTable.lightLine:setVisible(false)
		end

		
		if tempTable.uid ~= nil then 
			if enermyTable.uid ~= nil then
				if tempTable.promotionLevel == kRankFinal32 and enermyTable.promotionLevel == kRankFinal32 then
					tempTable.winSprite:setVisible(false)
					tempTable.lostSprite:setVisible(false)
				elseif tempTable.promotionLevel < kRankFinal32 and enermyTable.promotionLevel == kRankFinal32 then
					tempTable.winSprite:setVisible(true)
					tempTable.lostSprite:setVisible(false)
				elseif tempTable.promotionLevel == kRankFinal32 and enermyTable.promotionLevel < kRankFinal32 then
					tempTable.winSprite:setVisible(false)
					tempTable.lostSprite:setVisible(true)
				else
					print("promotion1................")
					print_t(tempTable)
					print("promotion2................")
					print_t(enermyTable)
					error("16 win/lost sprite error!")
				end
			else
				if tempTable.promotionLevel < kRankFinal32 then
					tempTable.winSprite:setVisible(true)
					tempTable.lostSprite:setVisible(false)
				else
					tempTable.winSprite:setVisible(false)
					tempTable.lostSprite:setVisible(false)
				end
			end
		else
			tempTable.winSprite:setVisible(false)
			tempTable.lostSprite:setVisible(false)
		end

	elseif p_headIconBgIndex == 9 then
		if tempTable.uid ~= nil then
			if tempTable.uid == _headIconBgTable[1].uid or tempTable.uid == _headIconBgTable[2].uid then
				tempTable.topGrayLine:setVisible(false)
				tempTable.topLightLine:setVisible(true)
				tempTable.bottomGrayLine:setVisible(true)
				tempTable.bottomLightLine:setVisible(false)
			elseif tempTable.uid == _headIconBgTable[5].uid or tempTable.uid == _headIconBgTable[6].uid then
				tempTable.topGrayLine:setVisible(true)
				tempTable.topLightLine:setVisible(false)
				tempTable.bottomGrayLine:setVisible(false)
				tempTable.bottomLightLine:setVisible(true)
			else
				error("9号格中的参赛者id不属于1、2、5、6号格参赛者id范围")
			end
		else
			tempTable.topGrayLine:setVisible(true)
			tempTable.topLightLine:setVisible(false)
			tempTable.bottomGrayLine:setVisible(true)
			tempTable.bottomLightLine:setVisible(false)
		end

	
		if tempTable.uid ~= nil then 
			if enermyTable.uid ~= nil then
				if tempTable.promotionLevel == kRankFinal8 and enermyTable.promotionLevel == kRankFinal8 then
					tempTable.winSprite:setVisible(false)
					tempTable.lostSprite:setVisible(false)
				elseif tempTable.promotionLevel < kRankFinal8 and enermyTable.promotionLevel == kRankFinal8 then
					tempTable.winSprite:setVisible(true)
					tempTable.lostSprite:setVisible(false)
				elseif tempTable.promotionLevel == kRankFinal8 and enermyTable.promotionLevel < kRankFinal8 then
					tempTable.winSprite:setVisible(false)
					tempTable.lostSprite:setVisible(true)
				else
					error("8 win/lost sprite error!")
				end
			else
				if tempTable.promotionLevel < kRankFinal8 then
					tempTable.winSprite:setVisible(true)
					tempTable.lostSprite:setVisible(false)
				else
					tempTable.winSprite:setVisible(false)
					tempTable.lostSprite:setVisible(false)
				end
			end
		else
			tempTable.winSprite:setVisible(false)
			tempTable.lostSprite:setVisible(false)
		end
	elseif p_headIconBgIndex == 10 then
		if tempTable.uid ~= nil then
			if tempTable.uid == _headIconBgTable[3].uid or tempTable.uid == _headIconBgTable[4].uid then
				tempTable.topGrayLine:setVisible(false)
				tempTable.topLightLine:setVisible(true)
				tempTable.bottomGrayLine:setVisible(true)
				tempTable.bottomLightLine:setVisible(false)
			elseif tempTable.uid == _headIconBgTable[7].uid or tempTable.uid == _headIconBgTable[8].uid then
				tempTable.topGrayLine:setVisible(true)
				tempTable.topLightLine:setVisible(false)
				tempTable.bottomGrayLine:setVisible(false)
				tempTable.bottomLightLine:setVisible(true)
			else
				error("10号格中的参赛者id不属于3、4、7、8号格参赛者id范围")
			end
		else
			tempTable.topGrayLine:setVisible(true)
			tempTable.topLightLine:setVisible(false)
			tempTable.bottomGrayLine:setVisible(true)
			tempTable.bottomLightLine:setVisible(false)
		end	

		if tempTable.uid ~= nil then 
			if enermyTable.uid ~= nil then
				if tempTable.promotionLevel == kRankFinal8 and enermyTable.promotionLevel == kRankFinal8 then
					tempTable.winSprite:setVisible(false)
					tempTable.lostSprite:setVisible(false)
				elseif tempTable.promotionLevel < kRankFinal8 and enermyTable.promotionLevel == kRankFinal8 then
					tempTable.winSprite:setVisible(true)
					tempTable.lostSprite:setVisible(false)
				elseif tempTable.promotionLevel == kRankFinal8 and enermyTable.promotionLevel < kRankFinal8 then
					tempTable.winSprite:setVisible(false)
					tempTable.lostSprite:setVisible(true)
				else
					error("8 win/lost sprite error!")
				end
			else
				if tempTable.promotionLevel < kRankFinal8 then
					tempTable.winSprite:setVisible(true)
					tempTable.lostSprite:setVisible(false)
				else
					tempTable.winSprite:setVisible(false)
					tempTable.lostSprite:setVisible(false)
				end
			end
		else
			tempTable.winSprite:setVisible(false)
			tempTable.lostSprite:setVisible(false)
		end
	else
		--p_headIconBgIndex = 11
		if tempTable.uid ~= nil then
			if tempTable.uid == _headIconBgTable[9].uid then
				_headIconBgTable[9].horizontalGrayLine:setVisible(false)
				_headIconBgTable[9].horizontalLightLine:setVisible(true)
				_headIconBgTable[10].horizontalGrayLine:setVisible(true)
				_headIconBgTable[10].horizontalLightLine:setVisible(false)
			elseif tempTable.uid == _headIconBgTable[10].uid then
				_headIconBgTable[9].horizontalGrayLine:setVisible(true)
				_headIconBgTable[9].horizontalLightLine:setVisible(false)
				_headIconBgTable[10].horizontalGrayLine:setVisible(false)
				_headIconBgTable[10].horizontalLightLine:setVisible(true)
			else
				error("11号格中的参赛者id不属于9、10号格参赛者id范围")
			end
		else
			_headIconBgTable[9].horizontalGrayLine:setVisible(true)
			_headIconBgTable[9].horizontalLightLine:setVisible(false)
			_headIconBgTable[10].horizontalGrayLine:setVisible(true)
			_headIconBgTable[10].horizontalLightLine:setVisible(false)
		end

		tempTable.winSprite:setVisible(false)
		tempTable.lostSprite:setVisible(false)
	end
end

--[[
	desc :	
--]]
function refreshHeadIconBgByIndex(p_index)
	local tempTable = _headIconBgTable[p_index]
	local enermyTable = _headIconBgTable[kEnermyMapTable[p_index]]
	print("refreshHeadIconBgByIndex")
	print_t(tempTable)
	print_t(enermyTable)
	if tempTable.uname ~= nil then
		tempTable.nameLabel:setString(tempTable.uname)

		if tonumber(tempTable.uid) == UserModel.getUserUid() then
			--若参赛者uid为当前用户，将字体颜色改为紫色
			tempTable.nameLabel:setColor(ccc3(0xff,0x00,0xe1))
		else
			--若参赛者uid不为当前用户，将字体颜色改为白色
			tempTable.nameLabel:setColor(ccc3(0xff,0xff,0xff))
		end
	else
		tempTable.nameLabel:setString("")
	end

	if tempTable.headIcon ~= nil then
		tempTable.headIcon:removeFromParentAndCleanup(true)
		tempTable.headIcon = nil
	end

	local headIcon = nil
	if tempTable.uid ~= nil then
		local dressId = tempTable.dress["1"]

		require "script/model/utils/HeroUtil"
		require "script/model/hero/HeroModel"
		--local tempOlympicStage = OlympicData.getStage()
		if p_index <= 8 then
				if enermyTable.promotionLevel ~= nil and enermyTable.promotionLevel < kRankFinal32 then
					local grayHeadIconImagePath = HeroUtil.getHeroIconImgByHTID(tempTable.htid, dressId)
					headIcon = BTGraySprite:create(grayHeadIconImagePath)
				else
					headIcon = HeroUtil.getHeroIconByHTID(tempTable.htid, dressId, HeroModel.getSex(tempTable.htid), tempTable.vip)
				end
		elseif p_index == 9 or p_index == 10 then
				if enermyTable.promotionLevel ~= nil and enermyTable.promotionLevel < kRankFinal8 then
					local grayHeadIconImagePath = HeroUtil.getHeroIconImgByHTID(tempTable.htid, dressId)
					headIcon = BTGraySprite:create(grayHeadIconImagePath)
				else
					headIcon = HeroUtil.getHeroIconByHTID(tempTable.htid, dressId, HeroModel.getSex(tempTable.htid), tempTable.vip)
				end
		elseif p_index == 11 then
			headIcon = HeroUtil.getHeroIconByHTID(tempTable.htid, dressId, HeroModel.getSex(tempTable.htid), tempTable.vip)
		else
			error(string.format("Out of range [1, %d], current head icon background index is %d", kHeadIconBgNumber, p_index))
		end
		headIcon:setAnchorPoint(ccp(0.5,0.5))
		headIcon:setPosition(tempTable.headIconBg:getContentSize().width/2,tempTable.headIconBg:getContentSize().height/2)
		tempTable.headIconBg:addChild(headIcon)
		tempTable.headIcon = headIcon
	end
end

function refreshHeadIconBgAndPromotionLineAll()
	for i = 1,kHeadIconBgNumber do 
		refreshHeadIconBgByIndex(i)
		refreshPromotionLineByIndex(i)
	end
end

--[[
	@des :	根据某个参赛者信息将其数据更新到对应的头像图标集合中
--]]
function updateHeadIconBgTableByParticipantInfo(p_parcitipantInfoTable)
	local headIconBgIndexTable = nil
	_,headIconBgIndexTable = OlympicData.convertToUIIndex(tonumber(p_parcitipantInfoTable.olympic_index))
	for k,index in pairs(headIconBgIndexTable) do
		_headIconBgTable[index].uid = p_parcitipantInfoTable.uid
		_headIconBgTable[index].uname = p_parcitipantInfoTable.uname
		_headIconBgTable[index].dress = p_parcitipantInfoTable.dress
		_headIconBgTable[index].htid = p_parcitipantInfoTable.htid
		_headIconBgTable[index].vip = tonumber(p_parcitipantInfoTable.vip)
		_headIconBgTable[index].olympicIndex = tonumber(p_parcitipantInfoTable.olympic_index)
		_headIconBgTable[index].promotionLevel = tonumber(p_parcitipantInfoTable.final_rank)
	end
end

--[[
	@des :	将当前小组的所有参赛者信息更新到对应的头像图标集合中
--]]
function updateHeadIconBgTableAll()
	--初始化_headIconBgTable中的状态数据
	initHeadIconBgTableAll()
	
	--require "script/ui/olympic/OlympicData"
	local currentGroupParticipantTable = OlympicData.getCurrentGroupAllParticipantTable()
	print("updateHeadIconBgTableAll")
	print_t(currentGroupParticipantTable)
	for _,v in pairs(currentGroupParticipantTable) do 
		updateHeadIconBgTableByParticipantInfo(v)
	end
end

--[[
	@des :	刷新指定索引战报查看蓝色按钮状态
--]]
function refreshCheckBtnByIndex(p_index)
	assert(p_index <= kCheckBtnNumber)

	if p_index <= 4 then
		if _headIconBgTable[p_index*2-1].uid == nil and _headIconBgTable[p_index*2].uid == nil then
			_checkBtnTable[p_index]:setEnabled(false)
		else
			if (_headIconBgTable[p_index*2-1].uid ~= nil and _headIconBgTable[p_index*2-1].promotionLevel < kRankFinal32) or
				(_headIconBgTable[p_index*2].uid ~= nil and _headIconBgTable[p_index*2].promotionLevel < kRankFinal32) then
				_checkBtnTable[p_index]:setEnabled(true)
			else
				_checkBtnTable[p_index]:setEnabled(false)
			end
		end
	elseif p_index == 5 then
		if _headIconBgTable[9].uid == nil then
			_checkBtnTable[p_index]:setEnabled(false)
		else
			if _headIconBgTable[9].promotionLevel < kRankFinal16 then
				_checkBtnTable[p_index]:setEnabled(true)
			else
				_checkBtnTable[p_index]:setEnabled(false)
			end
		end
	elseif p_index == 6 then
		if _headIconBgTable[10].uid == nil then
			_checkBtnTable[p_index]:setEnabled(false)
		else
			if _headIconBgTable[10].promotionLevel < kRankFinal16 then
				_checkBtnTable[p_index]:setEnabled(true)
			else
				_checkBtnTable[p_index]:setEnabled(false)
			end
		end
	else
		--p_index = 7
		if _headIconBgTable[11].uid == nil then
			_checkBtnTable[p_index]:setEnabled(false)
		else
			if _headIconBgTable[11].promotionLevel < kRankFinal8 then
				_checkBtnTable[p_index]:setEnabled(true)
			else
				_checkBtnTable[p_index]:setEnabled(false)
			end
		end
	end

end

--[[
	@des :	刷新所有战报查看蓝色按钮状态
--]]
function refreshCheckBtnAll()
	for i = 1,kCheckBtnNumber do 
		refreshCheckBtnByIndex(i)
	end
end

-- --[[

-- --]]
-- function refreshDescSpriteInTopUIByOlympicStage(p_StageIndex)
-- 	p_StageIndex = tonumber(p_StageIndex)
-- 	print("refreshDescSpriteInTopUIByOlympicStage",p_StageIndex)
-- 	if p_StageIndex == 3 then
-- 		_descSprite16:setVisible(true)
-- 		_descSprite8:setVisible(false)
-- 		_descSprite4:setVisible(false)
-- 	elseif p_StageIndex == 4 then
-- 		_descSprite16:setVisible(false)
-- 		_descSprite8:setVisible(true)
-- 		_descSprite4:setVisible(false)
-- 	elseif p_StageIndex == 5 then
-- 		_descSprite16:setVisible(false)
-- 		_descSprite8:setVisible(false)
-- 		_descSprite4:setVisible(true)
-- 	else
-- 		_descSprite16:setVisible(false)
-- 		_descSprite8:setVisible(false)
-- 		_descSprite4:setVisible(false)
-- 	end
-- end

--[[
	@des :	根据传入的头像索引返回排名最前的头像索引
	@param:	必须为小于等于kHeadIconBgNumber的正整数，如(1,2,3)
	@ret :	nil: 参数中的所有头像索引处均没有参赛者
			int: 排名最前的头像索引(当两个排名相同时返回首先获取的头像索引)
--]]
function getHeadIconBgIndexWithHigherPromotionLevel(...)	
	local tempPromotionLevel = nil
	local tempHeadIconBgIndex = nil
	local arg = {...}
	for k,v in ipairs(arg) do 
		assert(type(v) == "number" and v <= kHeadIconBgNumber)
		if _headIconBgTable[v].uid ~= nil then 	-- 剔除没有参赛者的头像索引
			--获得排名最前的头像索引
			if tempPromotionLevel == nil then
				tempPromotionLevel = _headIconBgTable[v].promotionLevel
				tempHeadIconBgIndex = v
			end

			if _headIconBgTable[v].promotionLevel < tempPromotionLevel then
				tempPromotionLevel = _headIconBgTable[v].promotionLevel
				tempHeadIconBgIndex = v
			end
		end
	end
	return tempHeadIconBgIndex
end
-------------------------------------------------[[ 动画效果 ]]---------------------------------------------------
--[[

--]]
function runWinAnimationByHeadIconBgIndex(p_index)
	local headIconBg = _headIconBgTable[tonumber(p_index)].headIconBg

	local  winEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/kuang/kuang"), -1, CCString:create(""))
	winEffectSprite:setScale(MainScene.elementScale)
	winEffectSprite:setAnchorPoint(ccp(0.5,0.5))
	winEffectSprite:setPosition(headIconBg:getContentSize().width/2,headIconBg:getContentSize().height/2)
	headIconBg:addChild(winEffectSprite,2)

	local animationDelegate = BTAnimationEventDelegate:create()
	winEffectSprite:setDelegate(animationDelegate)

	local function animationEndCb()
		winEffectSprite:retain()
		winEffectSprite:autorelease()
		winEffectSprite:removeFromParentAndCleanup(true)
	end

	local function animationChangedCb()

	end
	animationDelegate:registerLayerEndedHandler(animationEndCb)
	animationDelegate:registerLayerChangedHandler(animationChangedCb)
end

--[[
	@des :	用于比赛阶段推送中调用播放动画
--]]
function runWinAnimationByOlympicIndex(p_olympicIndex)
	p_olympicIndex = tonumber(p_olympicIndex)
	local tempGroupId,tempHeadIconBgIndexTable = OlympicData.convertToUIIndex(p_olympicIndex)

	--当推送的比赛位置不在当前组时不用播放动画
	if not OlympicData.isCurrentGroup(tempGroupId) then return end

	--方便定位获胜前的头像索引进行索引排序，并播放动画
	local function sortFunc(p_data1, p_data2)
		return tonumber(p_data1) > tonumber(p_data2)
	end
	table.sort(tempHeadIconBgIndexTable,sortFunc)

	local tempOlympicStage = OlympicData.getStage()
	if tempOlympicStage == OlympicData.kEightStage then
		runWinAnimationByHeadIconBgIndex(tempHeadIconBgIndexTable[1])
	elseif tempOlympicStage == OlympicData.kFourStage then
		runWinAnimationByHeadIconBgIndex(tempHeadIconBgIndexTable[2])
	elseif tempOlympicStage == OlympicData.kTwoStage then
		runWinAnimationByHeadIconBgIndex(tempHeadIconBgIndexTable[1])
	else

	end
end
--[[

--]]
function runStageChangeAnimationByOlympicStage(p_stageIndex, p_zOrder)
	p_stageIndex = tonumber(p_stageIndex)
	p_zOrder = p_zOrder and tonumber(p_zOrder) or 999
	local runningScene = CCDirector:sharedDirector():getRunningScene()

	local animationLayer = CCLayer:create()
	animationLayer:setScale(g_fScaleX)
	animationLayer:setContentSize(CCSizeMake(640,960))
	runningScene:addChild(animationLayer,p_zOrder)

	local separatorSprite = CCSprite:create("images/olympic/stage_animation/separator.png")
	separatorSprite:setAnchorPoint(ccp(0.5,0.5))
	separatorSprite:setPosition(320,480)
	animationLayer:addChild(separatorSprite)

	local leftSpriteImagePath = nil
	if p_stageIndex == OlympicData.kSixteenStage then
		leftSpriteImagePath = "images/olympic/stage_animation/16qiang_left.png"
	elseif p_stageIndex == OlympicData.kEightStage then
		leftSpriteImagePath = "images/olympic/stage_animation/8qiang_left.png"
	elseif p_stageIndex == OlympicData.kFourStage then
		leftSpriteImagePath = "images/olympic/stage_animation/4qiang_left.png"
	elseif p_stageIndex == OlympicData.kOneStage then
		leftSpriteImagePath = "images/olympic/stage_animation/guanjun_left.png"
	else
		error(string.format("Stage change animation do not support stage %d!",p_stageIndex))
	end

	local leftSprite = CCSprite:create(leftSpriteImagePath)
	leftSprite:setAnchorPoint(ccp(1,0.5))
	leftSprite:setPosition(0,500)
	animationLayer:addChild(leftSprite)
	leftSprite:runAction(CCMoveTo:create(0.2,ccp(360, 500)))

	local rightSprite = CCSprite:create("images/olympic/stage_animation/zhengba_right.png")
	rightSprite:setAnchorPoint(ccp(0,0.5))
	rightSprite:setPosition(640,460)
	animationLayer:addChild(rightSprite)
	local function rightAnimationEndCb()
		separatorSprite:runAction(CCFadeOut:create(0.5))
		leftSprite:runAction(CCFadeOut:create(0.5))

		local function rightSpriteFadeOutActionCb()
			animationLayer:removeFromParentAndCleanup(true)
		end
		local layerActionSequence = CCSequence:createWithTwoActions(CCFadeOut:create(0.5),CCCallFunc:create(rightSpriteFadeOutActionCb))
		rightSprite:runAction(layerActionSequence)
	end
	local rightActionSequence = CCSequence:createWithTwoActions(CCMoveTo:create(0.2,ccp(340,460)), CCCallFunc:create(rightAnimationEndCb))
	rightSprite:runAction(rightActionSequence)
end

--[[

--]]
function runDescSpriteEffectInTopUIByOlympicStage( p_olympicStageIndex)
	p_olympicStageIndex = tonumber(p_olympicStageIndex)
	local effectPath = nil
	-- local tempNode = nil
	if p_olympicStageIndex == OlympicData.kSixteenStage then
		effectPath = "images/base/effect/shiliuqiang/shiliuqiang"
		-- tempNode = _descSprite16
	elseif p_olympicStageIndex == OlympicData.kEightStage then
		effectPath = "images/base/effect/baqiang/baqiang"
		-- tempNode = _descSprite8
	elseif p_olympicStageIndex == OlympicData.kFourStage then
		effectPath = "images/base/effect/siqiang/siqiang"
		-- tempNode = _descSprite4
	else
		error(string.format("Out of range {%d, %d, %d}, current olympic stage is %d",OlympicData.kSixteenStage,OlympicData.kEightStage,OlympicData.kFourStage,p_olympicStageIndex))
	end

	_descSpriteInTopUI:removeAllChildrenWithCleanup(true)

	local descSpriteWithEffect = CCLayerSprite:layerSpriteWithName(CCString:create(effectPath), -1, CCString:create(""))
	descSpriteWithEffect:setAnchorPoint(ccp(0.5,0.5))
	descSpriteWithEffect:setPosition(_descSpriteInTopUI:getContentSize().width*0.5,_descSpriteInTopUI:getContentSize().height*0.5)
	_descSpriteInTopUI:addChild(descSpriteWithEffect)

	local animationDelegate = BTAnimationEventDelegate:create()
	descSpriteWithEffect:setDelegate(animationDelegate)

	local function animationEndCb()
		-- descSpriteWithEffect:retain()
		-- descSpriteWithEffect:autorelease()
		-- descSpriteWithEffect:removeFromParentAndCleanup(true)
	end

	local function animationChangedCb()

	end
	animationDelegate:registerLayerEndedHandler(animationEndCb)
	animationDelegate:registerLayerChangedHandler(animationChangedCb)
end
-------------------------------------------------[[ 推送处理 ]]---------------------------------------------------
--[[
	@des :	处理推送某个比赛位置时的界面更新(该函数调用前OlympicData中对应比赛位置的排名已更新)
--]]
function refreshUIByOlympicIndex(p_olympicIndex)
	p_olympicIndex = tonumber(p_olympicIndex)
	local tempGroupId,tempHeadIconBgIndexTable = OlympicData.convertToUIIndex(p_olympicIndex)

	--当推送的比赛位置不在当前组时不用更新界面
	if not OlympicData.isCurrentGroup(tempGroupId) then return end

	--更新数据
	local tempParticipantInfoTable = OlympicData.getUserInfoByOlympicIndex(p_olympicIndex)
	updateHeadIconBgTableByParticipantInfo(tempParticipantInfoTable)

	--方便定位获胜前的头像索引进行索引排序，并播放动画
	local function sortFunc(p_data1, p_data2)
		return tonumber(p_data1) > tonumber(p_data2)
	end
	table.sort(tempHeadIconBgIndexTable,sortFunc)
	local tempOlympicStage = OlympicData.getStage()
	if tempOlympicStage == OlympicData.kSixteenStage then
		runWinAnimationByHeadIconBgIndex(tempHeadIconBgIndexTable[1])
	elseif tempOlympicStage == OlympicData.kEightStage or tempOlympicStage == OlympicData.kFourStage then
		runWinAnimationByHeadIconBgIndex(tempHeadIconBgIndexTable[2])
	elseif tempOlympicStage == OlympicData.kTwoStage then
		runWinAnimationByHeadIconBgIndex(tempHeadIconBgIndexTable[1])
	else

	end

	for k,v in pairs(tempHeadIconBgIndexTable) do
		--刷新头像图标
		refreshHeadIconBgByIndex(v)

		--刷新晋级线
		refreshPromotionLineByIndex(v)
	end
end

--[[
	des :	处理推送多个比赛位置时的界面更新(该函数调用前OlympicData中对应比赛位置的排名已更新)
--]]
function refreshUIByOlympicIndexTable(p_olympicIndexTable)
	print("refreshUIByOlympicIndexTable")
	print_t(p_olympicIndexTable)
	for k,v in pairs(p_olympicIndexTable) do
		refreshUIByOlympicIndex(v)
	end

	--刷新所有checkBtn
	refreshCheckBtnAll()
end

--[[
	@des :	处理推送获得比赛阶段时的界面更新(该函数调用前OlympicData中对应比赛位置的排名已更新)
--]]
function refreshUIByOlympicStage(p_stageIndex)
	-- --更新顶部UI中的比赛描述
	-- refreshDescSpriteInTopUIByOlympicStage(p_stageIndex)

	--比赛阶段变化动画
	if OlympicData.getStage() >= OlympicData.kSixteenStage and OlympicData.getStage() < OlympicData.kTwoStage then
		--更新顶部UI中的比赛描述
		runDescSpriteEffectInTopUIByOlympicStage(p_stageIndex)

		runStageChangeAnimationByOlympicStage(p_stageIndex, kStageChangeAnimationLayerZOrder)
	end

	--更新——headIconBgTable所有数据
	updateHeadIconBgTableAll()
	
	--本阶段倒计时开始
	runTimeCountDownAction()

	--刷新头像和晋级线
	refreshHeadIconBgAndPromotionLineAll()

	--获胜头像处播放的动画
	local olympicIndexTableWithoutEnemy = OlympicData.getOlympicIndexTableWithoutEnemy()
	print("refreshUIByOlympicStage")
	print_t(olympicIndexTableWithoutEnemy)
	for k,v in pairs(olympicIndexTableWithoutEnemy) do
		runWinAnimationByOlympicIndex(v)
	end

	--刷新查看按钮
	refreshCheckBtnAll()
end
-------------------------------------------------[[ 回调事件 ]]-------------------------------------------------

--[[
	@des : 	奖池按钮回调
--]]
function rewardPoolButtonCallback( ... )
	require "script/ui/olympic/AwardPoolLayer"
	AwardPoolLayer.showLayer()
end

--[[
	@des : 	擂台争霸奖励
--]]
function olympicRewardButtonCallback( ... )
	require "script/ui/olympic/rewardPreview/OlympicRewardLayer"
	OlympicRewardLayer.showLayer()
end

--[[
	@des :	点击A、B、C、D组按钮的回调
--]]
function tapTeamBottonCb( tag, item )
	if tag == kGroupAButtonTag then
		OlympicData.setCurrentGroupId(kGroupAId)
	elseif tag == kGroupBButtonTag then
		OlympicData.setCurrentGroupId(kGroupBId)	
	elseif tag == kGroupCButtonTag then
		OlympicData.setCurrentGroupId(kGroupCId)
	else
		OlympicData.setCurrentGroupId(kGroupDId)
	end

	updateHeadIconBgTableAll()
	refreshHeadIconBgAndPromotionLineAll()
	refreshCheckBtnAll()
end

--[[
	@des :	点击蓝色圆形查看按钮的回调(按钮的开启条件)
--]]
function tapCheckBtnCb(tag, item)
	local tempHeadIconBgIndex = nil
	local tempOlympicIndex1 = nil
	local tempOlympicIndex2 = nil
	if tag == kTopLeftCheckBtnTag then
		tempOlympicIndex1 = _headIconBgTable[1].olympicIndex
		tempOlympicIndex2 = _headIconBgTable[2].olympicIndex
	elseif tag == kTopRightCheckBtnTag then
		tempOlympicIndex1 = _headIconBgTable[3].olympicIndex
		tempOlympicIndex2 = _headIconBgTable[4].olympicIndex
	elseif tag == kBottomLeftCheckBtnTag then
		tempOlympicIndex1 = _headIconBgTable[5].olympicIndex
		tempOlympicIndex2 = _headIconBgTable[6].olympicIndex
	elseif tag == kBottomRightCheckBtnTag then
		tempOlympicIndex1 = _headIconBgTable[7].olympicIndex
		tempOlympicIndex2 = _headIconBgTable[8].olympicIndex
	elseif tag == kMiddleLeftCheckBtnTag then
		tempHeadIconBgIndex = getHeadIconBgIndexWithHigherPromotionLevel(1,2)
		if tempHeadIconBgIndex == nil then 	--在头像位置为1，2处均无参赛者
			tempOlympicIndex1 = nil
		else
			tempOlympicIndex1 = _headIconBgTable[tempHeadIconBgIndex].olympicIndex
		end

		tempHeadIconBgIndex = getHeadIconBgIndexWithHigherPromotionLevel(5,6)
		if tempHeadIconBgIndex == nil then 	--在头像位置为5，6处均无参赛者
			tempOlympicIndex2 = nil
		else
			tempOlympicIndex2 = _headIconBgTable[tempHeadIconBgIndex].olympicIndex
		end
	elseif tag == kMiddleRightCheckBtnTag then
		tempHeadIconBgIndex = getHeadIconBgIndexWithHigherPromotionLevel(3,4)
		if tempHeadIconBgIndex == nil then 	--在头像位置为3，4处均无参赛者
			tempOlympicIndex1 = nil
		else
			tempOlympicIndex1 = _headIconBgTable[tempHeadIconBgIndex].olympicIndex
		end

		tempHeadIconBgIndex = getHeadIconBgIndexWithHigherPromotionLevel(7,8)
		if tempHeadIconBgIndex == nil then 	--在头像位置为7，8处均无参赛者
			tempOlympicIndex2 = nil
		else
			tempOlympicIndex2 = _headIconBgTable[tempHeadIconBgIndex].olympicIndex
		end
	else
		-- tag = kMiddleCenterCheckBtnTag
		tempOlympicIndex1 = _headIconBgTable[9].olympicIndex
		tempOlympicIndex2 = _headIconBgTable[10].olympicIndex
	end

	--没有对手直接晋级时的处理
	require "script/ui/tip/SingleTip"
	if tempOlympicIndex1 == nil or tempOlympicIndex2 == nil then
		SingleTip.showSingleTip(GetLocalizeStringBy("zz_128"))
		return
	end

	local reportId = OlympicData.getReportIdByOlympicPos(tempOlympicIndex1, tempOlympicIndex2)

	--还没战报时的处理
	if reportId == nil then
		SingleTip.showSingleTip(GetLocalizeStringBy("zz_129"))
		return
	end

	require "script/battle/BattleUtil"
	--该函数集成了下面的回调方法
	BattleUtil.playerBattleReportById(reportId)

	-- --RequestCenter.battle_getRecord
	-- --BattleLayer.showBattleWithString(dictData.ret,nil,nil,nil,nil,nil,nil,nil,true)
	-- local function battleReportCb(cbFlag, dictData, bRet)
	-- 	if dictData.err ~= "ok" then return end
	-- 	BattleLayer.showBattleWithString(dictData.ret,nil,nil,nil,nil,nil,nil,nil,true)
	-- end
	-- args = CCArray:create()
	-- args:addObject(CCInteger:create(tonumber(reportId)))
	-- RequestCenter.battle_getRecord(battleReportCb, args)
end

--[[
	@des : 	关闭按钮回调
--]]
function closeButtonCallFunc( ... )
	local function leaveCb()
		require "script/ui/active/ActiveList"
		local  activeList = ActiveList.createActiveListLayer()
		MainScene.changeLayer(activeList, "activeList")
	end
	if OlympicData.getStage() <= 5 then
		OlympicService.leave(leaveCb)
	else
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
		require "script/ui/olympic/Olympic4Layer"
		Olympic4Layer.show()
	end
end

--[[
	@des : 	活动说明按钮
--]]
function explainButtonCallback( ... )
	print("活动说明按钮")
	require "script/ui/olympic/ExplainDialog"
	ExplainDialog.show(-3000)
end

--[[
	@des : 查看战报
--]]
function battleReportButtonCallback( ... )
	require "script/ui/olympic/battleReport/CheckBattleReportLayer"
	CheckBattleReportLayer.showLayer(kBattleReportPanelTouchPriority)
end

--[[
	@des : 擂台争霸阶段变化推送
--]]
function stageChangePushCallback( p_StageIndex )
	
	if(p_StageIndex == 1 or p_StageIndex == 2 ) then
		require "script/ui/olympic/OlympicRegisterLayer"
		OlympicRegisterLayer.show()
	elseif(p_StageIndex >= 3 and p_StageIndex < 6) then
		refreshUIByOlympicStage(p_StageIndex)
	elseif(p_StageIndex >= 6) then
		if(MainScene.getOnRunningLayerSign() == "Olympic32Layer") then
			require "script/ui/olympic/Olympic4Layer"
			Olympic4Layer.show()
		end
	else
		require "script/ui/tip/AnimationTip"
    	AnimationTip.showTip(GetLocalizeStringBy("zz_130"))
	end
	
end
