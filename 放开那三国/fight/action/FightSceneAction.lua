-- FileName: FightSceneAction.lua
-- Author: lichenyang
-- Date: 2014-04-00
-- Purpose: 战斗场景动作
--[[TODO List]]

module("FightSceneAction", package.seeall)


local kShakeActionTag = 9001

--[[
    @des: 播放战斗开场特效
--]]
function playStartEffect( pCallBack )
    -- pCallBack()
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    local openEffect= XMLSprite:create("images/battle/effect/chuchangyun", 60)
    openEffect:setPosition(g_winSize.width/2,g_winSize.height*0.5)
    openEffect:setScale(g_fBgScaleRatio)
    openEffect:setReplayTimes(1, true)
    openEffect:registerEndCallback(function ( ... )
        if pCallBack then
            pCallBack()
        end
    end)
    runningScene:addChild(openEffect, 5000)
end

--[[
    @des:开始震屏
--]]
function startShake()
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    if(runningScene:getActionByTag(kShakeActionTag)==nil)then
        local action = schedule(runningScene,doShake,0.05)
        action:setTag(kShakeActionTag)
    end
end

--[[
    @des:震屏
--]]
function doShake()
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    math.randomseed(os.time())
    local wHight = CCDirector:sharedDirector():getWinSize().height
    local shakeY = math.floor(math.random()*3+1)*wHight*0.003
    if(runningScene:getPositionY()>=0) then
        shakeY = -shakeY
    end
    runningScene:setPosition(0,shakeY)
end

--[[
    @des:结束震屏
--]]
function endShake()
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:stopActionByTag(kShakeActionTag)
    runningScene:setPosition(0,0)
end

--[[
    @des:显示对话
    @parm:pTalkTime 对话时间
--]]
function playTalk( pTalkTime, pCallBack)
    print("playTalk pTalkTime", pTalkTime)
    --是否跳过
    if FightMainLoop.getIsSkip() == true then
        return
    end
    local isFirst = FightModel.getIsFirstEnter()
    if isFirst == false then
        pCallBack()
        return
    end
    local armyIndex = FightMainLoop.getArmyIndex()
    local armyInfo = FightModel.getArmyInfoByIndex(armyIndex)
    local talkId = nil
    local round  = nil
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    local talkCallback = function ()
        print("armyInfo.dialog_scene_over", armyInfo.dialog_scene_over)
        print("armyInfo.dialog_music_over", armyInfo.dialog_music_over)
        --对话完毕换背景
        if armyInfo.dialog_scene_over then
            local overBgInfo = string.split(armyInfo.dialog_scene_over, "|")
            local overTalkId = tonumber(overBgInfo[1])
            local overBgName = overBgInfo[2]
            if overTalkId == tonumber(talkId) then
                local fightBg = FightScene.getFightBg()
                fightBg:setBgName(overBgName)
            end
        end
        --对话完毕换背景音乐
        if armyInfo.dialog_music_over then
            local musicBgInfo = string.split(armyInfo.dialog_music_over, "|")
            local musicTalkId = tonumber(musicBgInfo[1])
            local musicBgName = musicBgInfo[2]
            if musicTalkId == tonumber(talkId) then
                AudioUtil.playBgm("audio/bgm/" .. musicBgName)
            end
        end
        pCallBack()
    end
    if pTalkTime == FightTalkTime.BEFORE then
        talkId = armyInfo.dialog_id_pre
    elseif pTalkTime == FightTalkTime.ROUND then
        talkId = armyInfo.dialog_id_pre
        round  = 1
    elseif pTalkTime == FightTalkTime.END then
        talkId = armyInfo.dialog_id_over
    end
    print("playTalk :", talkId)
    if talkId then
        require "script/ui/talk/talkLayer"
        local talkLayer = TalkLayer.createTalkLayer(talkId)
        runningScene:addChild(talkLayer,999999)
        TalkLayer.setCallbackFunction(talkCallback)
    else
        pCallBack()
    end
end

