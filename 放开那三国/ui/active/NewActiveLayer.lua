-- Filename: NewActiveLayer.lua
-- Author: llp
-- Date: 2015-10-8
-- Purpose: 该文件用于: 新活动

module ("NewActiveLayer", package.seeall)

require "script/utils/extern"

require "script/ui/active/NewActiveCell"
require "script/libs/LuaCC"
require "script/network/RequestCenter"
require "script/ui/tip/AnimationTip"
require "script/model/DataCache"
require "script/audio/AudioUtil"
require "script/ui/active/NewActiveService"
require "script/ui/active/NewActiveController"
require "script/ui/active/NewActiveData"
require "script/ui/main/BulletinLayer"
require "script/ui/main/MainScene"
require "script/ui/main/MenuLayer"

local IMG_PATH = "images/recharge/"
local _layer					= nil
local _tableView 				= nil
local _activeDataCopy			= nil
local _packBackground			= nil

function init( )
 	_layer 					= nil
 	_tableView 				= nil
 	_activeDataCopy			= nil
	_packBackground 		= nil
end

function freshTableView( ... )
	-- body
	_tableView:removeFromParentAndCleanup(true)
	_tableView = nil
	createTableView()
end

local function updateActive()
	-- body
	local layer = RechargeActiveMain.create()
	MainScene.changeLayer(layer, "layer")
end

