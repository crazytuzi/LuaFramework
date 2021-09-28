-- Filename：    PurgatoryEnemyLayer.lua
-- Author：      LLP
-- Date：        2015-5-28
-- Purpose：     查看对手阵容界面

module("PurgatoryEnemyLayer", package.seeall)

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
local _heroData                 = nil
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
    _rightLine                = nil
    _downHeroSprite           = nil
    _refreshItem              = nil
    _bgSprite                 = nil
    _bottomLineSprite         = nil
    _desLabel                 = nil
    _scrolllayer              = nil
    _heroData                 = nil

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
        _bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -552, true)
        _bgLayer:setTouchEnabled(true)
    elseif (event == "exit") then
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

function createLayOut( ... )

    local _copyInfo = PurgatoryData.getCopyInfo()

    local monsterId = tonumber(_copyInfo.monster[tostring(tonumber(_copyInfo.passed_stage)+1)])
    local armyData = DB_Army.getDataById(monsterId)

    local monsterGroupId = tonumber(armyData.monster_group)
    local monsterData = DB_Team.getDataById(monsterGroupId)

    local heroData = tostring(monsterData["4"])
    for k,v in pairs(monsterData)do
        if(k==4)then
            heroData = v
            break
        end
    end

    local hero_attr_arry = string.split(heroData, ",")
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
    menu:setTouchPriority(-553)
    _bgSprite:addChild(menu,0,100)
    --  返回
    _backItem:setAnchorPoint(ccp(0.5,0))
    _backItem:setScale(g_fElementScaleRatio)
    _backItem:setPosition(_bgSprite:getContentSize().width*0.5, -_backItem:getContentSize().height*g_fElementScaleRatio)
    _backItem:registerScriptTapHandler(backAction)
    menu:addChild(_backItem,1)

    local styleSprite = CCScale9Sprite:create("images/purgatory/1.png")
    styleSprite:setAnchorPoint(ccp(0.5,0.5))
    styleSprite:setScale(g_fScaleX )
    styleSprite:setPosition(ccp(_bgSprite:getContentSize().width*0.5,_bgSprite:getContentSize().height))
    _bgSprite:addChild(styleSprite)

    _bottomLineSprite = CCSprite:create("images/godweaponcopy/21.png")
    _bottomLineSprite:setScale(g_fScaleX )
    _bottomLineSprite:setAnchorPoint(ccp(0.5,0))
    _bgSprite:addChild(_bottomLineSprite)
    _bottomLineSprite:setPosition(ccp(_bgSprite:getContentSize().width*0.5,0))

    local leftFlower = CCScale9Sprite:create("images/god_weapon/flower.png")
    leftFlower:setScale(g_fScaleX )
    leftFlower:setAnchorPoint(ccp(1,0.5))
    leftFlower:setPosition(ccp(_bgSprite:getContentSize().width*0.5-styleSprite:getContentSize().width*g_fScaleX,_bgSprite:getContentSize().height))
    _bgSprite:addChild(leftFlower)

    local rightFlower = CCScale9Sprite:create("images/god_weapon/flower.png")
    rightFlower:setScale(-g_fScaleX)
    rightFlower:setAnchorPoint(ccp(1,0.5))
    rightFlower:setPosition(ccp(_bgSprite:getContentSize().width*0.5+styleSprite:getContentSize().width*g_fScaleX,_bgSprite:getContentSize().height))
    _bgSprite:addChild(rightFlower)

    for i=1,6 do
        local card = CCScale9Sprite:create("images/common/blank_card.png", CCRectMake(0, 0, 77, 82), CCRectMake(38, 39, 2, 3))
        card:setPreferredSize(CCSizeMake(128, 150))
        card:setScale(g_fScaleY*0.7 )
        card:setAnchorPoint(ccp(0.5,0))
        if(i<4)then
            card:setPosition(ccp(_bgSprite:getContentSize().width*0.25*(i),_bgSprite:getContentSize().height*0.6))
        else
            card:setPosition(ccp(_bgSprite:getContentSize().width*0.25*(i-3),_bgSprite:getContentSize().height*0.25))
        end
        _bgSprite:addChild(card,0,i)

        local addItem = nil
        local bodySprite = CCSprite:create()
        if(hero_attr_arry[i]~=nil)then
            if(tonumber(hero_attr_arry[i])~=0)then
                bodySprite = BattleCardUtil.getBattlePlayerCardImage(hero_attr_arry[i], false)
            else
                bodySprite:ignoreAnchorPointForPosition(false)
                bodySprite:setContentSize(CCSizeMake(128, 150))
            end
        end
        bodySprite:setAnchorPoint(ccp(0.5,0.5))
        card:addChild(bodySprite,0,i)
        bodySprite:setPosition(ccp(card:getContentSize().width*0.5,card:getContentSize().height*0.5))
    end
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
