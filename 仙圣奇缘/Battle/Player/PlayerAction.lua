--------------------------------------------------------------------------------------
-- 文件名:	PlayerAction.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2014-3-28 20:24
-- 版  本:	1.0
-- 描  述:	角色信息2
-- 应  用:
---------------------------------------------------------------------------------------
--[[
  左		  右
1 2 3  	3 2 1
4 5 6		6 5 4
7 8 9		9 8 7
]]

Enum_Action = {
	_Action_MeleeAttack = 1,
	_Action_MissileAttack = 2,
	_Action_NormalMeleeAttackHit = 3,
	_Action_PowerMeleeAttackHit = 4,
	_Action_NormalMissileAttack = 5,
	_Action_PowerMissileAttack = 6,
	_Action_Healing = 7,
	_Action_Miss = 8,
	_Action_Block = 9,
	_Action_Dead = 10,
}

Enum_SkillLightEffect = {
	_Damage = 1,
	_Critical = 2,
	_Block = 3,
	_BlockEffect = 4,
	_Dodge = 5,
	_Buff = 6,
	_DeBuff = 7,
	_DoubleHit = 8,
	_ReStrike = 9,
	_DeadA = 10,
	--_Battle_FullManaPhy = 11,
	--_Battle_FullManaMag = 12,
	_TiBuChuChang = 13,
	_SummonTiBu = 14,
	_SkillNameAnimation_Blue = 15,
	_PersueAttack = 16,
	_SkillNameAnimation = 17,
	--_UseSkillLight = 18,
}

function CPlayer:showDropItemEffect(szAniName, pszSpriteFrameName, func)
	if TbBattleReport and TbBattleReport.Mesh then
		local armature, userAnimation = g_CreateBattleJsonAnimation(szAniName, func)
		local bone = armature:getBone("Layer3");
		local numSkin1 = CCSkin:createWithSpriteFrameName(pszSpriteFrameName)
		bone:addDisplay(numSkin1,0)

		local bone2 = armature:getBone("Layer4");
		local numSkin2 = CCSkin:createWithSpriteFrameName(pszSpriteFrameName)
		bone2:addDisplay(numSkin2, 1)

		userAnimation:playWithIndex(0)
		local animationPos = g_tbCardPos[self.nPos].tbPos

		armature:setPosition(animationPos)
		TbBattleReport.Mesh:addNode(armature,  g_tbCardPos[self.nPos].nBattleLayer)

	else
		func()
	end
end


local HitWidget = nil
local nBegin = nil
local MoveWidget = nil
local nEnd = nil

local function resetBuZhen()
	if(not HitWidget or not MoveWidget)then
		return
	end
	
	HitWidget:setBrightStyle(BRIGHT_NORMAL)
	MoveWidget:removeFromParentAndCleanup(false)
	
	if TbBattleReport and TbBattleReport.tbGameFighters_OnWnd and TbBattleReport.tbGameFighters_OnWnd[nBegin] then
		TbBattleReport.tbGameFighters_OnWnd[nBegin]:resetPosition()
	end
	
	MoveWidget:release()

	nBegin = nil
	HitWidget = nil
    MoveWidget = nil
    nEnd = nil
end

local function changePosition()
	if not HitWidget then return end
    HitWidget:setBrightStyle(BRIGHT_NORMAL)
	
    local toPlayer = TbBattleReport.tbGameFighters_OnWnd[nEnd]
    local fromSkillData = TbBattleReport.tbSkillData[nBegin]
    local toSkillData = TbBattleReport.tbSkillData[nEnd]

    MoveWidget:retain()
	MoveWidget:removeFromParentAndCleanup(true)
	
	local fromPlayer = TbBattleReport.tbGameFighters_OnWnd[nBegin]
	if fromPlayer then
		fromPlayer:changePosition(nEnd, true)
	end
	
    MoveWidget:release()
	
    TbBattleReport.tbGameFighters_OnWnd[nBegin]:release()
    TbBattleReport.tbGameFighters_OnWnd[nBegin] = nil
    TbBattleReport.tbSkillData[nBegin] = nil
    TbBattleReport.tbSkillData[nEnd] = fromSkillData

    if toPlayer then
        toPlayer:changePosition(nBegin)
        TbBattleReport.tbSkillData[nBegin] = toSkillData
    end

    nBegin = nil
	HitWidget = nil
    MoveWidget = nil
    nEnd = nil
end

function g_battleChangePosition(tbMsg)
    if tbMsg.change_op == zone_pb.ChangeArrayType_Move then
        changePosition()
    else
    end
end

local function changePosition(nEndPos)
    nEnd = nEndPos
    g_MsgMgr:requestChangeCard(g_Hero:getCurZhenFaIndex(nBegin), g_Hero:getCurZhenFaIndex(nEnd))
end

