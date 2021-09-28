--------------------------------------------------------------------------------------
-- 文件名:	HF_BattleCard.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	flamehong
-- 日  期:	2014-9-22 21:09
-- 版  本:	1.0
-- 描  述:	效果-修改当前生命
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------


CEffectModifyHP = class("CEffectModifyHP", function() return CEffectBase:new() end)
CEffectModifyHP.__index = CEffectModifyHP

function CEffectModifyHP:takeEffect(GameObj_Attacker, GameObj_Defencer, bTakeFirst)
    
    if not GameObj_Attacker or not GameObj_Defencer then  return end
 
    if self.tbCfg.EffecType == macro_pb.Skill_Effect_Add_MaxHP--增加生命上限
	or self.tbCfg.EffecType == macro_pb.Skill_Effect_Reduce_MaxHP--减少生命上限
	or self.tbCfg.EffecType == macro_pb.Skill_Effect_Add_HPMaxPercent--增加生命上限万分比
	or self.tbCfg.EffecType == macro_pb.Skill_Effect_Reduce_HPMaxPercent--[[减少生命上限万分比]] then
	
        self.data = math.floor(self.tbCfg.EffectValue1 + (GameObj_Defencer.max_hp * self.tbCfg.EffectValue2) / g_BasePercent)

    else
        local nMaxHp = GameObj_Defencer.max_hp
		local nAddHp = self.tbCfg.EffectValue1 + (nMaxHp * self.tbCfg.EffectValue2) / g_BasePercent

        self.data = math.floor(-nAddHp)
		
		gEffectData:setHpEffectBleed(GameObj_Defencer.apos, self.data)
		gEffectData:setEffectCardObj(GameObj_Defencer.apos, GameObj_Defencer)
	   
		g_BattleMgr:handleBleedDamage(GameObj_Defencer, macro_pb.Battle_Effect_Bleed, -nAddHp)
    end
end


