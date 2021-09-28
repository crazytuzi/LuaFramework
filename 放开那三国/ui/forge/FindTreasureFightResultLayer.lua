-- Filename: FindTreasureFightResultLayer.lua
-- Author: bzx
-- Date: 2014-12-20
-- Purpose: 寻龙试炼战斗结算面板

require "script/utils/extern"
require "script/libs/LuaCCLabel"
module("FindTreasureFightResultLayer", package.seeall)

local IMG_PATH = "images/battle/report/"                -- 图片主路径

local _layer
local _isWin
local _animSprite = nil
local _back_animSprite = nil
local _back_animSprite2 = nil
local _commitButton
local _shareButton
local _touchPriority
local _confirmCallback
local _toOtherLayerCallback
local _isWithoutFight

function replayClick()

end

function commitClick()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    if(_animSprite~=nil)then
        _animSprite:removeFromParentAndCleanup(true)
    end
    if(_back_animSprite~=nil)then
        _back_animSprite:removeFromParentAndCleanup(true)
    end
    
    if(_back_animSprite2~=nil)then
        _back_animSprite2:removeFromParentAndCleanup(true)
    end
    
    _animSprite = nil
    _back_animSprite = nil
    _back_animSprite2 = nil
    if not _isWithoutFight then
        require "script/battle/BattleLayer"
        BattleLayer.closeLayer()
    else
        _layer:removeFromParentAndCleanup(true)
    end
    if _confirmCallback ~= nil then
        _confirmCallback()
    end
end

function shareCallBack()
    --_shareButton:setEnabled(false)
end

function shareClick()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/utils/BaseUI"
    local shareImagePath = BaseUI.getScreenshots()
    require "script/ui/share/ShareLayer"
    ShareLayer.show(nil, shareImagePath,9999, -1000, shareCallBack)
end

-- 武将强化回调
function strengthenHeroFun()
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2409"))
    -- 先关闭战斗场景
    commitClick()
    if _toOtherLayerCallback ~= nil then
        _toOtherLayerCallback()
    end
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
    if _toOtherLayerCallback ~= nil then
        _toOtherLayerCallback()
    end
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
    if _toOtherLayerCallback ~= nil then
        _toOtherLayerCallback()
    end
    
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
    if _toOtherLayerCallback ~= nil then
        _toOtherLayerCallback()
    end
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
    if _toOtherLayerCallback ~= nil then
        _toOtherLayerCallback()
    end

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
    if _toOtherLayerCallback ~= nil then
        _toOtherLayerCallback()
    end
    if not DataCache.getSwitchNodeState(ksSwitchBattleSoul) then
        return
    end
    require "script/ui/huntSoul/HuntSoulLayer"
    local layer = HuntSoulLayer.createHuntSoulLayer()
    MainScene.changeLayer(layer, "huntSoulLayer")
    
end

function stopAnimation(_animSprite)

end

function animationEnd(animationName,xmlSprite,functionName)

    if _layer:isRunning() == false then
        return
    end
    if(_animSprite~=nil)then
        _animSprite:cleanup()
    end
    if(_back_animSprite~=nil)then
        _back_animSprite:cleanup()
    end
end
function animationFrameChanged(animationName,xmlSprite,functionName)
end

