-- Filename: UpgradeLayer.lua
-- Author: zhz
-- Date: 2013-09-12
-- Purpose: 英雄等级升级时触发的事件： 弹出面板和特效


module ("UpgradeLayer", package.seeall)


require "script/model/user/UserModel"
require "script/ui/formation/FormationUtil"
require "script/audio/AudioUtil"
-------- 注册通知 --------


local _bgLayer 				     -- 背景
local IMG_PATH = "images/upgrade/"
local _count                    -- 显示几个白色的横幅

local _ksTagRob =2001           -- 夺宝
local _ksTagContest=2002        -- 比武
local _ksTagAlth=2003           -- 竞技

local function init( )
	_bgLayer = nil
    _count =2
end

-- layer 的回调函数
local function layerToucCb(eventType, x, y)
	return true
end
-- 确定按钮的回调函数
local function sureBtnCb()
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer=nil
end


function createLayer( )
	init()
	-- 特效
	createEffect()

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,166))
	  -- 设置灰色layer的优先级
    _bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(layerToucCb,false,-5550,true)

    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,10011)

    -- 判断夺宝的功能节点开启
    if(DataCache.getSwitchNodeState(ksSwitchRobTreasure, false)) then
         createUIAfterRob()
    else 
        createUIBeforeRob()
    end
end

-- 创建白色的背景
function createWhiteBg( )
    local levelBg = CCScale9Sprite:create("images/common/labelbg_white.png")
    levelBg:setContentSize( CCSizeMake(420,48))
    return levelBg
end

