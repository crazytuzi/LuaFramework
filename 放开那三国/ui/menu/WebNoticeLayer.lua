-- Filename: 	WebNoticeLayer.lua
-- Author: 		chenglaing
-- Date: 		2016-1-20
-- Purpose: 	该文件用于展示web活动公告

module ("WebNoticeLayer", package.seeall)


local _bgLayer

--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	
	if (eventType == "began") then
		-- print("began")

	    return true
    elseif (eventType == "moved") then
    	
    else
        -- print("end")
	end
end


--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		print("AlertTip.onNodeEvent.......................enter")
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -5000, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		print("AlertTip.onNodeEvent.......................exit")
		_bgLayer:unregisterScriptTouchHandler()
        _bgLayer = nil
       
	end
end


function closeAction()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	Platform.closeCustomWebView()
	if(_bgLayer) then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

function createUI( ... )
	-- 背景
	local bgSprite = CCScale9Sprite:create(CCRectMake(20, 22, 10, 12),"images/menu/notice_9scale.png")
    bgSprite:setContentSize(CCSizeMake(640*0.8*g_fElementScaleRatio,960*0.8*g_fElementScaleRatio))
    bgSprite:setAnchorPoint(ccp(0.5,0.5))
    bgSprite:setPosition(g_winSize.width/2,g_winSize.height/2)
    -- bgSprite:setScale(g_fElementScaleRatio)
    _bgLayer:addChild(bgSprite)

    local bgSize = bgSprite:getContentSize()
    -- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	bgSprite:addChild(closeMenuBar)
	closeMenuBar:setTouchPriority(-9999999999)
	local closeBtn = CCMenuItemImage:create("images/menu/web_n.png", "images/menu/web_h.png")
	closeBtn:registerScriptTapHandler(closeAction)
	closeBtn:setAnchorPoint(ccp(0.5, 1))
    closeBtn:setPosition(ccp(bgSprite:getContentSize().width*0.5, 0))
    closeBtn:setScale(g_fElementScaleRatio)
	closeMenuBar:addChild(closeBtn)

	local url = MainScene.getWebActivityUrl()
	if(url ~= nil and Platform.isHasFunction( "openCustomWebView" )) then
		-- 如果url不存在 或者方法不存在 就不显示
		Platform.openCustomWebView(url, bgSize.width-20, bgSize.height-20,
		 (g_winSize.width-bgSize.width)/2+10,  (g_winSize.height-bgSize.height)/2+10, 0, 0)


	end
end

function createLayer()
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)

	createUI()

	return _bgLayer
end

function show()
	local bgLayer = createLayer()

	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(bgLayer,2000)
end

