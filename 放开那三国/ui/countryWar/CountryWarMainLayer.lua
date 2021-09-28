-- FileName: CountryWarMainLayer.lua
-- Author: lcy
-- Date: 2015-11-2
-- Purpose: 国战主界面
--[[TODO List]]

module("CountryWarMainLayer", package.seeall)

require "script/ui/countryWar/CountryWarMainService"
require "script/ui/countryWar/CountryWarMainData"
require "script/ui/countryWar/CountryWarObserver"
require "script/ui/countryWar/CountryWarUtil"

local kBgMenuZorder = 10
local kWaitLayerZorder = 15
local kTopMenuZorder = 20
local kSubLayerZorder = 30

local _bgLayer     	= nil
local _subBgLayer  	= nil
local _bgSprite 	= nil

local kBgMap = {
	["main"] = "images/country_war/main_bg.jpg",
	["support"] = "images/lord_war/bg.jpg",
	["worship"] = "images/country_war/worship/worship_bg.jpg",
}

function init( ... )
	_bgLayer     	= nil
	_subBgLayer	 	= nil
	_goldButton  	= nil
	_itemButton  	= nil
	_bgSprite 		= nil
end
--[[
	@des 	:入口函数，用于场景切换
--]]
function show()
	-- 底包是否支持国战
    require "script/ui/login/CheckVersionUtil"
    local isSupport = CheckVersionUtil.isSuppurtCountryWar()
    print("g_publish_version",g_publish_version,"isSupport",isSupport)
    if(isSupport == false)then
        return
    end
    local layer = CountryWarMainLayer.createLayer()
    MainScene.changeLayer(layer, "CountryWarMainLayer")
end

--[[
	@des : 创建layer
--]]
function createLayer()
    init()
    _isEnter = true
	_bgLayer = CCLayer:create()
	_layerSize = g_winSize 
	MainScene.setMainSceneViewsVisible(false, false, false)

	_bgSprite = CCSprite:create("images/country_war/main_bg.jpg")
	_bgSprite:setPosition(ccps(0.5, 0.5))
	_bgSprite:setAnchorPoint(ccp(0.5, 0.5))
	_bgSprite:setScale(g_fBgScaleRatio * 1.02)
	_bgLayer:addChild(_bgSprite)

	createTopUi()

	_subBgLayer = CCLayer:create()
	_bgLayer:addChild(_subBgLayer, 10)

	CountryWarMainService.getCoutrywarInfo(function ( pRecData )
		CountryWarMainData.setCountryWarInfo(pRecData)
		CountryWarObserver.initObserver()
		CountryWarObserver.registerListener(stageDidChange)
		addSubLayer()
		_bgLayer:registerScriptHandler(onNodeEvent)
	end)
	require "script/audio/AudioUtil"
    AudioUtil.playBgm("audio/bgm/music02.mp3",true)
	return _bgLayer
end

function onNodeEvent( pEventType )
	if pEventType == "exit" then
		CountryWarObserver.destoryObserver()
	else

	end
end

