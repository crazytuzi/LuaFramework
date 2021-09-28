-- FileName: MissonTaskCell.lua
-- Author: shengyixian
-- Date: 2015-08-28
-- Purpose: 悬赏榜商店
module("MissionShopLayer",package.seeall)

require "script/ui/mission/shop/MissionShopCell"
require "script/ui/mission/shop/MissionShopController"

--界面层
local _layer = nil
--表示图背景
local _tableViewSp = nil
--触摸优先级
local _touchPriority = -390
-- 名望值文本
local _fameLabel = nil
-- 名望值
local _fameValueLabel = nil
-- 表示图
local _tableView = nil
-- 是否在商店整合中
local _isShow = nil
-- 中间层的尺寸
local _centerSize = nil
-- 中心层
local _centerLayer = nil
--[[
	@des 	: 初始化
	@param 	: 
	@return : 
--]]
function init()
	_layer = nil
	_tableViewSp = nil
	_fameLabel = nil
	_fameValueLabel = nil
	_tableView = nil
	_isShow = nil
	_centerLayer = nil
	_centerSize = nil
end
--[[
	@des 	: 初始化视图
	@param 	: 
	@return : 
--]]
function initView( ... )
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
    	local menu = CCMenu:create()
		menu:setTouchPriority(_touchPriority)
		menu:setPosition(ccp(0,0))
		_layer:addChild(menu)
		--关闭按钮
		local closeButton = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
		closeButton:setAnchorPoint(ccp(0.5, 0.5))
		closeButton:registerScriptTapHandler(closeButtonCallFunc)
		closeButton:setPosition(ccp(g_winSize.width * 0.9 ,g_winSize.height * 0.95))
		menu:addChild(closeButton)
		closeButton:setScale(g_fElementScaleRatio)
	end
    -- 背景人物
    local bgFigure = CCSprite:create("images/bounty/shop_bg_figure.png")
    bgFigure:setAnchorPoint(ccp(0,0.5))
    bgFigure:setPosition(ccp(-(bgFigure:getContentSize().width / 4 + 15),_centerSize.height*0.5))
    _centerLayer:addChild(bgFigure)
    bgFigure:setScale(MainScene.elementScale)
    -- 标题
    local title = CCSprite:create("images/bounty/shop_title.png")
    title:setAnchorPoint(ccp(0.5,1))
    title:setPosition(ccp(_centerLayer:getContentSize().width*0.5,_centerLayer:getContentSize().height))
    _centerLayer:addChild(title)
    title:setScale(MainScene.elementScale)
    -- “名望”
    _fameLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1007"),g_sFontPangWa,23,1,ccc3(0, 0x00, 0x00))
	_fameLabel:setColor(ccc3( 0xff, 0xf6, 0x00))
	_fameLabel:setAnchorPoint(ccp(0.5,1))
	_fameLabel:setPosition(ccp(g_winSize.width*0.6,title:getPositionY() - title:getContentSize().height*g_fScaleX))
	_centerLayer:addChild(_fameLabel)
	_fameLabel:setScale(g_fScaleX)
	-- 名望值
    _fameValueLabel = CCRenderLabel:create(UserModel.getFameNum(),g_sFontPangWa,23,1,ccc3(0, 0x00, 0x00))
	_fameValueLabel:setColor(ccc3( 0x00, 0xff, 0x18))
	_fameValueLabel:setAnchorPoint(ccp(0,0.5))
	_fameValueLabel:setPosition(ccp(3 + _fameLabel:getContentSize().width,12))
	_fameLabel:addChild(_fameValueLabel)
	-- 表视图背景
	local rect = CCRectMake(0,0,67,67)
	local insert = CCRectMake(27,29,12,10)
	local height = _fameLabel:getPositionY() - _fameLabel:getContentSize().height*g_fElementScaleRatio - 70*g_fScaleX
	_tableViewSp = CCScale9Sprite:create("images/warcraft/warcraft_formation_bg.png",rect,insert)
	_tableViewSp:setContentSize(CCSizeMake(444*g_fScaleX,height))
	_tableViewSp:setAnchorPoint(ccp(1,1))
	_tableViewSp:setPosition(ccp(g_winSize.width-10*g_fScaleX,_fameLabel:getPositionY() - _fameLabel:getContentSize().height*g_fScaleX))
	_centerLayer:addChild(_tableViewSp)
	createTableView()
	local explainLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1028"),g_sFontPangWa,23,1,ccc3( 0, 0, 0));
	explainLabel:setColor(ccc3( 0x51, 0xfb, 0xff))
	explainLabel:setAnchorPoint(ccp(0,1))
	explainLabel:setPosition(ccp(g_winSize.width - 454 * g_fScaleX,(_tableViewSp:getPositionY() - _tableViewSp:getContentSize().height)))
	explainLabel:setScale(g_fScaleX)
	_centerLayer:addChild(explainLabel)
end

--[[
	@des 	: 创建界面
	@param 	: 
	@return : 
--]]
function create()
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

--[[
	@des 	: 显示商店界面
	@param 	: 
	@return : 
--]]
function showLayer(touchPriority,zOrder)
	zOrder = zOrder or 512
	create()
	require "script/ui/shopall/ShoponeLayer"
	_centerLayer = createLayer(ShoponeLayer.getCenterSize(),touchPriority,zOrder,true)
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
	scene:addChild(_layer,zOrder)
end
--[[
	@des 	: 商店整合专用
	@param 	: 
	@return : 
--]]
function createLayer(p_centerSize,touchPriority,zOrder,isShow)
	-- body
	_touchPriority = touchPriority or -555
	zOrder = zOrder or 512
	_isShow = isShow or ni
	_centerSize = p_centerSize
	_centerLayer = CCLayer:create()
	_centerLayer:setContentSize(_centerSize)
	MissionShopController.getInfo(function ()
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
	local shopInfo = MissionShopData.getShopInfo()
	local cellSize = CCSizeMake(442*g_fScaleX, 164*g_fScaleX)
	local luaHandler = LuaEventHandler:create(function(fn,t,a1,a2)
			local ret
			if fn == "cellSize" then
				ret = CCSizeMake(cellSize.width,cellSize.height)
			elseif fn == "cellAtIndex" then
				ret = MissionShopCell.createCell(a1 + 1)
			elseif fn == "numberOfCells" then
				ret = #shopInfo
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
		-- package.loaded["script/ui/mission/shop/MissionShopLayer"] = nil
	end
end
--[[
	@des 	: 刷新
	@param 	: 
	@return : 
--]]
function refresh( ... )
	if _centerLayer then
		MissionShopController.getInfo(function ()
			local offset = _tableView:getContentOffset()
	    	_tableView:removeFromParentAndCleanup(true)
	    	_tableView = nil
	    	createTableView()
	    	_tableView:setContentOffset(offset)
			_fameValueLabel:setString(UserModel.getFameNum())
	    end)
	end
end
--[[
	@des 	: 商店是否开启
	@param 	: 
	@return : 
--]]
function isOpen()
	require "script/ui/mission/MissionMainData"
	if MissionMainData.isCanJion() and MissionMainData.getTeamId() >0 then
		return true
	else
		return false
	end
end