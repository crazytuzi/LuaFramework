-- FileName: FightDefAction.lua 
-- Author: lichenyang 
-- Date: 13-9-29 
-- Purpose: 战斗主场景

module("FightDefAction", package.seeall)

--[[
    @des:描述
    @parm:parm1 描述
    @ret:ret 描述
--]]
function playReaction( pBlockInfo, pCallback )
    --是否跳过
    if FightMainLoop.getIsSkip() == true then
        return
    end
    -- print("playReaction function")
    local atkHid    = pBlockInfo.attacker
    local atkCard   = FightScene.getCardByHid(atkHid)
    local dressId   = atkCard:getEntity():getDressId()
    local htid      = atkCard:getEntity():getHtid()
    local skillId   = pBlockInfo.action
    local skillInfo = BT_Skill.getDataById(skillId, dressId, htid)
    local mainDefId = pBlockInfo.defender
    local otherDefIds = {}

    if not  pBlockInfo.arrReaction then
        pCallback()
        return
    end

    for k,v in pairs(pBlockInfo.arrReaction) do
        table.insert(otherDefIds, v.defender)
    end
    --1.播放打击特效
    --2.播放被打击动作
    --3.播放伤害特效
    --4.播放掉血数字暴击和招架效果
    
    local playCallback = function ( ... )
        --总伤害
        showTotalDamage(pBlockInfo)
        performWithDelay(FightScene.getFightLayer(),function ( ... )
            pCallback()
        end,1.0)
    end
    --更新卡牌状态
    -- FightCardStatus.updateDefenderRage(pBlockInfo)
    FightCardStatus.updateDefenderHp(pBlockInfo)
    FightCardStatus.updateAttackerHp(pBlockInfo)
    --是否播放整容特效
    if skillInfo.meffectType == 2 then
        playFormationHitEffect(pBlockInfo, function ()
            playCallback()
        end)
    else
        playCardHitEffect(pBlockInfo, function ()
            playCallback()
        end)
    end
end

--[[
    @des:播放在整个阵型上的击中特效
    @parm:pSkillId  块数据
    @parm:pHid      执行卡牌id
--]]
function playFormationHitEffect( pBlockInfo, pCallback )
    --是否跳过
    if FightMainLoop.getIsSkip() == true then
        return
    end
    local atkHid    = pBlockInfo.attacker
    local atkCard   = FightScene.getCardByHid(atkHid)
    local dressId   = atkCard:getEntity():getDressId()
    local htid      = atkCard:getEntity():getHtid()
    local skillId   = pBlockInfo.action
    local skillInfo = BT_Skill.getDataById(skillId, dressId, htid)
    local mainDefId = pBlockInfo.defender
    local otherDefIds = {}
    for k,v in pairs(pBlockInfo.arrReaction) do
        table.insert(otherDefIds, v.defender)
    end

    local playCallback = function ( ... )
        if pCallback then
            pCallback()
        end
    end

    local effectLayer = nil
    local mainDefCard = FightScene.getCardByHid(mainDefId)
    if mainDefCard:isEnemy() then
        effectLayer = FightScene.getEnemyCardLayer()
        -- print("FightScene.getEnemyCardLayer()", effectLayer.getHeight())
    else
        effectLayer = FightScene.getPlayerCardLayer()
        -- print("FightScene.getPlayerCardLayer()", effectLayer.getHeight())
    end
    -- print("skillInfo.attackEffct", skillInfo.attackEffct)
    if skillInfo.attackEffct then
        skillInfo.spell_effect = skillInfo.spell_effect or skillInfo.attackEffct
        AudioUtil.playEffect("audio/effect/"..skillInfo.spell_effect..".mp3")
        local effectPaht = FightUtil.getEffectPath(skillInfo.attackEffct, atkCard:isEnemy())
        local effect = XMLSprite:create(effectPaht)
        effect:setPosition(g_winSize.width/2, effectLayer.getHeight())
        effect:setReplayTimes(1, true)
        FightScene:getEffectLayer():addChild(effect, ZOrderType.EFFECT)
        effect:setScale(g_fElementScaleRatio)
        effect:registerKeyFrameCallback(function ()
            --播放受伤特效
            for k,v in pairs(otherDefIds) do
                playHurtEffect(pBlockInfo, v, effect:getKeyFrameCount())
            end
        end)
        effect:registerEndCallback(function ()
            if effect:getKeyFrameCount() == 0 then
                playHurtEffect(pBlockInfo, v, 1)
            end
            playCallback()
            print("play formation hit effect finish 1")
        end)
    else
        --播放受伤特效
        print("play formation hit effect finish 2")
        for k,v in pairs(otherDefIds) do
            playHurtEffect(pBlockInfo, v, 1)
        end
        playCallback()
    end
