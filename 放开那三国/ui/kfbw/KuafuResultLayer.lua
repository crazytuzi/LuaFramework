-- FileName: KuafuResultLayer.lua 
-- Author: yangrui
-- Date: 15-10-15
-- Purpose: 在 script/ui/arena/AfterBattleLayer.lua 之上修改而来 用于跨服比武的战斗结算

require "script/utils/BaseUI"

module("KuafuResultLayer", package.seeall)

local mainLayer              = nil     
local menu                   = nil
local backAnimSprite         = nil
local animSprite             = nil
local winSize                = nil
local bg_sprite              = nil
local afterOKCallFun         = nil  -- 回调函数
local left_bg                = nil  -- 左文字
local mid_bg                 = nil  -- 中文字
local right_bg               = nil  -- 右文字
local upLootAnimSprite       = nil  -- 抢夺特效
local downLootAnimSprite     = nil  -- 抢夺特效
local paiziSprite            = nil
local yibi_data              = nil
local userFormationItem      = nil
local replayItem             = nil
local okItem                 = nil
local userFormationItem_font = nil
local replayItem_font        = nil
local okItem_font            = nil
local _fightStr              = nil
local _battleInfo            = nil

-- 初始化
function init( ... )
    mainLayer              = nil
    menu                   = nil
    backAnimSprite         = nil
    animSprite             = nil
    winSize                = nil
    bg_sprite              = nil
    afterOKCallFun         = nil
    left_bg                = nil
    mid_bg                 = nil
    right_bg               = nil
    upLootAnimSprite       = nil
    downLootAnimSprite     = nil
    paiziSprite            = nil
    yibi_data              = nil
    userFormationItem      = nil
    replayItem             = nil
    okItem                 = nil
    userFormationItem_font = nil
    replayItem_font        = nil
    okItem_font            = nil
    _fightStr              = nil
    _battleInfo            = nil
end

--[[
    @des    : touch事件处理
    @param  : 
    @return : 
--]]
function cardLayerTouch( eventType, x, y )
    return true
end

--[[
    @des    : 回调onEnter和onExit事件
    @param  : 
    @return : 
--]]
function onNodeEvent( event )
    if ( event == "enter" ) then
        PreRequest.setIsCanShowAchieveTip(false)
    elseif ( event == "exit" ) then
        PreRequest.setIsCanShowAchieveTip(true)
    end
end

