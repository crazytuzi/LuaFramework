--------------------------------------------------------------------------------------
-- 文件名:	EffectDefend.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	效果-绝对防御 受效果影响的单位，立即获得守备效果 该回合受到伤害只损失1点生命值（中毒也算），不填任何参数
-- 应  用:  
---------------------------------------------------------------------------------------


EffectDefend = class("EffectDefend", function() return CEffectBase:new() end)
EffectDefend.__index = EffectDefend

function EffectDefend:takeEffect(GameObj_Attacker, GameObj_Defencer, bTakeFirst)
    
    if not GameObj_Attacker or not GameObj_Defencer then  return end
	self.data = GameObj_Defencer.EffectValue1 or 1
end


