-- Filename: OvertrueLayer.lua
-- Author: lichenyang
-- Date: 2013-09-25
-- Purpose: 战斗场景

require "script/guide/overture/BattleCardUtilLee"
require "script/guide/overture/PlayerCardLayerLee"
require "script/ui/talk/talkLayer"
require "script/audio/AudioUtil"
module("OvertrueLayer", package.seeall)


playerFormation = nil
enemyFormation  = nil


local overCallback = nil
local backgroundLayer = nil
local runningScene = CCDirector:sharedDirector():getRunningScene()

local enemys = {}
local plays  = {}

local kGuanYuTag = 50


function play( p_callback )
	overCallback = p_callback

    local actionArray = CCArray:create()
    local dely = CCDelayTime:create(1.5)
    actionArray:addObject(dely)
    local calfuc = CCCallFunc:create(function ( ... )
        AudioUtil.playEffect("audio/overture/saveme.mp3")
    end)
    actionArray:addObject(calfuc)
    local seq = CCSequence:create(actionArray)
    runningScene:runAction(seq)

	local action1 = CCLayerSprite:layerSpriteWithName(CCString:create("images/guide/effect/kaichang/kaichang"),-1,CCString:create(""))
	action1:setScale(getMaxScaleParm() * 1.02)
    -- action1:setContentSize(CCSizeMake(960, 640))
	action1:setPosition(ccps(0.5,0.5))
	--action1:setFPS_interval(1/60.0)
    local animationDelegate = BTAnimationEventDelegate:create()
    animationDelegate:registerLayerEndedHandler(function ( eventType,layerSprite )
        action1:retain()
        action1:autorelease()
        print("kaichang delegate type = ", eventType)
        action1:removeFromParentAndCleanup(true)
        layerSprite = nil
        rolePlay()
    end)
    action1:setDelegate(animationDelegate)
   runningScene:addChild(action1, 1202)
end

function rolePlay()
    backgroundLayer = CCLayer:create()
    runningScene:addChild(backgroundLayer, 9999999)
    backgroundLayer:setScale(CCDirector:sharedDirector():getWinSize().width/640)
    local play2 = BattleLayerLee.createBattleCard(playerFormation["4"])
    play2:setPosition(PlayerCardLayerLee.getPointByPosition(4))
    -- play2:setPosition(ccps(0.5, 0.5))
    backgroundLayer:addChild(play2)
    plays[4] = play2

    play2:setScale(5)

    local next1Func = function ( ... )
        AudioUtil.playEffect("audio/overture/medown.mp3")
        ZhenPing(function ( ... )
            local talkLayer = TalkLayer.createTalkLayer(112)
            runningScene:addChild(talkLayer,99999999)
            TalkLayer.setCallbackFunction(player2)
        end)
    end

    local actionArray = CCArray:create()
    local scale  = CCScaleTo:create(0.3, 1)
    actionArray:addObject(scale)
    local calfuc = CCCallFunc:create(next1Func)
    actionArray:addObject(calfuc)
    local seq = CCSequence:create(actionArray)
    play2:runAction(seq)
end

