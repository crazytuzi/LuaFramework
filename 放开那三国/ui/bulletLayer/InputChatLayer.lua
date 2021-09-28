-- Filename：	InputChatLayer.lua
-- Author：		llp
-- Date：		2015-4-22
-- Purpose：		弹幕

module ("InputChatLayer", package.seeall)

require "script/ui/bulletLayer/BulletLayer"
require "script/ui/bulletLayer/BulletServices"
require "script/ui/guild/guildRobList/GuildRobData"
require "script/network/RequestCenter"
require "script/network/Network"
require "script/ui/main/BulletinData"

local menu 					= nil
local _bgLayer 				= nil
local _inputBox 			= nil
local _worldPanel 			= nil
local lookmessageLabel 		= nil
local wordColorLabel 		= nil
local _chooseColorButton 	= nil
local switchMenuItem 		= nil

local _type 				= 1
local _touch_priority   	= -1001

local _color 				= ccc3(0xff,0xff,0xff)

local _canSend 				= true

local function init()
	_bgLayer 			 = nil
	_inputBox 			 = nil
	_worldPanel 		 = nil
	menu 				 = nil
	lookmessageLabel 	 = nil
	wordColorLabel 		 = nil
	_chooseColorButton   = nil
	switchMenuItem 		 = nil

	_color 				 = ccc3(0xff,0xff,0xff)

	_canSend 			 = true

	_type 			 = 1
	_touch_priority   	 = -1001
end

--指定文字颜色
local colorTable = {
	ccc3(255,255,255),
	ccc3(255,0,0),
	ccc3(0,255,0),
	ccc3(0,0,255),
	ccc3(255,255,0),
	ccc3(0,255,255),
	ccc3(255,0,255),
	ccc3(148,0,211),
	ccc3(255,165,0),
	ccc3(0,255,127),
}

--颜色位置
local posTable = {
	0.15,0.325,0.5,0.675,0.85
}

function onNodeEvent(event)
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _touch_priority, true)
        _bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
		-- AudioUtil.playMainBgm()
	end
end

--layer触摸事件
function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
		return true
	end
end

-- 关闭按钮回调
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    -- AudioUtil.playEffect("audio/effect/guanbi.mp3")

	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

-- 点击改变颜色按钮回调
function changeColorCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    -- AudioUtil.playEffect("audio/effect/guanbi.mp3")
    if(_worldPanel:getScale()<1)then
    	_worldPanel:stopAllActions()
		local action = CCScaleTo:create(0.2, 1)
		_worldPanel:runAction(action)
    else
    	_worldPanel:stopAllActions()
		local action = CCScaleTo:create(0.2, 0)
		_worldPanel:runAction(action)
    end
end

-- 点击开关弹幕按钮
function switchCallBack( tag,sender )
	-- body
	local normalSprite  = CCSprite:create("images/bulletscreen/bulletopen.png")
	local selectSprite  = CCSprite:create("images/bulletscreen/bulletopen.png")
	local disabledSprite = CCSprite:create("images/bulletscreen/bulletclose.png")

	switchMenuItem:removeFromParentAndCleanup(true)
	switchMenuItem = nil

	if(BulletinData.getShow())then
		switchMenuItem = CCMenuItemSprite:create(disabledSprite,disabledSprite)
		BulletinData.setShow(false)
		BulletLayer.closeLayer()
	else
		switchMenuItem = CCMenuItemSprite:create(normalSprite,selectSprite)
		BulletinData.setShow(true)
		BulletLayer.showLayer()
	end

	switchMenuItem:setAnchorPoint(ccp(0,0.5))
	switchMenuItem:setPosition(ccp(lookmessageLabel:getPositionX()+lookmessageLabel:getContentSize().width+80,lookmessageLabel:getPositionY()-lookmessageLabel:getContentSize().height*0.5))
	switchMenuItem:registerScriptTapHandler(switchCallBack)
	menu:addChild(switchMenuItem,1,1)
end

--改变按钮颜色回调
function setColorCallBack( tag,sender )
	-- body
	_color = colorTable[tag]

	BulletinData.setScreenColor(_color)

	_chooseColorButton:removeFromParentAndCleanup(true)
	--选择颜色按钮
	local bgSprite = CCScale9Sprite:create("images/common/blue.png")
	bgSprite:setColor(colorTable[tag])
	bgSprite:setContentSize(CCSizeMake(85, 50))
	_chooseColorButton = CCMenuItemSprite:create(bgSprite, bgSprite)
	_chooseColorButton:setAnchorPoint(ccp(0.5, 0.5))
	_chooseColorButton:setPosition(ccp(lookmessageLabel:getPositionX()+lookmessageLabel:getContentSize().width+80+switchMenuItem:getContentSize().width*0.5, wordColorLabel:getPositionY()-lookmessageLabel:getContentSize().height*0.5 ))
	_chooseColorButton:registerScriptTapHandler(changeColorCallback)
	menu:addChild(_chooseColorButton)

	changeColorCallback()
end