function createDesUI()
	-- body
	_activeDataCopy = NewActiveData.getData()
	local cellbg = CCSprite:create("images/sign/cellbg.png")
	local bulletinLayerSize = RechargeActiveMain.getTopSize()
	local desSpriteBg = CCSprite:create("images/active/xiaobeijing1.png")
		  desSpriteBg:setScale(g_fScaleX)
		  desSpriteBg:setAnchorPoint(ccp(0.5,1))
		  desSpriteBg:setPosition(ccp(_packBackground:getContentSize().width*0.5,_packBackground:getContentSize().height))
	_packBackground:addChild(desSpriteBg)
	
	local blueLineSprite = CCSprite:create("images/active/suai.png")
		  blueLineSprite:setPosition(ccp(0,desSpriteBg:getContentSize().height*0.5))
	desSpriteBg:addChild(blueLineSprite)

	local activeNameLabel = CCRenderLabel:create(_activeDataCopy.config.name, g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
		  activeNameLabel:setColor(ccc3(0xff,0xf6,0x00))
		  activeNameLabel:setAnchorPoint(ccp(0.5,0.5))
		  activeNameLabel:setPosition(ccp(blueLineSprite:getContentSize().width*0.5,blueLineSprite:getContentSize().height*0.5))
	blueLineSprite:addChild(activeNameLabel)

	local activeEndTimeLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_255"), g_sFontName,20,1,ccc3(0x00,0x00,0x00),type_stroke)
		  activeEndTimeLabel:setColor(ccc3(0x00,0xe4,0xff))
		  activeEndTimeLabel:setAnchorPoint(ccp(0,0))
		  activeEndTimeLabel:setPosition(ccp(0,activeEndTimeLabel:getContentSize().height*0.5))
	desSpriteBg:addChild(activeEndTimeLabel)

	local curServerTime = BTUtil:getSvrTimeInterval()
	local endTimeStr = TimeUtil.getRemainTimeHMS(tonumber(_activeDataCopy.config.end_time))
	local endTimeLabel = CCRenderLabel:create(endTimeStr, g_sFontName,20,1,ccc3(0x00,0x00,0x00),type_stroke)
		  endTimeLabel:setColor(ccc3(0x00,0xff,0x18))
		  endTimeLabel:setAnchorPoint(ccp(0,0))
		  endTimeLabel:setPosition(ccp(activeEndTimeLabel:getContentSize().width,activeEndTimeLabel:getPositionY()))
	desSpriteBg:addChild(endTimeLabel)

	local fullRect = CCRectMake(0,0,75,75)
    local insetRect = CCRectMake(30,30,15,10)
    local desBg = CCScale9Sprite:create("images/common/bg/astro_btnbg.png",fullRect, insetRect)
	      desBg:setContentSize(CCSizeMake(270,80))
		  desBg:setAnchorPoint(ccp(0,0))
		  desBg:setPosition(ccp(desSpriteBg:getContentSize().width*0.52,0))
	desSpriteBg:addChild(desBg)

	local desLabel = CCLabelTTF:create(_activeDataCopy.config.tip,g_sFontName,18)
		  desLabel:setDimensions(CCSizeMake(desBg:getContentSize().width-40, 0))
		  desLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
		  desLabel:setAnchorPoint(ccp(0.5,0.5))
		  desLabel:setPosition(ccp(desBg:getContentSize().width*0.5,desBg:getContentSize().height*0.5))
	desBg:addChild(desLabel)

	local time = 0
	local actions1 = CCArray:create()
            actions1:addObject(CCDelayTime:create(1))
            actions1:addObject(CCCallFunc:create(function ( ... )
                curServerTime = BTUtil:getSvrTimeInterval()
                endTimeLabel:setString(TimeUtil.getRemainTimeHMS(_activeDataCopy.config.end_time))
                if(tonumber(curServerTime)==tonumber(_activeDataCopy.config.end_time)+1)then
                	desLabel:stopAllActions()
                	NewActiveService.getDesactInfo(updateActive)
               	end
            end))
    local sequence = CCSequence:create(actions1)
    local action = CCRepeatForever:create(sequence)
    desLabel:runAction(action)
end

-- 创建签到的tableView 和升级按钮
function createTableView( )
	_activeDataCopy = NewActiveUtil.sortRewardData()
	
	local cellbg = CCSprite:create("images/common/newbg.png")
	local desSpriteBg = CCSprite:create("images/active/xiaobeijing1.png")
	local bulletinLayerSize = RechargeActiveMain.getTopSize()
	local menuLayerSize = MenuLayer.getLayerContentSize()
	local height = g_winSize.height - (menuLayerSize.height + bulletinLayerSize.height )*g_fScaleX  - RechargeActiveMain.getBgWidth() -desSpriteBg:getContentSize().height*g_fScaleX
	local cellSize = CCSizeMake(640,204)	
	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if (fn == "cellSize") then
			r = CCSizeMake(cellSize.width*g_fScaleX, cellSize.height*g_fScaleX)
		elseif (fn == "cellAtIndex") then
            a2= NewActiveCell.createCell(_activeDataCopy,a1)
            r = a2
        elseif fn == "numberOfCells" then
            r=  #(_activeDataCopy.config.reward)
		elseif (fn == "cellTouched") then
		else
		end
		return r
	end)	

	_tableView= LuaTableView:createWithHandler(handler,CCSizeMake(cellbg:getContentSize().width*g_fScaleX,height))
	_tableView:setBounceable(true)
	_tableView:setTouchPriority(-499)
	_tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_tableView:ignoreAnchorPointForPosition(false)
	_tableView:setAnchorPoint(ccp(0.5,0))
	_tableView:setPosition(ccp(_packBackground:getContentSize().width*0.5,0))
	_packBackground:addChild(_tableView)
	_tableView:reloadData()
end

local function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
	    return true
	end
end

local function initBaseUIAndTableView( ... )
	-- body
	_packBackground = CCScale9Sprite:create(IMG_PATH .. "fund/fund_bg.png")

	local bulletinLayerSize = RechargeActiveMain.getTopSize()
	local menuLayerSize = MenuLayer.getLayerContentSize()
	local height = g_winSize.height - (menuLayerSize.height + bulletinLayerSize.height )*g_fScaleX  - RechargeActiveMain.getBgWidth()

	_packBackground:setContentSize(CCSizeMake(g_winSize.width,height))
	_packBackground:setPosition(ccp(0,menuLayerSize.height*g_fScaleX))

	_layer:addChild(_packBackground)
	NewActiveController.getInfo()
end

-- 创建签到界面
function createLayer()
	init()

	_layer = CCLayer:create()
	
	initBaseUIAndTableView()

	return _layer
end