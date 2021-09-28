-- Filename：	ShieldWarLay.lua
-- Author：		zhz
-- Date：		2013-12-2
-- Purpose：		展示界面免战


module("ShieldWarLay", package.seeall)

require "script/ui/treasure/TreasureData"
require "script/audio/AudioUtil"
require "script/utils/BaseUI"
require "script/audio/AudioUtil"
require "script/ui/item/ItemUtil"
require "script/ui/treasure/TreasureService"

local _bgLayer					--  
local _freeWarBg				-- 背景

local _costGold                  -- 花费的金币
local _addFreeHour               -- 增加的时间
local _itemTable                  -- 得到免战消耗物品以及数量

local _ksTagGold = 2001
local _ksTagFreeWar= 2002

local function init(  )
	_bgLayer = nil
    _costGold= TreasureData.getGlodByShieldTime()
    _addFreeHour= TreasureData.getShieldTime()  
    _itemTable= TreasureData.getShieldItemInfo()
end


local function layerToucCb(eventType, x, y)
    return true
end

-- 弹出面板
function showLayer(  )
    init()
	_bgLayer= CCLayerColor:create(ccc4(11,11,11,166))  
    _bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(layerToucCb,false,-660,true)

	local scene = CCDirector:sharedDirector():getRunningScene()
 	scene:addChild(_bgLayer,999,2013)
 	createBg()
end

function createBg(  )
	local fullRect = CCRectMake(0, 0, 213, 171)
    local insetRect = CCRectMake(100, 80, 10, 20)

    local mySize = CCSizeMake(433,319)
    local myScale = MainScene.elementScale
   	_freeWarBg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    _freeWarBg:setContentSize(mySize)
    _freeWarBg:setScale(myScale)
    _freeWarBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    _freeWarBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(_freeWarBg)

    -- title  
    local titleBg= CCSprite:create("images/common/viewtitle1.png")
    titleBg:setPosition(ccp(_freeWarBg:getContentSize().width*0.5,_freeWarBg:getContentSize().height-6))
    titleBg:setAnchorPoint(ccp(0.5, 0.5))
    _freeWarBg:addChild(titleBg)

    --奖励的标题文本
    local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_2974"), g_sFontPangWa,33,1,ccc3(0x0,0x00,0x0),type_shadow)
    labelTitle:setSourceAndTargetColor(ccc3( 0xff, 0xf0, 0x49), ccc3( 0xff, 0xa2, 0x00));
    labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5+2 ))
    labelTitle:setAnchorPoint(ccp(0.5,0.5))
    titleBg:addChild(labelTitle)


     -- 关闭按钮
    local menu =CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-661)
    _freeWarBg:addChild(menu,1000)
    local cancelBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    cancelBtn:setAnchorPoint(ccp(1, 1))
    cancelBtn:setPosition(ccp(_freeWarBg:getContentSize().width+14, _freeWarBg:getContentSize().height+14))
    cancelBtn:registerScriptTapHandler(cancelBtnCallBack)
    menu:addChild(cancelBtn)


    local alertContent = {}
    alertContent[1] = CCRenderLabel:create(GetLocalizeStringBy("key_1771"), g_sFontName, 24,1,ccc3(0x00,0x00,0x00),type_stroke)
    alertContent[1]:setColor(ccc3(0xff,0xe4,0x00))
    alertContent[2]=CCSprite:create("images/treasure/free.png")
    alertContent[3]=CCRenderLabel:create(GetLocalizeStringBy("key_2890"), g_sFontName,24,1, ccc3(0x00,0x00,0x00), type_stroke)
    alertContent[3]:setColor(ccc3(0xff,0xe4,0x00))
    alertContent[4]=CCSprite:create("images/common/gold.png")

    print("costGold is : ",_costGold, "  and addFreeHour  is : ", _addFreeHour)

    alertContent[5]= CCRenderLabel:create("".. _costGold .. GetLocalizeStringBy("key_2974") .. "" .. _addFreeHour , g_sFontName,24,1, ccc3(0x00,0x00,0x00), type_stroke)
    -- alertContent[6]=CCRenderLabel:create(, g_sFontName,24,1, ccc3(0x00,0x00,0x00), type_stroke)
    alertContent[5]:setColor(ccc3(0xff,0xe4,0x00))

    local alertNode=BaseUI.createHorizontalNode(alertContent)
    alertNode:setPosition(ccp(_freeWarBg:getContentSize().width/2, 229))
    alertNode:setAnchorPoint(ccp(0.5,0))
    _freeWarBg:addChild(alertNode)

    -- 文本：“”
    local descLabel=CCRenderLabel:create(GetLocalizeStringBy("key_1655"), g_sFontName,20,1,ccc3(0,0,0), type_stroke)
    descLabel:setColor(ccc3(0x00,0xff,0x18))
    descLabel:setAnchorPoint(ccp(0.5,0))
    descLabel:setPosition(_freeWarBg:getContentSize().width/2, 42)
    _freeWarBg:addChild(descLabel)

    -- 创建显示免战牌和金币的Ui
    createItemUI()


