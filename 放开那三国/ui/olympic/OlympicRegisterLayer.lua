-- Filename: OlympicRegisterLayer.lua
-- Author: lichenyang
-- Date: 2014-07-14
-- Purpose: 擂台争霸报名界面

require "script/utils/BaseUI"
require "script/ui/olympic/OlympicService"
require "script/battle/BattleUtil"
module("OlympicRegisterLayer",package.seeall)

------------------------------[[ 模块常量 ]]------------------------------
local kReporTypeAll 	  = 1
local kReporTypeSelf      = 2

------------------------------[[ 模块变量 ]]------------------------------
local _bgLayer               = nil
local _timeString            = nil
local _reportScrollView      = nil
local _challengeTimeLabel    = nil
local _bottomPanel           = nil
local _myStatusLabel         = nil
local _stationArray          = nil
local _stationScrollview     = nil
local _nowStageEndTime       = nil
local _reportInfos           = nil
local _reportType            = nil
local _challengeTime         = nil
local _challengeGoldNumLabel = nil
local _startGroupLabel 		 = nil
local _isLoading 			 = nil
function init( ... )
	_bgLayer                  = nil
	_timeString               = nil
	_reportScrollView         = nil
	_challengeTimeLabel       = nil
	_bottomPanel 		  	  = nil
	_myStatusLabel 	  		  = nil
	_stationScrollview  	  = nil
	_stationArray			  = {}
	_nowStageEndTime 	  	  = nil
	_reportInfos			  = {}
	_reportType         	  = nil
	_challengeTime      	  = nil
	_challengeGoldNumLabel    = nil
	_startGroupLabel 		  = nil
	_isLoading 			 	  = nil
end

------------------------------------[[ ui 创建方法 ]]-----------------------------------------

--[[
	@des : 显示擂台争霸场景
--]]
function show( ... )
    local layer = OlympicRegisterLayer.createLayer()
    MainScene.changeLayer(layer, "OlympicRegisterLayer")
end


--[[
	@des : 创建擂台争霸准备场景
--]]
function createLayer( ... )
	init()
	_bgLayer = CCLayer:create()
	local bgSprite = CCSprite:create("images/olympic/playoff_bg.jpg")
	bgSprite:setAnchorPoint(ccp(0.5, 0))
	bgSprite:setPosition(ccps(0.5, 0))
	bgSprite:setScale(g_fBgScaleRatio)
	_bgLayer:addChild(bgSprite)
	
	MainScene.setMainSceneViewsVisible(false, false, false)
	_layerSize              = {width= 0, height=0}
	_layerSize.width        = g_winSize.width 
	_layerSize.height       =g_winSize.height
	_bgLayer:setContentSize(CCSizeMake(_layerSize.width, _layerSize.height))
	OlympicService.getInfo(function ( ... )
		crateTopUI()
		createBottomUI()
		createCenterUI()
		OlympicService.registerSignupPush(signupPushCallback)
		OlympicService.regisgerStagechangePush(stageChangePushCallback)
		OlympicService.registerChallengeBattlePush(battleRecordPushCallback)
		schedule(_bgLayer, updateTimeFunc, 1)
		_isLoading = true
	end)
	return _bgLayer
end

