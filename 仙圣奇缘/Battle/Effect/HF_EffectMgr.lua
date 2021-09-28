--------------------------------------------------------------------------------------
-- 文件名:	HF_BattleCard.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	flamehong
-- 日  期:	2014-9-15 15:03
-- 版  本:	1.0
-- 描  述:	战斗效果管理类
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

CEffectMgr = class("CEffectMgr")
CEffectMgr.__index = CEffectMgr

function CEffectMgr:clear(nType)
	if not nType then
		self.tbEffectList = {}
	else
		local tbEffectBase = self:getSkillStatusEffectCsv(nType, 1)
		tbEffectBase:clear()
	end
end

function CEffectMgr:addEffectMgr(GameObj_Attacker, GameObj_Defencer, tbStatusCfg, nEffectType, nEffectLv)
    if nEffectType <= 0 and nEffectLv <= 0 then return end
    local tbEffectCfg = g_DataMgr:getSkillStatusEffectCsv(nEffectType, nEffectLv)
    if not tbEffectCfg then return end
	local effectBase = self:createEffect(nEffectType)
	if not effectBase then return end
	effectBase:initialize(tbEffectCfg)
	effectBase:addEffect(GameObj_Attacker, GameObj_Defencer, tbStatusCfg)
end

--添加状态
function CEffectMgr:addStatus(GameObj_Attacker, GameObj_Defencer, nStatusID, nStatusLv)
	local tbStatusCfg = g_DataMgr:getSkillStatusCsv(nStatusID, nStatusLv)
	if not tbStatusCfg then
		error("not exist status status:"..nStatusID.." lv:"..nStatusLv)
	end

    for i = 1, 5 do 
        local nEffectType = tbStatusCfg["EffecType"..i]
        local nEffectLv = tbStatusCfg["EffectLevel"..i]
        if tbStatusCfg and nEffectType > 0 and nEffectLv > 0 then
            self:addEffectMgr(GameObj_Attacker, GameObj_Defencer, tbStatusCfg, nEffectType, nEffectLv)
        end
    end

end

--每次行动
function CEffectMgr:onAction(GameObj_Defencer)
	for i = 1, macro_pb.Skill_Effect_Max - 1 do
		local tbEffectBase = self:getSkillStatusEffectCsv(i)
		if tbEffectBase and tbEffectBase:isValid()  and GameObj_Defencer.hp > 0 then
			tbEffectBase:takeEffect(nil, GameObj_Defencer, nil, nil)
			if GameObj_Defencer.hp <= 0 then
				break
			end
		end
	end
end

--每次行动完
function CEffectMgr:onTurn(GameObj_Defencer)
	for i = 1, macro_pb.Skill_Effect_Max-1 do
		local tbEffectBase = self:getSkillStatusEffectCsv(i, 1)
		if tbEffectBase and tbEffectBase:isValid() 
			and GameObj_Defencer.hp > 0 then
			tbEffectBase:onTurn()
		end
	end	
end