--[[
    @des:移动到下一个部队
--]]
function moveToArmy( pCallBack )
    --是否跳过
    if FightMainLoop.getIsSkip() == true then
        return
    end
    --清除墓碑特效
    FightSceneAction.removeDeadEffect()
    local playCardLayer = FightScene.getPlayerCardLayer()
    playCardLayer:playDeadEffect()
    
    local fightBg = FightScene.getFightBg()
    local armyIndex = FightMainLoop.getArmyIndex()
    local armyInfo = FightModel.getArmyInfoByIndex(armyIndex)
    if tonumber(armyInfo.appear_style) == EnemyAppearType.NORMAL then
        --1.判断是否要先创建敌方卡牌
        local enemyHids = FightModel.getHidsByArmyIndex(armyIndex)
        local enemyLayer = EnemyCardNode:createWithIds(enemyHids)
        FightScene.setEnemyCardLayer(enemyLayer)
        local offsetY = fightBg:getMoveDistance()
        enemyLayer:setPosition(0, offsetY)
        enemyLayer:runAction(CCMoveBy:create(2.5, ccp(0, -offsetY)))
        --2.卡牌行走动画
        playCardLayer:playWalkEffect()
        --3.背景移动到目标位置
        fightBg:moveToNext(function ()
            playCardLayer:stopAction()
            pCallBack()
        end)
    else
        pCallBack()
    end
end

--[[
    @des:播放npc部队出场特效
--]]
function playEnemyAppearEffect(pCallBack )
    --是否跳过
    if FightMainLoop.getIsSkip() == true then
        return
    end
    local fightBg = FightScene.getFightBg()
    local playCardLayer = FightScene.getPlayerCardLayer()
    local armyIndex = FightMainLoop.getArmyIndex()
    local armyInfo = FightModel.getArmyInfoByIndex(armyIndex)
    --普通模式，则无需创建
    if tonumber(armyInfo.appear_style) == EnemyAppearType.NORMAL then
        pCallBack()
        return
    end
    --特效闪现
    if tonumber(armyInfo.appear_style) == EnemyAppearType.FLASH then
        --创建敌方卡牌
        local enemyHids = FightModel.getHidsByArmyIndex(armyIndex)
        local enemyLayer = EnemyCardNode:createWithIds(enemyHids)
        FightScene.setEnemyCardLayer(enemyLayer)
        enemyLayer:setCardVisible(false)

        local playCount = table.count(enemyLayer._cardMap)
        local playNum   = 0
        local playCallback = function ( ... )
            playNum = playNum + 1
            print("playNum", playNum, playCount)
            if playNum == playCount then
                pCallBack()
                return
            end
        end
        for k,v in pairs(enemyLayer._cardMap) do
            local effectPos = v:convertToWorldSpace(ccpsprite(0.5, 0.5, v))
            local appearEffect = XMLSprite:create("images/battle/effect/meffevt_15")
            appearEffect:setPosition(effectPos)
            appearEffect:setReplayTimes(1, true)  
            appearEffect:setScale(g_fElementScaleRatio)
            FightScene.getEffectLayer():addChild(appearEffect, ZOrderType.EFFECT)
            appearEffect:registerEndCallback(function ( ... )
                v:setVisible(true)
                playCallback()
            end)
        end
    end
    --主动出现
    if tonumber(armyInfo.appear_style) == EnemyAppearType.DOWN then
        local enemyHids = FightModel.getHidsByArmyIndex(armyIndex)
        local enemyLayer = EnemyCardNode:createWithIds(enemyHids)
        FightScene.setEnemyCardLayer(enemyLayer)
        local offsetY = enemyLayer:getHeight() + 50 * g_fElementScaleRatio
        enemyLayer:setPosition(0, offsetY)
        --1.卡牌行走动画
        enemyLayer:playWalkEffect()
        local actionArray = CCArray:create()
        actionArray:addObject(CCMoveBy:create(2.5, ccp(0, -offsetY)))
        actionArray:addObject(CCCallFunc:create(function ( ... )
            enemyLayer:stopAction()
            pCallBack()
            return
        end))
        local action = CCSequence:create(actionArray)
        enemyLayer:runAction(action)
    end
end