--[[
	@des : 	创建顶部ui
--]]
function crateTopUI( ... )
	local topNode = CCNode:create()
	topNode:setAnchorPoint(ccp(0.5,1))
	topNode:setContentSize(CCSizeMake(640, 225))
	topNode:setPosition(ccp(_layerSize.width*0.5, g_winSize.height))
	_bgLayer:addChild(topNode)
	topNode:setScale(g_fScaleX)

	local lineSprite = CCSprite:create("images/copy/fort/top_cutline.png")
	lineSprite:setPosition(ccp(topNode:getContentSize().width * 0.5, 0))
	lineSprite:setAnchorPoint(ccp(0.5, 0))
	topNode:addChild(lineSprite)


	_bgLayer:setContentSize(CCSizeMake(_layerSize.width, _layerSize.height - topNode:getContentSize().height * g_fScaleX))
	_layerSize = CCSizeMake(_layerSize.width, _layerSize.height - topNode:getContentSize().height * g_fScaleX)

	local titleBg = CCSprite:create("images/olympic/title_bg.png")
	titleBg:setAnchorPoint(ccp(0.5, 1))
	titleBg:setPosition(ccpsprite(0.5, 1, topNode))
	topNode:addChild(titleBg)

	local titleSprite = CCSprite:create("images/olympic/title.png")
	titleSprite:setAnchorPoint(ccp(0.5, 1))
	titleSprite:setPosition(ccpsprite(0.5, 1, topNode))
	topNode:addChild(titleSprite)

	local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	topNode:addChild(menu)

	--奖池按钮
	local rewardPoolButton = CCMenuItemImage:create("images/olympic/reward_pool_n.png","images/olympic/reward_pool_h.png")
	rewardPoolButton:setAnchorPoint(ccp(0.5, 0))
	rewardPoolButton:registerScriptTapHandler(rewardPoolButtonCallback)
	rewardPoolButton:setPosition(ccp(topNode:getContentSize().width * 0.1 ,topNode:getContentSize().height * 0.1))
	menu:addChild(rewardPoolButton)
	--rewardPoolButton:setScale(MainScene.elementScale)

	--擂台争霸奖励
	local olympicRewardButton = CCMenuItemImage:create("images/olympic/olympic_reward_n.png","images/olympic/olympic_reward_h.png")
	olympicRewardButton:setAnchorPoint(ccp(0.5, 0))
	olympicRewardButton:registerScriptTapHandler(olympicRewardButtonCallback)
	olympicRewardButton:setPosition(ccp(topNode:getContentSize().width * 0.9 ,topNode:getContentSize().height * 0.1))
	menu:addChild(olympicRewardButton)

	--返回按钮
	local closeButton = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeButton:setAnchorPoint(ccp(1, 1))
	closeButton:registerScriptTapHandler(closeButtonCallFunc)
	closeButton:setPosition(ccp(topNode:getContentSize().width * 0.99 ,topNode:getContentSize().height * 0.99))
	menu:addChild(closeButton)



	_nowStageEndTime = OlympicData.getStageNowEndTime() - BTUtil:getSvrTimeInterval()
	if(_nowStageEndTime <0) then
		_nowStageEndTime = 0
	end

	local timeDes = CCRenderLabel:create( GetLocalizeStringBy("lcy_50041") , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	timeDes:setColor(ccc3(0x00,0xff,0x18))
	local timeBg = CCSprite:create("images/olympic/time_bg.png")
	_timeString = CCLabelTTF:create(getTimeDes(_nowStageEndTime), g_sFontPangWa, 21)
	_timeString:setAnchorPoint(ccp(0.5, 0.5))
	_timeString:setPosition(ccpsprite(0.5, 0.5, timeBg))
	timeBg:addChild(_timeString)
	desNodeTable = {timeDes,timeBg}
	
	_desTimeNode = BaseUI.createHorizontalNode(desNodeTable)
	_desTimeNode:setAnchorPoint(ccp(0.5, 0))
	_desTimeNode:setPosition(ccpsprite(0.5, 0.1, topNode))
	topNode:addChild(_desTimeNode)

	--阶段标题
	local stageTitle = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/sanshierqiang/sanshierqiang"), -1,CCString:create(""))
	stageTitle:setAnchorPoint(ccp(0.5, 1))
	stageTitle:setPosition(ccpsprite(0.5, 0, titleBg))
	titleBg:addChild(stageTitle)

	_startGroupLabel = CCRenderLabel:create( GetLocalizeStringBy("lcy_50035") , g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_startGroupLabel:setAnchorPoint(ccp(0.5, 0))
	_startGroupLabel:setPosition(ccpsprite(0.5, 0.1, topNode))
	topNode:addChild(_startGroupLabel)
	_startGroupLabel:setVisible(false)
	_startGroupLabel:setColor(ccc3(0x00,0xff,0x18))
	if(_nowStageEndTime <= 0) then
		_desTimeNode:setVisible(false)
		_startGroupLabel:setVisible(true)
	end

	
end


--[[
	@des :	创建中部ui
--]]
function createCenterUI( ... )
	local myStatusDesLabel = CCRenderLabel:create( GetLocalizeStringBy("lcy_50002") , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	myStatusDesLabel:setPosition(ccp(10*MainScene.elementScale, _layerSize.height))
	myStatusDesLabel:setAnchorPoint(ccp(0, 1))
	_bgLayer:addChild(myStatusDesLabel)
	myStatusDesLabel:setScale(MainScene.elementScale)

	_myStatusLabel = CCLabelTTF:create( GetLocalizeStringBy("lcy_50003") , g_sFontPangWa, 21)
	_myStatusLabel:setPosition(ccp(10*MainScene.elementScale +myStatusDesLabel:getContentSize().width*MainScene.elementScale, _layerSize.height))
	_myStatusLabel:setAnchorPoint(ccp(0, 1))
	_bgLayer:addChild(_myStatusLabel)
	_myStatusLabel:setColor(ccc3(0x00, 0xff, 0x18))
	_myStatusLabel:setScale(MainScene.elementScale)
	updateUserStatus()

	local registerStatusDesLabel = CCRenderLabel:create( GetLocalizeStringBy("lcy_50019") , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	registerStatusDesLabel:setPosition(ccp(_layerSize.width - 200*MainScene.elementScale, _layerSize.height))
	registerStatusDesLabel:setAnchorPoint(ccp(0, 1))
	_bgLayer:addChild(registerStatusDesLabel)
	registerStatusDesLabel:setScale(MainScene.elementScale)

	_registerStatusLabel = CCLabelTTF:create( OlympicData.getUserCount() .. "/32", g_sFontName, 21)
	_registerStatusLabel:setPosition(ccp(registerStatusDesLabel:getPositionX() + registerStatusDesLabel:getContentSize().width*MainScene.elementScale, _layerSize.height))
	_registerStatusLabel:setAnchorPoint(ccp(0, 1))
	_bgLayer:addChild(_registerStatusLabel)
	_registerStatusLabel:setColor(ccc3(0x00, 0xff, 0x18))
	_registerStatusLabel:setScale(MainScene.elementScale)


	_stationScrollview = CCScrollView:create()
	_stationScrollview:setViewSize(CCSizeMake(_layerSize.width - 14, _layerSize.height -_bottomPanel:getContentSize().height * g_fScaleX - myStatusDesLabel:getContentSize().height * g_fScaleX))
	_stationScrollview:setPosition(ccp(0, _bottomPanel:getContentSize().height * g_fScaleX))
	_stationScrollview:setContentSize(CCSizeMake(_layerSize.width - 14, 165*8*g_fScaleX))
	_stationScrollview:setDirection(kCCScrollViewDirectionVertical)
	_stationScrollview:setTouchPriority(-450)
	_bgLayer:addChild(_stationScrollview)
	_stationScrollview:setContentOffset(ccp(0, _stationScrollview:getViewSize().height - _stationScrollview:getContentSize().height))
	
	for i=1,8 do
		local rowNode = CCNode:create()
		rowNode:setContentSize(CCSizeMake(640, 165))
		rowNode:setAnchorPoint(ccp(0, 0))
		rowNode:setScale(g_fScaleX)
		rowNode:setPosition(ccp(0 ,_stationScrollview:getContentSize().height - i*165*g_fScaleX))
		_stationScrollview:addChild(rowNode)
		for j=1,4 do
			local taiziSprite = CCSprite:create("images/olympic/shan_tanzi.png")
			taiziSprite:setAnchorPoint(ccp(0.5, 0))
			taiziSprite:setPosition(ccpsprite(0.125 + (j-1)*0.25, 0, rowNode))
			rowNode:addChild(taiziSprite)
			table.insert(_stationArray, taiziSprite)
		end
	end
	for i=1,32 do
		updateStation(i)
	end
	updateTimeFunc()
end

--[[
	@des :	创建底部ui
--]]
function createBottomUI( ... )
	
	_bottomPanel = CCNode:create()
	_bottomPanel:setPosition(0.5 * _layerSize.width, 0)
	_bottomPanel:setAnchorPoint(ccp(0.5, 0))
	_bottomPanel:setContentSize(CCSizeMake(630, 310))
	_bottomPanel:setScale(g_fScaleX)
	_bgLayer:addChild(_bottomPanel)


	local lineSprite = CCSprite:create("images/copy/fort/top_cutline.png")
	lineSprite:setPosition(ccp(_bottomPanel:getContentSize().width * 0.5, _bottomPanel:getContentSize().height))
	lineSprite:setAnchorPoint(ccp(0.5, 0))
	lineSprite:setScaleY(-1)
	_bottomPanel:addChild(lineSprite)

	local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	_bottomPanel:addChild(menu)

	--活动说明按钮
	local explainButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(180,73), GetLocalizeStringBy("lcy_10048"), ccc3(255,222,0))
	explainButton:setAnchorPoint(ccp(0.5, 0.5))
	explainButton:registerScriptTapHandler(explainButtonCallback)
	explainButton:setPosition(ccp(_bottomPanel:getContentSize().width * 0.25 , 210))
	menu:addChild(explainButton)


	--清除时间
	local norSprite = CCScale9Sprite:create("images/common/btn/btn1_d.png")
    norSprite:setContentSize(CCSizeMake(240, 73))
    local higSprite = CCScale9Sprite:create("images/common/btn/btn1_n.png")
    higSprite:setContentSize(CCSizeMake(240, 73))
    local clearTimeButton = CCMenuItemSprite:create(norSprite, higSprite)
	clearTimeButton:setAnchorPoint(ccp(0.5, 0.5))
	clearTimeButton:registerScriptTapHandler(clearTimeButtonCallback)
	clearTimeButton:setPosition(ccp(_bottomPanel:getContentSize().width * 0.75 , 210))
    menu:addChild(clearTimeButton)

	local clearWorldLable = CCRenderLabel:create(GetLocalizeStringBy("lcy_10051"), g_sFontPangWa,33,1,ccc3( 0x00, 0x00, 0x00), type_stroke)
    clearWorldLable:setColor(ccc3(0xfe,0xdb,0x1c))
    clearWorldLable:setAnchorPoint(ccp(0.5,0.5))
    clearWorldLable:setPosition(ccp(clearTimeButton:getContentSize().width*0.5,clearTimeButton:getContentSize().height*0.5))

    local goldIcon = CCSprite:create("images/common/gold.png")

    _challengeGoldNumLabel = CCRenderLabel:create("0", g_sFontPangWa,18,1,ccc3( 0x00, 0x00, 0x00), type_stroke )
    _challengeGoldNumLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))

    local clearDesNode = BaseUI.createHorizontalNode({clearWorldLable, goldIcon, _challengeGoldNumLabel})
    clearDesNode:setAnchorPoint(ccp(0.5, 0.5))
    clearDesNode:setPosition(clearTimeButton:getContentSize().width *0.5, clearTimeButton:getContentSize().height * 0.5)
    clearTimeButton:addChild(clearDesNode,10,1)

    --挑战时间
    _challengeTime = OlympicData.getLastChallengeCD() --得到上次cd时间

    local challengeDes = CCRenderLabel:create(GetLocalizeStringBy("lcy_50004"), g_sFontPangWa,21,1,ccc3( 0x00, 0x00, 0x00), type_stroke )
    challengeDes:setColor(ccc3(0xff, 0x00, 0x00))
    challengeDes:setPosition(ccp(351, 270))
    challengeDes:setAnchorPoint(ccp(0, 0.5))
    _bottomPanel:addChild(challengeDes)

    _challengeTimeLabel = CCLabelTTF:create("00:00:00", g_sFontPangWa, 21)
    _challengeTimeLabel:setPosition(ccp(challengeDes:getPositionX() + challengeDes:getContentSize().width, 270))
    _challengeTimeLabel:setAnchorPoint(ccp(0, 0.5))
    _bottomPanel:addChild(_challengeTimeLabel)

    createReportPanel(_bottomPanel)
    
end

function createReportPanel( p_parentNode )
	
	local panel = CCScale9Sprite:create("images/common/s9_4.png")
	panel:setContentSize(CCSizeMake(630, 135))
	panel:setAnchorPoint(ccp(0.5, 0))
	panel:setPosition(ccpsprite(0.5, 0, p_parentNode))
	p_parentNode:addChild(panel)

	local btMenu = BTMenu:create()
	btMenu:setPosition(ccp(0, 0))
	btMenu:setAnchorPoint(ccp(0, 0))
	btMenu:setStyle(kMenuRadio)
	p_parentNode:addChild(btMenu)

	
	local image_n = "images/common/bg/button/ng_tab_n.png"
	local image_h = "images/common/bg/button/ng_tab_h.png"
	--整体战报
	local norSprite = CCScale9Sprite:create(image_n, CCRectMake(0, 0, 63, 43), CCRectMake(29, 18, 4, 1))
	norSprite:setContentSize(CCSizeMake(190, 43))
	local higSprite = CCScale9Sprite:create(image_h, CCRectMake(0, 0, 73, 53), CCRectMake(34, 25, 4, 1))
	higSprite:setContentSize(CCSizeMake(190, 53))

	local allReportButton = CCMenuItemSprite:create(norSprite, higSprite)
	allReportButton:setPosition(ccp(10, panel:getContentSize().height))
	allReportButton:setAnchorPoint(ccp(0, 0))
	allReportButton:registerScriptTapHandler(allReportButtonCallback)
	btMenu:addChild(allReportButton)

	local allReportButtonDes = CCRenderLabel:create( GetLocalizeStringBy("lcy_50005") , g_sFontPangWa, 28, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	allReportButtonDes:setAnchorPoint(ccp(0.5, 0.5))
	allReportButtonDes:setPosition(ccpsprite(0.5, 0.5, allReportButton))
	allReportButton:addChild(allReportButtonDes)
	--个人战报
	local norSprite = CCScale9Sprite:create(image_n, CCRectMake(0, 0, 63, 43), CCRectMake(29, 18, 4, 1))
	norSprite:setContentSize(CCSizeMake(190, 43))
	local higSprite = CCScale9Sprite:create(image_h, CCRectMake(0, 0, 73, 53), CCRectMake(34, 25, 4, 1))
	higSprite:setContentSize(CCSizeMake(190, 53))


	local selfReportButton = CCMenuItemSprite:create(norSprite, higSprite)
	selfReportButton:setPosition(ccp(allReportButton:getContentSize().width + 11, panel:getContentSize().height))
	selfReportButton:setAnchorPoint(ccp(0, 0))
	selfReportButton:registerScriptTapHandler(selfReportButtonCallback)
	btMenu:addChild(selfReportButton)
	local selfReportButtonDes = CCRenderLabel:create( GetLocalizeStringBy("lcy_50006") , g_sFontPangWa, 28, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	selfReportButtonDes:setAnchorPoint(ccp(0.5, 0.5))
	selfReportButtonDes:setPosition(ccpsprite(0.5, 0.5, allReportButton))
	selfReportButton:addChild(selfReportButtonDes)

	btMenu:setMenuSelected(allReportButton)
	_reportType = kReporTypeAll

	_reportScrollView = CCScrollView:create()
	_reportScrollView:setViewSize(CCSizeMake(panel:getContentSize().width - 14, panel:getContentSize().height - 5))
	_reportScrollView:setPosition(ccp(0, 0))
	_reportScrollView:setContentSize(CCSizeMake(panel:getContentSize().width - 14, panel:getContentSize().height))
	_reportScrollView:setDirection(kCCScrollViewDirectionVertical)
	_reportScrollView:setTouchPriority(-450)
	panel:addChild(_reportScrollView)
	_reportScrollView:setContentOffset(ccp(0, _reportScrollView:getViewSize().height - _reportScrollView:getContentSize().height))

	_reportInfos = OlympicData.getAllBattleReportInfo()
	updateReportScrollview()

end

------------------------------------------------[[ 更新ui 方法]]----------------------------------------

--[[
	@des : 定时器
--]]
function updateTimeFunc( ... )
	if(_timeString) then
		_nowStageEndTime = _nowStageEndTime - 1
		if(_nowStageEndTime <=0) then
			_nowStageEndTime = 0
			_desTimeNode:setVisible(false)
			_startGroupLabel:setVisible(true)
		end
		local str1,str2 = getTimeDes(_nowStageEndTime)
		_timeString:setString(str1)
	end

	if(_challengeTimeLabel) then
		_challengeTime = _challengeTime - 1
		if(_challengeTime <=0) then
			_challengeTime = 0
		end
		local str1,str2 = getTimeDes(_challengeTime)
		_challengeTimeLabel:setString(str2)
	end

	_challengeGoldNumLabel:setString(OlympicData.getClearChallgeCDCostByTime(_challengeTime))
	_registerStatusLabel:setString(OlympicData.getUserCount() .. "/32")
end



--[[
	@des:	更新报名位置状态
--]]
function updateStation( p_signPos)

	print("updateStation", p_signPos)
	local stationInfo = OlympicData.getUserInfoBySignPos(p_signPos-1)
	local stationSprite = _stationArray[p_signPos]
	stationSprite:removeAllChildrenWithCleanup(true)

	if(stationInfo == nil) then
		--空位置（参赛）
		local graySprit = CCSprite:create("images/olympic/gray_role.png") 
		graySprit:setAnchorPoint(ccp(0.5, 0))
		graySprit:setPosition(ccpsprite(0.5, 0.2, stationSprite))
		stationSprite:addChild(graySprit)

		local btMenu = BTMenu:create()
		btMenu:setAnchorPoint(ccp(0,0))
		btMenu:setPosition(ccp(0,0))
		stationSprite:addChild(btMenu)
		btMenu:setScrollView(_stationScrollview)

		local registerButton = CCMenuItemImage:create("images/olympic/cansai_n.png", "images/olympic/cansai_h.png")
		registerButton:setAnchorPoint(ccp(0.5, 0.5))
		registerButton:setPosition(ccpsprite(0.5, 0.5, stationSprite))
		registerButton:registerScriptTapHandler(registerButtonCallback)
		btMenu:addChild(registerButton, 1, p_signPos)

	elseif(tonumber(stationInfo.uid) == UserModel.getUserUid()) then
		--玩家自己报名位置
		local iconBg = CCSprite:create("images/olympic/touxiang.png")
		iconBg:setAnchorPoint(ccp(0.5, 0.5))
		iconBg:setPosition(ccpsprite(0.5, 0.6, stationSprite))
		stationSprite:addChild(iconBg)

		local userHeadIcon = HeroUtil.getHeroIconByHTID( UserModel.getAvatarHtid() ,UserModel.getDressIdByPos(1), UserModel.getUserSex(), UserModel.getVipLevel())
		userHeadIcon:setAnchorPoint(ccp(0.5, 0.5))
		userHeadIcon:setPosition(ccpsprite(0.5, 0.5, iconBg))
		iconBg:addChild(userHeadIcon)

		local userName = CCRenderLabel:create( UserModel.getUserName(), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		userName:setPosition(ccpsprite(0.5, 0.1, iconBg))
		userName:setAnchorPoint(ccp(0.5, 1))
		iconBg:addChild(userName)
		userName:setColor(ccc3(0xff,0x00,0xe1))
	else
		--其他玩家位置（报名）
		local btMenu = BTMenu:create()
		btMenu:setAnchorPoint(ccp(0,0))
		btMenu:setPosition(ccp(0,0))
		stationSprite:addChild(btMenu)
		btMenu:setScrollView(_stationScrollview)

		local challengeButton = CCMenuItemImage:create("images/arena/challenge_normal.png", "images/arena/challenge_select.png")
		challengeButton:setAnchorPoint(ccp(0.5, 0.5))
		challengeButton:setPosition(ccpsprite(0.5, 0.5, stationSprite))
		challengeButton:registerScriptTapHandler(challengeButtonCallback)
		btMenu:addChild(challengeButton, 1, p_signPos)
		challengeButton:setScale(0.85)
	end
end


function updateReportScrollview( ... )
	_reportScrollView:getContainer():removeAllChildrenWithCleanup(true)

	local selfReportNum = 0
	for i,v in ipairs(_reportInfos) do
		if(_reportType == kReporTypeSelf) then
			if(tonumber(v.attacker) == UserModel.getUserUid() or tonumber(v.defender) == UserModel.getUserUid()) then
				selfReportNum = selfReportNum + 1
			end
		end
	end

	if(_reportType == kReporTypeSelf) then
		_reportScrollView:setContentSize(CCSizeMake(_reportScrollView:getContentSize().width, selfReportNum * 25))
	else
		_reportScrollView:setContentSize(CCSizeMake(_reportScrollView:getContentSize().width, #_reportInfos * 25))
	end
	_reportScrollView:setContentOffset(ccp(0, _reportScrollView:getViewSize().height - _reportScrollView:getContentSize().height))
	
	local selfReportNum = 0
	local showTableInfo = table.reverse(_reportInfos)
	for i,v in ipairs(showTableInfo) do
		if(_reportType == kReporTypeAll) then
			local battleDesLabel = createReportDesNode(v)
			battleDesLabel:setPosition(15, _reportScrollView:getContentSize().height - i*25)
			battleDesLabel:setAnchorPoint(ccp(0 ,0))
			_reportScrollView:addChild(battleDesLabel)
		elseif(_reportType == kReporTypeSelf) then
			if(tonumber(v.attacker) == UserModel.getUserUid() or tonumber(v.defender) == UserModel.getUserUid()) then
				selfReportNum = selfReportNum + 1
				local battleDesLabel = createReportDesNode(v)
				battleDesLabel:setPosition(15, _reportScrollView:getContentSize().height - selfReportNum*25)
				battleDesLabel:setAnchorPoint(ccp(0 ,0))
				_reportScrollView:addChild(battleDesLabel)
			end
		end
	end
end

--[[
	@des: 更新报名状态
--]]
function updateUserStatus( ... )
	if(OlympicData.isUserRegister(UserModel.getUserUid()) == true) then
		_myStatusLabel:setString(GetLocalizeStringBy("zzh_1172"))
	else
		_myStatusLabel:setString(GetLocalizeStringBy("lcy_50003"))
	end
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
	@des : 	关闭按钮回调
--]]
function closeButtonCallFunc( ... )

	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	local requestCallback = function ( ... )
		require "script/ui/active/ActiveList"
		local  activeList = ActiveList.createActiveListLayer()
		MainScene.changeLayer(activeList, "activeList")
	end
	OlympicService.leave(requestCallback)
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
	@des : 清除cd按钮
--]]
function clearTimeButtonCallback( ... )
	print("清除cd按钮")
	if(_challengeTime <= 0) then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lcy_50007"))
		return
	end

	if(OlympicData.isUserRegister(UserModel.getUserUid()) == true) then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lcy_50040"))
		return
	end

	--判断当前金币是否够用
	if(OlympicData.getClearChallgeCDCostByTime(_challengeTime) > UserModel.getGoldNumber()) then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lcy_50045"))
		return
	end

	local requestCallback = function ( p_spendGold )
		print("clearTimeButtonCallback ok")
		AnimationTip.showTip(GetLocalizeStringBy("lcy_50008") .. p_spendGold .. GetLocalizeStringBy("key_10193"))
		_challengeTime = 0
	end
	OlympicService.clearChallengeCd(requestCallback)
end

--[[
	@des : 查看整体战报
--]]
function allReportButtonCallback( ... )
	_reportType = kReporTypeAll
	updateReportScrollview()
end

--[[
	@des : 个人战报
--]]
function selfReportButtonCallback( ... )
	_reportType = kReporTypeSelf
	updateReportScrollview()
end

--[[
	@des : 报名按钮回调
--]]
function registerButtonCallback( tag, sender )

	--当前位置是否已经有人报名
	if(OlympicData.getUserInfoBySignPos(tag-1) ~= nil) then
		require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("lcy_50030"))
		return
	end

	--是否已经报名
	if(OlympicData.isUserRegister( UserModel.getUserUid() )) then
		require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("lcy_50009"))
		return
	end

	--是否有足够的银币getJoinCostSilver
	if(OlympicData.getJoinCostSilver() > UserModel.getSilverNumber() )  then
		require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("lcy_50010"))
		return
	end
	--需要判断下报名结束时间，阶段推送会延迟
	local registerEndTime = tonumber(OlympicData.getInfo().timeConf.signStartTime) + tonumber(OlympicData.getInfo().timeConf.signDuration)
	if(OlympicData.getStage() == OlympicData.kGroupStage and BTUtil:getSvrTimeInterval() <= registerEndTime) then
		require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("lcy_50020"))
        return
	end
	require "script/ui/olympic/ApplyOlympicDialog"
	ApplyOlympicDialog.showTipLayer( OlympicData.getJoinCostSilver(),function ( ... )
		OlympicService.signUp(tag-1, nil)
		_challengeTime = 0
	end)
