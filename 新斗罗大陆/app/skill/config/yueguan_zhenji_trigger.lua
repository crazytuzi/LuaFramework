-- 技能 月关 注入异茸
-- ID 190079
-- 上yueguan_zhenji_debuff
--[[
	hero 月关
	ID:1018
	psf 2018-11-14
]]--
local yueguan_zhenji_trigger = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {buff_id = "yueguan_zhenji_buff1",remove_all_same_buff_id = true},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBArgsIsUnderStatus",
					OPTIONS = {is_attacker = true,status = "yueguan_zhenji_plus"},
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = 
					{
						{
							CLASS = "action.QSBActorStatus",
							OPTIONS = 
							{
							   { "target:role==boss_or_elite_boss","target:apply_buff:yueguan_zhenji_boss_debuff","under_status"},
							}
						},
					},
				},
			},
		},
		{
			CLASS = "action.QSBActorStatus",
			OPTIONS = 
			{
			   { "target:role==boss_or_elite_boss","target:apply_buff:yueguan_zhenji_debuff","not_under_status"},
			}
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return yueguan_zhenji_trigger 