--[[
	@des : 创建顶部ui
--]]
function createTopUi( ... )

	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setAnchorPoint(ccp(0,0))
	_bgLayer:addChild(menu, kBgMenuZorder)
	menu:setTouchPriority(-504)


	--奖励预览按钮
	local rewardPreviewButton = CCMenuItemImage:create("images/match/reward_n.png","images/match/reward_h.png")
	rewardPreviewButton:setAnchorPoint(ccp(0.5, 0.5))
	rewardPreviewButton:setPosition(ccp(_layerSize.width * 0.56 ,_layerSize.height * 0.95))
	rewardPreviewButton:registerScriptTapHandler(rewardPreviewButtonCallback)
	menu:addChild(rewardPreviewButton)
	rewardPreviewButton:setScale(MainScene.elementScale)

	--bank
	local bankButton = CCMenuItemImage:create("images/country_war/guozhanzijin_btn_n.png","images/country_war/guozhanzijin_btn_h.png")
	bankButton:setAnchorPoint(ccp(0.5, 0.5))
	bankButton:setPosition(ccp(_layerSize.width * 0.23 ,_layerSize.height * 0.95))
	bankButton:registerScriptTapHandler(bankButtonCallback)
	menu:addChild(bankButton)
	bankButton:setScale(MainScene.elementScale)

	--商店和说明返回用的menu
	local topMenu = CCMenu:create()
	topMenu:setAnchorPoint(ccp(0, 0))
	topMenu:setPosition(0,0)
	_bgLayer:addChild(topMenu, kTopMenuZorder)
	topMenu:setTouchPriority(-510)

	--商店
	local shopButton = CCMenuItemImage:create("images/country_war/shop_btn_n.png","images/country_war/shop_btn_h.png")
	shopButton:setAnchorPoint(ccp(0.5, 0.5))
	shopButton:setPosition(ccp(_layerSize.width * 0.40 ,_layerSize.height * 0.95))
	shopButton:registerScriptTapHandler(shopButtonCallback)
	topMenu:addChild(shopButton)
	shopButton:setScale(MainScene.elementScale)

	--活动说明
	local explainButton = CCMenuItemImage:create("images/recharge/card_active/btn_desc/btn_desc_n.png","images/recharge/card_active/btn_desc/btn_desc_h.png")
	explainButton:setAnchorPoint(ccp(0.5, 0.5))
	explainButton:registerScriptTapHandler(explainButtonCallFunc)
	explainButton:setPosition(ccp(_layerSize.width * 0.73 ,_layerSize.height * 0.95))
	topMenu:addChild(explainButton)
	explainButton:setScale(MainScene.elementScale)

	--关闭按钮
	local closeButton = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:registerScriptTapHandler(closeButtonCallFunc)
	closeButton:setPosition(ccp(_layerSize.width * 0.9 ,_layerSize.height * 0.95))
	topMenu:addChild(closeButton)
	closeButton:setScale(MainScene.elementScale)
end

