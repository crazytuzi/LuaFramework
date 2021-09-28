-- FileName: TsTallyChooseLayer.lua
-- Author: lgx
-- Date: 2016-08-22
-- Purpose: 兵符转换选择界面

module("TsTallyChooseLayer", package.seeall)

require "script/ui/bag/TallyBagCell"
require "script/ui/transform/tstally/TsTallyData"

local kSpriteTag 		= 100 	-- 背景图Tag
local kMenuTag 			= 200	-- 菜单Tag
local kBtnTag 			= 300	-- 按钮Tag

-- UI控件引用变量 --
local _touchPriority 	= nil	-- 触摸优先级
local _zOrder 		 	= nil	-- 显示层级
local _bgLayer 		 	= nil	-- 背景层
local _topBg 			= nil 	-- 顶部视图

-- 模块局部变量 --
local _selectedCallback = nil 	-- 选择的回调

--[[
	@desc 	: 初始化方法
	@param 	: 
	@return : 
--]]
local function init()
	_touchPriority 		= nil
	_zOrder 			= nil
	_bgLayer 			= nil
	_topBg 				= nil
	_selectedCallback 	= nil
end

--[[
	@desc 	: 显示界面方法
	@param 	: pCallback 确定回调
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function showLayer( pCallback, pTouchPriority, pZorder )
	local layer = createLayer(pCallback,pTouchPriority, pZorder)
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
	@param 	: pCallback 确定回调
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function createLayer( pCallback, pTouchPriority, pZorder )
	-- 初始化
	init()

	_selectedCallback = pCallback
	_touchPriority = pTouchPriority or -550
	_zOrder = pZorder or 1000

	-- 背景层
	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
	_bgLayer:setPosition(ccp(0, 0))
	_bgLayer:registerScriptHandler(onNodeEvent)
	_bgLayer:setAnchorPoint(ccp(0, 0))

	-- 大背景
	local bgSprite = CCSprite:create("images/main/module_bg.png")
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
	bgSprite:setScale(g_fBgScaleRatio)
	_bgLayer:addChild(bgSprite)

	-- 顶部背景
	_topBg = CCSprite:create("images/hero/select/title_bg.png")
	_topBg:setAnchorPoint(ccp(0.5, 1))
	_topBg:setPosition(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height)
	_topBg:setScale(g_fScaleX)
	_bgLayer:addChild(_topBg)

	-- 选择标题
	local titleSp = CCSprite:create("images/tally/select_tally.png")
	titleSp:setAnchorPoint(ccp(0,0))
	titleSp:setPosition(ccp(45, 50))
	_topBg:addChild(titleSp)

	-- 返回按钮
    local backMenu = CCMenu:create()
    backMenu:setAnchorPoint(ccp(0,0))
    backMenu:setPosition(ccp(0,0))
    backMenu:setTouchPriority(_touchPriority-5)
    _topBg:addChild(backMenu)

	-- 创建返回按钮
	local backItem = CCMenuItemImage:create("images/hero/btn_back_n.png","images/hero/btn_back_h.png")
	backItem:setAnchorPoint(ccp(0, 0))
	backItem:setPosition(ccp(473, 40))
	backMenu:addChild(backItem)
	backItem:registerScriptTapHandler(backItemCallback)

	-- 创建兵符列表
	createSelectTableView()

    return _bgLayer
end

--[[
	@desc	: 创建选择兵符列表
    @param	: 
    @return	: 
—-]]
function createSelectTableView()
	local cellSize = CCSizeMake(639,170)
	cellSize.width = cellSize.width * g_fScaleX 
	cellSize.height = cellSize.height * g_fScaleX

	local topHeight = (_topBg:getContentSize().height-16)*g_fScaleX
	local tableViewHeight = _bgLayer:getContentSize().height - topHeight

	-- 获取数据
	local tallylListData = TsTallyData.getSortChooseItemData()
	local selectList = TsTallyData.getSelectTallyList()

	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width, cellSize.height)
		elseif fn == "cellAtIndex" then
	        a2 = createTallySelectCell(tallylListData[a1 + 1],TsTallyData.getIsInSelectListByItemId(tallylListData[a1 + 1].item_id))
	        a2:setScale(g_fScaleX)
			r = a2
		elseif fn == "numberOfCells" then
			r = #tallylListData
		elseif fn == "cellTouched" then
			local touchData = tallylListData[a1:getIdx()+1]
			local cellBg = tolua.cast(a1:getChildByTag(kSpriteTag), "CCSprite")
			local checkMenu = tolua.cast(cellBg:getChildByTag(kMenuTag), "CCMenu")
			local checkBtn = tolua.cast(checkMenu:getChildByTag(kBtnTag), "CCMenuItemSprite")
			checkBtn:selected()

			-- 添加数据
			addItemToSelectList(tonumber(touchData.item_id))

			require "script/audio/AudioUtil"
			AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

			-- 关闭界面
			closeChooseLayer()

			-- 回调
			if (_selectedCallback ~= nil) then 
				_selectedCallback()
			end
		else
		end
		return r
	end)

	local listTableView = LuaTableView:createWithHandler(handler, CCSizeMake(_bgLayer:getContentSize().width, tableViewHeight))
	listTableView:setAnchorPoint(ccp(0,0))
	listTableView:setBounceable(true)
	listTableView:setTouchPriority(_touchPriority-3)
	listTableView:setPosition(ccp(0,0))
	_bgLayer:addChild(listTableView)
end

--[[
	@desc	: 创建选择列表的兵符cell
    @param	: pTallyInfo 兵符信息
    @param 	: pIsSelected 是否选择
    @return	: CCTableViewCell 创建好的兵符Cell
—-]]
function createTallySelectCell( pTallyInfo, pIsSelected )
	require "script/ui/bag/TallyBagCell"
	local tCell = TallyBagCell.createCell(pTallyInfo,nil,nil,nil,nil,true)
	local cellBgSize = CCSizeMake(639,169)

	-- 用于根据kSpriteTag取sp
	local sp = CCSprite:create()
	sp:setContentSize(cellBgSize)
	tCell:addChild(sp,1,kSpriteTag)

    -- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(_touchPriority-5)
	sp:addChild(menuBar,1,kMenuTag)

	-- 复选框
	local checkedBtn = CheckBoxItem.create()
	checkedBtn:setAnchorPoint(ccp(0.5, 0.5))
    checkedBtn:setPosition(ccp(cellBgSize.width*580/640, cellBgSize.height*0.5))
    checkedBtn:setEnabled(false)
	menuBar:addChild(checkedBtn,1,kBtnTag)

	if pIsSelected == true then
		checkedBtn:selected()
	else
		checkedBtn:unselected()
	end
	return tCell
end

--[[
	@desc	: 添加兵符id到选择列表
    @param	: pItemId 兵符id
    @return	: 
—-]]
function addItemToSelectList( pItemId )
	-- 先清除
	TsTallyData.cleanSelectTallyList()
	-- 再添加
	TsTallyData.addTallyToSelectList(pItemId)
end

--[[
	@desc	: 返回按钮回调
    @param	: 
    @return	: 
—-]]
function backItemCallback()
	require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    closeChooseLayer()
end

--[[
	@desc	: 关闭界面
    @param	: 
    @return	: 
—-]]
function closeChooseLayer()
	if not tolua.isnull(_bgLayer) then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end
