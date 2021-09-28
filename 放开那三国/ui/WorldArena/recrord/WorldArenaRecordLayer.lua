-- FileName: WorldArenaRecordLayer.lua
-- Author: licong
-- Date: 2015-07-01
-- Purpose: 巅峰对决战报主界面
--[[TODO List]]

module("WorldArenaRecordLayer", package.seeall)

require "script/ui/WorldArena/recrord/WorldArenaRecordData"
require "script/ui/WorldArena/recrord/WorldArenaRecordService"

local _bgLayer  						= nil
local _viewBg  							= nil
local _recordTableView 					= nil 

local _curRecordType  					= nil 
local _curRecordItem 					= nil	 
	
local _touchPriority  					= nil
local _zOrder 							= nil

local _recordTab 						= nil


--[[
	@des 	: 初始化
	@param 	: 
	@return : 
--]]
function init( ... )
	_bgLayer  							= nil
	_viewBg  							= nil
	_recordTableView 					= nil

	_curRecordType  					= nil
	_curRecordItem 						= nil

	_touchPriority  					= nil
	_zOrder 							= nil	

	_recordTab 							= nil

end

--[[
	@des 	: touch事件处理
	@param 	: 
	@return : 
--]]
local function onTouchesHandler( eventType, x, y )
	return true
end

--[[
	@des 	: onNodeEvent事件
	@param 	: 
	@return : 
--]]
local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end


--[[
	@des 	:关闭按钮回调
	@param 	:
	@return :
--]]
function closeBtnCallFunc( tag, itemBtn )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

   	if( _bgLayer ~= nil )then
   		_bgLayer:removeFromParentAndCleanup(true)
   		_bgLayer = nil
   	end
end

--[[
	@des 	:战报按钮回调
	@param 	:
	@return :
--]]
function menuItemCallFun( tag, itemBtn )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    itemBtn:selected()
	if(itemBtn ~= _curRecordItem ) then 
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
		_curRecordItem:unselected()
		_curRecordItem = itemBtn
		_curRecordItem:selected()
		_curRecordType = tag

		_recordTab = WorldArenaRecordData.getListData(_curRecordType)
		_recordTableView:reloadData()
	end
   
end

---------------------------------------------------------------------------- 创建UI -------------------------------------------------------------------------------------------
--[[
	@des 	: 创建tableview
	@param 	: 
	@return : 
--]]
function createTableView( ... )
	-- 按钮
    local menuBar = CCMenu:create()
    menuBar:setAnchorPoint(ccp(0,0))
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_touchPriority-5)
    _viewBg:addChild(menuBar)

    -- 标题
    local textTab = {GetLocalizeStringBy("lic_1679"),GetLocalizeStringBy("lic_1680")}
    local posX = {0.3,0.7}
    for i=1, #textTab do
		local rect_full_n 	= CCRectMake(0,0,63,43)
		local rect_inset_n 	= CCRectMake(25,20,13,3)
		local normalSp = CCScale9Sprite:create("images/common/bg/button/ng_tab_n.png",rect_full_n, rect_inset_n)
		normalSp:setContentSize(CCSizeMake(170,45))
		local normalText = CCLabelTTF:create( textTab[i],g_sFontPangWa, 24)
		normalText:setColor(ccc3(0x78,0x25,0x00))
		normalText:setAnchorPoint(ccp(0.5,0.5))
		normalText:setPosition(ccp(normalSp:getContentSize().width*0.5,normalSp:getContentSize().height*0.5))
		normalSp:addChild(normalText)

		local rect_full_h 	= CCRectMake(0,0,73,53)
		local rect_inset_h 	= CCRectMake(35,25,3,3)
		local selectSp = CCScale9Sprite:create("images/common/bg/button/ng_tab_h.png",rect_full_h,rect_inset_h)
		selectSp:setContentSize(CCSizeMake(170,53))
		local selectText = CCRenderLabel:create(  textTab[i],g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		selectText:setColor(ccc3(0xff,0xff,0xff))
		selectText:setAnchorPoint(ccp(0.5,0.5))
		selectText:setPosition(ccp(selectSp:getContentSize().width*0.5,selectSp:getContentSize().height*0.5))
		selectSp:addChild(selectText)
		
	    local menuItem = CCMenuItemSprite:create(normalSp, selectSp)
		menuItem:setAnchorPoint(ccp(0.5,0))
		menuBar:addChild(menuItem,1,i)
		menuItem:setPosition(ccp(_viewBg:getContentSize().width*posX[i],_viewBg:getContentSize().height))
		-- 注册回调
		menuItem:registerScriptTapHandler(menuItemCallFun)

		if( i == 1)then
			_curRecordItem = menuItem
			_curRecordItem:selected()
			_curRecordType = i
		end
	end

	_recordTab = WorldArenaRecordData.getListData(_curRecordType)
    require "script/ui/WorldArena/recrord/WorldArenaRecordCell"
    local cellSize = CCSizeMake(565, 180) 
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
			r = WorldArenaRecordCell.createCell(_recordTab[a1+1], _curRecordType, _touchPriority-3)
		elseif fn == "numberOfCells" then
			r =  #_recordTab
		else
		end
		return r
	end)

	_recordTableView = LuaTableView:createWithHandler(h, CCSizeMake(570, 620))
	_recordTableView:setBounceable(true)
	_recordTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_recordTableView:setTouchPriority(_touchPriority-4)
	_recordTableView:ignoreAnchorPointForPosition(false)
	_recordTableView:setAnchorPoint(ccp(0.5,0.5))
	_recordTableView:setPosition(ccp(_viewBg:getContentSize().width*0.5,_viewBg:getContentSize().height*0.5))
	_viewBg:addChild(_recordTableView)

end

--[[
	@des 	: 创建主界面
	@param 	: 
	@return : 
--]]
function createLayer( ... )

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,166))
	_bgLayer:registerScriptHandler(onNodeEvent) 

	-- 背景
	local bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
    bgSprite:setContentSize(CCSizeMake(630, 800))
    bgSprite:setAnchorPoint(ccp(0.5,0.5))
    bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(bgSprite)
    setAdaptNode(bgSprite)
    
    -- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(bgSprite:getContentSize().width/2, bgSprite:getContentSize().height-6.6 ))
	bgSprite:addChild(titlePanel)
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1678"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	-- 关闭按钮
	local menu = CCMenu:create()
    menu:setTouchPriority(_touchPriority-5)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	bgSprite:addChild(menu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(bgSprite:getContentSize().width * 0.955, bgSprite:getContentSize().height*0.975 ))
	closeButton:registerScriptTapHandler(closeBtnCallFunc)
	menu:addChild(closeButton)

	-- 二级背景
	_viewBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	_viewBg:setContentSize(CCSizeMake(580,640))
 	_viewBg:setAnchorPoint(ccp(0.5,1))
 	_viewBg:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height-100))
 	bgSprite:addChild(_viewBg)

 	-- 创建tableView
 	createTableView()

	return _bgLayer
end

--[[
	@des 	: 显示主界面
	@param 	: 
	@return : 
--]]
function showLayer( p_touchPriority, p_zOrder )

	local nextCallFun = function ( p_data )
		-- 缓存数据
		WorldArenaRecordData.setRecordInfo(p_data)
		
		-- 初始化
		init()

		_touchPriority = p_touchPriority or -500
		_zOrder = p_zOrder or 1010

		local runningScene = CCDirector:sharedDirector():getRunningScene()
	    local layer = createLayer()
	    runningScene:addChild(layer,_zOrder)
	end
	WorldArenaRecordService.getRecordList( nextCallFun )
end


