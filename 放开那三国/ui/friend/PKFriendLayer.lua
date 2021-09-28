-- FileName: PKFriendLayer.lua 
-- Author: licong 
-- Date: 14-5-12 
-- Purpose: function description of module 


module("PKFriendLayer", package.seeall)

local _pkUid 					= nil -- pk的好友的uid
local _bgLayer 					= nil
local _backGround 				= nil

local _maxCanPkNum 				= 0
local _maxBePkNum 				= 0
local _maxSamePkNum 			= 0

local _myUsePkNum 				= 0 -- 我当前已挑战的次数
local _friendBePkNum 			= 0 -- 该好友被挑战的次数
local _samePkNum 				= 0 -- 我已经挑战了该好友的次数

-- 初始化
local  function init( ... )
	_pkUid 						= nil -- pk的好友的uid
	_bgLayer 					= nil
	_backGround 				= nil
	_maxCanPkNum 				= 0
	_maxBePkNum 				= 0
 	_maxSamePkNum 				= 0
 	_myUsePkNum 				= 0
	_friendBePkNum 				= 0
	_samePkNum 					= 0
end

-- touch事件处理
local function cardLayerTouch(eventType, x, y)
    return true   
end

-- 关闭按钮回调
local function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

local function onNodeEvent( event )
	if (event == "enter") then
		print("enter")
		_bgLayer:registerScriptTouchHandler(cardLayerTouch,false,-453,true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		print("exit")
		_bgLayer:unregisterScriptTouchHandler()
		_bgLayer = nil
	end
end

local function okServiceCallFun( ret )
	-- 关掉自己
	closeButtonCallback()

	if(ret ~= "notFriend")then
		-- 进战斗
		if(ret.errcode == "success")then
			require "script/battle/BattleLayer"
			require "script/ui/active/mineral/AfterMineral"
			local afterBattleLayer = AfterMineral.createAfterMineralLayer( ret.appraisal, _pkUid, nil,ret.fightStr)
			BattleLayer.showBattleWithString(ret.fightStr, nil, afterBattleLayer,nil,nil,nil,nil,nil,true)
		else
			require "script/ui/tip/AnimationTip"
			AnimationTip.showTip(GetLocalizeStringBy("lic_1014") .. ret.errcode)
		end
	else
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1000"))
	end
end 

-- 确定按钮回调
local function okButtonCallback( tag, itemBtn )
	if(_friendBePkNum >= _maxBePkNum)then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1001"))
		return
	end

	if(_myUsePkNum >= _maxCanPkNum)then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1002"))
		return
	end

	if(_samePkNum >= _maxSamePkNum)then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1003"))
		return
	end

	FriendService.pkOnce(_pkUid,okServiceCallFun)
end

-- 初始化界面
local function initPKLayer( ... )
	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _bgLayer:registerScriptHandler(onNodeEvent)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,1999)

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
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2273"), g_sFontPangWa, 33)
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
 	local okButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(135,64),GetLocalizeStringBy("key_1458"),ccc3(0xfe,0xdb,0x1c))
    okButton:setAnchorPoint(ccp(0.5, 0))
    okButton:setPosition(_backGround:getContentSize().width*0.3, 36)
	menu:addChild(okButton)
	okButton:registerScriptTapHandler(okButtonCallback)
	
	local cancelButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(135,64),GetLocalizeStringBy("key_2482"),ccc3(0xfe,0xdb,0x1c))
    cancelButton:setAnchorPoint(ccp(0.5, 0))
    cancelButton:setPosition(_backGround:getContentSize().width*0.7, 36)
	menu:addChild(cancelButton)
	cancelButton:registerScriptTapHandler(closeButtonCallback)

 	-- 二级背景
    local second_bg = BaseUI.createContentBg(CCSizeMake(540,150))
    second_bg:setAnchorPoint(ccp(0.5,0))
    second_bg:setPosition(ccp(_backGround:getContentSize().width*0.5,200))
    _backGround:addChild(second_bg)
    
    -- 第一句 该好友今日还可被挑战次数
    local oneFont1 = CCLabelTTF:create(GetLocalizeStringBy("key_2350"),g_sFontName,25)
	oneFont1:setColor(ccc3(0xff,0xff,0xff))
	oneFont1:setAnchorPoint(ccp(0,0))
	oneFont1:setPosition(ccp(60,80))
	second_bg:addChild(oneFont1)
	-- 次数
    local friendTimes = _maxBePkNum - _friendBePkNum
    local oneFont2 = CCLabelTTF:create(friendTimes,g_sFontName,25)
	oneFont2:setColor(ccc3(0x21,0xf7,0x05))
	oneFont2:setAnchorPoint(ccp(0,0))
	oneFont2:setPosition(ccp(oneFont1:getPositionX()+oneFont1:getContentSize().width,oneFont1:getPositionY()))
	second_bg:addChild(oneFont2)
	-- 次
	local oneFont3 = CCLabelTTF:create(GetLocalizeStringBy("key_3010"),g_sFontName,25)
	oneFont3:setColor(ccc3(0xff,0xff,0xff))
	oneFont3:setAnchorPoint(ccp(0,0))
	oneFont3:setPosition(ccp(oneFont2:getPositionX()+oneFont2:getContentSize().width,oneFont1:getPositionY()))
	second_bg:addChild(oneFont3)

	-- 第二句 您当前剩余挑战数
	local twoFont1 = CCLabelTTF:create(GetLocalizeStringBy("key_1796"),g_sFontName,25)
	twoFont1:setColor(ccc3(0xff,0xff,0xff))
	twoFont1:setAnchorPoint(ccp(0,0))
	twoFont1:setPosition(ccp(60,30))
	second_bg:addChild(twoFont1)
	-- 次数
    local myTimes = _maxCanPkNum -_myUsePkNum
    local twoFont2 = CCLabelTTF:create(myTimes,g_sFontName,25)
	twoFont2:setColor(ccc3(0x21,0xf7,0x05))
	twoFont2:setAnchorPoint(ccp(0,0))
	twoFont2:setPosition(ccp(twoFont1:getPositionX()+twoFont1:getContentSize().width,twoFont1:getPositionY()))
	second_bg:addChild(twoFont2)
	-- 次
	local twoFont3 = CCLabelTTF:create(GetLocalizeStringBy("key_3010"),g_sFontName,25)
	twoFont3:setColor(ccc3(0xff,0xff,0xff))
	twoFont3:setAnchorPoint(ccp(0,0))
	twoFont3:setPosition(ccp(twoFont2:getPositionX()+twoFont2:getContentSize().width,twoFont1:getPositionY()))
	second_bg:addChild(twoFont3)

	-- 下边两句
	local str = GetLocalizeStringBy("key_3375") .. _maxSamePkNum .. GetLocalizeStringBy("key_3402")
	local threeFont1 = CCLabelTTF:create(str,g_sFontName,25)
	threeFont1:setColor(ccc3(0x00,0x00,0x00))
	threeFont1:setAnchorPoint(ccp(0,0))
	threeFont1:setPosition(ccp(90,150))
	_backGround:addChild(threeFont1)
	-- 次数
    local useTimes = _samePkNum
    local threeFont2 = CCLabelTTF:create(useTimes,g_sFontName,25)
	threeFont2:setColor(ccc3(0x0e,0x79,0x00))
	threeFont2:setAnchorPoint(ccp(0,0))
	threeFont2:setPosition(ccp(threeFont1:getPositionX()+threeFont1:getContentSize().width,threeFont1:getPositionY()))
	_backGround:addChild(threeFont2)
	-- 次
	local threeFont3 = CCLabelTTF:create(GetLocalizeStringBy("key_3357"),g_sFontName,25)
	threeFont3:setColor(ccc3(0x00,0x00,0x00))
	threeFont3:setAnchorPoint(ccp(0,0))
	threeFont3:setPosition(ccp(threeFont2:getPositionX()+threeFont2:getContentSize().width,threeFont1:getPositionY()))
	_backGround:addChild(threeFont3)

	-- 是否挑战
	local fourFont = CCLabelTTF:create(GetLocalizeStringBy("key_2402"),g_sFontName,25)
	fourFont:setColor(ccc3(0x00,0x00,0x00))
	fourFont:setAnchorPoint(ccp(0,0))
	fourFont:setPosition(ccp(90,110))
	_backGround:addChild(fourFont)
	
end

local function serviceCallFun( ret )
	if(tonumber(ret.isFriend) == 1)then
		-- 数据
		_maxCanPkNum,_maxBePkNum,_maxSamePkNum = FriendData.getPKMaxNum()
		-- 我已经挑战的次数
		_myUsePkNum = tonumber(ret.pk_num)
		-- 该好友被挑战的次数
		_friendBePkNum = tonumber(ret.friend_bepk_num)
		-- 已经挑战该好友的次数
		_samePkNum = tonumber(ret.sameFriendNum)
		-- 初始化界面
		initPKLayer()
	else
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1000"))
	end
end 


-- 显示pk界面
function showPkLayer( uid )
	init()

	-- pk好友uid
	_pkUid = uid

	FriendService.getPkInfo(uid,serviceCallFun)
end

























































