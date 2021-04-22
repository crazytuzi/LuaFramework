--斗罗SKILL 宗门武魂大招触发惩罚伤害
--宗门武魂争霸
--id 51377
--通用 器武魂独立头/兽武魂独立臂
--[[
50%最大血量伤害
]]--
--创建人：庞圣峰
--创建时间：2019-1-5

local zmwh_boss_tongyong_dazhao_damage = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
     	{
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {is_hit_effect = true},
		},
		{
			CLASS = "action.QSBActorStatus",
			OPTIONS = {
				{"self:hp_percent>0","self:decrease_hp:maxHp*0.5","under_status"},
			},
		},
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}
return zmwh_boss_tongyong_dazhao_damage