end

--[[
    @des:播放在卡牌上面的打击效果
    @parm:pBlockInfo 块数据 
    @parm:pCallback  块数据
--]]
function playCardHitEffect( pBlockInfo, pCallback )
    --是否跳过
    if FightMainLoop.getIsSkip() == true then
        return
    end
    local atkHid    = pBlockInfo.attacker
    local atkCard   = FightScene.getCardByHid(atkHid)
    local dressId   = atkCard:getEntity():getDressId()
    local htid      = atkCard:getEntity():getHtid()
    local skillId   = pBlockInfo.action
    local skillInfo = BT_Skill.getDataById(skillId, dressId, htid)
    local mainDefId = pBlockInfo.defender
    local otherDefIds = {}
    for k,v in pairs(pBlockInfo.arrReaction) do
        table.insert(otherDefIds, v.defender)
    end

    local playCallback = function ( ... )
        if pCallback then
            pCallback()
        end
    end

    local playCount = table.count(otherDefIds)
    local playNum = 0

    for k,v in pairs(otherDefIds) do
        local card   = FightScene.getCardByHid(v)
        
        -- print("effectPath","skillInfo.attackEffct", effectPath, skillInfo.attackEffct)
        if skillInfo.attackEffct then --and skillInfo.attackEffctPosition  then
            local cardPos = card:convertToWorldSpace(ccpsprite(0.5, 0.5, card))
            local effect = nil
            -- 没有挂点 则打击特效挂在攻击者身上 有挂点在挂在被攻击者身上（这个是个二逼约定）
            if skillInfo.attackEffctPosition then
                local effectPath = FightUtil.getEffectPath(skillInfo.attackEffct, card:isEnemy())
                effect = XMLSprite:create(effectPath)
                effect:setPosition(getHitEffectPos(skillInfo.attackEffctPosition, card))
            else
                local effectPath = FightUtil.getEffectPath(skillInfo.attackEffct, atkCard:isEnemy())
                effect = XMLSprite:create(effectPath)
                effect:setPosition(getHitEffectPos(CardEffectPos.HERT, atkCard))
            end
            -- effect:setPosition(getHitEffectPos(skillInfo.attackEffctPosition, card))
            effect:setReplayTimes(1, true)
            FightScene:getEffectLayer():addChild(effect, ZOrderType.EFFECT)
            effect:setScale(g_fElementScaleRatio)
            effect:registerKeyFrameCallback(function ()
                 --播放受伤特效
                playHurtEffect(pBlockInfo, v, effect:getKeyFrameCount())
            end)
            effect:registerEndCallback(function ()    
                playNum = playNum + 1
                if playNum == playCount then
                    playCallback()
                end
            end)
            skillInfo.spell_effect = skillInfo.spell_effect or skillInfo.attackEffct
            AudioUtil.playEffect("audio/effect/"..skillInfo.spell_effect .. ".mp3")
        else
            playNum = playNum + 1
            playHurtEffect(pBlockInfo, v, 1)
            if playNum == playCount then
                playCallback()
            end
        end
    end
end