end

--[[
	@des : 挑战按钮回调
--]]
function challengeButtonCallback( tag, sender )
	--是否已经报名
	if(OlympicData.isUserRegister( UserModel.getUserUid() )) then
		require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("lcy_50011"))
		return
	end

	if(OlympicData.getChallengeCostSilver() > UserModel.getSilverNumber() )  then
		print("OlympicData.getChallengeCostSilver()", OlympicData.getChallengeCostSilver())
		print("UserModel.getSilverNumber()", UserModel.getSilverNumber())
		require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("lcy_50012"))
		return
	end

	if(_challengeTime >0 )  then
		print("OlympicData.getChallengeCostSilver()", OlympicData.getChallengeCostSilver())
		print("UserModel.getSilverNumber()", UserModel.getSilverNumber())
		require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("lcy_50013"))
		return
	end
	--是否已经报名
	if(OlympicData.isUserRegister( UserModel.getUserUid() )) then
		require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("lcy_50031"))
		return
	end
	--需要判断下报名结束时间，阶段推送会延迟
	local registerEndTime = tonumber(OlympicData.getInfo().timeConf.signStartTime) + tonumber(OlympicData.getInfo().timeConf.signDuration)
	if(OlympicData.getStage() == OlympicData.kGroupStage and BTUtil:getSvrTimeInterval() <= registerEndTime) then
		require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("lcy_50039"))
        return
	end

	local requestCallback = function ( fightData )
		--重置挑战时间
		_challengeTime = OlympicData.getChallengeCDTime()
		--刷新报名位置玩家
		updateStation(tag)
		--更新报名状态
		updateUserStatus()
		--播放战斗
		local amf3_obj = Base64.decodeWithZip(fightData)
		local lua_obj = amf3.decode(amf3_obj)
		require "script/ui/guild/city/VisitorBattleLayer"
        local fightDate = {}
     	fightDate.server = lua_obj
     	require "script/battle/BattleLayer"
      	local visitor_battle_layer = VisitorBattleLayer.createAfterBattleLayer(fightDate)
	   	BattleLayer.showBattleWithString(fightData, nil, visitor_battle_layer,nil,nil,nil,nil,nil,true)
	end

	require "script/ui/olympic/ChallengeOlympicDialog"
	ChallengeOlympicDialog.showTipLayer( OlympicData.getChallengeCostSilver(),function ( ... )
		OlympicService.challenge(tag-1, requestCallback)
	end)
