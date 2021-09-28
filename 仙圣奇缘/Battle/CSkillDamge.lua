--------------------------------------------------------------------------------------
-- 文件名:	CSkillDamge.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2014-9-13 18:24
-- 版  本:	1.0
-- 描  述:	技能伤害类
-- 应  用:  
---------------------------------------------------------------------------------------

--创建CSkillDamge类
CSkillDamge = class("CSkillDamge")
CSkillDamge.__index = CSkillDamge

function CSkillDamge:setUnderAttackDamageData(GameFighter_Defencer, tbDamageInfo_Hurt, GameObj_SkillMgr, nPosSrc)
    self.tbDamageInfo_Hurt = tbDamageInfo_Hurt
    self.GameFighter_Defencer = GameFighter_Defencer
    self.GameObj_SkillMgr = GameObj_SkillMgr
    self.nPosSrc = nPosSrc or GameFighter_Defencer.nPos
end

function CSkillDamge:getCurrentSkillDetail()
    return self.GameObj_SkillMgr:getCurrentSkillDetail()
end


function CSkillDamge:showStatusEffect()
    --如果有受击状态
	local nStatusID = self.tbDamageInfo_Hurt.target_status
	local nStatuslv = self.tbDamageInfo_Hurt.target_statusLv
	if(nStatusID and nStatusID  > 0 )then
		if self.GameFighter_Defencer then
			self.GameFighter_Defencer:showStatusEffect(nStatusID, nStatuslv)
		end
	end
end