--[[
    @des:播放伤害特效
    @parm:pBlockInfo 战斗块数据
    @parm:pDefId 被攻击者id
    @parm:pCount 特效打击次数
    @parm:pCallback 播放完毕回调
    @ret:ret 描述
--]]
function playHurtEffect( pBlockInfo, pDefId, pCount, pCallback )
    print("playHurtEffect function")
    --是否跳过
    if FightMainLoop.getIsSkip() == true then
        return
    end
    local card      = FightScene.getCardByHid(pDefId)
    local atkHid    = pBlockInfo.attacker
    local atkCard   = FightScene.getCardByHid(atkHid)
    local dressId   = atkCard:getEntity():getDressId()
    local htid      = atkCard:getEntity():getHtid()
    local skillId   = pBlockInfo.action
    local skillInfo = BT_Skill.getDataById(skillId, dressId, htid)
    local defBlock = nil
    for k,v in pairs(pBlockInfo.arrReaction) do
        if tonumber(v.defender) == tonumber(pDefId) then
            defBlock = v
        end
    end
    --播放伤害动作
    local reaction = tonumber(defBlock.reaction)
    local isFatal  = defBlock.fatal
    --是否播放伤害动作
    if skillInfo.showDamageAction == 1 then
        local actionPath = nil
        if reaction == ReactionType.HIT then
            --击中
            actionPath = FightUtil.getActionXmlPaht(CardAction.hurt1)
            card:runXMLAction(actionPath)
        elseif reaction == ReactionType.DODGE then
            --闪避
            actionPath = FightUtil.getActionXmlPaht(CardAction.dodge)
            card:runXMLAction(actionPath)
        elseif reaction == ReactionType.PARRY then
            --招架
                
        end
    end
    --播放伤害特效
    -- print("skillInfo.hitEffct", skillInfo.hitEffct)
    if skillInfo.hitEffct then
        local effectPath = FightUtil.getEffectPath(skillInfo.hitEffct, card:isEnemy())
        -- print("hitEffct path", effectPath)
        if effectPath then
            local cardPos = card:convertToWorldSpace(ccpsprite(0.5, 0.5, card))
            local effect = XMLSprite:create(effectPath)
            effect:setPosition(cardPos)
            effect:setReplayTimes(1, true)
            FightScene:getEffectLayer():addChild(effect, ZOrderType.EFFECT)
            effect:setScale(g_fElementScaleRatio)
            effect:registerEndCallback(function ( ... )
                -- pCallback()
                --显示状态图标
                playTipIcon(card, reaction, isFatal)
                --有伤害播放掉血
                if not table.isEmpty(defBlock.arrDamage) then
                    --减掉卡牌血量
                    local damageValue = FightStrModel.getAtkDamageValue(pBlockInfo, pDefId)
                    --播放掉血动画
                    card:showAddHpEffect(-damageValue, pCount, isFatal)
                end
            end)
            skillInfo.hit_effect = skillInfo.hit_effect or skillInfo.hitEffct
            AudioUtil.playEffect("audio/effect/"..skillInfo.hit_effect .. ".mp3")
        end
    else
        --显示状态图标
        playTipIcon(card, reaction, isFatal)
        -- pCallback()
        if not table.isEmpty(defBlock.arrDamage) then
            --减掉卡牌血量
            local damageValue = FightStrModel.getAtkDamageValue(pBlockInfo, pDefId)
            --播放掉血动画
            card:showAddHpEffect(-damageValue, pCount, isFatal)
        end
    end
end


--[[
    @des:播放提示图标
    @parm:pCard 播放卡牌
    @parm:pReactionType 反应类型
    @parm:pIsFatal 是否暴击
    @parm:pCallback 播放完毕回调
    @ret:void
--]]
function playTipIcon( pCard, pReactionType, pIsFatal, pCallback)
    print("pCard, pReactionType, pIsFatal", pCard, pReactionType, pIsFatal)
    --是否跳过
    if FightMainLoop.getIsSkip() == true then
        return
    end
    --判断卡牌存在
    if tolua.isnull(pCard) then
        return
    end
    local reactionIcons = {
        [ReactionType.DODGE] = "images/battle/number/dodge.png",    --闪避
        [ReactionType.PARRY] = "images/battle/number/block.png",    --招架
        [ReactionType.FATAL] = "images/battle/number/critical.png", --暴击
    }
    local cardPos = pCard:convertToWorldSpace(ccpsprite(0.5, 0.95, pCard))
    --暴击提示
    local fatalIcon = CCSprite:create(reactionIcons[ReactionType.FATAL])
    fatalIcon:setAnchorPoint(ccp(0.5,0.5))
    fatalIcon:setPosition(cardPos)
    print("fatalIcon, ZOrderType.TIP", fatalIcon, ZOrderType.TIP)
    FightScene:getEffectLayer():addChild(fatalIcon, ZOrderType.TIP)
    fatalIcon:setVisible(false)
    fatalIcon:setScale(g_fElementScaleRatio)

    --其他反应提示
    local reactionIcon = nil
    if reactionIcons[pReactionType] then
        reactionIcon = CCSprite:create(reactionIcons[pReactionType])
        reactionIcon:setAnchorPoint(ccp(0.5,0.5))
        reactionIcon:setPosition(cardPos)
        FightScene:getEffectLayer():addChild(reactionIcon, ZOrderType.TIP)
        reactionIcon:setScale(g_fElementScaleRatio)
    end

    print("pIsFatal,reactionIcons[pReactionType]",pIsFatal,reactionIcons[pReactionType])

    if pIsFatal and reactionIcons[pReactionType] then
        --有暴击，有其他，先播放暴击，在播放其他的
        print("play fatal tip icon!")
        fatalIcon:setVisible(true)
        runIconTipAction(fatalIcon,function ( ... )
            if reactionIcons[pReactionType] then
                runIconTipAction(reactionIcon)
            end
        end)
    elseif pIsFatal and reactionIcons[pReactionType] == nil then
        --有暴击，没其他
        fatalIcon:setVisible(true)
        runIconTipAction(fatalIcon)
    else
        --没有暴击
        fatalIcon:removeFromParentAndCleanup(true)
        if reactionIcons[pReactionType] then
            runIconTipAction(reactionIcon)
        end
    end