--工厂方法创建不同的效果
function CEffectMgr:createEffect(nType)
	local tbEffectBase = self:getSkillStatusEffectCsv(nType, 1)
	if tbEffectBase then
		return tbEffectBase
	end

	if nType == macro_pb.Skill_Effect_Add_Mana--每回合增加气势
		or nType == macro_pb.Skill_Effect_Reduce_Mana--每回合减少气势
		or nType == macro_pb.Skill_Effect_ModifyMana--[[立即减少怒气]] 
        or nType == macro_pb.Skill_Effect_Add_MaxMana --增加气势上限
		or nType == macro_pb.Skill_Effect_Reduce_MaxMana--减少气势上限
		or nType == macro_pb.Skill_Effect_Add_ManaMaxPercent--增加气势上限万分比
		or nType == macro_pb.Skill_Effect_Reduce_ManaMaxPercent--[[减少气势上限万分比]]then

		tbEffectBase = CEffectModifyMana:new()

	elseif nType == macro_pb.Skill_Effect_Add_HP --持续回血增加当前生命
		or nType == macro_pb.Skill_Effect_Reduce_HP --持续流血减少当前生命
        or nType == macro_pb.Skill_Effect_Add_MaxHP--增加生命上限
		or nType == macro_pb.Skill_Effect_Reduce_MaxHP--减少生命上限
		or nType == macro_pb.Skill_Effect_Add_HPMaxPercent--增加生命上限万分比
		or nType == macro_pb.Skill_Effect_Reduce_HPMaxPercent--[[减少生命上限万分比]] then
  

		tbEffectBase = CEffectModifyHP:new()

	elseif nType == macro_pb.Skill_Effect_Add_PhyAtk
		or nType == macro_pb.Skill_Effect_Reduce_PhyAtk
		or nType == macro_pb.Skill_Effect_Add_PhyDef
		or nType == macro_pb.Skill_Effect_Reduce_PhyDef
		or nType == macro_pb.Skill_Effect_Add_MagAtk
		or nType == macro_pb.Skill_Effect_Reduce_MagAtk
		or nType == macro_pb.Skill_Effect_Add_MagDef
		or nType == macro_pb.Skill_Effect_Reduce_MagDef
		or nType == macro_pb.Skill_Effect_Add_SkillAtk
		or nType == macro_pb.Skill_Effect_Reduce_SkillAtk
		or nType == macro_pb.Skill_Effect_Add_SkillDef
		or nType == macro_pb.Skill_Effect_Reduce_SkillDef
		or nType == macro_pb.Skill_Effect_Add_CriticalChance
		or nType == macro_pb.Skill_Effect_Reduce_CriticalChance
		or nType == macro_pb.Skill_Effect_Add_CriticalResistance
		or nType == macro_pb.Skill_Effect_Reduce_CriticalResistance
		or nType == macro_pb.Skill_Effect_Add_CriticalStrike
		or nType == macro_pb.Skill_Effect_Reduce_CriticalStrike
		or nType == macro_pb.Skill_Effect_Add_CriticalStrikeResistance
		or nType == macro_pb.Skill_Effect_Reduce_CriticalStrikeResistance
		or nType == macro_pb.Skill_Effect_Add_HitChance
		or nType == macro_pb.Skill_Effect_Reduce_HitChance
		or nType == macro_pb.Skill_Effect_Add_DodgeChance
		or nType == macro_pb.Skill_Effect_Reduce_DodgeChance
		or nType == macro_pb.Skill_Effect_Add_PenetrateChance
		or nType == macro_pb.Skill_Effect_Reduce_PenetrateChance
		or nType == macro_pb.Skill_Effect_Add_BlockChance
		or nType == macro_pb.Skill_Effect_Reduce_BlockChance
		or nType == macro_pb.Skill_Effect_Add_PhyAttackPercent
		or nType == macro_pb.Skill_Effect_Reduce_PhyAttackPercent
		or nType == macro_pb.Skill_Effect_Add_PhyDefencePercent
		or nType == macro_pb.Skill_Effect_Reduce_PhyDefencePercent
		or nType == macro_pb.Skill_Effect_Add_MagAttackPercent
		or nType == macro_pb.Skill_Effect_Reduce_MagAttackPercent
		or nType == macro_pb.Skill_Effect_Add_MagDefencePercent
		or nType == macro_pb.Skill_Effect_Reduce_MagDefencePercent
		or nType == macro_pb.Skill_Effect_Add_SkillAttackPercent
		or nType == macro_pb.Skill_Effect_Reduce_SkillAttackPercent
		or nType == macro_pb.Skill_Effect_Add_SkillDefencePercent
		or nType == macro_pb.Skill_Effect_Reduce_SkillDefencePercent
		or nType == macro_pb.Skill_Effect_Add_Damage_Reduction
		or nType == macro_pb.Skill_Effect_Reduce_Damage_Reduction then

		tbEffectBase = CEffectModifyAbs:new()

	elseif nType == macro_pb.Skill_Effect_Cure_Phy --回血武力治疗
		or nType == macro_pb.Skill_Effect_Cure_Mag  --回血法术治疗
		or nType == macro_pb.Skill_Effect_Cure_PhySkill --回血武力加绝技治疗
		or nType == macro_pb.Skill_Effect_Cure_MagSkill --回血法术加绝技治疗
        or nType == macro_pb.Skill_Effect_Bleed_Phy --流血武力伤害
		or nType == macro_pb.Skill_Effect_Bleed_Mag --流血法术伤害
		or nType == macro_pb.Skill_Effect_Bleed_PhySkill --流血武力加绝技伤害
		or nType == macro_pb.Skill_Effect_Bleed_MagSkill --[[流血法术加绝技伤害]] then
        
		tbEffectBase = CEffectBleed:new()

	elseif nType == macro_pb.Skill_Effect_Heated then   --激昂

		tbEffectBase = CEffectHeated:new()

	elseif nType == macro_pb.Skill_Effect_RepetedHit        --连击
		or nType == macro_pb.Skill_Effect_Fury              --狂怒
		or nType == macro_pb.Skill_Effect_ImproveDamage         --百分比提高伤害

		or nType == macro_pb.Skill_Effect_Dizzy             --眩晕
		or nType == macro_pb.Skill_Effect_Confused          --混乱
		or nType == macro_pb.Skill_Effect_Frenzy            --狂暴
		or nType == macro_pb.Skill_Effect_Silence then      --封印

		tbEffectBase = CEffectBase:new()
    elseif nType == macro_pb.Skill_Effect_StealMana then        --偷怒气
        tbEffectBase = EffectStealMana:new()   

	elseif nType == macro_pb.Skill_Effect_RemoveMana then        --消除怒气
        tbEffectBase = EffectRemoveMana:new()

	elseif nType == macro_pb.Skill_Effect_Defend then        --绝对防御
        tbEffectBase = EffectDefend:new()
    elseif nType == macro_pb.Skill_Effect_Suck_Blood then        --吸血
        tbEffectBase = CEffectSuckBlood:new()
        
	else
		error("error skill type :"..nType)
	end
	
	if not self.tbEffectList then
		self.tbEffectList = {}
	end
	
	if not tbEffectBase then
		error("this Battle is nil, type:"..nType)
	end
	
	self.tbEffectList[nType] = tbEffectBase
	
	return tbEffectBase