--处理发送聊天信息回调
function handleMessage( cbFlag, dictData, bRet )
	-- body
	if dictData.err ~= "ok" then
        return
    else
    	if(_bgLayer~=nil)then
			_bgLayer:removeFromParentAndCleanup(true)
			_bgLayer = nil
		end
    end
end

--发送聊天信息回调
function sendMessageCallback( tag,sender )
	if(string.len(_inputBox:getText())>60)then
		AnimationTip.showTip(GetLocalizeStringBy("llp_180"))
		return
	end
	local storeTime = tonumber(BulletinData.getSendTime())+SendTime.time
	if(BTUtil:getSvrTimeInterval()<storeTime and tonumber(BulletinData.getSendTime())~=0)then
		_canSend = false
	else
		_canSend = true
	end
	--提示倒计时时间
	if(_canSend == false)then
		local lastTime = storeTime-BTUtil:getSvrTimeInterval()
		AnimationTip.showTip(GetLocalizeStringBy("llp_178")..tostring(lastTime)..GetLocalizeStringBy("key_10192"))
		return
	end

	-- body
	local message = _inputBox:getText()
	local messageCopy = string.gsub(message, " ", "")
	if(string.len(messageCopy)==0)then
		AnimationTip.showTip(GetLocalizeStringBy("llp_179"))
		return
	end
	_canSend=false
	_color = BulletinData.getScreenColor()
	local colorString = _color.r..",".._color.g..",".._color.b

	local tempArgs = CCArray:create()
	--抢粮战要发robId 别的不用
	local robId = 0
	if(_type==3)then
		robId = GuildRobData.getMyGuildRobId()
	end
	tempArgs:addObject(CCString:create(message))
	tempArgs:addObject(CCInteger:create(_type))
	tempArgs:addObject(CCInteger:create(robId))
	tempArgs:addObject(CCString:create(colorString))

	BulletServices.sendMessage(handleMessage,tempArgs)
	BulletinData.setSendTime(BTUtil:getSvrTimeInterval())
end

function watchStrNum( ... )
	-- body
	if(string.len(_inputBox:getText())>=20)then
		_inputBox:onExit()
	end
end

