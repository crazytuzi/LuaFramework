-- FileName: KFBWShopLayer.lua
-- Author: shengyixian
-- Date: 2015-09-30
-- Purpose: 跨服比武商店
module("KFBWShopLayer",package.seeall)
require "script/ui/kfbw/kfbwshop/KFBWShopCell"
require "script/ui/kfbw/kfbwshop/KFBWShopData"
require "script/ui/kfbw/kfbwshop/KFBWShopController"
require "script/ui/kfbw/KuafuData"

-- 背景层
local _layer = nil
-- 元素容器
local _eleContainer = nil
-- 触摸优先级
local _touchPriority = nil
-- 荣誉值文本
local _honorValueLabel = nil
-- 表示图背景
local _tableViewSp = nil
-- 表视图
local _tableView = nil
-- 不在商店整合中显示
local _isShow = nil
-- 层的尺寸
local _centerSize = nil
-- 中心层
local _centerLayer = nil
-- 武将精华数量文本
local _heroJhValueLabel = nil

function init( ... )
	-- body
	_layer = nil
	_eleContainer = nil
	_honorValueLabel = nil
	_tableViewSp = nil
	_tableView = nil
	_layerSize = nil
	_isShow = nil
	_centerLayer = nil
	_heroJhValueLabel = nil
end

function initView( ... )
	-- body
	 if not _isShow then
    	-- 从商店整合进入
        local rect = CCRectMake(0,0,55,50)
        local innerRect = CCRectMake(26,30,6,4)
        local underLayer = CCScale9Sprite:create("images/bounty/shop_bg.png",rect,innerRect)
        underLayer:setContentSize(_centerSize)
        underLayer:setAnchorPoint(ccp(0,0))
        underLayer:setPosition(ccp(0,0))
        _centerLayer:addChild(underLayer)
        --上波浪
        local up = CCSprite:create("images/match/shang.png")
        up:setAnchorPoint(ccp(0,1))
        up:setPosition(ccp(0, _centerSize.height))
        up:setScale(g_fScaleX)
        underLayer:addChild(up)
        --下波浪
        local down = CCSprite:create("images/match/xia.png")
        down:setPosition(ccp(0,0))
        down:setScale(g_fScaleX)
        underLayer:addChild(down)
    else
    	-- 从活动界面进入
    	-- 按钮
		local menu = CCMenu:create()
		menu:setTouchPriority(_touchPriority)
    	menu:setAnchorPoint(ccp(1,1))
		menu:setPosition(ccp(0,0))
		menu:setTouchPriority(_touchPriority)
		_layer:addChild(menu)
		-- 关闭按钮
		local closeButton = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
		closeButton:setAnchorPoint(ccp(0, 1))
		closeButton:registerScriptTapHandler(closeButtonCallFunc)
		closeButton:setPosition(ccp(_layer:getContentSize().width-closeButton:getContentSize().width*g_fScaleX-10*g_fScaleX,_layer:getContentSize().height-KuafuLayer.getBoardHeight()*g_fScaleX-20*g_fScaleX))
		closeButton:setScale(g_fScaleX)
		menu:addChild(closeButton)
	end
	-- 背景人物
    local bgFigure = CCSprite:create("images/kfbw/kfbwshop/bg_figure.png")
    bgFigure:setAnchorPoint(ccp(0,0.5))
    bgFigure:setPosition(ccp(-(bgFigure:getContentSize().width / 4 + 35),_centerSize.height*0.5))
    _centerLayer:addChild(bgFigure)
    bgFigure:setScale(MainScene.elementScale)
    -- 标题
    local title = CCSprite:create("images/kfbw/kfbwshop/title.png")
    title:setAnchorPoint(ccp(0.5,1))
    title:setPosition(ccp(_centerLayer:getContentSize().width*0.5,_centerLayer:getContentSize().height))
    _centerLayer:addChild(title)
    title:setScale(MainScene.elementScale)
   	-- “跨服荣誉”
    local honorLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1018"),g_sFontPangWa,23,1,ccc3(0, 0x00, 0x00))
	honorLabel:setColor(ccc3( 0xff, 0xf6, 0x00))
	honorLabel:setAnchorPoint(ccp(0,1))
	honorLabel:setPosition(ccp(g_winSize.width*0.26,title:getPositionY() - title:getContentSize().height*g_fScaleX))
	_centerLayer:addChild(honorLabel)
	honorLabel:setScale(g_fScaleX)
	--跨服图标
	local honorIcon = CCSprite:create("images/kfbw/kfbwshop/rongyushengji.png")
	honorLabel:addChild(honorIcon)
	honorIcon:setAnchorPoint(ccp(0,0))
	honorIcon:setPosition(ccp(honorLabel:getContentSize().width,0))
	-- 荣誉值
    _honorValueLabel = CCRenderLabel:create(UserModel.getCrossHonor(),g_sFontPangWa,23,1,ccc3(0, 0x00, 0x00))
	_honorValueLabel:setColor(ccc3( 0x00, 0xff, 0x18))
	_honorValueLabel:setAnchorPoint(ccp(0,0.5))
	_honorValueLabel:setPosition(ccp(honorLabel:getContentSize().width+honorIcon:getContentSize().width,12))
	honorLabel:addChild(_honorValueLabel)
	-- “武将精华”
    local heroJhLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1053"),g_sFontPangWa,23,1,ccc3(0, 0x00, 0x00))
	heroJhLabel:setColor(ccc3( 0xff, 0xf6, 0x00))
	heroJhLabel:setAnchorPoint(ccp(0,1))
	heroJhLabel:setPosition(ccp(g_winSize.width*0.65,honorLabel:getPositionY()))
	_centerLayer:addChild(heroJhLabel)
	heroJhLabel:setScale(g_fScaleX)
	--将星图标
	local heroIcon = CCSprite:create("images/kfbw/kfbwshop/jiangxing.png")
	heroJhLabel:addChild(heroIcon)
	heroIcon:setAnchorPoint(ccp(0,0))
	heroIcon:setPosition(ccp(heroJhLabel:getContentSize().width,0))
	_heroJhValueLabel = CCRenderLabel:create(UserModel.getHeroJh(),g_sFontPangWa,23,1,ccc3(0, 0x00, 0x00))
	_heroJhValueLabel:setColor(ccc3( 0x00, 0xff, 0x18))
	_heroJhValueLabel:setAnchorPoint(ccp(0,0.5))
	_heroJhValueLabel:setPosition(ccp(heroJhLabel:getContentSize().width+heroIcon:getContentSize().width,12))
	heroJhLabel:addChild(_heroJhValueLabel)
	-- 表视图背景
	local rect = CCRectMake(0,0,67,67)
	local insert = CCRectMake(27,29,12,10)
	local height = honorLabel:getPositionY() - honorLabel:getContentSize().height*g_fElementScaleRatio - 50*g_fScaleX
	_tableViewSp = CCScale9Sprite:create("images/warcraft/warcraft_formation_bg.png",rect,insert)
	_tableViewSp:setContentSize(CCSizeMake(462*g_fScaleX,height))
	_tableViewSp:setAnchorPoint(ccp(1,1))
	_tableViewSp:setPosition(ccp(g_winSize.width-10*g_fScaleX,honorLabel:getPositionY() - honorLabel:getContentSize().height*g_fScaleX))
	_centerLayer:addChild(_tableViewSp)
	createTableView()
