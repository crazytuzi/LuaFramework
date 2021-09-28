-- Filename: BattleLayer.lua
-- Author: k
-- Date: 2013-05-27
-- Purpose: 战斗场景



require "script/utils/extern"
require "script/libs/LuaCCLabel"
--require "amf3"
-- 主城场景模块声明
module("BattleReportLayer", package.seeall)

local IMG_PATH = "images/battle/report/"                -- 图片主路径

local m_reportLayer
local m_isWin
local animSprite = nil
local backAnimSprite = nil
local backAnimSprite2 = nil
-- local delegate = nil
local expLabel
local soulLabel
local moneyLabel
local m_soulNumber
local m_silverNumber
local m_expNumber
local m_expChangeNumber
local expBar
local commitButton
local shareButton
local levelLabel

local animationTime = 1.3
local isExpChanged = false
local m_copyType = nil

local function cardLayerTouch(eventType, x, y)

    return true

end

function replayClick()

    print("==========replayClick===============")
end

function commitClick()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    m_reportLayer = nil
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
    require "script/battle/BattleLayer"
    BattleLayer.closeLayer()

    --print("==========commitClick===============")

    --local scene = CCDirector:sharedDirector():getRunningScene()
    --scene:removeChildByTag(67890,true)
    --CCDirector:sharedDirector():getScheduler():setTimeScale(1)

end

function shareCallBack()
--shareButton:setEnabled(false)
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

function stopAnimation(animSprite)
--[[
    if(m_isWin) then
        animSprite:removeFromParentAndCleanup(true)
    else
        animSprite:removeFromParentAndCleanup(true)
    end
     --]]
end

function animationEnd(animationName,xmlSprite,functionName)
    ---[[
    --print("=============animationEnd===============")
    -- if(delegate~=nil)then
    --     delegate = tolua.cast(delegate,"CCObject")
    --     delegate:release()
    -- end
    if(animSprite~=nil)then
        --animSprite:removeFromParentAndCleanup(true)
        animSprite:cleanup()
    end
    if(backAnimSprite~=nil)then
        backAnimSprite:cleanup()
    end
    --]]
end
function animationFrameChanged(animationName,xmlSprite,functionName)
--print("=============animationFrameChanged===============")
end

function updateExpNumber()
    local number = tonumber(expLabel:getString())
    if(number~=nil and number<m_expNumber)then
        number = number + math.ceil(m_expNumber/animationTime/30)
        expLabel:setString("" .. number)
    else
        expLabel:setString("" .. m_expNumber)
        m_reportLayer:stopActionByTag(10001)
    end
end

function updateSoulNumber()
    local number = tonumber(soulLabel:getString())
    if(number~=nil and number<m_soulNumber)then
        number = number + math.ceil(m_soulNumber/animationTime/30)
        soulLabel:setString("" .. number)
    else
        soulLabel:setString("" .. m_soulNumber)
        m_reportLayer:stopActionByTag(10002)
    end
end

function updateSilverNumber()
    local number = tonumber(moneyLabel:getString())
    if(number~=nil and number<m_silverNumber)then
        number = number + math.ceil(m_silverNumber/animationTime/30)
        moneyLabel:setString("" .. number)
    else
        moneyLabel:setString("" .. m_silverNumber)
        m_reportLayer:stopActionByTag(10003)
    end
end


