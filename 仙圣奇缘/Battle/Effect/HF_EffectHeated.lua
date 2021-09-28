--------------------------------------------------------------------------------------
-- 文件名:	HF_BattleCard.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	flamehong
-- 日  期:	2014-9-22 20:43
-- 版  本:	1.0
-- 描  述:	效果-激昂 如果目标当前的气势低于EffectValue1，则目标的气势等于EffectValue1 受效果影响的单位，立即获得当前气势的改变
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------


CEffectHeated = class("CEffectHeated", function() return CEffectBase:new() end)
CEffectHeated.__index = CEffectHeated

function CEffectHeated:takeEffect(GameObj_Attacker, GameObj_Defencer, bTakeFirst)
    
    if not GameObj_Attacker or not GameObj_Defencer then  return end
    GameObj_Defencer.mana = math.max(GameObj_Defencer.mana, self.tbCfg.EffectValue1)
   
    gEffectData:setHpEffectBleed(GameObj_Defencer.apos, GameObj_Defencer.mana)
	gEffectData:setEffectCardObj(GameObj_Defencer.apos, GameObj_Defencer)
end


