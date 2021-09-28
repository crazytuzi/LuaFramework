-- FileName: HuntSoulLayer.lua 
-- Author: Li Cong 
-- Date: 14-2-11 
-- Purpose: function description of module 


module("HuntSoulLayer", package.seeall)
require "script/ui/huntSoul/HuntSoulData"
require "script/ui/huntSoul/HuntSoulService"

local _bgLayer 				= nil   
local topBg 				= nil
local _silverLabel 			= nil
local _goldLabel 			= nil
local btnFrameSp 			= nil
local huntBtn				= nil
local soulBtn				= nil
local _curButton 			= nil
local _curDisplayLayer 		= nil
local bulletinLayerSize 	= nil


-- 初始化
function init( ... )
	_bgLayer 			= nil  
	_bgSprite 			= nil
	topBg 				= nil
	_silverLabel 		= nil
	_goldLabel 			= nil
	btnFrameSp 			= nil
	huntBtn				= nil
	soulBtn				= nil
	_curButton 			= nil
	_curDisplayLayer 	= nil
	bulletinLayerSize 	= nil
end


-- 初始化猎魂界面
function initHuntSoulLayer( sign )
	-- 公告栏大小
	require "script/ui/main/BulletinLayer"
    bulletinLayerSize = BulletinLayer.getLayerContentSize()

    -- 上标题栏 显示战斗力，银币，金币
	topBg = CCSprite:create("images/hero/avatar_attr_bg.png")
	topBg:setAnchorPoint(ccp(0,1))
	topBg:setPosition(ccp(0, _bgLayer:getContentSize().height-bulletinLayerSize.height*g_fScaleX))
	_bgLayer:addChild(topBg,10)
	topBg:setScale(g_fScaleX)
	
	-- 战斗力
	local powerDescLabel = CCSprite:create("images/common/fight_value.png")
    powerDescLabel:setAnchorPoint(ccp(0.5,0.5))
    powerDescLabel:setPosition(topBg:getContentSize().width*0.13,topBg:getContentSize().height*0.43)
    topBg:addChild(powerDescLabel)
    local _powerDescLabel = CCRenderLabel:create(UserModel.getFightForceValue() , g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _powerDescLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    _powerDescLabel:setPosition(topBg:getContentSize().width*0.23,topBg:getContentSize().height*0.66)
    topBg:addChild(_powerDescLabel)

	-- 银币
	_silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(UserModel.getSilverNumber()),g_sFontName,20)  -- modified by yangrui at 2015-12-03
	_silverLabel:setColor(ccc3(0xe5, 0xf9, 0xff))
	_silverLabel:setAnchorPoint(ccp(0, 0))
	_silverLabel:setPosition(ccp(390, 10))
	topBg:addChild(_silverLabel)

	-- 金币
	_goldLabel = CCLabelTTF:create(UserModel.getGoldNumber(), g_sFontName, 20)
	_goldLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	_goldLabel:setAnchorPoint(ccp(0, 0))
	_goldLabel:setPosition(ccp(522, 10))
	topBg:addChild(_goldLabel)

	--按钮背景
    local fullRect = CCRectMake(0,0,58,99)
	local insetRect = CCRectMake(20,20,18,59)
	btnFrameSp = CCScale9Sprite:create("images/common/menubg.png", fullRect, insetRect)
	btnFrameSp:setPreferredSize(CCSizeMake(640, 100))
	btnFrameSp:setAnchorPoint(ccp(0.5, 1))
	btnFrameSp:setPosition(ccp(_bgLayer:getContentSize().width/2 , _bgLayer:getContentSize().height-topBg:getContentSize().height*g_fScaleX-bulletinLayerSize.height*g_fScaleX))
	_bgLayer:addChild(btnFrameSp,10)
	btnFrameSp:setScale(g_fScaleX)

	local menuBar = CCMenu:create()
	menuBar:setTouchPriority(-230)
	menuBar:setPosition(ccp(0, 0))
	btnFrameSp:addChild(menuBar)
	-- 猎魂
	--兼容东南亚英文版
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		huntBtn = LuaMenuItem.createMenuItemSprite( GetLocalizeStringBy("key_1813"),26,22 )
	else
		huntBtn = LuaMenuItem.createMenuItemSprite( GetLocalizeStringBy("key_1813"))
	end
	huntBtn:setAnchorPoint(ccp(0, 0))
	huntBtn:setPosition(ccp(btnFrameSp:getContentSize().width*0.01, btnFrameSp:getContentSize().height*0.1))
	huntBtn:registerScriptTapHandler(menuBarAction)
	menuBar:addChild(huntBtn, 2, 10001)

	-- 战魂
	--兼容东南亚英文版
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		soulBtn = LuaMenuItem.createMenuItemSprite( GetLocalizeStringBy("key_1243"),26,22)
	else
		soulBtn = LuaMenuItem.createMenuItemSprite( GetLocalizeStringBy("key_1243"))
	end
	soulBtn:setAnchorPoint(ccp(0, 0))
	soulBtn:setPosition(ccp(btnFrameSp:getContentSize().width*0.26, btnFrameSp:getContentSize().height*0.1))
	soulBtn:registerScriptTapHandler(menuBarAction)
	menuBar:addChild(soulBtn, 2, 10002)

	-- 装备战魂按钮
	local normalSprite  =CCScale9Sprite:create("images/hunt/zb_n.png")
    local selectSprite  =CCScale9Sprite:create("images/hunt/zb_h.png")
    local addSoulMenuItem = CCMenuItemSprite:create(normalSprite,selectSprite)
	addSoulMenuItem:registerScriptTapHandler(addSoulMenuAction)
	addSoulMenuItem:setAnchorPoint(ccp(1,0.5))
	addSoulMenuItem:setPosition(ccp(btnFrameSp:getContentSize().width-20,btnFrameSp:getContentSize().height*0.5))
	menuBar:addChild(addSoulMenuItem)

   	-- 战魂介绍
   	local normalSprite = CCScale9Sprite:create("images/hunt/jieshao_n.png")
    local selectSprite = CCScale9Sprite:create("images/hunt/jieshao_h.png")
    local jieShaoMenuItem = CCMenuItemSprite:create(normalSprite,selectSprite)
	jieShaoMenuItem:registerScriptTapHandler(jieShaoMenuAction)
	jieShaoMenuItem:setAnchorPoint(ccp(1,0.5))
	jieShaoMenuItem:setPosition(ccp(btnFrameSp:getContentSize().width-addSoulMenuItem:getContentSize().width-40,btnFrameSp:getContentSize().height*0.5))
	menuBar:addChild(jieShaoMenuItem)

	-- 当前状态
	if(sign == "fightSoulBag")then
		_curButton = soulBtn
	else
		_curButton = huntBtn
	end
	_curButton:selected()
	local curDisplayLayerHight = _bgLayer:getContentSize().height-bulletinLayerSize.height*g_fScaleX-topBg:getContentSize().height*g_fScaleX-btnFrameSp:getContentSize().height*g_fScaleX-MenuLayer.getHeight()
	-- 猎魂
	if(_curButton == huntBtn) then
		require "script/ui/huntSoul/SearchSoulLayer"
		_curDisplayLayer = SearchSoulLayer.createSearchSoulLayer(CCSizeMake(_bgLayer:getContentSize().width, curDisplayLayerHight))
	elseif(_curButton == soulBtn) then
	-- 战魂
		require "script/ui/huntSoul/FightSoulLayer"
		_curDisplayLayer = FightSoulLayer.createFightSoulLayer(CCSizeMake(_bgLayer:getContentSize().width, curDisplayLayerHight))
	end
	_curDisplayLayer:setPosition(ccp(0,MenuLayer.getHeight()))
	_bgLayer:addChild(_curDisplayLayer)
