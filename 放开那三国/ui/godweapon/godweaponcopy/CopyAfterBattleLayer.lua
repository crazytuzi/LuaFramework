-- FileName: CopyAfterBattleLayer.lua
-- Author: LLP
-- Date: 14-12-18
-- Purpose: 神兵副本计算面板


module("CopyAfterBattleLayer", package.seeall)
require "script/model/user/UserModel"
require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"
require "script/ui/hero/HeroPublicLua"
require "script/ui/hero/HeroPublicCC"
require "script/audio/AudioUtil"
require "script/ui/login/LoginScene"
require "script/ui/guild/GuildDataCache"
require "script/ui/godweapon/godweaponcopy/GodWeaponCopyMainLayer"

local IMG_PATH = "images/battle/report/"                -- 图片主路径

local mainLayer 				= nil
local menu 						= nil
local backAnimSprite 			= nil
local animSprite 				= nil
local winSize 					= nil
local bg_sprite					= nil
-- 回调函数
local afterOKCallFun 			= nil
-- 三个按钮
local userFormationItem 		= nil
local replayItem 				= nil
local okItem 					= nil
local userFormationItem_font 	= nil
local replayItem_font 			= nil
local okItem_font 				= nil
local _allData 					= nil
local flop_bg 					= nil
local _isReplay                 = nil
local _attackInfo               = nil
local _levelLimit               = 0
local isWin                     = nil
local _copyInfo                 = nil
-- 初始化
function init( ... )
    mainLayer 					= nil
    menu 						= nil
    backAnimSprite 				= nil
    backAnimSprite2             = nil
    animSprite 					= nil
    winSize 					= nil
    bg_sprite 					= nil
    -- 回调函数
    afterOKCallFun 				= nil
    -- 三个按钮
    userFormationItem 			= nil
    replayItem 					= nil
    okItem 						= nil
    userFormationItem_font 		= nil
    replayItem_font 			= nil
    okItem_font 				= nil
    _allData 					= nil
    flop_bg 					= nil
    _isReplay                   = nil
    _attackInfo                 = nil
    _levelLimit                 = 0
    isWin                       = nil
    _copyInfo                   = GodWeaponCopyData.getCopyInfo()
end
-- touch事件处理
local function cardLayerTouch(eventType, x, y)

    return true

end

function commitClick()
    --print("==========commitClick===============")
    if(animSprite~=nil)then
        animSprite:removeFromParentAndCleanup(true)
    end

    if(backAnimSprite~=nil)then
        backAnimSprite:removeFromParentAndCleanup(true)
    end

    if(backAnimSprite2~=nil)then
        backAnimSprite2:removeFromParentAndCleanup(true)
    end
    animSprite = nil
    backAnimSprite = nil
    backAnimSprite2 = nil
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    if(mainLayer~=nil)then
        mainLayer:removeFromParentAndCleanup(true)
        mainLayer = nil
    end
    require "script/battle/BattleLayer"
    BattleLayer.closeLayer()

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

