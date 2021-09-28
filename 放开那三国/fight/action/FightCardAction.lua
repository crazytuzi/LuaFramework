-- FileName: FightCardAction.lua
-- Author: licheng
-- Date: 2015-07-01
-- Purpose: 战斗中卡牌动作
--[[TODO List]]

module("FightCardAction", package.seeall)

--[[
	@des:执行循环中的一个动作
--]]
function playSkillAction(pBlockInfo, pCallback)
    print("FightScene playAction")
	--是否跳过
	if FightMainLoop.getIsSkip() == true then
		return
	end
	if pBlockInfo == nil then
        pCallback()
        return
	end
    --空动作数据块
    if FightStrModel.isNoAction(pBlockInfo) then
        pCallback()
        return
    end
    --更新攻击者怒气显示
    FightCardStatus.updateAttackerRage(pBlockInfo)

    --action为0的情况
    if tonumber(pBlockInfo.action) == 0 then
        FightAtkAction.playBufferEffect(pBlockInfo, pCallback)
        return
    end
    
    --skill 动作
    local attackHid = pBlockInfo.attacker
    local skillId   = pBlockInfo.action
    local card      = FightScene.getCardByHid(attackHid)
    local dressId   = card:getEntity():getDressId()
    local htid      = card:getEntity():getHtid()
    local skillInfo = BT_Skill.getDataById(skillId, dressId, htid)

    local playCardLayer = FightScene.getPlayerCardLayer()
    local enemyCardLayer = FightScene.getEnemyCardLayer()
    if card:isEnemy() then
    	enemyCardLayer:reorderChild(card, 100)
   	else
   		playCardLayer:reorderChild(card, 100)
   	end

    local playCallback = function ( ... )
    	local posNum = card:getEntity():getPosNum()
    	playCardLayer:reorderChild(card, posNum)
    	pCallback()
    end
    if skillInfo.mpostionType == AttackPos.NEAR then
        --近身释放
        FightAtkAction.playNearBodyEffect(pBlockInfo, playCallback)
    elseif skillInfo.mpostionType == AttackPos.SITU then
        --原地
        FightAtkAction.playOriginAttackEffect(pBlockInfo, playCallback)
    elseif skillInfo.mpostionType == AttackPos.SPECIFIED then
        --固定地点释放（移动到指定点释放一个弹道技能）
        FightAtkAction.playPosAttackEffect(pBlockInfo, playCallback)
    elseif skillInfo.mpostionType == AttackPos.SITU_BULLET then
        --原地有弹道（原地释放一个弹道技能）
        FightAtkAction.playBulletEffect(pBlockInfo, playCallback)
    elseif skillInfo.mpostionType == AttackPos.SITU_ROW then
        --固定地点同行贯穿
        FightAtkAction.playSameRowBulletEffect(pBlockInfo, playCallback)
    elseif skillInfo.mpostionType == AttackPos.MULTI_FAR then
        --多段远程
        FightAtkAction.playNearBodyEffect(pBlockInfo, playCallback)
    elseif skillInfo.mpostionType == AttackPos.SITU_STRIKE then
        --原地刺身
        FightAtkAction.playOriginAttackEffect(pBlockInfo, playCallback)
    elseif skillInfo.mpostionType == AttackPos.SITU_MULTI_BULLET then
        --原地不规则弹道
        FightAtkAction.playBulletEffect(pBlockInfo, playCallback)
    else
        FightAtkAction.playOriginAttackEffect(pBlockInfo, playCallback)
    end
    -- print("playAction")
end

--[[
	@des:播放卡牌攻击动作
	@parm:pSkillId 	块数据
	@parm:pHid 		执行卡牌id
--]]
function playAtkAction( pBlockInfo, pCallback )
	print("playAtkAction function")
	--是否跳过
	if FightMainLoop.getIsSkip() == true then
		return
	end
	local skillId = pBlockInfo.action
	local defendHid = pBlockInfo.attacker
	local attackHid = pBlockInfo.attacker
	local card = FightScene.getCardByHid(attackHid)
	--攻击者执行攻击动作
    local dressId   = card:getEntity():getDressId()
    local htid      = card:getEntity():getHtid()
    local skillInfo = BT_Skill.getDataById(skillId, dressId, htid)
    if skillInfo.actionid then
	    --播放人物攻击特效
	    local actionPath = FightUtil.getActionXmlPaht(skillInfo.actionid, card:isEnemy())
	    print("playAtkAction Path", actionPath)
	    card:runXMLAction(actionPath)
	    AudioUtil.playEffect("audio/effect/"..skillInfo.actionid..".mp3")
	    performWithDelay(FightScene.getFightLayer(), function ( ... )
			if pCallback then
				pCallback()
			end
		end,0.3)
	else
		if pCallback then
			pCallback()
		end
	end
    --播放攻击特效
    -- playAtkHitEffect(pBlockInfo)