-- 夺宝功能节点开启后的UI
function createUIAfterRob(  )
    local myScale = MainScene.elementScale
    local mySize = CCSizeMake(517,705)

    local upgradeBg = CCScale9Sprite:create("images/common/viewbg1.png")
    upgradeBg:setContentSize(mySize)
    upgradeBg:setScale(myScale)
    upgradeBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    upgradeBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(upgradeBg)

    -- 确定按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-5551)
    upgradeBg:addChild(menu)

    local sureBtn = CCMenuItemImage:create("images/common/btn/btn_green_n.png", "images/common/btn/btn_green_h.png")
    sureBtn:setPosition(ccp(upgradeBg:getContentSize().width*0.5, 25))
    sureBtn:setAnchorPoint(ccp(0.5,0))
    sureBtn:registerScriptTapHandler(sureBtnCb)
    menu:addChild(sureBtn)
    local sureLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1465"), g_sFontPangWa, 35, 2,ccc3(0x00,0x00,0x00), type_stroke)
    sureLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    sureLabel:setPosition(ccp(sureBtn:getContentSize().width*0.5,sureBtn:getContentSize().height*0.5))
    sureLabel:setAnchorPoint(ccp(0.5,0.5))
    sureBtn:addChild(sureLabel)

    -- 头部
    local ribbonSp = CCSprite:create(IMG_PATH .. "ribbon.png")
    ribbonSp:setPosition(ccp( upgradeBg:getContentSize().width*0.5,upgradeBg:getContentSize().height))
    ribbonSp:setAnchorPoint(ccp(0.5,0.85))
    upgradeBg:addChild(ribbonSp)

    local starSp = CCSprite:create(IMG_PATH .. "star.png")
    starSp:setPosition(ccp( ribbonSp:getContentSize().width*0.5,95))
    starSp:setAnchorPoint(ccp(0.5,0))
    ribbonSp:addChild(starSp)

     local upgradeSp = CCSprite:create(IMG_PATH .. "upgrade_head.png")
    upgradeSp:setPosition(ccp(ribbonSp:getContentSize().width*0.5,95))
    upgradeSp:setAnchorPoint(ccp(0.5,0))
    ribbonSp:addChild(upgradeSp)

    local leftWidth =160
    local middleWitdh =225
    local arrowWidth = 230
    local height = upgradeBg:getContentSize().height - 90
    -- 等级的背景
    local levelBg = createWhiteBg()
    levelBg:setPosition(ccp(upgradeBg:getContentSize().width/2,height))
    levelBg:setAnchorPoint(ccp(0.5,1))
    upgradeBg:addChild(levelBg) 
   
    local  levelContent={}
    levelContent[1]=CCRenderLabel:create(GetLocalizeStringBy("key_1355"), g_sFontPangWa, 20, 1,ccc3(0x00,0x00,0x00), type_stroke)
    levelContent[1]:setColor(ccc3(0xff,0xe4,0x00))
    levelContent[1]:setPosition(ccp(leftWidth,levelBg:getContentSize().height*0.5))
    levelContent[1]:setAnchorPoint(ccp(1,0.5))
    levelBg:addChild(levelContent[1])

    levelContent[2]= CCRenderLabel:create("Lv." .. UserModel.getHeroLevel()-1,g_sFontPangWa,20, 1,ccc3(0x00,0x00,0x00), type_stroke)
    levelContent[2]:setColor(ccc3(0x98,0xff,0xf2))
    levelContent[2]:setPosition(ccp(middleWitdh,levelBg:getContentSize().height*0.5))
    levelContent[2]:setAnchorPoint(ccp(1,0.5))
    levelBg:addChild(levelContent[2])

    levelContent[3]= CCSprite:create("images/common/arrow.png")
    levelContent[3]:setPosition(ccp(arrowWidth,levelBg:getContentSize().height*0.5))
    levelContent[3]:setAnchorPoint(ccp(0,0.5))
    levelBg:addChild(levelContent[3])

    levelContent[4]= CCRenderLabel:create("Lv." .. UserModel.getHeroLevel(),g_sFontPangWa,30, 1,ccc3(0x00,0x00,0x00), type_stroke)
    levelContent[4]:setColor(ccc3(0xff,0x42,0x00))
    levelContent[4]:setPosition(ccp(286,levelBg:getContentSize().height*0.5))
    levelContent[4]:setAnchorPoint(ccp(0,0.5))
    levelBg:addChild(levelContent[4])

    -- 耐力的背景
    height = height - 5- levelBg:getContentSize().height
    local stainBg = createWhiteBg()
    stainBg:setPosition(ccp(upgradeBg:getContentSize().width/2,height))
    stainBg:setAnchorPoint(ccp(0.5,1))
    upgradeBg:addChild(stainBg)

    local  stainContent={}
    stainContent[1]= CCRenderLabel:create(GetLocalizeStringBy("key_2268"),g_sFontPangWa, 20, 1,ccc3(0x00,0x00,0x00), type_stroke )
    stainContent[1]:setColor(ccc3(0xff,0x23,0xbe))
    stainContent[1]:setPosition(ccp(leftWidth,stainBg:getContentSize().height*0.5))
    stainContent[1]:setAnchorPoint(ccp(1,0.5))
    stainBg:addChild(stainContent[1])

    stainContent[2]= CCRenderLabel:create("" .. UserModel.getStaminaNumber() ,g_sFontPangWa, 20, 1,ccc3(0x00,0x00,0x00), type_stroke )
    stainContent[2]:setColor(ccc3(0xff,0xf6,0x00))
    stainContent[2]:setPosition(ccp(middleWitdh -1 ,stainBg:getContentSize().height*0.5))
    stainContent[2]:setAnchorPoint(ccp(1,0.5))
    stainBg:addChild(stainContent[2])

    stainContent[3]= CCSprite:create("images/common/arrow.png")
    stainContent[3]:setPosition(ccp(arrowWidth,stainBg:getContentSize().height*0.5))
    stainContent[3]:setAnchorPoint(ccp(0,0.5))
    stainBg:addChild(stainContent[3])

    -- -- 判断耐力是否已满
    -- if(UserModel.getStaminaNumber() >UserModel.getMaxStaminaNumber()) then
    --     -- stainContent[4]:setString("" .. UserModel.getStaminaNumber())
    --     stainContent[4]= CCRenderLabel:create("" .. UserModel.getStaminaNumber() ,g_sFontPangWa, 20, 1,ccc3(0x00,0x00,0x00), type_stroke )
    -- else
    local userStain = UserModel.getStaminaNumber()+20
    stainContent[4]= CCRenderLabel:create("" .. userStain ,g_sFontPangWa, 20, 1,ccc3(0x00,0x00,0x00), type_stroke )
    UserModel.setStaminaTime(BTUtil:getSvrTimeInterval())
    UserModel.setStainValue(userStain)
    -- end
   
    stainContent[4]:setColor(ccc3(0xff,0xf6,0x00))
    stainContent[4]:setPosition(ccp(282 ,stainBg:getContentSize().height*0.5))
    stainContent[4]:setAnchorPoint(ccp(0,0.5))
    stainBg:addChild(stainContent[4])
 
    -- 上阵武将
    height = height - 5- levelBg:getContentSize().height
    local heroNumBg = createWhiteBg()
    heroNumBg:setPosition(ccp(upgradeBg:getContentSize().width/2,height))
    heroNumBg:setAnchorPoint(ccp(0.5,1))
    upgradeBg:addChild(heroNumBg)

    local heroLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3262")  ,g_sFontPangWa, 20, 1,ccc3(0x00,0x00,0x00), type_stroke )
    heroLabel:setColor(ccc3(0xff,0xe4,0x00))
    if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" )then
        heroLabel:setPosition(ccp(260,heroNumBg:getContentSize().height/2))
    else
        heroLabel:setPosition(ccp(leftWidth,heroNumBg:getContentSize().height/2))
    end
    heroLabel:setAnchorPoint(ccp(1,0.5))
    heroNumBg:addChild(heroLabel)

    local heroNumLabel = CCRenderLabel:create("" .. FormationUtil.getFormationOpenedNum()  ,g_sFontPangWa, 20, 1,ccc3(0x00,0x00,0x00), type_stroke )
    heroNumLabel:setColor(ccc3(0xff,0xe4,0x00))
    if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" )then
        heroNumLabel:setPosition(ccp(325,heroNumBg:getContentSize().height/2))
    else
        heroNumLabel:setPosition(ccp(middleWitdh,heroNumBg:getContentSize().height/2))
    end
    heroNumLabel:setAnchorPoint(ccp(1,0.5))
    heroNumBg:addChild(heroNumLabel)

    -- 升级奖励
    height = height - 5- levelBg:getContentSize().height
    local rewardBg = createWhiteBg()
    rewardBg:setPosition(ccp(upgradeBg:getContentSize().width/2,height))
    rewardBg:setAnchorPoint(ccp(0.5,1))
    upgradeBg:addChild(rewardBg)

    local rewardContent ={}
    rewardContent[1]= CCRenderLabel:create(GetLocalizeStringBy("key_2823"),g_sFontPangWa, 20, 1,ccc3(0x00,0x00,0x00), type_stroke )
    rewardContent[1]:setColor(ccc3(0xff,0xe4,0x00))
    rewardContent[1]:setPosition(ccp(leftWidth,rewardBg:getContentSize().height*0.5))
    rewardContent[1]:setAnchorPoint(ccp(1,0.5))
    rewardBg:addChild(rewardContent[1])

    rewardContent[2]= CCSprite:create("images/common/gold.png")
    rewardContent[2]:setPosition(ccp(middleWitdh+1,rewardBg:getContentSize().height*0.5))
    rewardContent[2]:setAnchorPoint(ccp(1,0.5))
    rewardBg:addChild(rewardContent[2])

    rewardContent[3]= CCRenderLabel:create("10",g_sFontPangWa, 20, 1,ccc3(0x00,0x00,0x00), type_stroke )
    rewardContent[3]:setColor(ccc3(0xff,0xe4,0x00))
    local width = rewardContent[2]:getContentSize().width+ rewardContent[2]:getPositionX()
    rewardContent[3]:setPosition(ccp( width,rewardBg:getContentSize().height*0.5))
    rewardContent[3]:setAnchorPoint(ccp(1,0.5))
    rewardBg:addChild(rewardContent[3])

    -- 花纹：
    height = height - 10 - levelBg:getContentSize().height
    local alertContent = {}
    alertContent[1]=  CCRenderLabel:create(GetLocalizeStringBy("key_2021") ,g_sFontPangWa, 30, 1,ccc3(0x00,0x00,0x00), type_stroke )
    alertContent[1]:setColor(ccc3(0xf9,0x59,0xff))
    alertContent[2]=  CCRenderLabel:create("+20" ,g_sFontPangWa, 30, 1,ccc3(0x00,0x00,0x00), type_stroke )
    alertContent[2]:setColor(ccc3(0x00,0xff,0x18))

    local alertNode =  BaseUI.createHorizontalNode(alertContent)
    alertNode:setPosition(ccp(upgradeBg:getContentSize().width/2,height+4 ))
    alertNode:setAnchorPoint(ccp(0.5,1))
    upgradeBg:addChild(alertNode)
 
    local flowerBg= CCSprite:create("images/copy/herofrag/cutFlower.png")
    flowerBg:setPosition(upgradeBg:getContentSize().width/2,height)
    flowerBg:setScale(0.8)
    flowerBg:setAnchorPoint(ccp(0.5,1))
    upgradeBg:addChild(flowerBg)

    createButtons(upgradeBg)

    
