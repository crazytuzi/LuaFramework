--斗罗SKILL 钻出来/砸下来
--宗门武魂争霸
--id 51378
--通用 大招独立头/臂
--[[
入场
打个AOE
]]--
--创建人：庞圣峰
--创建时间：2019-1-5

local zmwh_boss_tongyong_dazhao_appear = 
{
     CLASS = "composite.QSBParallel",
     ARGS = 
     {
     	{
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "zmwh_boss_dazhaoer_mark"},
        },
		{
			CLASS = "action.QSBPlayAnimation",
			OPTIONS = {animation = "attack21"},
		},
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 0.3 },
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
				{
					CLASS = "action.QSBAttackFinish"
				},
			},
        },

    },
}
return zmwh_boss_tongyong_dazhao_appear