--[[
    @des:播放我方npc出场特效
--]]
function playNpcAppear( pCallBack )
    print("playNpcAppear")
    --是否跳过
    if FightMainLoop.getIsSkip() == true then
        return
    end
    local baseLv = FightModel.getBaseLv()
    --非npc战斗直接return
    if baseLv ~= 0 then
        pCallBack()
        return
    end
    local newHero = {}
    local newFmt = FightModel.getHerolist()
    local oldFmt = FightModel.getBattleFormation()
    for k,v in pairs(newFmt) do
        if oldFmt[k]==0 and v~=0 then
            newHero[k] = v
        end
    end
    if table.isEmpty(newHero) then
        pCallBack()
        return
    end
    --更新战斗阵型
    FightModel.setBattleFormation(newFmt)
    local playNum = 0
    local playCount = table.count(newHero)
    local playCallback = function ( ... )
        playNum = playNum + 1
        print("PlayNpcAppear playNum", playNum, playCount)
        if playNum == playCount then
            pCallBack()
            return
        end
    end
    local playCardLayer = FightScene.getPlayerCardLayer()
    for k,v in pairs(newHero) do
        playCardLayer:setHeroByPos(v, k+1)
        local card = FightScene.getCardByHid(v)
        card:setVisible(false)
        local effectPos = card:convertToWorldSpace(ccpsprite(0.5, 0.5, card))
        local appearEffect = XMLSprite:create("images/battle/effect/meffevt_15")
        appearEffect:setPosition(effectPos)
        appearEffect:setReplayTimes(1, true)  
        appearEffect:setScale(g_fElementScaleRatio)
        FightScene:getEffectLayer():addChild(appearEffect, ZOrderType.EFFECT)
        appearEffect:registerEndCallback(function ( ... )
            card:setVisible(true)
            playCallback()
        end)
    end
end

--[[
    @des:更新阵型
--]]
function switchForamtion( pCallBack )
    --是否托管
    if FightModel.getbType() ~= BattleType.ELITE then
        pCallBack()
        return
    else
        if FightModel.getAutoBattle() then
            pCallBack()
            return
        end
    end
    local playCardLayer = FightScene.getPlayerCardLayer()
    FightUILayer.setDoBattleVisible(true)
    playCardLayer:setSwitchMode(true)
    FightUILayer.setDoBattleCallback(function ( ... )
        playCardLayer:setSwitchMode(false)
        FightUILayer.setDoBattleVisible(false)
        pCallBack()
    end)
end

--[[
    @des:请求战斗数据
--]]
function requestBattleInfo( pCallBack )
    local requestCallback = function ( pFightRet )
        --1.刷新战斗数据
        FightStrModel.setFightRet(pFightRet)
        --2.刷新地方卡牌层
        local playerLayer = PlayerCardNode:createWithTeamInfo(FightStrModel.getPlayerInfo())
        FightScene.setPlayerCardLayer(playerLayer)
        --3.刷新玩家卡牌层
        local enemyLayer = EnemyCardNode:createWithTeamInfo(FightStrModel.getEnemyInfo())
        FightScene.setEnemyCardLayer(enemyLayer)
        --4.显示玩家怒气，血量
        playerLayer:setHpVisible(true)
        playerLayer:setRageVisible(true)
        pCallBack()
    end
    FightController.doBattle(requestCallback)
end

--[[
    @des:显示战斗结算面板
--]]
function showCopyAfterBattleLayer()
    local bType   = FightModel.getbType()
    local copyId  = FightModel.getCopyId()
    local baseId  = FightModel.getBaseId()
    local armInx  = FightMainLoop.getArmyIndex()
    local armyId  = FightModel.getArmyIdByIndex(armInx)
    local baseLv  = FightModel.getBaseLv()
    local itemAry = FightModel.getItemArray()
    local heroAry = FightModel.getHeroArray()
    local silver  = FightModel.getSilver()
    local exp     = FightModel.getExpNum()
    local soul    = FightModel.getSoul()
    local isWin   = FightModel.getResult()
    --精英副本
    require "script/battle/BattleReportLayer"
    local reportLayer = BattleReportLayer.getBattleReportLayer(isWin, copyId, baseId, baseLv, soul, itemAry, silver, exp, bType, heroAry, false)
    FightScene.setReportLayer(reportLayer)
    FightScene.showAfterBattleLayer()
end