end

-- 创建按钮
function createButtons(upgradeBg)
    local btnNote = { 
            {   txt = GetLocalizeStringBy("key_2572"), note = GetLocalizeStringBy("key_1471") ,  tag= _ksTagRob }  ,
            {   txt = GetLocalizeStringBy("key_2963"), note = GetLocalizeStringBy("key_3000")  ,tag= _ksTagContest }  ,
            {   txt = GetLocalizeStringBy("key_2918"), note = GetLocalizeStringBy("key_2795") ,tag= _ksTagAlth }  ,
        }

    -- 按钮的背景
    local buttonBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    buttonBg:setContentSize(CCSizeMake(463,258))
    buttonBg:setPosition(ccp(upgradeBg:getContentSize().width/2,95))
    buttonBg:setAnchorPoint(ccp(0.5,0))
    upgradeBg:addChild(buttonBg)

    -- line  
    for i=1,2 do
        local lineSp = CCScale9Sprite:create("images/common/line02.png")
        lineSp:setContentSize(CCSizeMake(446,4))
        lineSp:setPosition(ccp(buttonBg:getContentSize().width*0.5,81*i))
        lineSp:setAnchorPoint(ccp(0.5,0))
        buttonBg:addChild(lineSp)

    end

    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(-5555)
    buttonBg:addChild(menuBar)

    --去夺宝按钮按钮
    for i=1,3 do
        local itemLabel= CCRenderLabel:create( btnNote[i].txt , g_sFontName, 25, 1,ccc3(0x00,0x00,0x00), type_stroke)
        itemLabel:setPosition(22,28+(i-1)*81)
        itemLabel:setAnchorPoint(ccp(0,0))
        itemLabel:setColor(ccc3(0xff,0xe4,0x00))
        buttonBg:addChild(itemLabel)

        --抢夺按钮
        local item =  LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(130, 64), btnNote[i].note ,ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
        item:setPosition(318,17 + (i-1)*81)
        --item:setEnabled(false)
        item:registerScriptTapHandler(menuAction)
        menuBar:addChild(item,1, btnNote[i].tag )


        -- if( item:getTag() == _ksTagRob) then
        --     if( DataCache.getSwitchNodeState( ksSwitchRobTreasure ) ) then
        --         if(SwitchOpen.isHaveNotification == false or NewGuide.guideClass == ksGuideClose) then
        --               item:setEnabled(true)
        --         end
        --     end

        -- elseif(item:getTag() == _ksTagContest) then
        --       print("biwu ")
        --    if(DataCache.getSwitchNodeState(ksSwitchContest)) then
        --        if(SwitchOpen.isHaveNotification == false or NewGuide.guideClass == ksGuideClose) then
        --            item:setEnabled(true)
        --         end
        --     end

        -- elseif(item:getTag() = _ksTagAlth) then
        --     print("jingji ")
        --     if(DataCache.getSwitchNodeState(ksSwitchArena)) then
        --         if(SwitchOpen.isHaveNotification == false or NewGuide.guideClass == ksGuideClose) then
        --             item:setEnabled(true)
        --         end
        --     end

        -- end

    end

