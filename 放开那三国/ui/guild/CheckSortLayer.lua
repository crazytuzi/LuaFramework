-- Filename：	CheckSortLayer.lua
-- Author：		zhang zihang
-- Date：		2014-1-20
-- Purpose：		申请排序界面

module("CheckSortLayer", package.seeall)

local _bgLayer
local itemInfoSpite
local tagTable
local buttomMenu
local selectId
local nowMethod
function init()
	_bgLayer = nil
	itemInfoSpite = nil
	tagTable = {}
	buttomMenu = nil
	selectId = 1
	nowMethod = nil
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

local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -550, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then

		_bgLayer:unregisterScriptTouchHandler()
	end
end

function closeCb()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

function makeSure()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
	MemberListLayer.setSortTypeAndRefreshDelegate(nowMethod-2000)
end

function fnHandlerOfMenuItemStarLevelSell(tag,item_obj)
	local item = tolua.cast(buttomMenu:getChildByTag(tagTable[selectId]), "CCMenuItemImage")
	local ccSelected = tolua.cast(item:getChildByTag(tagTable[selectId]), "CCSprite")
	ccSelected:setVisible(false)
	if tag == tagTable[1] then
		local item = tolua.cast(buttomMenu:getChildByTag(tagTable[1]), "CCMenuItemImage")
		local ccSelected = tolua.cast(item:getChildByTag(tagTable[1]), "CCSprite")
		ccSelected:setVisible(true)
		selectId = 1
		nowMethod = 2001
	end
	if tag == tagTable[2] then
		local item = tolua.cast(buttomMenu:getChildByTag(tagTable[2]), "CCMenuItemImage")
		local ccSelected = tolua.cast(item:getChildByTag(tagTable[2]), "CCSprite")
		ccSelected:setVisible(true)
		selectId = 2
		nowMethod = 2002
	end
	if tag == tagTable[3] then
		local item = tolua.cast(buttomMenu:getChildByTag(tagTable[3]), "CCMenuItemImage")
		local ccSelected = tolua.cast(item:getChildByTag(tagTable[3]), "CCSprite")
		ccSelected:setVisible(true)
		selectId = 3
		nowMethod = 2003
	end
	if tag == tagTable[4] then
		local item = tolua.cast(buttomMenu:getChildByTag(tagTable[4]), "CCMenuItemImage")
		local ccSelected = tolua.cast(item:getChildByTag(tagTable[4]), "CCSprite")
		ccSelected:setVisible(true)
		selectId = 4
		nowMethod = 2004
	end
end

function createFourButtom()
	buttomMenu = CCMenu:create()
    buttomMenu:setPosition(ccp(0,0))
    buttomMenu:setTouchPriority(-552)
    itemInfoSpite:addChild(buttomMenu,99)
	
    local nameTable = {GetLocalizeStringBy("key_2630"),GetLocalizeStringBy("key_1681"),GetLocalizeStringBy("key_2045"),GetLocalizeStringBy("key_1514")}
	for i = 1,4 do
		tagTable[i] = 1000+i
		
		--local item = CCMenuItemImage:create("images/hero/star_sell/item_bg_n.png", "images/hero/star_sell/item_bg_h.png")
		local item = LuaCC.create9ScaleMenuItem("images/hero/star_sell/item_bg_n.png","images/hero/star_sell/item_bg_h.png",CCSizeMake(330, 60),nameTable[i],ccc3(0xff, 0xdb, 0x1c),30,g_sFontName,1, ccc3(0x00, 0x00, 0x00))
		item:registerScriptTapHandler(fnHandlerOfMenuItemStarLevelSell)
		item:setAnchorPoint(ccp(0.5,0.5))
		buttomMenu:addChild(item,0,tagTable[i])
		item:setPosition(ccp(itemInfoSpite:getContentSize().width/2,itemInfoSpite:getContentSize().height*0.85-itemInfoSpite:getContentSize().height*0.7*(i-1)/3))
		local ccSpriteSelected = CCSprite:create("images/common/checked.png")
		ccSpriteSelected:setAnchorPoint(ccp(1,0.5))
		ccSpriteSelected:setPosition(ccp(item:getContentSize().width, item:getContentSize().height/2))
		ccSpriteSelected:setVisible(false)
		item:addChild(ccSpriteSelected, 0, tagTable[i])
	end
	local item = tolua.cast(buttomMenu:getChildByTag(tagTable[selectId]), "CCMenuItemImage")
	local ccSelected = tolua.cast(item:getChildByTag(tagTable[selectId]), "CCSprite")
	ccSelected:setVisible(true)
end

function createBackGround()
	require "script/ui/main/MainScene"
    local _myScale = MainScene.elementScale
    local _mySize = CCSizeMake(620,600)

    local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
    local breakDownGiftBg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    breakDownGiftBg:setContentSize(_mySize)
    breakDownGiftBg:setScale(_myScale)
    breakDownGiftBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    breakDownGiftBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(breakDownGiftBg)

    local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(breakDownGiftBg:getContentSize().width*0.5, breakDownGiftBg:getContentSize().height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	breakDownGiftBg:addChild(titleBg)

	--奖励的标题文本
	local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_2246"), g_sFontPangWa,33,2,ccc3(0x00,0x00,0x0),type_shadow)
    labelTitle:setAnchorPoint(ccp(0.5,0.5))
	labelTitle:setColor(ccc3(0xff,0xe4,0x00))
	labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5))
	titleBg:addChild(labelTitle)

	itemInfoSpite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    itemInfoSpite:setContentSize(CCSizeMake(556,400))
    itemInfoSpite:setPosition(ccp(breakDownGiftBg:getContentSize().width*0.5,breakDownGiftBg:getContentSize().height-50))
    itemInfoSpite:setAnchorPoint(ccp(0.5,1))
    breakDownGiftBg:addChild(itemInfoSpite)

    createFourButtom()

	-- 关闭按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-551)
    breakDownGiftBg:addChild(menu,99)
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(_mySize.width*1.03,_mySize.height*1.03))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menu:addChild(closeBtn)

    local ccBtnSure = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 64), GetLocalizeStringBy("key_2229"), ccc3(0xfe, 0xdb, 0x1c),28,g_sFontPangWa,1, ccc3(0, 0, 0))
    ccBtnSure:setPosition(ccp(breakDownGiftBg:getContentSize().width/3,75))
    ccBtnSure:setAnchorPoint(ccp(0.5,0.5))
    ccBtnSure:registerScriptTapHandler(makeSure)
    menu:addChild(ccBtnSure)

    local ccBtnCancel = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 64), GetLocalizeStringBy("key_1106"), ccc3(0xfe, 0xdb, 0x1c),28,g_sFontPangWa,1, ccc3(0, 0, 0))
    ccBtnCancel:setPosition(ccp(breakDownGiftBg:getContentSize().width*2/3,75))
    ccBtnCancel:setAnchorPoint(ccp(0.5,0.5))
    ccBtnCancel:registerScriptTapHandler(closeCb)
    menu:addChild(ccBtnCancel)
end

function showLayer(orignId)
	init()
	
	if orignId ~= nil then
		selectId = orignId
	end

	nowMethod = 2000+selectId

	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)

    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,999,1500)

    createBackGround()
end