end

--[[
	@des:播放攻击特效
	@parm:pSkillId 	动作id
	@parm:pHid 		执行卡牌id
--]]
function playAtkEffect( pBlockInfo, pCallback )
	print("playAtkEffect function")
	--是否跳过
	if FightMainLoop.getIsSkip() == true then
		return
	end
	local attackHid = pBlockInfo.attacker
	local skillId = pBlockInfo.action
	local atkCard = FightScene.getCardByHid(attackHid)
	local dressId   = atkCard:getEntity():getDressId()
    local htid      = atkCard:getEntity():getHtid()
	local skillInfo = BT_Skill.getDataById(skillId, dressId, htid)

	if skillInfo.skillEffect == nil then
		pCallback()
		return
	end

	--特效
	local effectPaht = FightUtil.getEffectPath(skillInfo.skillEffect, atkCard:isEnemy())
	local effect = XMLSprite:create(effectPaht)
	effect:setPosition(ccpsprite(0.5, 0.5, atkCard))
	atkCard:addChild(effect, 200)
	effect:setScale(g_fElementScaleRatio)
	effect:registerEndCallback(function ( ... )
		effect:removeFromParentAndCleanup(true)
		effect = nil
		pCallback()
	end)
end


--[[
	@des:播放技能打击效果
	@parm:pBlockInfo 
--]]
function playAtkHitEffect( pBlockInfo, pCallback )
	--是否跳过
	if FightMainLoop.getIsSkip() == true then
		return
	end
	local attackHid = pBlockInfo.attacker
	local skillId   = pBlockInfo.action
	local card      = FightScene.getCardByHid(attackHid)
	local dressId   = card:getEntity():getDressId()
	local htid      = card:getEntity():getHtid()
	local skillInfo = BT_Skill.getDataById(skillId, dressId, htid)
	--技能打击特效
	-- skillInfo.attackEffctPosition 
	-- 没有挂点 则打击特效挂在攻击者身上 有挂点在挂在被攻击者身上（这个是个二逼约定）
	if skillInfo.attackEffctPosition == nil and skillInfo.attackEffct and skillInfo.meffectType ~= 2 then
		local effectPaht = FightUtil.getEffectPath(skillInfo.attackEffct, card:isEnemy())
		local effect = XMLSprite:create(effectPaht)
		effect:setPosition(card:convertToWorldSpace(ccpsprite(0.5, 0.5, card)))
		FightScene:getEffectLayer():addChild(effect, ZOrderType.EFFECT)
		effect:registerEndCallback(function ( ... )
			effect:removeFromParentAndCleanup(true)
			effect = nil
			if pCallback then
				pCallback()
			end
		end)
	else
		if pCallback then
			pCallback()
		end
	end
end


