-- FileName: WorldArenaRankLayer.lua
-- Author: licong
-- Date: 2015-07-01
-- Purpose: 排行榜 主界面
--[[TODO List]]

module("WorldArenaRankLayer", package.seeall)

require "script/ui/WorldArena/rank/WorldArenaRankService"
require "script/ui/WorldArena/rank/WorldArenaRankData"

local _bgLayer  						= nil
local _viewBg  							= nil
local _rankTableView 					= nil

local _curRankType  					= nil
local _curRankItem 						= nil	
	
local _touchPriority  					= nil
local _zOrder 							= nil

local _rankData 						= nil

--[[
	@des 	: 初始化
	@param 	: 
	@return : 
--]]
function init( ... )
	_bgLayer  							= nil
	_viewBg  							= nil
	_rankTableView 						= nil

	_curRankType  						= nil
	_curRankItem 						= nil

	_touchPriority  					= nil
	_zOrder 							= nil	

	_rankData 							= nil

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
	@des 	:排行按钮回调
	@param 	:
	@return :
--]]
function menuItemCallFun( tag, itemBtn )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    itemBtn:selected()
	if(itemBtn ~= _curRankItem ) then 
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
		_curRankItem:unselected()
		_curRankItem = itemBtn
		_curRankItem:selected()
		_curRankType = tag

		_rankData = WorldArenaRankData.getRankInfoByTpye( _curRankType )
		_rankTableView:reloadData()
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
    menuBar:setTouchPriority(_touchPriority-3)
    _viewBg:addChild(menuBar)

    -- 标题
    local textTab = {GetLocalizeStringBy("lic_1672"),GetLocalizeStringBy("lic_1673"),GetLocalizeStringBy("lic_1671")}
    local posX = {0.2,0.5,0.8}
    for i=1, #textTab do
		local rect_full_n 	= CCRectMake(0,0,63,43)
		local rect_inset_n 	= CCRectMake(25,20,13,3)
		local normalSp = CCScale9Sprite:create("images/common/bg/button/ng_tab_n.png",rect_full_n, rect_inset_n)
		normalSp:setContentSize(CCSizeMake(170,45))
		local normalText = CCLabelTTF:create( textTab[i],g_sFontPangWa, 24)
		normalText:setColor(ccc3(0xf4,0xdf,0xcb))
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
			_curRankItem = menuItem
			_curRankItem:selected()
			_curRankType = i
		end
	end

    _rankData = WorldArenaRankData.getRankInfoByTpye( _curRankType )
    require "script/ui/WorldArena/rank/WorldArenaRankCell"
	local cellBg = CCSprite:create("images/match/rank_bg.png")
    local cellSize = cellBg:getContentSize() 
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width, cellSize.height+10)
		elseif fn == "cellAtIndex" then
			r = WorldArenaRankCell.createCell(_rankData[a1+1], _curRankType)
		elseif fn == "numberOfCells" then
			r =  #_rankData
		else
		end
		return r
	end)

	_rankTableView = LuaTableView:createWithHandler(h, CCSizeMake(570, 580))
	_rankTableView:setBounceable(true)
	_rankTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_rankTableView:setTouchPriority(_touchPriority-2)
	_rankTableView:ignoreAnchorPointForPosition(false)
	_rankTableView:setAnchorPoint(ccp(0.5,0.5))
	_rankTableView:setPosition(ccp(_viewBg:getContentSize().width*0.5,_viewBg:getContentSize().height*0.5))
	_viewBg:addChild(_rankTableView)

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
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1665"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	-- 关闭按钮
	local menu = CCMenu:create()
    menu:setTouchPriority(_touchPriority-3)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	bgSprite:addChild(menu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(bgSprite:getContentSize().width * 0.955, bgSprite:getContentSize().height*0.975 ))
	closeButton:registerScriptTapHandler(closeBtnCallFunc)
	menu:addChild(closeButton)

	-- 你的战绩
	local tipTitle = CCLabelTTF:create(GetLocalizeStringBy("lic_1666"),g_sFontPangWa, 24)
	tipTitle:setColor(ccc3(0x78,0x25,0x00))
	tipTitle:setAnchorPoint(ccp(0.5,1))
	tipTitle:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height-40))
	bgSprite:addChild(tipTitle)

	-- 击杀排行榜
	local tipFont1 = CCLabelTTF:create(GetLocalizeStringBy("lic_1668"),g_sFontPangWa, 22)
	tipFont1:setColor(ccc3(0x78,0x25,0x00))
	tipFont1:setAnchorPoint(ccp(0,0.5))
	tipFont1:setPosition(ccp(30,tipTitle:getPositionY()-tipTitle:getContentSize().height-20))
	bgSprite:addChild(tipFont1)
	-- 排行数字
	local str1 = WorldArenaRankData.getMyRankInfoByTpye(1)
	if(str1 == nil)then
		str1 = GetLocalizeStringBy("lic_1670")
	end
	local tipNum1 = CCRenderLabel:create(str1, g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	tipNum1:setColor(ccc3(0x00,0xff,0x18))
	tipNum1:setAnchorPoint(ccp(0,0.5))
	tipNum1:setPosition(ccp(tipFont1:getPositionX()+tipFont1:getContentSize().width,tipFont1:getPositionY()))
	bgSprite:addChild(tipNum1)

	--连杀排行榜
	local tipFont2 = CCLabelTTF:create(GetLocalizeStringBy("lic_1669"),g_sFontPangWa, 22)
	tipFont2:setColor(ccc3(0x78,0x25,0x00))
	tipFont2:setAnchorPoint(ccp(0,0.5))
	tipFont2:setPosition(ccp(230,tipFont1:getPositionY()))
	bgSprite:addChild(tipFont2)
	-- 排行数字
	local str2 = WorldArenaRankData.getMyRankInfoByTpye(2)
	if(str2 == nil)then
		str2 = GetLocalizeStringBy("lic_1670")
	end
	local tipNum2 = CCRenderLabel:create(str2, g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	tipNum2:setColor(ccc3(0x00,0xff,0x18))
	tipNum2:setAnchorPoint(ccp(0,0.5))
	tipNum2:setPosition(ccp(tipFont2:getPositionX()+tipFont2:getContentSize().width,tipFont2:getPositionY()))
	bgSprite:addChild(tipNum2)

	-- 对决排行榜 
	local tipFont3 = CCLabelTTF:create(GetLocalizeStringBy("lic_1667"),g_sFontPangWa, 22)
	tipFont3:setColor(ccc3(0x78,0x25,0x00))
	tipFont3:setAnchorPoint(ccp(0,0.5))
	tipFont3:setPosition(ccp(430,tipFont1:getPositionY()))
	bgSprite:addChild(tipFont3)
	-- 排行数字
	local str3 = WorldArenaRankData.getMyRankInfoByTpye(3)
	if(str3 == nil)then
		str3 = GetLocalizeStringBy("lic_1670")
	end
	local tipNum3 = CCRenderLabel:create(str3, g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	tipNum3:setColor(ccc3(0x00,0xff,0x18))
	tipNum3:setAnchorPoint(ccp(0,0.5))
	tipNum3:setPosition(ccp(tipFont3:getPositionX()+tipFont3:getContentSize().width,tipFont3:getPositionY()))
	bgSprite:addChild(tipNum3)

	-- 二级背景
	_viewBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	_viewBg:setContentSize(CCSizeMake(580,600))
 	_viewBg:setAnchorPoint(ccp(0.5,1))
 	_viewBg:setPosition(ccp(bgSprite:getContentSize().width*0.5,tipFont1:getPositionY()-80))
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
		WorldArenaRankData.setRankInfo(p_data)

		-- 初始化
		init()

		_touchPriority = p_touchPriority or -500
		_zOrder = p_zOrder or 1010

		local runningScene = CCDirector:sharedDirector():getRunningScene()
	    local layer = createLayer()
	    runningScene:addChild(layer,_zOrder)
	end
    WorldArenaRankService.getRankList(nextCallFun)
end