end

local function closeBattleLayer(  )
    if(SwitchOpen.isFight) then
        require "script/battle/BattleLayer"
        BattleLayer.closeLayer()
    end
end

-- 按钮的回调函数
function menuAction( tag,menuItem )

    sureBtnCb()
    closeBattleLayer()
    require "script/ui/switch/SwitchOpen"
    require "script/ui/item/ItemUtil"
    require "script/guide/NewGuide"

    if(ItemUtil.isBagFull() == true )then
        return
    end
    -- 判断武将满了
    require "script/ui/hero/HeroPublicUI"
    if HeroPublicUI.showHeroIsLimitedUI() then
        return
    end

    require "script/ui/talk/talkLayer"
    TalkLayer.stopCurrentTalk()


    
    if(tag == _ksTagRob) then
        print("rob")
        if( DataCache.getSwitchNodeState( ksSwitchRobTreasure ) ) then
            if(SwitchOpen.isHaveNotification == false or NewGuide.guideClass == ksGuideClose) then

                require "script/ui/treasure/TreasureMainView"
                local treasureLayer = TreasureMainView.create()
                MainScene.changeLayer(treasureLayer,"treasureLayer")
            end
        end

    elseif(tag==_ksTagContest) then
        print("biwu ")
       if(DataCache.getSwitchNodeState(ksSwitchContest)) then
           if(SwitchOpen.isHaveNotification == false or NewGuide.guideClass == ksGuideClose) then
                require "script/ui/match/MatchLayer"
                local matchLayer = MatchLayer.createMatchLayer()
                MainScene.changeLayer(matchLayer, "matchLayer")
            end
        end
    elseif(tag== _ksTagAlth) then
        print("jingji ")
        if(DataCache.getSwitchNodeState(ksSwitchArena)) then
            if(SwitchOpen.isHaveNotification == false or NewGuide.guideClass == ksGuideClose) then
                require "script/ui/arena/ArenaLayer"
                local arenaLayer = ArenaLayer.createArenaLayer()
                MainScene.changeLayer(arenaLayer, "arenaLayer")
            end
        end
    end
    
