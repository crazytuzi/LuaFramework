-- FileName: AfterBattleLayer.lua 
-- Author: Li Cong 
-- Date: 13-10-8 
-- Purpose: function description of module  竞技场

require "script/utils/BaseUI"
module("AfterBattleLayer", package.seeall)
local mainLayer = nil     
local menu = nil
local backAnimSprite = nil
local animSprite = nil
local winSize = nil
local bg_sprite = nil
-- 回调函数
local afterOKCallFun = nil
-- 左中右文字
local left_bg = nil
local mid_bg = nil
local right_bg = nil
-- 翻牌按钮
local cardMenu = nil
-- 抢夺特效
local upLootAnimSprite = nil
local downLootAnimSprite = nil
local paiziSprite = nil
local yibi_data = nil
-- 抽中高亮特效
local lightAnimSprite = nil
-- 左中右物品背景
local left_item_bg = nil
local mid_item_bg = nil
local right_item_bg = nil
-- 掉落物品数据
local _flopData = nil
-- 三个按钮
local userFormationItem = nil
local replayItem = nil
local okItem = nil
local userFormationItem_font = nil
local replayItem_font = nil
local okItem_font = nil
-- 是否是npc
local isNpc = nil
local npc_name = nil

local _fightStr
local _battleInfo            = nil

-- 初始化
function init( ... )
    mainLayer = nil
    menu = nil
    backAnimSprite = nil
    animSprite = nil
    winSize = nil
    bg_sprite = nil
    -- 回调函数
    afterOKCallFun = nil
    -- 左中右文字
    left_bg = nil
    mid_bg = nil
    right_bg = nil
    -- 翻牌按钮
    cardMenu = nil
    -- 抢夺特效
    upLootAnimSprite = nil
    downLootAnimSprite = nil
    paiziSprite = nil
    yibi_data = nil
    -- 抽中高亮特效
    lightAnimSprite = nil
    -- 左中右物品背景
    left_item_bg = nil
    mid_item_bg = nil
    right_item_bg = nil
    -- 掉落物品数据
    _flopData = nil
    -- 三个按钮
    userFormationItem = nil
    replayItem = nil
    okItem = nil
    userFormationItem_font = nil
    replayItem_font = nil
    okItem_font = nil
    isNpc = nil
    npc_name = nil
    _battleInfo            = nil
end
-- touch事件处理
local function cardLayerTouch(eventType, x, y)
   
    return true
    
end

local function onNodeEvent(event)
    if (event == "enter") then
        PreRequest.setIsCanShowAchieveTip(false)
    elseif (event == "exit") then
        PreRequest.setIsCanShowAchieveTip(true)
    end
end

