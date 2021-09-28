-- Filename：    PurgatoryScoreLayer.lua
-- Author：      LLP
-- Date：        2015-5-28
-- Purpose：     炼狱副本积分界面

module("PurgatoryScoreLayer", package.seeall)

local _bgLayer                  = nil
local _OpponentInfo             = nil           --对手信息
local _copyInfo                 = nil           --副本信息
local _original_pos             = nil
local _desBg                    = nil
local _rightLine                = nil
local _downHeroSprite           = nil
local _refreshItem              = nil
local _bgSprite                 = nil
local _bottomLineSprite         = nil
local _desLabel                 = nil
local _scrolllayer              = nil
local _styleSprite              = nil
local _hardlv                   = 0             --难度
local _buyNum                   = 0
local _count                    = 0
local _chooseWhich              = 0
local _zorder                   = 100

local _isChalleng               = false

local _began_pos                         --初始卡牌编号
local _touchBeganPoint                   --触摸位置
local _began_heroSprite                 --初始开牌
local _began_hero_position               --初始卡牌位置

local end_pos                           --卡牌结束位置
local end_sprite
local _inFormationInfo          = {}
local chooseData                = {}
local heroCardsTable            = {}

function init()
    _bgLayer               = nil
    _OpponentInfo          = nil
    _original_pos           = nil
    _touchBeganPoint        = nil
    _began_pos              = nil
    _began_heroSprite      = nil
    _began_hero_position    = nil
    end_pos                = nil
    end_sprite             = nil
    _desBg                 = nil
    _styleSprite              = nil
    _rightLine                = nil
    _downHeroSprite           = nil
    _refreshItem              = nil
    _bgSprite                 = nil
    _bottomLineSprite         = nil
    _desLabel                 = nil
    _scrolllayer              = nil

    _hardlv             = 0             --难度
    _count              = 0
    _buyNum             = 0
    _chooseWhich        = 0
    _zorder             = 100

    _isChalleng         = false

    chooseData          = {}
    heroCardsTable      = {}
    _inFormationInfo    = {}
end

--界面起始结束
local function onTouchesHandler( eventType, x, y )
    if (eventType == "began") then
        return true
    end
end

--layer点击事件
local function onNodeEvent( event )
    if (event == "enter") then
        PurgatoryMainLayer.setClick(false)
        _bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -550, true)
        _bgLayer:setTouchEnabled(true)
    elseif (event == "exit") then
        PurgatoryMainLayer.setClick(true)
        _bgLayer:unregisterScriptTouchHandler()
    end
end

--返回事件
function backAction(tag,itembtn)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
end

