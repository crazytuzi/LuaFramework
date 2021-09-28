-- Filename: GuildWarWorshipRewardDialog.lua
-- Author: lichenyang
-- Date: 2015-01-20
-- Purpose: 个人跨服赛膜拜奖励奖励预览界面

module("GuildWarWorshipRewardDialog", package.seeall)


--------------------------------------------- added by zhangdaofeng 2015-01-23 ---------------------------------------------

require "script/model/utils/ActivityConfig"
require "script/audio/AudioUtil"

local kDialogBgImage         = "images/common/viewbg1.png"
local kDialogTitleBgImage    = "images/common/viewtitle1.png"
local kBtnCloseNormalImage   = "images/common/btn_close_n.png"
local kBtnCloseSelectedImage = "images/common/btn_close_h.png"
local kTableViewBgImage      = "images/sign/tableBg.png"
local kDialogTitleTextKey    = "zdf_1"

local _bgLayer         -- 触摸屏蔽层
local _touchPriority   -- 触摸优先级
local _zOrder

local function onTouchesHandler(eventType, x, y)
	if eventType == "began" then 
		return true
	end
end

local function onNodeEvent(event) 
	if event == "enter" then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
		_bgLayer:setTouchEnabled(true)
	elseif event == "exit" then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

--[[
	@des    : 初始化
	@param  : p_touchPriority, 触摸优先级
			  p_zOrder       , Z Order
	@return : 
--]]
local function init(p_touchPriority, p_zOrder) 
	_bgLayer = nil
	setTouchPriority(p_touchPriority)
	setZOrder(p_zOrder)
end

--[[
	@des    : 从父节点移除本层
	@param  : 
	@return : 
--]]
local function destroyLayer() 
	if _bgLayer ~= nil then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

--[[
	@des    : 关闭按钮的回调函数
	@param  : 
	@return : 
--]]
local function closeBtnCallback() 
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	destroyLayer()
end

--[[
	@des    : 创建本层
	@param  : p_touchPriority, 触摸优先级
			  p_zOrder       , Z Order
	@return : 要显示的层
--]]
function createLayer(p_touchPriority, p_zOrder) 
	init(p_touchPriority, p_zOrder)

	_bgLayer = CCLayerColor:create(ccc4(0x00, 0x2e, 0x49, 153))
	_bgLayer:registerScriptHandler(onNodeEvent)

	local rewardDialog = createRewardDialog()
	rewardDialog:setPosition(ccp(g_winSize.width/2, g_winSize.height/2))
	_bgLayer:addChild(rewardDialog)

	return _bgLayer
end

--[[
	@des    : 创建显示奖励的对话框
	@param  : 
	@return : 奖励对话框
--]]
function createRewardDialog() 
	local rewardDialogBg = createRewardDialogBg()
	local rewardTableView = createRewardTableView()
	
	rewardTableView:setAnchorPoint(ccp(0.5, 0.5))
	rewardTableView:setPosition(ccp(rewardDialogBg:getContentSize().width/2, rewardDialogBg:getContentSize().height/2-5))
	rewardDialogBg:addChild(rewardTableView)

	return rewardDialogBg
end

--[[
	@des    : 创建奖励对话框背景
	@param  : 
	@return : 奖励对话框背景
--]]
function createRewardDialogBg() 
	-- 背景图片
	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
	local dialogBgSprite = CCScale9Sprite:create(kDialogBgImage, fullRect, insetRect)
	dialogBgSprite:setPreferredSize(CCSizeMake(620, 750))
	dialogBgSprite:setAnchorPoint(ccp(0.5, 0.5))

	-- 标题背景
	local titleBgSprite = CCSprite:create(kDialogTitleBgImage)
	titleBgSprite:setAnchorPoint(ccp(0.5, 0.5))
	titleBgSprite:setPosition(dialogBgSprite:getContentSize().width/2, dialogBgSprite:getContentSize().height-6)
	dialogBgSprite:addChild(titleBgSprite)

	-- 标题文本
	local fontSize = 30
	local titleTextLabel = CCRenderLabel:create(GetLocalizeStringBy(kDialogTitleTextKey), g_sFontPangWa, fontSize, 2, ccc3(0x0,0x00,0x0), type_stroke)
	titleTextLabel:setSourceAndTargetColor(ccc3( 0xff, 0xf0, 0x49), ccc3( 0xff, 0xa2, 0x00))
	titleTextLabel:setAnchorPoint(ccp(0.5, 0.5))
	titleTextLabel:setPosition(ccp(titleBgSprite:getContentSize().width/2, titleBgSprite:getContentSize().height/2+2))
	titleBgSprite:addChild(titleTextLabel)

	-- 关闭按钮
	local closeBtn = CCMenuItemImage:create(kBtnCloseNormalImage, kBtnCloseSelectedImage)
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
	closeBtn:setPosition(dialogBgSprite:getContentSize().width-20, dialogBgSprite:getContentSize().height-20)
	closeBtn:registerScriptTapHandler(closeBtnCallback)
	local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setTouchPriority(_touchPriority-1)
	menu:addChild(closeBtn)
	dialogBgSprite:addChild(menu)

	return dialogBgSprite
end

--[[
	@des    : 创建显示奖励的TableView
	@param  : 
	@return : 带有棕色背景的TableView
--]]
function createRewardTableView() 
	-- TableView背景
	local fullRect = CCRectMake(0, 0, 75, 75)
	local insetRect = CCRectMake(28, 28, 6, 6)
	local tableViewBg = CCScale9Sprite:create(kTableViewBgImage, fullRect, insetRect)
	tableViewBg:setPreferredSize(CCSizeMake(575, 655))

	-- TableView
	require "script/ui/guildWar/reward/WishRewardPreviewTableView"
	local tableView = WishRewardPreviewTableView.createTableView(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height)
	tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	tableView:setBounceable(true)
	tableView:setTouchPriority(_touchPriority-1)
	tableView:setAnchorPoint(ccp(0, 0))
	tableView:setPosition(ccp(0, 0))
	tableViewBg:addChild(tableView)

	return tableViewBg
end

--[[
	@des    : 获得触摸优先级
	@param  : 
	@return : 触摸优先级
--]]
function getTouchPriority()
	return _touchPriority
end

--[[
	@des    : 设置触摸优先级
	@param  : p_touchPriority, 触摸优先级
	@return : 
--]]
function setTouchPriority(p_touchPriority) 
	_touchPriority = p_touchPriority or -550
end

--[[
	@des    : 获得ZOrder
	@param  : 
	@return : Z Order
--]]
function getZOrder()
	return _zOrder
end

--[[
	@des    : 设置ZOrder
	@param  : p_zOrder, Z Order
	@return : 
--]]
function setZOrder(p_zOrder)
	_zOrder = p_zOrder or 999
end

--[[
	@des    : 显示本层, 入口函数
	@param  : p_touchPriority, 触摸优先级
			  p_zOrder       , Z Order
	@return : 
--]]
function showLayer(p_touchPriority, p_zOrder) 
	createLayer(p_touchPriority, p_zOrder)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_bgLayer, _zOrder)
end








