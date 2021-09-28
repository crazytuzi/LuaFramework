-- FileName: TsTallyPreviewLayer.lua
-- Author: lgx
-- Date: 2016-08-22
-- Purpose: 兵符转换预览界面

module("TsTallyPreviewLayer", package.seeall)

require "script/ui/transform/tstally/TsTallyData"
require "script/ui/item/ItemUtil"
require "script/utils/BaseUI"

-- UI控件引用变量 --
local _touchPriority 	= nil	-- 触摸优先级
local _zOrder 		 	= nil	-- 显示层级
local _bgLayer 		 	= nil	-- 背景层
local _tableViewBg 		= nil 	-- tableView的背景

-- 模块局部变量 --

--[[
	@desc 	: 初始化方法
	@param 	: 
	@return : 
--]]
local function init()
	_touchPriority 		= nil
	_zOrder 			= nil
	_bgLayer 			= nil
	_tableViewBg 		= nil
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
	-- 初始化
	init()

	_touchPriority = pTouchPriority or -550
	_zOrder = pZorder or 1000

	-- 背景层
	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
	_bgLayer:setPosition(ccp(0, 0))
	_bgLayer:registerScriptHandler(onNodeEvent)
	_bgLayer:setAnchorPoint(ccp(0, 0))

	-- 背景框
	local bgSprite = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
	bgSprite:setContentSize(CCSizeMake(640, 540))
	bgSprite:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(bgSprite)

	-- 标题
	local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(bgSprite:getContentSize().width/2, bgSprite:getContentSize().height-6.6 ))
	bgSprite:addChild(titlePanel)

	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("lgx_1106"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	-- 关闭按钮Menu
	local closeMenu = CCMenu:create()
	closeMenu:setPosition(ccp(0, 0))
	closeMenu:setAnchorPoint(ccp(0,0))
	closeMenu:setTouchPriority(_touchPriority-30)
	bgSprite:addChild(closeMenu, 10)

	-- 关闭按钮
	local closeItem = CCMenuItemImage:create("images/common/btn_close_n.png","images/common/btn_close_h.png")
	closeItem:setAnchorPoint(ccp(0.5,0.5))
	closeItem:setPosition(ccp(bgSprite:getContentSize().width*0.955, bgSprite:getContentSize().height*0.975))
	closeItem:registerScriptTapHandler(closeItemCallback)
	closeMenu:addChild(closeItem,1)

	-- 列表背景
	_tableViewBg = BaseUI.createContentBg(CCSizeMake(590, 400))
	_tableViewBg:setAnchorPoint(ccp(0.5,1))
	_tableViewBg:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height-50))
	bgSprite:addChild(_tableViewBg)

	-- 创建列表
	createTableView()

	-- 提示文字
	local tipFont = CCLabelTTF:create(GetLocalizeStringBy("lgx_1107"), g_sFontPangWa, 25)
	tipFont:setColor(ccc3(0x78, 0x25, 0x00))
	tipFont:setAnchorPoint(ccp(0.5,0.5))
	tipFont:setPosition(ccp(bgSprite:getContentSize().width*0.5, _tableViewBg:getPositionY()-_tableViewBg:getContentSize().height-30))
	bgSprite:addChild(tipFont)

    return _bgLayer
end

--[[
	@desc	: 创建兵符预览列表
    @param	: 
    @return	: 
—-]]
function createTableView()
	local showItems = TsTallyData.getAllTsTallyItemTid()
	-- 创建Cell
	local handler = LuaEventHandler:create(function(fn, table, a1, a2) 
		local r
		if fn == "cellSize" then
			r = CCSizeMake(590, 140)
		elseif fn == "cellAtIndex" then
			a2 = CCTableViewCell:create()
			local posArrX = {0.13,0.37,0.62,0.87}
			for i=1,4 do
				if(showItems[a1*4+i] ~= nil)then
					-- 物品图标
					local tab = {}
					tab.tid = showItems[a1*4+i]
					tab.num = 1
					tab.type = "item"
					local iconSp = ItemUtil.createGoodsIcon(tab, _touchPriority-3, 1020, _touchPriority-50)
					a2:addChild(iconSp)
					iconSp:setAnchorPoint(ccp(0.5,1))
					iconSp:setPosition(ccp(590*posArrX[i],130))
				end
			end
			r = a2
		elseif fn == "numberOfCells" then
			local num = #showItems
			r = math.ceil(num/4)
			print("num is : ", num)
		else
		end
		return r
	end)

	local listTableView = LuaTableView:createWithHandler(handler, CCSizeMake(_tableViewBg:getContentSize().width,_tableViewBg:getContentSize().height-20))
	listTableView:setBounceable(true)
	listTableView:setTouchPriority(_touchPriority-4)
	listTableView:ignoreAnchorPointForPosition(false)
	listTableView:setAnchorPoint(ccp(0.5,0.5))
	listTableView:setPosition(ccp(_tableViewBg:getContentSize().width*0.5,_tableViewBg:getContentSize().height*0.5))
	_tableViewBg:addChild(listTableView)
	-- 设置单元格升序排列
	listTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
end

--[[
	@desc	: 关闭按钮回调,关闭界面
    @param	: 
    @return	: 
—-]]
function closeItemCallback()
	require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    if not tolua.isnull(_bgLayer) then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end