end

-- 创建显示免战牌和金币的Ui
function createItemUI(  )

     -- 显示物品的灰色背景
    local itemInfoSpite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    itemInfoSpite:setContentSize(CCSizeMake(377,147))
    itemInfoSpite:setPosition(ccp(_freeWarBg:getContentSize().width/2,74))
    itemInfoSpite:setAnchorPoint(ccp(0.5,0))
    _freeWarBg:addChild(itemInfoSpite)

    local menuBar= CCMenu:create()
    menuBar:setTouchPriority(-661)
    menuBar:setPosition(0,0)
    itemInfoSpite:addChild(menuBar)

    --免战pai
    local freeWarItem = CCMenuItemImage:create("images/treasure/free_war_card/free_war_n.png", "images/treasure/free_war_card/free_war_h.png")
    freeWarItem:setPosition(ccp(itemInfoSpite:getContentSize().width*0.25, 60))
    freeWarItem:setAnchorPoint(ccp(0.5,0))
    freeWarItem:registerScriptTapHandler(menuAction)
    menuBar:addChild(freeWarItem,1, _ksTagFreeWar)


    local freeContent= {}
    freeContent[1] = CCRenderLabel:create(GetLocalizeStringBy("key_2794"), g_sFontName, 18,1, ccc3(0,0,0), type_stroke)
    freeContent[1]:setColor(ccc3(0xff,0xff,0xff))
    freeContent[2]= CCRenderLabel:create( _itemTable[1].num .. GetLocalizeStringBy("key_1527"), g_sFontName, 18, 1,ccc3(0,0,0), type_stroke)
    freeContent[2]:setColor(ccc3(0xff,0xe4,0x00))

    local freeNode = BaseUI.createHorizontalNode(freeContent)
    freeNode:setPosition(itemInfoSpite:getContentSize().width*0.25, 23)
    freeNode:setAnchorPoint(ccp(0.5,0))
    itemInfoSpite:addChild(freeNode)

    local itemInfo= ItemUtil.getCacheItemInfoBy(_itemTable[1].itemTid)
    local num=0
    print(" ========= ==== 239049440")
    print_t(itemInfo)
    if(itemInfo) then
       num= itemInfo.item_num
    end

    local numBg= CCSprite:create("images/common/tip_1.png")
    numBg:setPosition(freeWarItem:getContentSize().width*1.1, freeWarItem:getContentSize().height*1.1)
    numBg:setAnchorPoint(ccp(1,1))
    freeWarItem:addChild(numBg)

    local numLabel = CCLabelTTF:create(tostring(num) ,g_sFontName, 21)
    numLabel:setPosition(ccp(numBg:getContentSize().width*0.45,numBg:getContentSize().height*0.6))
    numLabel:setAnchorPoint(ccp(0.5,0.5))
    numBg:addChild(numLabel)


    -- 金币免战
    local goldItem = CCMenuItemImage:create("images/treasure/gold/gold_n.png", "images/treasure/gold/gold_h.png")
    goldItem:setPosition(ccp(itemInfoSpite:getContentSize().width*0.75, 60))
    goldItem:setAnchorPoint(ccp(0.5,0))
    goldItem:registerScriptTapHandler(menuAction)
    menuBar:addChild(goldItem,1, _ksTagGold)

    local goldContent= {}
    goldContent[1] = CCRenderLabel:create(GetLocalizeStringBy("key_2794"), g_sFontName, 18, 1,ccc3(0,0,0), type_stroke)
    goldContent[1]:setColor(ccc3(0xff,0xff,0xff))
    goldContent[2]= CCRenderLabel:create( _costGold ..GetLocalizeStringBy("key_1491"), g_sFontName, 18,1, ccc3(0,0,0), type_stroke)
    goldContent[2]:setColor(ccc3(0xff,0xe4,0x00))

    local goldNode = BaseUI.createHorizontalNode(goldContent)
    goldNode:setPosition(itemInfoSpite:getContentSize().width*0.75, 23)
    goldNode:setAnchorPoint(ccp(0.5,0))
    itemInfoSpite:addChild(goldNode)

end



----------------------------------  回调函数 ---------------------------------

function cancelBtnCallBack( tag,item )
    
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    if(_bgLayer ~= nil) then
        _bgLayer:removeFromParentAndCleanup(true)
        _bgLayer=nil
    end 
    TreasureMainView.updateLabel()
end

 --  $ freeType 1:金币免战 2:物品免战 
function menuAction( tag,item )
    if(_bgLayer ~= nil) then
        _bgLayer:removeFromParentAndCleanup(true)
        _bgLayer=nil
    end 

    local freeType =0
    if(tag== _ksTagFreeWar ) then
        print("== _ksTagFreeWar  ")
        freeType =2
        TreasureService.whiteFlag(freeType , cancelBtnCallBack)

    elseif(tag == _ksTagGold) then
        freeType =1
        print("== _ksTagFreeWar  ")
        TreasureService.whiteFlag(freeType , cancelBtnCallBack)
    end
end