local function createParentMenu()
    local _copyInfo = PurgatoryData.getCopyInfo()
    local height = 0
    if(not table.isEmpty(_copyInfo.point))then
        for i=1,table.count(_copyInfo.point) do
            local label1 = CCLabelTTF:create(GetLocalizeStringBy("llp_194",i),g_sFontPangWa,28)
            height = height+label1:getContentSize().height*2*g_fScaleX
        end
        local normalData = DB_Lianyutiaozhan_rule.getDataById(1)
        local leftNum = tonumber(normalData.challenge_num)+tonumber(_copyInfo.buy_atk_num)
        for i=table.count(_copyInfo.point)+1,leftNum do
            local label1 = CCLabelTTF:create(GetLocalizeStringBy("llp_194",i),g_sFontPangWa,28)
            height = height+label1:getContentSize().height*2*g_fScaleX
        end
        for i=1,table.count(_copyInfo.point) do

            local label1 = CCLabelTTF:create(GetLocalizeStringBy("llp_194",i),g_sFontPangWa,28)
            local label2 = CCLabelTTF:create(_copyInfo.point[i],g_sFontPangWa,28)

            label1:setScale(g_fScaleX)
            label2:setScale(g_fScaleX)

            label1:setColor(ccc3(0,255,0))

            label1:setAnchorPoint(ccp(1,0))
            label2:setAnchorPoint(ccp(0,0))

            label1:setPosition(ccp(640*0.5*g_fScaleX,height-label1:getContentSize().height*2*i*g_fScaleX))
            label2:setPosition(ccp(640*0.5*g_fScaleX,height-label1:getContentSize().height*2*i*g_fScaleX))

            _scrolllayer:addChild(label1)
            _scrolllayer:addChild(label2)
        end
        for i=table.count(_copyInfo.point)+1,leftNum do
            local node = CCSprite:create()
            local label1 = CCLabelTTF:create(GetLocalizeStringBy("llp_194",i),g_sFontPangWa,28)
            local label2 = CCLabelTTF:create(GetLocalizeStringBy("llp_195"),g_sFontPangWa,28)

            label1:setScale(g_fScaleX)
            label2:setScale(g_fScaleX)

            label1:setColor(ccc3(0,255,0))

            label1:setAnchorPoint(ccp(1,0))
            label2:setAnchorPoint(ccp(0,0))

            label1:setPosition(ccp(640*0.5*g_fScaleX,height-label1:getContentSize().height*2*i*g_fScaleX))
            label2:setPosition(ccp(640*0.5*g_fScaleX,height-label1:getContentSize().height*2*i*g_fScaleX))

            _scrolllayer:addChild(label1)
            _scrolllayer:addChild(label2)
        end
        _scrolllayer:setContentSize(CCSizeMake(640,height))
    else
        local normalData = DB_Lianyutiaozhan_rule.getDataById(1)
        for i=1,tonumber(normalData.challenge_num)+tonumber(_copyInfo.buy_atk_num) do
            local label1 = CCLabelTTF:create(GetLocalizeStringBy("llp_194",i),g_sFontPangWa,28)
            height = height+label1:getContentSize().height*2*g_fScaleX
        end
        for i=1,tonumber(normalData.challenge_num)+tonumber(_copyInfo.buy_atk_num) do
            local node = CCSprite:create()
            local label1 = CCLabelTTF:create(GetLocalizeStringBy("llp_194",i),g_sFontPangWa,28)
            local label2 = CCLabelTTF:create(GetLocalizeStringBy("llp_195"),g_sFontPangWa,28)

            label1:setColor(ccc3(0,255,0))

            label1:setScale(g_fScaleX)
            label2:setScale(g_fScaleX)

            label2:setPosition(ccp(label1:getContentSize().width*g_fScaleX,0))

            node:setContentSize(CCSizeMake(label1:getContentSize().width*g_fScaleX+label2:getContentSize().width*g_fScaleX,label1:getContentSize().height*g_fScaleX))
            node:setAnchorPoint(ccp(0.5,0))
            node:setPosition(ccp(640*0.5*g_fScaleX,height-label1:getContentSize().height*2*i*g_fScaleX))

            node:addChild(label1)
            node:addChild(label2)
            _scrolllayer:addChild(node)
        end
        _scrolllayer:setContentSize(CCSizeMake(640,height))
    end
    _scrolllayer:setAnchorPoint(ccp(0,0))

    _scrolllayer:setPosition(ccp(0,_bgSprite:getContentSize().height-_bottomLineSprite:getContentSize().height*g_fScaleY-_desLabel:getContentSize().height*g_fScaleY-_styleSprite:getContentSize().height*g_fScaleX-height))
end

local function fnCreateDetailContentLayer()
    --创建ScrollView
    local contentScrollView = CCScrollView:create()
    contentScrollView:setTouchPriority(-703)--_menu_priority-3 or
    local scrollViewHeight = _bgSprite:getContentSize().height
    contentScrollView:setViewSize(CCSizeMake(g_winSize.width, scrollViewHeight-_bottomLineSprite:getContentSize().height*g_fScaleY-_desLabel:getContentSize().height*g_fScaleY-_styleSprite:getContentSize().height*g_fScaleX))
    contentScrollView:setDirection(kCCScrollViewDirectionVertical)

    _scrolllayer = CCLayer:create()

    contentScrollView:setContainer(_scrolllayer)

    -- _scrolllayer:setContentSize(CCSizeMake(640,_bgSprite:getContentSize().height-_bottomLineSprite:getContentSize().height*g_fScaleY-_desLabel:getContentSize().height*g_fScaleY-_styleSprite:getContentSize().height*g_fScaleX))

    contentScrollView:setPosition(ccp(0,_bottomLineSprite:getContentSize().height*g_fScaleY+_desLabel:getContentSize().height*g_fScaleY))

    _bgSprite:addChild(contentScrollView)

    createParentMenu()
