-- FileName: VisitorBattleLayer.lua 
-- Author: zhang zihang
-- Date: 14-4-27 
-- Purpose: 第三方人士看到的战斗结算面板

module("VisitorBattleLayer", package.seeall) 

local _allData
local afterOKCallFun
local _isReplay
local backAnimSprite
local animSprite
local _sendMsgItem
local function init()
    _allData       = nil
    afterOKCallFun = nil
    _isReplay      = nil
    backAnimSprite = nil
    animSprite     = nil
    _sendMsgItem   = nil
end

local function cardLayerTouch(eventType, x, y)
    return true
end

local function getHeroNameColor( utid )
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

-- 查看战报回调
local function userFormationItemFun( tag, item_obj )
    -- 音效
    if table.count(_allData.server.team1.memberList) == 0 or table.count(_allData.server.team2.memberList) == 0 then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("key_2383"))
    else
        require "script/audio/AudioUtil"
        AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
        print(GetLocalizeStringBy("key_1742") .. tag )

        require "script/ui/guild/copy/GuildBattleReportLayer"
        GuildBattleReportLayer.showLayer(_allData,false,-493)
    end
end

local function replayItemFun( tag, item_obj )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    print(GetLocalizeStringBy("key_2460") .. tag )
    -- require "script/battle/BattleLayer"
    -- BattleLayer.replay()
end

local function okItemFun( tag, item_obj )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    --require "script/ui/guild/GuildMainLayer"
   -- GuildMainLayer.cityFireAction()

    require "script/battle/BattleLayer"
    BattleLayer.closeLayer()

    -- 点确定后 调用回调
    if(afterOKCallFun ~= nil)then
        afterOKCallFun()
    end
end

local function createButtonItem()
    local normalSprite  = CCScale9Sprite:create("images/common/btn/btn_green_n.png")
    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn_green_h.png")
    local disabledSprite = CCScale9Sprite:create("images/common/btn/btn_hui.png")
    local item = CCMenuItemSprite:create(normalSprite,selectSprite,disabledSprite)
    return item
end

function animationEnd( ... )
    if(backAnimSprite~=nil)then
        backAnimSprite:cleanup()
    end
    if(animSprite~=nil)then
        animSprite:cleanup()
    end
end

function animationFrameChanged()
end