function onClickResetBuZhen(pSender,eventType)
    if TbBattleReport.bOnClickGoGoGo then return end

    if eventType == ccs.TouchEventType.ended then
		local index = pSender:getTag()
		if(not MoveWidget)then
			return
		end

		if(HitWidget)then
			HitWidget:setBrightStyle(BRIGHT_NORMAL)
			local nEnd = HitWidget:getTag()
            local tbCheckPos = g_Hero:getCurZhenFaIndex(nEnd)
            if not tbCheckPos then
               resetBuZhen()
            end

			if(nBegin ~= nEnd )then
                changePosition(nEnd)
			else
				resetBuZhen()
			end
		end
	elseif(eventType == ccs.TouchEventType.began)then
		nBegin = pSender:getTag()
        local index = tbServerToClientPosConvert[nBegin]
        HitWidget = TbBattleReport.TbBattleWnd.Image_BuZhen:getChildByName("Button_BattlePos"..index)
        HitWidget:setBrightStyle(BRIGHT_HIGHLIGHT)

        local GameFighter_Attacker  = TbBattleReport.tbGameFighters_OnWnd[nBegin]
        if not GameFighter_Attacker then
            return
        end
        MoveWidget = GameFighter_Attacker
		if(MoveWidget)then
			local icount = 0
			icount = MoveWidget:retainCount()

			MoveWidget:retain()
			MoveWidget:removeFromParentAndCleanup(false)
	        local tbCurScene = g_pDirector:getRunningScene()
	        tbCurScene:addChild(MoveWidget, INT_MAX)
			local nPos = pSender:getTouchStartPos()
			MoveWidget:setPosition(ccp(nPos.x, nPos.y-GameFighter_Attacker.tbFighterBase.CardHeight/4*g_nCardScale))
	
			local icount = 0
			icount = MoveWidget:retainCount()
		end
	elseif(eventType == ccs.TouchEventType.moved)then
        local GameFighter_Attacker  = TbBattleReport.tbGameFighters_OnWnd[nBegin]
		local nPos = pSender:getTouchMovePos()
		if MoveWidget and MoveWidget:isExsit() and GameFighter_Attacker and GameFighter_Attacker.tbFighterBase and GameFighter_Attacker.tbFighterBase.CardHeight then
			--设置默认值 如果为nil 这里又回崩溃
			GameFighter_Attacker.tbFighterBase.CardHeight = GameFighter_Attacker.tbFighterBase.CardHeight or 1
		    MoveWidget:setPosition(ccp(nPos.x, nPos.y-GameFighter_Attacker.tbFighterBase.CardHeight/4*g_nCardScale))
		end

		local children = TbBattleReport.TbBattleWnd.Image_BuZhen:getChildren()
		if(children ~= nil)then
			for i = 0, children:count() -1 do
				local object = children:objectAtIndex(i)
				local widget = tolua.cast(object, "Widget")

				if(widget ~= nil and widget:hitTest(nPos)) then
                    local tbCheckPos = g_Hero:getCurZhenFaIndex(widget:getTag())
                    if not tbCheckPos then  return  end

					if(widget ~= HitWidget)then
						if(HitWidget)then
							HitWidget:setBrightStyle(BRIGHT_NORMAL)
						end
						HitWidget = widget
						HitWidget:setBrightStyle(BRIGHT_HIGHLIGHT)
					end
					break
				end
			end
		end
	else
		if(HitWidget)then
			HitWidget:setBrightStyle(BRIGHT_NORMAL)
		end
		if(HitWidget and MoveWidget)then
			local nEnd = HitWidget:getTag()
            local tbCheckPos = g_Hero:getCurZhenFaIndex(nEnd)
            if not tbCheckPos then
               resetBuZhen()
            end

			if(nBegin and nBegin ~= nEnd  )then
               --交换
                changePosition(nEnd)
			else
				resetBuZhen()
			end
		end
	end
end

function CPlayer:addDeadDropItemsDetail(tbDropItems,deadDropCallBack)
	local TbBattleWnd = TbBattleReport.TbBattleWnd
	local nMax = 0
	if(tbDropItems )then
		for i=1, #tbDropItems do
			local curDropItem = tbDropItems[i]
			local nType = curDropItem.drop_item_type
			local nNum = curDropItem.drop_item_num

			if(nType < macro_pb.ITEM_TYPE_MASTER_EXP)then--播放的是资源
				self:showDropItemEffect("Drop", "Item"..nType..".png", deadDropCallBack)
				nMax = nMax + 1
			end
		end
	end

	return  nMax
end

--死亡掉落
function CPlayer:addDeadDropItems(tbDropItems, func, bReturnQuick)
	local nMax  = 0
	local nCurCount = 0
	local function deadDropCallBack()
		nCurCount = nCurCount + 1
		if(nCurCount == nMax)then
			if(func)then
				func()
			end
		end
	end

	if tbDropItems then
        if func then func() end
	else
		nMax = nMax + 1
		deadDropCallBack()
	end
end


--取攻击动作ID
function CPlayer:getCurFireActionID()
    local tbSkillData =  TbBattleReport.tbSkillData[self.nPos]
	return tbSkillData[self.nSkillIndex].FireActionID
end

--取受击动作ID
function CPlayer:getCurHitActionID()
	local nCurrentAttackPos = TbBattleReport.nCurrentAttackPos
	local tbAttacker = TbBattleReport.tbGameFighters_OnWnd[nCurrentAttackPos]
    local tbSkillData =  TbBattleReport.tbSkillData[nCurrentAttackPos]
    return tbSkillData[tbAttacker.nSkillIndex].HitActionID
end

--取施法声音
function CPlayer:getFireSound()
    local tbSkillData =  TbBattleReport.tbSkillData[self.nPos]
    return tbSkillData[self.nSkillIndex].FireSound
end

--取施法特效
function CPlayer:getFireEffectID()
	local tbSkillData =  TbBattleReport.tbSkillData[self.nPos]
    return tbSkillData[self.nSkillIndex].FireEffect
end

--取施法声音
function CPlayer:getHitSound()
	local nCurrentAttackPos = TbBattleReport.nCurrentAttackPos
	local tbAttacker = TbBattleReport.tbGameFighters_OnWnd[nCurrentAttackPos]

    local tbSkillData =  TbBattleReport.tbSkillData[nCurrentAttackPos]
    return tbSkillData[tbAttacker.nSkillIndex].HitSound
end

--取飞行特效
function CPlayer:getFlyEffectID()
	local tbSkillData =  TbBattleReport.tbSkillData[self.nPos]
    return tbSkillData[self.nSkillIndex].FlyEffect
end

function CPlayer:getFlyEffectType()
	local tbSkillData =  TbBattleReport.tbSkillData[self.nPos]
    return tbSkillData[self.nSkillIndex].FlyEffectType