end

function createLayOut( ... )

    local _copyInfo = PurgatoryData.getCopyInfo()

    -- 当前阵型图片
    local _backItem= LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(213,73),GetLocalizeStringBy("key_3290"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))

    local fullRect = CCRectMake(0,0,187,30)
    local insetRect = CCRectMake(84,10,12,18)
    _bgSprite = CCScale9Sprite:create("images/godweaponcopy/blackred.png", fullRect, insetRect)
    _bgSprite:setContentSize(CCSizeMake(g_winSize.width, g_winSize.height*0.5))
    _bgLayer:addChild(_bgSprite,0,1)
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    -- 关闭按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,1))
    menu:setTouchPriority(-551)
    _bgSprite:addChild(menu,0,100)
    --  返回
    _backItem:setAnchorPoint(ccp(0.5,0))
    _backItem:setScale(g_fElementScaleRatio)
    _backItem:setPosition(_bgSprite:getContentSize().width*0.5, -_backItem:getContentSize().height*g_fElementScaleRatio)
    _backItem:registerScriptTapHandler(backAction)
    menu:addChild(_backItem,1)

    _styleSprite = CCScale9Sprite:create("images/purgatory/score1.png")
    _styleSprite:setAnchorPoint(ccp(0.5,0.5))
    _styleSprite:setScale(g_fScaleX )
    _styleSprite:setPosition(ccp(_bgSprite:getContentSize().width*0.5,_bgSprite:getContentSize().height))
    _bgSprite:addChild(_styleSprite)

    _bottomLineSprite = CCSprite:create("images/godweaponcopy/21.png")
    _bottomLineSprite:setScale(g_fScaleX )
    _bottomLineSprite:setAnchorPoint(ccp(0.5,0))
    _bgSprite:addChild(_bottomLineSprite)
    _bottomLineSprite:setPosition(ccp(_bgSprite:getContentSize().width*0.5,0))

    local leftFlower = CCScale9Sprite:create("images/god_weapon/flower.png")
    leftFlower:setScale(g_fScaleX )
    leftFlower:setAnchorPoint(ccp(1,0.5))
    leftFlower:setPosition(ccp(_bgSprite:getContentSize().width*0.5-_styleSprite:getContentSize().width*g_fScaleX,_bgSprite:getContentSize().height))
    _bgSprite:addChild(leftFlower)

    local rightFlower = CCScale9Sprite:create("images/god_weapon/flower.png")
    rightFlower:setScale(-g_fScaleX)
    rightFlower:setAnchorPoint(ccp(1,0.5))
    rightFlower:setPosition(ccp(_bgSprite:getContentSize().width*0.5+_styleSprite:getContentSize().width*g_fScaleX,_bgSprite:getContentSize().height))
    _bgSprite:addChild(rightFlower)

    _desLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_193"),g_sFontPangWa,28)
    _desLabel:setScale(g_fScaleX )
    _bgSprite:addChild(_desLabel)
    _desLabel:setAnchorPoint(ccp(0.5,0))
    _desLabel:setColor(ccc3(255,255,0))
    _desLabel:setPosition(ccp(_bgSprite:getContentSize().width*0.5,_bottomLineSprite:getContentSize().height*g_fScaleY))
    fnCreateDetailContentLayer()
end

function createLayer( ... )
    -- 底层
    _bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
    _bgLayer:registerScriptHandler(onNodeEvent)

    createLayOut()

    return _bgLayer
end

function showLayer(p_touch,p_zorder)
    init()
    p_touch = p_touch or -400
    p_zorder = p_zorder or 100

    local pLayer = createLayer()

    --把layer加到runningScene上
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:addChild(pLayer,p_zorder)
end
