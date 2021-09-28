-- Filename: BattleLayerLee.lua
-- Author: k
-- Date: 2013-05-27
-- Purpose: 战斗场景



require "script/utils/extern"
--require "amf3"
-- 主城场景模块声明
module("BattleReportLayerLee", package.seeall)

local IMG_PATH = "images/battle/report/"				-- 图片主路径

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

local animationTime = 2

local function cardLayerTouch(eventType, x, y)
    
    return true
    
end

function replayClick()
    
    print("==========replayClick===============")
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
    require "script/guide/overture/BattleLayerLee"
    BattleLayerLee.closeLayer()
    --print("==========commitClick===============")
    
    --local scene = CCDirector:sharedDirector():getRunningScene()
    --scene:removeChildByTag(67890,true)
    --CCDirector:sharedDirector():getScheduler():setTimeScale(1)
    
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
    --print("updateExpLine:",m_expChangeNumber,m_expChangeNumber>m_expNumber)
    if(m_expChangeNumber~=nil and m_expChangeNumber>0)then
        m_expChangeNumber = m_expChangeNumber - m_expNumber/animationTime/30
        
        require "db/DB_Level_up_exp"
        local db_level = DB_Level_up_exp.getDataById(2)
        local percent = 1
        if(db_level~=nil and db_level["lv_" .. (tonumber(UserModel.getHeroLevel())+1)]~=nil and UserModel.getExpValue()~=nil) then
            --print("updateExpLine:",UserModel.getExpValue(),m_expChangeNumber,db_level["lv_" .. (tonumber(UserModel.getHeroLevel())+1)])
            percent = (UserModel.getExpValue()-m_expChangeNumber)/db_level["lv_" .. (tonumber(UserModel.getHeroLevel())+1)]
        end
        percent = percent - math.floor(percent)
        expBar:setTextureRect(CCRectMake(0,0,expBar:getTexture():getContentSize().width*percent,expBar:getContentSize().height))
        --print("updateExpLine ing")
    else
        m_reportLayer:stopActionByTag(10004)
    end
end

