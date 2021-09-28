--------------------------------------------------------------------------------------
-- 文件名:	HF_BattleCard.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	flamehong
-- 日  期:	2014-9-22 20:43
-- 版  本:	1.0
-- 描  述:	效果-镇定
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------


CEffectCalm = class("CEffectCalm", function() return CEffectBase:new() end)
CEffectCalm.__index = CEffectCalm

function CEffectCalm:takeEffect()
end