end

--[[
	@des : 玩家报名推送回调
--]]
function signupPushCallback( p_pos )
	if(_isLoading) then
		updateStation(p_pos + 1)
		updateUserStatus()
	end
end

--[[
	@des : 擂台争霸阶段变化推送
--]]
function stageChangePushCallback( p_StageIndex )
	if(MainScene.getOnRunningLayerSign() ~= "OlympicRegisterLayer") then
		return
	end
	local stageIndex = p_StageIndex

	if(stageIndex == 1) then
		require "script/ui/olympic/OlympicRegisterLayer"
		OlympicRegisterLayer.show()
	elseif(stageIndex >= 3 and stageIndex < 6) then
		print("stageChangePushCallback call Olympic32Layer layer", stageIndex)
		require "script/ui/olympic/Olympic32Layer"
		Olympic32Layer.show()
	elseif(stageIndex >= 6) then
		require "script/ui/olympic/Olympic4Layer"
		Olympic4Layer.show()
	end
end

function battleRecordPushCallback( p_olympicIndexs, p_battleReports )
	for k,v in pairs(p_battleReports) do
		table.insert(_reportInfos, v)
	end
	for i=1,32 do
		updateStation(i)
	end
	updateUserStatus()
	updateReportScrollview()
end

-------------------------------------[[ 工具方法 ]]------------------------------------------