end

--取受击特效ID
function CPlayer:getHitEffectID()
	local nCurrentAttackPos = TbBattleReport.nCurrentAttackPos
	local tbAttacker = TbBattleReport.tbGameFighters_OnWnd[nCurrentAttackPos]

    local tbSkillData =  TbBattleReport.tbSkillData[nCurrentAttackPos]
    return tbSkillData[tbAttacker.nSkillIndex].HitEffect
end

--取攻击区域类型
function CPlayer:getAttackAreaEffectID()
	local tbSkillData =  TbBattleReport.tbSkillData[self.nPos]
    return tbSkillData[self.nSkillIndex].AreaEffect
end

--[[
  左		  右
1 2 3  	3 2 1
4 5 6		6 5 4
7 8 9		9 8 7
0，单体(当前默认目标)
1，自己
2，列，纵向攻击 123 456 789
3，排，横向攻击 147 258 369
4，全体
5，前排单位
6，后排单位
7，残血单位，生命值最少的前n个目标
8，随机单位，随机n个目标
9，气势最高的前n个单位]]
function CPlayer:getAttackArea()
	local tbSkillData =  TbBattleReport.tbSkillData[self.nPos]
    return tbSkillData[self.nSkillIndex].AttackArea
end

--取攻击区域类型
function CPlayer:getAttackAreaType()
	local tbSkillData =  TbBattleReport.tbSkillData[self.nPos]
    return tbSkillData[self.nSkillIndex].AreaEffectType
end

--显示状态情况
function CPlayer:showStatusEffect(nStatusID, nStatusLevel)
	if nStatusID and nStatusID <= 0 then return end
	if nStatusLevel and nStatusLevel <= 0 then return end

	local CSV_SkillStatus = g_DataMgr:getSkillStatusCsv(nStatusID, nStatusLevel)
	
    self.nStatusCount = CSV_SkillStatus.StatusCon - 1 --自身加了马上减去1
	
    if self.AniStatusLightEffect then
		self.AniStatusLightEffect:removeFromParentAndCleanup(true)
		self.AniStatusLightEffect = nil
	end

	local function cleanupAniStatusLightEffect()
		self.AniStatusLightEffect = nil
	end

	--状态光效
	if CSV_SkillStatus.LightEffect > 0 then
		local CSV_SkillLightEffect = g_DataMgr:getSkillLightEffectCsv(CSV_SkillStatus.LightEffect)
		if CSV_SkillLightEffect.IsStatusOnGround == 0 then
			self.AniStatusLightEffect = self:showEffectOnPlayerByID(CSV_SkillStatus.LightEffect, cleanupAniStatusLightEffect, true, Enum_PosLayer.StatusEffect)--光效层级设置
		else
			self.AniStatusLightEffect = self:showEffectOnGroundByID(CSV_SkillStatus.LightEffect, cleanupAniStatusLightEffect, nil,nil, Enum_EffectLayer.StatusEffect)--光效层级设置
		end
	end
	
	--状态类型（0为正面状态 Buff，1为负面状态 DeBuff） --Buff
	local nWordEffectID
	if CSV_SkillStatus.StatusType == 0 then -- 正面buff
		nWordEffectID = Enum_SkillLightEffect._Buff
	else --负面DeBuff
		nWordEffectID = Enum_SkillLightEffect._DeBuff
	end

    local fDelayTime = 0
	local nPos = self.nPos
	
	if CSV_SkillStatus.WordEffect1 ~= "" then
    	local armatureWordEffect = self:showEffectOnGroundByID(nWordEffectID, nil, nil,nil, Enum_MeshLayer.StatusWord, g_nPiaoZiAccelaration, bIsPiaoZi)--光效层级设置
		local boneWordEffect = armatureWordEffect:getBone("Layer1")
		local strWordEffectFile = CSV_SkillStatus.WordEffect1..".png"
		local skinWordEffect = CCSkin:createWithSpriteFrameName(strWordEffectFile)
		boneWordEffect:addDisplay(skinWordEffect, 0)
        boneWordEffect:changeDisplayWithIndex(0, true)
        fDelayTime = g_fStatusEffectDelayTime
	end

    if CSV_SkillStatus.WordEffect2 ~= "" then
        local function showWordEffect2()
			if TbBattleReport and TbBattleReport.tbGameFighters_OnWnd then
				local GameFighter = TbBattleReport.tbGameFighters_OnWnd[nPos]
				if GameFighter then
					 local armatureWordEffect = GameFighter:showEffectOnGroundByID(
						nWordEffectID, nil, nil,nil, Enum_MeshLayer.StatusWord, g_nPiaoZiAccelaration, bIsPiaoZi
					)--光效层级设置
					local boneWordEffect = armatureWordEffect:getBone("Layer1")
					local strWordEffectFile = CSV_SkillStatus.WordEffect2..".png"
					local skinWordEffect = CCSkin:createWithSpriteFrameName(strWordEffectFile)
					boneWordEffect:addDisplay(skinWordEffect, 0)
					boneWordEffect:changeDisplayWithIndex(0, true)
				end
			end
        end
        g_Timer:pushTimer(fDelayTime*g_TimeSpeed, showWordEffect2)
        fDelayTime = fDelayTime + g_fStatusEffectDelayTime
	end

    if CSV_SkillStatus.WordEffect3 ~= "" then
        local function showWordEffect3()
			if TbBattleReport and TbBattleReport.tbGameFighters_OnWnd then
				local GameFighter = TbBattleReport.tbGameFighters_OnWnd[nPos]
				if GameFighter then
					local armatureWordEffect = GameFighter:showEffectOnGroundByID(
						nWordEffectID, nil, nil,nil, Enum_MeshLayer.StatusWord, g_nPiaoZiAccelaration, bIsPiaoZi
					)--光效层级设置
					local boneWordEffect = armatureWordEffect:getBone("Layer1")
					local strWordEffectFile = CSV_SkillStatus.WordEffect3..".png"
					local skinWordEffect = CCSkin:createWithSpriteFrameName(strWordEffectFile)
					boneWordEffect:addDisplay(skinWordEffect, 0)
					boneWordEffect:changeDisplayWithIndex(0, true)
				end
			end
         end
		g_Timer:pushTimer(fDelayTime*g_TimeSpeed, showWordEffect3)
	end