function player2( ... )

    AudioUtil.playEffect("audio/overture/card_appear.mp3")
    local action1 = CCLayerSprite:layerSpriteWithName(CCString:create("images/guide/effect/mobingchuxian/mobingchuxian"),-1,CCString:create(""))
    
    action1:setPosition(ccps(0.5,0.5))
    --action1:setFPS_interval(1/60.0)
    local animationDelegate = BTAnimationEventDelegate:create()
    action1:setDelegate(animationDelegate)
    animationDelegate:registerLayerEndedHandler(function ( eventType,layerSprite )
        action1:retain()
        action1:autorelease()
        action1:removeFromParentAndCleanup(true)
        layerSprite = nil
    end)
    action1:setPosition(BattleLayerLee.getEnemyCardPointByPosition(0))
    backgroundLayer:addChild(action1, 10)
    --042135
    local play2 = BattleCardUtilLee.getBattlePlayerCard(enemyFormation["0"])
    play2:setPosition(BattleLayerLee.getEnemyCardPointByPosition(0))
    -- play2:setPosition(ccps(0.5, 0.5))
    backgroundLayer:addChild(play2)
    enemys[0] = play2

    local next1Func = function ( ... )
        player3()
    end

    local actionArray = CCArray:create()
    local scale  = CCScaleTo:create(0.3, 1)
    -- play2:setScale(5)
    -- actionArray:addObject(scale)

    local dely = CCDelayTime:create(0.2)
    actionArray:addObject(dely)

    local calfuc = CCCallFunc:create(next1Func)
    actionArray:addObject(calfuc)

    local seq = CCSequence:create(actionArray)
    play2:runAction(seq)
end

function player3( ... )

    local action1 = CCLayerSprite:layerSpriteWithName(CCString:create("images/guide/effect/mobingchuxian/mobingchuxian"),-1,CCString:create(""))
    
    action1:setPosition(ccps(0.5,0.5))
    --action1:setFPS_interval(1/60.0)
    local animationDelegate = BTAnimationEventDelegate:create()
    action1:setDelegate(animationDelegate)
    animationDelegate:registerLayerEndedHandler(function ( eventType,layerSprite )
        action1:retain()
        action1:autorelease()
        action1:removeFromParentAndCleanup(true)
        layerSprite = nil
    end)
    action1:setPosition(BattleLayerLee.getEnemyCardPointByPosition(4))
    backgroundLayer:addChild(action1, 10)

    --042135
    local play2 = BattleCardUtilLee.getBattlePlayerCard(enemyFormation["4"])
    play2:setPosition(BattleLayerLee.getEnemyCardPointByPosition(4))
    -- play2:setPosition(ccps(0.5, 0.5))
    backgroundLayer:addChild(play2)
    enemys[4] = play2

    local next1Func = function ( ... )

        player4()
    end

    local actionArray = CCArray:create()
    local scale  = CCScaleTo:create(0.3, 1)
    -- play2:setScale(5)
    -- actionArray:addObject(scale)

    local dely = CCDelayTime:create(0.2)
    actionArray:addObject(dely)

    local calfuc = CCCallFunc:create(next1Func)
    actionArray:addObject(calfuc)

    local seq = CCSequence:create(actionArray)
    play2:runAction(seq)
end
function player4( ... )
    local action1 = CCLayerSprite:layerSpriteWithName(CCString:create("images/guide/effect/mobingchuxian/mobingchuxian"),-1,CCString:create(""))
    
    action1:setPosition(ccps(0.5,0.5))
    --action1:setFPS_interval(1/60.0)
    local animationDelegate = BTAnimationEventDelegate:create()
    action1:setDelegate(animationDelegate)
    action1:setDelegate(animationDelegate)
    animationDelegate:registerLayerEndedHandler(function ( eventType,layerSprite )
        action1:retain()
        action1:autorelease()
        action1:removeFromParentAndCleanup(true)
        layerSprite = nil
    end)
    action1:setPosition(BattleLayerLee.getEnemyCardPointByPosition(2))
    backgroundLayer:addChild(action1, 10)
    --042135
    local play2 = BattleCardUtilLee.getBattlePlayerCard(enemyFormation["2"])
    play2:setPosition(BattleLayerLee.getEnemyCardPointByPosition(2))
    -- play2:setPosition(ccps(0.5, 0.5))
    backgroundLayer:addChild(play2)
    enemys[2] = play2

    local next1Func = function ( ... )

        player5()
    end

   local actionArray = CCArray:create()
    local scale  = CCScaleTo:create(0.3, 1)
    -- play2:setScale(5)
    -- actionArray:addObject(scale)

    local dely = CCDelayTime:create(0.2)
    actionArray:addObject(dely)

    local calfuc = CCCallFunc:create(next1Func)
    actionArray:addObject(calfuc)

    local seq = CCSequence:create(actionArray)
    play2:runAction(seq)