function getTimeDes( p_timeInterval )
	local hour = math.floor(p_timeInterval/3600)
	local min  = math.floor((p_timeInterval - hour*3600)/60)
	local sec  = p_timeInterval - hour*3600 - 60*min
	local ret1 = string.format("%02d",hour) .. "  :  " .. string.format("%02d",min) .. "  :  ".. string.format("%02d",sec)
	local ret2 = string.format("%02d",hour) .. ":" .. string.format("%02d",min) .. ":".. string.format("%02d",sec)
	return ret1, ret2
end

function createReportDesNode( p_battleInfo )
	
	local attackerName = p_battleInfo.attackerName
	local defenderName = p_battleInfo.defenderName
	local reportId     = tonumber(p_battleInfo.brid)
	print("createReportDesNode reportId", reportId)
	
	local label1 = CCLabelTTF:create(attackerName, g_sFontName, 21)
	label1:setColor(ccc3(0x00, 0xe4, 0xff))
	local label2 = CCLabelTTF:create(GetLocalizeStringBy("lcy_50014"), g_sFontName, 21)
	label2:setColor(ccc3(0xff, 0x00, 0x00))
	local label3 = CCLabelTTF:create(defenderName, g_sFontName, 21)
	label3:setColor(ccc3(0x00, 0xe4, 0xff))
	local label4 = CCLabelTTF:create(GetLocalizeStringBy("lcy_50015"), g_sFontName, 21)
	label4:setColor(ccc3(0x00, 0xe4, 0xff))
	local label5 = CCLabelTTF:create(GetLocalizeStringBy("lcy_50016"), g_sFontName, 21)
	label5:setColor(ccc3(0xff, 0x60, 0x00))
	local label6 = CCLabelTTF:create(GetLocalizeStringBy("lcy_50017"), g_sFontName, 21)
	label6:setColor(ccc3(0x00, 0xe4, 0xff))

	local reportLabel = CCLabelTTF:create(GetLocalizeStringBy("lcy_50018"), g_sFontName, 21)
	reportLabel:setColor(ccc3(0x00, 0xff, 0x18))
	local label7 = CCMenuItemLabel:create(reportLabel)
	label7:setTag(reportId)
	label7:setUserObject(CCInteger:create(reportId))
	label7:registerScriptTapHandler(BattleUtil.playerBattleReportById)
	local desNode =  BaseUI.createHorizontalNode({label1,label2,label3,label4,label5,label6,label7}, -450)

	if(string.upper(p_battleInfo.result) == "F" or string.upper(p_battleInfo.result) == "E") then
		attackerName = p_battleInfo.defenderName
		defenderName = p_battleInfo.attackerName

		local label10 = CCLabelTTF:create(attackerName, g_sFontName, 21)
		label10:setColor(ccc3(0x00, 0xe4, 0xff))
		local label20 = CCLabelTTF:create(GetLocalizeStringBy("lcy_50034"), g_sFontName, 21)
		label20:setColor(ccc3(0xff, 0x00, 0x00))
		local label30 = CCLabelTTF:create(defenderName, g_sFontName, 21)
		label30:setColor(ccc3(0x00, 0xe4, 0xff))
		local label40 = CCLabelTTF:create(GetLocalizeStringBy("lcy_50017"), g_sFontName, 21)
		label6:setColor(ccc3(0x00, 0xe4, 0xff))
		
		local reportLabel = CCLabelTTF:create(GetLocalizeStringBy("lcy_50018"), g_sFontName, 21)
		reportLabel:setColor(ccc3(0x00, 0xff, 0x18))
		local label70 = CCMenuItemLabel:create(reportLabel)
		label70:setTag(reportId)
		label70:setUserObject(CCInteger:create(reportId))
		label70:registerScriptTapHandler(BattleUtil.playerBattleReportById)
		desNode = BaseUI.createHorizontalNode({label10,label20,label30,label70}, -450)
	end

	return desNode
end

