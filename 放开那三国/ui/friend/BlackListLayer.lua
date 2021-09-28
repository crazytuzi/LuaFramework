-- FileName: BlackListLayer.lua 
-- Author: licong 
-- Date: 14-6-10 
-- Purpose: 黑名单


module("BlackListLayer", package.seeall)

local _bgLayer 						= nil        
local _content_bg 					= nil
local _listTableView 				= nil
local _listWidth 					= nil
local _listHeight 					= nil      
local _curDataFont 					= nil
local _blackListData 				= nil

-- 初始化
local function init( ... )
	_bgLayer 						= nil        
	_content_bg 					= nil
	_listTableView 					= nil
	_listWidth 						= nil
	_listHeight 					= nil      
	_curDataFont 					= nil
	_blackListData 					= nil
end


--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		print("enter")
	elseif (event == "exit") then
		print("exit")
		_bgLayer = nil
	end
end

-- 创建滑动列表
local function createTabView()
	-- 显示单元格背景的size
	local cell_bg_size = { width = 584, height = 110 } 
	-- 得到黑名单列表数据
	_blackListData = FriendData.getBlackListData()
	print("黑名单数据")
	print_t(_blackListData)
	require "script/ui/friend/BlackListCell"
	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if (fn == "cellSize") then
			-- 显示单元格的间距
			local interval = 10
			r = CCSizeMake(cell_bg_size.width*g_fScaleX, (cell_bg_size.height + interval)*g_fScaleX)
		elseif (fn == "cellAtIndex") then
			r = BlackListCell.createCell(_blackListData[a1+1])
			r:setScale(g_fScaleX)
		elseif (fn == "numberOfCells") then
			r = #_blackListData
		else
		end
		return r
	end)

	_listTableView = LuaTableView:createWithHandler(handler, CCSizeMake(_listWidth,_listHeight))
	_listTableView:setBounceable(true)
	_listTableView:ignoreAnchorPointForPosition(false)
	_listTableView:setAnchorPoint(ccp(0.5, 1))
	_listTableView:setPosition(ccp(_content_bg:getPositionX(),_content_bg:getPositionY()-4*MainScene.elementScale))
	_bgLayer:addChild(_listTableView)
	-- 设置单元格升序排列
	_listTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	-- 设置滑动列表的优先级
	_listTableView:setTouchPriority(-130)
end



-- 创建好友层
local function initLayer( ... )
	-- 内容背景
	_content_bg = BaseUI.createContentBg(CCSizeMake((_bgLayer:getContentSize().width-50*MainScene.elementScale),(_bgLayer:getContentSize().height-345*MainScene.elementScale)))
	_content_bg:setAnchorPoint(ccp(0.5,1))
	_content_bg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height-250*MainScene.elementScale))
	_bgLayer:addChild(_content_bg)
	_listWidth = _bgLayer:getContentSize().width-50*MainScene.elementScale
	_listHeight = _bgLayer:getContentSize().height-355*MainScene.elementScale

    -- 创建列表
    createTabView()

	-- 当前黑名单
	local curFriend_font = CCRenderLabel:create( GetLocalizeStringBy("lic_1050") , g_sFontPangWa, 30*MainScene.elementScale, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
    curFriend_font:setColor(ccc3(0x78, 0x25, 0x00))
    curFriend_font:setPosition(ccp(146*MainScene.elementScale,73*MainScene.elementScale))
    _bgLayer:addChild(curFriend_font)
    -- 当前数量
    _curDataFont = CCRenderLabel:create( table.count(_blackListData) .. "/100" , g_sFontPangWa, 35*MainScene.elementScale, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _curDataFont:setColor(ccc3(0xff, 0xf6, 0x00))
    _curDataFont:setAnchorPoint(ccp(0,1))
    _curDataFont:setPosition(ccp(355*MainScene.elementScale,75*MainScene.elementScale))
    _bgLayer:addChild(_curDataFont)

end

-- 刷新tableView
function refreshTableView( ... )
	local lastHight = table.count(_blackListData) * 120*g_fScaleX
	_blackListData = FriendData.getBlackListData()
	local newHight = table.count(_blackListData) * 120*g_fScaleX
	local offset = _listTableView:getContentOffset()
	_listTableView:reloadData()
	print("offset -- ", offset.y)
	if(lastHight > newHight)then
		if( offset.y ~= 0)then
			_listTableView:setContentOffset(ccp(offset.x,offset.y+120*g_fScaleX))
		end
	else
		_listTableView:setContentOffset(offset)
	end
end

-- 刷新黑名单数量
function refreshCurNumFont( )
	if(_curDataFont ~= nil)then
		_curDataFont:removeFromParentAndCleanup(true)
		_curDataFont = nil
	end
	_curDataFont = CCRenderLabel:create( table.count(_blackListData) .. "/100" , g_sFontPangWa, 35*MainScene.elementScale, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _curDataFont:setColor(ccc3(0xff, 0xf6, 0x00))
    _curDataFont:setAnchorPoint(ccp(0,1))
    _curDataFont:setPosition(ccp(355*MainScene.elementScale,75*MainScene.elementScale))
    _bgLayer:addChild(_curDataFont)
end

-- 创建黑名单层
function createBlackListLayer( ... )
	init()
	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)

	-- 创建下一步UI
	local function createNext( ... )
		-- 初始化
		initLayer()
	end
	FriendService.getBlackers(createNext)

	return _bgLayer
end