function createLayer(  )
	init()

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _bgLayer:registerScriptHandler(onNodeEvent)

	-- 创建背景
	_backGround = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    _backGround:setContentSize(CCSizeMake(540, 363))
    _backGround:setAnchorPoint(ccp(0.5,0.5))
    _backGround:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    _bgLayer:addChild(_backGround)
    -- 适配
    setAdaptNode(_backGround)
    -- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(_backGround:getContentSize().width/2, _backGround:getContentSize().height-6.6 ))
	_backGround:addChild(titlePanel)
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_173"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)
	--冷却label
	local coolDownLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_174"), g_sFontName, 25)
	_backGround:addChild(coolDownLabel)
	coolDownLabel:setColor(ccc3(0x00,0x00,0x00))
	coolDownLabel:setAnchorPoint(ccp(0,1))
	coolDownLabel:setPosition(ccp(20,_backGround:getContentSize().height-titlePanel:getContentSize().height))
	--输入框
	_inputBox = CCEditBox:create(CCSizeMake(coolDownLabel:getContentSize().width,50), CCScale9Sprite:create("images/common/bg/search_bg.png"))
    _inputBox:setTouchPriority(-1002)
    _inputBox:setPlaceHolder(GetLocalizeStringBy("llp_175"))
    _inputBox:setAnchorPoint(ccp(0,1))
    _inputBox:setFont(g_sFontName,25)
    _inputBox:setFontColor(ccc3(0xff,0xff,0xff))
    _inputBox:setPlaceholderFontColor(ccc3(0xff,0xff,0xff))
    _inputBox:setMaxLength(1000)
    _inputBox:setReturnType(kKeyboardReturnTypeDone)
    _inputBox:setInputFlag (kEditBoxInputFlagInitialCapsWord)
    _backGround:addChild(_inputBox)
    _inputBox:setPosition(ccp(20,_backGround:getContentSize().height-titlePanel:getContentSize().height-10-coolDownLabel:getContentSize().height))
	-- 关闭按钮
	menu = CCMenu:create()
    menu:setTouchPriority(-1002)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	_backGround:addChild(menu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(_backGround:getContentSize().width * 0.955, _backGround:getContentSize().height*0.975 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)

	--发送按钮
	local closeButton = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png","images/star/intimate/btn_blue_h.png",CCSizeMake(120,64),GetLocalizeStringBy("key_1138"),ccc3(255,222,0))
	closeButton:setAnchorPoint(ccp(0, 0.5))
	closeButton:setPosition(ccp(coolDownLabel:getContentSize().width+25, _inputBox:getPositionY()-25 ))
	closeButton:registerScriptTapHandler(sendMessageCallback)
	menu:addChild(closeButton)

	--观看弹幕label
	lookmessageLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_176"),g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
	_backGround:addChild(lookmessageLabel)
	lookmessageLabel:setAnchorPoint(ccp(0,1))
	lookmessageLabel:setPosition(ccp(100,_inputBox:getPositionY()-80))
	lookmessageLabel:setColor(ccc3(0xff, 0xe4, 0x00))

	--文字颜色label
	wordColorLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_177"),g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
	_backGround:addChild(wordColorLabel)
	wordColorLabel:setAnchorPoint(ccp(0,1))
	wordColorLabel:setPosition(ccp(100,lookmessageLabel:getPositionY()-lookmessageLabel:getContentSize().height-40))
	wordColorLabel:setColor(ccc3(0xff, 0xe4, 0x00))

	--开关弹幕按钮
	local isShow = BulletinData.getShow()
	if(isShow)then
		local normalSprite  = CCSprite:create("images/bulletscreen/bulletopen.png")
		local selectSprite  = CCSprite:create("images/bulletscreen/bulletopen.png")
		local disabledSprite = CCSprite:create("images/bulletscreen/bulletclose.png")
	    switchMenuItem = CCMenuItemSprite:create(normalSprite,selectSprite)
	else
		local disabledSprite = CCSprite:create("images/bulletscreen/bulletclose.png")
	    switchMenuItem = CCMenuItemSprite:create(disabledSprite,disabledSprite)
	end
	switchMenuItem:setAnchorPoint(ccp(0,0.5))
	switchMenuItem:setPosition(ccp(lookmessageLabel:getPositionX()+lookmessageLabel:getContentSize().width+80,lookmessageLabel:getPositionY()-lookmessageLabel:getContentSize().height*0.5))
	switchMenuItem:registerScriptTapHandler(switchCallBack)
	menu:addChild(switchMenuItem,1,1)

	--选择颜色按钮
	local fullRect = CCRectMake(0,0,49,49)
	local insetRect = CCRectMake(20,20,10,8)
	local bgSprite = CCScale9Sprite:create("images/common/blue.png", fullRect, insetRect)
	bgSprite:setPreferredSize(CCSizeMake(85, 50))
	bgSprite:setColor(BulletinData.getScreenColor())
	_chooseColorButton = CCMenuItemSprite:create(bgSprite, bgSprite)
	_chooseColorButton:setAnchorPoint(ccp(0.5, 0.5))
	_chooseColorButton:setPosition(ccp(lookmessageLabel:getPositionX()+lookmessageLabel:getContentSize().width+80+switchMenuItem:getContentSize().width*0.5, wordColorLabel:getPositionY()-lookmessageLabel:getContentSize().height*0.5 ))
	_chooseColorButton:registerScriptTapHandler(changeColorCallback)
	menu:addChild(_chooseColorButton)

	--子菜单背景
	_worldPanel = CCScale9Sprite:create("images/main/sub_icons/menu_bg.png")
	_worldPanel:setAnchorPoint(ccp(0.5, 1))
	_backGround:addChild(_worldPanel, 3200)
	_worldPanel:setScale(0)

	--子菜单背景上的按钮
	local colorMenu = CCMenu:create()
	colorMenu:setTouchPriority(-1002)
	colorMenu:setPosition(ccp(0, 0))
	colorMenu:setAnchorPoint(ccp(0, 0))
	_worldPanel:addChild(colorMenu,3)
	_worldPanel:setContentSize(CCSizeMake(_backGround:getContentSize().width,147))

	--菜单上的按钮
	for i=1,10 do
		local colorButton = CCMenuItemImage:create("images/common/blue.png", "images/common/blue.png")
		colorButton:setAnchorPoint(ccp(0.5, 0.5))
		if(i<6)then
			colorButton:setPosition(ccpsprite(posTable[i], 0.66, _worldPanel))
		else
			colorButton:setPosition(ccpsprite(posTable[i-5], 0.3, _worldPanel))
		end
		colorButton:registerScriptTapHandler(setColorCallBack)
		colorMenu:addChild(colorButton,1,i)
		colorButton:setColor(colorTable[i])
	end

	--小三角
	local pos = (lookmessageLabel:getPositionX()+lookmessageLabel:getContentSize().width+80+switchMenuItem:getContentSize().width*0.5)/_backGround:getContentSize().width
	local arrowSprite = CCSprite:create("images/common/arrow_panel.png")
	_worldPanel:setPosition(_backGround:getContentSize().width*0.5 , _chooseColorButton:getPositionY()-_chooseColorButton:getContentSize().height*0.5-arrowSprite:getContentSize().height-2)
	arrowSprite:setAnchorPoint(ccp(0.5, 0))
	arrowSprite:setPosition(ccpsprite(pos, 0.97, _worldPanel))
	_worldPanel:addChild(arrowSprite)

	if(isShow)then
		BulletLayer.showLayer()
	else

	end

	return _bgLayer
end

function showLayer( p_type,p_touch,p_zorder )
	-- body
	local layer = createLayer()
	_type = p_type
	local runing_scene = CCDirector:sharedDirector():getRunningScene()
    runing_scene:addChild(layer, 100)
end