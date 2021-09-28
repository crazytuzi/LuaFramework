-- FileName: ChariotIllustrateLayer.lua
-- Author: lgx
-- Date: 2016-06-27
-- Purpose: 战车图鉴界面

module("ChariotIllustrateLayer", package.seeall)

require "script/ui/chariot/ChariotDef"
require "script/ui/chariot/ChariotUtil"
require "script/ui/chariot/illustrate/ChariotIllustrateData"
require "script/ui/chariot/illustrate/ChariotIllustrateCell"
require "script/ui/chariot/illustrate/ChariotSuitCell"

local _touchPriority 	= nil	-- 触摸优先级
local _zOrder 		 	= nil	-- 显示层级
local _bgLayer 		 	= nil	-- 背景层
local _leftArrowSp 		= nil	-- 左箭头
local _rightArrowSp 	= nil	-- 右箭头
local _tableViewBg 		= nil 	-- tableView的背景
local _tableView 		= nil 	-- 展示的tableView
local _curShowType 		= nil 	-- 当前显示的界面类型
local _allListInfo 		= nil 	-- 列表视图数据
local _tipLabelOne		= nil	-- 提示标签1

--[[
	@desc 	: 初始化方法
	@param 	: 
	@return : 
--]]
local function init()
	_touchPriority 	 = nil
	_zOrder 		 = nil
	_bgLayer 		 = nil
	_leftArrowSp	 = nil
	_rightArrowSp 	 = nil
	_tableViewBg 	 = nil
	_tableView 		 = nil
	_curShowType	 = nil
	_allListInfo 	 = nil
	_tipLabelOne	 = nil
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
	@desc 	: 显示界面方法
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function showLayer( pTouchPriority, pZorder )
	local layer = createLayer(pTouchPriority, pZorder)
	local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(layer,_zOrder)
end

--[[
	@desc 	: 创建Layer及UI
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function createLayer( pTouchPriority, pZorder )
	-- 初始化
	init()

	_touchPriority = pTouchPriority or -800
	_zOrder = pZorder or 800
	_curShowType = ChariotDef.kShowTypeIllustrate

	-- 背景层
	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
	_bgLayer:setPosition(ccp(0, 0))
	_bgLayer:registerScriptHandler(onNodeEvent)
	_bgLayer:setAnchorPoint(ccp(0, 0))

	-- 背景框
	local bgSprite = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
	bgSprite:setContentSize(CCSizeMake(636,810))
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setScale(g_fElementScaleRatio)
	bgSprite:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
	_bgLayer:addChild(bgSprite)

	-- 标题
	local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(bgSprite:getContentSize().width/2, bgSprite:getContentSize().height-6.6))
	bgSprite:addChild(titlePanel)

	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("lgx_1069"), g_sFontPangWa, 33)
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
	_tableViewBg = BaseUI.createContentBg(CCSizeMake(600,660))
 	_tableViewBg:setAnchorPoint(ccp(0.5,1))
 	_tableViewBg:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height-110))
 	bgSprite:addChild(_tableViewBg)

 	-- 提示文字
    _tipLabelOne = CCLabelTTF:create(GetLocalizeStringBy("lgx_1094"), g_sFontName, 24)
	bgSprite:addChild(_tipLabelOne,10)
	_tipLabelOne:setAnchorPoint(ccp(0.5, 0))
	_tipLabelOne:setPosition(ccp(bgSprite:getContentSize().width*0.5,95))
	_tipLabelOne:setColor(ccc3(0xff,0xff,0xff))

	local tipLabelTwo = CCLabelTTF:create(GetLocalizeStringBy("lgx_1070"), g_sFontName, 24)
	bgSprite:addChild(tipLabelTwo,10)
	tipLabelTwo:setAnchorPoint(ccp(0.5, 0))
	tipLabelTwo:setPosition(ccp(bgSprite:getContentSize().width*0.5,55))
	tipLabelTwo:setColor(ccc3(0xff,0xff,0xff))

 	-- 创建战车图鉴列表
 	createTableView()

 	-- 标签菜单
    createTopMenu(bgSprite)

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

	-- 1战车图鉴
    local illustrateButton = LuaCCMenuItem.createMenuItemOfRenderAndFont(  image_n, image_h,image_h,
          rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
          btn_size_n2, btn_size_h2,btn_size_h2,
          GetLocalizeStringBy("lgx_1081"), text_color_n, text_color_h, text_color_h, font, font_size_n, 
          font_size_h, strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)

    -- 2战车组合
    local suitButton = LuaCCMenuItem.createMenuItemOfRenderAndFont(  image_n, image_h,image_h,
          rect_full_n, rect_inset_n, rect_full_h, rect_inset_h,rect_full_h, rect_inset_h,
          btn_size_n2, btn_size_h2,btn_size_h2,
          GetLocalizeStringBy("lgx_1082"), text_color_n, text_color_h, text_color_h, font, font_size_n, 
          font_size_h, strokeCor_n, strokeCor_h,strokeCor_h, stroke_size_n, stroke_size_h, stroke_size_h)

    table.insert(radio_data.items,illustrateButton)
    table.insert(radio_data.items,suitButton)

    local typeMenu = LuaCCSprite.createRadioMenuWithItems(radio_data)
    typeMenu:setAnchorPoint(ccp(0,0))
    typeMenu:setPosition(ccp(35,pMenuBg:getContentSize().height-110))
    pMenuBg:addChild(typeMenu)