end

--[[
    @des:播放提示图标特效action
    @parm:icon 提示图标
    @parm:pCallbac 播放完毕回调
--]]
function runIconTipAction( pIcon, pCallback )
    --是否跳过
    if FightMainLoop.getIsSkip() == true then
        return
    end
    local actionArray = CCArray:create()
    actionArray:addObject(CCFadeIn:create(0.3))
    actionArray:addObject(CCDelayTime:create(0.7))
    actionArray:addObject(CCFadeOut:create(0.3))
    actionArray:addObject(CCCallFuncN:create(function ( node )
        node:removeFromParentAndCleanup(true)
        if pCallback then
            pCallback()
        end
    end))
    pIcon:runAction(CCSequence:create(actionArray))
end

--[[
    @des:显示总伤害
    @parm:总伤害值
    @ret:
--]]
function showTotalDamage(pBlockInfo)
    if FightMainLoop.getIsSkip() then
        return
    end

    local defCount = FightStrModel.getDefenderCount(pBlockInfo)
    local keyCount = FightStrModel.getAttackKeyFrameCount(pBlockInfo)
    local totalNum = tonumber(pBlockInfo.totalNum) or 0
    --伤害小于等于0，则不显示总伤害
    if totalNum <= 0 then
        return
    end
    --被攻击武将数量大于1显示
    local runEffect = function ( ... )
        if defCount >1 or keyCount >1 or pBlockInfo.showTotal then
            AudioUtil.playEffect("audio/effect/zongshanghai.mp3")
            local effectPath = FightUtil.getEffectPath("zongshanghai")
            local effect = XMLSprite:create(effectPath)
            effect:setPosition(ccps(0.5,0.5))
            effect:setReplayTimes(1, true)
            FightScene:getEffectLayer():addChild(effect, ZOrderType.EFFECT)
            effect:setScale(g_fElementScaleRatio)
            
            local numberPath = "images/battle/number/red"
            local hpNumLabel = BTNumerLabel:createWithPath(numberPath,totalNum)
            hpNumLabel:setPosition(100, 0)
            hpNumLabel:setAnchorPoint(ccp(0.5, 0.5))
            effect:addChild(hpNumLabel, 10)
        end
    end
    performWithDelay(FightScene.getFightLayer(), runEffect, 0.2)
end

--[[
    @des:得到打击特效播放位置
    @parm:pPos 特效挂点
    @parm:pCard 播放特效的卡片
    @ret: postion
--]]
function getHitEffectPos( pPos, pCard )
    local pos = tonumber(pPos) or CardEffectPos.HERT
    local posMap = {
        [CardEffectPos.HEAD] = ccpsprite(0.5, 0.9, pCard),
        [CardEffectPos.HERT] = ccpsprite(0.5, 0.5, pCard),
        [CardEffectPos.FOOT] = ccpsprite(0.5, 0.1, pCard),
    }
    local resultPos = pCard:convertToWorldSpace(posMap[pos])
    return resultPos
end

