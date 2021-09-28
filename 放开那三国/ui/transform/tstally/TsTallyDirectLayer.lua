-- FileName: TsTallyDirectLayer.lua
-- Author: lgx
-- Date: 2016-08-22
-- Purpose: 兵符转换定向选择界面

module("TsTallyDirectLayer", package.seeall)

require "script/ui/transform/tstally/TsTallyData"
require "script/ui/item/ItemUtil"
require "script/utils/BaseUI"

-- UI控件引用变量 --
local _touchPriority 	= nil	-- 触摸优先级
local _zOrder 		 	= nil	-- 显示层级
local _bgLayer 		 	= nil	-- 背景层
local _tableViewBg 		= nil 	-- tableView的背景
local _listTableView 	= nil 	-- tableView

-- 模块局部变量 --
local _oldTid 			= nil 	-- 原Tid
local _selectTid 		= nil 	-- 选择的Tid
local _cormfirmCallback = nil 	-- 确定回调

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
	_listTableView		= nil
	_oldTid 			= nil
	_selectTid 			= nil
	_cormfirmCallback 	= nil
end

--[[
	@desc 	: 显示界面方法
	@param 	: pCallback 确定回调
	@param 	: pOldTid 原兵符Tid
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function showLayer( pCallback, pOldTid, pTouchPriority, pZorder )
	local layer = createLayer(pCallback, pOldTid,pTouchPriority, pZorder)
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
	@param 	: pOldTid 原兵符Tid
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function createLayer( pCallback, pOldTid, pTouchPriority, pZorder )
	-- 初始化
	init()

	_cormfirmCallback = pCallback
	_oldTid = pOldTid or 0
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

	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1795"), g_sFontPangWa, 33)
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
	_tableViewBg = BaseUI.createContentBg(CCSizeMake(590, 320))
	_tableViewBg:setAnchorPoint(ccp(0.5,1))
	_tableViewBg:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height-50))
	bgSprite:addChild(_tableViewBg)

	-- 创建列表
	createTableView()

	-- 提示文字
	local tipFont = CCLabelTTF:create(GetLocalizeStringBy("lgx_1105"), g_sFontPangWa, 25)
	tipFont:setColor(ccc3(0x78, 0x25, 0x00))
	tipFont:setAnchorPoint(ccp(0.5,0.5))
	tipFont:setPosition(ccp(bgSprite:getContentSize().width*0.5, _tableViewBg:getPositionY()-_tableViewBg:getContentSize().height-30))
	bgSprite:addChild(tipFont)

	-- 更换按钮
	local cormfirmItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("lic_1097"),ccc3(0xfe,0xdb,0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	cormfirmItem:setAnchorPoint(ccp(0.5, 0))
	cormfirmItem:setPosition(ccp(bgSprite:getContentSize().width*0.5, 30))
	closeMenu:addChild(cormfirmItem)
	cormfirmItem:registerScriptTapHandler(cormfirmItemCallBack)

    return _bgLayer
end

--[[
	@desc	: 创建定向选择兵符列表
    @param	: 
    @return	: 
—-]]
function createTableView()
	local showItems = TsTallyData.getTsTallyItemByTid(_oldTid)
	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(590, 140)
		elseif fn == "cellAtIndex" then
			a2 = CCTableViewCell:create()
			local posArrX = {0.13,0.37,0.62,0.87}
			for i=1,4 do
				if (showItems[a1*4+i] ~= nil) then
					local menu = BTSensitiveMenu:create()
					menu:setAnchorPoint(ccp(0,0))
					menu:setPosition(ccp(0,0))
					a2:addChild(menu)
					menu:setTouchPriority(_touchPriority-3)
					local normalSp = CCSprite:create()
					normalSp:setContentSize(CCSizeMake(80,80))
					local selectSp = CCSprite:create()
					selectSp:setContentSize(CCSizeMake(80,80))
					local menuItem = CCMenuItemSprite:create(normalSp,selectSp)
					menuItem:setAnchorPoint(ccp(0.5,1))
					menuItem:setPosition(ccp(590*posArrX[i],130))
					menu:addChild(menuItem,1,tonumber(showItems[a1*4+i]))
					-- 物品图标
					local tab = {}
					tab.tid = showItems[a1*4+i]
					tab.num = 1
					tab.type = "item"
					local iconSp = ItemUtil.createGoodsIcon(tab, nil, nil, nil, nil ,nil,true)
					menuItem:addChild(iconSp)
					iconSp:setAnchorPoint(ccp(0.5,1))
					iconSp:setPosition(menuItem:getContentSize().width*0.5,menuItem:getContentSize().height)
					-- 点击回调
					menuItem:registerScriptTapHandler(function ( tag, itemBtn )
						-- print("menuItem_selectTid",_selectTid,tag)
						require "script/audio/AudioUtil"
						AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
						_selectTid = tag
						-- 刷新tableview
						local offset = _listTableView:getContentOffset() 
						_listTableView:reloadData()
						_listTableView:setContentOffset(offset)
					end)

					-- print("_selectTid",_selectTid,tonumber(showItems[a1*4+i]))
					if (_selectTid == tonumber(showItems[a1*4+i])) then
						local selectedTagSprite = CCSprite:create("images/common/checked.png")
					    selectedTagSprite:setAnchorPoint(ccp(0.5, 0.5))
					    selectedTagSprite:setPosition(ccpsprite(0.5, 0.5, iconSp))
						iconSp:addChild(selectedTagSprite)
					end
				end
			end
			r = a2
		elseif fn == "numberOfCells" then
			local num = #showItems
			r = math.ceil(num/4)
			-- print("num is : ", num)
		else
		end
		return r
	end)

	_listTableView = LuaTableView:createWithHandler(handler, CCSizeMake(_tableViewBg:getContentSize().width,_tableViewBg:getContentSize().height-20))
	_listTableView:setBounceable(true)
	_listTableView:setTouchPriority(_touchPriority-4)
	_listTableView:ignoreAnchorPointForPosition(false)
	_listTableView:setAnchorPoint(ccp(0.5,0.5))
	_listTableView:setPosition(ccp(_tableViewBg:getContentSize().width*0.5,_tableViewBg:getContentSize().height*0.5))
	_tableViewBg:addChild(_listTableView)
	-- 设置单元格升序排列
	_listTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
end

--[[
	@desc	: 确定按钮回调
    @param	: 
    @return	: 
—-]]
function cormfirmItemCallBack()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	closeDirectLayer()
	-- 回调方法
	if (_cormfirmCallback ~= nil) then 
		_cormfirmCallback(_selectTid)
	end
end

--[[
	@desc	: 关闭按钮回调
    @param	: 
    @return	: 
—-]]
function closeItemCallback()
	require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    closeDirectLayer()
end

--[[
	@desc	: 关闭界面
    @param	: 
    @return	: 
—-]]
function closeDirectLayer()
	if not tolua.isnull(_bgLayer) then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end