-- 获得卡牌层
function getBattleReportLayer (isWin,copy_id,base_id,level,soulNumber,itemArray,silverNumber,expNumber,copyType,heroArray)
    m_soulNumber = soulNumber
    m_silverNumber = silverNumber
    m_expNumber = expNumber
    m_expChangeNumber = m_expNumber
    require "script/ui/main/MainScene"
    
    local m_layerSize = CCSizeMake(600,640)
    
    local scale = CCDirector:sharedDirector():getWinSize().height/960
    --local scale = MainScene.elementScale
    
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
    m_reportInfoLayer:setPosition((CCDirector:sharedDirector():getWinSize().width-m_layerSize.width*scale)/2,CCDirector:sharedDirector():getWinSize().height*0.72-m_layerSize.height*scale)
    m_reportLayer:addChild(m_reportInfoLayer)
    m_isWin = isWin
    
    require "script/model/user/UserModel"
    
    --播放胜负动画
    
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
    
    else
        backAnimSprite = nil
        animSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushibai"), -1,CCString:create(""));
    end
    animSprite:retain()
    animSprite:setAnchorPoint(ccp(0.5, 0.5));
    animSprite:setPosition(CCDirector:sharedDirector():getWinSize().width/2,CCDirector:sharedDirector():getWinSize().height*0.74);
    animSprite:setScale(scale)
    m_reportLayer:addChild(animSprite);
    animSprite:release()
    
    local delegate = BTAnimationEventDelegate:create()
    --delegate:retain()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    animSprite:setDelegate(delegate)
    
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
    
    local titleBg = CCSprite:create(IMG_PATH .. "title_bg.png")
    titleBg:setAnchorPoint(ccp(0.5,0.5))
    titleBg:setPosition(300,633.5)
    m_reportBg:addChild(titleBg)
    
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
    end
    local displayName = CCLabelTTF:create(cp.name,g_sFontName,35)
    --local displayName = CCRenderLabel:create(cp.name, g_sFontName, 35, 3, ccc3( 0x36, 0x00, 0x03), type_stroke)
    --displayName:setSourceAndTargetColor(ccc3( 0xff, 0xf0, 0x49), ccc3( 0xff, 0xa2, 0x00));
    --displayName:setPosition((titleBg:getContentSize().width-displayName:getContentSize().width)/2,titleBg:getContentSize().height*0.85)
    displayName:setColor(ccc3( 0xff, 0xf0, 0x49))
    displayName:setAnchorPoint(ccp(0.5,0.5))
    displayName:setPosition((titleBg:getContentSize().width)/2,titleBg:getContentSize().height*0.5)
    titleBg:addChild(displayName)
    
    require "db/DB_Stronghold"
    local sh = DB_Stronghold.getDataById(base_id)
    --local shName = CCRenderLabel:create(sh.name, g_sFontName, 30, 2, ccc3( 0xff, 0xd5, 0x94), type_stroke)
    local shName = CCLabelTTF:create(sh.name, g_sFontName, 30)
    shName:setColor(ccc3( 0x78, 0x25, 0x00))
    --shName:setSourceAndTargetColor(ccc3( 0x78, 0x25, 0x00), ccc3( 0x77, 0x25, 0x00));
    shName:setAnchorPoint(ccp(0.5,0.5))
    shName:setPosition(m_layerSize.width*0.5,m_layerSize.height*0.905)
    m_reportBg:addChild(shName)
    
    ---[[
    --修改缓存信息
    if(m_isWin) then
        UserModel.addExpValue(tonumber(expNumber),"battlereportlee")
        UserModel.changeSilverNumber(tonumber(silverNumber))
        UserModel.changeHeroSoulNumber(tonumber(soulNumber))
        --UserModel.addExpValue(expNumber)
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
    if(level==0) then
        costEnegy = 0
    else
        costEnegy = sh["cost_energy_" .. levelStr]
    end
    
    if(costEnegy==nil)then
       costEnegy = 0
    end
    --print("-------------- costEnegy:",costEnegy,UserModel.getEnergyValue())
    UserModel.changeEnergyValue(-1*tonumber(costEnegy))
    --print("-------------- UserModel.getEnergyValue:",UserModel.getEnergyValue())
    
    local moneyBg = CCScale9Sprite:create(CCRectMake(20, 20, 10, 10),"images/common/labelbg_white.png")
    moneyBg:setContentSize(CCSizeMake(380,40))
    moneyBg:setAnchorPoint(ccp(0.5,0.5))
    moneyBg:setPosition(m_layerSize.width*0.5,m_layerSize.height*0.84)
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
    soulBg:setPosition(m_layerSize.width*0.5,m_layerSize.height*0.765)
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
    expBg:setPosition(m_layerSize.width*0.5,m_layerSize.height*0.69)
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
    
    local expAction = schedule(m_reportLayer,updateExpNumber,1/60)
    expAction:setTag(10001)
    
    
    local levelIcon = CCSprite:create("images/common/lv.png")
    levelIcon:setAnchorPoint(ccp(0.5,0.5))
    levelIcon:setPosition(m_layerSize.width*0.3,m_layerSize.height*0.62)
    m_reportBg:addChild(levelIcon)
    
    local levelLabel = CCLabelTTF:create("" .. UserModel.getHeroLevel(),g_sFontName,24)
    levelLabel:setAnchorPoint(ccp(0.5,0.5))
    levelLabel:setPosition(m_layerSize.width*0.37,m_layerSize.height*0.62)
    levelLabel:setColor(ccc3(0xff,0xf6,0x00))
    m_reportBg:addChild(levelLabel)
    
    local expBarBg = CCSprite:create("images/main/progress_black.png")
    expBarBg:setAnchorPoint(ccp(0,0.5))
    expBarBg:setPosition(m_layerSize.width*0.47,m_layerSize.height*0.62)
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
    
    
    local commitButton = CCMenuItemImage:create("images/battle/btn/btn_commit_n.png","images/battle/btn/btn_commit_h.png")
    commitButton:setAnchorPoint(ccp(0.5,0.5))
    commitButton:setPosition(ccp(m_layerSize.width*0.5,m_layerSize.height*0.1))
    commitButton:registerScriptTapHandler(BattleReportLayerLee.commitClick)
    
    --[[
    local replayButton = CCMenuItemImage:create("images/battle/btn/btn_replay_n.png","images/battle/btn/btn_replay_h.png")
    replayButton:setAnchorPoint(ccp(0.5,0.5))
    replayButton:setPosition(ccp(m_layerSize.width*0.7,m_layerSize.height*0.1))
    replayButton:registerScriptTapHandler(BattleReportLayerLee.replayClick)
    --]]
    
    local menu = CCMenu:create()
    menu:setAnchorPoint(ccp(0,0))
    menu:setPosition(0,0)
    menu:addChild(commitButton)
    --menu:addChild(replayButton)
    m_reportBg:addChild(menu)
    menu:setTouchPriority(-505)
    
    local m_itemBg = CCScale9Sprite:create(CCRectMake(20, 20, 10, 10),"images/copy/fort/textbg.png")
    m_itemBg:setContentSize(CCSizeMake(550,270))
    m_itemBg:setAnchorPoint(ccp(0,0))
    m_itemBg:setPosition(25,105)
    m_reportBg:addChild(m_itemBg)
    
    local itemBgTitle = CCLabelTTF:create(GetLocalizeStringBy("key_2882"),g_sFontName,30)
    itemBgTitle:setAnchorPoint(ccp(0.5,0.5))
    itemBgTitle:setPosition(m_itemBg:getContentSize().width*0.5,m_itemBg:getContentSize().height*0.91)
    itemBgTitle:setColor(ccc3(0x78,0x25,0x00))
    m_itemBg:addChild(itemBgTitle)
    
    if(m_isWin) then
        
        local scrollView = CCScrollView:create()
        scrollView:setTouchPriority(-504)
        scrollView:setContentSize(CCSizeMake(520,210))
        scrollView:setViewSize(CCSizeMake(520,210))
        -- 设置弹性属性
        scrollView:setBounceable(true)
        -- 垂直方向滑动
        scrollView:setDirection(kCCScrollViewDirectionVertical)
        scrollView:setAnchorPoint(ccp(0,0))
        scrollView:setPosition(ccp(m_itemBg:getContentSize().width*0.05,m_itemBg:getContentSize().height*0.05))
        m_itemBg:addChild(scrollView)
        
        local rewardCount = #itemArray + #heroArray
        
        local startX = m_itemBg:getContentSize().width*0.15-scrollView:getPositionX()
        local startY = m_itemBg:getContentSize().height*0.63-scrollView:getPositionY()
        
        local intervalX = m_itemBg:getContentSize().width*0.23
        local intervalY = m_itemBg:getContentSize().height*0.4
        
        if(math.floor(rewardCount/4)>2)then
            startY = startY + (math.floor(rewardCount/4)-2)*intervalY
        end
        
        local rewardLayer = CCLayer:create()
        rewardLayer:setContentSize(CCSizeMake(520,startY+intervalY*0.8))
        rewardLayer:setAnchorPoint(ccp(0,0))
        rewardLayer:setPosition(0,0)
        scrollView:setContainer(rewardLayer)
        
        require "script/ui/item/ItemSprite"
        for i=1,#itemArray do
            --local item = CCSprite:create("images/item/bg/itembg_" .. (i%6+1) .. ".png")
            local item = ItemSprite.getItemSpriteById(tonumber(itemArray[i].item_template_id))
            item:setAnchorPoint(ccp(0.5,0.5))
            item:setPosition(startX+intervalX*math.floor((i-1)%4),startY-intervalY*math.floor((i-1)/4))
            rewardLayer:addChild(item)
            
        end
        heroArray = heroArray==nil and {} or heroArray
        require "script/ui/hero/HeroPublicCC"
        for i=1,#heroArray do
            --print("battle report hero array:",heroArray[i].htid)
            local item = HeroPublicCC.getCMISHeadIconByHtid(tonumber(heroArray[i].htid))
            item:setAnchorPoint(ccp(0.5,0.5))
            item:setPosition(startX+intervalX*math.floor(((i+#itemArray)-1)%4),startY-intervalY*math.floor(((i+#itemArray)-1)/4))
            rewardLayer:addChild(item)
        end
    end
    
    local barAction = schedule(m_reportLayer,updateExpLine,1/30)
    barAction:setTag(10004)
    
    --m_reportLayer:setScale(scale)
    m_reportLayer:setTouchEnabled(true)
    m_reportLayer:registerScriptTouchHandler(cardLayerTouch,false,-500,true)
    
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
