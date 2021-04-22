--斗罗SKILL 宗门武魂延爆伤害
--宗门武魂争霸
--id 51362
--通用 主体
--[[
如果是守卫,触发51363,否则直接hit
]]--
--创建人：庞圣峰
--创建时间：2019-1-5

local zmwh_boss_tongyong_third2_trigger = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
     	{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBArgsIsUnderStatus",
					OPTIONS = {is_attacker = true,status = "zmwh_boss_shouwei"},
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = {
						----守卫
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBTriggerSkill",
									OPTIONS = {skill_id = 51363, target_type = "skill_target" },
								},
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {effect_id ="zmwh_boss_shouwuhun_attack07_3_3",is_hit_effect = false},
								},
								{
									CLASS = "action.QSBRemoveBuff",
									OPTIONS = {is_target = false, buff_id = "zmwh_boss_qiwuhun_third2_debuff"},
								},
								{
									CLASS = "action.QSBRemoveBuff",
									OPTIONS = {is_target = false, buff_id = "zmwh_boss_qiwuhun_third2_yujing"},
								},
								{
									CLASS = "action.QSBShakeScreen",
									OPTIONS = {amplitude = 3, duration = 0.15, count = 1,},
								},
								{
									CLASS = "action.QSBAttackFinish"
								},
							},
						},
						----玩家魂师
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBHitTarget",
								},
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {effect_id ="zmwh_boss_shouwuhun_attack07_3_3",is_hit_effect = false},
								},
								{
									CLASS = "action.QSBRemoveBuff",
									OPTIONS = {is_target = false, buff_id = "zmwh_boss_qiwuhun_third2_debuff"},
								},
								{
									CLASS = "action.QSBRemoveBuff",
									OPTIONS = {is_target = false, buff_id = "zmwh_boss_qiwuhun_third2_yujing"},
								},
								{
									CLASS = "action.QSBShakeScreen",
									OPTIONS = {amplitude = 3, duration = 0.15, count = 1,},
								},
								{
									CLASS = "action.QSBAttackFinish"
								},
							},
						},
					},
				},
			},
		},
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}
return zmwh_boss_tongyong_third2_trigger