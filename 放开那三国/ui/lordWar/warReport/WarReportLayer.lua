-- FileName: WarReportLayer.lua 
-- Author: Zhang Zihang
-- Date: 2014/8/4
-- Purpose: 跨服战战报界面

module("WarReportLayer", package.seeall)

require "script/audio/AudioUtil"
require "script/model/user/UserModel"
require "script/ui/lordWar/LordWarData"
require "script/utils/BaseUI"
require "script/ui/main/MainScene"

local _touchPriority
local _zOrder
local _bgLayer
local _battleInfo
local _fInfo
local _sInfo
local _fWin
local _sWin
local _isInner
local _isNoReport
local _heroInfo

----------------------------------------初始化函数----------------------------------------
local function init()
	_touchPriority = nil
	_zOrder = nil
	_bgLayer = nil
	_battleInfo = nil
	_fInfo = nil
	_sInfo = nil
	_fWin = nil
	_sWin = nil
	_isInner = nil
	_isNoReport = false
	_heroInfo = {}
end

----------------------------------------触摸事件函数----------------------------------------
local function onTouchesHandler(eventType,x,y)
	if (eventType == "began") then
	    return true
	elseif (eventType == "moved") then
		print("moved")
	else
	    print("end")
	end
end

local function onNodeEvent(event)
	if event == "enter" then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
		_bgLayer:setTouchEnabled(true)
	elseif eventType == "exit" then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

----------------------------------------回调函数----------------------------------------
--[[
	@des 	:关闭按钮回调
	@param 	:
	@return :
--]]
function closeCallBack()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

----------------------------------------UI函数----------------------------------------
--[[
	@des 	:创建背景UI
	@param 	:
	@return :
--]]
function createBgUI()
	--处理显示比分和胜负方数据
    local firstInfo = {}
    local secondInfo = {}
    local atkWinNum,defWinNum 
    if _fInfo ~= nil then
    	firstInfo = _fInfo
    	secondInfo = _sInfo
    	atkWinNum = _fWin
    	defWinNum = _sWin
    elseif _isNoReport then
    	firstInfo = _heroInfo.hero_1
    	secondInfo = _heroInfo.hero_2
    	atkWinNum = 0
    	defWinNum = 0
    else
    	firstInfo,secondInfo,atkWinNum,defWinNum = dealData()
    end

	--背景图
	local bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
	bgSprite:setContentSize(CCSizeMake(600,755))
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setScale(MainScene.elementScale)
	bgSprite:setPosition(ccp(_bgLayer:getContentSize().width/2,_bgLayer:getContentSize().height/2))
	_bgLayer:addChild(bgSprite)

	--标题背景
	local titleSprite = CCSprite:create("images/common/viewtitle1.png")
	titleSprite:setAnchorPoint(ccp(0.5,0.5))
	titleSprite:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height - 6))
	bgSprite:addChild(titleSprite)

	--标题
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3414"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff,0xe4,0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titleSprite:getContentSize().width/2,titleSprite:getContentSize().height/2))
	titleSprite:addChild(titleLabel)

	--二级背景
	local secondSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	secondSprite:setContentSize(CCSizeMake(555,560))
	secondSprite:setAnchorPoint(ccp(0.5,1))
	secondSprite:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height - 95))
	bgSprite:addChild(secondSprite)

	--如果服内
	require "db/DB_Heroes"
	local ANameLabel = CCRenderLabel:create(firstInfo.uname,g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	ANameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(DB_Heroes.getDataById(tonumber(firstInfo.htid)).potential))
	ANameLabel:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:addChild(ANameLabel)
	local AServerLabel = CCRenderLabel:create("(" .. firstInfo.serverName .. ")",g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_stroke)
	AServerLabel:setColor(ccc3(0xff,0xff,0xff))
	AServerLabel:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:addChild(AServerLabel)
	
	local scoreLabel = CCRenderLabel:create(atkWinNum .. ":" .. defWinNum,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
	scoreLabel:setColor(ccc3(0x00,0xff,0x18))
	scoreLabel:setAnchorPoint(ccp(0.5,0.5))
	scoreLabel:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height - 60))
	bgSprite:addChild(scoreLabel)

	local DNameLabel = CCRenderLabel:create(secondInfo.uname,g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	DNameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(DB_Heroes.getDataById(tonumber(secondInfo.htid)).potential))
	DNameLabel:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:addChild(DNameLabel)
	local DServerLabel = CCRenderLabel:create("(" .. secondInfo.serverName .. ")",g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_stroke)
	DServerLabel:setColor(ccc3(0xff,0xff,0xff))
	DServerLabel:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:addChild(DServerLabel)
	if _isInner then
		ANameLabel:setPosition(ccp(150,bgSprite:getContentSize().height - 60))
		AServerLabel:setVisible(false)
		DNameLabel:setPosition(ccp(bgSprite:getContentSize().width - 150,bgSprite:getContentSize().height - 60))
		DServerLabel:setVisible(false)
	else
		ANameLabel:setPosition(ccp(150,bgSprite:getContentSize().height - 50))
		AServerLabel:setPosition(150,bgSprite:getContentSize().height - 70)
		DNameLabel:setPosition(ccp(bgSprite:getContentSize().width - 150,bgSprite:getContentSize().height - 50))
		DServerLabel:setPosition(bgSprite:getContentSize().width - 150,bgSprite:getContentSize().height - 70)
	end

	--攻方（服务器名字） 几比几 守方（服务器名字）
	-- local ANameLabel = CCRenderLabel:create(firstInfo.uname,g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	-- ANameLabel:setColor(ccc3(0xff,0xf6,0x00))
	-- local AServerLabel = CCRenderLabel:create("(" .. firstInfo.serverName .. ")",g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_stroke)
	-- AServerLabel:setColor(ccc3(0xff,0xff,0xff))
	-- local scoreLabel = CCRenderLabel:create(atkWinNum .. ":" .. defWinNum,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
	-- scoreLabel:setColor(ccc3(0x00,0xff,0x18))
	-- local DNameLabel = CCRenderLabel:create(secondInfo.uname,g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	-- DNameLabel:setColor(ccc3(0xff,0xf6,0x00))
	-- local DServerLabel = CCRenderLabel:create("(" .. secondInfo.serverName .. ")",g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_stroke)
	-- DServerLabel:setColor(ccc3(0xff,0xff,0xff))

	-- local upNode = BaseUI.createHorizontalNode({ANameLabel,AServerLabel,scoreLabel,DNameLabel,DServerLabel})
	-- upNode:setAnchorPoint(ccp(0.5,0.5))
	-- upNode:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height - 60))
	-- bgSprite:addChild(upNode)

	--背景按钮层
	local bgMenu = CCMenu:create()
	bgMenu:setPosition(ccp(0,0))
	bgMenu:setAnchorPoint(ccp(0,0))
	bgMenu:setTouchPriority(_touchPriority - 3)
	bgSprite:addChild(bgMenu)

	--关闭按钮
	local closeMenuItem = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeMenuItem:setPosition(ccp(bgSprite:getContentSize().width*1.03,bgSprite:getContentSize().height*1.03))
    closeMenuItem:setAnchorPoint(ccp(1,1))
    closeMenuItem:registerScriptTapHandler(closeCallBack)
    bgMenu:addChild(closeMenuItem)

    --确定按钮
    local sureMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1985"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	sureMenuItem:setAnchorPoint(ccp(0.5,0))
    sureMenuItem:setPosition(ccp(bgSprite:getContentSize().width*0.5,30))
    sureMenuItem:registerScriptTapHandler(closeCallBack)
	bgMenu:addChild(sureMenuItem)

    --创建tableView
    require "script/ui/lordWar/warReport/WarTableView"
    local innerTableView
    if _isNoReport == false then
	    innerTableView = WarTableView.createTableView(_battleInfo,firstInfo,secondInfo,_isInner)
	    innerTableView:setAnchorPoint(ccp(0,0))
	    innerTableView:setPosition(ccp(0,0))
	    innerTableView:setTouchPriority(_touchPriority - 1)
	    secondSprite:addChild(innerTableView)
	else
		innerTableView = WarTableView.createOneTableView(firstInfo,secondInfo,_isInner)
	    innerTableView:setAnchorPoint(ccp(0,0))
	    innerTableView:setPosition(ccp(0,0))
	    innerTableView:setTouchPriority(_touchPriority - 1)
	    secondSprite:addChild(innerTableView)
	end
end

----------------------------------------入口函数----------------------------------------
function showLayer(p_battleInfo,p_touchPriority,p_zOrder,p_stage,p_firstInfo,p_secondInfo,p_firstWin,p_secondWin,p_heroInfo)
	init()

	_isInner = p_stage

	_touchPriority = p_touchPriority or -550
	_zOrder = p_zOrder or 999

	print("=============战报数据")
	print_t(p_battleInfo)
	print("=============英雄信息")
	print_t(p_heroInfo)

	_isNoReport = false
	if table.isEmpty(p_battleInfo) then
		_isNoReport = true
		_heroInfo = p_heroInfo
	else
		_battleInfo = p_battleInfo

		_fInfo = p_firstInfo
		_sInfo = p_secondInfo
		_fWin = p_firstWin
		_sWin = p_secondWin
	end

	--触摸屏蔽层
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrder)

    --创建背景UI
    createBgUI()
