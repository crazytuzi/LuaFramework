-- FileName: ChariotChooseLayer.lua
-- Author: lgx 
-- Date: 16-06-27
-- Purpose: 战车选择界面

module("ChariotChooseLayer", package.seeall)

require "script/ui/main/BulletinLayer"
require "script/ui/main/MenuLayer"
require "script/ui/chariot/ChariotMainData"
require "script/ui/bag/ChariotCell"
require "script/ui/main/MainScene"
require "script/ui/bag/BagLayer"

local _touchPriority 	= nil	-- 触摸优先级
local _zOrder 		 	= nil	-- 显示层级
local _bgLayer 		 	= nil	-- 背景层
local _bgSprite			= nil  	-- 背景
local _chariotPos 		= nil	-- 战车装备的位置
local _canEquipData 	= nil	-- 可装备的战车信息

--[[
	@desc	: 初始化方法
	@param 	: 
    @return	: 
--]]
local function init()
	_touchPriority	= nil
	_zOrder			= nil
	_bgLayer		= nil
	_bgSprite 		= nil
	_chariotPos		= nil
	_canEquipData	= nil
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
		_bgLayer:registerScriptTouchHandler(layerToucCallback,false,_touchPriority,false)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
		_bgLayer = nil
	end
end

--[[
	@desc 	: 显示界面方法
	@param	: pPos 装备位置
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function showLayer( pPos, pTouchPriority, pZorder )
	-- local layer = createLayer(pPos,pTouchPriority, pZorder)
	-- local scene = CCDirector:sharedDirector():getRunningScene()
	-- scene:addChild(layer,_zOrder)

    -- 使用MainSence.changeLayer进入
	-- 显示底部和顶部
	MainScene.setMainSceneViewsVisible(true,false,true)
	local chariotChooseLayer = createLayer(pPos,pTouchPriority, pZorder)
	MainScene.changeLayer(chariotChooseLayer, "ChariotChooseLayer")
end

--[[
	@desc 	: 创建Layer及UI
	@param	: pPos 装备位置
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function createLayer( pPos, pTouchPriority, pZorder )
	-- 初始化
	init()

	_chariotPos = pPos or 1
	_touchPriority = pTouchPriority or -600
	_zOrder = pZorder or 600

	-- 可装备的战车
	_canEquipData = ChariotMainData.getCanEquipChariotByPos(pPos)

	
	-- 背景层
	_bgLayer = CCLayer:create()
	_bgLayer:setPosition(ccp(0, 0))
	_bgLayer:registerScriptHandler(onNodeEvent)
	_bgLayer:setAnchorPoint(ccp(0, 0))

	-- 背景
	_bgSprite = CCSprite:create("images/main/module_bg.png")
	_bgSprite:setAnchorPoint(ccp(0.5,0.5))
	_bgSprite:setPosition(ccp(_bgLayer:getContentSize().width/2,_bgLayer:getContentSize().height/2))
	_bgSprite:setScale(g_fBgScaleRatio)
	_bgLayer:addChild(_bgSprite)

	-- 顶部标题
	createChariotEquipTitle()

	-- 战车列表
	createChariotList()

	return _bgLayer
end

--[[
	@desc 	: 创建选择战车标题UI
	@param 	: 
	@return : 
--]]
function createChariotEquipTitle()
	-- 公告的高度
	local bulletHeight = BulletinLayer.getLayerHeight()

	-- title的背景
	-- local fullRect = CCRectMake(0,0,58,99)
	-- local insetRect = CCRectMake(20,20,18,59)
	-- _titleBgSprite = CCScale9Sprite:create("images/formation/changeequip/topbg.png",fullRect,insetRect)
	-- _titleBgSprite:setContentSize(CCSizeMake(640,98))
	_titleBgSprite = CCSprite:create("images/hero/select/title_bg.png")
	_titleBgSprite:setAnchorPoint(ccp(0.5,1))
	_titleBgSprite:setPosition(ccp(_bgLayer:getContentSize().width/2,_bgLayer:getContentSize().height-bulletHeight*g_fScaleX))
	-- _titleBgSprite:setPosition(ccp(_bgLayer:getContentSize().width/2,_bgLayer:getContentSize().height))
	_titleBgSprite:setScale(g_fScaleX)
	_bgLayer:addChild(_titleBgSprite)

	-- 创建title
	local titleSprite = CCSprite:create("images/chariot/choose_title.png")
	titleSprite:setAnchorPoint(ccp(0,0.5))
	titleSprite:setPosition(ccp(20*g_fElementScaleRatio,_titleBgSprite:getContentSize().height/2+10))
	_titleBgSprite:addChild(titleSprite)

	-- 创建返回按钮
	local closeMenu = CCMenu:create()
	closeMenu:setPosition(ccp(0,0))
	closeMenu:setTouchPriority(_touchPriority-50)
	_titleBgSprite:addChild(closeMenu)

	-- 返回按钮
	local closeItem = CCMenuItemImage:create("images/hero/btn_back_n.png","images/hero/btn_back_h.png")
	closeItem:setAnchorPoint(ccp(1,0.5))
	closeItem:setPosition(ccp(_titleBgSprite:getContentSize().width-20*g_fElementScaleRatio,_titleBgSprite:getContentSize().height/2+10))
	closeItem:registerScriptTapHandler(closeItemCallback)
	closeMenu:addChild(closeItem)

end

--[[
	@desc 	: 创建战车列表
	@param 	: 
	@return : 
--]]
function createChariotList()
	-- 公告的高度
	local bulletHeight = BulletinLayer.getLayerHeight()

	-- 底部菜单的高
	local bottomHeight = MenuLayer.getHeight()

	-- 创建列表
	local tableViewSize = CCSizeMake(_bgLayer:getContentSize().width,(_bgLayer:getContentSize().height-bottomHeight-(_titleBgSprite:getContentSize().height-18)*g_fScaleX-bulletHeight*g_fScaleX))
	-- local tableViewSize = CCSizeMake(_bgLayer:getContentSize().width,(_bgLayer:getContentSize().height-_titleBgSprite:getContentSize().height*g_fScaleX))
	local cellSize = CCSizeMake(_bgLayer:getContentSize().width,190*g_fScaleX)
	local data = _canEquipData
	local dataLen = table.count(data)
	local luaHandler = LuaEventHandler:create(function(fn,t,a1,a2)
		local ret
		if fn == "cellSize" then
			ret = cellSize
		elseif fn == "cellAtIndex" then
			ret = createChariotCell(data[a1+1])
		elseif fn == "numberOfCells" then
			ret = dataLen
		elseif fn == "cellTouched" then
		end
		return ret
	end)
	_chariotTableView = LuaTableView:createWithHandler(luaHandler,tableViewSize)
	_chariotTableView:setTouchPriority(_touchPriority-20)
	_chariotTableView:setBounceable(true)
	_chariotTableView:setDirection(kCCScrollViewDirectionVertical)
	_chariotTableView:setAnchorPoint(ccp(0,0))
	_chariotTableView:setPosition(ccp(2,bottomHeight))
	-- _chariotTableView:setPosition(ccp(2,0))
	_bgLayer:addChild(_chariotTableView)
end

--[[
	@desc 	: 创建战车列表Cell
	@param 	: 
	@return : 
--]]
function createChariotCell( pCellData )
	local cell = ChariotCell.createCell(pCellData,-1,false,nil)
	-- 隐藏下拉按钮
	ChariotCell.setOpenMenuBtnVisible(false)
	cell:setContentSize(CCSizeMake(640,190))
	cell:setScale(g_fScaleX)

	-- Menu
	local btnMenuBar = CCMenu:create()
	btnMenuBar:setPosition(ccp(0,0))
	btnMenuBar:setTouchPriority(_touchPriority-30)
	cell:addChild(btnMenuBar,_zOrder)

	-- 装备按钮
	local equipItem = CCMenuItemImage:create("images/formation/changeequip/btn_equip_n.png",  "images/formation/changeequip/btn_equip_h.png")
	equipItem:setAnchorPoint(ccp(1,0.5))
	equipItem:setPosition(ccp(cell:getContentSize().width-30,cell:getContentSize().height/2))
	equipItem:registerScriptTapHandler(equipItemCallback)
	btnMenuBar:addChild(equipItem,_zOrder,tonumber(pCellData.item_id))

	return cell
end

--[[
	@desc 	: 点击装备按钮回调
	@param 	: 
	@return : 
--]]
function equipItemCallback( pTag, pItem )
	require "script/ui/chariot/ChariotMainController"
	ChariotMainController.equip(function()
		print("---------------equip Success--------------")
		closeItemCallback()
	end,_chariotPos,pTag)
end

--[[
	@desc 	: 点击关闭按钮回调
	@param 	: 
	@return : 
--]]
function closeItemCallback()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	-- if not tolua.isnull(_bgLayer) then
	-- 	_bgLayer:removeFromParentAndCleanup(true)
	-- 	_bgLayer = nil
	-- 	MainScene.setMainSceneViewsVisible(false,false,false)
	-- end

	-- 返回战车主界面
	MainScene.setMainSceneViewsVisible(false,false,false)
	local chariotMainLayer = ChariotMainLayer.createLayer(_chariotPos)
	MainScene.changeLayer(chariotMainLayer, "ChariotMainLayer")
end