--[[
    @des:播放怒气特效
    @parm:pBlockInfo
	@parm:pCallback
--]]
function playerRegeEffect( pBlockInfo, pCallback)
	print("playerRegeEffect function")
	--是否跳过
	if FightMainLoop.getIsSkip() == true then
		return
	end
	local attackHid = pBlockInfo.attacker
	local skillId   = pBlockInfo.action
	local atkCard      = FightScene.getCardByHid(attackHid)
	local dressId   = atkCard:getEntity():getDressId()
	local htid      = atkCard:getEntity():getHtid()
	local skillInfo = BT_Skill.getDataById(skillId, dressId, htid)

	--不是怒气技能则不释放
	if skillInfo.functionWay ~= FuntionWay.RAGE then
		pCallback()
		return
	end
	--地方卡牌怒气技能不释放
	if atkCard:isEnemy() == true then
		local effect = XMLSprite:create("images/battle/effect/meffect_31")
		effect:setPosition(atkCard:convertToWorldSpace(ccpsprite(0.5, 0.5, atkCard)))
		effect:setReplayTimes(1, true)
		FightScene.getEffectLayer():addChild(effect, ZOrderType.EFFECT)
		effect:setScale(g_fElementScaleRatio)
		effect:registerEndCallback(function ( ... )
			pCallback()
		end)
		--如果是怒气技能，则显示技能名称
		if skillInfo.functionWay == FuntionWay.RAGE then
			local pos = atkCard:convertToWorldSpace(ccpsprite(0.5, 0.8, atkCard))
			local nameBg = CCSprite:create("images/battle/skill_bg.png")
	        nameBg:setAnchorPoint(ccp(0.5,0.5))
	        nameBg:setPosition(pos)
	        FightScene.getEffectLayer():addChild(nameBg, ZOrderType.TIP)
	        nameBg:setScale(0)

	        local nameLabel = CCLabelTTF:create(skillInfo.name or "",g_sFontName,25)
	        nameLabel:setAnchorPoint(ccp(0.5,0.5))
	        nameLabel:setPosition(ccpsprite(0.5, 0.5, nameBg))
	        nameBg:addChild(nameLabel)

	        local actionArray = CCArray:create()
	        actionArray:addObject(CCScaleTo:create(0.2, g_fElementScaleRatio))
	        actionArray:addObject(CCDelayTime:create(0.4))
	        actionArray:addObject(CCCallFuncN:create(function ( pNode )
	        	pNode:removeFromParentAndCleanup(true)
	        end))
	        nameBg:runAction(CCSequence:create(actionArray))
		end
		return
	end
	--播放头像特效
	local regeHeadIconName = atkCard:getEntity():getDBConfig().rage_head_icon_id
	if regeHeadIconName == nil then
		pCallback()
	else
		local rageIconName = atkCard:getEntity():getRageHeadIconName()
		if rageIconName then
			AudioUtil.playEffect("audio/effect/nuqitouxiang.mp3")
			local effectPaht = "images/battle/effect/" .. "nuqitouxiang"
			local replaceIcon = "images/battle/rage_head/" .. rageIconName
			local headEffect = XMLSprite:create(effectPaht)
			headEffect:setPosition(ccps(0.5, 0.5))
			headEffect:replaceImage("nuqitouxiang_31", replaceIcon)
			headEffect:setReplayTimes(1, true)	
			FightScene.getEffectLayer():addChild(headEffect, ZOrderType.EFFECT)
			headEffect:setScale(g_fElementScaleRatio)
			headEffect:registerEndCallback(function ( ... )
				pCallback()
			end)
		end
		--播放文字特效
		local wordEffectPath = "images/battle/effect/" .. "nqtxjnmz"
		if skillInfo.icon then
			local replaceWordPath = "images/battle/rage_head/" .. skillInfo.icon
			local wordEffect = XMLSprite:create(wordEffectPath)
			wordEffect:setPosition(ccps(0.5, 0.5))
			wordEffect:setReplayTimes(1, true)	
			wordEffect:replaceImage("nqtxjnmz_01", replaceWordPath)
			FightScene.getEffectLayer():addChild(wordEffect, ZOrderType.EFFECT)
			wordEffect:setScale(g_fElementScaleRatio)
		end
	end
end

--[[
	@des:pCardA 移动到 pCardB 的正前方
	@parm:pCardA  pCardB
	@ret:
--]]
function moveAction( pCardAId, pCardBId, pCallback )
	--是否跳过
	if FightMainLoop.getIsSkip() == true then
		return
	end
	local atkCard = FightScene.getCardByHid(pCardAId)
	local defCard = FightScene.getCardByHid(pCardBId)

	local tarPos = defCard:convertToWorldSpace(ccpsprite(0.5, 0.5, defCard))
	if defCard:isEnemy() == true then
		tarPos.y = tarPos.y - (defCard:getContentSize().height - 20)*g_fElementScaleRatio
	else
		tarPos.y = tarPos.y + (defCard:getContentSize().height + 20)*g_fElementScaleRatio
	end
	local move = CCMoveTo:create(0.2, tarPos)
	local calfunc = CCCallFunc:create(function ( ... )
		pCallback()
	end)
	local actionArray = CCArray:create()
	actionArray:addObject(move)
	actionArray:addObject(calfunc)
	local seqAction = CCSequence:create(actionArray)
	atkCard:runAction(seqAction)
