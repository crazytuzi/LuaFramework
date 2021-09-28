--------------------------------------------------------------------------------------
-- 文件名:	EffectRemoveMana.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	效果-消除怒气 如果目标当前的气势高于EffectValue1，则目标的气势等于EffectValue1
-- 应  用:    
---------------------------------------------------------------------------------------
EffectRemoveMana = class("EffectRemoveMana", function() return CEffectBase:new() end)
EffectRemoveMana.__index = EffectRemoveMana

function EffectRemoveMana:takeEffect(GameObj_Attacker, GameObj_Defencer, bTakeFirst)

	if not GameObj_Attacker or not GameObj_Defencer or not self.tbCfg then  return end

    if self.tbCfg.EffecType == macro_pb.Skill_Effect_RemoveMana --[[消除怒气]] then
        
        GameObj_Defencer.mana = GameObj_Defencer.mana >= self:getDataValue1() and self:getDataValue1() or GameObj_Defencer.mana
    
    	gEffectData:setManaEffectValue(GameObj_Defencer.apos, GameObj_Defencer.mana)
		gEffectData:setEffectCardObj(GameObj_Defencer.apos, GameObj_Defencer)
    end
end