end

function player5( ... )
    local action1 = CCLayerSprite:layerSpriteWithName(CCString:create("images/guide/effect/mobingchuxian/mobingchuxian"),-1,CCString:create(""))
    
    action1:setPosition(ccps(0.5,0.5))
    --action1:setFPS_interval(1/60.0)
    local animationDelegate = BTAnimationEventDelegate:create()
    action1:setDelegate(animationDelegate)
    animationDelegate:registerLayerEndedHandler(function ( eventType,layerSprite )
        action1:retain()
        action1:autorelease()
        action1:removeFromParentAndCleanup(true)
        layerSprite = nil
    end)
    action1:setPosition(BattleLayerLee.getEnemyCardPointByPosition(1))
    backgroundLayer:addChild(action1, 10)
    --042135
    local play2 = BattleCardUtilLee.getBattlePlayerCard(enemyFormation["1"])
    play2:setPosition(BattleLayerLee.getEnemyCardPointByPosition(1))
    -- play2:setPosition(ccps(0.5, 0.5))
    backgroundLayer:addChild(play2, 1, 1)
    enemys[1] = play2

    local next1Func = function ( ... )

        player6()
    end

   local actionArray = CCArray:create()
    local scale  = CCScaleTo:create(0.3, 1)
    -- play2:setScale(5)
    -- actionArray:addObject(scale)

    local dely = CCDelayTime:create(0.2)
    actionArray:addObject(dely)

    local calfuc = CCCallFunc:create(next1Func)
    actionArray:addObject(calfuc)

    local seq = CCSequence:create(actionArray)
    play2:runAction(seq)
end


function player6( ... )
    local action1 = CCLayerSprite:layerSpriteWithName(CCString:create("images/guide/effect/mobingchuxian/mobingchuxian"),-1,CCString:create(""))
    
    action1:setPosition(ccps(0.5,0.5))
    --action1:setFPS_interval(1/60.0)
    local animationDelegate = BTAnimationEventDelegate:create()
    action1:setDelegate(animationDelegate)
    animationDelegate:registerLayerEndedHandler(function ( eventType,layerSprite )
        action1:retain()
        action1:autorelease()
        action1:removeFromParentAndCleanup(true)
        layerSprite = nil
    end)
    action1:setPosition(BattleLayerLee.getEnemyCardPointByPosition(3))
    backgroundLayer:addChild(action1, 10)
    --042135
    local play2 = BattleCardUtilLee.getBattlePlayerCard(enemyFormation["3"])
    play2:setPosition(BattleLayerLee.getEnemyCardPointByPosition(3))
    -- play2:setPosition(ccps(0.5, 0.5))
    backgroundLayer:addChild(play2, 1, 3)
    enemys[3] = play2

    local next1Func = function ( ... )
        player7()
    end

   local actionArray = CCArray:create()
    local scale  = CCScaleTo:create(0.3, 1)
    -- play2:setScale(5)
    -- actionArray:addObject(scale)

    local dely = CCDelayTime:create(0.2)
    actionArray:addObject(dely)

    local calfuc = CCCallFunc:create(next1Func)
    actionArray:addObject(calfuc)

    local seq = CCSequence:create(actionArray)
    play2:runAction(seq)
end