-- 创建挑战结算面板
-- flopData:掉落数据
-- CallFun: 自定义确定按钮后回调
function createAfterBattleLayer( p_info,tAllData, p_HardLv, CallFun )
    -- 初始化
    init()

    -- 所有数据
    _levelLimit = p_HardLv
    _allData = tAllData
    _attackInfo = p_info
    -- 点击确定按钮传入回调
    afterOKCallFun = CallFun
    winSize = CCDirector:sharedDirector():getWinSize()
    mainLayer = CCLayerColor:create(ccc4(11,11,11,200))
    mainLayer:setTouchEnabled(true)
    mainLayer:registerScriptTouchHandler(cardLayerTouch,false,-490,true)

    local dbData = DB_Overcome.getDataById(tonumber(_copyInfo.cur_base))

    local str = dbData.gradeCount
    local tab = string.split(str,",")
    local itemStar = {}
    local starCount = 0
    for i=1,table.count(tab) do
        itemStar = string.split(tab[i],"|")
        if(_attackInfo["hpGrade"]~=nil and tonumber(_attackInfo["hpGrade"])==tonumber(itemStar[1]))then
            starCount = i
            break
        end
    end

    -- 战斗胜负判断
    isWin = nil
    local appraisal = _attackInfo.appraisal
    -- 战斗胜负判断 appraisal true是玩家这方赢了
    if( appraisal ~= "E" and appraisal ~= "F" )then
        isWin = true
        -- 创建胜利背景框
        bg_sprite = BaseUI.createViewBg(CCSizeMake(520,425))
        bg_sprite:setAnchorPoint(ccp(0.5,0.5))
        bg_sprite:setPosition(ccp(winSize.width/2,winSize.height*0.40))
        mainLayer:addChild(bg_sprite)
    else
        isWin = false
        -- 创建失败背景框
        bg_sprite = BaseUI.createViewBg(CCSizeMake(520,588))
        bg_sprite:setAnchorPoint(ccp(0.5,0.5))
        bg_sprite:setPosition(ccp(winSize.width/2,winSize.height*0.40))
        mainLayer:addChild(bg_sprite)
    end

    -- 三个按钮
    menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-1510)
    bg_sprite:addChild(menu)

    -- 确定
    okItem = createButtonItem()
    okItem:setAnchorPoint(ccp(0.5,0.5))
    okItem:registerScriptTapHandler(okItemFun)
    menu:addChild(okItem)
    -- 字体
    okItem_font = CCRenderLabel:create( GetLocalizeStringBy("key_1985") , g_sFontPangWa, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    okItem_font:setAnchorPoint(ccp(0.5,0.5))
    okItem_font:setPosition(ccp(okItem:getContentSize().width*0.5,okItem:getContentSize().height*0.5))
    okItem:addChild(okItem_font)
    okItem_font:setColor(ccc3(0xfe, 0xdb, 0x1c))

    if(isWin) then
        -- 创建中间ui
        local shLevelBg = CCSprite:create("images/copy/stronghold/starbg.png")
        shLevelBg:setAnchorPoint(ccp(0.5,0.5))
        shLevelBg:setPosition(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height*0.8)
        bg_sprite:addChild(shLevelBg)

        for ln=1,starCount do
            local starFile = "star.png"
            local shStar = CCSprite:create(IMG_PATH .. starFile)
            shStar:setAnchorPoint(ccp(0.5,0.5))
            shStar:setPosition(shLevelBg:getContentSize().width*(1/(starCount+1))*ln,shLevelBg:getContentSize().height*0.5)
            shLevelBg:addChild(shStar)
        end

        local desLabel = CCRenderLabel:create( GetLocalizeStringBy("llp_133"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        shLevelBg:addChild(desLabel)
        desLabel:setAnchorPoint(ccp(0.5,0.5))
        desLabel:setPosition(ccp(shLevelBg:getContentSize().width*0.5,-desLabel:getContentSize().height+10))
        -- 说明
        local fullRect = CCRectMake(0,0,187,30)
        local insetRect = CCRectMake(84,10,12,8)
        local descSprite = CCScale9Sprite:create("images/godweaponcopy/redbg.png", fullRect, insetRect)
        descSprite:setPreferredSize(CCSizeMake(420, 100))
        descSprite:setAnchorPoint(ccp(0.5, 0))
        descSprite:setPosition(ccp(bg_sprite:getContentSize().width * 0.5, bg_sprite:getContentSize().height*0.5-30))
        bg_sprite:addChild(descSprite)

        local dbData = DB_Overcome.getDataById(tonumber(_copyInfo.cur_base))
        local strPoint = dbData.baseReward
        local tabPoint = string.split(strPoint,",")
        local itemPoint = {}
        itemPoint = string.split(tabPoint[_levelLimit],"|")
        --上头红底内容
        if(starCount~=0)then
            for ln=1,starCount do
                local starFile = "star.png"
                local shStar = CCSprite:create(IMG_PATH .. starFile)
                shStar:setAnchorPoint(ccp(0,0.5))
                shStar:setPosition(shStar:getContentSize().width*ln-shStar:getContentSize().width*0.5,descSprite:getContentSize().height*0.5)
                descSprite:addChild(shStar,1,ln)
            end
        end
        local starFile = "star.png"
        local shStar = CCSprite:create(IMG_PATH .. starFile)
        --X
        local xLabel = CCRenderLabel:create("X", g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        xLabel:setAnchorPoint(ccp(0,0.5))
        xLabel:setPosition(ccp(shStar:getContentSize().width*3-shStar:getContentSize().width*0.5+10+shStar:getContentSize().width,descSprite:getContentSize().height*0.5))
        descSprite:addChild(xLabel)
        --得星倍率
        local baseLabel = CCRenderLabel:create( GetLocalizeStringBy("key_10033"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        baseLabel:setColor(ccc3(0xff,0xf6,0x00))
        baseLabel:setAnchorPoint(ccp(0,0))
        baseLabel:setPosition(ccp(xLabel:getPositionX()+10+xLabel:getContentSize().width,descSprite:getContentSize().height*0.5))
        descSprite:addChild(baseLabel)

        --得星倍率数
        local dbData = DB_Overcome.getDataById(tonumber(_copyInfo.cur_base))
        print("_copyInfo.cur_base==".._copyInfo.cur_base)
        local str = dbData.baseReward
        local tab = string.split(str,",")
        local item = {}
        print("_levelLimit==".._levelLimit)
        item = string.split(tab[_levelLimit],"|")

        -- local buffArry = string.split(dbData.gradeCount, "|")
        print("23423423423423")
        print_t(item)
        print("23423423423423")
        local baseNumLabel = CCRenderLabel:create( tonumber(item[3]), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        baseNumLabel:setColor(ccc3(0xff,0xf6,0x00))
        baseNumLabel:setAnchorPoint(ccp(0.5,1))
        baseNumLabel:setPosition(ccp(xLabel:getPositionX()+10+baseLabel:getContentSize().width*0.5+xLabel:getContentSize().width,descSprite:getContentSize().height*0.5))
        descSprite:addChild(baseNumLabel)
        --=
        local equalLabel = CCRenderLabel:create( "=", g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        equalLabel:setAnchorPoint(ccp(0,0.5))
        equalLabel:setPosition(ccp(baseLabel:getPositionX()+20+baseLabel:getContentSize().width,descSprite:getContentSize().height*0.5))
        descSprite:addChild(equalLabel)

        --获得星数
        local getStarLabel = CCRenderLabel:create( GetLocalizeStringBy("key_10034"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        getStarLabel:setColor(ccc3(0x00,0xff,0x18))
        getStarLabel:setAnchorPoint(ccp(0,0))
        getStarLabel:setPosition(ccp(equalLabel:getPositionX()+10+equalLabel:getContentSize().width,descSprite:getContentSize().height*0.5))
        descSprite:addChild(getStarLabel)

        --获得星数值
        local hardLv = starCount
        local starNum = tonumber(item[3])
        local getStarNumLabel = CCRenderLabel:create( starNum*hardLv, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        getStarNumLabel:setColor(ccc3(0xff,0x00,0x00))
        getStarNumLabel:setAnchorPoint(ccp(0.5,1))
        getStarNumLabel:setPosition(ccp(getStarLabel:getPositionX()+getStarLabel:getContentSize().width*0.5,descSprite:getContentSize().height*0.5))
        descSprite:addChild(getStarNumLabel)
        --end 上头红底内容
        local fullRect_3 = CCRectMake(0,0,187,30)
        local insetRect_3 = CCRectMake(84,10,12,8)
        local descSprite_down = CCScale9Sprite:create("images/godweaponcopy/redbg.png", fullRect_3, insetRect_3)
        descSprite_down:setPreferredSize(CCSizeMake(420, 100))
        descSprite_down:setAnchorPoint(ccp(0.5, 1))
        descSprite_down:setPosition(ccp(bg_sprite:getContentSize().width * 0.5, descSprite:getPositionY()))
        bg_sprite:addChild(descSprite_down)

        --下头红底内容
        local starFile = "star.png"
        local shStar = CCSprite:create(IMG_PATH .. starFile)

        -- local dbData = DB_Overcome.getDataById(tonumber(_copyInfo.cur_base))

        --基础积分
        local basePointLabel = CCRenderLabel:create(GetLocalizeStringBy("key_10035"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        basePointLabel:setAnchorPoint(ccp(0.5,0))
        basePointLabel:setPosition(ccp(shStar:getContentSize().width*2,descSprite_down:getContentSize().height*0.5))
        descSprite_down:addChild(basePointLabel)
        --基础积分数值
        local basePointNumLabel = CCRenderLabel:create(itemPoint[2], g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        basePointNumLabel:setAnchorPoint(ccp(0.5,1))
        basePointNumLabel:setPosition(ccp(shStar:getContentSize().width*2,descSprite_down:getContentSize().height*0.5))
        descSprite_down:addChild(basePointNumLabel)
        --X
        local xPointLabel = CCRenderLabel:create("X", g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        xPointLabel:setAnchorPoint(ccp(0,0.5))
        xPointLabel:setPosition(ccp(shStar:getContentSize().width*3-shStar:getContentSize().width*0.5+10+shStar:getContentSize().width,descSprite_down:getContentSize().height*0.5))
        descSprite_down:addChild(xPointLabel)
        --积分倍率
        local basePointLabel = CCRenderLabel:create( GetLocalizeStringBy("key_10036"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        basePointLabel:setColor(ccc3(0xff,0xf6,0x00))
        basePointLabel:setAnchorPoint(ccp(0,0))
        basePointLabel:setPosition(ccp(xPointLabel:getPositionX()+10+xPointLabel:getContentSize().width,descSprite_down:getContentSize().height*0.5))
        descSprite_down:addChild(basePointLabel)

        --积分倍率数
        -- local dbData = DB_Overcome.getDataById(tonumber(_copyInfo.cur_base))

        -- local str = dbData.gradeCount
        -- local tab = string.split(str,",")
        -- local item = {}

        -- item = string.split(tab[_levelLimit],"|")

        -- local buffArry = string.split(dbData.gradeCount, "|")
        local baseNumPointLabel = CCRenderLabel:create( tonumber(itemStar[2])/10000, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        baseNumPointLabel:setColor(ccc3(0xff,0xf6,0x00))
        baseNumPointLabel:setAnchorPoint(ccp(0.5,1))
        baseNumPointLabel:setPosition(ccp(xPointLabel:getPositionX()+10+basePointLabel:getContentSize().width*0.5+xPointLabel:getContentSize().width,descSprite_down:getContentSize().height*0.5))
        descSprite_down:addChild(baseNumPointLabel)
        --=
        local equalPointLabel = CCRenderLabel:create( "=", g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        equalPointLabel:setAnchorPoint(ccp(0,0.5))
        equalPointLabel:setPosition(ccp(basePointLabel:getPositionX()+20+basePointLabel:getContentSize().width,descSprite_down:getContentSize().height*0.5))
        descSprite_down:addChild(equalPointLabel)

        --获得积分
        local getStarPointLabel = CCRenderLabel:create( GetLocalizeStringBy("key_10037"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        getStarPointLabel:setColor(ccc3(0x00,0xff,0x18))
        getStarPointLabel:setAnchorPoint(ccp(0,0))
        getStarPointLabel:setPosition(ccp(equalPointLabel:getPositionX()+10+equalPointLabel:getContentSize().width,descSprite_down:getContentSize().height*0.5))
        descSprite_down:addChild(getStarPointLabel)

        --获得积分数值
        local hardLv = tonumber(itemPoint[2])
        local starNum = tonumber(itemStar[2])/10000
        local total = math.floor(starNum*hardLv)
        local getStarNumPointLabel = CCRenderLabel:create( total, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        getStarNumPointLabel:setColor(ccc3(0xff,0x00,0x00))
        getStarNumPointLabel:setAnchorPoint(ccp(0.5,1))
        getStarNumPointLabel:setPosition(ccp(getStarPointLabel:getPositionX()+getStarPointLabel:getContentSize().width*0.5,descSprite_down:getContentSize().height*0.5))
        descSprite_down:addChild(getStarNumPointLabel)
        --end 下透红底内容


        -- 敌方姓名的颜色
        local enemyNameStr = tAllData["team2"].name
        local name_color,stroke_color = getHeroNameColor( 1 )
        local enemyName_font = CCRenderLabel:create( enemyNameStr, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        enemyName_font:setColor(name_color)
        enemyName_font:setAnchorPoint(ccp(0.5,0.5))
        enemyName_font:setPosition(ccp(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-50))
        bg_sprite:addChild(enemyName_font)
        -- enemyName_font:setScale(enemyName_font:getScaleX()*-1)

        -- 确定位置
        okItem:setPosition(ccp(bg_sprite:getContentSize().width*0.5,57-5))

        -- 胜利特效
        backAnimSprite2 = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli03"), -1,CCString:create(""));
        backAnimSprite2:setAnchorPoint(ccp(0.5, 0.5))
        backAnimSprite2:setPosition(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height)
        bg_sprite:addChild(backAnimSprite2,-1)
        backAnimSprite2:setVisible(false)

        local function showBg2()
            backAnimSprite2:setVisible(true)
        end

        local layerActionArray = CCArray:create()
        layerActionArray:addObject(CCDelayTime:create(0.1))
        layerActionArray:addObject(CCCallFunc:create(showBg2))
        backAnimSprite2:runAction(CCSequence:create(layerActionArray))

        backAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli02"), -1,CCString:create(""));

        backAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
        backAnimSprite:setPosition(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-10)
        bg_sprite:addChild(backAnimSprite,0)

        animSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli01"), -1,CCString:create(""))
    else
        -- 确定位置
        okItem:setPosition(ccp(bg_sprite:getContentSize().width*0.5,57))

        -- -- 创建中间ui

        local middle_bg = BaseUI.createContentBg(CCSizeMake(463,414))
        middle_bg:setAnchorPoint(ccp(0.5,1))
        middle_bg:setPosition(ccp(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-60))
        bg_sprite:addChild(middle_bg)

        local str1 = GetLocalizeStringBy("key_3053")
        local text1 = CCRenderLabel:create( str1 , g_sFontPangWa, 26, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        text1:setColor(ccc3(0xff, 0xff, 0xff))
        text1:setPosition(ccp(45,middle_bg:getContentSize().height-20))
        middle_bg:addChild(text1)
        local str2 = GetLocalizeStringBy("key_1175")
        local text2 = CCRenderLabel:create( str2 , g_sFontPangWa, 26, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        text2:setColor(ccc3(0xff, 0xff, 0xff))
        text2:setPosition(ccp(10,middle_bg:getContentSize().height-66))
        middle_bg:addChild(text2)

        -- 四个按钮
        local middle_menu = CCMenu:create()
        middle_menu:setPosition(ccp(0,0))
        middle_menu:setTouchPriority(-509)
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
        train_star_item:setAnchorPoint(ccp(0.5,0.5))
        train_star_item:setPosition(ccp(123,58))
        middle_menu:addChild(train_star_item)
        train_star_item:registerScriptTapHandler(trainStarFun)
        -- -- 喂养宠物
        -- local feed_pet_item = CCMenuItemImage:create("images/common/feed_pet_n.png","images/common/feed_pet_h.png")
        -- feed_pet_item:setAnchorPoint(ccp(0.5,0.5))
        -- feed_pet_item:setPosition(ccp(337,58))
        -- middle_menu:addChild(feed_pet_item)
        -- feed_pet_item:registerScriptTapHandler(feedPetFun)

          -- 升级战魂 added by zhz
        local fight_soul_item = CCMenuItemImage:create("images/common/up_fightsoul_n.png","images/common/up_fightsoul_h.png")
        fight_soul_item:setAnchorPoint(ccp(0.5,0.5))
        fight_soul_item:setPosition(ccp(337,56))
        middle_menu:addChild(fight_soul_item)
        fight_soul_item:registerScriptTapHandler(fightSoulFun)

        animSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushibai"), -1,CCString:create(""))
    end

    animSprite:setAnchorPoint(ccp(0.5, 0.5));
    animSprite:setPosition(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-20)
    bg_sprite:addChild(animSprite)

    delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    animSprite:setDelegate(delegate)

    -- 适配
    setAdaptNode(bg_sprite)



    -- 为保持数据一致 已创建就开始加数值
    bg_sprite:registerScriptHandler(function ( eventType,node )
        if(eventType == "enter") then
            -- 加奖励数据
            -- 胜利了

            LoginScene.setBattleStatus(false)
        end
        if(eventType == "exit") then
        end
    end)
    return mainLayer
end

-- 特效播放结束后回调
function animationEnd( ... )
    if(backAnimSprite~=nil)then
        backAnimSprite:cleanup()
    end
    if(animSprite~=nil)then
        animSprite:cleanup()
    end
end

function animationFrameChanged( ... )
    -- body
end

-- 按钮item
function createButtonItem()
    local normalSprite  = CCScale9Sprite:create("images/common/btn/btn_green_n.png")
    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn_green_h.png")
    local disabledSprite = CCScale9Sprite:create("images/common/btn/btn_hui.png")
    local item = CCMenuItemSprite:create(normalSprite,selectSprite,disabledSprite)
    return item
end

-- 确定回调
function okItemFun( tag, item_obj )
    -- 音效

    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    if(mainLayer~=nil)then
        mainLayer:removeFromParentAndCleanup(true)
        mainLayer = nil
    end

    if(isWin)then
        require "script/battle/BattleLayer"
        BattleLayer.closeLayer()
        -- GodWeaponCopyMainLayer.setStatus(2)
    else
        -- print("losetime===="..challengTime)
        -- local normalData = DB_Normal_config.getDataById(1)
        -- local lose_num = GodWeaponCopyData.getLoseTimes()
        -- local challengTime = tonumber(normalData.challengingTimes)-tonumber(lose_num)
        -- if(challengTime>0)then
        --     GodWeaponCopyData.setLoseTimes(tonumber(challengTime)+1)
        -- else
        --     GodWeaponCopyData.setLoseTimes(0)
        -- end

        require "script/battle/BattleLayer"
        BattleLayer.closeLayer()
    end
    -- 点确定后 调用回调
    if(afterOKCallFun ~= nil)then
        afterOKCallFun(isWin)
    end
end

-- 玩家名字的颜色
function getHeroNameColor( utid )
    local name_color = nil
    local stroke_color = nil
    if(tonumber(utid) == 1)then
        -- 女性玩家
        name_color = ccc3(0xf9,0x59,0xff)
        stroke_color = ccc3(0x00,0x00,0x00)
    elseif(tonumber(utid) == 2)then
        -- 男性玩家
        name_color = ccc3(0x00,0xe4,0xff)
        stroke_color = ccc3(0x00,0x00,0x00)
    end
    return name_color, stroke_color
end