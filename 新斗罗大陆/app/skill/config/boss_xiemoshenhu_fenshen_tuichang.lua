-- 技能 BOSS邪魔神虎 分身 退场
-- 技能ID 50869
-- 自然消失
--[[
	boss 邪魔神虎
	ID:3697
	psf 2018-7-19
]]--

local boss_xiemoshenhu_fenshen_tuichang = 
{
	CLASS = "composite.QSBSequence",
	ARGS =
	{
		{
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
			CLASS = "composite.QSBParallel",
			ARGS = 
			{
				{
					CLASS = "action.QSBActorFadeOut",
					OPTIONS = {duration = 0.3, revertable = true},
				},
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "heihu_attack12_1_2" ,is_hit_effect = false},
				},
            },
        },
		{
			CLASS = "action.QSBSuicide",
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}
return boss_xiemoshenhu_fenshen_tuichang