-- FileName: ChariotMainLayer.lua
-- Author: lgx
-- Date: 2016-06-27
-- Purpose: 战车主界面(战车装备界面)

module("ChariotMainLayer", package.seeall)

require "script/ui/chariot/ChariotMainData"
require "script/ui/chariot/ChariotUtil"
require "script/ui/chariot/ChariotEquipCell"

local _touchPriority 	= nil -- 触摸优先级
local _zOrder 		 	= nil -- 显示层级
local _bgLayer 		 	= nil -- 背景层
local _leftArrowSp 		= nil -- 左箭头
local _rightArrowSp 	= nil -- 右箭头
local _chariotTabView 	= nil -- 战车tabView
local _showType 		= nil -- 显示状态

--[[
	@desc	: 初始化方法
	@param 	: 
    @return	: 
--]]
local function init()
	_touchPriority 	 = nil
	_zOrder 		 = nil
	_bgLayer 		 = nil
	_leftArrowSp	 = nil
	_rightArrowSp 	 = nil
	_chariotTabView	 = nil
	_showType		 = nil
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

	-- 判断功能节点是否开启
    if (not DataCache.getSwitchNodeState(ksSwitchChariot)) then
        return
    end

	-- 使用MainSence.changeLayer进入
	MainScene.setMainSceneViewsVisible(false,false,false)
	local chariotMainLayer = createLayer(1,pTouchPriority, pZorder)
	MainScene.changeLayer(chariotMainLayer, "ChariotMainLayer")
end

--[[
	@desc 	: 创建Layer及UI
	@param	: pCurPos 当前显示的位置 选择战车界面用
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : CCLayer 背景层
--]]
function createLayer( pCurPos, pTouchPriority, pZorder )
	-- 初始化
	init()

	_touchPriority = pTouchPriority or -700
	_zOrder = pZorder or 700

	-- 背景层
	_bgLayer = CCLayer:create()
	_bgLayer:setPosition(ccp(0, 0))
	_bgLayer:registerScriptHandler(onNodeEvent)
	_bgLayer:setAnchorPoint(ccp(0, 0))

	-- 背景图
	local bgSprite = CCSprite:create("images/chariot/main_bg.png")
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
	bgSprite:setScale(g_fBgScaleRatio)
	_bgLayer:addChild(bgSprite)

	-- 标题
	local titleSprite = CCSprite:create("images/chariot/main_title.png")
    titleSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height-titleSprite:getContentSize().height/2-25*g_fElementScaleRatio))
    titleSprite:setAnchorPoint(ccp(0.5,0.5))
    titleSprite:setScale(g_fElementScaleRatio)
    _bgLayer:addChild(titleSprite)

    -- 黑烟特效
    local effectSprite = XMLSprite:create("images/chariot/effect/bgzhanche/bgzhanche")
    effectSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.6))
    effectSprite:setAnchorPoint(ccp(0.5,0.5))
    effectSprite:setScale(g_fElementScaleRatio)
    _bgLayer:addChild(effectSprite,5)

	-- 返回按钮Menu
	local backMenu = CCMenu:create()
    backMenu:setPosition(ccp(0, 0))
    backMenu:setTouchPriority(_touchPriority-30)
    _bgLayer:addChild(backMenu, 10)

    -- 返回按钮
    local backItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
    backItem:setScale(g_fElementScaleRatio)
    backItem:setAnchorPoint(ccp(1,0.5))
    backItem:setPosition(ccp(_bgLayer:getContentSize().width-20,_bgLayer:getContentSize().height-60*g_fElementScaleRatio))
    backItem:registerScriptTapHandler(backItemCallback)
    backMenu:addChild(backItem,1)

	-- 图鉴按钮
   	local illustrateItem = CCMenuItemImage:create("images/chariot/btn_chariot_illustrate_n.png","images/chariot/btn_chariot_illustrate_h.png")
    illustrateItem:setScale(g_fElementScaleRatio)
    illustrateItem:setAnchorPoint(ccp(0,0.5))
    illustrateItem:setPosition(ccp(20,_bgLayer:getContentSize().height-60*g_fElementScaleRatio))
    illustrateItem:registerScriptTapHandler(illustrateItemCallback)
    backMenu:addChild(illustrateItem,1)

	-- 创建战车装备信息
	createEquipChariot(pCurPos)

    return _bgLayer
end