function getBattleReportLayer (isWin,itemArray, heroArray, point, confirmCallback, touchPriority, toOtherLayerCallback, isWithoutFight)
    _touchPriority = touchPriority or -600
    _confirmCallback = confirmCallback
    _toOtherLayerCallback = toOtherLayerCallback
    _isWithoutFight = isWithoutFight
    require "script/ui/main/MainScene"
    local m_layerSize = isWin == true and CCSizeMake(520, 500) or CCSizeMake(520,720)
    local scale = MainScene.elementScale
    
    local standSize = CCSizeMake(640, 960)
    
    local winSize = CCDirector:sharedDirector():getWinSize()
    
    if(winSize.height/winSize.width>standSize.height/standSize.width) then
        elementScale = winSize.width/standSize.width;
        scale = elementScale   
    else
        elementScale = winSize.height/standSize.height;
        scale = elementScale
    end
    _layer = CCLayer:create()
    _layer:registerScriptHandler(onNodeEvent)
    local m_reportInfoLayer = CCLayer:create()
    m_reportInfoLayer:setScale(scale)
    m_reportInfoLayer:setPosition((CCDirector:sharedDirector():getWinSize().width-m_layerSize.width*scale)/2,CCDirector:sharedDirector():getWinSize().height*0.755-m_layerSize.height*scale)
    _layer:addChild(m_reportInfoLayer)
    _isWin = isWin
    
    require "script/model/user/UserModel"
    
    --播放胜负动画
    AudioUtil.stopBgm()
    --local _animSprite = nil
    if(isWin) then
        _back_animSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli02"), -1,CCString:create(""));
        
        _back_animSprite:setAnchorPoint(ccp(0.5, 0.5));
        _back_animSprite:setPosition(CCDirector:sharedDirector():getWinSize().width/2,CCDirector:sharedDirector():getWinSize().height*0.74);
        _back_animSprite:setScale(scale)
        _layer:addChild(_back_animSprite,-1);
        
        local showBg2 = function()
            local _back_animSprite2 = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli03"), -1,CCString:create(""));
            
            _back_animSprite2:setAnchorPoint(ccp(0.5, 0.5));
            _back_animSprite2:setPosition(CCDirector:sharedDirector():getWinSize().width/2,CCDirector:sharedDirector():getWinSize().height*0.74);
            _back_animSprite2:setScale(scale)
            _layer:addChild(_back_animSprite2,-2);
            
        end
    
    local layerActionArray = CCArray:create()
    layerActionArray:addObject(CCDelayTime:create(1.5))
    layerActionArray:addObject(CCCallFunc:create(showBg2))
    _back_animSprite:runAction(CCSequence:create(layerActionArray))
    
    _animSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli01"), -1,CCString:create(""));
        if(file_exists("audio/effect/zhandoushengli.mp3")) then
            AudioUtil.playEffect("audio/effect/zhandoushengli.mp3")
        end
    else
        _back_animSprite = nil
        _animSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushibai"), -1,CCString:create(""));
    
        if(file_exists("audio/effect/zhandoushibai.mp3")) then
            
            print("zhandoushibai.mp3")
            AudioUtil.playEffect("audio/effect/zhandoushibai.mp3")
        end
    end

    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    _animSprite:setDelegate(delegate)

    _animSprite:retain()
    _animSprite:setAnchorPoint(ccp(0.5, 0.5));
    _animSprite:setPosition(CCDirector:sharedDirector():getWinSize().width/2,CCDirector:sharedDirector():getWinSize().height*0.74);
    _animSprite:setScale(scale)
    _layer:addChild(_animSprite);
    _animSprite:release()
    
    local m_reportBg = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),IMG_PATH .. "bg.png")
    m_reportBg:setContentSize(m_layerSize)
    m_reportBg:setAnchorPoint(ccp(0,0))
    m_reportBg:setPosition(0,0)
    m_reportInfoLayer:addChild(m_reportBg)


    require "script/utils/LuaUtil"
require "script/model/DataCache"

--区分胜负