function player7( ... )
    local action1 = CCLayerSprite:layerSpriteWithName(CCString:create("images/guide/effect/mobingchuxian/mobingchuxian"),-1,CCString:create(""))
    
    --action1:setFPS_interval(1/60.0)
    local animationDelegate = BTAnimationEventDelegate:create()
    action1:setDelegate(animationDelegate)
    animationDelegate:registerLayerEndedHandler(function ( eventType,layerSprite )
        action1:retain()
        action1:autorelease()
        action1:removeFromParentAndCleanup(true)
        layerSprite = nil
    end)
    action1:setPosition(BattleLayerLee.getEnemyCardPointByPosition(5))
    backgroundLayer:addChild(action1, 10)
    --042135
    local play2 = BattleCardUtilLee.getBattlePlayerCard(enemyFormation["5"])
    play2:setPosition(BattleLayerLee.getEnemyCardPointByPosition(5))
    -- play2:setPosition(ccps(0.5, 0.5))
    backgroundLayer:addChild(play2, 1, 5)
    enemys[5] = play2

    local next1Func = function ( ... )
        -- backgroundLayer:removeFromParentAndCleanup(true)
        local talkLayer = TalkLayer.createTalkLayer(113)
        runningScene:addChild(talkLayer,99999999)
        TalkLayer.setCallbackFunction(player71)
        -- overCallback()
    end

    local actionArray = CCArray:create()
    local scale  = CCScaleTo:create(0.3, 1)
    -- play2:setScale(5)
    -- actionArray:addObject(scale)

    local dely = CCDelayTime:create(0.2)
    actionArray:addObject(dely)

    local calfuc = CCCallFunc:create(next1Func)
    actionArray:addObject(calfuc)

    local seq = CCSequence:create(actionArray)
    play2:runAction(seq)
end

function player71( ... )

    local attack = function ( ... )
        --攻击动作
        print("player71")
        local attackEffect = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/texiao3_u"),-1,CCString:create(""))
        local animationDelegate = BTAnimationEventDelegate:create()
        attackEffect:setDelegate(animationDelegate)
        animationDelegate:registerLayerEndedHandler(function ( eventType,layerSprite )
            attackEffect:retain()
            attackEffect:autorelease()
            print("player71 eventType = ", player71)
            attackEffect:removeFromParentAndCleanup(true)
            layerSprite = nil
        end)
        
        attackEffect:setAnchorPoint(ccp(0.5, 0.5))
        attackEffect:setPosition(ccpsprite(0.5, 0, enemys[1]))
        enemys[1]:addChild(attackEffect, 10)
        enemys[1]:setBasePoint(ccp(enemys[1]:getPositionX(), enemys[1]:getPositionY()))
        enemys[1]:runXMLAnimation(CCString:create("images/battle/xml/action/T001_u_0"));
        local animationEnd = function ( ... )

            enemys[1]:setBasePoint(BattleLayerLee.getEnemyCardPointByPosition(1))
            local actionArray = CCArray:create()
            local back   = CCMoveTo:create(0.1, BattleLayerLee.getEnemyCardPointByPosition(1))
            local calfuc = CCCallFunc:create(function ( ... )
                local talkLayer = TalkLayer.createTalkLayer(114)
                runningScene:addChild(talkLayer,99999999)
                TalkLayer.setCallbackFunction(player8)
            end)

            actionArray:addObject(back)
            actionArray:addObject(calfuc)

            local seq = CCSequence:create(actionArray)
            enemys[1]:runAction(seq)
        end
        local animationFrameChanged = function ( frameIndex,xmlSprite )
            local tempSprite = tolua.cast(xmlSprite,"CCXMLSprite")
            if(tempSprite:getIsKeyFrame()) then
                --受伤动画
                local attackEffect = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/dajizhong"),-1,CCString:create(""))
                local animationDelegate = BTAnimationEventDelegate:create()
                attackEffect:setDelegate(animationDelegate)
                animationDelegate:registerLayerEndedHandler(function ( eventType,layerSprite )
                    attackEffect:retain()
                    attackEffect:autorelease()
                    attackEffect:removeFromParentAndCleanup(true)
                    layerSprite = nil
                end)
                attackEffect:setPosition(ccpsprite(0.5, 0.5, plays[4]))
                plays[4]:addChild(attackEffect, 10)

                AudioUtil.playEffect("audio/overture/attack.mp3")
            end
        end
        local delegate = BTAnimationEventDelegate:create()
        delegate:registerLayerEndedHandler(animationEnd)
        delegate:registerLayerChangedHandler(animationFrameChanged)
        enemys[1]:setDelegate(delegate)
    end



    local goMove = CCMoveTo:create(0.1, ccp(plays[4]:getPositionX(), plays[4]:getPositionY() + plays[4]:getContentSize().height * 1.5))
    local callback = CCCallFunc:create(attack)
    
    
    local actionArray = CCArray:create()
    actionArray:addObject(goMove)
    actionArray:addObject(callback)


    local seq = CCSequence:create(actionArray)
    enemys[1]:runAction(seq)
