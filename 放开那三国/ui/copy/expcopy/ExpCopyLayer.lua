-- Filename: ExpCopyLayer.lua
-- Author: lichenyang
-- Date: 2013-08-12
-- Purpose: 主角经验副本

require "script/libs/LuaCC"
require "script/libs/LuaCCSprite"
require "script/utils/LuaUtil"
require "script/audio/AudioUtil"
require "script/ui/copy/expcopy/ExpCopyCell"
require "script/ui/copy/expcopy/ExpCopyData"
require "script/ui/copy/expcopy/ExpCopyController"


module("ExpCopyLayer", package.seeall)

local colorLayer      = nil
local copyTable     = nil
local rewardList      = nil
local rewardCountNum  = nil
local pageLayer       = nil
local updataTimerFunc = nil
local slideIcons      = nil
local slideNode       = nil
local _priority       = nil
local _zOrder 		  = nil
local _background 	  = nil
----------------------------[[ ui创建 ]]----------------------------------

function init( )
	colorLayer      = nil
	copyTable     = nil
	rewardList      = nil
	rewardCountNum  = nil
	pageLayer       = nil
	updataTimerFunc = nil
	background 		= nil
	slideIcons      = {}
	slideNode       = nil
end

function show( p_Priority, p_zOrder )
 	local zOrder = p_zOrder or 2000
	local layer = ExpCopyLayer.create(p_Priority, zOrder)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(layer, zOrder)
end

function create(p_Priority, zOrder)

	init()

	colorLayer = CCLayerColor:create(ccc4(0, 0, 0, 200))
	colorLayer:setPosition(ccp(0, 0))
	-- added by zhz
	colorLayer:registerScriptTouchHandler(layerToucCb,false,-350,true)
	colorLayer:setTouchEnabled(true)
	colorLayer:setAnchorPoint(ccp(0, 0))
	
	local g_winSize = CCDirector:sharedDirector():getWinSize()

	_background = CCScale9Sprite:create("images/common/viewbg1.png")
	_background:setContentSize(CCSizeMake(630, 796))
	_background:setAnchorPoint(ccp(0.5, 0.5))
	_background:setPosition(ccp(g_winSize.width/2, g_winSize.height/2))
	colorLayer:addChild(_background)
	AdaptTool.setAdaptNode(_background)

	--标题
	local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(_background:getContentSize().width/2, _background:getContentSize().height - 7 )
	_background:addChild(titlePanel)

	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("lcyx_1816"), g_sFontPangWa, 35, 1, ccc3(0,0,0))
	titleLabel:setColor(ccc3(0xff , 0xe4, 0x00))
	local x = (titlePanel:getContentSize().width - titleLabel:getContentSize().width)/2
	local y = titlePanel:getContentSize().height - (titlePanel:getContentSize().height - titleLabel:getContentSize().height)/2
	titleLabel:setPosition(ccp(x , y))
	titlePanel:addChild(titleLabel)

	--奖励一周内不领取会消失
	local rewardAlert = CCLabelTTF:create(GetLocalizeStringBy("lcyx_1814"), g_sFontName, 21)
	rewardAlert:setPosition(ccp(_background:getContentSize().width/2, _background:getContentSize().height - 81))
	rewardAlert:setColor(ccc3(0x00, 0x6d, 0x2f))
	rewardAlert:setAnchorPoint(ccp(0.5, 0))
	_background:addChild(rewardAlert)

	--奖励一周内不领取会消失
	local challengeDesLabel = CCLabelTTF:create(GetLocalizeStringBy("lcyx_1815"), g_sFontName, 21)
	challengeDesLabel:setPosition(ccp(_background:getContentSize().width/2,40))
	challengeDesLabel:setColor(ccc3(0x78, 0x25, 0x00))
	challengeDesLabel:setAnchorPoint(ccp(0.5, 0))
	_background:addChild(challengeDesLabel)

	local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	-- changed by zhz
	menu:setTouchPriority(-360)
	_background:addChild(menu)

	--关闭按钮
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setPosition(_background:getContentSize().width * 0.95, _background:getContentSize().height * 0.96)
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)

	createTableView()
	return colorLayer
end
-- pageLayer 注册注册layer
function pageLayerCb(eventType, x, y)
	return true
end

function createTableView()

	local tableBackground = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	tableBackground:setContentSize(CCSizeMake(575, 595))
	tableBackground:setAnchorPoint(ccp(0.5, 0))
	tableBackground:setPosition(ccp(_background:getContentSize().width*0.5, 110))
	_background:addChild(tableBackground)

	local copyList = ExpCopyData.getCopyList()
	print("copyList:")
	print_t(copyList)

	local  function copyTableCallback(fn, t_table, a1, a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(567, 189 * 567/640)
		elseif fn == "cellAtIndex" then
			a2 = ExpCopyCell.create(copyList[a1 + 1], copyTable)
			a2:setScale(567/640)
			r = a2
		elseif fn == "numberOfCells" then
			r = #copyList
			print("numberOfCells r = " ,r)
		elseif fn == "cellTouched" then
			local copyInfo = copyList[a1:getIdx() + 1]
			print("copyInfo:")
			print_t(copyInfo)
			if copyInfo.isOpen == true then
				closeLayer()
				ExpCopyController.doBattleCallback(copyInfo)
			end
		end
		return r
	end
	copyTable = LuaTableView:createWithHandler(LuaEventHandler:create(copyTableCallback), CCSizeMake(567,583))
	copyTable:setBounceable(true)
	copyTable:setAnchorPoint(ccp(0, 0))
	copyTable:setPosition(ccpsprite(0, 0, tableBackground))
	tableBackground:addChild(copyTable, 20)
	copyTable:setTouchPriority(-430)
	copyTable:setContentOffset(ccp(0, copyTable:getViewSize().height - copyTable:getContentSize().height))
end

-- layerTouch 的回调函数
function layerToucCb(eventType, x, y)
	return true
end

function updateCopyList()
	copyTable:reloadData()
	copyTable:setContentOffset(ccp(0, copyTable:getViewSize().height - copyTable:getContentSize().height))
end

----------------------------[[ 回调事件 ]]----------------------------------
--领取单行

--关闭模块
function closeButtonCallback( tag, sender )
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	closeLayer()
end

function closeLayer()
	colorLayer:removeFromParentAndCleanup(true)
	colorLayer = nil
end

function attack( p_copyInfo )
	ExpCopyService.doBattle()
end