end

-- 介绍猎魂回调
function jieShaoMenuAction( ... )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	
	require "script/ui/huntSoul/introduceLayer"
	introduceLayer.ShowIntroduceLayer()
end

-- 猎魂 和 战魂 按钮回调
function menuBarAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
	itemBtn:selected()
	if (_curButton ~= itemBtn) then
		_curButton:unselected()
		_curButton = itemBtn
		_curButton:selected()
		if(_curDisplayLayer) then
			_curDisplayLayer:removeFromParentAndCleanup(true)
			_curDisplayLayer=nil
			if g_system_type == kBT_PLATFORM_ANDROID then
		        require "script/utils/LuaUtil"
		        checkMem()
		    else
		        CCTextureCache:sharedTextureCache():removeUnusedTextures()
		    end
		end
		local curDisplayLayerHight = _bgLayer:getContentSize().height-bulletinLayerSize.height*g_fScaleX-topBg:getContentSize().height*g_fScaleX-btnFrameSp:getContentSize().height*g_fScaleX-MenuLayer.getHeight()
		-- 猎魂
		if(_curButton == huntBtn) then
			require "script/ui/huntSoul/SearchSoulLayer"
			_curDisplayLayer = SearchSoulLayer.createSearchSoulLayer(CCSizeMake(_bgLayer:getContentSize().width, curDisplayLayerHight))
		elseif(_curButton == soulBtn) then
		-- 战魂
			require "script/ui/huntSoul/FightSoulLayer"
			_curDisplayLayer = FightSoulLayer.createFightSoulLayer(CCSizeMake(_bgLayer:getContentSize().width, curDisplayLayerHight))
		end
		_curDisplayLayer:setPosition(ccp(0,MenuLayer.getHeight()))
		_bgLayer:addChild(_curDisplayLayer)
	end
end

-- 装备战魂按钮回调
function addSoulMenuAction( ... )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	
	require "script/ui/formation/FormationLayer"
	local layer = FormationLayer.createLayer(nil, false, false, false, 2)
	MainScene.changeLayer(layer,"FormationLayer")
end

-- 刷新银币
function refreshCoin( ... )
	if(_silverLabel)then
		_silverLabel:setString(string.convertSilverUtilByInternational(UserModel.getSilverNumber()))  -- modified by yangrui at 2015-12-03
	end
end

-- 刷新金币
function refreshGold( ... )
	if(_goldLabel)then
		_goldLabel:setString(UserModel.getGoldNumber())
	end
end

-- 得到银币的屏幕坐标系
function getCoinScreenPosition( ... )
	local temp = ccp(_silverLabel:getContentSize().width/2,_silverLabel:getContentSize().height/2 )
	local position = _silverLabel:convertToWorldSpace(ccp(temp.x,temp.y))
	return position
end

-- 创建猎魂界面
-- sign: fightSoulBag 为战魂背包标识， 默认为猎魂界面
function createHuntSoulLayer( sign )
	init()
	_bgLayer = CCLayer:create()

	-- 隐藏玩家信息栏
	MainScene.setMainSceneViewsVisible(true, false, true)

	-- 初始化猎魂界面
	initHuntSoulLayer(sign)


	return _bgLayer
end




