end

--加地面上
function CPlayer:showEffectOnGroundByID(nEffectID, funcEffectOnGroundEndCall, bIsFighterSideIsRight, nSourcePos, nlayer, nAnimationSpeed, bIsPiaoZi)
	local armature, tbPos = self:showEffectByID(nEffectID, funcEffectOnGroundEndCall, bIsFighterSideIsRight, nSourcePos, nil, nAnimationSpeed, bIsPiaoZi)
	armature:setPosition(tbPos)
	
	if TbBattleReport and TbBattleReport.Mesh then
		TbBattleReport.Mesh:addNode(armature, nlayer)
	end

	return armature
end

--固定坐标加地面上
function CPlayer:showFixedPosEffectOnGroundByID(nEffectID, func, bIsFighterSideIsRight, tbEffectData)
	local armature, tbPos = self:showEffectByID(nEffectID, func, bIsFighterSideIsRight, nil, tbEffectData.tbPos)
	armature:setPosition(tbPos)
	
	if TbBattleReport and TbBattleReport.Mesh then
		TbBattleReport.Mesh:addNode(armature, tbEffectData.nBattleLayer)
	end

	return armature
end

--加人物身上
function CPlayer:showEffectOnPlayerByID(nEffectID, func, bInvert, nBattleLayer)
	local bIsFighterSideIsRight = nil
	if(bInvert)then
		bIsFighterSideIsRight = self.nPos < 10
	else
		bIsFighterSideIsRight = self.nPos > 10
	end

	local armature, tbPos = self:showEffectByID(nEffectID, func, bIsFighterSideIsRight)
    if(not armature)then
    end

	if(armature.tbEffect.Type == 2)then
		armature:setPosition(tbPos)
		if TbBattleReport and TbBattleReport.Mesh then
			TbBattleReport.Mesh:addNode(armature, nBattleLayer)
		end
	else
		if TbBattleReport and TbBattleReport.Mesh then
			local tbWPos = TbBattleReport.Mesh:convertToWorldSpace(tbPos)
			local tbNodePos = self:convertToNodeSpace(tbWPos)
			armature:setPosition(tbNodePos)
		end
		self:addNode(armature,  nBattleLayer)
	end

	return armature
end

--[[通过特效ID 显示特效
0，以九宫格Pos的中心点为描点
1，以伙伴图片的中心点为描点
2，以伙伴头顶血条的中心点为描点
3，以纵向平移AOE特效写死的坐标点为描点
4，以伙伴的右上角顶点为描点
5，以伙伴右边的中心点为描点]]
function CPlayer:showEffectByID(nEffectID, func, bIsFighterSideIsRight, nSourcePos, tbFixedPos, nAnimationSpeed, bIsPiaoZi)
	if(not nEffectID or nEffectID <= 0)then
		return nil
	end

	local tbEffect = g_DataMgr:getSkillLightEffectCsv(nEffectID )
	local nType = tbEffect.Type
	local armature, userAnimation = nil
	if(nType == 2)then  --plist文件
		armature =  CCParticleSystemQuad:create(getEffectParticlePlist(tbEffect.File))
		--因为飞行特效里面的流程是在自己的action的结束回调里面 执行的。。这里不能 自己删除 。不然 飞行特效的流程有问题的。
		-- armature:setAutoRemoveOnFinish(true)
	elseif(nType == 4)then  --骨骼动画
		armature = g_CreateSpineAnimation(tbEffect.File, func, tbEffect)
	else -- cocostudio 动画 1是在CocoAnimation
		
		armature, userAnimation = g_CreateBattleJsonAnimation(tbEffect.File, func, tbEffect, nAnimationSpeed, bIsPiaoZi)
	end

	local nEffectPosType = tbEffect.PosType

	local nPosition  = nil
	local animationPos = nil
	if(tbFixedPos )then --类型3，以纵向平移AOE特效写死的坐标点为描点
		CCAssert(nEffectPosType == 3, " 类型3，以纵向平移AOE特效写死的坐标点为描点	 "..nEffectPosType)
		nPosition = tbFixedPos
	else
		animationPos = nSourcePos or self.nPos--没有源位置则为默认自己的位置
		--添加子节点,如果是右边的则需要对光效的偏移做特殊处理
		if(nSourcePos)then --在对方的位置
			nPosition = g_tbCardPos[animationPos].tbPos
		else --
			nPosition = self:getPosition()
		end

		if(nEffectPosType == 0)then --类型0，以九宫格Pos的中心点为描点
			--
		elseif(nEffectPosType == 1)then --类型1，以伙伴图片的中心点为描点
			nPosition = ccpAdd(self:getPosition(), self.Image_Card:getPosition() )
            local tbPos_CardCenter = self:getPlayerCenterPos()
			nPosition.y = nPosition.y + tbPos_CardCenter.y
		elseif(nEffectPosType == 2)then --类型2，以伙伴头顶血条的中心点为描点
			nPosition = ccpAdd(nPosition, ccp(self.tbPos_HP.x, self.tbPos_HP.y))
		elseif(nEffectPosType == 4)then --类型4，以伙伴的右上角顶点为描点
			nPosition = ccpAdd(self:getPosition(), self.Image_Card:getPosition() )
            local tbPos_CardCenter = self:getPlayerCenterPos()
			if(bIsFighterSideIsRight)then
				nPosition = ccp(nPosition.x - tbPos_CardCenter.x, nPosition.y + 2*tbPos_CardCenter.y)
			else
				nPosition = ccp(nPosition.x + tbPos_CardCenter.x, nPosition.y + 2*tbPos_CardCenter.y)
			end
		elseif(nEffectPosType == 5)then --5，以伙伴右边的中心点为描点
            local tbPos_CardCenter = self:getPlayerCenterPos()
			if(bIsFighterSideIsRight)then
				nPosition = ccp(nPosition.x - tbPos_CardCenter.x, nPosition.y + tbPos_CardCenter.y)
			else
				nPosition = ccp(nPosition.x + tbPos_CardCenter.x, nPosition.y + tbPos_CardCenter.y)
			end
		else
			error(" CPlayer:showEffectByID "..nEffectPosType)
		end
	end

	local fScale = tbEffect.Scale/100
    if(fScale ~= 0 )then--默认是0
	    armature:setScale(fScale)
    end

    --spine特效反转 add by zgj
    if nType == 4 then
    	if bIsFighterSideIsRight then --Fighter在右边反相
			if tbEffect.InvertType == 1 then
				armature:setScaleX(-fScale)
			end
		else --Fighter在左边反相
			if tbEffect.InvertType == 2 then
				armature:setScaleX(-fScale)
			end
		end
	end
	--over

	--cocostudio animation 需要特殊处理
	if(userAnimation)then
		local nMovementCount = userAnimation:getMovementCount()
		if(nMovementCount > 1 )then
			if tbEffect.IsMoreThanOneSkins and tbEffect.IsMoreThanOneSkins >= 1 then
				if bIsFighterSideIsRight then --Fighter在右边反相
					if tbEffect.InvertType == 1 then
						armature:setScaleX(-fScale)
					end
				else --Fighter在左边反相
					if tbEffect.InvertType == 2 then
						armature:setScaleX(-fScale)
					end
				end
				userAnimation:playWithIndex(tbEffect.JsonAnimationIndex)
			else
				if(bIsFighterSideIsRight)then --右边的光效播放索引2的
					userAnimation:playWithIndex(1)
				else
					userAnimation:playWithIndex(0)
				end
			end
		else
			if bIsFighterSideIsRight then --Fighter在右边反相
				if tbEffect.InvertType == 1 then
					armature:setScaleX(-fScale)
				end
			else --Fighter在左边反相
				if tbEffect.InvertType == 2 then
					armature:setScaleX(-fScale)
				end
			end
			userAnimation:playWithIndex(0)
		end
    --[[粒子动画不需要反向
    else
        --1需要反向
	    if(bIsFighterSideIsRight and tbEffect.NeedInvert == 1)then--粒子特效不需要处理
		    armature:setScaleX(-fScale)
	    end
        ]]
	end

	armature.tbEffect = tbEffect
	return armature, nPosition