end

function CEffectMgr:getSkillStatusEffectCsv(nType)
	return self.tbEffectList[nType]
end

function CEffectMgr:GetEffectData(nType)
	local tbEffectBase = self:getSkillStatusEffectCsv(nType, 1)
	if not tbEffectBase then
		return 0
	end
	
	return tbEffectBase:getData()
end

--连击次数
function CEffectMgr:GetRepetedHitTimes()
	local tbEffectBase = self:getSkillStatusEffectCsv(macro_pb.Skill_Effect_RepetedHit, 1)
	if not tbEffectBase then
		return 0
	end
	local repeted_times = 0
	local repeted_precent = tbEffectBase:getDataValue2()
	for i = 1, tbEffectBase:getData() -1 do
		if g_isRandomInRange(repeted_precent, g_BasePercent) then
			repeted_times = repeted_times + 1
		end
	end
	return repeted_times
end

--吸血
function CEffectMgr:HandlerSuckBlood(GameObj_Attacker)
	if not self:isValid(macro_pb.Skill_Effect_Suck_Blood) then
		return 
	end
	
	local nDamage = 0
	local tbBattleTurn = g_BattleMgr:getBattleTurn()
	for i = 1, #tbBattleTurn.actioncardlist do
		local tbActionCard = tbBattleTurn.actioncardlist[i]
        if tbActionCard.damage and tbActionCard.damage > 0 then
		    nDamage = nDamage + tbActionCard.damage
        end
	end
	--造成伤害的万分比转换为自己的血量，转换的血量 = 伤害 * EffectValue1/10000
	local nSuckBlood = nDamage * self:GetEffectData(macro_pb.Skill_Effect_Suck_Blood)
	g_BattleMgr:handleBleedDamage(GameObj_Attacker, macro_pb.Battle_Effect_SuckBlood, -nSuckBlood)
