--斗罗SKILL 兽武魂大招触发惩罚
--宗门武魂争霸
--id 51375
--通用 兽武魂独立头
--[[
播动效
hit上debuff
]]--
--创建人：庞圣峰
--创建时间：2019-1-5

local zmwh_boss_shouwuhun_dazhao_trigger = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
     	{
			CLASS = "action.QSBPlayAnimation",
			OPTIONS = {animation = "attack11"},
		},
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 2.2 },
				},
				{
					 CLASS = "composite.QSBParallel",
					 ARGS = 
					 {
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = false},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBHitTarget",
						},
					},
				},
			},
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 3.5 },
				},
				{
					CLASS = "action.QSBSuicide"
				},
				{
					CLASS = "action.QSBAttackFinish"
				},
			},
        },
    },
}
return zmwh_boss_shouwuhun_dazhao_trigger