end

local function shakeScreen()
	--local pshake = CCShake:createWithStrength(1.5*g_TimeSpeed, 4, 6)
  --  TbBattleReport.TbBattleWnd.Scene:runAction(pshake)

  math.randomseed(os.time())
  if not TbBattleReport or not TbBattleReport.TbBattleWnd then
  	return false
  end

  local pSender = TbBattleReport.TbBattleWnd.Scene
  if not pSender or pSender:isExsit() == false then return false end

  local OffsetX = 5
  local OffsetY = 5
  local fInterval = 0.02
  local time = 0
  local function showShake()
	time = time + fInterval
	local x = math.random(-OffsetX, OffsetX)
	local y = math.random(-OffsetY, OffsetY)
	OffsetX = OffsetX*(1-fInterval)
	OffsetY = OffsetY*(1-fInterval)
	if pSender:isExsit() then
		pSender:setPositionXY(640+x, -5 + y)
	end
	
	if pSender:isExsit() then
		if(time >= g_TimeSpeed)then
			pSender:setPositionXY(640, -5)
		end
	end
	
  end

  g_pushLimtTimeTimer(g_TimeSpeed, fInterval, showShake, pSender)

  return true
end

--备份 showShake
local function function_name_test( ... )
	--local OffsetX = 4
  --local OffsetY = 5
  local OffsetX = 5
  local OffsetY = 5
  --local PosX = pSender:getPositionX()
  --local PosY = pSender:getPositionY()
  local function showShake(fInterval, bOver)
  --[[
	local x = math.random()
	local y = math.random()
	pSender:setPositionXY(PosX+OffsetX*x, PosY + OffsetY*y)
]]

	local x = math.random(-OffsetX, OffsetX)
	local y = math.random(-OffsetY, OffsetY)
	OffsetX = OffsetX*(1-fInterval)
	OffsetY = OffsetY*(1-fInterval)
	if pSender:isExsit() then
		pSender:setPositionXY(640+x, -5 + y)
	end
	

		--[[
	local x = math.random()
	local y = math.random()
	local XX = math.random(-x, x)
	local YY = math.random(-y, y)
	pSender:setPositionXY(PosX+OffsetX*XX, PosY + OffsetY*YY)
		]]

	if pSender:isExsit() then
		if(bOver)then
			pSender:setPositionXY(640, -5)
		end
	end
	
  end

  g_Timer:pushLimtTimeTimer(g_TimeSpeed, showShake, 0.02)
end