-- 创建挑战结算面板
-- appraisal:战斗评价
-- enemyUid:对方的uid
-- enemyFightData:敌方战斗力
-- silverData:获得银币数 没有可为nil
-- expData:获得将魂数 没有可为nil
-- flopData:掉落翻牌数据
-- afterOKCallFun: 自定义确定按钮后回调
function createAfterBattleLayer( appraisal, enemyUid, enemyDataTab, enemyFightData,silverData, expData, flopData, CallFun, fightStr )
    -- 初始化
    init()
    -- 判断是否是npc
    if(tonumber(enemyUid) >= 11001 and tonumber(enemyUid) <= 16000)then
        isNpc = true
    end

    _fightStr= fightStr
    local amf3_obj = Base64.decodeWithZip( _fightStr)
    _battleInfo    = amf3.decode(amf3_obj)

    -- 点击确定按钮传入回调
    afterOKCallFun = CallFun
    _flopData = flopData
    print("2222222")
    print_t(_flopData)
    winSize = CCDirector:sharedDirector():getWinSize()
    mainLayer = CCLayerColor:create(ccc4(11,11,11,200))
    mainLayer:setTouchEnabled(true)
    mainLayer:registerScriptTouchHandler(cardLayerTouch,false,-600,true)
    mainLayer:registerScriptHandler(onNodeEvent)

    -- 战斗胜负判断
    local isWin = nil
    if( appraisal ~= "E" and appraisal ~= "F" )then
        isWin = true
        -- 创建胜利背景框
        bg_sprite = BaseUI.createViewBg(CCSizeMake(520,728))
        bg_sprite:setAnchorPoint(ccp(0.5,0.5))
        bg_sprite:setPosition(ccp(winSize.width/2,winSize.height*0.40))
        mainLayer:addChild(bg_sprite)
    else
        isWin = false
        -- 创建失败背景框
        bg_sprite = BaseUI.createViewBg(CCSizeMake(520,728))
        bg_sprite:setAnchorPoint(ccp(0.5,0.5))
        bg_sprite:setPosition(ccp(winSize.width/2,winSize.height*0.40))
        mainLayer:addChild(bg_sprite)
    end

    -- 创建V/S
    local fullRect = CCRectMake(0, 0, 469, 89)
    local insetRect = CCRectMake(198,41,70, 25)
    local vs_bg = CCScale9Sprite:create("images/arena/vs_bg.png", fullRect, insetRect)
    vs_bg:setContentSize(CCSizeMake(469, 110))
    vs_bg:setAnchorPoint(ccp(0.5,0.5))
    vs_bg:setPosition(ccp(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-90))
    bg_sprite:addChild(vs_bg)
    -- vs
    local vs_sprite = CCSprite:create("images/arena/vs.png")
    vs_sprite:setAnchorPoint(ccp(0.5,0.5))
    vs_sprite:setPosition(ccp(vs_bg:getContentSize().width*0.5,vs_bg:getContentSize().height*0.5))
    vs_bg:addChild(vs_sprite)
    -- 我方名字 战斗力
    require "script/ui/arena/ArenaData"
    require "script/model/user/UserModel"
    local myUid = UserModel.getUserUid()
    local myDataTab = ArenaData.getHeroDataByUid(myUid)
    --  -- 我方姓名的颜色
    local name_color,stroke_color = ArenaData.getHeroNameColor( myDataTab.utid )
    local myName_font = CCRenderLabel:create( myDataTab.uname, g_sFontPangWa, 25, 1, stroke_color, type_stroke)
    myName_font:setColor(name_color)
    myName_font:setPosition(ccp(20,vs_bg:getContentSize().height-2))
    vs_bg:addChild(myName_font)
    -- 我方战力
    local zhan = CCSprite:create("images/arena/zhan.png")
    zhan:setAnchorPoint(ccp(0,0))
    zhan:setPosition(ccp(15,34))
    vs_bg:addChild(zhan)
    local zhan_data = CCRenderLabel:create(UserModel.getFightForceValue() , g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    zhan_data:setColor(ccc3(0xff,0xf6,0x00))
    --兼容泰文版
    --added by Zhang Zihang
    if(Platform.getPlatformFlag() == "ios_thailand" or Platform.getPlatformFlag() == "Android_taiguo" )then
        zhan_data:setPosition(ccp(74,zhan_data:getContentSize().height + 38))
    else
        zhan_data:setPosition(ccp(60,zhan_data:getContentSize().height + 38))
    end
    vs_bg:addChild(zhan_data)

    -- 敌方名字 战斗力
    require "script/ui/arena/ArenaData"
    require "script/model/user/UserModel"
    if(isNpc)then
        -- npc 性别
        local utid = tonumber(enemyDataTab.utid)
        npc_name = ArenaData.getNpcName( tonumber(enemyUid), utid)
        --  -- 敌方姓名的颜色
        local name_color,stroke_color = ArenaData.getHeroNameColor( enemyDataTab.utid )
        local enemyName_font = CCRenderLabel:create( npc_name, g_sFontPangWa, 25, 1, stroke_color, type_stroke)
        enemyName_font:setColor(name_color)
        enemyName_font:setAnchorPoint(ccp(1,1))
        enemyName_font:setPosition(ccp(vs_bg:getContentSize().width-20,vs_bg:getContentSize().height-2))
        vs_bg:addChild(enemyName_font)
    else
        --  -- 敌方姓名的颜色
        local name_color,stroke_color = ArenaData.getHeroNameColor( enemyDataTab.utid )
        local enemyName_font = CCRenderLabel:create( enemyDataTab.uname, g_sFontPangWa, 25, 1, stroke_color, type_stroke)
        enemyName_font:setColor(name_color)
        enemyName_font:setAnchorPoint(ccp(1,1))
        enemyName_font:setPosition(ccp(vs_bg:getContentSize().width-20,vs_bg:getContentSize().height-2))
        vs_bg:addChild(enemyName_font)
    end
    -- 敌方战力
    local zhan = CCSprite:create("images/arena/zhan.png")
    zhan:setAnchorPoint(ccp(0,0))
    zhan:setPosition(ccp(308,34))
    vs_bg:addChild(zhan)
    local enemyFightData = tonumber(enemyFightData) or 0
    local zhan_data = CCRenderLabel:create(math.floor(enemyFightData), g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    zhan_data:setColor(ccc3(0xff,0xf6,0x00))
    --兼容泰文版
    --added by Zhang Zihang
    if(Platform.getPlatformFlag() == "ios_thailand" or Platform.getPlatformFlag() == "Android_taiguo" )then
        zhan_data:setPosition(ccp(362,zhan_data:getContentSize().height + 38))
    else
        zhan_data:setPosition(ccp(348,zhan_data:getContentSize().height + 38))
    end
    vs_bg:addChild(zhan_data)

    --我方伤害
    local team1damageIcon = CCSprite:create("images/battle/report/damage.png")
    team1damageIcon:setAnchorPoint(ccp(0,0))
    team1damageIcon:setPosition(ccp(15,4))
    vs_bg:addChild(team1damageIcon)
    local team1DamageLabel = CCRenderLabel:create(math.abs(tonumber(_battleInfo.team2.totalDamage) or 0) , g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    team1DamageLabel:setColor(ccc3(45,253,46))
    team1DamageLabel:setAnchorPoint(ccp(0, 0.5))
    team1DamageLabel:setPosition(team1damageIcon:getContentSize().width + 10, team1damageIcon:getContentSize().height/2)
    team1damageIcon:addChild(team1DamageLabel)
    --敌方伤害
    local team2damageIcon = CCSprite:create("images/battle/report/damage.png")
    team2damageIcon:setAnchorPoint(ccp(0,0))
    team2damageIcon:setPosition(ccp(308,4))
    vs_bg:addChild(team2damageIcon)
    local team2DamageLabel = CCRenderLabel:create(math.abs(tonumber(_battleInfo.team1.totalDamage) or 0), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    team2DamageLabel:setColor(ccc3(45,253,46))
    team2DamageLabel:setAnchorPoint(ccp(0, 0.5))
    team2DamageLabel:setPosition(team2damageIcon:getContentSize().width + 10, team1damageIcon:getContentSize().height/2)
    team2damageIcon:addChild(team2DamageLabel)

    if _battleInfo.team2.totalDamage == nil then
        team1damageIcon:setVisible(false)
        team1DamageLabel:setVisible(false)
        team2damageIcon:setVisible(false)
        team2DamageLabel:setVisible(false)
    end

    -- 三个按钮
    menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-600)
    bg_sprite:addChild(menu)

    -- 对方阵容
    userFormationItem = createButtonItem()
    userFormationItem:setAnchorPoint(ccp(0.5,0.5))
    userFormationItem:registerScriptTapHandler(userFormationItemFun)
    if(isNpc)then
        menu:addChild(userFormationItem,1,tonumber(enemyDataTab.armyId))
    else
        menu:addChild(userFormationItem,1,tonumber(enemyUid))
    end
    -- 字体
    userFormationItem_font = CCRenderLabel:create( GetLocalizeStringBy("key_3305") , g_sFontPangWa, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    userFormationItem_font:setAnchorPoint(ccp(0.5,0.5))
    userFormationItem_font:setPosition(ccp(userFormationItem:getContentSize().width*0.5,userFormationItem:getContentSize().height*0.5))
    userFormationItem:addChild(userFormationItem_font)
    userFormationItem:setEnabled(false)
    userFormationItem_font:setColor(ccc3(0xf1,0xf1,0xf1))
    -- 是npc不显示阵容
    -- if(isNpc)then
    --     userFormationItem:setVisible(false)
    -- end

    -- 重播
    replayItem = createButtonItem()
    replayItem:setAnchorPoint(ccp(0.5,0.5))
    replayItem:registerScriptTapHandler(replayItemFun)
    menu:addChild(replayItem)
    -- 字体
    replayItem_font = CCRenderLabel:create( GetLocalizeStringBy("key_2184") , g_sFontPangWa, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    replayItem_font:setAnchorPoint(ccp(0.5,0.5))
    replayItem_font:setPosition(ccp(replayItem:getContentSize().width*0.5,replayItem:getContentSize().height*0.5))
    replayItem:addChild(replayItem_font)
    replayItem:setEnabled(false)
    replayItem_font:setColor(ccc3(0xf1,0xf1,0xf1))


    -- 发送战报 -- added by zhz
    _sendMsgItem =  createButtonItem()
    _sendMsgItem:setAnchorPoint(ccp(0.5,0.5))
    _sendMsgItem:registerScriptTapHandler(sendMegFun )
    _sendMsgItem:setPosition(ccp(bg_sprite:getContentSize().width*0.5,164))
    menu:addChild(_sendMsgItem)
    -- 文字
    _sendMsgItem_font = CCRenderLabel:create( GetLocalizeStringBy("key_4000") , g_sFontPangWa, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _sendMsgItem_font:setAnchorPoint(ccp(0.5,0.5))
    _sendMsgItem_font:setPosition(ccp(_sendMsgItem:getContentSize().width*0.5,_sendMsgItem:getContentSize().height*0.5))
    _sendMsgItem:addChild(_sendMsgItem_font)
    _sendMsgItem:setEnabled(false)
    _sendMsgItem_font:setColor(ccc3(0xf1,0xf1,0xf1))

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
    okItem:setEnabled(false)
    okItem_font:setColor(ccc3(0xf1,0xf1,0xf1))

    if(isWin) then
        -- 创建中间ui
        local middle_bg = BaseUI.createContentBg(CCSizeMake(463,374))
        middle_bg:setAnchorPoint(ccp(0.5,1))
        middle_bg:setPosition(ccp(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-150))
        bg_sprite:addChild(middle_bg)
        -- 花纹
        local huawen = CCSprite:create("images/arena/huawen.png")
        huawen:setAnchorPoint(ccp(0.5,0.5))
        huawen:setPosition(ccp(middle_bg:getContentSize().width*0.5,middle_bg:getContentSize().height-35))
        middle_bg:addChild(huawen)
        -- 恭喜获得
        local huode = CCSprite:create("images/arena/huode.png")
        huode:setAnchorPoint(ccp(0.5,0.5))
        huode:setPosition(ccp(huawen:getContentSize().width*0.5,huawen:getContentSize().height*0.5))
        huawen:addChild(huode)
        -- 银币
        local yibi = CCSprite:create("images/arena/yibi.png")
        yibi:setAnchorPoint(ccp(0,1))
        yibi:setPosition(ccp(10,middle_bg:getContentSize().height-80))
        middle_bg:addChild(yibi)
        local silverData = silverData or 0
        local yibi_data = CCRenderLabel:create("+".. silverData , g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        yibi_data:setColor(ccc3(0x70,0xff,0x18))
        yibi_data:setPosition(ccp(65,middle_bg:getContentSize().height-76))
        middle_bg:addChild(yibi_data)
        -- exp
        local exp = CCSprite:create("images/arena/exp.png")
        exp:setAnchorPoint(ccp(0,1))
        exp:setPosition(ccp(180,middle_bg:getContentSize().height-80))
        middle_bg:addChild(exp)
        local expData = expData or 0
        local exp_data = CCRenderLabel:create("+".. expData, g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        exp_data:setColor(ccc3(0x00,0xe4,0xff))
        exp_data:setPosition(ccp(238,middle_bg:getContentSize().height-76))
        middle_bg:addChild(exp_data)
        -- 耐力
        local naili = CCSprite:create("images/arena/naili.png")
        naili:setAnchorPoint(ccp(0,1))
        naili:setPosition(ccp(360,middle_bg:getContentSize().height-80))
        middle_bg:addChild(naili)
        local naili_data = CCRenderLabel:create("-2", g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        naili_data:setColor(ccc3(0xff,0x17,0x0c))
        naili_data:setPosition(ccp(415,middle_bg:getContentSize().height-76))
        middle_bg:addChild(naili_data)
        -- 主人请抽卡片
        local line = CCScale9Sprite:create("images/common/line2.png")
        line:setContentSize(CCSizeMake(305,38))
        line:setAnchorPoint(ccp(0.5,0.5))
        line:setPosition(ccp(middle_bg:getContentSize().width*0.5,middle_bg:getContentSize().height-135))
        middle_bg:addChild(line)
        local font_str = GetLocalizeStringBy("key_1566")
        local font = CCRenderLabel:create(font_str, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        font:setColor(ccc3(0xff,0xe4,0x00))
        font:setPosition(ccp((line:getContentSize().width-font:getContentSize().width)*0.5,line:getContentSize().height-2))
        line:addChild(font)
        -- 三张牌按钮
        cardMenu = CCMenu:create()
        cardMenu:setTouchPriority(-600)
        cardMenu:setPosition(ccp(0,0))
        middle_bg:addChild(cardMenu)
        -- 左
        local leftItem = CCMenuItemImage:create("images/arena/card_back.png","images/arena/card_back.png")
        leftItem:setAnchorPoint(ccp(0.5,0.5))
        leftItem:setPosition(ccp(6+leftItem:getContentSize().width*0.5,50+leftItem:getContentSize().height*0.5))
        cardMenu:addChild(leftItem,1,1001)
        leftItem:registerScriptTapHandler(cardMenuActionFun)
        -- 中
        local midItem = CCMenuItemImage:create("images/arena/card_back.png","images/arena/card_back.png")
        midItem:setAnchorPoint(ccp(0.5,0.5))
        midItem:setPosition(ccp(156+midItem:getContentSize().width*0.5,50+midItem:getContentSize().height*0.5))
        cardMenu:addChild(midItem,1,1002)
        midItem:registerScriptTapHandler(cardMenuActionFun)
        -- 右
        local rightItem = CCMenuItemImage:create("images/arena/card_back.png","images/arena/card_back.png")
        rightItem:setAnchorPoint(ccp(0.5,0.5))
        rightItem:setPosition(ccp(middle_bg:getContentSize().width-rightItem:getContentSize().width*0.5-6,50+rightItem:getContentSize().height*0.5))
        cardMenu:addChild(rightItem,1,1003)
        rightItem:registerScriptTapHandler(cardMenuActionFun)
        -- 左中右名字背景
        left_bg = CCSprite:create("images/arena/item_name_bg.png")
        left_bg:setAnchorPoint(ccp(0.5,0.5))
        left_bg:setPosition(ccp(leftItem:getPositionX(),left_bg:getContentSize().height*0.5+10))
        middle_bg:addChild(left_bg)
        left_bg:setVisible(false)
        mid_bg = CCSprite:create("images/arena/item_name_bg.png")
        mid_bg:setAnchorPoint(ccp(0.5,0.5))
        mid_bg:setPosition(ccp(midItem:getPositionX(),mid_bg:getContentSize().height*0.5+10))
        middle_bg:addChild(mid_bg)
        mid_bg:setVisible(false)
        right_bg = CCSprite:create("images/arena/item_name_bg.png")
        right_bg:setAnchorPoint(ccp(0.5,0.5))
        right_bg:setPosition(ccp(rightItem:getPositionX(),right_bg:getContentSize().height*0.5+10))
        middle_bg:addChild(right_bg)
        right_bg:setVisible(false)
        -- 动画
        -- 缩放动画时间(跳动画)
        local scaleSecond = 0.05
        -- 延时时间(每张跳动的间隔时间)
        local scaleDelay = 0.5
        local seqArray = CCArray:create()
        seqArray:addObject(CCCallFunc:create(function ( ... )
            -- 中
            local actionArray = CCArray:create()
            actionArray:addObject(CCScaleTo:create(scaleSecond, 1.2))
            actionArray:addObject(CCScaleTo:create(scaleSecond, 1.0))
            local mid_cardAction = CCSequence:create(actionArray)
            midItem:runAction(mid_cardAction)            
        end))
        seqArray:addObject(CCDelayTime:create(scaleDelay))
        seqArray:addObject(CCCallFunc:create(function ( ... )
             -- 右
            local right_actionArray = CCArray:create()
            right_actionArray:addObject(CCScaleTo:create(scaleSecond, 1.2))
            right_actionArray:addObject(CCScaleTo:create(scaleSecond, 1.0))
            local right_cardAction = CCSequence:create(right_actionArray)
            rightItem:runAction(right_cardAction)
        end))
        seqArray:addObject(CCDelayTime:create(scaleDelay))
        seqArray:addObject(CCCallFunc:create(function ( ... )
             -- 左
            local right_actionArray = CCArray:create()
            right_actionArray:addObject(CCScaleTo:create(scaleSecond, 1.2))
            right_actionArray:addObject(CCScaleTo:create(scaleSecond, 1.0))
            local right_cardAction = CCSequence:create(right_actionArray)
            leftItem:runAction(right_cardAction)
        end))
        seqArray:addObject(CCDelayTime:create(scaleDelay))
        local seq = CCSequence:create(seqArray)
        cardMenu:runAction(CCRepeatForever:create(seq))
        
       -- 左中右真是掉落实物品
        left_item_bg = CCSprite:create("images/arena/card_face.png")
        left_item_bg:setAnchorPoint(ccp(0.5,0.5))
        left_item_bg:setPosition(ccp(leftItem:getPositionX(),leftItem:getPositionY()))
        middle_bg:addChild(left_item_bg)
        left_item_bg:setVisible(false)
        mid_item_bg = CCSprite:create("images/arena/card_face.png")
        mid_item_bg:setAnchorPoint(ccp(0.5,0.5))
        mid_item_bg:setPosition(ccp(midItem:getPositionX(),midItem:getPositionY()))
        middle_bg:addChild(mid_item_bg)
        mid_item_bg:setVisible(false)
        right_item_bg = CCSprite:create("images/arena/card_face.png")
        right_item_bg:setAnchorPoint(ccp(0.5,0.5))
        right_item_bg:setPosition(ccp(rightItem:getPositionX(),rightItem:getPositionY()))
        middle_bg:addChild(right_item_bg)
        right_item_bg:setVisible(false)

        -- 对方阵容位置
        userFormationItem:setPosition(ccp(bg_sprite:getContentSize().width*0.3,164))

        -- 发送战报位置 added by zhz
        _sendMsgItem:setPosition(bg_sprite:getContentSize().width*0.7,164)

        -- 重播位置
        replayItem:setPosition(ccp(bg_sprite:getContentSize().width*0.3,77))
        -- 确定位置
        okItem:setPosition(ccp(bg_sprite:getContentSize().width*0.7,77))

        -- 胜利特效
        backAnimSprite2 = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli03"), -1,CCString:create(""));
        backAnimSprite2:setAnchorPoint(ccp(0.5, 0.5))
        backAnimSprite2:setPosition(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height)
        bg_sprite:addChild(backAnimSprite2,-1)
        backAnimSprite2:setVisible(false)
        
        local function showBg2()
            --print("================showBg2")
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
        
        bg_sprite:registerScriptHandler(function ( eventType,node )
            if(eventType == "enter") then
               if(file_exists("audio/effect/zhandoushengli.mp3")) then
                   AudioUtil.playEffect("audio/effect/zhandoushengli.mp3")
               end
            end
            if(eventType == "exit") then
                if(paiziSprite ~= nil)then
                    paiziSprite:removeFromParentAndCleanup(true)
                    paiziSprite = nil
                end
                if(upLootAnimSprite ~= nil)then
                      upLootAnimSprite:removeFromParentAndCleanup(true)
                      upLootAnimSprite = nil
                end
                if(downLootAnimSprite ~= nil)then
                    downLootAnimSprite:removeFromParentAndCleanup(true)
                    downLootAnimSprite = nil
                end
            end
        end)
    else
        -- 对方阵容位置
        userFormationItem:setPosition(ccp(bg_sprite:getContentSize().width*0.3,130))
        userFormationItem:setEnabled(true)
        userFormationItem_font:setColor(ccc3(0xfe, 0xdb, 0x1c))

        -- added by zhz
        _sendMsgItem:setPosition(bg_sprite:getContentSize().width*0.7,130)  
        _sendMsgItem:setEnabled(true)
        _sendMsgItem_font:setColor(ccc3(0xfe, 0xdb, 0x1c))

        -- 重播位置
        replayItem:setPosition(ccp(bg_sprite:getContentSize().width*0.3,57))
        replayItem:setEnabled(true)
        replayItem_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
        -- 确定位置
        okItem:setPosition(ccp(bg_sprite:getContentSize().width*0.7,57))
        okItem:setEnabled(true)
        okItem_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
        -- 创建中间ui
        local middle_bg = BaseUI.createContentBg(CCSizeMake(463,414))
        middle_bg:setAnchorPoint(ccp(0.5,1))
        middle_bg:setPosition(ccp(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-145))
        bg_sprite:addChild(middle_bg)
        -- 花纹
        local huawen = CCSprite:create("images/arena/huawen.png")
        huawen:setAnchorPoint(ccp(0.5,0.5))
        huawen:setPosition(ccp(middle_bg:getContentSize().width*0.5,middle_bg:getContentSize().height-35))
        middle_bg:addChild(huawen)
        -- 恭喜获得
        local huode = CCRenderLabel:create( GetLocalizeStringBy("key_1400") , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        huode:setColor(ccc3(0xff, 0xf6, 0x00))
        huode:setAnchorPoint(ccp(0.5,0.5))
        huode:setPosition(ccp(huawen:getContentSize().width*0.5,huawen:getContentSize().height*0.5))
        huawen:addChild(huode)
        -- 银币
        local yibi = CCSprite:create("images/arena/yibi.png")
        yibi:setAnchorPoint(ccp(0,1))
        yibi:setPosition(ccp(10,middle_bg:getContentSize().height-65))
        middle_bg:addChild(yibi)
        local silverData = silverData or 0
        local yibi_data = CCRenderLabel:create("+".. silverData , g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        yibi_data:setColor(ccc3(0x70,0xff,0x18))
        yibi_data:setPosition(ccp(65,middle_bg:getContentSize().height-61))
        middle_bg:addChild(yibi_data)
        -- exp
        local exp = CCSprite:create("images/arena/exp.png")
        exp:setAnchorPoint(ccp(0,1))
        exp:setPosition(ccp(180,middle_bg:getContentSize().height-65))
        middle_bg:addChild(exp)
        local expData = expData or 0
        local exp_data = CCRenderLabel:create("+".. expData, g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        exp_data:setColor(ccc3(0x00,0xe4,0xff))
        exp_data:setPosition(ccp(238,middle_bg:getContentSize().height-61))
        middle_bg:addChild(exp_data)
        -- 耐力
        local naili = CCSprite:create("images/arena/naili.png")
        naili:setAnchorPoint(ccp(0,1))
        naili:setPosition(ccp(360,middle_bg:getContentSize().height-65))
        middle_bg:addChild(naili)
        local naili_data = CCRenderLabel:create("-2", g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        naili_data:setColor(ccc3(0xff,0x17,0x0c))
        naili_data:setPosition(ccp(415,middle_bg:getContentSize().height-61))
        middle_bg:addChild(naili_data)

        local str1 = GetLocalizeStringBy("key_3053")
        local text1 = CCRenderLabel:create( str1 , g_sFontPangWa, 26, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        text1:setColor(ccc3(0xff, 0xff, 0xff))
        text1:setPosition(ccp(45,middle_bg:getContentSize().height-96))
        middle_bg:addChild(text1)
        local str2 = GetLocalizeStringBy("key_1175")
        local text2 = CCRenderLabel:create( str2 , g_sFontPangWa, 26, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        text2:setColor(ccc3(0xff, 0xff, 0xff))
        text2:setPosition(ccp(10,middle_bg:getContentSize().height-136))
        middle_bg:addChild(text2)

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

      -- 升级战魂
        local fight_soul_item = CCMenuItemImage:create("images/common/up_fightsoul_n.png","images/common/up_fightsoul_h.png")
        fight_soul_item:setAnchorPoint(ccp(0.5,0.5))
        fight_soul_item:setPosition(ccp(337,56))
        middle_menu:addChild(fight_soul_item)
        fight_soul_item:registerScriptTapHandler(fightSoulFun)

        animSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushibai"), -1,CCString:create(""))
        
        bg_sprite:registerScriptHandler(function ( eventType,node )
            if(eventType == "enter") then
               if(file_exists("audio/effect/zhandoushibai.mp3")) then
                    AudioUtil.playEffect("audio/effect/zhandoushibai.mp3")
                end
            end
            if(eventType == "exit") then
                if(paiziSprite ~= nil)then
                    paiziSprite:removeFromParentAndCleanup(true)
                    paiziSprite = nil
                end
                if(upLootAnimSprite ~= nil)then
                      upLootAnimSprite:removeFromParentAndCleanup(true)
                      upLootAnimSprite = nil
                end
                if(downLootAnimSprite ~= nil)then
                    downLootAnimSprite:removeFromParentAndCleanup(true)
                    downLootAnimSprite = nil
                end
            end
        end)
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

-- 底层银币特效播放结束
function fnDownAnimationEnd( ... )
    if(downLootAnimSprite ~= nil)then
        downLootAnimSprite:cleanup()
        -- 下方淡出
        local function fnRemoveLayerAction2()
             local function fnEndCallback()
                downLootAnimSprite:removeFromParentAndCleanup(true)
                downLootAnimSprite = nil
            end 
            local spActionArr = CCArray:create()
            spActionArr:addObject(CCFadeOut:create(2.0))
            spActionArr:addObject(CCCallFuncN:create(fnEndCallback))
            downLootAnimSprite:runAction(CCSequence:create(spActionArr))
        end
        -- 下方action
        local layerActionArray = CCArray:create()
        layerActionArray:addObject(CCDelayTime:create(0.3))
        layerActionArray:addObject(CCCallFunc:create(fnRemoveLayerAction2))
        downLootAnimSprite:runAction(CCSequence:create(layerActionArray))
        -- 板子淡出
        local function fnRemovePaiziSpriteAction()
            local function fnEndCallback()
                paiziSprite:removeFromParentAndCleanup(true)
                paiziSprite = nil
            end 
            local spActionArr = CCArray:create()
            spActionArr:addObject(CCFadeOut:create(2.0))
            spActionArr:addObject(CCCallFuncN:create(fnEndCallback))
            paiziSprite:runAction(CCSequence:create(spActionArr))
            -- 银币数据淡出
            local function fnStrEndCallback()
                yibi_data:removeFromParentAndCleanup(true)
                yibi_data = nil
            end 
            local spActionArr = CCArray:create()
            spActionArr:addObject(CCFadeOut:create(2.0))
            spActionArr:addObject(CCCallFuncN:create(fnStrEndCallback))
            yibi_data:runAction(CCSequence:create(spActionArr))
        end
        -- 板子action
        local layerActionArray = CCArray:create()
        layerActionArray:addObject(CCDelayTime:create(0.3))
        layerActionArray:addObject(CCCallFunc:create(fnRemovePaiziSpriteAction))
        paiziSprite:runAction(CCSequence:create(layerActionArray))
    end
end

-- 上层银币特效播放结束
function fnUpAnimationEnd( ... )
    if(upLootAnimSprite ~= nil)then
        upLootAnimSprite:cleanup()
        -- 上方淡出
        local function fnRemoveLayerAction1()
            local function fnEndCallback()
                upLootAnimSprite:removeFromParentAndCleanup(true)
                upLootAnimSprite = nil
            end 
            local spActionArr = CCArray:create()
            spActionArr:addObject(CCFadeOut:create(2.0))
            spActionArr:addObject(CCCallFuncN:create(fnEndCallback))
            upLootAnimSprite:runAction(CCSequence:create(spActionArr))
        end
        -- 上方action
        local layerActionArray = CCArray:create()
        layerActionArray:addObject(CCDelayTime:create(0.3))
        layerActionArray:addObject(CCCallFunc:create(fnRemoveLayerAction1))
        upLootAnimSprite:runAction(CCSequence:create(layerActionArray))
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


-- 对方阵容回调
function userFormationItemFun( tag, item_obj )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2710") .. tag )
    -- local str1 = GetLocalizeStringBy("key_3038")
    -- require "script/ui/tip/AnimationTip"
    -- AnimationTip.showTip(str1)
    require "script/ui/active/RivalInfoLayer"
    if(isNpc)then
        print(GetLocalizeStringBy("key_2710") .. tag )
        RivalInfoLayer.createLayer(tonumber(tag),true,npc_name)
    else
        print(GetLocalizeStringBy("key_2710") .. tag )
        RivalInfoLayer.createLayer(tonumber(tag))
    end
end

-- 重播回调
function replayItemFun( tag, item_obj )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2460") .. tag )
    require "script/battle/BattleLayer"
    BattleLayer.replay()
end

-- 确定回调
function okItemFun( tag, item_obj )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2060") .. tag )
    require "script/battle/BattleLayer"
    BattleLayer.closeLayer()
    -- 把下边的一排按钮显示
    MainScene.setMainSceneViewsVisible(true, false, true)
    -- 点确定后 调用回调
    if(afterOKCallFun ~= nil)then
        afterOKCallFun()
    end
end


-- 武将强化回调
function strengthenHeroFun()
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2409"))
    if not DataCache.getSwitchNodeState(ksSwitchGeneralForge) then
        return
    end
    -- 先关闭战斗场景
    require "script/battle/BattleLayer"
    BattleLayer.closeLayer()

    require "script/ui/hero/HeroLayer"
    MainScene.changeLayer(HeroLayer.createLayer(), "HeroLayer")
end

-- 装备强化回调
function strengthenArmFun()
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_1244"))
    if not DataCache.getSwitchNodeState(ksSwitchWeaponForge) then
        return
    end
    -- 先关闭战斗场景
    require "script/battle/BattleLayer"
    BattleLayer.closeLayer()

    require "script/ui/bag/BagLayer"
    local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_Arming)
    MainScene.changeLayer(bagLayer, "bagLayer")
end


-- 培养名将回调
function trainStarFun()
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2827"))
    if not DataCache.getSwitchNodeState(ksSwitchGreatSoldier) then
        return
    end
    -- 先关闭战斗场景
    require "script/battle/BattleLayer"
    BattleLayer.closeLayer()

    require "script/ui/star/StarLayer"
    local starLayer = StarLayer.createLayer()
    MainScene.changeLayer(starLayer, "starLayer")
end

-- 喂养宠物回调
function feedPetFun()
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2236"))
    
    if not DataCache.getSwitchNodeState(ksSwitchPet) then
        return
    end
    -- 先关闭战斗场景
    require "script/battle/BattleLayer"
    BattleLayer.closeLayer()

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
    require "script/battle/BattleLayer"
    BattleLayer.closeLayer()

    require("script/ui/formation/FormationLayer")
    local formationLayer = FormationLayer.createLayer()
    MainScene.changeLayer(formationLayer, "formationLayer")

end


-- added by zhz 发送战报的回调
function sendMegFun( tag, item )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/ui.chat/ChatUtil"
    local function sendClickCallback( )
        _sendMsgItem:setEnabled(false)
        _sendMsgItem_font:setColor(ccc3(0xf1,0xf1,0xf1))
        AnimationTip.showTip( GetLocalizeStringBy("key_4001") )
    end

    if(_fightStr == nil) then
        AnimationTip.showTip( GetLocalizeStringBy("key_4002"))
        return
    end

    local amf3_obj = Base64.decodeWithZip( _fightStr)
    local lua_obj = amf3.decode(amf3_obj)
    ChatUtil.sendChatinfo(lua_obj, ChatCache.ChatInfoType.battle_report_player, ChatCache.ChannelType.world, sendClickCallback)
end

-- 猎魂的回调函数 ，added by zhz
function fightSoulFun( )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2236"))
      -- 先关闭战斗场景
    require "script/battle/BattleLayer"
    BattleLayer.closeLayer()

    if not DataCache.getSwitchNodeState(ksSwitchBattleSoul) then
        return
    end
    require "script/ui/huntSoul/HuntSoulLayer"
    local layer = HuntSoulLayer.createHuntSoulLayer()
    MainScene.changeLayer(layer, "huntSoulLayer")
end


-- 翻牌回调
function cardMenuActionFun( tag, item_obj )
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    -- 翻牌动画的秒数
    local needSecond = 0.2
    -- 其他翻牌动画间隔的时间
    local intervalSecond = 0.15
    -- 停止动画
    cardMenu:stopAllActions()
    cardMenu:setTouchEnabled(false)
    -- 停止动画
    cardMenu:stopAllActions()
    cardMenu:setTouchEnabled(false)
    if(tag == 1001)then
        print("left card")
        -- 抽中数据
        local realData = _flopData.real
        -- 判断是否播放抢夺特效
        local isShow = nil
        for k,v in pairs(realData) do
            if(k == "rob")then
                isShow = true
            else
                isShow = false
            end
        end
        -- 其他两个翻转
        -- show 1 数据
        local show1Data = _flopData.show1
        fnGetIconByData(show1Data,mid_item_bg,mid_bg)
         -- show 2 数据
        local show2Data = _flopData.show2
        fnGetIconByData(show2Data,right_item_bg,right_bg)
        -- 添加图标
        fnGetIconByData(realData,left_item_bg,left_bg,isShow)
        -- 特效action
        local actionArr = CCArray:create()
        actionArr:addObject(CCOrbitCamera:create(needSecond, 1, 0, 0, 90, 0, 0))
        actionArr:addObject(CCCallFunc:create(function ( ... )
            -- UI显示
            left_item_bg:setVisible(true)
            local actions1 = CCArray:create()
            actions1:addObject(CCDelayTime:create(0.08))
            actions1:addObject(CCCallFunc:create(function ( ... )
                item_obj:setVisible(false)
            end))
            item_obj:runAction(CCSequence:create(actions1))

            -- 优化翻转特效
            local actionArr = CCArray:create()
            actionArr:addObject(CCOrbitCamera:create(needSecond, 1, 0, 270, 90, 0, 0))
            actionArr:addObject(CCCallFunc:create(function ( ... )
                addHighLight(left_item_bg)
                left_bg:setVisible(true)
            end))
            left_item_bg:runAction(CCSequence:create(actionArr))
        end))
        actionArr:addObject(CCDelayTime:create(intervalSecond))
        actionArr:addObject(CCCallFunc:create(function ( ... )
            -- 其他两天特效action
            local actionArr = CCArray:create()
            actionArr:addObject(CCOrbitCamera:create(needSecond, 1, 0, 0, 90, 0, 0))
            actionArr:addObject(CCCallFunc:create(function ( ... )
                -- UI显示
                mid_item_bg:setVisible(true)
                local actions1 = CCArray:create()
                actions1:addObject(CCDelayTime:create(0.08))
                actions1:addObject(CCCallFunc:create(function ( ... )
                    cardMenu:getChildByTag(1002):setVisible(false)
                end))
                cardMenu:getChildByTag(1002):runAction(CCSequence:create(actions1))
                -- 优化翻转特效
                local actionArr = CCArray:create()
                actionArr:addObject(CCOrbitCamera:create(needSecond, 1, 0, 270, 90, 0, 0))
                actionArr:addObject(CCCallFunc:create(function ( ... )
                    mid_bg:setVisible(true)
                end))
                mid_item_bg:runAction(CCSequence:create(actionArr))
            end))   
            cardMenu:getChildByTag(1002):runAction(CCSequence:create(actionArr))
            local actionArr = CCArray:create()
            actionArr:addObject(CCOrbitCamera:create(needSecond, 1, 0, 0, 90, 0, 0))
            actionArr:addObject(CCCallFunc:create(function ( ... )
                -- UI显示
                right_item_bg:setVisible(true)
                local actions1 = CCArray:create()
                actions1:addObject(CCDelayTime:create(0.08))
                actions1:addObject(CCCallFunc:create(function ( ... )
                    cardMenu:getChildByTag(1003):setVisible(false)
                end))
                cardMenu:getChildByTag(1003):runAction(CCSequence:create(actions1))
                -- 优化翻转特效
                local actionArr = CCArray:create()
                actionArr:addObject(CCOrbitCamera:create(needSecond, 1, 0, 270, 90, 0, 0))
                actionArr:addObject(CCCallFunc:create(function ( ... )
                    right_bg:setVisible(true)
                end))
                right_item_bg:runAction(CCSequence:create(actionArr))
            end))   
            cardMenu:getChildByTag(1003):runAction(CCSequence:create(actionArr))
        end))
        item_obj:runAction(CCSequence:create(actionArr))
    elseif(tag == 1002)then
        print("middle card")
        -- 抽中数据
        local realData = _flopData.real
        -- 判断是否播放抢夺特效
        local isShow = nil
        for k,v in pairs(realData) do
            if(k == "rob")then
                isShow = true
            else
                isShow = false
            end
        end
        fnGetIconByData(realData,mid_item_bg,mid_bg,isShow)
        -- 其他两个翻转
        -- show 1 数据
        local show1Data = _flopData.show1
        fnGetIconByData(show1Data,left_item_bg,left_bg)
        -- show 2 数据
        local show2Data = _flopData.show2
        fnGetIconByData(show2Data,right_item_bg,right_bg)
        -- 特效action
        local actionArr = CCArray:create()
        actionArr:addObject(CCOrbitCamera:create(needSecond, 1, 0, 0, 90, 0, 0))
        actionArr:addObject(CCCallFunc:create(function ( ... )
            -- UI显示
            mid_item_bg:setVisible(true)
            local actions1 = CCArray:create()
            actions1:addObject(CCDelayTime:create(0.08))
            actions1:addObject(CCCallFunc:create(function ( ... )
                item_obj:setVisible(false)
            end))
            item_obj:runAction(CCSequence:create(actions1))
            -- 优化翻转特效
            local actionArr = CCArray:create()
            actionArr:addObject(CCOrbitCamera:create(needSecond, 1, 0, 270, 90, 0, 0))
            actionArr:addObject(CCCallFunc:create(function ( ... )
                addHighLight(mid_item_bg)
                mid_bg:setVisible(true)
            end))
            mid_item_bg:runAction(CCSequence:create(actionArr))
        end))
        actionArr:addObject(CCDelayTime:create(intervalSecond))
        actionArr:addObject(CCCallFunc:create(function ( ... )
            -- 特效action
            local actionArr = CCArray:create()
            actionArr:addObject(CCOrbitCamera:create(needSecond, 1, 0, 0, 90, 0, 0))
            actionArr:addObject(CCCallFunc:create(function ( ... )
                -- UI显示
                left_item_bg:setVisible(true)
                local actions1 = CCArray:create()
                actions1:addObject(CCDelayTime:create(0.08))
                actions1:addObject(CCCallFunc:create(function ( ... )
                    cardMenu:getChildByTag(1001):setVisible(false)
                end))
                cardMenu:getChildByTag(1001):runAction(CCSequence:create(actions1))
                -- 优化翻转特效
                local actionArr = CCArray:create()
                actionArr:addObject(CCOrbitCamera:create(needSecond, 1, 0, 270, 90, 0, 0))
                actionArr:addObject(CCCallFunc:create(function ( ... )
                    left_bg:setVisible(true)
                end))
                left_item_bg:runAction(CCSequence:create(actionArr))
            end))   
            cardMenu:getChildByTag(1001):runAction(CCSequence:create(actionArr))
            local actionArr = CCArray:create()
            actionArr:addObject(CCOrbitCamera:create(needSecond, 1, 0, 0, 90, 0, 0))
            actionArr:addObject(CCCallFunc:create(function ( ... )
                -- UI显示
                right_item_bg:setVisible(true)
                local actions1 = CCArray:create()
                actions1:addObject(CCDelayTime:create(0.08))
                actions1:addObject(CCCallFunc:create(function ( ... )
                    cardMenu:getChildByTag(1003):setVisible(false)
                end))
                cardMenu:getChildByTag(1003):runAction(CCSequence:create(actions1))
                -- 优化翻转特效
                local actionArr = CCArray:create()
                actionArr:addObject(CCOrbitCamera:create(needSecond, 1, 0, 270, 90, 0, 0))
                actionArr:addObject(CCCallFunc:create(function ( ... )
                    right_bg:setVisible(true)
                end))
                right_item_bg:runAction(CCSequence:create(actionArr))
            end))   
            cardMenu:getChildByTag(1003):runAction(CCSequence:create(actionArr))
        end))
        item_obj:runAction(CCSequence:create(actionArr))
    elseif(tag == 1003)then
        print("right card")
         -- 抽中数据
        local realData = _flopData.real
        -- 判断是否播放抢夺特效
        local isShow = nil
        for k,v in pairs(realData) do
            if(k == "rob")then
                isShow = true
            else
                isShow = false
            end
        end
        fnGetIconByData(realData,right_item_bg,right_bg,isShow)
        -- show 1 数据
        local show1Data = _flopData.show1
        fnGetIconByData(show1Data,left_item_bg,left_bg)
        -- show 2 数据
        local show2Data = _flopData.show2
        fnGetIconByData(show2Data,mid_item_bg,mid_bg)
        -- 特效action
        local actionArr = CCArray:create()
        actionArr:addObject(CCOrbitCamera:create(needSecond, 1, 0, 0, 90, 0, 0))
        actionArr:addObject(CCCallFunc:create(function ( ... )
            -- UI显示
            right_item_bg:setVisible(true)
            local actions1 = CCArray:create()
            actions1:addObject(CCDelayTime:create(0.08))
            actions1:addObject(CCCallFunc:create(function ( ... )
                item_obj:setVisible(false)
            end))
            item_obj:runAction(CCSequence:create(actions1))
            -- 优化翻转特效
            local actionArr = CCArray:create()
            actionArr:addObject(CCOrbitCamera:create(needSecond, 1, 0, 270, 90, 0, 0))
            actionArr:addObject(CCCallFunc:create(function ( ... )
                addHighLight(right_item_bg)
                right_bg:setVisible(true)
            end))
            right_item_bg:runAction(CCSequence:create(actionArr))
        end))
        actionArr:addObject(CCDelayTime:create(intervalSecond))
        actionArr:addObject(CCCallFunc:create(function ( ... )
            -- 其他两个翻转
            -- 特效action
            local actionArr = CCArray:create()
            actionArr:addObject(CCOrbitCamera:create(needSecond, 1, 0, 0, 90, 0, 0))
            actionArr:addObject(CCCallFunc:create(function ( ... )
                -- UI显示
                left_item_bg:setVisible(true)
                local actions1 = CCArray:create()
                actions1:addObject(CCDelayTime:create(0.08))
                actions1:addObject(CCCallFunc:create(function ( ... )
                   cardMenu:getChildByTag(1001):setVisible(false)
                end))
                cardMenu:getChildByTag(1001):runAction(CCSequence:create(actions1))
                -- 优化翻转特效
                local actionArr = CCArray:create()
                actionArr:addObject(CCOrbitCamera:create(needSecond, 1, 0, 270, 90, 0, 0))
                actionArr:addObject(CCCallFunc:create(function ( ... )
                    left_bg:setVisible(true)
                end))
                left_item_bg:runAction(CCSequence:create(actionArr))
            end))   
            cardMenu:getChildByTag(1001):runAction(CCSequence:create(actionArr))
            local actionArr = CCArray:create()
            actionArr:addObject(CCOrbitCamera:create(needSecond, 1, 0, 0, 90, 0, 0))
            actionArr:addObject(CCCallFunc:create(function ( ... )
                -- UI显示
                mid_item_bg:setVisible(true)
                local actions1 = CCArray:create()
                actions1:addObject(CCDelayTime:create(0.08))
                actions1:addObject(CCCallFunc:create(function ( ... )
                   cardMenu:getChildByTag(1002):setVisible(false)
                end))
                cardMenu:getChildByTag(1002):runAction(CCSequence:create(actions1))
                -- 优化翻转特效
                local actionArr = CCArray:create()
                actionArr:addObject(CCOrbitCamera:create(needSecond, 1, 0, 270, 90, 0, 0))
                actionArr:addObject(CCCallFunc:create(function ( ... )
                    mid_bg:setVisible(true)
                end))
                mid_item_bg:runAction(CCSequence:create(actionArr))
            end))   
            cardMenu:getChildByTag(1002):runAction(CCSequence:create(actionArr))
        end))
        item_obj:runAction(CCSequence:create(actionArr))
    end
    -- 启用按钮
    userFormationItem:setEnabled(true)
    userFormationItem_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    replayItem:setEnabled(true)
    replayItem_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    okItem:setEnabled(true)
    okItem_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    -- added by zhz
    _sendMsgItem:setEnabled(true)
    _sendMsgItem_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
end



-- 获得翻牌物品的图标
-- 返回一个可查看信息的icon和num
-- iconParent:图标父节点
-- nameParent:名字父节点
-- isShow:是否播放抢夺特效
function fnGetIconByData( data, iconParent, nameParent, isShow )
    for k,v in pairs(data) do
        if(k == "rob")then
            icon = CCSprite:create("images/arena/lueduo.png")
            icon:setAnchorPoint(ccp(0.5,0.5))
            num = tonumber(v) or 0
            icon:setPosition(ccp(iconParent:getContentSize().width*0.5,iconParent:getContentSize().height*0.5))
            iconParent:addChild(icon)
            -- 物品名字
            local font = CCRenderLabel:create(GetLocalizeStringBy("key_1946"), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            font:setColor(ccc3(0xff,0xff,0xff))
            font:setAnchorPoint(ccp(0.5,0.5))
            font:setPosition(ccp(nameParent:getContentSize().width*0.5,nameParent:getContentSize().height*0.5))
            nameParent:addChild(font)
            if(isShow)then
                -- 播放抢夺特效
                local runningScene = CCDirector:sharedDirector():getRunningScene()
                paiziSprite = CCSprite:create("images/arena/paizi.png")
                paiziSprite:setAnchorPoint(ccp(0.5,1))
                paiziSprite:setPosition(ccp(winSize.width*0.5,winSize.height*1.5))
                runningScene:addChild(paiziSprite,8889)
                paiziSprite:runAction(CCEaseBounceOut:create(CCMoveTo:create(2, ccp(winSize.width/2, winSize.height))))
                setAdaptNode(paiziSprite)
                -- 银币数量
                yibi_data = CCRenderLabel:create( num , g_sFontPangWa, 45, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
                yibi_data:setColor(ccc3(0x70,0xff,0x18))
                yibi_data:setPosition(ccp(paiziSprite:getContentSize().width*0.5-50,140))
                paiziSprite:addChild(yibi_data)
                -- 上方银币特效
                upLootAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/loot/chenggonglueduo_u"), -1,CCString:create(""))
                upLootAnimSprite:setAnchorPoint(ccp(0.5, 0))
                upLootAnimSprite:setPosition(ccp(winSize.width*0.5,0))
                runningScene:addChild(upLootAnimSprite,8890)
                setAdaptNode(upLootAnimSprite)
                -- 上方代理
                local upDelegate = BTAnimationEventDelegate:create()
                upDelegate:registerLayerEndedHandler(fnUpAnimationEnd)
                upLootAnimSprite:setDelegate(upDelegate)
                -- 下方银币特效
                downLootAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/loot/chenggonglueduo_d"), -1,CCString:create(""))
                downLootAnimSprite:setAnchorPoint(ccp(0.5, 0))
                downLootAnimSprite:setPosition(ccp(winSize.width*0.5,0))
                runningScene:addChild(downLootAnimSprite,8887)
                setAdaptNode(downLootAnimSprite)
                -- 下方代理
                local downDelegate = BTAnimationEventDelegate:create()
                downDelegate:registerLayerEndedHandler(fnDownAnimationEnd)
                downLootAnimSprite:setDelegate(downDelegate)

                -- 特效音效
                downLootAnimSprite:registerScriptHandler(function ( eventType,node )
                    if(eventType == "enter") then
                        AudioUtil.playEffect("audio/effect/lueduochenggong.mp3")
                    end
                end)
            end
        elseif(k == "item")then
            require "script/ui/item/ItemSprite"
            require "script/ui/item/ItemUtil"
            require "script/ui/hero/HeroPublicLua"
            local data = v
            icon = ItemSprite.getItemSpriteById( data.id, nil, nil, nil, -600,999999)
            num = tonumber(v.num)
            icon:setAnchorPoint(ccp(0.5,0.5))
            icon:setPosition(ccp(iconParent:getContentSize().width*0.5,iconParent:getContentSize().height*0.5))
            iconParent:addChild(icon)
            -- 物品的数量
            local num_data = num or 1
            local num_font = CCRenderLabel:create(num_data, g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            num_font:setColor(ccc3(0x70, 0xff, 0x18))
            num_font:setAnchorPoint(ccp(1,0))
            num_font:setPosition(ccp(icon:getContentSize().width-5,2))
            icon:addChild(num_font)
            -- 物品名字
            local itemData = ItemUtil.getItemById(data.id)
            local name_color = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
            local font = CCRenderLabel:create(itemData.name, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            font:setColor(name_color)
            font:setAnchorPoint(ccp(0.5,0.5))
            font:setPosition(ccp(nameParent:getContentSize().width*0.5,nameParent:getContentSize().height*0.5))
            nameParent:addChild(font)
        elseif(k == "treasFrag")then
            require "script/ui/item/ItemSprite"
            require "script/ui/item/ItemUtil"
            require "script/ui/hero/HeroPublicLua"
            local data = v
            icon = ItemSprite.getItemSpriteById( data.id, nil, nil, nil, -600,999999)
            num = tonumber(v.num)
            icon:setAnchorPoint(ccp(0.5,0.5))
            icon:setPosition(ccp(iconParent:getContentSize().width*0.5,iconParent:getContentSize().height*0.5))
            iconParent:addChild(icon)
            -- 物品的数量
            local num_data = num or 1
            local num_font = CCRenderLabel:create(num_data, g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            num_font:setColor(ccc3(0x70, 0xff, 0x18))
            num_font:setAnchorPoint(ccp(1,0))
            num_font:setPosition(ccp(icon:getContentSize().width-5,2))
            icon:addChild(num_font)
            -- 物品名字
            local itemData = ItemUtil.getItemById(data.id)
            local name_color = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
            local font = CCRenderLabel:create(itemData.name, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            font:setColor(name_color)
            font:setAnchorPoint(ccp(0.5,0.5))
            font:setPosition(ccp(nameParent:getContentSize().width*0.5,nameParent:getContentSize().height*0.5))
            nameParent:addChild(font)
        elseif(k == "silver")then
            require "script/ui/item/ItemSprite"
            icon = ItemSprite.getSiliverIconSprite()
            num = tonumber(v)
            icon:setAnchorPoint(ccp(0.5,0.5))
            icon:setPosition(ccp(iconParent:getContentSize().width*0.5,iconParent:getContentSize().height*0.5))
            iconParent:addChild(icon)
            -- 物品的数量
            local num_data = num or 1
            local num_font = CCRenderLabel:create(num_data, g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            num_font:setColor(ccc3(0x70, 0xff, 0x18))
            num_font:setAnchorPoint(ccp(1,0))
            num_font:setPosition(ccp(icon:getContentSize().width-5,2))
            icon:addChild(num_font)
            -- 物品名字
            local quality = ItemSprite.getSilverQuality()
            local name_color = HeroPublicLua.getCCColorByStarLevel(quality)
            local font = CCRenderLabel:create(GetLocalizeStringBy("key_1687"), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            font:setColor(name_color)
            font:setAnchorPoint(ccp(0.5,0.5))
            font:setPosition(ccp(nameParent:getContentSize().width*0.5,nameParent:getContentSize().height*0.5))
            nameParent:addChild(font)
        elseif(k == "gold")then
            require "script/ui/item/ItemSprite"
            require "script/ui/hero/HeroPublicLua"
            icon = ItemSprite.getGoldIconSprite()
            num = tonumber(v)
            icon:setAnchorPoint(ccp(0.5,0.5))
            icon:setPosition(ccp(iconParent:getContentSize().width*0.5,iconParent:getContentSize().height*0.5))
            iconParent:addChild(icon)
            -- 物品的数量
            local num_data = num or 1
            local num_font = CCRenderLabel:create(num_data, g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            num_font:setColor(ccc3(0x70, 0xff, 0x18))
            num_font:setAnchorPoint(ccp(1,0))
            num_font:setPosition(ccp(icon:getContentSize().width-5,2))
            icon:addChild(num_font)
            -- 物品名字
            local quality = ItemSprite.getGoldQuality()
            local name_color = HeroPublicLua.getCCColorByStarLevel(quality)
            local font = CCRenderLabel:create(GetLocalizeStringBy("key_1491"), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            font:setColor(name_color)
            font:setAnchorPoint(ccp(0.5,0.5))
            font:setPosition(ccp(nameParent:getContentSize().width*0.5,nameParent:getContentSize().height*0.5))
            nameParent:addChild(font)
        elseif(k == "soul")then
            require "script/ui/item/ItemSprite"
            require "script/ui/hero/HeroPublicLua"
            icon = ItemSprite.getSoulIconSprite()
            num = tonumber(v)
            icon:setAnchorPoint(ccp(0.5,0.5))
            icon:setPosition(ccp(iconParent:getContentSize().width*0.5,iconParent:getContentSize().height*0.5))
            iconParent:addChild(icon)
            -- 物品的数量
            local num_data = num or 1
            local num_font = CCRenderLabel:create(num_data, g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            num_font:setColor(ccc3(0x70, 0xff, 0x18))
            num_font:setAnchorPoint(ccp(1,0))
            num_font:setPosition(ccp(icon:getContentSize().width-5,2))
            icon:addChild(num_font)
            -- 物品名字
            local quality = ItemSprite.getSoulQuality()
            local name_color = HeroPublicLua.getCCColorByStarLevel(quality)
            local font = CCRenderLabel:create(GetLocalizeStringBy("key_1616"), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            font:setColor(name_color)
            font:setAnchorPoint(ccp(0.5,0.5))
            font:setPosition(ccp(nameParent:getContentSize().width*0.5,nameParent:getContentSize().height*0.5))
            nameParent:addChild(font)
        elseif(k == "hero")then
            require "script/ui/hero/HeroPublicCC"
            require "script/ui/hero/HeroPublicLua"
            require "db/DB_Heroes"
            local data = v
            icon = CCMenu:create()
            icon:setPosition(ccp(0,0))
            icon:setTouchPriority(-600)
            iconItem = HeroPublicCC.getCMISHeadIconByHtid(data.id)
            iconItem:setAnchorPoint(ccp(0.5,0.5))
            iconItem:setPosition(ccp(iconParent:getContentSize().width*0.5,iconParent:getContentSize().height*0.5))
            icon:addChild(iconItem,1,tonumber(data.id))
            iconItem:registerScriptTapHandler(heroSpriteCb)
            num = tonumber(v.num)
            iconParent:addChild(icon)
            -- 物品的数量
            local num_data = num or 1
            local num_font = CCRenderLabel:create(num_data, g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            num_font:setColor(ccc3(0x70, 0xff, 0x18))
            num_font:setAnchorPoint(ccp(1,0))
            num_font:setPosition(ccp(iconItem:getContentSize().width-5,2))
            iconItem:addChild(num_font)
            local heroData = DB_Heroes.getDataById(data.id)
            local name_color = HeroPublicLua.getCCColorByStarLevel(heroData.star_lv)
            local font = CCRenderLabel:create(heroData.name, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            font:setColor(name_color)
            font:setAnchorPoint(ccp(0.5,0.5))
            font:setPosition(ccp(nameParent:getContentSize().width*0.5,nameParent:getContentSize().height*0.5))
            nameParent:addChild(font)
        end
    end
end



-- 获得英雄的信息
local function getHeroData( htid)
    value = {}

    value.htid = htid
    require "db/DB_Heroes"
    local db_hero = DB_Heroes.getDataById(htid)
    value.country_icon = HeroModel.getCiconByCidAndlevel(db_hero.country, db_hero.star_lv)
    value.name = db_hero.name
    value.level = db_hero.lv
    value.star_lv = db_hero.star_lv
    value.hero_cb = menu_item_tap_handler
    value.head_icon = "images/base/hero/head_icon/" .. db_hero.head_icon_id
    value.quality_bg = "images/hero/quality/"..value.star_lv .. ".png"
    value.quality_h = "images/hero/quality/highlighted.png"
    value.type = "HeroFragment"
    value.isRecruited = false
    value.evolve_level = 0

    return value
end

-- 点击英雄头像的回调函数
function heroSpriteCb( tag,menuItem )
    local data = getHeroData(tag)
    local tArgs = {}
    tArgs.sign = "AfterBattleLayer"
    tArgs.fnCreate = AfterBattleLayer.createAfterBattleLayer
    tArgs.reserved =  {index= 10001}
    HeroInfoLayer.createLayer(data, {isPanel=true})
end

-- 抽中高亮特效
function addHighLight( parent )
    lightAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/light/duobaoshanguang"), -1,CCString:create(""))
    lightAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
    lightAnimSprite:setPosition(parent:getContentSize().width*0.5,parent:getContentSize().height*0.5)
    parent:addChild(lightAnimSprite,-1)
end











