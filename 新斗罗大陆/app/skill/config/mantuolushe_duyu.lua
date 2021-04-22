-- 技能 闪电长枪
-- 全屏AOE
--[[
	boss 杨无敌
	ID:3246 副本2-4
	psf 2018-3-22
]]--

local mantuolushe_duyu = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
		{
			 CLASS = "composite.QSBSequence",
             ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 34},
				},
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "mantuoluoshe_attack11_3", is_hit_effect = false},
				},
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 8},
				},
				{
					CLASS = "action.QSBHitTarget",
				},
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "mantuoluoshe_attack11_3", is_hit_effect = false},
				},
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 8},
				},
				{
					CLASS = "action.QSBHitTarget",
				},
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 8},
				},
				{
					CLASS = "action.QSBHitTarget",
				},
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "mantuoluoshe_attack11_3", is_hit_effect = false},
				},
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 8},
				},
				{
					CLASS = "action.QSBHitTarget",
				},
			},
        },
    },
}

return mantuolushe_duyu