--[[
    @des:删除墓碑
--]]
function removeDeadEffect( ... )
    local deadEffs = FightModel.getDeadEffs()
    for k,v in pairs(deadEffs) do
        if not tolua.isnull(v) then
            v:removeFromParentAndCleanup(true)
            deadEffs[k] = nil
        end
    end
end

--[[
    @des:跳过战斗
--]]
function skipFightAction( pCallBack )
    --副本模式有跳过限制
    if FightModel.getbModel() == BattleModel.COPY then
        if(FightModel.getIsFirstEnter() == true) then
            if(FightModel.canSkipBattle() == false) then
                return
            end
        end
    end
    FightUILayer.setSkipVisible(false)
    FightMainLoop.setIsSkip(true)
    local playCardLayer = FightScene.getPlayerCardLayer()
    local enemyCardLayer = FightScene.getEnemyCardLayer()
    --所有的卡牌放到原始位置
    for k,v in pairs(playCardLayer._cardMap) do
        local card = FightScene.getCardByHid(v:getEntity():getHid())
        card:stopSchedule()
        card:stopAllActions()
        card:setPosition(playCardLayer:convertPNToPos(v:getEntity():getPosNum()))
        print("skipPos:"..card:getEntity():getName()..":"..card:getPositionX()..","..card:getPositionY())
    end
    --所有的卡牌放到原始位置
    for k,v in pairs(enemyCardLayer._cardMap) do
        local card = FightScene.getCardByHid(v:getEntity():getHid())
        card:stopSchedule()
        card:stopAllActions()
        card:setPosition(enemyCardLayer:convertPNToPos(v:getEntity():getPosNum()))
        print("skipPos:"..card:getEntity():getName()..":"..card:getPositionX()..","..card:getPositionY())
    end
    
    --清除所有特效
    local effectLayer = FightScene.getEffectLayer()
    effectLayer:removeAllChildrenWithCleanup(true)
    --清除所有的buffer
    playCardLayer:removeBuffer()
    enemyCardLayer:removeBuffer()
    
    --播放死亡特效
    local dieHids = FightStrModel.getDeadHids()
    local battleIndex = FightMainLoop.getBattleIndex()
    local playNum = 0
    print("skipFightAction dieHids count",table.count(dieHids))
    local playCallback = function ( ... )
        playNum = playNum + 1
        if playNum >= table.count(dieHids) then
            if FightModel.getbModel() == BattleModel.COPY then
                FightStrModel.clearData()
                performWithDelay(FightScene.getFightLayer(), function ( ... )
                     FightMainLoop.nextArmyCallback()
                    print("FightMainLoop.nextArmyCallback()")
                end, 1)
            else
                 performWithDelay(FightScene.getFightLayer(), function ( ... )
                    FightScene.showAfterBattleLayer()
                end, 1)
            end
        end
        print("skipFightAction playNum",playNum)
    end

    --所有的卡牌放到原始位置
    for k,v in pairs(playCardLayer._cardMap) do
        local damage = -FightStrModel.getRemainDamage(v:getEntity():getHid(), battleIndex)
        v:showAddHpEffect(damage, 1 ,false)
        v:addHp(damage)
    end
    --所有的卡牌放到原始位置
    for k,v in pairs(enemyCardLayer._cardMap) do
         local damage = -FightStrModel.getRemainDamage(v:getEntity():getHid(), battleIndex)
        v:showAddHpEffect(damage, 1 ,false)
        v:addHp(damage)
    end
    for k,v in pairs(dieHids) do
        local card = FightScene.getCardByHid(v)
        if not tolua.isnull(card) then
            card:setHpVisible(false)
            card:setNameVisible(false)
            card:setRageVisible(false)
            local point = nil
            if card:isEnemy() then
                point = enemyCardLayer:convertPNToPos(card:getEntity():getPosNum())
            else
                point = playCardLayer:convertPNToPos(card:getEntity():getPosNum())
            end
            card:setPosition(point)
            local actionPath = FightUtil.getActionXmlPaht(CardAction.die, card:isEnemy())
            card:runXMLAction(actionPath)
            card:registerActionEndCallback(function ()
                card:setIsDead(true)
                card:setVisible(false)
                card:setOpacity(0)
                playCallback()
            end)
        end
    end
    if table.count(dieHids) == 0 then
        playCallback()
    end
end