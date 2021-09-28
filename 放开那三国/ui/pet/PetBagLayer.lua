-- Filename：	PetBagLayer.lua
-- Author：		zhang zihang
-- Date：		2014-4-4
-- Purpose：		宠物的背包界面

module( "PetBagLayer", package.seeall)

require "script/model/user/UserModel"
require "script/utils/BaseUI"
require "script/ui/main/BulletinLayer"
require "script/ui/main/MainScene"
require "script/ui/main/MenuLayer"
require "script/ui/pet/PetData"
require "script/audio/AudioUtil"

local _bgLayer
local _layerSize     
local _ksTagBag
local _ksTagFrag  
local _menuBag
local _menuFrag
local menuLayerSize
local _bagLayerKey
local _fragLayerKey
local _scrollview_height
local nHeightOfBottom
local expandBtn
local needMoney
local _goldLabel
local ratio
local everyNum
local fragMentNum
local alertNum
local alertSprite

local function init()
	_bgLayer 	        = nil
    _layerSize          = nil   
    _menuBag            = nil
    _menuFrag           = nil
    menuLayerSize       = nil
    _scrollview_height  = nil
    nHeightOfBottom     = nil
    expandBtn           = nil
    _goldLabel          = nil

    _ksTagBag           = 1001
    _ksTagFrag          = 1002
    _bagLayerKey        = 2001
    _fragLayerKey       = 2002
    needMoney           = 0
    ratio               = nil
    everyNum            = nil
    fragMentNum         = nil
    alertNum            = nil
    alertSprite         = nil
end

   -- 上标题栏 显示战斗力，银币，金币
function createTopUI()
    local _topBg = CCSprite:create("images/hero/avatar_attr_bg.png")
    _topBg:setAnchorPoint(ccp(0,1))
    _topBg:setPosition(0,_layerSize.height - 32*MainScene.elementScale)
    _topBg:setScale(g_fScaleX)
    _bgLayer:addChild(_topBg, 10)

    local powerDescLabel = CCSprite:create("images/common/fight_value.png")
    powerDescLabel:setAnchorPoint(ccp(0.5,0.5))
    powerDescLabel:setPosition(_topBg:getContentSize().width*0.13,_topBg:getContentSize().height*0.43)
    _topBg:addChild(powerDescLabel)
    
    local _powerLabel = CCRenderLabel:create( UserModel.getFightForceValue(), g_sFontName, 23, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _powerLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    _powerLabel:setPosition(_topBg:getContentSize().width*0.23,_topBg:getContentSize().height*0.66)
    _topBg:addChild(_powerLabel)
    
    local _silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(UserModel.getSilverNumber()),g_sFontName,18)-- modified by yangrui at 2015-12-03
    _silverLabel:setColor(ccc3(0xe5,0xf9,0xff))
    _silverLabel:setAnchorPoint(ccp(0,0.5))
    _silverLabel:setPosition(_topBg:getContentSize().width*0.61,_topBg:getContentSize().height*0.43)
    _topBg:addChild(_silverLabel)
    
    _goldLabel = CCLabelTTF:create(UserModel.getGoldNumber()  ,g_sFontName,18)
    _goldLabel:setColor(ccc3(0xff,0xe2,0x44))
    _goldLabel:setAnchorPoint(ccp(0,0.5))
    _goldLabel:setPosition(_topBg:getContentSize().width*0.82,_topBg:getContentSize().height*0.43)
    _topBg:addChild(_goldLabel)
end