end

-- 夺宝功能节点开启前的UI
function createUIBeforeRob( )
    local myScale = MainScene.elementScale
    local mySize = CCSizeMake(517,387)

    local upgradeBg = CCSprite:create(IMG_PATH .. "upgrade_bg.png")
    upgradeBg:setScale(myScale)
    upgradeBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    upgradeBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(upgradeBg)

    -- 确定按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-5551)
    upgradeBg:addChild(menu)

    local sureBtn = CCMenuItemImage:create("images/common/btn/btn_green_n.png", "images/common/btn/btn_green_h.png")
    sureBtn:setPosition(ccp(upgradeBg:getContentSize().width*0.5, 30))
    sureBtn:setAnchorPoint(ccp(0.5,0))
    sureBtn:registerScriptTapHandler(sureBtnCb)
    menu:addChild(sureBtn)
    local sureLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1465"), g_sFontPangWa, 35, 2,ccc3(0x00,0x00,0x00), type_stroke)
    sureLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    sureLabel:setPosition(ccp(sureBtn:getContentSize().width*0.5,sureBtn:getContentSize().height*0.5))
    sureLabel:setAnchorPoint(ccp(0.5,0.5))
    sureBtn:addChild(sureLabel)

    -- 头部
    local ribbonSp = CCSprite:create(IMG_PATH .. "ribbon.png")
    ribbonSp:setPosition(ccp( upgradeBg:getContentSize().width*0.5,235))
    ribbonSp:setAnchorPoint(ccp(0.5,0))
    upgradeBg:addChild(ribbonSp)

    local starSp = CCSprite:create(IMG_PATH .. "star.png")
    starSp:setPosition(ccp( upgradeBg:getContentSize().width*0.5,330))
    starSp:setAnchorPoint(ccp(0.5,0))
    upgradeBg:addChild(starSp)

     local upgradeSp = CCSprite:create(IMG_PATH .. "upgrade_head.png")
    upgradeSp:setPosition(ccp( upgradeBg:getContentSize().width*0.5,330))
    upgradeSp:setAnchorPoint(ccp(0.5,0))
    upgradeBg:addChild(upgradeSp)

    -- 升到的等级
    local levelBg = CCScale9Sprite:create("images/common/labelbg_white.png")
    levelBg:setContentSize( CCSizeMake(420,48))
    levelBg:setPosition(ccp(upgradeBg:getContentSize().width*0.5,255))
    levelBg:setAnchorPoint(ccp(0.5,0))
    upgradeBg:addChild(levelBg)

    local levelLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3408")   ,g_sFontPangWa, 30, 2,ccc3(0x00,0x00,0x00), type_stroke )
    levelLabel:setColor(ccc3(0xff,0xe4,0x00))
    levelLabel:setPosition(ccp(65,levelBg:getContentSize().height*0.5 ))
    levelLabel:setAnchorPoint(ccp(0,0.5))
    levelBg:addChild(levelLabel)

    -- lv Sprite
    local levelSprite = CCSprite:create("images/common/lv.png")
    levelSprite:setPosition(ccp(292, levelBg:getContentSize().height*0.5))
    levelSprite:setAnchorPoint(ccp(0,0.5))
    levelBg:addChild(levelSprite)
    local  userInfo = UserModel.getUserInfo()
     local levelLabel = CCRenderLabel:create("" .. userInfo.level ,g_sFontName, 24, 1,ccc3(0x00,0x00,0x00), type_stroke )
     levelLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
     levelLabel:setAnchorPoint(ccp(0,0.5))
     levelLabel:setPosition(ccp(320+ levelLabel:getContentSize().width, levelBg:getContentSize().height*0.5  ))
     levelBg:addChild(levelLabel)

    -- 上阵武将数
    
    local heroLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1364") .. FormationUtil.getFormationOpenedNum()  ,g_sFontPangWa, 24, 2,ccc3(0x00,0x00,0x00), type_stroke )
    heroLabel:setColor(ccc3(0xff,0xff,0xff))
    heroLabel:setPosition(ccp(upgradeBg:getContentSize().width*0.5,196))
    heroLabel:setAnchorPoint(ccp(0.5,0))
    upgradeBg:addChild(heroLabel)

    -- 细线
    local lineSp = CCScale9Sprite:create("images/common/line01.png")
    lineSp:setContentSize(CCSizeMake(450,4))
    lineSp:setPosition(ccp(upgradeBg:getContentSize().width*0.5,171))
    lineSp:setAnchorPoint(ccp(0.5,0))
    upgradeBg:addChild(lineSp)

    local rewardLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2344") ,g_sFontPangWa, 24, 2,ccc3(0x00,0x00,0x00), type_stroke )
    rewardLabel:setColor(ccc3(0xff,0xe4,0x00))
    rewardLabel:setPosition(ccp(145,152))
    upgradeBg:addChild(rewardLabel)

    local goldSprite = CCSprite:create("images/common/gold.png")
    local width = rewardLabel:getPositionX()+ rewardLabel:getContentSize().width --+ 10
    local height = rewardLabel:getPositionY() - rewardLabel:getContentSize().height
    goldSprite:setPosition(ccp(width,height))
    upgradeBg:addChild(goldSprite)

    local goldLabel =  CCRenderLabel:create("10" ,g_sFontName, 24, 1,ccc3(0x00,0x00,0x00), type_stroke )
    goldLabel:setColor(ccc3(0xff,0xe4,0x00))
    local width = width + goldSprite:getContentSize().width + 5
    goldLabel:setPosition(width, 142)
    upgradeBg:addChild(goldLabel)
    -- UserModel.addGoldNumber(10)

