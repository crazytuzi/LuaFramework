--------------------------------------------------------------------------------------
-- 文件名:	HF_BattleCard.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	flamehong
-- 日  期:	2014-9-15 15:03
-- 版  本:	1.0
-- 描  述:	战斗效果管理类
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

CEffectBleed = class("CEffectBleed", function() return CEffectBase:new() end)
CEffectBleed.__index = CEffectBleed

function CEffectBleed:takeEffect(GameObj_Attacker, GameObj_Defencer, bTakeFirst)
	if bTakeFirst then
        local bleedFlag = true  -- true 回血 false 流血
		local nAdjustDamage = 0
		if self.tbCfg.EffecType == macro_pb.Skill_Effect_Bleed_Phy  then --流血武力伤害

			nAdjustDamage = math.max(GameObj_Attacker:get_phy_attack() - GameObj_Defencer:get_phy_defence(), GameObj_Attacker:get_phy_attack()*0.15)
            bleedFlag = false
		elseif self.tbCfg.EffecType == macro_pb.Skill_Effect_Bleed_Mag then ----流血法术伤害

			nAdjustDamage = math.max(GameObj_Attacker:get_mag_attack() - GameObj_Defencer:get_mag_defence(), GameObj_Attacker:get_mag_attack()*0.15)
             bleedFlag = false
		elseif self.tbCfg.EffecType == macro_pb.Skill_Effect_Bleed_PhySkill then --流血武力加绝技伤害
		
			nAdjustDamage = math.max(GameObj_Attacker:get_phy_attack() - GameObj_Defencer:get_phy_defence(), 
				GameObj_Attacker:get_phy_attack() * 0.15) + math.max(GameObj_Attacker:get_skill_attack() - GameObj_Defencer:get_skill_defence(), 
				GameObj_Attacker:get_skill_attack() * 0.15)
				 bleedFlag = false
		elseif self.tbCfg.EffecType == macro_pb.Skill_Effect_Bleed_MagSkill then --流血法术加绝技伤害
		
			nAdjustDamage = math.max(GameObj_Attacker:get_mag_attack() - GameObj_Defencer:get_mag_defence(), 
				GameObj_Attacker:get_mag_attack() * 0.15) + math.max(GameObj_Attacker:get_skill_attack() - GameObj_Defencer:get_skill_defence(), 
				GameObj_Attacker:get_skill_attack() * 0.15)
                 bleedFlag = false
		elseif self.tbCfg.EffecType == macro_pb.Skill_Effect_Cure_Phy then--[[回血武力治疗]] 

			nAdjustDamage = GameObj_Attacker:get_phy_attack() - self.tbCfg.EffectValue1

		elseif self.tbCfg.EffecType == macro_pb.Skill_Effect_Cure_Mag then--[[回血法术治疗]] 

			nAdjustDamage = GameObj_Attacker:get_mag_attack() - self.tbCfg.EffectValue1

		elseif self.tbCfg.EffecType == macro_pb.Skill_Effect_Cure_PhySkill then  --[[回血武力加绝技治疗]]

			nAdjustDamage = GameObj_Attacker:get_phy_attack() + GameObj_Attacker:get_skill_attack() + self.tbCfg.EffectValue1

		elseif self.tbCfg.EffecType == macro_pb.Skill_Effect_Cure_MagSkill then --回血法术加绝技治疗

			nAdjustDamage = GameObj_Attacker:get_mag_attack() + GameObj_Attacker:get_skill_attack() + self.tbCfg.EffectValue1
		end

        local sum = math.floor((nAdjustDamage + self.tbCfg.EffectValue1) * (self.tbCfg.EffectValue2) / g_BasePercent)
         
        if  bleedFlag then  sum = -sum end
        self.data = sum

        gEffectData:setHpEffectBleed(GameObj_Defencer.apos, self.data)
		gEffectData:setEffectCardObj(GameObj_Defencer.apos, GameObj_Defencer)

	end
end