--进入背包界面
local function interBagLayer()
    local bagLayer = CCLayer:create()
    _bgLayer:addChild(bagLayer,1,_bagLayerKey)
    require "script/ui/pet/PetBagCell"
    local bagView = PetBagCell.creteBagTableView(_layerSize.width,_scrollview_height)
    --bagView:setTouchPriority(-551)
    bagLayer:addChild(bagView)

    local blackPosY = nHeightOfBottom+10*MainScene.elementScale

    --携带数栏
    local blackButton = CCScale9Sprite:create("images/copy/ecopy/lefttimesbg.png")
    blackButton:setContentSize(CCSizeMake(215,40))
    blackButton:setAnchorPoint(ccp(0.5,0))
    blackButton:setPosition(ccp(_layerSize.width/2,blackPosY))
    blackButton:setScale(g_fScaleX)
    bagLayer:addChild(blackButton)

    local character = CCLabelTTF:create(GetLocalizeStringBy("key_1838"), g_sFontName, 24)
    character:setColor(ccc3(0xff,0xff,0xff))
    ratio = CCLabelTTF:create(tostring(PetData.getPetNum()) .. "/" .. tostring(PetData.getOpenBagNum()), g_sFontName, 24)
    ratio:setColor(ccc3(0x00,0xff,0x18))

    local blackSize = blackButton:getContentSize()

    local underBlack = BaseUI.createHorizontalNode({character,ratio})
    underBlack:setAnchorPoint(ccp(0.5,0.5))
    underBlack:setPosition(ccp(blackSize.width/2,blackSize.height/2))
    blackButton:addChild(underBlack)

    bagView:setPosition(ccp(0,nHeightOfBottom))
end

local function  interFragLayer()
    local fragLayer = CCLayer:create()
    _bgLayer:addChild(fragLayer,1,_fragLayerKey)

    require "script/ui/pet/PetFragCell"
    local fragView = PetFragCell.crateFragTableView(_layerSize.width,_scrollview_height)
    fragLayer:addChild(fragView)

    local blackPosY = nHeightOfBottom+10*MainScene.elementScale

    fragView:setPosition(ccp(0,nHeightOfBottom))
end

function changeViewLayer(tag,obj)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")

    if tag == _ksTagBag then
        _menuBag:setEnabled(false)
        _menuFrag:setEnabled(true)
        _menuBag:selected()
        _menuFrag:unselected()
        _bgLayer:removeChildByTag(_fragLayerKey,true)
        expandBtn:setVisible(true)
        sellBtn:setVisible(true)
        interBagLayer()
    elseif tag == _ksTagFrag then
        _menuBag:setEnabled(true)
        _menuFrag:setEnabled(false)
        _menuBag:unselected()
        _menuFrag:selected()
        _bgLayer:removeChildByTag(_bagLayerKey,true)
        expandBtn:setVisible(false)
        sellBtn:setVisible(false)
        interFragLayer()
    end
end

--[[
    @des    :扩充后刷新UI
    @param  :
    @return :
--]]
function refreshUI()
    if( tolua.cast(_bgLayer,"CCLayer") == nil )then 
        return
    end
    _goldLabel:setString(tostring(UserModel.getGoldNumber()))
    ratio:setString(tostring(PetData.getPetNum()) .. "/" .. tostring(PetData.getOpenBagNum()))
end

-- 卖出的回调函数
local function sellFunCb( )
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/ui/pet/SellPetLayer"
    local sellPetLayer= SellPetLayer.createLayer()
    MainScene.changeLayer(sellPetLayer, "sellPetLayer")
end

local function expandFunction()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
 
    require "script/ui/bag/BagUtil"
    require "script/ui/bag/BagEnlargeDialog"
    BagEnlargeDialog.showLayer(BagUtil.PET_TYPE, refreshUI)
end

local function returnFunction()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    require "script/ui/pet/PetMainLayer"
    local layer = PetMainLayer.createLayer()
    MainScene.changeLayer(layer,"PetMainLayer")
    -- _bgLayer:removeFromParentAndCleanup(true)
    -- _bgLayer=nil
end