--[[
    @des    : 创建挑战结算面板
    @param  : appraisal 战斗评价   enemyDataTab 对手信息   CallFun 自定义确定按钮后回调
    @return : 
--]]
function createAfterBattleLayer( pRetData, enemyDataTab, CallFun )
    print("创建战斗结算面板")
    -- 初始化
    init()
    local appraisal = pRetData.appraisal
    -- 战斗喘
    _fightStr = pRetData.fightRet
    print(_fightStr)
    print("zip")
    local amf3_obj = Base64.decodeWithZip( _fightStr)
    print("decode")
    _battleInfo    = amf3.decode(amf3_obj)
    -- 点击确定按钮传入回调
    afterOKCallFun = CallFun

    winSize = CCDirector:sharedDirector():getWinSize()
    mainLayer = CCLayerColor:create(ccc4(11,11,11,200))
    mainLayer:setTouchEnabled(true)
    mainLayer:registerScriptTouchHandler(cardLayerTouch,false,-600,true)
    mainLayer:registerScriptHandler(onNodeEvent)
    print("胜负判断")
    -- 战斗胜负判断
    local isWin = nil
    if( appraisal ~= "E" and appraisal ~= "F" )then
        isWin = true
        -- 创建胜利背景框
        bg_sprite = BaseUI.createViewBg(CCSizeMake(520,528))
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
    print("创建V/S")
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
    -- -- 我方名字 战斗力
    require "script/model/user/UserModel"
    local mName = UserModel.getUserName()
    --  -- 我方姓名的颜色
    local userHtid = UserModel.getAvatarHtid()
    local heroInfo = HeroUtil.getHeroLocalInfoByHtid(userHtid)
    local nameColor = HeroPublicLua.getCCColorByStarLevel(heroInfo.star_lv)
    local myName_font = CCRenderLabel:create( mName, g_sFontPangWa, 25, 1, ccc3(0x00,0x00,0x00), type_stroke)
    myName_font:setColor(nameColor)
    myName_font:setPosition(ccp(20,vs_bg:getContentSize().height-2))
    vs_bg:addChild(myName_font)
    -- 我方战力
    local zhan = CCSprite:create("images/arena/zhan.png")
    zhan:setAnchorPoint(ccp(0,0))
    zhan:setPosition(ccp(15,34))
    vs_bg:addChild(zhan)
    local zhan_data = CCRenderLabel:create(UserModel.getFightForceValue() , g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    zhan_data:setColor(ccc3(0xff,0xf6,0x00))
    zhan_data:setPosition(ccp(60,zhan_data:getContentSize().height + 38))
    vs_bg:addChild(zhan_data)
    -- 敌方名字 战斗力
    local heroInfo = HeroUtil.getHeroLocalInfoByHtid(enemyDataTab.htid)
    local nameColor = HeroPublicLua.getCCColorByStarLevel(heroInfo.star_lv)
    -- 敌方姓名的颜色
    local enemyName_font = CCRenderLabel:create( enemyDataTab.uname, g_sFontPangWa, 25, 1, ccc3(0x00,0x00,0x00), type_stroke)
    enemyName_font:setColor(nameColor)
    enemyName_font:setAnchorPoint(ccp(1,1))
    enemyName_font:setPosition(ccp(vs_bg:getContentSize().width-20,vs_bg:getContentSize().height-2))
    vs_bg:addChild(enemyName_font)
    -- 敌方战力
    local zhan = CCSprite:create("images/arena/zhan.png")
    zhan:setAnchorPoint(ccp(0,0))
    zhan:setPosition(ccp(308,34))
    vs_bg:addChild(zhan)
    local enemyFightData = tonumber(enemyDataTab.fight_force) or 0
    local zhan_data = CCRenderLabel:create(math.floor(enemyDataTab.fight_force), g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    zhan_data:setColor(ccc3(0xff,0xf6,0x00))
    zhan_data:setPosition(ccp(348,zhan_data:getContentSize().height + 38))
    vs_bg:addChild(zhan_data)
    --我方伤害
    print("我方伤害")
    local team1damageIcon = CCSprite:create("images/battle/report/damage.png")
    team1damageIcon:setAnchorPoint(ccp(0,0))
    team1damageIcon:setPosition(ccp(15,4))
    vs_bg:addChild(team1damageIcon)
    local team1DamageLabel = CCRenderLabel:create(math.abs(tonumber(_battleInfo.team2.totalDamage) or 0), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
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
    -- 兼容战斗力不显示
    if _battleInfo.team2.totalDamage == nil then
        team1damageIcon:setVisible(false)
        team1DamageLabel:setVisible(false)
        team2damageIcon:setVisible(false)
        team2DamageLabel:setVisible(false)
    end
    -- 三个按钮
    print("三个按钮")
    menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-600)
    bg_sprite:addChild(menu)
    -- 对方阵容
    print("对方阵容")
    userFormationItem = createButtonItem()
    userFormationItem:setAnchorPoint(ccp(0.5,0.5))
    userFormationItem:registerScriptTapHandler(function ( ... )
        userFormationItemFun(enemyDataTab.server_id,enemyDataTab.pid)
    end)
    menu:addChild(userFormationItem,1)
    -- 对方阵容文字
    print("对方阵容")
    userFormationItem_font = CCRenderLabel:create( GetLocalizeStringBy("key_3305") , g_sFontPangWa, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    userFormationItem_font:setAnchorPoint(ccp(0.5,0.5))
    userFormationItem_font:setPosition(ccp(userFormationItem:getContentSize().width*0.5,userFormationItem:getContentSize().height*0.5))
    userFormationItem:addChild(userFormationItem_font)
    userFormationItem_font:setColor(ccc3(0xf1,0xf1,0xf1))
    -- 重播
    print("重播")
    replayItem = createButtonItem()
    replayItem:setAnchorPoint(ccp(0.5,0.5))
    replayItem:registerScriptTapHandler(replayItemFun)
    menu:addChild(replayItem)
    -- 重播字体
    replayItem_font = CCRenderLabel:create( GetLocalizeStringBy("key_2184") , g_sFontPangWa, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    replayItem_font:setAnchorPoint(ccp(0.5,0.5))
    replayItem_font:setPosition(ccp(replayItem:getContentSize().width*0.5,replayItem:getContentSize().height*0.5))
    replayItem:addChild(replayItem_font)
    replayItem_font:setColor(ccc3(0xf1,0xf1,0xf1))
    -- 确定
    print("确定")
    okItem = createButtonItem()
    okItem:setAnchorPoint(ccp(0.5,0.5))
    okItem:registerScriptTapHandler(okItemFun)
    menu:addChild(okItem)
    -- 确定字体
    okItem_font = CCRenderLabel:create( GetLocalizeStringBy("key_1985") , g_sFontPangWa, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    okItem_font:setAnchorPoint(ccp(0.5,0.5))
    okItem_font:setPosition(ccp(okItem:getContentSize().width*0.5,okItem:getContentSize().height*0.5))
    okItem:addChild(okItem_font)
    okItem_font:setColor(ccc3(0xf1,0xf1,0xf1))
    print("判断是否胜利")
    -- 判断是否胜利
    if(isWin) then
        -- 创建中间ui
        local middle_bg = BaseUI.createContentBg(CCSizeMake(463,150))
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
        -- 创建荣誉
        -- KuafuData.getShouldAddHonor(enemyForce)
        require "script/libs/LuaCCLabel"
        local richInfo = {
            linespace = 2, -- 行间距
            alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
            lineAlignment = 2, -- 当前行在竖直方向上的对齐方式 1，下对齐， 2，居中， 3，上对齐
            labelDefaultFont = g_sFontPangWa,
            labelDefaultColor = ccc3(0xff, 0xf6, 0x00),
            labelDefaultSize = 24,
            defaultType = "CCRenderLabel",
            elements =
            {
                {
                    type = "CCRenderLabel", 
                    newLine = false,
                    text = GetLocalizeStringBy("yr_2023"),
                    renderType = 2,-- 1 描边， 2 投影
                },
                {
                    type = "CCRenderLabel", 
                    newLine = false,
                    text = "+" .. KuafuData.getShouldAddHonor(enemyDataTab.fight_force),
                    color = ccc3(0x00, 0xff, 0x00),
                    renderType = 2,-- 1 描边， 2 投影
                },
            }
        }
        local richTextLayer = LuaCCLabel.createRichLabel(richInfo)
        richTextLayer:setAnchorPoint(ccp(0.5, 1))
        richTextLayer:setPosition(ccp(middle_bg:getContentSize().width*0.5, middle_bg:getContentSize().height*0.5))
        middle_bg:addChild(richTextLayer)
        -- 对方阵容位置
        userFormationItem:setPosition(ccp(bg_sprite:getContentSize().width*0.5,164))
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
    else--- 失败
        -- 对方阵容位置
        userFormationItem:setPosition(ccp(bg_sprite:getContentSize().width*0.5,130))
        userFormationItem_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
        -- 重播位置
        replayItem:setPosition(ccp(bg_sprite:getContentSize().width*0.3,57))
        replayItem_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
        -- 确定位置
        okItem:setPosition(ccp(bg_sprite:getContentSize().width*0.7,57))
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
        -- 提示获得失败荣誉
        require "script/libs/LuaCCLabel"
        local richInfo = {
            linespace = 2, -- 行间距
            alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
            lineAlignment = 2, -- 当前行在竖直方向上的对齐方式 1，下对齐， 2，居中， 3，上对齐
            labelDefaultFont = g_sFontPangWa,
            labelDefaultColor = ccc3(0xff, 0xf6, 0x00),
            labelDefaultSize = 24,
            defaultType = "CCRenderLabel",
            elements =
            {
                {
                    type = "CCRenderLabel", 
                    newLine = false,
                    text = GetLocalizeStringBy("yr_2023"),
                    renderType = 2,-- 1 描边， 2 投影
                },
                {
                    type = "CCRenderLabel", 
                    newLine = false,
                    text = "+" .. KuafuData.getFailHonor(),
                    color = ccc3(0x00, 0xff, 0x00),
                    renderType = 2,-- 1 描边， 2 投影
                },
            }
        }
        local richTextLayer = LuaCCLabel.createRichLabel(richInfo)
        richTextLayer:setAnchorPoint(ccp(0.5, 1))
        richTextLayer:setPosition(ccp(huawen:getContentSize().width*0.5, huawen:getPositionY()-huawen:getContentSize().height-5))
        middle_bg:addChild(richTextLayer)
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
        -- 调整整容
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
    animSprite:setDelegate(delegate)

    -- 适配
    setAdaptNode(bg_sprite)

    print("创建结束")

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

-- 按钮item
function createButtonItem()
    local normalSprite  = CCScale9Sprite:create("images/common/btn/btn_green_n.png")
    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn_green_h.png")
    local disabledSprite = CCScale9Sprite:create("images/common/btn/btn_hui.png")
    local item = CCMenuItemSprite:create(normalSprite,selectSprite,disabledSprite)
    return item
end


-- 对方阵容回调
function userFormationItemFun( pServerId, pPid )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    require "script/ui/active/RivalInfoLayer"
    local pid = tonumber(pPid)
    local serverId = tonumber(pServerId)
    RivalInfoLayer.createLayer(nil,nil,nil,nil,nil,nil,pid,serverId,true)
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
    MainScene.setMainSceneViewsVisible(false, false, true)
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
