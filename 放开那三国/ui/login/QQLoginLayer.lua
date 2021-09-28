-- Filename:QQLoginLayer.lua
-- Author: 	cheng liang
-- Date: 	2014-11-12
-- Purpose: 该文件用于QQ登录模块

-- QQ登录模块
module ("QQLoginLayer", package.seeall)

local _bgLayer 		= nil

local _kQQ_Tag 		= 10001
local _kWechat_Tag 	= 10002


local function onTouchesHandler( eventType, x, y )
	
	if (eventType == "began") then
		-- print("began")

	    return true
    elseif (eventType == "moved") then
    	
    else
        -- print("end")
	end
end

local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -5600, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
        _bgLayer = nil
       
	end
end


function init()
	_bgLayer = nil
end


function createLayer()

	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)

	local bg = CCSprite:create("images/login/bg.jpg")
	bg:setPosition(ccp(g_winSize.width/2, g_winSize.height/2))
	bg:setAnchorPoint(ccp(0.5, 0.5))
	_bgLayer:addChild(bg)
	bg:setScale(g_fBgScaleRatio)

	local logoSprite = CCSprite:create("images/login/logo.png")
	logoSprite:setAnchorPoint(ccp(0.5, 0.5))
	logoSprite:setPosition(ccp(_bgLayer:getContentSize().width/2, _bgLayer:getContentSize().height*0.8))
	logoSprite:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(logoSprite,6)

	local effectSprite = XMLSprite:create("images/login/denglujiemian_zhulin_luoye/denglujiemian_zhulin_luoye")
	effectSprite:setScale(g_fElementScaleRatio)
	effectSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
	effectSprite:setAnchorPoint(ccp(0.5,0.5))
	_bgLayer:addChild(effectSprite,5)

	local effectSprite2 = XMLSprite:create("images/login/denglujiemian_zhulin/denglujiemian_zhulin")
	-- effectSprite2:setScale(g_fElementScaleRatio)
	effectSprite2:setPosition(ccp(bg:getContentSize().width*0.5,bg:getContentSize().height*0.5))
	effectSprite2:setAnchorPoint(ccp(0.5,0.5))
	bg:addChild(effectSprite2,5)

	local effectSprite3 = XMLSprite:create("images/login/denglujiemian_3nian_tubiao/denglujiemian_3nian_tubiao")
	effectSprite3:setScale(g_fElementScaleRatio)
	effectSprite3:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.8))
	effectSprite3:setAnchorPoint(ccp(0.5,0.5))
	_bgLayer:addChild(effectSprite3,7)

	-- local bg2 = CCSprite:create("images/login/bg2.png")
	-- bg2:setPosition(ccps(0.5, 0.5))
	-- bg2:setAnchorPoint(ccp(0.5, 0.5))
	-- _bgLayer:addChild(bg2)
	-- setAdaptNode(bg2)
end

function loginAction( tag, item_btn )
	local protocol = PluginManager:getInstance():loadPlugin()
	QQLoginLayer.removeLayer()
	-- body
	print("tag==", tag)
	print("protocol==", protocol)
	if(tag==10001)then
		print("QQ登录")
		protocol:callOCFunctionWithName_oneParam_noBack("loginWithQQ",nil)
	elseif(tag==10002)then
		print("微信登录")
		protocol:callOCFunctionWithName_oneParam_noBack("loginWithWeixin",nil)
	end
end

function createButton()
	local login_menu = CCMenu:create()
	login_menu:setPosition(0,0)
	_bgLayer:addChild(login_menu)

	local qq_btn = CCMenuItemImage:create("images/login/qq/btn_qq_normal.png","images/login/qq/btn_qq_highlight.png")
	qq_btn:registerScriptTapHandler(loginAction)
	qq_btn:setScale(g_fElementScaleRatio)
    qq_btn:setPosition(ccps(0.25, 0.2))
    qq_btn:setAnchorPoint(ccp(0.5, 0.5))

    login_menu:addChild(qq_btn, 22, _kQQ_Tag)

    local wechat_btn = CCMenuItemImage:create("images/login/qq/btn_wechat_normal.png","images/login/qq/btn_wechat_highlight.png")
	wechat_btn:registerScriptTapHandler(loginAction)
	wechat_btn:setScale(g_fElementScaleRatio)
    wechat_btn:setPosition(ccps(0.75, 0.2))
    wechat_btn:setAnchorPoint(ccp(0.5, 0.5))

    login_menu:addChild(wechat_btn, 22, _kWechat_Tag)
    login_menu:setTouchPriority(-5601)
    
end

function showLayer()
	init()
	createLayer()
	createButton()
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_bgLayer, 1000)
end

function removeLayer()
	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end