--创建背包碎片按钮
local function createMenuSp()
    local tArgs = {}
    tArgs[1] = {text=GetLocalizeStringBy("key_2527"), x=-8, tag=_ksTagBag, handler=changeViewLayer}
    tArgs[2] = {text=GetLocalizeStringBy("key_1801"), x=169, tag=_ksTagFrag, handler=changeViewLayer}

    require "script/libs/LuaCCSprite"
    local topMenuBar = LuaCCSprite.createTitleBar(tArgs)
    topMenuBar:setAnchorPoint(ccp(0, 1))
    topMenuBar:setPosition(0, _layerSize.height-70*MainScene.elementScale)
    topMenuBar:setScale(g_fScaleX)
    _bgLayer:addChild(topMenuBar)

    local topBottomMenu = tolua.cast(topMenuBar:getChildByTag(10001), "CCMenu")
    topBottomMenu:setTouchPriority(-500)
    _menuBag = tolua.cast(topBottomMenu:getChildByTag(_ksTagBag), "CCMenuItem")
    _menuFrag = tolua.cast(topBottomMenu:getChildByTag(_ksTagFrag), "CCMenuItem")

    local isShow,fragNum = PetData.isShowTip()
    fragMentNum = fragNum
    if isShow then
        alertSprite = CCSprite:create("images/common/tip_2.png")
        alertSprite:setAnchorPoint(ccp(1,1))
        alertSprite:setPosition(ccp(_menuFrag:getContentSize().width-5,_menuFrag:getContentSize().height))
        _menuFrag:addChild(alertSprite,1,1998)

        alertNum = CCLabelTTF:create(tostring(fragNum),g_sFontName, 21)
        alertNum:setAnchorPoint(ccp(0.5,0.5))
        alertNum:setPosition(ccp(alertSprite:getContentSize().width/2,alertSprite:getContentSize().height/2))
        alertSprite:addChild(alertNum)
    end

    _menuBag:setEnabled(false)
    _menuBag:selected()

    local otherMenu = CCMenu:create()
    otherMenu:setAnchorPoint(ccp(0,0))
    otherMenu:setPosition(ccp(0,0))
    topMenuBar:addChild(otherMenu)

    -- 宠物卖出按钮
    sellBtn= CCMenuItemImage:create("images/common/btn/btn_sale_n.png","images/common/btn/btn_sale_h.png")
    sellBtn:setAnchorPoint(ccp(0.5,0))
    sellBtn:setPosition(ccp(405,15))
    sellBtn:registerScriptTapHandler(sellFunCb)
    otherMenu:addChild(sellBtn)

    -- 
    expandBtn = CCMenuItemImage:create("images/common/btn/btn_expand_n.png","images/common/btn/btn_expand_h.png")
    expandBtn:setAnchorPoint(ccp(0.5,0))
    expandBtn:setPosition(ccp(500,15))
    expandBtn:registerScriptTapHandler(expandFunction)
    otherMenu:addChild(expandBtn)

    local returnBtn = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
    returnBtn:setAnchorPoint(ccp(0.5,0))
    returnBtn:setPosition(ccp(591,15))
    returnBtn:registerScriptTapHandler(returnFunction)
    otherMenu:addChild(returnBtn)

    --为了创建TableView准备的数据
    nHeightOfBottom = (menuLayerSize.height)*g_fScaleX
    local nHeightOfTitle = (topMenuBar:getContentSize().height)*g_fScaleX
    _scrollview_height = g_winSize.height - 70*MainScene.elementScale - nHeightOfBottom - nHeightOfTitle

    --默认为背包界面
    interBagLayer()
end

function createLayer()
	
    init()

    _bgLayer= CCLayer:create()

    --_bgLayer:registerScriptHandler(onNodeEvent)

    local bg = CCSprite:create("images/main/module_bg.png")
    bg:setScale(g_fBgScaleRatio)
    _bgLayer:addChild(bg)

    local bulletinLayerSize = BulletinLayer.getLayerContentSize()
    menuLayerSize = MenuLayer.getLayerContentSize()
    
    MainScene.getAvatarLayerObj():setVisible(false)
    MenuLayer.getObject():setVisible(true)
    BulletinLayer.getLayer():setVisible(true)

    _layerSize = _bgLayer:getContentSize()

    createMenuSp()
    createTopUI()
    
    return _bgLayer
end

function refreshFragView()
    _bgLayer:removeChildByTag(_fragLayerKey,true)
    interFragLayer()
end

function minusRed()
    fragMentNum = fragMentNum-1
    alertNum:setString(tostring(fragMentNum))
    if fragMentNum == 0 then
        alertSprite:setVisible(false)
    end
end
