--------------------------------------------------------------------------------------
-- 文件名:	HF_BattleCard.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	flamehong
-- 日  期:	2014-9-22 20:43
-- 版  本:	1.0
-- 描  述:	效果
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------


CEffectModifyAbs = class("CEffectModifyAbs", function() return CEffectBase:new() end)
CEffectModifyAbs.__index = CEffectModifyAbs

function CEffectModifyAbs:takeEffect(GameObj_Attacker, GameObj_Defencer, bTakeFirst)
	if bTakeFirst then
		local nBaseProp = 0
		if self.tbCfg.EffecType == macro_pb.Skill_Effect_Add_PhyAtk--增加武力攻击属性
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Reduce_PhyAtk--减少武力攻击属性
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Add_PhyAttackPercent--增加武力攻击万分比属性
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Reduce_PhyAttackPercent--[[减少武力攻击万分比属性]] then
			nBaseProp = GameObj_Defencer.phy_attack
		elseif self.tbCfg.EffecType == macro_pb.Skill_Effect_Add_PhyDef--增加武力防御属性
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Reduce_PhyDef--减少武力防御属性
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Add_PhyDefencePercent--增加武力防御万分比属性
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Reduce_PhyDefencePercent--[[减少武力防御万分比属性]] then
			nBaseProp = GameObj_Defencer.phy_defence
		elseif self.tbCfg.EffecType == macro_pb.Skill_Effect_Add_MagAtk--增加法术攻击属性
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Reduce_MagAtk--减少法术攻击属性
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Add_MagAttackPercent--增加法术攻击万分比属性
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Reduce_MagAttackPercent--[[减少法术攻击万分比属性]] then
			nBaseProp = GameObj_Defencer.mag_attack
		elseif self.tbCfg.EffecType == macro_pb.Skill_Effect_Add_MagDef--增加法术防御属性
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Reduce_MagDef--减少法术防御属性
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Add_MagDefencePercent--增加法术防御万分比属性
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Reduce_MagDefencePercent--[[减少法术防御万分比属性]] then
			nBaseProp = GameObj_Defencer.mag_defence
		elseif self.tbCfg.EffecType == macro_pb.Skill_Effect_Add_SkillAtk--增加绝技攻击属性
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Reduce_SkillAtk--减少绝技攻击属性
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Add_SkillAttackPercent--增加绝技攻击万分比属性
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Reduce_SkillAttackPercent--[[减少绝技攻击万分比属性]] then
			nBaseProp = GameObj_Defencer.skill_attack
		elseif self.tbCfg.EffecType == macro_pb.Skill_Effect_Add_SkillDef--增加绝技防御属性
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Reduce_SkillDef--减少绝技防御属性
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Add_SkillDefencePercent--增加绝技防御万分比属性
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Reduce_SkillDefencePercent--[[减少绝技防御万分比属性]] then
			nBaseProp = GameObj_Defencer.skill_defence
		elseif self.tbCfg.EffecType == macro_pb.Skill_Effect_Add_CriticalChance--增加暴击属性
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Reduce_CriticalChance--[[减少暴击属性]] then
			nBaseProp = GameObj_Defencer.critical_chance
		elseif self.tbCfg.EffecType == macro_pb.Skill_Effect_Add_CriticalResistance--增加韧性属性
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Reduce_CriticalResistance--[[减少韧性属性]] then
			nBaseProp = GameObj_Defencer.critical_resistance
		elseif self.tbCfg.EffecType == macro_pb.Skill_Effect_Add_CriticalStrike--增加必杀属性
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Reduce_CriticalStrike--[[减少必杀属性]] then
			nBaseProp = GameObj_Defencer.critical_strike
		elseif self.tbCfg.EffecType == macro_pb.Skill_Effect_Add_CriticalStrikeResistance--增加刚毅属性
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Reduce_CriticalStrikeResistance--[[减少刚毅属性]] then
			nBaseProp = GameObj_Defencer.critical_strikeresistance
		elseif self.tbCfg.EffecType == macro_pb.Skill_Effect_Add_HitChance--增加命中属性
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Reduce_HitChance--[[减少命中属性]] then
			nBaseProp = GameObj_Defencer.hit_change
		elseif self.tbCfg.EffecType == macro_pb.Skill_Effect_Add_DodgeChance--增加闪避属性
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Reduce_DodgeChance--[[减少闪避属性]] then
			nBaseProp = GameObj_Defencer.dodge_chance
		elseif self.tbCfg.EffecType == macro_pb.Skill_Effect_Add_PenetrateChance--增加穿刺属性
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Reduce_PenetrateChance--[[减少穿刺属性]] then
			nBaseProp = GameObj_Defencer.penetrate_chance
		elseif self.tbCfg.EffecType == macro_pb.Skill_Effect_Add_BlockChance --增加格挡属性
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Reduce_BlockChance--[[减少格挡属性]] then
			nBaseProp = GameObj_Defencer.block_chance
		elseif self.tbCfg.EffecType == macro_pb.Skill_Effect_Add_Damage_Reduction--增加万分比免伤
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Reduce_Damage_Reduction--[[减少万分比免伤]] then
			nBaseProp = GameObj_Defencer.damage_reduction
        
		else
			error("error tyep:"..self.tbCfg.EffecType)
		end

		self.data = math.floor(self.tbCfg.EffectValue1 + (nBaseProp * self.tbCfg.EffectValue2) / g_BasePercent)




	end	
end