end

function createLayer( ... )
	-- body
	init()
	_layer = CCLayerColor:create(ccc4(11,11,11,166))
	_layer:registerScriptTouchHandler(function (eventType,x,y)
		if eventType == "began" then
			--todo
			return true
		end
	end,false,_touchPriority,true)
	_layer:setTouchEnabled(true)
	return _layer
end

function showLayer(touchPriority,zOrder)
	-- body
	zOrder = zOrder or 555
	_touchPriority = touchPriority or -605
	local layer = createLayer()
	require "script/ui/shopall/ShoponeLayer"
	createCenterLayer(ShoponeLayer.getCenterSize(),touchPriority,zOrder,true)
    _centerLayer:ignoreAnchorPointForPosition(false)
    _centerLayer:setAnchorPoint(ccp(0.5, 0.5))
    _centerLayer:setPosition(ccpsprite(0.5, 0.5, _layer))
    _centerLayer:registerScriptTouchHandler(function (eventType,x,y)
		if eventType == "began" then
			--todo
			return true
		end
	end,false,_touchPriority,true)
	_centerLayer:setTouchEnabled(true)
    _layer:addChild(_centerLayer)
	local scene = CCDirector:sharedDirector():getRunningScene()
	scene:addChild(layer,zOrder)
end
--[[
	@des 	: 在商店整合中显示
	@param 	: 
	@return : 
--]]
function createCenterLayer( p_LayerSize,touchPriority,zOrder,isShow )
	-- body
	_touchPriority = touchPriority or -605
	_isShow = isShow
	_centerSize = p_LayerSize
	_centerLayer = CCLayer:create()
	_centerLayer:setContentSize(_centerSize)
	require "script/ui/kfbw/KuafuService"
	KFBWShopController.getItemInfo(function ( ... )
		-- body
		initView()
	end)
	return _centerLayer
end
--[[
	@des 	: 创建表示图
	@param 	: 
	@return : 
--]]
function createTableView()
	local tItemInfo = KFBWShopData.getItemInfo()
	local cellSize = CCSizeMake(442*g_fScaleX, 164*g_fScaleX)
	local luaHandler = LuaEventHandler:create(function(fn,t,a1,a2)
			local ret
			if fn == "cellSize" then
				ret = CCSizeMake(cellSize.width,cellSize.height)
			elseif fn == "cellAtIndex" then
				ret = KFBWShopCell.createCell(a1 + 1)
			elseif fn == "numberOfCells" then
				ret = #tItemInfo
			elseif fn == "cellTouched" then
			end
			return ret
		end
	)
	_tableView = LuaTableView:createWithHandler(luaHandler,CCSizeMake(442*g_fScaleX,_tableViewSp:getContentSize().height - 10))
	_tableView:setTouchPriority(_touchPriority - 2)
	_tableView:setBounceable(true)
	_tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_tableView:setAnchorPoint(ccp(0.5,0.5))
	_tableView:setPosition(ccpsprite(0.5,0.5,_tableViewSp))
    _tableView:ignoreAnchorPointForPosition(false)
	_tableViewSp:addChild(_tableView)
end

--[[
	@des 	: 关闭
	@param 	: 
	@return : 
--]]
function closeButtonCallFunc( ... )
	-- 播放关闭音效
	require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    if _layer then
		_layer:removeFromParentAndCleanup(true)
		_layer = nil
	end
end
--[[
	@des 	: 刷新
	@param 	: 
	@return : 
--]]
function refresh( ... )
	if _centerLayer then
		KFBWShopController.getItemInfo(function ()
			local offset = _tableView:getContentOffset()
	    	_tableView:removeFromParentAndCleanup(true)
	    	_tableView = nil
	    	createTableView()
	    	_tableView:setContentOffset(offset)
			_honorValueLabel:setString(UserModel.getCrossHonor())
			_heroJhValueLabel:setString(UserModel.getHeroJh())
	    end)
	end
end