end

----------------------------------------工具函数----------------------------------------
--[[
	@des 	:得到触摸优先级
	@param 	:
	@return :触摸优先级
--]]
function getTouchPriority()
	return _touchPriority
end

--[[
	@des 	:处理数据，以便显示比分和攻守方的名字
	@param 	:
	@return :攻方数据
			 守方数据
			 攻方胜利数
			 守方胜利数
--]]
function dealData()	
	print("拉到的数据")
	print_t(_battleInfo)

	local firstUid = _battleInfo[1].atk.uid
	local firstServerId = _battleInfo[1].atk.serverId

	local secondUid = _battleInfo[1].def.uid
	local secondServerId = _battleInfo[1].def.serverId

	local firstWinNum = 0
	local secondWinNum = 0

	for i = 1,#_battleInfo do
		if tonumber(_battleInfo[i].def.uid) == tonumber(firstUid) then
			if tonumber(_battleInfo[i].res) == 0 then
				secondWinNum = secondWinNum + 1
			else
				firstWinNum = firstWinNum + 1
			end
		else
			if tonumber(_battleInfo[i].res) == 0 then
				firstWinNum = firstWinNum + 1
			else
				secondWinNum = secondWinNum + 1
			end
		end
	end

	print("第一uid",_battleInfo[1].atk.uid)
	print("第一serverId",_battleInfo[1].atk.serverId)

	print("第二uid",_battleInfo[1].def.uid)
	print("第二serverid",_battleInfo[1].def.serverId)

	local firstData = LordWarData.getUserInfoBy(firstServerId,firstUid)
	local secondData = LordWarData.getUserInfoBy(secondServerId,secondUid)

	print("返回第一数据")
	print_t(firstData)

	print("返回的第二数据")
	print_t(secondData)

	return firstData,secondData,firstWinNum,secondWinNum
end