end

function CEffectMgr:HandlerFury(GameObj_Attacker, nDamage)
	if not self:isValid(macro_pb.Skill_Effect_Fury) then
		return nDamage
	end
	
	local hp_precent = math.floor(GameObj_Attacker.hp * g_BasePercent / GameObj_Attacker.max_hp)
	local tbEffectBase = self:getSkillStatusEffectCsv(macro_pb.Skill_Effect_Fury, 1)
	if not tbEffectBase then
		return nDamage
	end
	
	if hp_precent < 7500 then --低于80%
		nDamage = nDamage * (g_BasePercent + 1000) / g_BasePercent
	elseif hp_precent < 5000 then --低于60%
		nDamage = nDamage * (g_BasePercent + 2000) / g_BasePercent
	elseif hp_precent < 2500 then --低于40%
		nDamage = nDamage * (g_BasePercent + 3000) / g_BasePercent
	end
	
	nDamage = math.floor(nDamage)
	return nDamage
end

function CEffectMgr:isValid(nType)
	local tbEffectBase = self:getSkillStatusEffectCsv(nType, 1)
	if not tbEffectBase then
		return false
	end
	
	return tbEffectBase:isValid()
end

function CEffectMgr:HandlerImproveDamage(GameObj_Attacker, nDamage)
	local tbImproveDamage = self:getSkillStatusEffectCsv(macro_pb.Skill_Effect_ImproveDamage, 1)
	if tbImproveDamage and tbImproveDamage.tbCfg then
		nDamage = nDamage * (g_BasePercent + tbImproveDamage:getDataValue1()) / g_BasePercent
	end

	nDamage = math.floor(nDamage)
	return nDamage
end

function CEffectMgr:HandlerStealMana(GameObj_Attacker, GameObj_Defencer)
	local tbStealMana = self:getSkillStatusEffectCsv(macro_pb.Skill_Effect_StealMana, 1)
	if tbStealMana and tbStealMana:isValid() then
		local steal_mana = tbStealMana:getDataValue1()
		steal_mana = math.min(steal_mana, GameObj_Defencer.mana)
		GameObj_Attacker.mana = GameObj_Attacker.mana + steal_mana
	end
end

function CEffectMgr:HandlerRemoveMana(GameObj_Attacker, GameObj_Defencer)
	local tbRemoveMana = self:getSkillStatusEffectCsv(macro_pb.Skill_Effect_RemoveMana, 1)
	if tbRemoveMana and tbRemoveMana:isValid() then
		GameObj_Defencer.mana = math.min(GameObj_Defencer.mana, tbRemoveMana:getDataValue1())
	end
end

function CEffectMgr:HandlerDefend(GameObj_Defencer, nDamage)
	if self:isValid(macro_pb.Skill_Effect_Defend) then

        local tbStealMana = self:getSkillStatusEffectCsv(macro_pb.Skill_Effect_Defend, 1)
        
        if not tbStealMana then return nDamage end 

        local defendDamage = tbStealMana:getData() == 0 and 1 or tbStealMana:getData()
--		nDamage = math.min(nDamage, defendDamage)
        nDamage = defendDamage
	end
	return nDamage
end

function CEffectMgr:isDizzy(GameObj_Defencer)
	return self:isValid(macro_pb.Skill_Effect_Dizzy)
end

function CEffectMgr:isConfused(GameObj_Defencer)
	return self:isValid(macro_pb.Skill_Effect_Confused)
end

function CEffectMgr:isFrenzy(GameObj_Defencer)
	return self:isValid(macro_pb.Skill_Effect_Frenzy)
end

function CEffectMgr:isSilence(GameObj_Defencer)
	return self:isValid(macro_pb.Skill_Effect_Silence)
end