end


--诸葛亮出场
function player8( ... )
    AudioUtil.playEffect("audio/overture/boy_down.mp3")
    --03452
    local play2 = BattleCardUtilLee.getBattlePlayerCard(playerFormation["3"])
    play2:setPosition(PlayerCardLayerLee.getPointByPosition(3))
    -- play2:setPosition(ccps(0.5, 0.5))
    backgroundLayer:addChild(play2)

    play2:setScale(5)

    local next1Func = function ( ... )
        ZhenPing(function ( ... )
            local talkLayer = TalkLayer.createTalkLayer(115)
            runningScene:addChild(talkLayer,99999999)
            TalkLayer.setCallbackFunction(player9)
        end)
    end

    local actionArray = CCArray:create()
    local scale  = CCScaleTo:create(0.3, 1)
    actionArray:addObject(scale)
    local calfuc = CCCallFunc:create(next1Func)
    actionArray:addObject(calfuc)
    local seq = CCSequence:create(actionArray)
    play2:runAction(seq)
end

--关羽出场
function player9( ... )
    AudioUtil.playEffect("audio/overture/guanyu.mp3")
    --03452
    local play2 = BattleCardUtilLee.getBattlePlayerCard(playerFormation["0"])
    play2:setPosition(PlayerCardLayerLee.getPointByPosition(0))
    -- play2:setPosition(ccps(0.5, 0.5))
    backgroundLayer:addChild(play2,1,kGuanYuTag)

    play2:setScale(5)

    local next1Func = function ( ... )
        ZhenPing(function ( ... )
            local talkLayer = TalkLayer.createTalkLayer(116)
            runningScene:addChild(talkLayer,99999999)
            TalkLayer.setCallbackFunction(player10)
        end)
    end

    local actionArray = CCArray:create()
    local scale  = CCScaleTo:create(0.3, 1)
    actionArray:addObject(scale)
    local calfuc = CCCallFunc:create(next1Func)
    actionArray:addObject(calfuc)
    local seq = CCSequence:create(actionArray)
    play2:runAction(seq)
end

--赵云
function player10( ... )
     AudioUtil.playEffect("audio/overture/boy_down.mp3")
    --03452
    local play2 = BattleCardUtilLee.getBattlePlayerCard(playerFormation["1"])
    play2:setPosition(PlayerCardLayerLee.getPointByPosition(1))
    -- play2:setPosition(ccps(0.5, 0.5))
    backgroundLayer:addChild(play2)

    play2:setScale(5)

    local next1Func = function ( ... )
        ZhenPing(function ( ... )
            local talkLayer = TalkLayer.createTalkLayer(117)
            runningScene:addChild(talkLayer,99999999)
            TalkLayer.setCallbackFunction(player11)           
        end)
    end

    local actionArray = CCArray:create()
    local scale  = CCScaleTo:create(0.3, 1)
    actionArray:addObject(scale)
    local calfuc = CCCallFunc:create(next1Func)
    actionArray:addObject(calfuc)
    local seq = CCSequence:create(actionArray)
    play2:runAction(seq)
