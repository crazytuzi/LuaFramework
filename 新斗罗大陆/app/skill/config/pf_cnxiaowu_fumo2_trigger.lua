-- 技能 小舞 附魔II虚无爆杀
-- 技能ID 180121
-- 目标是BOSS就触发180127,否则触发180130
--[[
	hero 成年小舞
	ID:1025
	psf 2018-9-19
]]--
--2019年1月21日 BOSS判定暂时改成target:trigger_skill_as_target写法热更,后面优化恢复原写法

local pf_cnxiaowu_fumo2_trigger = {
     CLASS = "composite.QSBSequence",
     ARGS = {
		{
			CLASS = "action.QSBActorStatus",
			OPTIONS = 
			{
			   { "target:hp_percent<0.45","target:apply_buff:fumo_cnxiaowu_debuff"},
			}
		},
		{
			CLASS = "action.QSBArgsIsUnderStatus",
			OPTIONS = {is_attackee = true,status = "cnxiaowu_fumo_debuff"},
		},
		{
			CLASS = "composite.QSBSelector",
			ARGS = 
			{
				----有残血标记时
				{
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
							CLASS = "action.QSBActorStatus",
							OPTIONS = 
							{
							   { "target:role==boss_or_elite_boss","target:trigger_skill_as_target:180127","under_status"},
							}
						},
						{
							CLASS = "action.QSBActorStatus",
							OPTIONS = 
							{
							   { "target:role==boss_or_elite_boss","target:trigger_skill_as_target:280130","not_under_status"},
							}
						},
						{
							CLASS = "action.QSBAttackFinish"
						},	
					},
				},
				------没有残血标记时
				{
					CLASS = "composite.QSBParallel",
					ARGS = 
					{
						{
							CLASS = "action.QSBAttackFinish"
						},
					},
				}
			},
		},
    },
}

return pf_cnxiaowu_fumo2_trigger