end



local function effectLayerToucCb(eventType, x, y)
    return true
end 




--  升级特效
function createEffect( )
    local _effectLayer = CCLayer:create()
    CCDirector:sharedDirector():getRunningScene():addChild(_effectLayer,11011)
    _effectLayer:registerScriptTouchHandler(effectLayerToucCb,false,-6000,true)
    _effectLayer:setTouchEnabled(true)

	local leveUpEffect = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/levelup/shengji"),-1,CCString:create(""))
	leveUpEffect:setScale(g_fElementScaleRatio)
    if(file_exists("images/upgrade/shengji/shengji.mp3")) then
        require "script/audio/AudioUtil"
        AudioUtil.playEffect("images/upgrade/shengji/shengji.mp3")
    end
	leveUpEffect:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*480/960))
	leveUpEffect:setFPS_interval(1/60.0)
    -- leveUpEffect:registerAnimationEvent(function ( eventType,layerSprite )
    --     print("eventType = ",eventType)
    --     if(eventType == "Ended") then
    --         layerSprite:removeFromParentAndCleanup(true)
    --         layerSprite = nil
    --         _effectLayer:removeFromParentAndCleanup(true)
    --         _effectLayer = nil
    --     end
    -- end)

    local animationEnd = function(actionName,xmlSprite)
    print("actionName  is :", actionName)
    print("xmlSprite  is : ",xmlSprite )
        leveUpEffect:retain()
        leveUpEffect:autorelease()
        leveUpEffect:removeFromParentAndCleanup(true)
        leveUpEffect = nil
        _effectLayer:removeFromParentAndCleanup(true)
        _effectLayer = nil
    end

     local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
    -- delegate:registerLayerChangedHandler(animationFrameChanged)
    leveUpEffect:setDelegate(delegate)

   _effectLayer:addChild(leveUpEffect, 1202)

end