if(_isWin==true)then

    local pointTitle = CCSprite:create("images/forge/fight_result/get_point.png")
    m_reportBg:addChild(pointTitle)
    pointTitle:setAnchorPoint(ccp(0, 0.5))
    pointTitle:setPosition(ccp(180, 430))

    local pointLabel = CCRenderLabel:create(tostring(point), g_sFontName, 26, 1, ccc3( 0x10, 0x10, 0x10), type_stroke)
    pointTitle:addChild(pointLabel)
    pointLabel:setAnchorPoint(ccp(0, 0.5))
    pointLabel:setPosition(ccpsprite(1, 0.5, pointTitle))
    pointLabel:setColor(ccc3(0x00, 0xff, 0x18))


     _commitButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200,73),GetLocalizeStringBy("key_1061"),ccc3(255,222,0))
    _commitButton:setAnchorPoint(ccp(0.5,0.5))
    if(Platform.getOS() == "wp")then
        _commitButton:setPosition(ccp(m_layerSize.width*0.5, 57))
    else
        _commitButton:setPosition(ccp(m_layerSize.width*0.7, 57))
    end
    
    _commitButton:registerScriptTapHandler(commitClick)

    _shareButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200,73),GetLocalizeStringBy("key_2391"),ccc3(255,222,0))
    _shareButton:setAnchorPoint(ccp(0.5,0.5))
    _shareButton:setPosition(ccp(m_layerSize.width*0.3, 57))
    _shareButton:registerScriptTapHandler(shareClick)
    --[[
    local replayButton = CCMenuItemImage:create("images/battle/btn/btn_replay_n.png","images/battle/btn/btn_replay_h.png")
    replayButton:setAnchorPoint(ccp(0.5,0.5))
    replayButton:setPosition(ccp(m_layerSize.width*0.7,m_layerSize.height*0.1))
    replayButton:registerScriptTapHandler(BattleReportLayer.replayClick)
    --]]
    
    local menu = CCMenu:create()
    menu:setAnchorPoint(ccp(0,0))
    menu:setPosition(0,0)
    menu:addChild(_commitButton)
    if(Platform.getOS() ~= "wp")then
        menu:addChild(_shareButton)
    end
    
    --menu:addChild(replayButton)
    m_reportBg:addChild(menu)
    menu:setTouchPriority(_touchPriority - 5)
    
    local m_itemBg = CCScale9Sprite:create(CCRectMake(20, 20, 10, 10),"images/common/bg/9s_1.png")
    m_itemBg:setContentSize(CCSizeMake(m_layerSize.width-50,270))
    m_itemBg:setAnchorPoint(ccp(0,0))
    m_itemBg:setPosition(25,100)
    m_reportBg:addChild(m_itemBg)

    local labelbg = CCScale9Sprite:create(CCRectMake(25, 15, 20, 10),"images/common/astro_labelbg.png")
    labelbg:setPreferredSize(CCSizeMake(m_layerSize.width*0.4, 36))
    labelbg:setAnchorPoint(ccp(0.5,0.5))
    labelbg:setPosition(m_itemBg:getContentSize().width*0.5,m_itemBg:getContentSize().height*1)
    m_itemBg:addChild(labelbg)

    local itemBgTitle = CCLabelTTF:create(GetLocalizeStringBy("key_2882"),g_sFontName,24)
    itemBgTitle:setAnchorPoint(ccp(0.5,0.5))
    itemBgTitle:setPosition(m_itemBg:getContentSize().width*0.5,m_itemBg:getContentSize().height*1)
    itemBgTitle:setColor(ccc3(0xff,0xf6,0x00))
    m_itemBg:addChild(itemBgTitle)
    
    if(_isWin) then
        
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
        
        local rewardCount = #itemArray + #heroArray
        
        local columnNumber = 3
        
        local startX = m_itemBg:getContentSize().width*0.2-scrollView:getPositionX()
        local startY = m_itemBg:getContentSize().height*0.75-scrollView:getPositionY()
        
        local intervalX = m_itemBg:getContentSize().width*0.3
        local intervalY = m_itemBg:getContentSize().height*0.43
        --print("rewardCount,startY:",rewardCount,startY)
        if(math.ceil(rewardCount/columnNumber)>2)then
            startY = startY + (math.ceil(rewardCount/columnNumber)-2)*intervalY
        end
        --print("startX,startY:",startX,startY)
        local rewardLayer = CCLayer:create()
        rewardLayer:setContentSize(CCSizeMake(520,startY+intervalY*0.4))
        rewardLayer:setAnchorPoint(ccp(0,0))
        
        local rewardLayerY = rewardLayer:getContentSize().height>scrollView:getContentSize().height and -rewardLayer:getContentSize().height+scrollView:getContentSize().height or 0
        rewardLayer:setPosition(0,rewardLayerY)
        scrollView:setContainer(rewardLayer)
        
        require "script/ui/item/ItemSprite"
        require "script/ui/item/ItemUtil"
        for i=1,#itemArray do
            --local item = CCSprite:create("images/item/bg/itembg_" .. (i%6+1) .. ".png")
            local item = ItemSprite.getItemSpriteById(tonumber(itemArray[i].item_template_id))
            item:setAnchorPoint(ccp(0.5,0.5))
            item:setPosition(startX+intervalX*math.floor((i-1)%columnNumber),startY-intervalY*math.floor((i-1)/columnNumber))
            rewardLayer:addChild(item)
            --print("itemArray[i].item_template_id:",itemArray[i].item_template_id)
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
        heroArray = heroArray==nil and {} or heroArray
        
        require "script/ui/hero/HeroPublicCC"
        require "db/DB_Monsters_tmpl"
        for i=1,#heroArray do
            --print("battle report hero array:",heroArray[i].htid)
            local item = HeroPublicCC.getCMISHeadIconByHtid(tonumber(heroArray[i].htid))
            item:setAnchorPoint(ccp(0.5,0.5))
            item:setPosition(startX+intervalX*math.floor(((i+#itemArray)-1)%columnNumber),startY-intervalY*math.floor(((i+#itemArray)-1)/columnNumber))
            rewardLayer:addChild(item)
            
            local dbItem = DB_Monsters_tmpl.getDataById(tonumber(heroArray[i].htid))
            if(dbItem~=nil and dbItem.name~=nil)then
                local itemNameLabel = CCRenderLabel:create(dbItem.name, g_sFontName, 18, 1.5, ccc3( 0x10, 0x10, 0x10), type_stroke)
                itemNameLabel:setColor(ccc3( 0xff, 0xf6, 0x00))
                itemNameLabel:setAnchorPoint(ccp(0.5,0.5))
                itemNameLabel:setPosition(item:getContentSize().width*0.5,-item:getContentSize().height*0.1)
                item:addChild(itemNameLabel)
            end
        end
    end
    else
        --失败界面
        
        _commitButton = CCMenuItemImage:create("images/battle/btn/btn_commit_n.png","images/battle/btn/btn_commit_h.png")
        _commitButton:setAnchorPoint(ccp(0.5,0.5))
        _commitButton:setPosition(ccp(m_layerSize.width*0.5, 57))
        _commitButton:registerScriptTapHandler(commitClick)
        
        --[[
         local replayButton = CCMenuItemImage:create("images/battle/btn/btn_replay_n.png","images/battle/btn/btn_replay_h.png")
         replayButton:setAnchorPoint(ccp(0.5,0.5))
         replayButton:setPosition(ccp(m_layerSize.width*0.7,m_layerSize.height*0.1))
         replayButton:registerScriptTapHandler(BattleReportLayer.replayClick)
         --]]
        
        local menu = CCMenu:create()
        menu:setAnchorPoint(ccp(0,0))
        menu:setPosition(0,0)
        menu:addChild(_commitButton)
        --menu:addChild(replayButton)
        m_reportBg:addChild(menu)
        menu:setTouchPriority(_touchPriority - 5)
    
    -- 创建中间ui
    local middle_bg = CCScale9Sprite:create(CCRectMake(20, 20, 10, 10),"images/common/bg/bg_ng_attr.png")
    middle_bg:setContentSize(CCSizeMake(m_layerSize.width-50,450))
    --BaseUI.createContentBg(CCSizeMake(463,374))
    middle_bg:setAnchorPoint(ccp(0.5,1))
    middle_bg:setPosition(ccp(m_reportBg:getContentSize().width*0.5,m_reportBg:getContentSize().height-150))
    m_reportBg:addChild(middle_bg)
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
    middle_menu:setTouchPriority(_touchPriority - 5)
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

    end
    return _layer
end


function onNodeEvent(event)
    if (event == "enter") then
        _layer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
        _layer:setTouchEnabled(true)
    elseif (event == "exit") then
        _layer:unregisterScriptTouchHandler()
        _layer = nil
    end
end

function onTouchesHandler(eventType, x, y)
    return true
end