function updateExpLine()
    --print("updateExpLine!")
    print("updateExpLine:",m_expChangeNumber,m_expChangeNumber>m_expNumber)
    if(m_expChangeNumber~=nil and m_expChangeNumber<=m_expNumber and m_expNumber>0)then
        --m_expChangeNumber = m_expChangeNumber - m_expNumber/animationTime/30
        m_expChangeNumber = m_expChangeNumber + m_expNumber/animationTime/30

        require "db/DB_Level_up_exp"
        local db_level = DB_Level_up_exp.getDataById(2)
        local percent = 1
        if(db_level~=nil and db_level["lv_" .. (tonumber(UserModel.getHeroLevel())+1)]~=nil and UserModel.getExpValue()~=nil) then
            --print("updateExpLine:",UserModel.getExpValue(),m_expChangeNumber,db_level["lv_" .. (tonumber(UserModel.getHeroLevel())+1)])
            --print("m_expChangeNumber:",m_expChangeNumber,db_level["lv_" .. (tonumber(UserModel.getHeroLevel())+1)])
            percent = (UserModel.getExpValue()+m_expChangeNumber)/db_level["lv_" .. (tonumber(UserModel.getHeroLevel())+1)]
        end
        if(percent >= 1 and levelLabel~=nil)then
            local levelStr = tonumber(UserModel.getHeroLevel())+1
            levelLabel:setString(levelStr .. "")
            percent = (UserModel.getExpValue()+m_expChangeNumber-db_level["lv_" .. (tonumber(UserModel.getHeroLevel())+1)])/db_level["lv_" .. (tonumber(UserModel.getHeroLevel())+2)]
        end

        percent = percent - math.floor(percent)
        expBar:setTextureRect(CCRectMake(0,0,expBar:getTexture():getContentSize().width*percent,expBar:getContentSize().height))
        --print("updateExpLine ing")
    else
        m_reportLayer:stopActionByTag(10004)

        commitButton:setEnabled(true)
        --commitButton:setColor(ccc3(255,255,255))
        if(Platform.getOS()~= "wp")then
            shareButton:setEnabled(true)
        end

        require "script/model/user/UserModel"
        --修改缓存信息
        if(m_isWin and isExpChanged == false) then
            --print("^^^^^^^^^^^BattleReportLayer expChanged^^^^^^^^^^^")
            isExpChanged = true
            UserModel.addExpValue(tonumber(m_expNumber),"dobattle")
            UserModel.changeSilverNumber(tonumber(m_silverNumber))
            UserModel.changeHeroSoulNumber(tonumber(m_soulNumber))
        end
    end
end

