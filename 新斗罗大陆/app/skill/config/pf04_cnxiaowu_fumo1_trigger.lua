-- 技能 小舞 附魔I虚无爆杀
-- 技能ID 180120
-- 目标是BOSS就触发180126,否则触发180129
--[[
	hero 成年小舞
	ID:1025
	psf 2018-9-19
]]--
--2019年1月21日 BOSS判定暂时改成target:trigger_skill_as_target写法热更,后面优化恢复原写法

local pf_cnxiaowu_fumo1_trigger = {
     CLASS = "composite.QSBSequence",
     ARGS = {
		{
			CLASS = "action.QSBActorStatus",
			OPTIONS = 
			{
			   { "target:hp_percent<0.4","target:apply_buff:fumo_cnxiaowu_debuff"},
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
							   { "target:role==boss_or_elite_boss","target:trigger_skill_as_target:180126","under_status"},
							}
						},
						{
							CLASS = "action.QSBActorStatus",
							OPTIONS = 
							{
							   { "target:role==boss_or_elite_boss","target:trigger_skill_as_target:283129","not_under_status"},
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

return pf_cnxiaowu_fumo1_trigger