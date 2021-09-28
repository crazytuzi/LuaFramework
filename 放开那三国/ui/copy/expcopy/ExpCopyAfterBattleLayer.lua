-- Filename: ExpCopyAfterBattleLayer.lua
-- Author: lichenyang
-- Date: 2015-04-07
-- Purpose: 主角经验副本战斗结算面板

require "script/utils/extern"
require "script/libs/LuaCCLabel"
module("ExpCopyAfterBattleLayer", package.seeall)


local _bgLayer = nil
local _touchPriority = nil
local _bgSprite = nil
local _copyTitle = nil
local _fightSp = nil
local _powerDescLabel = nil
local _itemArray = nil
function init( ... )
    _bgLayer = nil
    _touchPriority = nil
    _bgSprite = nil
    _copyTitle = nil
    _fightSp = nil
    _powerDescLabel = nil
    _itemArray = nil
end

function createLayer(p_itemArray, p_appraisal, p_touchPriority)
    
    init()
    _touchPriority = p_touchPriority or -888
    _bgLayer = BaseUI.createMaskLayer(_touchPriority)
    _itemArray = p_itemArray or {}

    local m_layerSize = CCSizeMake(520,500)
    local scale = MainScene.elementScale
    local standSize = CCSizeMake(640, 960)
    local winSize = CCDirector:sharedDirector():getWinSize()

    _bgSprite = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/battle/report/bg.png")
    _bgSprite:setContentSize(m_layerSize)
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccps(0.5, 0.42))
    _bgLayer:addChild(_bgSprite,5)
    _bgSprite:setScale(MainScene.elementScale)

    _copyTitle = CCRenderLabel:create(GetLocalizeStringBy("key_10022"), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _copyTitle:setAnchorPoint(ccp(0.5, 0.5))
    _copyTitle:setPosition(ccpsprite(0.5, 0.90, _bgSprite))
    _copyTitle:setColor(ccc3(252, 232, 3))
    _bgSprite:addChild(_copyTitle)

    _fightSp = CCSprite:create("images/common/cur_fight.png")
    _fightSp:setAnchorPoint(ccp(0.5,0.5))
    _fightSp:setPosition(ccp(m_layerSize.width*0.4,m_layerSize.height*0.83))
    _bgSprite:addChild(_fightSp)
    
    _powerDescLabel = CCRenderLabel:create(UserModel.getFightForceValue() , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _powerDescLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    _powerDescLabel:setAnchorPoint(ccp(0,0.5))
    _powerDescLabel:setPosition(_fightSp:getPositionX()+_fightSp:getContentSize().width/2+10,_fightSp:getPositionY())
    _bgSprite:addChild(_powerDescLabel)

    if string.byte(p_appraisal) == string.byte('E') or string.byte(p_appraisal) == string.byte('F') then
        createFailInfo()
    else
        createWinInfo()
    end


    commitButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200,73),GetLocalizeStringBy("key_1061"),ccc3(255,222,0))
    commitButton:setAnchorPoint(ccp(0.5,0.5))
    if(Platform.getOS() == "wp")then
        commitButton:setPosition(ccp(m_layerSize.width*0.5,m_layerSize.height*0.1))
    else
        commitButton:setPosition(ccp(m_layerSize.width*0.7,m_layerSize.height*0.1))
    end
    
    commitButton:registerScriptTapHandler(commitClick)

    shareButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200,73),GetLocalizeStringBy("key_2391"),ccc3(255,222,0))
    shareButton:setAnchorPoint(ccp(0.5,0.5))
    shareButton:setPosition(ccp(m_layerSize.width*0.3,m_layerSize.height*0.1))
    shareButton:registerScriptTapHandler(shareClick)
    
    if(m_isWin==true and tonumber(m_expNumber)>0) then
        commitButton:setEnabled(false)
        --commitButton:setColor(ccc3(111,111,111))
        if(Platform.getOS() ~= "wp")then
            shareButton:setEnabled(false)
        end
    end
    commitButton:setCascadeColorEnabled(true)

    local menu = CCMenu:create()
    menu:setAnchorPoint(ccp(0,0))
    menu:setPosition(0,0)
    menu:addChild(commitButton)
    if(Platform.getOS() ~= "wp")then
        menu:addChild(shareButton)
    end
    
    _bgSprite:addChild(menu)
    menu:setTouchPriority(_touchPriority-505)

    return _bgLayer
end

