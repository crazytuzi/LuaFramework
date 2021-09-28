-- FileName: ApplyCityLayer.lua 
-- Author: licong 
-- Date: 14-4-21 
-- Purpose: 城池报名


module("ApplyCityLayer", package.seeall)

require "script/utils/BaseUI"
require "script/libs/LuaCC"
require "script/ui/guild/city/CityData"
require "script/ui/guild/city/CityService"
require "script/ui/guild/GuildImpl"

local _applyCityId 				= nil
local _bgLayer 					= nil
local _backGround 				= nil
local _second_bg 				= nil

function init( ... )
	_applyCityId 				= nil
	_bgLayer 					= nil
	_backGround 				= nil
	_second_bg 					= nil
end


-- touch事件处理
local function cardLayerTouch(eventType, x, y)
   
    return true
    
end

-- 关闭按钮回调
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	-- print("closeButtonCallback")
	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

function onNodeEvent( event )
	if (event == "enter") then
		print("enter")
		_bgLayer:registerScriptTouchHandler(cardLayerTouch,false,-453,true)
		_bgLayer:setTouchEnabled(true)
		-- 注册删除回调
		GuildImpl.registerCallBackFun("ApplyCityLayer",closeButtonCallback)
	elseif (event == "exit") then
		print("exit")
		_bgLayer:unregisterScriptTouchHandler()
		_bgLayer = nil
		GuildImpl.registerCallBackFun("ApplyCityLayer",nil)
	end
end

