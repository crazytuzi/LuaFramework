--------------------------------------------------------------------------------------
-- 文件名:	HF_BattleCard.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	flamehong
-- 日  期:	2014-9-22 20:21
-- 版  本:	1.0
-- 描  述:	战斗效果基础类
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------


CEffectBase = class("CEffectBase")
CEffectBase.__index = CEffectBase

function CEffectBase:initialize(tbEffectCfg)
	self:clear()
	self.tbCfg = tbEffectCfg
end

function CEffectBase:addEffect(GameObj_Attacker, GameObj_Defencer, tbStatusCfg, nEffectType, nEffectLv)
	
    self.left_con = tbStatusCfg.StatusCon
    self:takeEffect(GameObj_Attacker, GameObj_Defencer, true)

end

function CEffectBase:takeEffect(GameObj_Attacker, GameObj_Defencer, bTakFirst)
    
    if not GameObj_Attacker or not GameObj_Defencer or not self.tbCfg then 
        return 
    end

    if self.tbCfg.EffecType == macro_pb.Skill_Effect_ImproveDamage then --百分比提高伤害
        self.data = self.tbCfg.EffectValue1 / g_BasePercent
    elseif self.tbCfg.EffecType == macro_pb.Skill_Effect_Fury then 
--        当生命万分比低于EffectValue1/10000的时候，伤害提高EffectValue2/10000
    end

end

function CEffectBase:isManaEffect()
	local nType = self.tbCfg.EffecType
	return nType == macro_pb.Skill_Effect_Add_Mana
			or nType == macro_pb.Skill_Effect_Reduce_Mana
			or nType == macro_pb.Skill_Effect_ModifyMana
			or nType == macro_pb.Skill_Effect_Add_Mana
			or nType == macro_pb.Skill_Effect_Add_Mana
			or nType == macro_pb.Skill_Effect_Add_Mana
			or nType == macro_pb.Skill_Effect_Add_Mana
			or nType == macro_pb.Skill_Effect_Add_Mana
			or nType == macro_pb.Skill_Effect_Add_Mana
			or nType == macro_pb.Skill_Effect_Add_Mana
			or nType == macro_pb.Skill_Effect_Add_Mana
end

function CEffectBase:isValid()
	return self.left_con > 0
end

function CEffectBase:getData()
	if self:isValid() then
		return self.data
	end
    return 0
end

function CEffectBase:getDataValue1()
    if not self.tbCfg then 
        return 0
    end
	return self.tbCfg.EffectValue1
end

function CEffectBase:getDataValue2()
    if not self.tbCfg then 
        return 0
    end
	return self.tbCfg.EffectValue2
end

function CEffectBase:onTurn()
	if self.left_con > 0 then
		self.left_con = self.left_con -1 
		if self.left_con == 0 then
			self:clear()
		end
	end
end

function CEffectBase:clear()
	self.data = 0
	self.left_con = 0
	self.tbCfg = nil
end
