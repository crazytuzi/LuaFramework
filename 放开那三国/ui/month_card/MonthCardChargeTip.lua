-- Filename：	MonthCardChargeTip.lua
-- Author：		chengliang
-- Date：		2014-11-21
-- Purpose：		月卡充值提示

module("MonthCardChargeTip", package.seeall)


local _bgLayer
local _bgSprite
local _zOrder 	
local _bgSprite 
local _vipCardDBData = nil
local _cardId = nil
function init()
	_bgLayer 	= nil
	_priority 	= nil
	_zOrder 	= nil
	_bgSprite 	= nil
    _vipCardDBData = nil
    _cardId = nil
end


local function onTouchesHandler( eventType, x, y )
	
	if (eventType == "began") then
		-- print("began")
		
	    return true
    elseif (eventType == "moved") then
    	
    else
        -- print("end")
	end
end

function rechargeCallback( gold_num )
	MonthCardData.addMonthChargeGold(_cardId,gold_num)
	closeCb()
end 


 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _priority, true)
		_bgLayer:setTouchEnabled(true)
		require "script/ui/shop/RechargeLayer"
		RechargeLayer.registerChargeGoldCb( rechargeCallback )
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
        _bgLayer = nil
        require "script/ui/shop/RechargeLayer"
		RechargeLayer.registerChargeGoldCb(nil)
	end
end

-- 关闭按钮的回调函数
function closeCb()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

function showChargeFunc(  )
	-- closeCb()
	local layer = RechargeLayer.createLayer(nil,nil,_cardId)
	local scene = CCDirector:sharedDirector():getRunningScene()
	scene:addChild(layer,1111)
end

-- 
function createContent()
	-- 默认文本的信息
    local local_infos = {}
    local_infos.localColor = ccc3(0,0,0)
    local_infos.localFontSize = 25
    local_infos.localLabelType = "label"
    local_infos.font = g_sFontName

    -- 各个变量的节点信息 也就是 %s 中要替代的内容
    local param_table = {
                            { 
                                ntype     = "image",
                                image     = "images/common/gold.png",
                 
                            },
                            { 
                                ntype     = "label",
                                fontSize  = 25,
                                text      = MonthCardData.getMonthChargeGold(_cardId),
                                color     = ccc3( 155, 0, 0),
                            },
                            { 
                                ntype     = "image",
                                image     = "images/common/gold.png",
                            },
                            { 
                                ntype     = "label",
                                fontSize  = 25,
                                text      = tonumber(_vipCardDBData.payneedgold)-MonthCardData.getMonthChargeGold(_cardId),
                                color     = ccc3( 155, 0, 0),
                            },
                        }

    -- tip
    local infos_sprite = GetLocalizeLabelSpriteBy("cl_1012", local_infos, param_table)
    infos_sprite:setPosition(ccp(60, 190))
    infos_sprite:setAnchorPoint(ccp(0,0.5))
    _bgSprite:addChild(infos_sprite)
	
	local menuBar=CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_priority-2)
    _bgSprite:addChild(menuBar)

    local reChargeItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_shop_n.png","images/common/btn/btn_shop_h.png",CCSizeMake(164, 80),GetLocalizeStringBy("key_1170"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    reChargeItem:setAnchorPoint(ccp(0.5, 0.5))
    reChargeItem:setPosition( _bgSprite:getContentSize().width*0.5, _bgSprite:getContentSize().width*0.15 )
    reChargeItem:registerScriptTapHandler(showChargeFunc)
    menuBar:addChild(reChargeItem)
end

-- 
local function createBgSprite()
	local myScale = MainScene.elementScale
	local mySize = CCSizeMake(550, 300)
	-- 背景
	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
    _bgSprite = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    _bgSprite:setContentSize(mySize)
    _bgSprite:setScale(myScale)
    _bgSprite:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(_bgSprite)

    local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(_bgSprite:getContentSize().width*0.5, _bgSprite:getContentSize().height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	_bgSprite:addChild(titleBg)

	 --标题文本
	local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("cl_1009"), g_sFontPangWa,33,2,ccc3(0x00,0x00,0x0),type_shadow)
	labelTitle:setPosition(ccp(titleBg:getContentSize().width/2, (titleBg:getContentSize().height-1)/2))
	labelTitle:setColor(ccc3(0xff,0xe4,0x00))
	labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5))
    labelTitle:setAnchorPoint(ccp(0.5,0.5))
	titleBg:addChild(labelTitle)

	-- 关闭按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_priority-1)
    _bgSprite:addChild(menu,99)
    closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(mySize.width*1.02,mySize.height*1.02))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menu:addChild(closeBtn)
end

-- 创建
function createLayer()
	
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)

	createBgSprite()
	createContent()

	return _bgLayer
end

-- 展示
function showLayer( priority, zOrder ,tag)
	init()
	_priority = priority or -450
	_zOrder = zOrder or  999
    _cardId = tag
	_vipCardDBData = MonthCardData.getVipCardDatafromXml(_cardId)
	createLayer()
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_bgLayer, _zOrder)

end


