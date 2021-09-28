-- Filename: TreasureMainView.lua
-- Author: lichenyang
-- Date: 2013-11-2
-- Purpose: 宝物主界面

module("TreasureMainView", package.seeall)

require "script/ui/treasure/TreasureFuseView"
require "script/ui/treasure/TreasureService"

local ImagePath = "images/treasure/"

local mainLayer 		= nil
local layerSize 		= nil
local btnFrameSp 		= nil
local topBg 			= nil
local _curButton 		= nil
local _curDisplayLayer 	= nil
local _staminaLabel 	= nil
function init( ... )
	mainLayer 			= nil
	layerSize 			= nil
	btnFrameSp 			= nil
	topBg				= nil
	_curButton			= nil
	_curDisplayLayer	= nil
	_staminaLabel 		= nil
end
---------------------------[[ ui 记忆数据]]-------------------------------

local memoryTreasureType = nil


----------------------------[[ ui创建 ]]----------------------------------
--[[
	@des:	创建最顶部信息条
]]
function createTopUI( ... )
	-- 上标题栏 显示战斗力，银币，金币
	require "script/model/user/UserModel"
    local userInfo = UserModel.getUserInfo()
    if userInfo == nil then
        return
    end
	
	-- 上标题栏 显示战斗力，银币，金币
	topBg = CCSprite:create("images/star/intimate/top.png")
	topBg:setAnchorPoint(ccp(0,1))
	topBg:setPosition(ccp(0, mainLayer:getContentSize().height))
	topBg:setScale(g_fScaleX/MainScene.elementScale)
	mainLayer:addChild(topBg)
	titleSize = topBg:getContentSize()
	
	-- 战斗力
    powerDescLabel = CCRenderLabel:create(UserModel.getFightForceValue() , g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    powerDescLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    powerDescLabel:setPosition(108, 34)
    topBg:addChild(powerDescLabel)

    -- 耐力
    _staminaLabel = CCLabelTTF:create(UserModel.getStaminaNumber() .. "/" .. UserModel.getMaxStaminaNumber(), g_sFontName, 20)
	_staminaLabel:setColor(ccc3(0xff, 0xff, 0xff))
	_staminaLabel:setAnchorPoint(ccp(0, 0))
	_staminaLabel:setPosition(ccp(278, 10))
	topBg:addChild(_staminaLabel)
	-- 注册耐力更新函数

	-- 刷新耐力显示UI
	local upDateStamina = function()
		if( _staminaLabel ~= nil)then
			_staminaLabel:setString(UserModel.getStaminaNumber() .. "/" .. UserModel.getMaxStaminaNumber())
		end
	end
	require "script/ui/main/MainScene"
	MainScene.registerStaminaNumberChangeCallback( upDateStamina )

	-- 银币
	-- modified by yangrui at 2015-12-03
	m_silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(UserModel.getSilverNumber()),g_sFontName,20)
	m_silverLabel:setColor(ccc3(0xe5, 0xf9, 0xff))
	m_silverLabel:setAnchorPoint(ccp(0, 0))
	m_silverLabel:setPosition(ccp(402, 10))
	topBg:addChild(m_silverLabel)

	-- 金币
	m_goldLabel = CCLabelTTF:create(UserModel.getGoldNumber(), g_sFontName, 20)
	m_goldLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	m_goldLabel:setAnchorPoint(ccp(0, 0))
	m_goldLabel:setPosition(ccp(522, 10))
	topBg:addChild(m_goldLabel)

	mainLayer:registerScriptHandler(function ( nodeType )
		if(nodeType == "exit") then
			print(GetLocalizeStringBy("key_3085"))
			upDateStamina= nil
			MainScene.registerStaminaNumberChangeCallback( nil )
		end
	end)
    return topBg
end