end

--[[
	@des:移动到指定点
	@parm:parm1 描述
	@ret:ret 描述
--]]
function moveTaretAction( pCardAtkId, pCardDefId, pTargetPos, pCallback )
	--是否跳过
	if FightMainLoop.getIsSkip() == true then
		return
	end
	local atkCard = FightScene.getCardByHid(pCardAtkId)
	local defCard = FightScene.getCardByHid(pCardDefId)

	local tarPos = ccp(g_winSize.width/2, g_winSize.height/2)
	local distance = (defCard:getContentSize().height/2 + 20)*g_fElementScaleRatio
	if defCard:isEnemy() == true then
		tarPos.y = g_winSize.height/2
	else
		tarPos.y = tarPos.y + distance
	end
	local move = CCMoveTo:create(0.2, tarPos)
	local calfunc = CCCallFunc:create(function ( ... )
		pCallback()
	end)
	local actionArray = CCArray:create()
	actionArray:addObject(move)
	actionArray:addObject(calfunc)
	local seqAction = CCSequence:create(actionArray)
	atkCard:runAction(seqAction)
end

--[[
	@des:移动到指定列
	@parm:parm1 描述
	@ret:ret 描述
--]]
function moveRowAction( pBlockInfo, pCallback )
	--是否跳过
	if FightMainLoop.getIsSkip() == true then
		return
	end
	local attackHid = pBlockInfo.attacker
	local defendHid = pBlockInfo.defender

	local atkCard = FightScene.getCardByHid(attackHid)
	local defCard = FightScene.getCardByHid(defendHid)

	local tarPos = defCard:convertToWorldSpace(ccpsprite(0.5, 0.5, defCard))
	for k,v in pairs(pBlockInfo.arrReaction) do
		local card = FightScene.getCardByHid(v.defender)
		local cardPos = card:convertToWorldSpace(ccpsprite(0.5, 0.5, card))
		if cardPos.y < tarPos.y and atkCard:isEnemy() == false then
			tarPos.y = cardPos.y
		elseif cardPos.y > tarPos.y and atkCard:isEnemy() == true then
			tarPos.y = cardPos.y
		end
	end
	--两个卡牌直接的间隔
	local distance = (defCard:getContentSize().height + 20)*g_fElementScaleRatio
	if atkCard:isEnemy() then
		tarPos.y = tarPos.y + distance
	else
		tarPos.y = tarPos.y - distance
	end
	local move = CCMoveTo:create(0.2, tarPos)
	local calfunc = CCCallFunc:create(function ( ... )
		pCallback()
	end)
	local actionArray = CCArray:create()
	actionArray:addObject(move)
	actionArray:addObject(calfunc)
	local seqAction = CCSequence:create(actionArray)
	atkCard:runAction(seqAction)
end


--[[
	@des:卡牌执行action返回值自己原始位置
	@parm:pCardId 卡牌id
	@ret:ret 描述
--]]
function moveBack(pCardId, pCallback)
	--是否跳过
	if FightMainLoop.getIsSkip() == true then
		return
	end
	local card = FightScene.getCardByHid(pCardId)
	card:stop()
	local playCardLayer = FightScene.getPlayerCardLayer()
	local enemyCardLayer = FightScene.getEnemyCardLayer()
	local point = nil
	if card:isEnemy() then
		point = enemyCardLayer:convertPNToPos(card:getEntity():getPosNum())
	else
		point = playCardLayer:convertPNToPos(card:getEntity():getPosNum())
	end
	local move = CCMoveTo:create(0.2, point)
	local calfunc = CCCallFunc:create(function ()
		pCallback()
	end)
	local actionArray = CCArray:create()
	actionArray:addObject(move)
	actionArray:addObject(calfunc)
	local seqAction = CCSequence:create(actionArray)
	card:runAction(seqAction)
end

