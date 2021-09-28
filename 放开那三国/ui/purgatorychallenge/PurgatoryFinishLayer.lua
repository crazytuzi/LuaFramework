-- FileName: PurgatoryAfterBattleLayer.lua
-- Author: LLP
-- Date: 16-6-12
-- Purpose: 结算面板


module("PurgatoryFinishLayer", package.seeall)
require "script/model/user/UserModel"
require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"
require "script/ui/hero/HeroPublicLua"
require "script/ui/hero/HeroPublicCC"
require "script/audio/AudioUtil"
require "script/ui/login/LoginScene"
require "script/ui/guild/GuildDataCache"
require "script/ui/purgatorychallenge/PurgatoryMainLayer"
require "script/animation/XMLSprite"

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
    _copyInfo                   = PurgatoryData.getCopyInfo()
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

-- 创建挑战结算面板
-- flopData:掉落数据
-- CallFun: 自定义确定按钮后回调
function createAfterBattleLayer(pNum)
    -- 初始化
    init()
    -- 点击确定按钮传入回调
    afterOKCallFun = CallFun
    winSize = CCDirector:sharedDirector():getWinSize()
    mainLayer = CCLayerColor:create(ccc4(11,11,11,200))
    mainLayer:setTouchEnabled(true)
    mainLayer:registerScriptTouchHandler(cardLayerTouch,false,-450,true)

    -- 创建胜利背景框
    bg_sprite = BaseUI.createViewBg(CCSizeMake(520,425))
    bg_sprite:setAnchorPoint(ccp(0.5,0.5))
    bg_sprite:setPosition(ccp(winSize.width/2,winSize.height*0.40))
    mainLayer:addChild(bg_sprite)
    local pCopyInfo = PurgatoryData.getCopyInfo()
    local maxPoint = 0
    local pMaxPointTable = _copyInfo.point

    table.insert(pMaxPointTable,tonumber(_copyInfo.curr_point))

    for k,v in pairs(pMaxPointTable)do
        if(tonumber(v)>maxPoint)then
            maxPoint = tonumber(v)
        end
    end

    for i=1,3 do

        local bg = CCScale9Sprite:create(CCRectMake(20, 20, 10, 10),"images/common/labelbg_white.png")
        if(i==1)then
            bg = CCScale9Sprite:create(CCRectMake(84, 10, 12, 8),"images/common/purple.png")
        end
        bg:setContentSize(CCSizeMake(380,50))
        bg:setAnchorPoint(ccp(0.5,0.5))
        bg:setPosition(ccp(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height*0.25+bg_sprite:getContentSize().height*0.2*i))
        bg_sprite:addChild(bg)
        local str = "llp_"..tostring(206-i)
        local leftLabel = CCLabelTTF:create(GetLocalizeStringBy(str),g_sFontName,25)
        leftLabel:setColor(ccc3(0x78,0x25,0x00))
        if(i==1)then
            leftLabel = CCLabelTTF:create(GetLocalizeStringBy(str),g_sFontPangWa,25)
            leftLabel:setColor(ccc3(0xff,0xff,0xff))
        end

        leftLabel:setAnchorPoint(ccp(0,0.5))
        bg:addChild(leftLabel)
        leftLabel:setPosition(ccp(bg:getContentSize().width*0.2,bg:getContentSize().height*0.5))

        local rightLabel = nil
        if(i==1)then
            rightLabel = CCLabelTTF:create(pNum,g_sFontPangWa,25)
            rightLabel:setColor(ccc3(0xff,0xf6,0x00))
        elseif(i==2)then
            rightLabel = CCLabelTTF:create(maxPoint,g_sFontName,25)
            rightLabel:setColor(ccc3(0x00,0x00,0x00))
        elseif(i==3)then
            rightLabel = CCLabelTTF:create(_copyInfo.curr_point,g_sFontName,25)
            rightLabel:setColor(ccc3(0x00,0x00,0x00))
        end
        rightLabel:setAnchorPoint(ccp(0,0.5))
        bg:addChild(rightLabel,0,i)
        rightLabel:setPosition(ccp(bg:getContentSize().width*0.7,bg:getContentSize().height*0.5))
    end
    -- 三个按钮
    menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-1510)
    bg_sprite:addChild(menu)

    -- 确定
    okItem = createButtonItem(GetLocalizeStringBy("key_1985"))
    okItem:setAnchorPoint(ccp(0.5,0.5))
    okItem:registerScriptTapHandler(okItemFun)
    menu:addChild(okItem)

    okItem:setPosition(ccp(bg_sprite:getContentSize().width*0.5,57-5))

    -- 胜利特效
    backAnimSprite2 = XMLSprite:create("images/battle/xml/report/zhandoushengli03")
    backAnimSprite2:setReplayTimes(1, false)
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

    backAnimSprite = XMLSprite:create("images/battle/xml/report/zhandoushengli02")
    backAnimSprite:setReplayTimes(1, false)
    backAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
    backAnimSprite:setPosition(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-10)
    bg_sprite:addChild(backAnimSprite,0)

    animSprite = XMLSprite:create("images/purgatory/zhandoujiesuan/zhandoujiesuan")
    animSprite:setAnchorPoint(ccp(0.5, 0.5));
    animSprite:setPosition(bg_sprite:getContentSize().width*0.5,bg_sprite:getContentSize().height-20)
    bg_sprite:addChild(animSprite)
    animSprite:setReplayTimes(1, false)
    -- delegate = BTAnimationEventDelegate:create()
    -- delegate:registerLayerEndedHandler(animationEnd)
    -- delegate:registerLayerChangedHandler(animationFrameChanged)
    -- animSprite:setDelegate(delegate)

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
        animSprite:stop()
    end
end

function animationFrameChanged( ... )
    -- body
end

-- -- 按钮item
-- function createButtonItem()
--     local normalSprite  = CCScale9Sprite:create("images/common/btn/btn_green_n.png")
--     local selectSprite  = CCScale9Sprite:create("images/common/btn/btn_green_h.png")
--     local disabledSprite = CCScale9Sprite:create("images/common/btn/btn_hui.png")
--     local item = CCMenuItemSprite:create(normalSprite,selectSprite,disabledSprite)
--     return item
-- end

-- 按钮item
function createButtonItem( str )
    local normalSprite  =CCScale9Sprite:create("images/common/btn/btn_green_n.png")
    local selectSprite  =CCScale9Sprite:create("images/common/btn/btn_green_h.png")
    local disableSprite= CCScale9Sprite:create("images/common/btn/btn_hui.png")
    local item = CCMenuItemSprite:create(normalSprite,selectSprite, disableSprite)
    -- 字体
    local item_font = CCRenderLabel:create( str , g_sFontPangWa, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    item_font:setAnchorPoint(ccp(0.5,0.5))
    item_font:setPosition(ccp(item:getContentSize().width*0.5,item:getContentSize().height*0.5))
    item:addChild(item_font,1)
    return item
end

-- 确定回调
function okItemFun( tag, item_obj )
    -- 音效

    AudioUtil.playBgm("audio/bgm/music17.mp3")
    if(mainLayer~=nil)then
        mainLayer:removeFromParentAndCleanup(true)
        mainLayer = nil
    end

    PurgatoryMainLayer.setClick(true)
    PurgatoryMainLayer.refreshFunc()
end

-- 重播
function repalyItemFun( ... )
    -- body
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    require "script/battle/BattleLayer"
    BattleLayer.replay()
end