-- 获得卡牌层
function getBattleReportLayer (isWin,copy_id,base_id,level,soulNumber,itemArray,silverNumber,expNumber,copyType,heroArray,isScore)
    --print("*************BattleReportLayer getBattleReportLayer*************")

    if(m_reportLayer~=nil)then
    --return m_reportLayer
    end
    m_copyType = copyType
    isScore = isScore==nil and "false" or isScore
    isExpChanged = false
    require "script/battle/BattleLayer"
    BattleLayer.endShake()

    m_soulNumber = soulNumber
    m_silverNumber = silverNumber
    m_expNumber = expNumber
    print("getBattleReportLayer m_expNumber", m_expNumber)
    --m_expChangeNumber = m_expNumber
    m_expChangeNumber = 0
    require "script/ui/main/MainScene"

    local m_layerSize = CCSizeMake(520,720)

    --local scale = CCDirector:sharedDirector():getWinSize().height/960
    local scale = MainScene.elementScale

    local standSize = CCSizeMake(640, 960)

    local winSize = CCDirector:sharedDirector():getWinSize()

    if(winSize.height/winSize.width>standSize.height/standSize.width) then
        bgScale = winSize.height/standSize.height;
        elementScale = winSize.width/standSize.width;
        -- 伸缩比率因子设成全局变量
        g_fElementScaleRatio = elementScale
        g_fBgScaleRatio = bgScale
        scale = elementScale

    else
        elementScale = winSize.height/standSize.height;
        bgScale = winSize.width/standSize.width;
        -- 伸缩比率因子设成全局变量
        g_fElementScaleRatio = elementScale
        g_fBgScaleRatio = bgScale
        scale = elementScale
    end
    --print("------------",scale)
    m_reportLayer = CCLayer:create()
    local m_reportInfoLayer = CCLayer:create()
    m_reportInfoLayer:setScale(scale)
    m_reportInfoLayer:setPosition((CCDirector:sharedDirector():getWinSize().width-m_layerSize.width*scale)/2,CCDirector:sharedDirector():getWinSize().height*0.755-m_layerSize.height*scale)
    m_reportLayer:addChild(m_reportInfoLayer)
    m_reportLayer:setTouchEnabled(true)
    m_reportLayer:registerScriptTouchHandler(cardLayerTouch,false,-700,true)
    m_isWin = isWin

    require "script/model/user/UserModel"

    --播放胜负动画
    AudioUtil.stopBgm()
    --local animSprite = nil
    if(isWin) then
        backAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli02"), -1,CCString:create(""));

        backAnimSprite:setAnchorPoint(ccp(0.5, 0.5));
        backAnimSprite:setPosition(CCDirector:sharedDirector():getWinSize().width/2,CCDirector:sharedDirector():getWinSize().height*0.74);
        backAnimSprite:setScale(scale)
        m_reportLayer:addChild(backAnimSprite,-1);

        local function showBg2()
            --print("================showBg2")
            local backAnimSprite2 = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli03"), -1,CCString:create(""));

            backAnimSprite2:setAnchorPoint(ccp(0.5, 0.5));
            backAnimSprite2:setPosition(CCDirector:sharedDirector():getWinSize().width/2,CCDirector:sharedDirector():getWinSize().height*0.74);
            backAnimSprite2:setScale(scale)
            m_reportLayer:addChild(backAnimSprite2,-2);

        end

        local layerActionArray = CCArray:create()
        layerActionArray:addObject(CCDelayTime:create(1.5))
        layerActionArray:addObject(CCCallFunc:create(showBg2))
        backAnimSprite:runAction(CCSequence:create(layerActionArray))

        animSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli01"), -1,CCString:create(""));
        if(file_exists("audio/effect/zhandoushengli.mp3")) then
            --print("zhandoushengli01.mp3")
            AudioUtil.playEffect("audio/effect/zhandoushengli.mp3")
        end
    else
        backAnimSprite = nil
        animSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushibai"), -1,CCString:create(""));

        if(file_exists("audio/effect/zhandoushibai.mp3")) then

            print("zhandoushibai.mp3")
            AudioUtil.playEffect("audio/effect/zhandoushibai.mp3")
        end
    end

    local delegate = BTAnimationEventDelegate:create()
    --delegate:retain()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    animSprite:setDelegate(delegate)

    animSprite:retain()
    animSprite:setAnchorPoint(ccp(0.5, 0.5));
    animSprite:setPosition(CCDirector:sharedDirector():getWinSize().width/2,CCDirector:sharedDirector():getWinSize().height*0.74);
    animSprite:setScale(scale)
    m_reportLayer:addChild(animSprite);
    animSprite:release()

    --[[
    local animTime = animSprite:getAnimationTime()
    print("================== animTime:",animTime)
    local trailActionArray = CCArray:create()
    trailActionArray:addObject(CCDelayTime:create(animTime))
    trailActionArray:addObject(CCCallFuncN:create(stopAnimation))
    --animSprite:runAction(CCSequence:create(trailActionArray));
    --]]

    local m_reportBg = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),IMG_PATH .. "bg.png")
    m_reportBg:setContentSize(m_layerSize)
    m_reportBg:setAnchorPoint(ccp(0,0))
    m_reportBg:setPosition(0,0)
    m_reportInfoLayer:addChild(m_reportBg)
    --[[
    local titleBg = CCSprite:create(IMG_PATH .. "title_bg.png")
    titleBg:setAnchorPoint(ccp(0.5,0.5))
    titleBg:setPosition(300,633.5)
    m_reportBg:addChild(titleBg)
    --]]
    local cp = nil
    if(copyType==1)then
        require "db/DB_Copy"
        cp = DB_Copy.getDataById(copy_id)
    elseif(copyType==2)then
        require "db/DB_Elitecopy"
        cp = DB_Elitecopy.getDataById(copy_id)
    elseif(copyType==3)then
        require "db/DB_Activitycopy"
        cp = DB_Activitycopy.getDataById(copy_id)
    elseif(copyType==4)then
        require "db/DB_Tower_layer"
        cp = DB_Tower_layer.getDataById(copy_id)
    end
    --[[
    local displayName = CCLabelTTF:create(cp.name,g_sFontName,35)
    --local displayName = CCRenderLabel:create(cp.name, g_sFontName, 35, 3, ccc3( 0x36, 0x00, 0x03), type_stroke)
    --displayName:setSourceAndTargetColor(ccc3( 0xff, 0xf0, 0x49), ccc3( 0xff, 0xa2, 0x00));
    --displayName:setPosition((titleBg:getContentSize().width-displayName:getContentSize().width)/2,titleBg:getContentSize().height*0.85)
    displayName:setColor(ccc3( 0xff, 0xf0, 0x49))
    displayName:setAnchorPoint(ccp(0.5,0.5))
    displayName:setPosition((titleBg:getContentSize().width)/2,titleBg:getContentSize().height*0.5)
    titleBg:addChild(displayName)
    --]]
    require "db/DB_Stronghold"
    local sh = DB_Stronghold.getDataById(base_id)
    local shName = CCRenderLabel:create(sh.name, g_sFontPangWa, 30, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    --local shName = CCLabelTTF:create(sh.name, g_sFontName, 30)
    shName:setColor(ccc3( 0xff, 0xe4, 0x00))
    --shName:setSourceAndTargetColor(ccc3( 0x78, 0x25, 0x00), ccc3( 0x77, 0x25, 0x00));
    shName:setAnchorPoint(ccp(0.5,0.5))
    shName:setPosition(m_layerSize.width*0.5,m_layerSize.height*0.94)
    m_reportBg:addChild(shName)

    --[[
    --修改缓存信息
    if(m_isWin) then
        UserModel.addExpValue(tonumber(expNumber),"dobattle")
        UserModel.changeSilverNumber(tonumber(silverNumber))
        UserModel.changeHeroSoulNumber(tonumber(soulNumber))
    end
    --]]
    require "script/utils/LuaUtil"
    --print_table("itemArray",sh)

    local levelStr = nil
    --减少体力
    if(level==1) then
        levelStr = "simple"
    elseif(level==2) then
        levelStr = "normal"
    elseif(level==3) then
        levelStr = "hard"
    else
        -- NPC战斗
        levelStr = "simple"
    end

    local costEnegy = nil
    --策划确认NPC战不扣体力
    if(level==0) then
        costEnegy = 0
    else
        costEnegy = sh["cost_energy_" .. levelStr]
    end

    if(costEnegy==nil)then
        costEnegy = 0
    end
    if(m_isWin==true and m_copyType ~= 5)then
        UserModel.changeEnergyValue(-1*tonumber(costEnegy))
    end
    --展示难度
    local shLevelLabel = CCSprite:create(IMG_PATH .."level_" .. levelStr .. ".png")
    shLevelLabel:setAnchorPoint(ccp(0.5,0.5))
    shLevelLabel:setPosition(m_layerSize.width*0.15,m_layerSize.height*0.87)
    m_reportBg:addChild(shLevelLabel)

    local shLevelBg = CCSprite:create("images/copy/stronghold/starbg.png")
    shLevelBg:setAnchorPoint(ccp(0.5,0.5))
    shLevelBg:setPosition(m_layerSize.width*0.5,m_layerSize.height*0.87)
    m_reportBg:addChild(shLevelBg)

    require "script/model/DataCache"
    --print_table("normalCopy",DataCache.getNormalCopyData())
    local normalCopyList = DataCache.getNormalCopyData()
    local currentStar = 0
    for cNum=1,#normalCopyList do
        local copy_info = normalCopyList[cNum].va_copy_info
        --print("copy_info:",copy_info,copy_info.progress,base_id)
        --print_table("copy_info.progress",copy_info.progress)
        if(copy_info~=nil and copy_info.progress~=nil and copy_info.progress["" .. base_id]~=nil)then
            --print("copy_info.progress[base_id]:",copy_info.progress["" .. base_id])
            currentStar = tonumber(copy_info.progress["" .. base_id])==nil and 0 or tonumber(copy_info.progress["" .. base_id])-2
            break
        end
    end
    --print("isScore:",isScore)
    if(m_isWin==true and (isScore==true or isScore=="true"))then
        --print("currentStar,level:",currentStar,level)
        local currentLevel = level==0 and 1 or level
        currentStar = currentStar>currentLevel and currentStar or currentLevel
    end

    --local levelLimit = level==0 and 1 or level
    local levelLimit = 1
    if(sh.army_ids_hard~=nil)then
        levelLimit = 3
    elseif(sh.army_ids_normal~=nil)then
        levelLimit = 2
    end
    --print("currentStar,levelLimit:",currentStar,levelLimit)
    for ln=1,levelLimit do
        local starFile = ln>currentStar and "star_d.png" or "star.png"
        local shStar = CCSprite:create(IMG_PATH .. starFile)
        shStar:setAnchorPoint(ccp(0.5,0.5))
        shStar:setPosition(shLevelBg:getContentSize().width*(1/(levelLimit+1))*ln,shLevelBg:getContentSize().height*0.5)
        shLevelBg:addChild(shStar)
    end

    --区分胜负

    if(m_isWin==true)then
        local moneyBg = CCScale9Sprite:create(CCRectMake(20, 20, 10, 10),"images/common/labelbg_white.png")
        moneyBg:setContentSize(CCSizeMake(380,40))
        moneyBg:setAnchorPoint(ccp(0.5,0.5))
        moneyBg:setPosition(m_layerSize.width*0.5,m_layerSize.height*0.8)
        m_reportBg:addChild(moneyBg)

        local moneyDesc = CCLabelTTF:create(GetLocalizeStringBy("key_2470"),g_sFontName,24)
        moneyDesc:setAnchorPoint(ccp(0.5,0.5))
        moneyDesc:setPosition(moneyBg:getContentSize().width*0.32,moneyBg:getContentSize().height*0.5)
        moneyDesc:setColor(ccc3(0x78,0x25,0x00))
        moneyBg:addChild(moneyDesc)

        local moneyIcon = CCSprite:create("images/battle/icon/icon_money.png")
        moneyIcon:setAnchorPoint(ccp(0.5,0.5))
        moneyIcon:setPosition(moneyBg:getContentSize().width*0.61,moneyBg:getContentSize().height*0.5)
        moneyBg:addChild(moneyIcon)

        moneyLabel = CCLabelTTF:create("" .. 0,g_sFontName,24)
        moneyLabel:setAnchorPoint(ccp(0,0.5))
        moneyLabel:setPosition(moneyBg:getContentSize().width*0.67,moneyBg:getContentSize().height*0.5)
        moneyLabel:setColor(ccc3(0x00,0x00,0x00))
        moneyBg:addChild(moneyLabel)

        local silverAction = schedule(m_reportLayer,updateSilverNumber,1/60)
        silverAction:setTag(10003)

        local soulBg = CCScale9Sprite:create(CCRectMake(20, 20, 10, 10),"images/common/labelbg_white.png")
        soulBg:setContentSize(CCSizeMake(380,40))
        soulBg:setAnchorPoint(ccp(0.5,0.5))
        soulBg:setPosition(m_layerSize.width*0.5,m_layerSize.height*0.735)
        m_reportBg:addChild(soulBg)

        local soulDesc = CCLabelTTF:create(GetLocalizeStringBy("key_1008"),g_sFontName,24)
        soulDesc:setAnchorPoint(ccp(0.5,0.5))
        soulDesc:setPosition(soulBg:getContentSize().width*0.32,soulBg:getContentSize().height*0.5)
        soulDesc:setColor(ccc3(0x78,0x25,0x00))
        soulBg:addChild(soulDesc)

        local soulIcon = CCSprite:create("images/battle/icon/icon_soul.png")
        soulIcon:setAnchorPoint(ccp(0.5,0.5))
        soulIcon:setPosition(soulBg:getContentSize().width*0.61,soulBg:getContentSize().height*0.5)
        soulBg:addChild(soulIcon)

        soulLabel = CCLabelTTF:create("" .. 0,g_sFontName,24)
        soulLabel:setAnchorPoint(ccp(0,0.5))
        soulLabel:setPosition(soulBg:getContentSize().width*0.67,soulBg:getContentSize().height*0.5)
        soulLabel:setColor(ccc3(0x00,0x00,0x00))
        soulBg:addChild(soulLabel)

        local soulAction = schedule(m_reportLayer,updateSoulNumber,1/60)
        soulAction:setTag(10002)


        local expBg = CCScale9Sprite:create(CCRectMake(20, 20, 10, 10),"images/common/labelbg_white.png")
        expBg:setContentSize(CCSizeMake(380,40))
        expBg:setAnchorPoint(ccp(0.5,0.5))
        expBg:setPosition(m_layerSize.width*0.5,m_layerSize.height*0.67)
        m_reportBg:addChild(expBg)

        local expDesc = CCLabelTTF:create(GetLocalizeStringBy("key_2969"),g_sFontName,24)
        expDesc:setAnchorPoint(ccp(0.5,0.5))
        expDesc:setPosition(expBg:getContentSize().width*0.32,expBg:getContentSize().height*0.5)
        expDesc:setColor(ccc3(0x78,0x25,0x00))
        expBg:addChild(expDesc)

        local expIcon = CCSprite:create("images/common/exp.png")
        expIcon:setAnchorPoint(ccp(0.5,0.5))
        expIcon:setPosition(expBg:getContentSize().width*0.57,expBg:getContentSize().height*0.5)
        expBg:addChild(expIcon)

        expLabel = CCLabelTTF:create("" .. 0,g_sFontName,24)
        expLabel:setAnchorPoint(ccp(0,0.5))
        expLabel:setPosition(expBg:getContentSize().width*0.67,expBg:getContentSize().height*0.5)
        expLabel:setColor(ccc3(0x00,0x00,0x00))
        expBg:addChild(expLabel)

        --双倍活动
        require "script/ui/rechargeActive/ActiveCache"
        if ActiveCache.isWealActivityOpen(ActiveCache.WealType.MULT_COPY) then
            if m_copyType ==  BattleLayer.kNormalCopy then
                local DoubleExpEffect = XMLSprite:create("images/battle/report/effect/huodongfanbei")
                DoubleExpEffect:setPosition(ccpsprite(0.95, 0.5, expBg))
                expBg:addChild(DoubleExpEffect, 20)
            end
        end

        local expAction = schedule(m_reportLayer,updateExpNumber,1/60)
        expAction:setTag(10001)


        local levelIcon = CCSprite:create("images/common/lv.png")
        levelIcon:setAnchorPoint(ccp(0.5,0.5))
        levelIcon:setPosition(m_layerSize.width*0.3,m_layerSize.height*0.61)
        m_reportBg:addChild(levelIcon)

        --local levelLabel = CCLabelTTF:create("" .. UserModel.getHeroLevel(),g_sFontName,24)
        levelLabel = CCRenderLabel:create("" .. UserModel.getHeroLevel(), g_sFontName, 24, 1.5, ccc3( 0x00, 0x00, 0x03), type_stroke)
        levelLabel:setAnchorPoint(ccp(0.5,0.5))
        levelLabel:setPosition(m_layerSize.width*0.37,m_layerSize.height*0.61)
        levelLabel:setColor(ccc3(0xff,0xf6,0x00))
        m_reportBg:addChild(levelLabel)

        if(UserModel.hasReachedMaxLevel()==true)then
            local maxSprite = CCSprite:create("images/battle/report/max.png")
            maxSprite:setAnchorPoint(ccp(0.5,0.5))
            maxSprite:setPosition(m_layerSize.width*0.65,m_layerSize.height*0.61)
            m_reportBg:addChild(maxSprite,12)
        end

        local expBarBg = CCSprite:create("images/main/progress_black.png")
        expBarBg:setAnchorPoint(ccp(0,0.5))
        expBarBg:setPosition(m_layerSize.width*0.47,m_layerSize.height*0.61)
        m_reportBg:addChild(expBarBg)

        require "db/DB_Level_up_exp"
        local db_level = DB_Level_up_exp.getDataById(2)
        local percent = 1
        if(db_level~=nil and db_level["lv_" .. (tonumber(UserModel.getHeroLevel())+1)]~=nil and UserModel.getExpValue()~=nil) then
            percent = UserModel.getExpValue()/db_level["lv_" .. (tonumber(UserModel.getHeroLevel())+1)]
        end
        expBar = CCSprite:create("images/main/progress_blue.png")
        expBar:setAnchorPoint(ccp(0,0.5))
        expBar:setPosition(0,expBarBg:getContentSize().height*0.5)
        expBar:setTextureRect(CCRectMake(0,0,expBar:getContentSize().width*percent,expBar:getContentSize().height))
        expBarBg:addChild(expBar)

        -- add by licong
        -- 当前战斗力
        local fightSp = CCSprite:create("images/common/cur_fight.png")
        fightSp:setAnchorPoint(ccp(0.5,0.5))
        fightSp:setPosition(ccp(m_layerSize.width*0.4,m_layerSize.height*0.57))
        m_reportBg:addChild(fightSp)
        local  powerDescLabel = CCRenderLabel:create(UserModel.getFightForceValue() , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        powerDescLabel:setColor(ccc3(0xff, 0xf6, 0x00))
        powerDescLabel:setAnchorPoint(ccp(0,0.5))
        powerDescLabel:setPosition(fightSp:getPositionX()+fightSp:getContentSize().width/2+10,fightSp:getPositionY())
        m_reportBg:addChild(powerDescLabel)
        -----------------------------------------

        commitButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200,73),GetLocalizeStringBy("key_1061"),ccc3(255,222,0))
        commitButton:setAnchorPoint(ccp(0.5,0.5))
        if(Platform.getOS() == "wp")then
            commitButton:setPosition(ccp(m_layerSize.width*0.5,m_layerSize.height*0.08))
        else
            commitButton:setPosition(ccp(m_layerSize.width*0.7,m_layerSize.height*0.08))
        end

        commitButton:registerScriptTapHandler(BattleReportLayer.commitClick)

        shareButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200,73),GetLocalizeStringBy("key_2391"),ccc3(255,222,0))
        shareButton:setAnchorPoint(ccp(0.5,0.5))
        shareButton:setPosition(ccp(m_layerSize.width*0.3,m_layerSize.height*0.08))
        shareButton:registerScriptTapHandler(shareClick)

        if(m_isWin==true and tonumber(m_expNumber)>0) then
            commitButton:setEnabled(false)
            --commitButton:setColor(ccc3(111,111,111))
            if(Platform.getOS() ~= "wp")then
                shareButton:setEnabled(false)
            end
        end
        commitButton:setCascadeColorEnabled(true)

        --[[
    local replayButton = CCMenuItemImage:create("images/battle/btn/btn_replay_n.png","images/battle/btn/btn_replay_h.png")
    replayButton:setAnchorPoint(ccp(0.5,0.5))
    replayButton:setPosition(ccp(m_layerSize.width*0.7,m_layerSize.height*0.1))
    replayButton:registerScriptTapHandler(BattleReportLayer.replayClick)
    --]]

        local menu = CCMenu:create()
        menu:setAnchorPoint(ccp(0,0))
        menu:setPosition(0,0)
        menu:addChild(commitButton)
        if(Platform.getOS() ~= "wp")then
            menu:addChild(shareButton)
        end

        --menu:addChild(replayButton)
        m_reportBg:addChild(menu)
        menu:setTouchPriority(-720)

        local m_itemBg = CCScale9Sprite:create(CCRectMake(20, 20, 10, 10),"images/common/bg/9s_1.png")
        m_itemBg:setContentSize(CCSizeMake(m_layerSize.width-50,270))
        m_itemBg:setAnchorPoint(ccp(0,0))
        m_itemBg:setPosition(25,100)
        m_reportBg:addChild(m_itemBg)

        local labelbg = CCScale9Sprite:create(CCRectMake(25, 15, 20, 10),"images/common/astro_labelbg.png")
        labelbg:setPreferredSize(CCSizeMake(m_layerSize.width*0.4,m_layerSize.height*0.05))
        labelbg:setAnchorPoint(ccp(0.5,0.5))
        labelbg:setPosition(m_itemBg:getContentSize().width*0.5,m_itemBg:getContentSize().height*1)
        m_itemBg:addChild(labelbg)

        local itemBgTitle = CCLabelTTF:create(GetLocalizeStringBy("key_2882"),g_sFontName,24)
        itemBgTitle:setAnchorPoint(ccp(0.5,0.5))
        itemBgTitle:setPosition(m_itemBg:getContentSize().width*0.5,m_itemBg:getContentSize().height*1)
        itemBgTitle:setColor(ccc3(0xff,0xf6,0x00))
        m_itemBg:addChild(itemBgTitle)

        if(m_isWin) then

            local scrollView = CCScrollView:create()
            scrollView:setTouchPriority(-720)
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
                --兼容东南亚英文版
                if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
                else
                    local dbItem = ItemUtil.getItemById(tonumber(itemArray[i].item_template_id))
                    if(dbItem~=nil and dbItem.name~=nil)then
                        local itemNameLabel = CCRenderLabel:create(dbItem.name, g_sFontName, 18, 1, ccc3( 0x10, 0x10, 0x10), type_stroke)
                        local quality = ItemUtil.getEquipQualityByTid(itemArray[i].item_template_id)
                        local qualityColor = HeroPublicLua.getCCColorByStarLevel(quality)
                        itemNameLabel:setColor( qualityColor or ccc3( 0xff, 0xf6, 0x00))
                        itemNameLabel:setAnchorPoint(ccp(0.5,0.5))
                        itemNameLabel:setPosition(item:getContentSize().width*0.5,-item:getContentSize().height*0.15)
                        item:addChild(itemNameLabel)
                    end
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

                --兼容东南亚英文版
                if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
                else
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
        end

        local barAction = schedule(m_reportLayer,updateExpLine,1/30)
        barAction:setTag(10004)

        --m_reportLayer:setScale(scale)

    else
        --失败界面

        commitButton = CCMenuItemImage:create("images/battle/btn/btn_commit_n.png","images/battle/btn/btn_commit_h.png")
        commitButton:setAnchorPoint(ccp(0.5,0.5))
        commitButton:setPosition(ccp(m_layerSize.width*0.5,m_layerSize.height*0.09))
        commitButton:registerScriptTapHandler(BattleReportLayer.commitClick)

        --[[
         local replayButton = CCMenuItemImage:create("images/battle/btn/btn_replay_n.png","images/battle/btn/btn_replay_h.png")
         replayButton:setAnchorPoint(ccp(0.5,0.5))
         replayButton:setPosition(ccp(m_layerSize.width*0.7,m_layerSize.height*0.1))
         replayButton:registerScriptTapHandler(BattleReportLayer.replayClick)
         --]]

        local menu = CCMenu:create()
        menu:setAnchorPoint(ccp(0,0))
        menu:setPosition(0,0)
        menu:addChild(commitButton)
        --menu:addChild(replayButton)
        m_reportBg:addChild(menu)
        menu:setTouchPriority(-720)

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

        -- add by licong
        -- 当前战斗力
        local fightSp = CCSprite:create("images/common/cur_fight.png")
        fightSp:setAnchorPoint(ccp(0.5,0.5))
        fightSp:setPosition(ccp(m_layerSize.width*0.4,middle_bg:getContentSize().height-150))
        middle_bg:addChild(fightSp)
        local  powerDescLabel = CCRenderLabel:create(UserModel.getFightForceValue() , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        powerDescLabel:setColor(ccc3(0xff, 0xf6, 0x00))
        powerDescLabel:setAnchorPoint(ccp(0,0.5))
        powerDescLabel:setPosition(fightSp:getPositionX()+fightSp:getContentSize().width/2+10,fightSp:getPositionY())
        middle_bg:addChild(powerDescLabel)

        -- 四个按钮
        local middle_menu = CCMenu:create()
        middle_menu:setPosition(ccp(0,0))
        middle_menu:setTouchPriority(-720)
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
    return m_reportLayer
end

function getScene()
    local scene = CCScene:create()
    scene:addChild(getBattleReportLayer(true,1,1001,1,1234,{},1234,54321))
    return scene
end

-- 退出场景，释放不必要资源
function release (...)

end