--1号开场动作
function CPlayer:actionRunInScreen(funcActionEndCall, fDelayTime)
	local fDelayTime = fDelayTime or 0
	local x,y = self:getPositionXY()

	--一个动作播完需要的时间是0.8秒，一个动作走两步，走一步的时间是0.4秒
	--nStepCount需要为偶数
	local nMoveDistEveryStep = 80
	local nStepCount = 12
	local fAccelerateScale = 0.8 --动作时间加速参数微调细节
	local nWalkDistance = nMoveDistEveryStep * nStepCount
	if  self.nPos > 10 then
		self:setPosition(ccp(x + nWalkDistance, y))
		nWalkDistance = -nWalkDistance
    else
		self:setPosition(ccp(x - nWalkDistance, y))
    end

    local fAnimationDuration = self.CCNode_Skeleton:getAnimationDuration("walk")
    local nWalkTime = fAccelerateScale * fAnimationDuration * nStepCount * g_TimeSpeedWalk/ 2
    local actionMoveForward = CCMoveBy:create(nWalkTime, ccp(nWalkDistance,0))

    local arrAct = CCArray:create()
	arrAct:addObject(CCDelayTime:create(fDelayTime))
	arrAct:addObject(actionMoveForward)
	local function executeActionEndCall()
		self:hideHeadInfoHurtAction(false)
		if funcActionEndCall then
			funcActionEndCall()
		end
	end
	arrAct:addObject(CCCallFuncN:create(executeActionEndCall))
    local action = CCSequence:create(arrAct)
    self:runAction(action)
    self:runSpineWalk() --人物的Walk的帧数统一调整为24帧了，每个角色的动作时间都是一样的
	cclog("==================播放入场动作了================")
end

--开场动作
function CPlayer:actionRunOutScreen(funcCallBack)
	--一个动作播完需要的时间是0.8秒，一个动作走两步，走一步的时间是0.4秒
	--nStepCount需要为偶数
	local nMoveDistEveryStep = 80
	local nStepCount = 18
	local fAccelerateScale = 0.8 --动作时间加速参数微调细节
	local nWalkDistance = nMoveDistEveryStep * nStepCount
    local fAnimationDuration = self.CCNode_Skeleton:getAnimationDuration("walk")
    local nWalkTime = fAccelerateScale * fAnimationDuration * nStepCount * g_TimeSpeedWalk / 2
    local actionMoveForward = CCMoveBy:create(nWalkTime, ccp(nWalkDistance,0))

    local arrAct = CCArray:create()
	arrAct:addObject(actionMoveForward)
	arrAct:addObject(CCCallFuncN:create(funcCallBack))
    local action = CCSequence:create(arrAct)
    self:runAction(action)
    self:runSpineWalk() --人物的Walk的帧数统一调整为24帧了，每个角色的动作时间都是一样的
end

--3号开场动作，淡出，同时作为替补出场动画
function CPlayer:showTiBuAppearAction(showTiBuActionEndCall)

	self.CCNode_Skeleton:setVisible(false)

	local arrAct_FadeOut = CCArray:create()
	local action_FadeOut = CCFadeOut:create(0.001)
	arrAct_FadeOut:addObject(action_FadeOut)

	local function executeFadeOutEndCall()
		self.CCNode_Skeleton:setVisible(true)
		local arrAct_FadeIn = CCArray:create()
		local action_FadeIn = CCFadeIn:create(0.3*g_TimeSpeed)
		arrAct_FadeIn:addObject(action_FadeIn)
		if(showTiBuActionEndCall)then
			self:hideHeadInfoHurtAction(false)
			arrAct_FadeIn:addObject(CCCallFuncN:create(showTiBuActionEndCall))
		end
		local actionSequence_FadeIn = CCSequence:create(arrAct_FadeIn)
		 --渐入，参数：时间
		self.CCNode_Skeleton:runAction(actionSequence_FadeIn)
	end
	arrAct_FadeOut:addObject(CCCallFuncN:create(executeFadeOutEndCall))
	local actionSequence_FadeOut = CCSequence:create(arrAct_FadeOut)
	self.CCNode_Skeleton:runAction(actionSequence_FadeOut)

end

function CPlayer:setCardColorToWhite()
	-- local pProgram = CCGLProgram:new()
	-- pProgram:initWithVertexShaderByteArray(ccPositionTextureColor_vert, pszWhiteFragSource)
	-- self.CCNode_Skeleton:setShaderProgram(pProgram)
	-- pProgram:autorelease()
	-- local shader = self.CCNode_Skeleton:getShaderProgram()
	-- shader:addAttribute(kCCAttributeNamePosition, kCCVertexAttrib_Position)
	-- shader:addAttribute(kCCAttributeNameColor, kCCVertexAttrib_Color)
	-- shader:addAttribute(kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords)

	-- shader:link()
	-- shader:updateUniforms()
end

function CPlayer:setCardColorToNomal()
	self.CCNode_Skeleton:setShaderProgram("ShaderPositionTextureColor")
end

function CPlayer:showActionColorToWhite()
	local function funcCallBackColorToNomal()
		self:setCardColorToNomal()
	end
	local arrAct = CCArray:create()
	self:setCardColorToWhite()
	arrAct:addObject(CCDelayTime:create(0.15*g_TimeSpeed))
	arrAct:addObject(CCCallFuncN:create(funcCallBackColorToNomal))
	local action = CCSequence:create(arrAct)
	return action
end