--[[
	@des:	创建分页按钮
]]
local function createMenu( )
	
	local fullRect = CCRectMake(0,0,58,99)
	local insetRect = CCRectMake(20,20,18,59)
	--按钮背景
	btnFrameSp = CCScale9Sprite:create("images/common/menubg.png", fullRect, insetRect)
	btnFrameSp:setPreferredSize(CCSizeMake(640, 100))
	btnFrameSp:setAnchorPoint(ccp(0.5, 1))
	btnFrameSp:setPosition(ccp(mainLayer:getContentSize().width/2 , mainLayer:getContentSize().height- topBg:getContentSize().height * g_fScaleX ))
	btnFrameSp:setScale(g_fScaleX/MainScene.elementScale)
	mainLayer:addChild(btnFrameSp, 10)

	local shopMenuBar = CCMenu:create()
	shopMenuBar:setPosition(ccp(0, 0))
	btnFrameSp:addChild(shopMenuBar, 10)
	-- 战马抢夺
	_pubButton = LuaMenuItem.createMenuItemSprite(GetLocalizeStringBy("key_2850"), 30)
	_pubButton:setAnchorPoint(ccp(0, 0))
	_pubButton:setPosition(ccp(btnFrameSp:getContentSize().width*0, btnFrameSp:getContentSize().height*0.1))
	_pubButton:registerScriptTapHandler(tabMenuCallFunc)
	shopMenuBar:addChild(_pubButton, 1, kTreasureHorseType)

	-- 兵书抢夺
	_propButton = LuaMenuItem.createMenuItemSprite( GetLocalizeStringBy("key_2789"),30)
	_propButton:setAnchorPoint(ccp(0, 0))
	_propButton:setPosition(ccp(btnFrameSp:getContentSize().width*0.25, btnFrameSp:getContentSize().height*0.1))
	_propButton:registerScriptTapHandler(tabMenuCallFunc)
	shopMenuBar:addChild(_propButton, 1, kTreasureBookType)

	local  menuCloseBar = CCMenu:create()
	menuCloseBar:setTouchPriority(-150)
	menuCloseBar:setPosition(ccp(0,0))
	btnFrameSp:addChild(menuCloseBar)
	local closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:setAnchorPoint(ccp(0, 0))
	closeMenuItem:registerScriptTapHandler(closeLayerCallFunc)
	closeMenuItem:setAnchorPoint(ccp(1,0.5))
	closeMenuItem:setPosition(ccp(btnFrameSp:getContentSize().width-20,btnFrameSp:getContentSize().height*0.5+6))
	menuCloseBar:addChild(closeMenuItem)


	--免战按钮添加
	local shieldMenuItem = CCMenuItemImage:create("images/treasure/free_war_button_nor.png","images/treasure/free_war_button_hig.png")
	shieldMenuItem:setAnchorPoint(ccp(0, 0))
	shieldMenuItem:registerScriptTapHandler(shieldButtonCallback)
	shieldMenuItem:setAnchorPoint(ccp(1,0.5))
	shieldMenuItem:setPosition(ccp(btnFrameSp:getContentSize().width-160,btnFrameSp:getContentSize().height*0.5+6))
	menuCloseBar:addChild(shieldMenuItem)

		--计算层大小
	local t_layerSize = CCSizeMake(layerSize.width, mainLayer:getContentSize().height - topBg:getContentSize().height * g_fScaleX -btnFrameSp:getContentSize().height * g_fScaleX)
	if(memoryTreasureType == kTreasureHorseType or memoryTreasureType == nil) then
		_curButton = _pubButton
		_curButton:selected()
		memoryTreasureType = kTreasureHorseType
		_curDisplayLayer = TreasureFuseView.create(kTreasureHorseType, t_layerSize)
	elseif(memoryTreasureType == kTreasureBookType) then
		_curButton = _propButton
		_curButton:selected()
		_curDisplayLayer = TreasureFuseView.create(kTreasureBookType, t_layerSize)
	end
	mainLayer:addChild(_curDisplayLayer)
end 

--[[
	@des 		:主创建方法，创建整个碎片界面
	@return		:CCLayer
]]
function create()
	init()
	mainLayer = MainScene.createBaseLayer(ImagePath .. "background.jpg",true,false,true)
	layerSize = mainLayer:getContentSize()
	print("mainLayer size:",layerSize.width, layerSize.height)
	print("mainLayer scale", mainLayer:getScale())
	createTopUI()
	TreasureService.getSeizerInfo(function ( ... )
		createMenu()
	end)
	
	return mainLayer
end

----------------------------[[ 回调事件 ]]----------------------------------
--[[
	@des 		:分页按钮回调处理
]]
function tabMenuCallFunc( tag, itemBtn )
	itemBtn:selected()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
	if (_curButton ~= itemBtn) then
		if(_curButton == _pubButton) then
			PubLayer.stopScheduler()
		end
		_curButton:unselected()
		_curButton = itemBtn
		_curButton:selected()
		if(_curDisplayLayer) then
			_curDisplayLayer:removeFromParentAndCleanup(true)
			_curDisplayLayer=nil
		end
		--计算层大小
	local t_layerSize = CCSizeMake(layerSize.width, mainLayer:getContentSize().height - topBg:getContentSize().height * g_fScaleX -btnFrameSp:getContentSize().height * g_fScaleX)
		print("t_layerSize", t_layerSize)
		print("t_layerSize ", t_layerSize.width, t_layerSize.height)
		if(tag == kTreasureHorseType) then
			memoryTreasureType = kTreasureHorseType
			_curDisplayLayer = TreasureFuseView.create(kTreasureHorseType, t_layerSize)
		elseif(tag == kTreasureBookType) then
			memoryTreasureType = kTreasureBookType
			_curDisplayLayer = TreasureFuseView.create(kTreasureBookType, t_layerSize)
		end
		mainLayer:addChild(_curDisplayLayer)
	end
end


--[[
	@des 		:关闭按钮事件
]]
function closeLayerCallFunc( ... )
	require "script/ui/active/ActiveList"
	local activeListr = ActiveList.createActiveListLayer()
	MainScene.changeLayer(activeListr, "activeListr")
end

--[[
	@des:	免战按钮回调事件
]]
function shieldButtonCallback( sender,tag )

	require "script/ui/treasure/ShieldWarLay"
	ShieldWarLay.showLayer()

end


------------------------------------[[ui 刷新方法]]---------------------------------------------
function updateLabel( ... )
	-- modified by yangrui at 2015-12-03
	m_silverLabel:setString(string.convertSilverUtilByInternational(UserModel.getSilverNumber()))
	m_goldLabel:setString(UserModel.getGoldNumber())
end