function CSkillDamge:executeHitEffectProcess(funcHitEffectProcessEndCall, nAttackIndex)

    local function funcHitEffectEndCall()
        if funcHitEffectProcessEndCall then funcHitEffectProcessEndCall() end
    end

	local nCurCount = 0
	local nMaxCount  = 0
	local function funcHitTargetEndCall()
		nCurCount = nCurCount + 1
		if nCurCount == nMaxCount then
            if TbBattleReport.tbMutileAttack then--合击的死亡特殊处理一下 一定要最后一个人攻击才死亡
                if TbBattleReport.tbMutileAttack.Num > 1 then
                    TbBattleReport.tbMutileAttack.Num = TbBattleReport.tbMutileAttack.Num - 1
                    funcHitEffectEndCall()
                    return
                end
            end
			
			if not self.GameFighter_Defencer or not self.GameFighter_Defencer.checkIsDead then return end -- 回调没清干净
			
			if self.GameFighter_Defencer and self.GameFighter_Defencer.checkIsDead and self.GameFighter_Defencer:checkIsDead() == true then
				self:killDefencer(funcHitEffectEndCall)
			else
				funcHitEffectEndCall()
			end
		end
	end
	
    --攻击伤害类型
	local nDamage = self.tbDamageInfo_Hurt["damage"]
	local bCrit = nil
	local tbType = {}
	local tbDemageType = self.tbDamageInfo_Hurt.damagetype
	if(tbDemageType and #tbDemageType > 0)then
		for i =1, #tbDemageType do
            -- 暴击 被攻击方
			if(macro_pb.Battle_Effect_Crit == tbDemageType[i])then
				bCrit =  true
			else
				table.insert(tbType, tbDemageType[i])
			end
		end
	end
	
	--还有格挡或者闪避特效
	if (#tbType > 0) then
		for i = 1, #tbType do
			local nDemageType = tbType[i]			
			nMaxCount = nMaxCount + 1
			
			if (nDemageType == macro_pb.Battle_Effect_Miss) then
                --未命中，miss 被攻击方--闪避 播放闪避动作、闪避声音、闪避飘字，无需播放受击特效
    			--闪避声音
				g_playSoundEffectBattle("Sound/Battle_Miss.mp3")

				--闪避飘字 Dodge
				local function showDodgeActionCallBack()
                    --闪避结束 闪避是无伤害的
					self.GameFighter_Defencer:showEffectOnGroundByID(Enum_SkillLightEffect._Dodge, funcHitEffectEndCall, 
                        self.GameFighter_Defencer.nPos > 10, nil, Enum_MeshLayer.DamageEffectWord
					)--光效层级设置
				end
	
				--闪避动作
				self.GameFighter_Defencer:showActionByID(Enum_Action._Action_Miss, showDodgeActionCallBack) 

			elseif (nDemageType == macro_pb.Battle_Effect_Block) then
                 --格挡 播放格挡动作、格挡特效、格挡声音、格挡飘字、受击特效、伤害飘字
				local function showBlockActionCallBack()
                    --格挡结束，格挡是有伤害的
					local funcEffectOnGroundEndCall = calcCountCallBack(3, funcHitTargetEndCall)
					--格挡特效
					self.GameFighter_Defencer:showEffectOnGroundByID(Enum_SkillLightEffect._BlockEffect, funcEffectOnGroundEndCall, 
                        self.GameFighter_Defencer.nPos > 10, nil, g_tbCardPos[self.GameFighter_Defencer.nPos].nBattleLayer + Enum_EffectLayer.BloclEffect
					)--光效层级设置
					--格挡飘字 Block
					self.GameFighter_Defencer:showEffectOnGroundByID(Enum_SkillLightEffect._Block, funcEffectOnGroundEndCall, 
                        self.GameFighter_Defencer.nPos > 10, nil, Enum_MeshLayer.DamageEffectWord
					)--光效层级设置

					if(bCrit)then
						self.GameFighter_Defencer:showCriticalDamage(nDamage, funcEffectOnGroundEndCall)
						local GameFighter_Attacker =  TbBattleReport.tbGameFighters_OnWnd[self.nPosSrc]
						if GameFighter_Attacker then
							GameFighter_Attacker:showEffectOnGroundByID(Enum_SkillLightEffect._Critical, nil, GameFighter_Attacker.nPos > 10, nil, Enum_MeshLayer.DamageEffectWord)--光效层级设置
						else
							-- nothing
						end
					else
						--普通伤害数字
						self.GameFighter_Defencer:showDamage(nDamage, funcEffectOnGroundEndCall)
					end
				end
				
				local function showHitActandSound()
					--格挡声音 
					g_playSoundEffectBattle("Sound/Battle_Block.mp3")
					--格挡动作
					self.GameFighter_Defencer:showActionByID(Enum_Action._Action_Block, showBlockActionCallBack)
                    self:showStatusEffect()
				end
				--受击特效
				local nHitEffetcID = self.GameObj_SkillMgr:getHitEffectID()
				self:showHitAllEffects(nHitEffetcID, showHitActandSound)
			else --未知的类型
				error("未知的伤害类型 ")
			end
		end

        self.GameFighter_Defencer:showWorldBossDrop(nAttackIndex)
	else
		local function showHitActionCallBack()
			if(nDamage > 0)then 
				if(bCrit)then--伤害暴击
					nMaxCount = nMaxCount + 1
					self.GameFighter_Defencer:showCriticalDamage(nDamage, funcHitTargetEndCall)
					--暴击是释放则播放
					local GameFighter_Attacker =  TbBattleReport.tbGameFighters_OnWnd[self.nPosSrc]
					nMaxCount = nMaxCount + 1
                    --伤害暴击 都是显示暴击的 Critical --光效层级设置
					if GameFighter_Attacker then
						GameFighter_Attacker:showEffectOnGroundByID(Enum_SkillLightEffect._Critical, funcHitTargetEndCall, GameFighter_Attacker.nPos > 10, nil, Enum_MeshLayer.DamageEffectWord)
					else
						-- nothing
					end
				else--普通伤害
					nMaxCount =  nMaxCount + 1
					self.GameFighter_Defencer:showDamage(nDamage, funcHitTargetEndCall)
				end
			else 
				if(bCrit)then--治疗暴击
					nMaxCount = nMaxCount + 1
					self.GameFighter_Defencer:showCriticalHealing(nDamage, funcHitTargetEndCall)
					local GameFighter_Attacker =  TbBattleReport.tbGameFighters_OnWnd[self.nPosSrc ]
					nMaxCount = nMaxCount + 1
                    --治疗暴击 都是显示暴击的 Critical --光效层级设置
					if GameFighter_Attacker then
						GameFighter_Attacker:showEffectOnGroundByID(Enum_SkillLightEffect._Critical, funcHitTargetEndCall, GameFighter_Attacker.nPos > 10, nil, Enum_MeshLayer.DamageEffectWord)
					else
						-- nothing
					end
				else --普通治疗
					nMaxCount =  nMaxCount + 1
					self.GameFighter_Defencer:showHealing(nDamage, funcHitTargetEndCall)
				end
			end

            self.GameFighter_Defencer:showWorldBossDrop(nAttackIndex)
		end
		
		local function showHitActandSound()
			--受击声音
			if self.GameObj_SkillMgr:getHitSound() ~= 0 then
				g_playSoundEffectBattle("Sound/Skill/"..self.GameObj_SkillMgr:getHitSound())
			end
			
			--受击动作
			self.GameFighter_Defencer:showActionByID(self.GameObj_SkillMgr:getCurHitActionID(), showHitActionCallBack)

            self:showStatusEffect()
		end

		--受击特效
		local nHitEffetcID = self.GameObj_SkillMgr:getHitEffectID()
		self:showHitAllEffects(nHitEffetcID, showHitActandSound)
	end
end

function CSkillDamge:showHitAllEffects(nHitEffetcID, func)
	if(not nHitEffetcID or nHitEffetcID <= 0)then --无特效
		func()
		return
	end
	
	local tbEffect = g_DataMgr:getSkillLightEffectCsv(nHitEffetcID )
	if(not tbEffect)then --无特效
		func()
	else
		if(tbEffect.Type == 2)then --plist特效
			func()
			self:addHitEffect(nHitEffetcID)
		else--cocos特效
			self:addHitEffect(nHitEffetcID, func)
		end
	end
end

--受击光效 左边的需要反向 右边的不需要
function CSkillDamge:addHitEffect(nHitEffetcID, func)
	if(nHitEffetcID > 0)then	
		self.GameFighter_Defencer:showEffectOnGroundByID(nHitEffetcID, func, self.GameFighter_Defencer.nPos < 10, nil, g_tbCardPos[self.GameFighter_Defencer.nPos].nBattleLayer+Enum_EffectLayer.HitEffect)--光效层级设置
	else
		if(func)then
			func()
		end
	end
end

function CSkillDamge:bornSubsitionFighter(funcCallBack, nDeadPos)
	local function changeCardCallBack()
		if TbBattleReport and TbBattleReport.nRepeatAttackNum then
			TbBattleReport.nRepeatAttackNum = TbBattleReport.nRepeatAttackNum - self.nSubAttackNum--强制让可以下一关
		end
		funcCallBack() 
	end
    
	if TbBattleReport then
		if TbBattleReport.tbGameFighters_OnWnd then
			local GameFighter_Defencer = TbBattleReport.tbGameFighters_OnWnd[nDeadPos]
			if GameFighter_Defencer then
				GameFighter_Defencer:changeCardByDead(changeCardCallBack, self.tbTibuData)
				self.tbTibuData = nil
			else
				changeCardCallBack()
				--SendError("==GameFighter_Defencer==Nil==deadRemoveChild")
			end
		else
			changeCardCallBack()
			--SendError("==tbGameFighters_OnWnd==Nil==deadRemoveChild")
		end
	else
		changeCardCallBack()
		--SendError("==TbBattleReport==Nil==deadRemoveChild")
	end
end

function CSkillDamge:executeDefencerDeadAction(funcDefencerDeadActionEndCall)
    self.nSubAttackNum = #self.GameFighter_Defencer.tbSkillDamageList_Hurt - 1
    self.GameFighter_Defencer:removeStatus()
	local nDeadPos = self.GameFighter_Defencer.nPos
	
	local function deadRemoveChild()
        if not self.tbTibuData then
			if TbBattleReport and TbBattleReport.nRepeatAttackNum then
				TbBattleReport.nRepeatAttackNum = TbBattleReport.nRepeatAttackNum - self.nSubAttackNum--强制让可以下一关
			end
       
            funcDefencerDeadActionEndCall()--没有替补马上下一轮
			
			if TbBattleReport then
				if TbBattleReport.tbGameFighters_OnWnd then
					local GameFighter_Defencer = TbBattleReport.tbGameFighters_OnWnd[nDeadPos]
					if GameFighter_Defencer then
						TbBattleReport.tbGameFighters_OnWnd[nDeadPos]:removeStatus()
						TbBattleReport.tbGameFighters_OnWnd[nDeadPos]:release()
						TbBattleReport.tbGameFighters_OnWnd[nDeadPos]:removeFromParentAndCleanup(true)
						TbBattleReport.tbGameFighters_OnWnd[nDeadPos] = nil
						self.GameFighter_Defencer = nil
					else
						--SendError("==GameFighter_Defencer==Nil==deadRemoveChild")
					end
				else
					--SendError("==tbGameFighters_OnWnd==Nil==deadRemoveChild")
				end
			else
				--SendError("==TbBattleReport==Nil==deadRemoveChild")
			end
        else
           self:bornSubsitionFighter(funcDefencerDeadActionEndCall, nDeadPos)    
        end
	end
	
	local function executeDropItemLogic()
		if TbBattleReport then
			if TbBattleReport.tbGameFighters_OnWnd then
				local GameFighter_Defencer = TbBattleReport.tbGameFighters_OnWnd[nDeadPos]
				if GameFighter_Defencer then
					local tbDrop = self.tbDamageInfo_Hurt.die_drop_info	
					--死亡掉落
					GameFighter_Defencer:addDeadDropItems(tbDrop, deadRemoveChild, self.tbTibuData == nil)

					if tbDrop then 
						local wndInstance = g_WndMgr:getWnd("Game_Battle")
						if wndInstance then
							wndInstance:refreshDropInfo(tbDrop)
						end
					end
				else
					deadRemoveChild()
					--SendError("==GameFighter_Defencer==Nil==executeDropItemLogic")
				end
			else
				deadRemoveChild()
				--SendError("==tbGameFighters_OnWnd==Nil==executeDropItemLogic")
			end
		else
			deadRemoveChild()
			--SendError("==TbBattleReport==Nil==executeDropItemLogic")
		end
	end
	
	--先是在Action里面黑化，然后再黑化后的回调里面播放光效
	local function deadAnimationEndCall()
		if TbBattleReport then
			if TbBattleReport.tbGameFighters_OnWnd then
				local GameFighter_Defencer = TbBattleReport.tbGameFighters_OnWnd[nDeadPos]
				if GameFighter_Defencer then
					GameFighter_Defencer:showEffectOnGroundByID(
						Enum_SkillLightEffect._DeadA,
						executeDropItemLogic,
						GameFighter_Defencer.nPos > 10,
						nil,
						g_tbCardPos[GameFighter_Defencer.nPos].nBattleLayer+Enum_EffectLayer.DeadEffect
					)
				else
					executeDropItemLogic()
					--SendError("==GameFighter_Defencer==Nil==deadAnimationEndCall")
				end
			else
				executeDropItemLogic()
				--SendError("==tbGameFighters_OnWnd==Nil==deadAnimationEndCall")
			end
		else
			executeDropItemLogic()
			--SendError("==TbBattleReport==Nil==deadAnimationEndCall")
		end
	end
	self.GameFighter_Defencer:showActionByID(Enum_Action._Action_Dead, deadAnimationEndCall, nil) --让死亡前计数器加1
	
    updateSkillPlayerList(1, self.GameFighter_Defencer.nPos)
end

--死亡动作,死亡特效->掉落动画->替补->下一关
function CSkillDamge:killDefencer(funcKillDefencerEndCall)
    if self.tbDamageInfo_Hurt.die_sub_apos  then
        local nReliveFromPos = self.tbDamageInfo_Hurt.die_sub_apos
        if self.GameFighter_Defencer.nPos < 10 then
		    self.tbTibuData = TbBattleReport.tbSubsitutionFighterList_Atk[nReliveFromPos]
	    else
		    self.tbTibuData = TbBattleReport.tbSubsitutionFighterList_Def[nReliveFromPos]
	    end
    end
	
    --必须等待其他的攻击都返回了
    self:executeDefencerDeadAction(funcKillDefencerEndCall)
end