--1号动作 近战飞过去，再飞回来
function CPlayer:showActionID1(funcCallBack, funcActOver)
	local nPosID = self.tbBattleTurnData.actioncardlist[1].affectinfo
	local mTarget = TbBattleReport.tbGameFighters_OnWnd[nPosID]
	
	if not mTarget then return end
	
    local x2,y2 = mTarget:getPositionXY()
    local tbSize1 = self.Image_Card:getContentSize()
	local tbSize2 = mTarget.Image_Card:getContentSize()
	local mSelfAchorPoin =  self.Image_Card:getAnchorPoint()
	local mTargetAchorPoin  =  mTarget.Image_Card:getAnchorPoint()

	local movetoX = 0
	if((self.nPos  < 10 and mTarget.nPos  < 10 ) or (self.nPos  > 10 and mTarget.nPos  > 10 ) )then
		if(funcActOver)then
			funcActOver()
		end
	else
		if self.nPos > 10 then
			movetoX = x2 + tbSize1.width * mSelfAchorPoin.x*g_nCardScale + tbSize2.width *g_nCardScale* (1 - mTargetAchorPoin.x )/2 + 100
		else
			movetoX = x2 - tbSize1.width *(1 - mSelfAchorPoin.x)*g_nCardScale -  tbSize2.width *g_nCardScale* mTargetAchorPoin.x/2 - 100
		end
	end

    --层次调整
	local nLayerTarget = g_tbCardPos[mTarget.nPos].nBattleLayer
	self:setZOrder(nLayerTarget + Enum_EffectLayer.BaseLayer)
	
	--飞行到目标
	local fDistance = math.abs(movetoX - x2)
	self.fFlyTime = fDistance/1000
	local actionFlyTO = CCMoveTo:create(self.fFlyTime*g_TimeSpeed, CCPointMake(movetoX, y2))   --移动，参数： 移动时间，x，y坐标
	local actionFlyTOEase = CCEaseOut:create(actionFlyTO, 2)
	local arrAct = CCArray:create()
    arrAct:addObject(actionFlyTOEase)
	local function executeAttackEvent()
		if(funcCallBack)then
			funcCallBack()
		end
	end
	arrAct:addObject(CCCallFuncN:create(executeAttackEvent))
	local function executeAttackOverEvent()
		if(funcActOver)then
			funcActOver()
		end
	end
	arrAct:addObject(CCCallFuncN:create(executeAttackOverEvent))
    local actionSequence = CCSequence:create(arrAct)
	self:runAction(actionSequence)
end

--2号动作 原地施法，只是执行回调而已
function CPlayer:showActionID2(funcCallBack, funcActOver)
    local arrAct_Pos = CCArray:create()
	local function executeAttackEvent()
		if(funcCallBack)then
			funcCallBack()
		end
	end
	arrAct_Pos:addObject(CCCallFuncN:create(executeAttackEvent))
	local function executeAttackOverEvent()
		if(funcActOver)then
			funcActOver()
		end
	end
	arrAct_Pos:addObject(CCCallFuncN:create(executeAttackOverEvent))
    local actionSequence_Pos = CCSequence:create(arrAct_Pos)
	self:runAction(actionSequence_Pos)
end

--3号动作 近战普通攻击受击,执行回调,并附带受击闪光
function  CPlayer:showActionID3(funcCallBack, funcActOver)
	local arrAct = CCArray:create()
	local function executeAttackEvent()
		if(funcCallBack)then
			funcCallBack()
		end
	end
	arrAct:addObject(CCCallFuncN:create(executeAttackEvent))
	local function executeAttackOverEvent()
		if(funcActOver)then
			funcActOver()
		end
	end
	arrAct:addObject(CCCallFuncN:create(executeAttackOverEvent))
	local actionColorToWhite = self:showActionColorToWhite()
	local actionSequence = CCSequence:create(arrAct)
	local actionSpawn = CCSpawn:createWithTwoActions(actionColorToWhite, actionSequence)
	self:runAction(actionSpawn)
end

--4号动作 近战绝技攻击受击,执行回调,带屏幕抖动,并附带受击闪光
function CPlayer:showActionID4(funcCallBack, funcActOver)
	local arrAct = CCArray:create()
	arrAct:addObject(CCCallFuncN:create(shakeScreen))
	local function executeAttackEvent()
		if(funcCallBack)then
			funcCallBack()
		end
	end
	arrAct:addObject(CCCallFuncN:create(executeAttackEvent))
	local function executeAttackOverEvent()
		if(funcActOver)then
			funcActOver()
		end
	end
	arrAct:addObject(CCCallFuncN:create(executeAttackOverEvent))
	local actionColorToWhite = self:showActionColorToWhite()
	local actionSequence = CCSequence:create(arrAct)
	local actionSpawn = CCSpawn:createWithTwoActions(actionColorToWhite, actionSequence)
	self:runAction(actionSpawn)
end

--5号动作 远程普通攻击受击,执行回调,并附带受击闪光
function CPlayer:showActionID5(funcCallBack, funcActOver)
	local arrAct = CCArray:create()
	local function executeAttackEvent()
		if(funcCallBack)then
			funcCallBack()
		end
	end
	arrAct:addObject(CCCallFuncN:create(executeAttackEvent))
	local function executeAttackOverEvent()
		if(funcActOver)then
			funcActOver()
		end
	end
	arrAct:addObject(CCCallFuncN:create(executeAttackOverEvent))
	local actionColorToWhite = self:showActionColorToWhite()
	local actionSequence = CCSequence:create(arrAct)
	local actionSpawn = CCSpawn:createWithTwoActions(actionColorToWhite, actionSequence)
	self:runAction(actionSpawn)
end

--6号动作 远程绝技攻击受击,执行回调,带屏幕抖动,并附带受击闪光
function CPlayer:showActionID6(funcCallBack, funcActOver)
	local arrAct = CCArray:create()
	arrAct:addObject(CCCallFuncN:create(shakeScreen))
	local function executeAttackEvent()
		if(funcCallBack)then
			funcCallBack()
		end
	end
	arrAct:addObject(CCCallFuncN:create(executeAttackEvent))
	local function executeAttackOverEvent()
		if(funcActOver)then
			funcActOver()
		end
	end
	arrAct:addObject(CCCallFuncN:create(executeAttackOverEvent))
	local actionColorToWhite = self:showActionColorToWhite()
	local actionSequence = CCSequence:create(arrAct)
	local actionSpawn = CCSpawn:createWithTwoActions(actionColorToWhite, actionSequence)
	self:runAction(actionSpawn)
