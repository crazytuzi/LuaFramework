-- FileName: BattleResultDialog.lua 
-- Author: llp
-- Date: 16-4-18
-- Purpose: 

require "script/utils/BaseUI"

module("BattleResultDialog", package.seeall)

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
local _isSigle               = nil
local _isWin                 = nil
local _teamData = {}
local spriteTable = {"images/horse/help.png","images/horse/self.png"}
-- 初始化
function init( ... )
    _teamData = {}
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
    _isWin                 = nil
    _isSigle               = nil
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

function createCell( cellValues,pIndex )
    -- body
    local tCell = CCTableViewCell:create()
    if(cellValues.level==nil)then
        return tCell
    end
    if(_isSigle == nil)then

    elseif(_isSigle == true )then
        pIndex = 2
    elseif(_isSigle == false)then
        pIndex = 1
    end

    local nameStr= cellValues.uname
    local htid = tonumber(cellValues.htid)
    local level = cellValues.level
    local guildName= cellValues.guild_name or nil

    local dressId= nil
    local uid= tonumber(cellValues.uid)
    if(cellValues.dress and cellValues.dress[1]) then
        dressId = tonumber(cellValues.dress[1]) 
    end

    -- -- 头像
    local vip = cellValues.vip or 0
    local headIcon = HeroUtil.getHeroIconByHTID(htid, dressId, nil, vip) 
    headIcon:setPosition(9,57)
    tCell:addChild(headIcon)

    local sprite = CCSprite:create(spriteTable[pIndex])
          sprite:setAnchorPoint(ccp(0.1,0.5))
          sprite:setPosition(ccp(0,headIcon:getContentSize().height))
    headIcon:addChild(sprite)
    
    -- -- 名字
    local nameLabel = CCRenderLabel:create( nameStr , g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setPosition(139,122)
    nameLabel:setAnchorPoint(ccp(0,0))
    tCell:addChild(nameLabel)

    -- 军团名
    if(guildName) then
        local guildNameLabel = CCRenderLabel:create( " [" .. guildName .. "]" , g_sFontName, 24,1, ccc3(0x00,0x00,0x00), type_stroke)
        guildNameLabel:setColor(ccc3(0xff,0xf6,0x00) )
        guildNameLabel:setPosition(ccp(139, 81))
        guildNameLabel:setAnchorPoint(ccp(0,0))
        tCell:addChild(guildNameLabel)
    end

    -- 等级
    local lvSp= CCSprite:create("images/common/lv.png")
    local levelLabel = CCRenderLabel:create(tostring(level),  g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    levelLabel:setColor(ccc3(0xff,0xf6,0x00))
    local levelNode =BaseUI.createHorizontalNode({lvSp,levelLabel})
    levelNode:setPosition(headIcon:getContentSize().width/2 ,0)
    levelNode:setAnchorPoint(ccp(0.5,1))
    headIcon:addChild(levelNode)

    local bloodLable = CCLabelTTF:create(GetLocalizeStringBy("llp_417"),g_sFontName,25)
          bloodLable:setAnchorPoint(ccp(0,0))
          bloodLable:setPosition(ccp(139,41))
    tCell:addChild(bloodLable)

    local expBarBg = CCSprite:create("images/main/progress_black.png")
    expBarBg:setAnchorPoint(ccp(0,0.5))
    expBarBg:setPosition(bloodLable:getContentSize().width,bloodLable:getContentSize().height*0.5)
    bloodLable:addChild(expBarBg)

    require "db/DB_Level_up_exp"
    local db_level = DB_Level_up_exp.getDataById(2)
    local percent = cellValues.resetHpPrecent/100
    expBar = CCSprite:create("images/main/progress_blue.png")
    expBar:setAnchorPoint(ccp(0,0.5))
    expBar:setPosition(0,expBarBg:getContentSize().height*0.5)
    expBar:setTextureRect(CCRectMake(0,0,expBar:getContentSize().width*percent,expBar:getContentSize().height))
    expBarBg:addChild(expBar)

    local percentForString = percent*100
    local percentLabel = CCLabelTTF:create(percentForString.."/100",g_sFontName,22)
          percentLabel:setAnchorPoint(ccp(0.5,0.5))
          percentLabel:setPosition(ccp(expBarBg:getContentSize().width*0.5,expBarBg:getContentSize().height*0.5))
    expBarBg:addChild(percentLabel)
    return tCell
end
--[[
    @des    : 创建结算面板
    @param  : appraisal 战斗评价   enemyDataTab 对手信息   CallFun 自定义确定按钮后回调
    @return : 
--]]
function createAfterBattleLayer( pRetData, enemyDataTab, rewardData, CallFun, pIsHelp )
    -- 初始化
    init()

    for k,v in pairs(enemyDataTab)do
        if(v.level~=nil)then
            table.insert(_teamData,v)
        end
    end
    
    local appraisal = pRetData.appraisal
    -- 点击确定按钮传入回调
    afterOKCallFun = CallFun

    winSize = CCDirector:sharedDirector():getWinSize()
    mainLayer = CCLayerColor:create(ccc4(11,11,11,200))
    mainLayer:setTouchEnabled(true)
    mainLayer:registerScriptTouchHandler(cardLayerTouch,false,-1600,true)
    mainLayer:registerScriptHandler(onNodeEvent)
    print("胜负判断")
    -- 战斗胜负判断
    
    if( appraisal ~= "E" and appraisal ~= "F" )then
        _isWin = true
        -- 创建胜利背景框
        bg_sprite = BaseUI.createViewBg(CCSizeMake(520,728))
        bg_sprite:setAnchorPoint(ccp(0.5,0.5))
        bg_sprite:setPosition(ccp(winSize.width/2,winSize.height*0.40))
        mainLayer:addChild(bg_sprite)
    else
        _isWin = false
        -- 创建失败背景框
        bg_sprite = BaseUI.createViewBg(CCSizeMake(520,728))
        bg_sprite:setAnchorPoint(ccp(0.5,0.5))
        bg_sprite:setPosition(ccp(winSize.width/2,winSize.height*0.40))
        mainLayer:addChild(bg_sprite)
    end
    -- 对方信息
    local vs_bg = BaseUI.createContentBg(CCSizeMake(463,328))
    vs_bg:setContentSize(CCSizeMake(469, 328))
    vs_bg:setAnchorPoint(ccp(0.5,0))
    vs_bg:setPosition(ccp(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height*0.5))
    bg_sprite:addChild(vs_bg)
    _isSigle = pIsHelp

    local cellSize= CCSizeMake(575, 164)
    local h = LuaEventHandler:create(function(fn, tableV, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            r = CCSizeMake( cellSize.width, cellSize.height)
        elseif fn == "cellAtIndex" then
            a2 = createCell( _teamData[a1+1], a1+1 )
            r = a2
        elseif fn == "numberOfCells" then
            r =  table.count(_teamData)
        elseif fn == "cellTouched" then 
        elseif (fn == "scroll") then
            
        end
            return r
    end)
    _myTableView = LuaTableView:createWithHandler(h, CCSizeMake(575, 320 ))
    _myTableView:setBounceable(true)
    _myTableView:setAnchorPoint(ccp(0, 0))
    _myTableView:setPosition(ccp(4, 3))
    -- _myTableView:setTouchPriority(-2200)
    _myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    vs_bg:addChild(_myTableView)

    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-2200)
    bg_sprite:addChild(menu)
    -- 确定
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

    -- 判断是否胜利
    if(_isWin) then
        -- 创建中间ui
        local middle_bg = BaseUI.createContentBg(CCSizeMake(463,200))
        middle_bg:setAnchorPoint(ccp(0.5,0))
        middle_bg:setPosition(ccp(bg_sprite:getContentSize().width*0.5,120))
        bg_sprite:addChild(middle_bg)

        local scrollView = CCScrollView:create()
        scrollView:setTouchPriority(-2200)
        scrollView:setContentSize(CCSizeMake(520,180))
        scrollView:setViewSize(CCSizeMake(520,180))
        -- 设置弹性属性
        scrollView:setBounceable(true)
        -- 垂直方向滑动
        scrollView:setDirection(kCCScrollViewDirectionVertical)
        scrollView:setAnchorPoint(ccp(0,0))
        scrollView:setPosition(ccp(middle_bg:getContentSize().width*0.05,middle_bg:getContentSize().height*0.05))
        middle_bg:addChild(scrollView)
        local itemArray = rewardData
        local rewardCount = #itemArray

        local columnNumber = 3

        local startX = middle_bg:getContentSize().width*0.2-scrollView:getPositionX()
        local startY = middle_bg:getContentSize().height*0.75-scrollView:getPositionY()

        local intervalX = middle_bg:getContentSize().width*0.3
        local intervalY = middle_bg:getContentSize().height*0.58
        --print("rewardCount,startY:",rewardCount,startY)
        if(math.ceil(rewardCount/columnNumber)>=2)then
            startY = startY + (math.ceil(rewardCount/columnNumber)-1)*intervalY
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
            local item = nil
            if(itemArray[i][1].type == "silver")then
                item = ItemSprite.getSiliverIconSprite()
            elseif(itemArray[i][1].type == "grain")then
                item = ItemSprite.getGrainSprite()
            elseif(itemArray[i][1].type == "item")then
                item = ItemSprite.getItemSpriteByItemId(itemArray[i][1].tid)
            end

            item:setAnchorPoint(ccp(0.5,0.5))
            item:setPosition(startX+intervalX*math.floor((i-1)%columnNumber),startY-30-intervalY*math.floor((i-1)/columnNumber))
            rewardLayer:addChild(item)
            --兼容东南亚英文版
            
            local nameStr = nil
            if(itemArray[i][1].type == "silver")then
                nameStr = itemArray[i][1].name
            elseif(itemArray[i][1].type == "grain")then
                nameStr = itemArray[i][1].name
            elseif(itemArray[i][1].type == "item")then
                nameStr = ItemUtil.getItemById(tonumber(itemArray[i][1].tid)).name
            end
            if(nameStr~=nil)then
                local itemNameLabel = CCRenderLabel:create(nameStr, g_sFontName, 18, 1, ccc3( 0x10, 0x10, 0x10), type_stroke)
                itemNameLabel:setColor(ccc3( 0xff, 0xf6, 0x00))
                itemNameLabel:setAnchorPoint(ccp(0.5,0.5))
                itemNameLabel:setPosition(item:getContentSize().width*0.5,-item:getContentSize().height*0.15)
                item:addChild(itemNameLabel)
            end

            --数量
            local itemNumber = nil
            if(itemArray[i][1].num==nil or tonumber(itemArray[i][1].num)==nil)then
                itemNumber = ""
            else
                itemNumber = tonumber(itemArray[i][1].num)
            end
            local itemNumberLabel = CCRenderLabel:create( itemNumber .. "", g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            itemNumberLabel:setColor(ccc3( 0x66, 0xff, 0x66))
            itemNumberLabel:setAnchorPoint(ccp(1,0))
            itemNumberLabel:setPosition(item:getContentSize().width*0.92,item:getContentSize().height*0.05)
            item:addChild(itemNumberLabel)
        end
        local labelbg = CCScale9Sprite:create(CCRectMake(25, 15, 20, 10),"images/common/astro_labelbg.png")
        labelbg:setPreferredSize(CCSizeMake(middle_bg:getContentSize().width*0.4,middle_bg:getContentSize().height*0.15))
        labelbg:setAnchorPoint(ccp(0.5,0.5))
        labelbg:setPosition(middle_bg:getContentSize().width*0.5,middle_bg:getContentSize().height)
        middle_bg:addChild(labelbg)

        local itemBgTitle = CCLabelTTF:create(GetLocalizeStringBy("key_2882"),g_sFontName,24)
        itemBgTitle:setAnchorPoint(ccp(0.5,0.5))
        itemBgTitle:setPosition(middle_bg:getContentSize().width*0.5,middle_bg:getContentSize().height)
        itemBgTitle:setColor(ccc3(0xff,0xf6,0x00))
        middle_bg:addChild(itemBgTitle)
        -- 确定位置
        okItem:setPosition(ccp(bg_sprite:getContentSize().width*0.5,77))
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
        local middle_bg = BaseUI.createContentBg(CCSizeMake(463,250))
        middle_bg:setAnchorPoint(ccp(0.5,0))
        middle_bg:setPosition(ccp(bg_sprite:getContentSize().width*0.5,90))
        bg_sprite:addChild(middle_bg)
        okItem:setPosition(ccp(bg_sprite:getContentSize().width*0.5,57))
        okItem_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
        
        -- 四个按钮
        local middle_menu = CCMenu:create()
        middle_menu:setPosition(ccp(0,0))
        middle_menu:setTouchPriority(-2200)
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