end

--[[
	@desc 	: 更新箭头显示状态
	@param 	: 
	@return : 
--]]
function updateArrowShowSttus()
    if (_tableView == nil) then
        return
    end

    local offset = _tableView:getContentSize().width + _tableView:getContentOffset().x - _tableView:getViewSize().width
	if (_rightArrowSp ~= nil) then
		if (offset > 1 or offset < -1) then
			_rightArrowSp:setVisible(true)
		else
			_rightArrowSp:setVisible(false)
		end
	end

	if (_leftArrowSp ~= nil) then
		if (_tableView:getContentOffset().x < 0) then
			_leftArrowSp:setVisible(true)
		else
			_leftArrowSp:setVisible(false)
		end
	end
end

--[[
	@desc 	: 创建tableView
	@param 	: 
	@return : 
--]]
function createTableView()
	_allListInfo = ChariotIllustrateData.getAllBookInfo()

 	local cellSize = CCSizeMake(296,645)
	local createTableCallback = function(fn, t_table, a1, a2)
		local r
		if fn == "cellSize" then
			-- r = CCSizeMake(cellSize.width, cellSize.height)
			if (_curShowType == ChariotDef.kShowTypeIllustrate) then
				r = CCSizeMake(296,645)
			else
				r = CCSizeMake(592,645)
			end
		elseif fn == "cellAtIndex" then
			-- a2 = ChariotIllustrateCell.createCell(_allListInfo[a1 + 1])
			if (_curShowType == ChariotDef.kShowTypeIllustrate) then
				a2 = ChariotIllustrateCell.createCell(_allListInfo[a1 + 1])
			else
				a2 = ChariotSuitCell.createCell(_allListInfo[a1 + 1])
			end
			r = a2
		elseif fn == "numberOfCells" then
			r = #_allListInfo
		elseif fn == "scroll" then
			updateArrowShowSttus()
		end
		return r
	end

	_tableView = LuaTableView:createWithHandler(LuaEventHandler:create(createTableCallback), CCSizeMake(592,570))
	_tableView:setBounceable(true)
	_tableView:setDirection(kCCScrollViewDirectionHorizontal)
	_tableView:ignoreAnchorPointForPosition(false)
	_tableView:setAnchorPoint(ccp(0.5, 0))
	_tableView:setPosition(ccp(_tableViewBg:getContentSize().width*0.5,90))
	_tableViewBg:addChild(_tableView)
	_tableView:reloadData()
	_tableView:setTouchPriority(_touchPriority-60)

	-- 创建箭头
	-- 左箭头
    _leftArrowSp = CCSprite:create("images/common/left_big.png")
    _leftArrowSp:setAnchorPoint(ccp(0,0.5))
    _leftArrowSp:setPosition(0,_bgLayer:getContentSize().height*0.5)
    _bgLayer:addChild(_leftArrowSp,5)
    _leftArrowSp:setVisible(false)
    _leftArrowSp:setScale(g_fElementScaleRatio)
    ChariotUtil.runArrowAction(_leftArrowSp)

    -- 右箭头
    _rightArrowSp = CCSprite:create("images/common/right_big.png")
    _rightArrowSp:setAnchorPoint(ccp(1,0.5))
    _rightArrowSp:setPosition(_bgLayer:getContentSize().width,_bgLayer:getContentSize().height*0.5)
    _bgLayer:addChild(_rightArrowSp,5)
    _rightArrowSp:setVisible(false)
    _rightArrowSp:setScale(g_fElementScaleRatio)
    ChariotUtil.runArrowAction(_rightArrowSp)

	if (#_allListInfo > 2) then
		_rightArrowSp:setVisible(true)
	end
end

--[[
	@desc 	: 更新列表视图 图鉴/组合
	@param 	: 
	@return : 
--]]
function updateTableView()
	if (_curShowType == ChariotDef.kShowTypeIllustrate) then
		_allListInfo = ChariotIllustrateData.getAllBookInfo()
	else
		_allListInfo = ChariotIllustrateData.getAllSuitInfo()
	end
	_tableView:reloadData()
end

--[[
	@desc 	: 点击图鉴/组合类型标签
	@param 	: pTag 按钮tag pItem 按钮
	@return : 
--]]
function changeTypeCallBack( pTag , pItem )
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
	
	local tipStrOne = GetLocalizeStringBy("lgx_1094")
	if (pTag == 1) then
		_curShowType = ChariotDef.kShowTypeIllustrate
	elseif (pTag == 2) then
		_curShowType = ChariotDef.kShowTypeSuit
		tipStrOne = GetLocalizeStringBy("lgx_1095")
	else
		print("changeTypeCallBack tag error!")
	end
	-- print("显示类型:".._curShowType)
	-- 刷新提示
	_tipLabelOne:setString(tipStrOne)
	-- 刷新列表
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