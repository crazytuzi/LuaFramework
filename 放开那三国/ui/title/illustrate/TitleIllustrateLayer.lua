-- Filename: TitleIllustrateLayer.lua
-- Author: lgx
-- Date: 2016-05-04
-- Purpose: 称号图鉴界面

module("TitleIllustrateLayer", package.seeall)
require "script/ui/title/TitleDef"
require "script/ui/title/TitleData"
require "script/utils/BaseUI"

local _touchPriority 	= nil	-- 触摸优先级
local _zOrder 		 	= nil	-- 显示层级
local _bgLayer 		 	= nil	-- 背景层
local _tableViewBg 		= nil 	-- tableView的背景
local _tableView 		= nil 	-- 展示的tableView
local _curTitleInfo 	= nil	-- 当前显示的称号数据

--[[
	@desc 	: 初始化方法
	@param 	: 
	@return : 
--]]
local function init()
	_touchPriority 	 = nil
	_zOrder 		 = nil
	_bgLayer 		 = nil
	_tableViewBg 	 = nil
	_tableView 		 = nil
	_curTitleInfo 	 = nil
end

--[[
	@desc 	: 显示界面方法
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function showLayer( pTouchPriority, pZorder )
	_touchPriority = pTouchPriority or -800
	_zOrder = pZorder or 800

    local layer = createLayer(_touchPriority, _zOrder)
	local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(layer,_zOrder)
end

--[[
	@desc 	: 背景层触摸回调
	@param 	: eventType 事件类型 x,y 触摸点
	@return : 
--]]
local function layerToucCallback( eventType, x, y )
	return true
end

--[[
	@desc 	: 回调onEnter和onExit事件
	@param 	: event 事件名
	@return : 
--]]
function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(layerToucCallback,false,_touchPriority,true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
		_bgLayer = nil
	end
end

--[[
	@desc 	: 创建Layer及UI
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function createLayer( pTouchPriority, pZorder )
	_touchPriority = pTouchPriority or -800
	_zOrder = pZorder or 800

	-- 背景层
	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
	_bgLayer:setPosition(ccp(0, 0))
	_bgLayer:registerScriptHandler(onNodeEvent)
	_bgLayer:setAnchorPoint(ccp(0, 0))

	-- 背景框
	local bgSprite = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
	bgSprite:setContentSize(CCSizeMake(630,830))
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setScale(g_fElementScaleRatio)
	bgSprite:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
	_bgLayer:addChild(bgSprite)

	-- 标题
	local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(bgSprite:getContentSize().width/2, bgSprite:getContentSize().height-6.6))
	bgSprite:addChild(titlePanel)

	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("lgx_1038"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	-- 返回按钮Menu
	local backMenu = CCMenu:create()
    backMenu:setPosition(ccp(0, 0))
    backMenu:setAnchorPoint(ccp(0,0))
    backMenu:setTouchPriority(_touchPriority-30)
    bgSprite:addChild(backMenu, 10)

    -- 返回按钮
    local backItem = CCMenuItemImage:create("images/common/btn_close_n.png","images/common/btn_close_h.png")
    backItem:setAnchorPoint(ccp(0.5,0.5))
    backItem:setPosition(ccp(bgSprite:getContentSize().width*0.955, bgSprite:getContentSize().height*0.975))
    backItem:registerScriptTapHandler(backItemCallback)
    backMenu:addChild(backItem,1)

    -- 列表背景
	_tableViewBg = BaseUI.createContentBg(CCSizeMake(584,590))
 	_tableViewBg:setAnchorPoint(ccp(0.5,1))
 	_tableViewBg:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height-115))
 	bgSprite:addChild(_tableViewBg)

 	-- 创建称号列表
 	createTableView()

    -- 类型标签菜单
    createTopMenu(bgSprite)

 	-- 提示字
 	local leftNoteLabel = CCLabelTTF:create(GetLocalizeStringBy("lgx_1040"),g_sFontPangWa,25)
 	leftNoteLabel:setColor(ccc3(0x78,0x25,0x00))

 	local rightNoteLabel = CCLabelTTF:create(GetLocalizeStringBy("lgx_1041"),g_sFontPangWa,25)
 	rightNoteLabel:setColor(ccc3(0xff,0x00,0x00))

 	local noteLabel = BaseUI.createHorizontalNode({leftNoteLabel,rightNoteLabel})
 	noteLabel:setAnchorPoint(ccp(0.5,0.5))
    noteLabel:setPosition(ccp(bgSprite:getContentSize().width*0.5,100))
    bgSprite:addChild(noteLabel,2)

 	-- 激活数
 	local gotNoteLabel = CCLabelTTF:create(GetLocalizeStringBy("lgx_1042"),g_sFontPangWa,25)
 	gotNoteLabel:setColor(ccc3(0x78,0x25,0x00))

 	local gotNumLabel = CCLabelTTF:create(TitleData.getGotTitleString(),g_sFontPangWa,25)
 	gotNumLabel:setColor(ccc3(0x00,0x6d,0x2f))

 	local gotLabel = BaseUI.createHorizontalNode({gotNoteLabel,gotNumLabel})
 	gotLabel:setAnchorPoint(ccp(0.5,0.5))
    gotLabel:setPosition(ccp(bgSprite:getContentSize().width*0.5,60))
    bgSprite:addChild(gotLabel,2)

    return _bgLayer
end

--[[
	@desc 	: 创建称号类型标签
	@param 	: pMenuBg 菜单加的框
	@return : 
--]]
function createTopMenu( pMenuBg )
	-- 创建称号类型标签
	local argsTable = {}
	require "script/libs/LuaCCMenuItem"
	local image_n = "images/common/bg/button/ng_tab_n.png"
    local image_h = "images/common/bg/button/ng_tab_h.png"
    local rect_full_n   = CCRectMake(0,0,63,43)
    local rect_inset_n  = CCRectMake(25,20,13,3)
    local rect_full_h   = CCRectMake(0,0,73,53)
    local rect_inset_h  = CCRectMake(35,25,3,3)
    local btn_size_n    = CCSizeMake(225, 60)
    local btn_size_n2   = CCSizeMake(165, 60)
    local btn_size_h    = CCSizeMake(230, 65)
    local btn_size_h2   = CCSizeMake(170, 65)
    
    local text_color_n  = ccc3(0xf4, 0xdf, 0xcb)
    local text_color_h  = ccc3(0xff, 0xff, 0xff)
    local font          = g_sFontPangWa
    local font_size_n   = 25
    local font_size_h   = 25
    local strokeCor_n   = ccc3(0x00, 0x00, 0x00)
    local strokeCor_h   = ccc3(0x00, 0x00, 0x00)
    local stroke_size_n = 0
    local stroke_size_h = 1

    local radio_data = {}
    radio_data.touch_priority = _touchPriority - 50
    radio_data.space = 3
    radio_data.callback = changeTypeCallBack
    radio_data.direction = 1
    radio_data.defaultIndex = 1
    radio_data.items = {}

	-- 1普通称号
    local normalButton = LuaCCMenuItem.createMenuItemOfRenderAndFont(  image_n, image_h,image_h,
          rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
          btn_size_n2, btn_size_h2,btn_size_h2,
          GetLocalizeStringBy("lgx_1031"), text_color_n, text_color_h, text_color_h, font, font_size_n, 
          font_size_h, strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)

    -- 2活动称号
    local activityButton = LuaCCMenuItem.createMenuItemOfRenderAndFont(  image_n, image_h,image_h,
          rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
          btn_size_n2, btn_size_h2,btn_size_h2,
          GetLocalizeStringBy("lgx_1032"), text_color_n, text_color_h, text_color_h, font, font_size_n, 
          font_size_h, strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)

    -- 3跨服称号
    local crossButton = LuaCCMenuItem.createMenuItemOfRenderAndFont(  image_n, image_h,image_h,
          rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
          btn_size_n2, btn_size_h2,btn_size_h2,
          GetLocalizeStringBy("lgx_1033"), text_color_n, text_color_h, text_color_h, font, font_size_n, 
          font_size_h, strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)

    table.insert(radio_data.items,normalButton)
    table.insert(radio_data.items,activityButton)
    table.insert(radio_data.items,crossButton)

    local typeMenu = LuaCCSprite.createRadioMenuWithItems(radio_data)
    typeMenu:setAnchorPoint(ccp(0,0))
    typeMenu:setPosition(ccp(35,pMenuBg:getContentSize().height-115))
    pMenuBg:addChild(typeMenu)
end

--[[
	@desc 	: 创建tableView
	@param 	: 
	@return : 
--]]
function createTableView()
	_curTitleInfo = TitleData.getSortedTitleIllustrateInfoByType(_curTitleType)

	local cellSize = CCSizeMake(574,105)
	local createTableCallback = function(fn, t_table, a1, a2)
		require "script/ui/title/illustrate/TitleIllustrateCell"
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width, cellSize.height)
		elseif fn == "cellAtIndex" then
			a2 = TitleIllustrateCell.createCell(_curTitleInfo[a1 + 1])
			r = a2
		elseif fn == "numberOfCells" then
			r = #_curTitleInfo
		elseif fn == "cellTouched" then
			
		end
		return r
	end

	_tableView = LuaTableView:createWithHandler(LuaEventHandler:create(createTableCallback), CCSizeMake(574,585))
	_tableView:setBounceable(true)
	_tableView:ignoreAnchorPointForPosition(false)
	_tableView:setAnchorPoint(ccp(0.5, 0.5))
	_tableView:setPosition(ccp(_tableViewBg:getContentSize().width*0.5,_tableViewBg:getContentSize().height*0.5))
	_tableViewBg:addChild(_tableView)
	_tableView:setTouchPriority(_touchPriority-60)
end

--[[
	@desc 	: 更新称号列表
	@param 	: 
	@return : 
--]]
function updateTableView()
	_curTitleInfo = TitleData.getSortedTitleIllustrateInfoByType(_curTitleType)
	_tableView:reloadData()
end


--[[
	@desc 	: 点击称号类型标签
	@param 	: pTag 按钮tag pItem 按钮
	@return : 
--]]
function changeTypeCallBack( pTag , pItem )
	-- if (_tableView) then
		AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
	-- end
	if (pTag == 1) then
		_curTitleType = TitleDef.kTitleTypeNormal
	elseif (pTag == 2) then
		_curTitleType = TitleDef.kTitleTypeActivity
	elseif (pTag == 3) then
		_curTitleType = TitleDef.kTitleTypeCross
	else
		print("changeTypeCallBack tag error!")
	end
	print("称号类型:".._curTitleType)
	updateTableView()
end

--[[
	@desc 	: 返回按钮回调,关闭界面
	@param 	: 
	@return : 
--]]
function backItemCallback()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if not tolua.isnull(_bgLayer) then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end