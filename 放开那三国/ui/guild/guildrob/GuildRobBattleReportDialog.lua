-- FileName: GuildRobBattleReportDialog.lua
-- Author: lichenyang
-- Date: 14-1-8
-- Purpose: 军团pvp战报对话框
-- @module GuildRobBattleReportDialog

module("GuildRobBattleReportDialog",package.seeall)

require "script/ui/guild/guildrob/GuildRobBattleData"
require "script/ui/guild/guildrob/GuildRobBattleService"
require "script/battle/BattleUtil"
------------------------------[[ 模块常量 ]]------------------------------
local kReporTypeAll 	  = 1
local kReporTypeSelf      = 2

------------------------------[[ 模块变量 ]]------------------------------
local _bgLayer = nil
local _layerSize = nil
local _touchPriority = nil
local _reportScrollView = nil
local _reportInfos = nil
function init( ... )
	_bgLayer = nil
	_layerSize = nil
	_touchPriority = nil
	_reportInfos = nil
end


-------------------------------[[ ui 创建方法 ]]---------------------------
--[[
	@des : 显示接口
--]]
function show( p_touchPriority, p_zOrder )
	local layer = createLayer(p_touchPriority, p_zOrder)
	local runningScene =  CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(layer, p_zOrder)
end

--[[
	@des : 创建层
--]]
function createLayer( p_touchPriority, p_zOrder )
	init()
	_touchPriority = p_touchPriority
	_bgLayer = BaseUI.createMaskLayer(_touchPriority - 10)

	_layerSize  = CCDirector:sharedDirector():getWinSize()
	
	createReportPanel(_bgLayer)
	
	return _bgLayer
end


--[[
	@des : 创建战报对话框
--]]
function createReportPanel( p_parentNode )
	
	local panel = CCScale9Sprite:create("images/common/bg/9s_1.png")
	panel:setContentSize(CCSizeMake(464, 180))
	panel:setAnchorPoint(ccp(0.5, 0))
	panel:setPosition(ccpsprite(0.5, 0.08, p_parentNode))
	p_parentNode:addChild(panel)
	panel:setScale(MainScene.elementScale)

	local menu = CCMenu:create()
	menu:setAnchorPoint(ccp(0, 0))
	menu:setPosition(ccp(0, 0))
	menu:setTouchPriority(_touchPriority - 100)
	panel:addChild(menu)

	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png","images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccpsprite(1, 1, panel))
	closeButton:registerScriptTapHandler(closeCallback)
	menu:addChild(closeButton)

	local btMenu = BTMenu:create(true)
	btMenu:setPosition(ccp(0, 0))
	btMenu:setAnchorPoint(ccp(0, 0))
	btMenu:setStyle(kMenuRadio)
	btMenu:setTouchPriority(_touchPriority - 10)
	panel:addChild(btMenu)

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
	_reportScrollView:setViewSize(CCSizeMake(panel:getContentSize().width - 14, panel:getContentSize().height - 10))
	_reportScrollView:setPosition(ccp(0, 0))
	_reportScrollView:setContentSize(CCSizeMake(panel:getContentSize().width - 14, panel:getContentSize().height))
	_reportScrollView:setDirection(kCCScrollViewDirectionVertical)
	_reportScrollView:setTouchPriority(_touchPriority - 30)
	panel:addChild(_reportScrollView)
	_reportScrollView:setContentOffset(ccp(0, _reportScrollView:getViewSize().height - _reportScrollView:getContentSize().height))

	_reportInfos = GuildRobBattleData.getReportInfo()
	updateReportScrollview()
end

function updateReportScrollview( ... )
	if (_bgLayer==nil) then
		return
	end
	_reportInfos = GuildRobBattleData.getReportInfo()
	_reportScrollView:getContainer():removeAllChildrenWithCleanup(true)
	local selfReportNum = 0
	for i,v in ipairs(_reportInfos) do
		if(_reportType == kReporTypeSelf) then
			if(tonumber(v.winnerId) == UserModel.getUserUid() or tonumber(v.loserId) == UserModel.getUserUid()) then
				selfReportNum = selfReportNum + 1
			end
		end
	end

	if(_reportType == kReporTypeSelf) then
		_reportScrollView:setContentSize(CCSizeMake(_reportScrollView:getContentSize().width, selfReportNum * 25))
	else
		_reportScrollView:setContentSize(CCSizeMake(_reportScrollView:getContentSize().width, #_reportInfos * 25))
	end
	-- _reportScrollView:setContentOffset(ccp(0, _reportScrollView:getViewSize().height - _reportScrollView:getContentSize().height))
	if _reportScrollView:getContentSize().height > _reportScrollView:getViewSize().height then
		_reportScrollView:setContentOffset(ccp(0, 0))
	else
		_reportScrollView:setContentOffset(ccp(0, _reportScrollView:getViewSize().height-_reportScrollView:getContentSize().height))
	end
	local selfReportNum = 0
	for i,v in ipairs(_reportInfos) do
		if(_reportType == kReporTypeAll) then
			local battleDesLabel = createReportDesNode(v)
			battleDesLabel:setPosition(15, _reportScrollView:getContentSize().height - i*25)
			battleDesLabel:setAnchorPoint(ccp(0 ,0))
			_reportScrollView:addChild(battleDesLabel)
		elseif(_reportType == kReporTypeSelf) then
			if(tonumber(v.winnerId) == UserModel.getUserUid() or tonumber(v.loserId) == UserModel.getUserUid()) then
				selfReportNum = selfReportNum + 1
				local battleDesLabel = createReportDesNode(v)
				battleDesLabel:setPosition(15, _reportScrollView:getContentSize().height - selfReportNum*25)
				battleDesLabel:setAnchorPoint(ccp(0 ,0))
				_reportScrollView:addChild(battleDesLabel)
				
			end
		end
	end
	
end

-------------------------------[[ 回调方法 ]]---------------------------
--[[
	@des : 关闭按钮
--]]
function closeCallback( tag, sender )
	if _bgLayer  then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
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

-------------------------------[[ 工具方法 ]]---------------------------
--[[
	@des : 创建一条战报信息
--]]
function createReportDesNode( p_battleInfo )
	
	local winnerName = p_battleInfo.winnerName
	local loserName =  p_battleInfo.loserName
	local reportId     = tonumber(p_battleInfo.brid)
	print("createReportDesNode reportId", reportId)
	
	local label1 = CCLabelTTF:create(winnerName, g_sFontName, 21)
	label1:setColor(ccc3(0x00, 0xe4, 0xff))
	local label2 = CCLabelTTF:create(GetLocalizeStringBy("lcy_50014"), g_sFontName, 21)
	label2:setColor(ccc3(0xff, 0x00, 0x00))
	local label3 = CCLabelTTF:create(loserName, g_sFontName, 21)
	label3:setColor(ccc3(0x00, 0xe4, 0xff))

	local reportLabel = CCLabelTTF:create(GetLocalizeStringBy("lcy_50018"), g_sFontName, 21)
	reportLabel:setColor(ccc3(0x00, 0xff, 0x18))
	local label7 = CCMenuItemLabel:create(reportLabel)
	label7:setTag(reportId)
	label7:setUserObject(CCInteger:create(reportId))
	label7:registerScriptTapHandler(BattleUtil.playerBattleReportById)
	local desNode =  BaseUI.createHorizontalNode({label1,label2,label3,label7}, _touchPriority-450, _reportScrollView)
	return desNode
end