function createWinInfo( ... )

    local m_layerSize = CCSizeMake(520,500)
    local scale = MainScene.elementScale
    local standSize = CCSizeMake(640, 960)
    local winSize = CCDirector:sharedDirector():getWinSize()

    _bgSprite:setContentSize(m_layerSize)
    backAnimSprite = XMLSprite:create("images/battle/xml/report/zhandoushengli02")    
    backAnimSprite:setPosition(ccpsprite(0.46, 0.9, _bgSprite))
    backAnimSprite:setReplayTimes(1, false)
    _bgSprite:addChild(backAnimSprite,-1)
    
    local showBg2 = function()
        local backAnimSprite2 = XMLSprite:create("images/battle/xml/report/zhandoushengli03")        
        backAnimSprite2:setAnchorPoint(ccp(0.5, 0.5))
        backAnimSprite2:setPosition(ccpsprite(0.5, 0.9, _bgSprite))
        _bgSprite:addChild(backAnimSprite2,-2)
    end

    local layerActionArray = CCArray:create()
    layerActionArray:addObject(CCDelayTime:create(1.5))
    layerActionArray:addObject(CCCallFunc:create(showBg2))
    backAnimSprite:runAction(CCSequence:create(layerActionArray))
    
    animSprite = XMLSprite:create("images/battle/xml/report/zhandoushengli01")
    animSprite:setAnchorPoint(ccp(0.5, 0.5));
    animSprite:setPosition(ccpsprite(0.5, 0.95, _bgSprite));
    animSprite:setReplayTimes(1, false)
    _bgSprite:addChild(animSprite, 5)

    if(file_exists("audio/effect/zhandoushengli.mp3")) then
        AudioUtil.playEffect("audio/effect/zhandoushengli.mp3")
    end

    local m_itemBg = CCScale9Sprite:create(CCRectMake(20, 20, 10, 10),"images/common/bg/9s_1.png")
    m_itemBg:setContentSize(CCSizeMake(m_layerSize.width-50,270))
    m_itemBg:setAnchorPoint(ccp(0,0))
    m_itemBg:setPosition(25,100)
    _bgSprite:addChild(m_itemBg)

    local labelbg = CCScale9Sprite:create(CCRectMake(25, 15, 20, 10),"images/common/astro_labelbg.png")
    labelbg:setPreferredSize(CCSizeMake(m_layerSize.width*0.4,35))
    labelbg:setAnchorPoint(ccp(0.5,0.5))
    labelbg:setPosition(m_itemBg:getContentSize().width*0.5,m_itemBg:getContentSize().height*1)
    m_itemBg:addChild(labelbg)

    local itemBgTitle = CCLabelTTF:create(GetLocalizeStringBy("key_2882"),g_sFontName,24)
    itemBgTitle:setAnchorPoint(ccp(0.5,0.5))
    itemBgTitle:setPosition(m_itemBg:getContentSize().width*0.5,m_itemBg:getContentSize().height*1)
    itemBgTitle:setColor(ccc3(0xff,0xf6,0x00))
    m_itemBg:addChild(itemBgTitle)

    local scrollView = CCScrollView:create()
    scrollView:setTouchPriority(-504)
    scrollView:setContentSize(CCSizeMake(520,240))
    scrollView:setViewSize(CCSizeMake(520,240))
    -- 设置弹性属性
    scrollView:setBounceable(true)
    -- 垂直方向滑动
    scrollView:setDirection(kCCScrollViewDirectionVertical)
    scrollView:setAnchorPoint(ccp(0,0))
    scrollView:setPosition(ccp(m_itemBg:getContentSize().width*0.05,m_itemBg:getContentSize().height*0.05))
    m_itemBg:addChild(scrollView)
    

    local itemArray = {}
    if(_itemArray~=nil and #_itemArray>0) then
        for i=1,#_itemArray do
            itemArray[#itemArray+1] = _itemArray[i]
        end
    end
    
    local rewardCount = #itemArray
    
    local columnNumber = 3
    
    local startX = m_itemBg:getContentSize().width*0.2-scrollView:getPositionX()
    local startY = m_itemBg:getContentSize().height*0.75-scrollView:getPositionY()
    
    local intervalX = m_itemBg:getContentSize().width*0.3
    local intervalY = m_itemBg:getContentSize().height*0.43

    if(math.ceil(rewardCount/columnNumber)>2)then
        startY = startY + (math.ceil(rewardCount/columnNumber)-2)*intervalY
    end

    local rewardLayer = CCLayer:create()
    rewardLayer:setContentSize(CCSizeMake(520,startY+intervalY*0.4))
    rewardLayer:setAnchorPoint(ccp(0,0))
    
    local rewardLayerY = rewardLayer:getContentSize().height>scrollView:getContentSize().height and -rewardLayer:getContentSize().height+scrollView:getContentSize().height or 0
    rewardLayer:setPosition(0,rewardLayerY)
    scrollView:setContainer(rewardLayer)
    
    require "script/ui/item/ItemSprite"
    require "script/ui/item/ItemUtil"
    for i=1,#itemArray do
        local item = ItemSprite.getItemSpriteById(tonumber(itemArray[i].item_template_id))
        item:setAnchorPoint(ccp(0.5,0.5))
        item:setPosition(startX+intervalX*math.floor((i-1)%columnNumber),startY-intervalY*math.floor((i-1)/columnNumber))
        rewardLayer:addChild(item)

        local dbItem = ItemUtil.getItemById(tonumber(itemArray[i].item_template_id))
        if(dbItem~=nil and dbItem.name~=nil)then
            local itemNameLabel = CCRenderLabel:create(dbItem.name, g_sFontName, 18, 1, ccc3( 0x10, 0x10, 0x10), type_stroke)
            itemNameLabel:setColor(ccc3( 0xff, 0xf6, 0x00))
            itemNameLabel:setAnchorPoint(ccp(0.5,0.5))
            itemNameLabel:setPosition(item:getContentSize().width*0.5,-item:getContentSize().height*0.15)
            item:addChild(itemNameLabel)
        end
        
        --数量
        local itemNumber = nil
        if(itemArray[i].item_num==nil or tonumber(itemArray[i].item_num)==nil)then
            itemNumber = ""
        else
            itemNumber = tonumber(itemArray[i].item_num)
        end
        local itemNumberLabel = CCRenderLabel:create( itemNumber .. "", g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        itemNumberLabel:setColor(ccc3( 0x66, 0xff, 0x66))
        itemNumberLabel:setAnchorPoint(ccp(1,0))
        itemNumberLabel:setPosition(item:getContentSize().width*0.92,item:getContentSize().height*0.05)
        item:addChild(itemNumberLabel)
    end
end

function createFailInfo( ... )

    local m_layerSize = CCSizeMake(520,720)
    local scale = MainScene.elementScale
    local standSize = CCSizeMake(640, 960)
    local winSize = CCDirector:sharedDirector():getWinSize()
    _bgSprite:setContentSize(m_layerSize)

    animSprite = XMLSprite:create("images/battle/xml/report/zhandoushibai")
    animSprite:setAnchorPoint(ccp(0.5, 0.5));
    animSprite:setPosition(ccpsprite(0.5, 0.95, _bgSprite));
    animSprite:setReplayTimes(1, false)
    _bgSprite:addChild(animSprite, 5)

    AudioUtil.playEffect("audio/effect/zhandoushibai.mp3")

    _copyTitle:setPosition(ccpsprite(0.5, 0.90, _bgSprite))
    _fightSp:setPosition(ccp(m_layerSize.width*0.4,m_layerSize.height*0.83))
    _powerDescLabel:setPosition(_fightSp:getPositionX()+_fightSp:getContentSize().width/2+10,_fightSp:getPositionY())


    local middle_bg = CCScale9Sprite:create(CCRectMake(20, 20, 10, 10),"images/common/bg/bg_ng_attr.png")
    middle_bg:setContentSize(CCSizeMake(m_layerSize.width-50,450))
    middle_bg:setAnchorPoint(ccp(0.5,1))
    middle_bg:setPosition(ccp(_bgSprite:getContentSize().width*0.5,_bgSprite:getContentSize().height-150))
    _bgSprite:addChild(middle_bg)
    
    local str1 = GetLocalizeStringBy("key_3053")
    local text1 = CCRenderLabel:create( str1 , g_sFontPangWa, 26, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    text1:setColor(ccc3(0xff, 0xff, 0xff))
    text1:setPosition(ccp(45,middle_bg:getContentSize().height-10))
    middle_bg:addChild(text1)
    
    local str2 = GetLocalizeStringBy("key_1175")
    local text2 = CCRenderLabel:create( str2 , g_sFontPangWa, 26, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    text2:setColor(ccc3(0xff, 0xff, 0xff))
    text2:setPosition(ccp(10,middle_bg:getContentSize().height-50))
    middle_bg:addChild(text2)
    
    local str3 = GetLocalizeStringBy("key_2265")
    local text3 = CCRenderLabel:create( str3 , g_sFontPangWa, 26, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    text3:setColor(ccc3(0xff, 0xff, 0xff))
    text3:setPosition(ccp(10,middle_bg:getContentSize().height-90))
    middle_bg:addChild(text3)
    -- 四个按钮
    local middle_menu = CCMenu:create()
    middle_menu:setPosition(ccp(0,0))
    middle_menu:setTouchPriority(-600)
    middle_bg:addChild(middle_menu)
    -- 武将强化
    local strengthen_hero_item = CCMenuItemImage:create("images/common/strengthen_hero_n.png","images/common/strengthen_hero_h.png")
    strengthen_hero_item:setAnchorPoint(ccp(0,0.5))
    strengthen_hero_item:setPosition(ccp(18,181))
    middle_menu:addChild(strengthen_hero_item)
    strengthen_hero_item:registerScriptTapHandler(strengthenHeroFun)

    -- 调整整容， changed by zhz。
    local formation_item= CCMenuItemImage:create("images/common/change_formation_n.png","images/common/change_formation_h.png")
    formation_item:setAnchorPoint(ccp(0.5,0.5))
    formation_item:setPosition(ccp(middle_bg:getContentSize().width/2 ,181))
    middle_menu:addChild(formation_item)
    formation_item:registerScriptTapHandler(formationFun)

    -- 装备强化
    local strengthen_arm_item = CCMenuItemImage:create("images/common/strengthen_arm_n.png","images/common/strengthen_arm_h.png")
    strengthen_arm_item:setAnchorPoint(ccp(0.5,0.5))
    strengthen_arm_item:setPosition(ccp(387,181))
    middle_menu:addChild(strengthen_arm_item)
    strengthen_arm_item:registerScriptTapHandler(strengthenArmFun)
    -- 培养名将
    local train_star_item = CCMenuItemImage:create("images/common/train_star_n.png","images/common/train_star_h.png")
    train_star_item:setAnchorPoint(ccp(0,0.5))
    train_star_item:setPosition(ccp(18,58))
    middle_menu:addChild(train_star_item)
    train_star_item:registerScriptTapHandler(trainStarFun)
end

-- 武将强化回调
function strengthenHeroFun()
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2409"))
    -- 先关闭战斗场景
    commitClick()
    
    if not DataCache.getSwitchNodeState(ksSwitchGeneralForge) then
        return
    end
    require "script/ui/hero/HeroLayer"
    MainScene.changeLayer(HeroLayer.createLayer(), "HeroLayer")
    AudioUtil.playBgm("audio/main.mp3")
end

-- 装备强化回调
function strengthenArmFun()
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_1244"))
    -- 先关闭战斗场景
    commitClick()
    
    if not DataCache.getSwitchNodeState(ksSwitchWeaponForge) then
        return
    end
    require "script/ui/bag/BagLayer"
    local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_Arming)
    MainScene.changeLayer(bagLayer, "bagLayer")
    AudioUtil.playBgm("audio/main.mp3")
end

-- 培养名将回调
function trainStarFun()
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2827"))
    -- 先关闭战斗场景
    commitClick()
    
    if not DataCache.getSwitchNodeState(ksSwitchGreatSoldier) then
        return
    end
    require "script/ui/star/StarLayer"
    local starLayer = StarLayer.createLayer()
    MainScene.changeLayer(starLayer, "starLayer")
    AudioUtil.playBgm("audio/main.mp3")
end

-- 喂养宠物回调
function feedPetFun()
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2236"))
    -- 先关闭战斗场景
    commitClick()
    
     if not DataCache.getSwitchNodeState(ksSwitchPet) then
        return
    end
    require "script/ui/pet/PetMainLayer"
    local layer= PetMainLayer.createLayer()
    MainScene.changeLayer(layer, "PetMainLayer")
end

-- 跳到阵容的回调函数 , added by zhz
function formationFun(  )

    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2236"))
    -- 先关闭战斗场景
    commitClick()

    require("script/ui/formation/FormationLayer")
    local formationLayer = FormationLayer.createLayer()
    MainScene.changeLayer(formationLayer, "formationLayer")

end

-- 猎魂的回调函数 ，added by zhz
function fightSoulFun( )

    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2236"))
    -- 先关闭战斗场景
    commitClick()

    if not DataCache.getSwitchNodeState(ksSwitchBattleSoul) then
        return
    end
    require "script/ui/huntSoul/HuntSoulLayer"
    local layer = HuntSoulLayer.createHuntSoulLayer()
    MainScene.changeLayer(layer, "huntSoulLayer")
    
end


function commitClick()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
    
    require "script/battle/BattleLayer"
    BattleLayer.closeLayer()
end

function shareClick()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/utils/BaseUI"
    local shareImagePath = BaseUI.getScreenshots()
    require "script/ui/share/ShareLayer"
    ShareLayer.show(nil, shareImagePath,9999, -1000, shareCallBack)
end