-- 初始化界面
function initApplyCityLayer( ... )
	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _bgLayer:registerScriptHandler(onNodeEvent)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,1010,1)

	-- 创建背景
	_backGround = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    _backGround:setContentSize(CCSizeMake(618, 398))
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
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1966"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	-- 关闭按钮
	local menu = CCMenu:create()
    menu:setTouchPriority(-454)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	_backGround:addChild(menu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(_backGround:getContentSize().width * 0.955, _backGround:getContentSize().height*0.975 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)

 	-- 确认 取消 按钮
 	local okButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(135,64),GetLocalizeStringBy("key_1985"),ccc3(0xfe,0xdb,0x1c))
    okButton:setAnchorPoint(ccp(0.5, 0))
    okButton:setPosition(_backGround:getContentSize().width*0.3, 36)
	menu:addChild(okButton)
	okButton:registerScriptTapHandler(okButtonCallback)
	
	local cancelButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(135,64),GetLocalizeStringBy("key_1202"),ccc3(0xfe,0xdb,0x1c))
    cancelButton:setAnchorPoint(ccp(0.5, 0))
    cancelButton:setPosition(_backGround:getContentSize().width*0.7, 36)
	menu:addChild(cancelButton)
	cancelButton:registerScriptTapHandler(closeButtonCallback)

 	-- 第一行字
 	local font1 = CCLabelTTF:create(GetLocalizeStringBy("key_2838"),g_sFontPangWa,23)
 	font1:setColor(ccc3(0x78,0x25,0x00))
 	font1:setAnchorPoint(ccp(0,0))
 	_backGround:addChild(font1)

 	local name,color = CityData.getCityNameAndLvColor(_applyCityId)
 	local cityFont = CCRenderLabel:create("<" .. name .. ">",g_sFontPangWa,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
 	cityFont:setColor(color)
 	cityFont:setAnchorPoint(ccp(0,0))
 	_backGround:addChild(cityFont)

 	local font2 = CCLabelTTF:create("?",g_sFontPangWa,23)
 	font2:setColor(ccc3(0x78,0x25,0x00))
 	font2:setAnchorPoint(ccp(0,0))
 	_backGround:addChild(font2)

 	local pox = (_backGround:getContentSize().width-font1:getContentSize().width-cityFont:getContentSize().width-font2:getContentSize().width)/2
 	font1:setPosition(ccp(pox,290))
 	cityFont:setPosition(ccp(font1:getPositionX()+font1:getContentSize().width+2,font1:getPositionY()))
 	font2:setPosition(ccp(cityFont:getPositionX()+cityFont:getContentSize().width+2,cityFont:getPositionY()))

 	-- 第二行
 	local font1 = CCLabelTTF:create(GetLocalizeStringBy("key_1859"),g_sFontPangWa,23)
	font1:setColor(ccc3(0x78,0x25,0x00))
 	font1:setAnchorPoint(ccp(0,0))
 	_backGround:addChild(font1)

 	local font2 = CCLabelTTF:create(GetLocalizeStringBy("key_1804"),g_sFontPangWa,23)
	font2:setColor(ccc3(0x0e,0x79,0x00))
 	font2:setAnchorPoint(ccp(0,0))
 	_backGround:addChild(font2)

 	local font3 = CCLabelTTF:create(GetLocalizeStringBy("key_3283"),g_sFontPangWa,23)
	font3:setColor(ccc3(0x78,0x25,0x00))
 	font3:setAnchorPoint(ccp(0,0))
 	_backGround:addChild(font3)

 	local font4 = CCLabelTTF:create(GetLocalizeStringBy("key_2585"),g_sFontPangWa,23)
	font4:setColor(ccc3(0x01,0x72,0xc2))
 	font4:setAnchorPoint(ccp(0,0))
 	_backGround:addChild(font4)

 	local font5 = CCLabelTTF:create(")",g_sFontPangWa,23)
	font5:setColor(ccc3(0x78,0x25,0x00))
 	font5:setAnchorPoint(ccp(0,0))
 	_backGround:addChild(font5)

 	local pox = (_backGround:getContentSize().width-font1:getContentSize().width-font2:getContentSize().width-font3:getContentSize().width-font4:getContentSize().width-font5:getContentSize().width)/2
 	font1:setPosition(ccp(pox,230))
 	font2:setPosition(ccp(font1:getPositionX()+font1:getContentSize().width,font1:getPositionY()))
 	font3:setPosition(ccp(font2:getPositionX()+font2:getContentSize().width,font1:getPositionY()))
 	font4:setPosition(ccp(font3:getPositionX()+font3:getContentSize().width,font1:getPositionY()))
 	font5:setPosition(ccp(font4:getPositionX()+font4:getContentSize().width,font1:getPositionY()))

	-- 第三行
	local font1 = CCLabelTTF:create(GetLocalizeStringBy("key_1379"),g_sFontPangWa,23)
	font1:setColor(ccc3(0x00,0x00,0x00))
 	font1:setAnchorPoint(ccp(0,0))
 	_backGround:addChild(font1)

 	local num = CityData.getNumForSignupCity()
 	local numFont = CCLabelTTF:create(num,g_sFontPangWa,23)
 	numFont:setColor(ccc3(0x01,0x72,0xc2))
 	numFont:setAnchorPoint(ccp(0,0))
 	_backGround:addChild(numFont)

 	local pox = (_backGround:getContentSize().width-font1:getContentSize().width-numFont:getContentSize().width)/2
 	font1:setPosition(ccp(pox,170))
 	numFont:setPosition(ccp(font1:getPositionX()+font1:getContentSize().width+2,font1:getPositionY()))

 	-- 提示文字
	local str = GetLocalizeStringBy("key_3345")
	local strFont = CCLabelTTF:create(str,g_sFontPangWa,23)
	strFont:setAnchorPoint(ccp(0.5,0))
 	strFont:setColor(ccc3(0xff,0x00,0x00))
 	strFont:setPosition(ccp(_backGround:getContentSize().width*0.5,113))
 	_backGround:addChild(strFont)
end


-- 网络回调
function serviceCallFunc( ret )
	-- 关闭自己
	closeButtonCallback()

	-- 成功后才修复数据
	if( ret == "ok" )then
		-- 修改数据 
		-- 本地添加已报名的城池数据
		CityData.addSignCity(_applyCityId)	

		-- 修改城池信息界面 状态ui
		CityInfoLayer.createSignupStateUi(3)

		-- 提示
		local timeTab = CityData.getTimeTable()
		local zhunbeiTime = tonumber(timeTab.arrAttack[1][1]) - tonumber(timeTab.prepare)
		local timeStr = CityData.getTimeStrByNum(zhunbeiTime)
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("key_1247") .. timeStr .. GetLocalizeStringBy("key_1281"))

		-- add by chengliang
		BigMap.refreshMapUI()
	end
end

-- 确定按钮回调
function okButtonCallback( tag, itemBtn )
	
 	local num = CityData.getNumForSignupCity()
 	if(num <= 0)then
 		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("key_1104"))
		-- 关闭自己
		closeButtonCallback()
		return
 	end
 	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 发送报名请求
	CityService.signup(_applyCityId,serviceCallFunc)
end


-- 显示报名界面
function showApplyCityLayer( city_id )
	init()
	-- 申请的城池id
	_applyCityId = city_id

	-- 初始化界面
	initApplyCityLayer()
end
