end
--吕布
function player11( ... )
    AudioUtil.playEffect("audio/overture/boy_down.mp3")
    --03452
    local play2 = BattleCardUtilLee.getBattlePlayerCard(playerFormation["2"])
    play2:setPosition(PlayerCardLayerLee.getPointByPosition(2))
    -- play2:setPosition(ccps(0.5, 0.5))
    backgroundLayer:addChild(play2)

    play2:setScale(5)

    local next1Func = function ( ... )
        ZhenPing(function ( ... )
            local talkLayer = TalkLayer.createTalkLayer(119)
            runningScene:addChild(talkLayer,99999999)
            TalkLayer.setCallbackFunction(player12)
        end)
    end

    local actionArray = CCArray:create()
    local scale  = CCScaleTo:create(0.3, 1)
    actionArray:addObject(scale)
    local calfuc = CCCallFunc:create(next1Func)
    actionArray:addObject(calfuc)
    local seq = CCSequence:create(actionArray)
    play2:runAction(seq)
end

--貂蝉
function player12( ... )
    AudioUtil.playEffect("audio/overture/jiaochan_down.mp3")
    --03452
    local play2 = BattleCardUtilLee.getBattlePlayerCard(playerFormation["5"])
    play2:setPosition(PlayerCardLayerLee.getPointByPosition(5))
    -- play2:setPosition(ccps(0.5, 0.5))
    backgroundLayer:addChild(play2)

    play2:setScale(5)

    local next1Func = function ( ... )
        ZhenPing(function ( ... )
            print("talk ")
            local talkLayer = TalkLayer.createTalkLayer(118)
            runningScene:addChild(talkLayer,99999999)
            TalkLayer.setCallbackFunction(play13)
        end)
    end

    local actionArray = CCArray:create()
    local scale  = CCScaleTo:create(0.3, 1)
    actionArray:addObject(scale)
    local calfuc = CCCallFunc:create(next1Func)
    actionArray:addObject(calfuc)
    local seq = CCSequence:create(actionArray)
    play2:runAction(seq)
end

function play13()
    print("play13")

    local actionArray = CCArray:create()
    local dely  = CCDelayTime:create(0.1)
    actionArray:addObject(dely)
    local calfuc = CCCallFunc:create(function ( ... )
        local talkLayer = TalkLayer.createTalkLayer(120)
        runningScene:addChild(talkLayer,99999999)
        TalkLayer.setCallbackFunction(exitLayer)
    end)
    actionArray:addObject(calfuc)
    local seq = CCSequence:create(actionArray)
    runningScene:runAction(seq)
end

function exitLayer( ... )
    print("exitLayer")

    backgroundLayer:removeChildByTag(kGuanYuTag, true)
    local actionArray = CCArray:create()
    local dely = CCDelayTime:create(0.8)
    actionArray:addObject(dely)
    local calfuc = CCCallFunc:create(function ( ... )
        backgroundLayer:removeFromParentAndCleanup(true)
    end)
    actionArray:addObject(calfuc)
    local seq = CCSequence:create(actionArray)
    runningScene:runAction(seq)

    overCallback()
end

function ZhenPing( p_callback )

    local size      = ccp(runningScene:getPositionX(), runningScene:getPositionY())
    local left1     = CCMoveBy:create(0.05,ccp(5,0))
    local right1    = CCMoveBy:create(0.05,ccp(-5,0))
    local top1      = CCMoveBy:create(0.05,ccp(0,5))
    local rom1      = CCMoveBy:create(0.05,ccp(0,-5))
    local goPos     = CCMoveTo:create(0,size)
    local callback  = CCCallFunc:create(p_callback)

    local actionArray = CCArray:create()
    actionArray:addObject(left1)
    actionArray:addObject(right1)
    actionArray:addObject(top1)
    actionArray:addObject(rom1)
    actionArray:addObject(goPos)
    actionArray:addObject(callback)

    local action3   = CCSequence:create(actionArray)
    runningScene:runAction(action3);
end



