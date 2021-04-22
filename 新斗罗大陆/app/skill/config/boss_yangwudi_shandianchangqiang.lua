-- 技能 闪电长枪
-- 全屏AOE
--[[
	boss 杨无敌
	ID:3246 副本2-4
	psf 2018-3-22
]]--

local boss_yangwudi_shandianchangqiang = {
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
                    CLASS = "action.QSBPlaySceneEffect",
                    OPTIONS = {effect_id = "yangwudi_attack11_3", pos  = {x = 575 , y = 180}, ground_layer = true},
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
			},
        },
    },
}

return boss_yangwudi_shandianchangqiang