function createAfterBattleLayer( tAllData, isReplay, CallFun )
	init()

	_allData = tAllData
	afterOKCallFun = CallFun
	_isReplay = isReplay

	local winSize = CCDirector:sharedDirector():getWinSize()
    local mainLayer = CCLayerColor:create(ccc4(11,11,11,200))
    mainLayer:setTouchEnabled(true)
    mainLayer:registerScriptTouchHandler(cardLayerTouch,false,-500,true)

    local bg_sprite = BaseUI.createViewBg(CCSizeMake(515,370))
    bg_sprite:setAnchorPoint(ccp(0.5,0.5))
    bg_sprite:setPosition(ccp(winSize.width/2,winSize.height*0.4))
    mainLayer:addChild(bg_sprite)

    setAdaptNode(bg_sprite)

    local brownBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    brownBg:setContentSize(CCSizeMake(470,160))
    brownBg:setAnchorPoint(ccp(0.5,0))
    brownBg:setPosition(ccp(bg_sprite:getContentSize().width/2,140))
    bg_sprite:addChild(brownBg)

    -- 攻方名字
    local fullRect = CCRectMake(0,0,31,41)
    local insetRect = CCRectMake(8,17,2,2)
    local myName_bg = CCScale9Sprite:create("images/common/b_name_bg.png", fullRect, insetRect)
    myName_bg:setContentSize(CCSizeMake(195,44))
    myName_bg:setAnchorPoint(ccp(0,0.5))
    myName_bg:setPosition(ccp(3,brownBg:getContentSize().height-35))
    brownBg:addChild(myName_bg)
    -- 攻方姓名的颜色
    local myNameStr = tAllData.server.team1.name
    local name_color,stroke_color = getHeroNameColor(2)
    local myName_font = CCRenderLabel:create( myNameStr, g_sFontPangWa, 25, 1, stroke_color, type_stroke)
    myName_font:setColor(name_color)
    myName_font:setAnchorPoint(ccp(0.5,0.5))
    myName_font:setPosition(ccp(myName_bg:getContentSize().width*0.5,myName_bg:getContentSize().height*0.5))
    myName_bg:addChild(myName_font)

    -- 守方名字 
    local fullRect = CCRectMake(0,0,31,41)
    local insetRect = CCRectMake(8,17,2,2)
    local enemyName_bg = CCScale9Sprite:create("images/common/b_name_bg.png", fullRect, insetRect)
    enemyName_bg:setContentSize(CCSizeMake(195,44))
    enemyName_bg:setAnchorPoint(ccp(0,0.5))
    enemyName_bg:setPosition(ccp(brownBg:getContentSize().width-3,brownBg:getContentSize().height-35))
    brownBg:addChild(enemyName_bg)
    enemyName_bg:setScale(enemyName_bg:getScaleX()*-1)
    -- 守方姓名的颜色
    local enemyNameStr = tAllData.server.team2.name
    local name_color,stroke_color = getHeroNameColor( 1 )
    local enemyName_font = CCRenderLabel:create( enemyNameStr, g_sFontPangWa, 25, 1, stroke_color, type_stroke)
    enemyName_font:setColor(name_color)
    enemyName_font:setAnchorPoint(ccp(0.5,0.5))
    enemyName_font:setPosition(ccp(enemyName_bg:getContentSize().width*0.5,enemyName_bg:getContentSize().height*0.5))
    enemyName_bg:addChild(enemyName_font)
    enemyName_font:setScale(enemyName_font:getScaleX()*-1)

    local vs_sprite = CCSprite:create("images/arena/vs.png")
    vs_sprite:setAnchorPoint(ccp(0.5,0.5))
    vs_sprite:setPosition(ccp(brownBg:getContentSize().width*0.5,brownBg:getContentSize().height-20-enemyName_bg:getContentSize().height/2))
    brownBg:addChild(vs_sprite)

    local winFlag = CCSprite:create("images/battle/battlefield_report/sheng.png")
    winFlag:setAnchorPoint(ccp(0.5,0))
    brownBg:addChild(winFlag)

    local lostFlag = CCSprite:create("images/battle/battlefield_report/fu.png")
    lostFlag:setAnchorPoint(ccp(0.5,0))
    brownBg:addChild(lostFlag)
    
    tAllData.server.appraisal = tAllData.server.appraisal or "G"
    if tAllData.server.result == "false" or tAllData.server.result == false or string.upper(tAllData.server.appraisal) == "F" or string.upper(tAllData.server.appraisal) == "E" then
        lostFlag:setPosition(ccp(75,20)) 
        winFlag:setPosition(ccp(brownBg:getContentSize().width-75,20))
    else
        winFlag:setPosition(ccp(75,20))
        lostFlag:setPosition(ccp(brownBg:getContentSize().width-75,20))
    end
    
    --我方伤害
    local battleInfo = tAllData.server
    local team1damageIcon = CCSprite:create("images/battle/report/damage.png")
    team1damageIcon:setAnchorPoint(ccp(0,0.5))
    team1damageIcon:setPosition(ccp(10, 85))
    brownBg:addChild(team1damageIcon)
    local team1DamageLabel = CCRenderLabel:create(math.abs(tonumber(battleInfo.team2.totalDamage) or 0) , g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    team1DamageLabel:setColor(ccc3(45,253,46))
    team1DamageLabel:setAnchorPoint(ccp(0, 0.5))
    team1DamageLabel:setPosition(team1damageIcon:getContentSize().width + 10, team1damageIcon:getContentSize().height/2)
    team1damageIcon:addChild(team1DamageLabel)

    --敌方伤害
    local team2damageIcon = CCSprite:create("images/battle/report/damage.png")
    team2damageIcon:setAnchorPoint(ccp(0,0.5))
    team2damageIcon:setPosition(ccp(brownBg:getContentSize().width/2+60, 85))
    brownBg:addChild(team2damageIcon)
    local team2DamageLabel = CCRenderLabel:create(math.abs(tonumber(battleInfo.team1.totalDamage) or 0), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    team2DamageLabel:setColor(ccc3(45,253,46))
    team2DamageLabel:setAnchorPoint(ccp(0, 0.5))
    team2DamageLabel:setPosition(team2damageIcon:getContentSize().width + 10, team1damageIcon:getContentSize().height/2)
    team2damageIcon:addChild(team2DamageLabel)

    if battleInfo.team2.totalDamage == nil then
        team1damageIcon:setVisible(false)
        team1DamageLabel:setVisible(false)
        team2damageIcon:setVisible(false)
        team2DamageLabel:setVisible(false)
    end

    -- 三个按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-1001)
    bg_sprite:addChild(menu)

    --[[
     查看战报
    local userFormationItem = createButtonItem()
    userFormationItem:setAnchorPoint(ccp(0.5,0))
    userFormationItem:registerScriptTapHandler(userFormationItemFun)
    menu:addChild(userFormationItem)
    -- 字体
    local userFormationItem_font = CCRenderLabel:create( GetLocalizeStringBy("key_2849") , g_sFontPangWa, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    userFormationItem_font:setAnchorPoint(ccp(0.5,0.5))
    userFormationItem_font:setPosition(ccp(userFormationItem:getContentSize().width*0.5,userFormationItem:getContentSize().height*0.5))
    userFormationItem:addChild(userFormationItem_font)
    userFormationItem_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    userFormationItem:setPosition(ccp(bg_sprite:getContentSize().width*0.3,135))
    --]]
    
    --[[
    -- 发送战报 -- added by zhz
    _sendMsgItem =  createButtonItem()
    _sendMsgItem:setAnchorPoint(ccp(0.5,0.5))
    _sendMsgItem:registerScriptTapHandler(sendMegFun )
    menu:addChild(_sendMsgItem)
    -- 文字
    _sendMsgItem_font = CCRenderLabel:create( GetLocalizeStringBy("key_4000") , g_sFontPangWa, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _sendMsgItem_font:setAnchorPoint(ccp(0.5,0.5))
    _sendMsgItem_font:setPosition(ccp(_sendMsgItem:getContentSize().width*0.5,_sendMsgItem:getContentSize().height*0.5))
    _sendMsgItem:addChild(_sendMsgItem_font)
    _sendMsgItem_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    _sendMsgItem_font:setPosition(ccp(bg_sprite:getContentSize().width*0.7,135))
    --]]
     -- 重播
    local replayItem = createButtonItem()
    replayItem:setAnchorPoint(ccp(0.5,0))
    replayItem:registerScriptTapHandler(replayItemFun)
    menu:addChild(replayItem)
    -- 字体
    local replayItem_font = CCRenderLabel:create( GetLocalizeStringBy("key_2184") , g_sFontPangWa, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    replayItem_font:setAnchorPoint(ccp(0.5,0.5))
    replayItem_font:setPosition(ccp(replayItem:getContentSize().width*0.5,replayItem:getContentSize().height*0.5))
    replayItem:addChild(replayItem_font)
    -- 重播功能暂未开放
    replayItem:setEnabled(false)
    replayItem_font:setColor(ccc3(0xf1,0xf1,0xf1))

    replayItem:setPosition(ccp(bg_sprite:getContentSize().width*0.3,50))

    -- 确定
    local okItem = createButtonItem()
    okItem:setAnchorPoint(ccp(0.5,0))
    okItem:registerScriptTapHandler(okItemFun)
    menu:addChild(okItem)
    -- 字体
    local okItem_font = CCRenderLabel:create( GetLocalizeStringBy("key_1985") , g_sFontPangWa, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    okItem_font:setAnchorPoint(ccp(0.5,0.5))
    okItem_font:setPosition(ccp(okItem:getContentSize().width*0.5,okItem:getContentSize().height*0.5))
    okItem:addChild(okItem_font)
    okItem_font:setColor(ccc3(0xfe, 0xdb, 0x1c))

    okItem:setPosition(ccp(bg_sprite:getContentSize().width*0.7,45))

    -- 胜利特效
    local backAnimSprite2 = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli03"), -1,CCString:create(""))
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

    backAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli02"), -1,CCString:create(""))
    backAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
    backAnimSprite:setPosition(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-10)
    bg_sprite:addChild(backAnimSprite,0)
    
    animSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/xml/report/zhandoushengli01"), -1,CCString:create(""))

    animSprite:setAnchorPoint(ccp(0.5, 0.5));
    animSprite:setPosition(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-20)
    bg_sprite:addChild(animSprite)
    
    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    animSprite:setDelegate(delegate)

    return mainLayer
end

--[[

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

    local fightStr = _allData.server
    ChatUtil.sendChatinfo(fightStr, ChatCache.ChatInfoType.battle_report_city, ChatCache.ChannelType.world, sendClickCallback)
end
--]]

