--斗罗SKILL 蓝电专属技
--宗门武魂争霸
--id 51356
--通用 主体
--[[
主目标上zmwh_boss_zhuanshuji_landian_debuff2
再打伤害
]]--
--创建人：庞圣峰
--创建时间：2019-1-9

local zmwh_boss_zhuanshuji_landian = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = false},
				},
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 1 },
						},
						{
							CLASS = "composite.QSBParallel",
							ARGS = { 
								{
									CLASS = "action.QSBPlaySceneEffect",
									OPTIONS = {effect_id = "zmwh_boss_shouwuhun_attack05_3_2", pos  = {x = 640 , y = 410}, scale_actor_face = -1, front_layer = true},
								},
								{
									CLASS = "action.QSBHitTarget",
								},
							},
						},
						-- {
							-- CLASS = "action.QSBAttackByBuffNum",
							-- OPTIONS = {
								-- buff_id = "zmwh_boss_zhuanshuji_count_debuff", target_type = "enemy",
								-- num_pre_stack_count = 4, attackMaxNum = 1,
								-- trigger_skill_id = 51361
							-- },
						-- },
					},
				},
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 2.7 },
						},
						{
							CLASS = "action.QSBAttackFinish"
						},
					},
				},
            },
        },
    },
}

return zmwh_boss_zhuanshuji_landian