--[[
	@desc	: 创建战车装备位置UI
	@param	: pCurPos 当前显示的位置
    @return	: 
--]]
function createEquipChariot( pCurPos )
	local posNum = ChariotMainData.getCanEquipPosNum()
	-- 位置大于 1 ，才创建滑动提示箭头
	if (posNum > 1) then
		-- 左箭头 
		_leftArrowSp = CCSprite:create("images/formation/btn_left.png")
	    _leftArrowSp:setAnchorPoint(ccp(0,0.5))
	    _leftArrowSp:setPosition(0,_bgLayer:getContentSize().height*0.5)
	    _bgLayer:addChild(_leftArrowSp,5)
	    _leftArrowSp:setVisible(false)
	    _leftArrowSp:setScale(g_fElementScaleRatio)
	    ChariotUtil.runArrowAction(_leftArrowSp)

		-- 右箭头 
	    _rightArrowSp = CCSprite:create("images/formation/btn_right.png")
	    _rightArrowSp:setAnchorPoint(ccp(1,0.5))
	    _rightArrowSp:setPosition(_bgLayer:getContentSize().width,_bgLayer:getContentSize().height*0.5)
	    _bgLayer:addChild(_rightArrowSp,5)
	    _rightArrowSp:setVisible(true)
	    _rightArrowSp:setScale(g_fElementScaleRatio)
	    ChariotUtil.runArrowAction(_rightArrowSp)
	end

	-- 创建战车滑动列表
	local tabViewSize = CCSizeMake(_bgLayer:getContentSize().width,_bgLayer:getContentSize().height-100*g_fElementScaleRatio)
    local eventHandler = function ( functionName, tableView, index, cell )
		if functionName == "cellSize" then
			return tabViewSize
		elseif functionName == "cellAtIndex" then
			local chariotInfo = ChariotMainData.getEquipChariotInfoByPos(index)
			local tCell = ChariotEquipCell.createCell(ChariotDef.kCellShowTypeEquip,chariotInfo,index,tabViewSize,_touchPriority)
			return tCell
		elseif functionName == "numberOfCells" then
			return posNum
		elseif functionName == "cellTouched" then
			
		elseif functionName == "scroll" then
			
		elseif functionName == "moveEnd" then
			-- 更新箭头
    		updateArrowShowSttus(index)
		end
	end
	-- 战车tabView
    _chariotTabView = STTableView:create()
    _chariotTabView:setDirection(kCCScrollViewDirectionHorizontal)
    _chariotTabView:setContentSize(tabViewSize)
	_chariotTabView:setEventHandler(eventHandler)
	-- _chariotTabView:setPageViewEnabled(true)
	_chariotTabView:setPageViewEnabled((posNum > 1))
	_chariotTabView:setTouchPriority(_touchPriority - 10)
	_bgLayer:addChild(_chariotTabView,10)
	_chariotTabView:reloadData()


	-- 设置显示当前战车
	if (pCurPos and pCurPos > 0) then
		_chariotTabView:showCellByIndex(pCurPos)
		updateArrowShowSttus(pCurPos)
	end
end

--[[
	@desc	: 更新箭头显示状态
	@param	: pIndex 当前位置
	@return	:
--]]
function updateArrowShowSttus( pIndex )
	-- 根据当前的显示的位置,更新箭头显示
	local posNum = ChariotMainData.getCanEquipPosNum()
	if (posNum > 1) then
		if (pIndex == 1) then 
			_leftArrowSp:setVisible(false)
			_rightArrowSp:setVisible(true)
		elseif (pIndex == posNum) then 
			_leftArrowSp:setVisible(true)
			_rightArrowSp:setVisible(false)
		else
			_leftArrowSp:setVisible(true)
			_rightArrowSp:setVisible(true)
		end
	end
end

--[[
	@desc	: 刷新所有的Cell
	@param	: 
	@return	:
--]]
function updateAllCell()
	if tolua.isnull(_bgLayer) then
		return
	end
	-- 全部Cell都刷新
	_chariotTabView:refresh()
end

--[[
	@desc	: 刷新指定位置的Cell
	@param	: pPos 刷新位置
	@return	:
--]]
function updateCellByPos( pPos )
	if tolua.isnull(_bgLayer) then
		return
	end
	if (pPos and pPos > 0) then
		_chariotTabView:updateCellAtIndex(pPos)
	end
end

--[[
	@desc	: 点击图鉴按钮回调方法，显示战车图鉴
	@param 	: 
    @return	: 
--]]
function illustrateItemCallback()
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/chariot/illustrate/ChariotIllustrateController"
	ChariotIllustrateController.getChariotBook(function()
		require "script/ui/chariot/illustrate/ChariotIllustrateLayer"
		ChariotIllustrateLayer.showLayer(_touchPriority-100,_zOrder+10)
	end)
end

--[[
	@desc 	: 返回按钮回调，切回到主界面
	@param 	: 
	@return : 
--]]
function backItemCallback()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	-- 进入主界面
	require "script/ui/main/MainBaseLayer"
	local mainBaseLayer = MainBaseLayer.create()
	MainScene.changeLayer(mainBaseLayer, "main_base_layer",MainBaseLayer.exit)
	MainScene.setMainSceneViewsVisible(true,true,true)
end