function createMenuItem(normalString, selectedString, disabledString, size)
    local norSprite = CCScale9Sprite:create("images/common/btn/btn1_d.png")
	norSprite:setContentSize(size)
	local norTitle  =  CCRenderLabel:create(normalString, g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	norTitle:setColor(ccc3(0xfe, 0xdb, 0x1c))
	norTitle:setPosition(ccpsprite(0.5, 0.5, norSprite))
	norTitle:setAnchorPoint(ccp(0.5, 0.5))
	norSprite:addChild(norTitle)
	
	local higSprite = CCScale9Sprite:create("images/common/btn/btn1_n.png")
	higSprite:setContentSize(size)
    selectedString = selectedString or normalString
	local higTitle  =  CCRenderLabel:create(selectedString, g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	higTitle:setColor(ccc3(0xfe, 0xdb, 0x1c))
	higTitle:setPosition(ccpsprite(0.5, 0.5, higSprite))
	higTitle:setAnchorPoint(ccp(0.5, 0.5))
	higSprite:addChild(higTitle)
	
	local graySprite = CCScale9Sprite:create("images/common/btn/btn1_g.png")
	graySprite:setContentSize(size)
    disabledString = disabledString or normalString
	local grayTitle  =  CCRenderLabel:create(disabledString, g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	grayTitle:setColor(ccc3(78, 78, 78))
	grayTitle:setPosition(ccpsprite(0.5, 0.5, graySprite))
	grayTitle:setAnchorPoint(ccp(0.5, 0.5))
	graySprite:addChild(grayTitle)
	
	local button = CCMenuItemSprite:create(norSprite, higSprite, graySprite)
    return button
end

--[[
	@des:添加子界面
--]]
function addSubLayer(pCurrStage)
	if tolua.isnull(_subBgLayer) then
		return
	end
	_subBgLayer:removeAllChildrenWithCleanup(true)
	local currStage = pCurrStage or CountryWarMainData.getCurStage()

	print("currStage", currStage)
	if currStage == CountryWarDef.TEAM then
		setBgImage(kBgMap["main"])
		addTeamLayer()
	elseif currStage > CountryWarDef.TEAM and currStage <= CountryWarDef.AUDITION then
		setBgImage(kBgMap["main"])
		addSignUpLayer()
	elseif currStage >= CountryWarDef.SUPPORT and currStage <= CountryWarDef.FINALTION then
		setBgImage(kBgMap["support"])
		addCheerLayer()
	elseif currStage == CountryWarDef.WORSHIP then
		setBgImage(kBgMap["worship"])
		addWorshipLayer()
	end
end

--[[
	@des:更换背景图
--]]
function setBgImage( pImagePath )
	local texture = CCTextureCache:sharedTextureCache():addImage(pImagePath)
	local size = texture:getContentSize()
	local spriteFrame = CCSpriteFrame:create(pImagePath, CCRect(0, 0, size.width, size.height))
	_bgSprite:setDisplayFrame(spriteFrame)
end

--[[
	@des:关闭按钮回调
--]]
function closeButtonCallFunc( ... )
	--注销国战链接
	require "script/ui/countryWar/war/CountryWarController"
	CountryWarController.logoutCross()
	--返回主界面
	require "script/ui/main/MainBaseLayer"
	local main_base_layer = MainBaseLayer.create()
	MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
	MainScene.setMainSceneViewsVisible(true,true,true)
end

--[[
	@des:活动说明
--]]
function explainButtonCallFunc( ... )
	require "script/ui/countryWar/CountryWarExplainDialog"
	CountryWarExplainDialog.show()
end

--[[
	@des:奖励预览
--]]
function rewardPreviewButtonCallback( ... )
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/mission/reward/MissionRewardLayer"
	MissionRewardLayer.show(nil,nil,"countryWar")
end

--[[
	@des:商店按钮回调
--]]
function shopButtonCallback( ... )
     require "script/ui/countryWar/shop/CountryWarShopLayer"
     CountryWarShopLayer.show()
end

--[[
	@des:国战基金
--]]
function bankButtonCallback( ... )
	require "script/ui/countryWar/foundation/CountryWarFoundationLayer"
	CountryWarFoundationLayer.showLayer()
end

--[[
	@des:添加分组界面
--]]
function addTeamLayer( ... )

	local maskLayer = BaseUI.createMaskLayer(-507)
	_subBgLayer:addChild(maskLayer)

	local cuntdownTime = CountryWarUtil.getCountdownSprite()
	cuntdownTime:setAnchorPoint(ccp(0.5, 0.5))
	cuntdownTime:setPosition(ccps(0.5, 0.5))
	maskLayer:addChild(cuntdownTime, 50)
end

--[[
	@des:添加报名界面
--]]
function addSignUpLayer( ... )
	-- -- body
	require "script/ui/countryWar/signUp/CountryWarSignLayer"
	local layer = CountryWarSignLayer.createLayer()
	_subBgLayer:addChild(layer)
end

--[[
	@des: 进入膜拜 add by yangrui 2015-11-18
--]]
function addWorshipLayer( ... )
	require "script/ui/countryWar/worship/CountryWarWorshipLayer"
	local layer = CountryWarWorshipLayer.createWorshipLayer()
	_subBgLayer:addChild(layer)
end

--[[
	@des: 进入助威界面
--]]
function addCheerLayer( ... )
	--没有报名就不能进入
	require "script/ui/countryWar/cheer/CountryWarCheerListLayer"
	local layer = CountryWarCheerListLayer.create()
	_subBgLayer:addChild(layer)
end

--[[
	@des:阶段变化回调
	@parm:pCurrStage 返回当前stag
--]]
function stageDidChange( pCurrStage )
	print("change stage =", pCurrStage)
	addSubLayer(pCurrStage)
end
