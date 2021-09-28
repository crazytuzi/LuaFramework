-- Filename：	CheckCodeTip.lua
-- Author：		chengliang
-- Date：		2015-3-12
-- Purpose：		验证码确认框

module("CheckCodeTip", package.seeall)


local _bgLayer
local _bgSprite
local _zOrder 	
local _bgSprite 

local _layerSize 
local _title 
local _check_code

local _pid
local _check_file

function init()
	_bgLayer 	= nil
	_priority 	= nil
	_zOrder 	= nil
	_bgSprite 	= nil
	_layerSize	= nil
	_title 		= nil
	_check_code = nil
	_pid 		= nil
	_check_file = nil
end

function getBgSprite()
	return _bgSprite
end

local function onTouchesHandler( eventType, x, y )
	return true
end

 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _priority, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
        _bgLayer = nil
	end
end

-- 关闭按钮的回调函数
function closeCb()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

-- 确认
function menuAction( ... )
	print("menuAction")
	local checkCodeStr = _check_code:getText()
	if( checkCodeStr == nil or checkCodeStr == "" )then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("cl_1016"))
		print("cl_1016cl_1016")
		return
	end
	closeCb()
	LoginScene.loginLogicServer(_pid, checkCodeStr)
end


function createCheckCode()
	local checkLabel = CCLabelTTF:create(GetLocalizeStringBy("cl_1014"), g_sFontName, 21)
	checkLabel:setPosition(ccp(60, _bgSprite:getContentSize().height*0.5 -10))
	checkLabel:setColor(ccc3(100, 25, 4))
	_bgSprite:addChild(checkLabel)

	_check_code = CCEditBox:create (CCSizeMake(200,45), CCScale9Sprite:create("images/login/login_text_bg.png"))
	_check_code:setPosition(ccp(139, _bgSprite:getContentSize().height*0.5))
	_check_code:setAnchorPoint(ccp(0, 0.5))
	_check_code:setPlaceHolder(GetLocalizeStringBy("cl_1015"))
	_check_code:setPlaceholderFontColor(ccc3(177, 177, 177))
	_check_code:setFont(g_sFontName,24)
	_check_code:setFontColor(ccc3( 0x78, 0x25, 0x00))
	_check_code:setMaxLength(24)
	_check_code:setReturnType(kKeyboardReturnTypeDone)
	_check_code:setInputFlag (kEditBoxInputFlagInitialCapsWord)
	_check_code:setTouchPriority(_priority - 1)
	_bgSprite:addChild(_check_code)

	local checkSprite = CCSprite:create(_check_file)
	checkSprite:setPosition(ccp(139+200+5, _bgSprite:getContentSize().height*0.5))
	checkSprite:setAnchorPoint(ccp(0, 0.5))
	checkSprite:setScale(1.5)
	_bgSprite:addChild(checkSprite)

	-- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(-5601)
	_bgSprite:addChild(menuBar)

	-- 确认
	require "script/libs/LuaCC"
	local confirmBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), GetLocalizeStringBy("key_2864"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	confirmBtn:setAnchorPoint(ccp(0.5, 0))
	confirmBtn:setPosition(ccp(_bgSprite:getContentSize().width*0.5, 20))
    confirmBtn:registerScriptTapHandler(menuAction)
	menuBar:addChild(confirmBtn, 1, 10001)


end

-- 
local function createBgSprite()
	local myScale = MainScene.elementScale
	local mySize = _layerSize
	-- 背景
	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
    _bgSprite = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    _bgSprite:setContentSize(mySize)
    _bgSprite:setScale(g_fScaleX)
    _bgSprite:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(_bgSprite)

    if( _title ~= nil )then
	    local titleBg= CCSprite:create("images/common/viewtitle1.png")
		titleBg:setPosition(ccp(_bgSprite:getContentSize().width*0.5, _bgSprite:getContentSize().height-6))
		titleBg:setAnchorPoint(ccp(0.5, 0.5))
		_bgSprite:addChild(titleBg)

		 --标题文本
		local labelTitle = CCRenderLabel:create(_title, g_sFontPangWa,33,2,ccc3(0x00,0x00,0x0),type_shadow)
		labelTitle:setPosition(ccp(titleBg:getContentSize().width/2, (titleBg:getContentSize().height-1)/2))
		labelTitle:setColor(ccc3(0xff,0xe4,0x00))
		labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5))
	    labelTitle:setAnchorPoint(ccp(0.5,0.5))
		titleBg:addChild(labelTitle)
	end

	createCheckCode()
end

-- 创建
function showTip( pid, check_file  )
	init()
	_pid = pid
	_check_file = check_file
	_priority = priority or -450
	_zOrder = zOrder or  100
	_layerSize = layerSize or CCSizeMake(550, 300)
	_title = title

	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)

	createBgSprite()

	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_bgLayer, 2002)
end