--[[
	@des:播放一个弹道特效
	@parm:pCardId 打击者id
	@parm:pCallback
--]]
function runSingleBulletAction( pBlockInfo, pCardId, pCallback)
	--是否跳过
	if FightMainLoop.getIsSkip() == true then
		return
	end
	local attackHid  = pBlockInfo.attacker
	local skillId    = pBlockInfo.action
	local atkCard    = FightScene.getCardByHid(attackHid)
	local dressId    = atkCard:getEntity():getDressId()
	local htid       = atkCard:getEntity():getHtid()
	local skillInfo  = BT_Skill.getDataById(skillId, dressId, htid)

	print("----[runSingleBulletAction]----------")
	print("skillId, dressId, htid",skillId, dressId, htid)
	print("skillInfo.distancePath",skillInfo.distancePath)

	local defCard 	 = FightScene.getCardByHid(pCardId)

	local bulletPath = FightUtil.getEffectPath(skillInfo.distancePath, atkCard:isEnemy())
	local bulletEffect = XMLSprite:create(bulletPath)
	local beginPos = atkCard:convertToWorldSpace(ccpsprite(0.5, 0.5, atkCard))
	bulletEffect:setPosition(beginPos)
	FightScene.getEffectLayer():addChild(bulletEffect, ZOrderType.EFFECT)
	bulletEffect:setScale(g_fElementScaleRatio)
	local endPos      = defCard:convertToWorldSpace(ccpsprite(0.5, 0.5, defCard))
	--计算弹道角度
	local rotation = 0
	local reletivePoint = ccp(endPos.x-beginPos.x,endPos.y-beginPos.y)
	local rotation = math.deg(math.atan(math.abs(reletivePoint.x/reletivePoint.y)))
	if(reletivePoint.x<0)then
	    rotation = 360 - rotation
	end
	if(reletivePoint.y<0)then
	    rotation = rotation>180 and 540-rotation or 180-rotation
	end
	bulletEffect:setRotation(rotation)

	AudioUtil.playEffect("audio/effect/" .. skillInfo.distancePath .. ".mp3")
	local actionArray = CCArray:create()
	actionArray:addObject(CCMoveTo:create(0.4, endPos))
	actionArray:addObject(CCCallFuncN:create(function ( bulletNode )
		bulletNode:removeFromParentAndCleanup(true)
		pCallback()
	end))
	local seqAction   = CCSequence:create(actionArray)
	bulletEffect:runAction(seqAction)
end

--[[
	@des:播放多个弹道特效
	@parm:pBlockInfo 战斗块数据
	@parm:pCallback 播放完毕回调
--]]
function runMultiBulletAction( pBlockInfo, pCallback )
	--是否跳过
	if FightMainLoop.getIsSkip() == true then
		return
	end
	local attackHid  = pBlockInfo.attacker
	local skillId    = pBlockInfo.action
	local card       = FightScene.getCardByHid(attackHid)
	local dressId    = card:getEntity():getDressId()
	local htid       = card:getEntity():getHtid()
	local skillInfo  = BT_Skill.getDataById(skillId, dressId, htid)
	--得到卡牌对象
	local atkCard = FightScene.getCardByHid(attackHid)
	local defCards = {}
	for k,v in pairs(pBlockInfo.arrReaction) do
		table.insert(defCards, v.defender)
	end
	local bulletCount = table.count(defCards)
	local playNum = 0
	local calfunc = function ( bulletNode )
		playNum = playNum + 1
		if playNum >= bulletCount then
			print("play all bullet action flinish")
			pCallback()
		end
	end
	local beginPos = atkCard:convertToWorldSpace(ccpsprite(0.5, 0.5, atkCard))
	for k,v in pairs(pBlockInfo.arrReaction) do
		runSingleBulletAction(pBlockInfo, v.defender, calfunc)
	end
end

