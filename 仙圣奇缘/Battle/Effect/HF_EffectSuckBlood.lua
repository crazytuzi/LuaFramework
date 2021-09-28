--------------------------------------------------------------------------------------
-- 文件名:	HF_EffectSuckBlood.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	flamehong
-- 日  期:	2014-9-22 21:09
-- 版  本:	1.0
-- 描  述:	效果-吸血
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------


CEffectSuckBlood = class("CEffectSuckBlood", function() return CEffectBase:new() end)
CEffectSuckBlood.__index = CEffectSuckBlood

function CEffectSuckBlood:takeEffect(GameObj_Attacker, GameObj_Defencer, bTakeFirst)
	if bTakeFirst then
		self.data = self.tbCfg.EffectValue1 / g_BasePercent
	end

end