end

--7号动作 治疗受击动作,放大缩小
function CPlayer:showActionID7(funcCallBack, funcActOver)
    local arrAct_Pos = CCArray:create()
    local actionScaleTo_Pos1 = CCScaleTo:create(0.18*g_TimeSpeed, 1.2*self.fPosScale)     -- 相对缩放，参数：缩放时间，缩放比例
	local actionScaleTo_Pos2 = CCScaleTo:create(0.3*g_TimeSpeed, 1*self.fPosScale)     -- 相对缩放，参数：缩放时间，缩放比例
	arrAct_Pos:addObject(actionScaleTo_Pos1)
	local function executeAttackEvent()
		if(funcCallBack)then
			funcCallBack()
		end
	end
	arrAct_Pos:addObject(CCCallFuncN:create(executeAttackEvent))
	arrAct_Pos:addObject(actionScaleTo_Pos2)
	local function executeAttackOverEvent()
		if(funcActOver)then
			funcActOver()
		end
	end
	arrAct_Pos:addObject(CCCallFuncN:create(executeAttackOverEvent))
    local actionSequence_Pos = CCSequence:create(arrAct_Pos)
	self:runAction(actionSequence_Pos)
end

--8号动作 闪避动作
function CPlayer:showActionID8(funcCallBack, funcActOver)
	local CardPoint = g_tbCardPos[self.nPos].tbPos
	local x = 0
	if  self.nPos < 10 then
		x = -60
	else
		x = 60
	end
	
	local arrAct = CCArray:create()
    local actionTo = CCMoveBy:create(0.05*g_TimeSpeed, CCPointMake(x, 0))     --移动，参数： 移动时间，x，y坐标
    local actionToEase = CCEaseOut:create(actionTo, 3)
	local actionBack = CCMoveTo:create(0.2*g_TimeSpeed, CardPoint)
	local actionBackEase = CCEaseIn:create(actionBack, 3)
	arrAct:addObject(actionToEase)
	if(funcCallBack)then
		arrAct:addObject(CCCallFuncN:create(funcCallBack))
	end
	arrAct:addObject(CCDelayTime:create(0.6*g_TimeSpeed))
	arrAct:addObject(actionBackEase)
	if(funcActOver)then
		arrAct:addObject(CCCallFuncN:create(funcActOver))
	end

	local actionSequence = CCSequence:create(arrAct)
	self:runAction(actionSequence)
end

--9号动作 格挡动作
function CPlayer:showActionID9(funcCallBack, funcActOver)
	local arrAct = CCArray:create()
	local function executeAttackEvent()
		if(funcCallBack)then
			funcCallBack()
		end
	end
	arrAct:addObject(CCCallFuncN:create(executeAttackEvent))
	local function executeAttackOverEvent()
		if(funcActOver)then
			funcActOver()
		end
	end
	arrAct:addObject(CCCallFuncN:create(executeAttackOverEvent))
	local actionColorToWhite = self:showActionColorToWhite()
	local actionSequence = CCSequence:create(arrAct)
	local actionSpawn = CCSpawn:createWithTwoActions( actionColorToWhite, actionSequence)
	self:runAction(actionSpawn)
end

--10号动作 死亡动作
function CPlayer:showActionID10(funcCallBack, funcActOver)
	self:hideHeadInfoHurtAction(true)
	local actionTintTo = CCTintTo:create(0.2*g_TimeSpeed, 0,0,0)
	local actionFadeOut = CCFadeOut:create(0.5*g_TimeSpeed)            --渐隐，参数：时间
    local arrAct = CCArray:create()
	arrAct:addObject(actionTintTo)
	if(funcCallBack)then
		g_playSoundEffectBattle("Sound/Dead.mp3")
		arrAct:addObject(CCCallFuncN:create(funcCallBack))
	end
    arrAct:addObject(actionFadeOut)
	if(funcActOver)then
		arrAct:addObject(CCCallFuncN:create(funcActOver))
	end
    local actionSequence = CCSequence:create(arrAct)
	self.CCNode_Skeleton:runAction(actionSequence)
end

--取要播放的動畫
function CPlayer:showActionByID(nActionType, funcCallBack, funcActOver)
	if (nActionType == Enum_Action._Action_MeleeAttack) then
		self:showActionID1(funcCallBack, funcActOver)
	elseif (nActionType == Enum_Action._Action_MissileAttack) then
		self:showActionID2(funcCallBack, funcActOver)
	elseif (nActionType == Enum_Action._Action_NormalMeleeAttackHit) then
		self:showActionID3(funcCallBack, funcActOver)
		self:runSpineHurt()
	elseif (nActionType == Enum_Action._Action_PowerMeleeAttackHit) then
		self:showActionID4(funcCallBack, funcActOver)
		self:runSpineHurt()
	elseif (nActionType == Enum_Action._Action_NormalMissileAttack) then
		self:showActionID5(funcCallBack, funcActOver)
		self:runSpineHurt()
	elseif (nActionType == Enum_Action._Action_PowerMissileAttack) then
		self:showActionID6(funcCallBack, funcActOver)
		self:runSpineHurt()
	elseif (nActionType == Enum_Action._Action_Healing) then
		self:showActionID7(funcCallBack, funcActOver)
	elseif (nActionType == Enum_Action._Action_Miss) then
		self:showActionID8(funcCallBack, funcActOver)
	elseif (nActionType == Enum_Action._Action_Block) then
		self:showActionID9(funcCallBack, funcActOver)
		self:runSpineHurt()
	elseif (nActionType == Enum_Action._Action_Dead) then
		self:showActionID10(funcCallBack, funcActOver)
	else
		if(funcCallBack)then
			funcCallBack()
		end
		if(funcActOver)then
			funcActOver()
		end
	end
end