--[[
	@des:死亡动画
	@parm:pBlockInfo 
--]]
function playDieEffect( pBlockInfo, pCallback )
	--是否跳过
	if FightMainLoop.getIsSkip() == true then
		return
	end
	--检查死亡角色
	local dieHids = {}
	--攻击者死亡检测
	if pBlockInfo.mandown == true then
		table.insert( dieHids, pBlockInfo.attacker)
	end
	--被攻击者死亡检测
	if pBlockInfo.arrReaction then
		for k,v in pairs(pBlockInfo.arrReaction) do
			if v.mandown == true then
				table.insert( dieHids, v.defender)
			end
		end
	end
	local count = table.count(dieHids)
	if count == 0 then
		pCallback()
		return
	end

	local playNum = 0
	--播放完成回调
	local palyCallback = function ()
		playNum = playNum + 1
		if playNum == count and pCallback then
			pCallback()
		end
	end
	--播放死亡特效
	for k,v in pairs(dieHids) do
		local card = FightScene.getCardByHid(v)
		if not tolua.isnull(card) then
			card:setIsDead(true)
			card:setHpVisible(false)
			card:setNameVisible(false)
			card:setRageVisible(false)
			local actionPath = FightUtil.getActionXmlPaht(CardAction.die, card:isEnemy())
			card:runXMLAction(actionPath)
			card:registerActionEndCallback(function ()
		        card:setOpacity(0)
			    card:setVisible(false)
		        	if card:isEnemy() == false then
				        local deadEffect = XMLSprite:create("images/battle/effect/deada")
				        local fireEffect = XMLSprite:create("images/battle/effect/guihuo")
				        deadEffect:setPosition(card:convertToWorldSpace(ccpsprite(0.5,0.5,card)))
				        deadEffect:setReplayTimes(1, false)
				        FightScene.getEffectLayer():addChild(deadEffect, ZOrderType.TOM)
				        deadEffect:setScale(g_fElementScaleRatio)
				        fireEffect:setPosition(0, -50)
				        deadEffect:addChild(fireEffect)
				        FightModel.addDeadEff(deadEffect)
				    end
			    --播放卡牌掉落特效
			    playDropCardEffect(v)
			    palyCallback()
		    end)
		end
	end
end

--[[
	@des:播放掉落卡牌特效
--]]
function playDropCardEffect( pHid )
	--是否跳过
	if FightMainLoop.getIsSkip() == true then
		return
	end
	--判断是否掉落卡牌
	if FightModel.isDropCard(pHid) == false then
		return
	end
	local card         = FightScene.getCardByHid(pHid)
	local cardPos      = card:convertToWorldSpace(ccpsprite(0.5, 0.5, card))
	local resIcon      = FightUILayer.getResIcon()
	local resPos       = resIcon:convertToWorldSpace(ccpsprite(0.5, 0.5, resIcon))
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	card:stopAllActions()
    --卡牌飞入背包特效
	local playCardMoveAction = function ( ... )
		local cardSprite = CCSprite:create("images/shop/pub/card_opp.png")
	    cardSprite:setAnchorPoint(ccp(0.5,0.5))
	    cardSprite:setPosition(cardPos)
	    runningScene:addChild(cardSprite,99999)
	    cardSprite:setScale(0.23)
	    cardSprite:runAction(CCRotateBy:create(1,7200))

	    --播放卡牌飞入背包特效
		local spwanArray = CCArray:create()
		spwanArray:addObject(CCEaseIn:create(CCMoveTo:create(1, resPos), 0.5))
		spwanArray:addObject(CCScaleTo:create(1, 0.05))
		local spwan = CCSpawn:create(spwanArray)
		local seqActionArray = CCArray:create()
		seqActionArray:addObject(spwan)
		seqActionArray:addObject(CCCallFunc:create(function ( ... )
			cardSprite:removeFromParentAndCleanup(true)
			cardSprite = nil
			--图标呼吸效果		
		    local actionA = CCEaseIn:create(CCScaleTo:create(0.5, 1.5), 0.5)
		    local actionB = CCEaseOut:create(CCScaleTo:create(0.5, 1), 0.5)
		    local resSeqArray = CCArray:create()
		    resSeqArray:addObject(actionA)
		    resSeqArray:addObject(actionB)
		    if not tolua.isnull(resIcon) then
		    	resIcon:runAction(CCSequence:create(resSeqArray))
		    end
		end))
		cardSprite:runAction(CCSequence:create(seqActionArray))
	end
	--播放掉落卡牌特效
	local effect = XMLSprite:create("images/battle/effect/fubendiaoluo")
    effect:setAnchorPoint(ccp(0.5, 0.5))
    effect:setPosition(cardPos)
    effect:setReplayTimes(1, true)
    FightScene.getEffectLayer():addChild(effect, ZOrderType.EFFECT)
    effect:registerEndCallback(function ( ... )
    	playCardMoveAction()
    end)
end