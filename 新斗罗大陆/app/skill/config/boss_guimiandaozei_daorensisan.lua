-- 技能 鬼面盗贼旋转刀刃爆炸
-- 技能ID 50361
-- 爆炸,飞刀射向敌人,然后自杀(现在自杀动画会留一帧,可能很丑)
--[[
	boss 鬼面盗贼的刀刃
	ID:3284 副本6-8
	psf 2018-3-30
]]--

local boss_guimiandaozei_daorensisan = {
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
                    ARGS = {
                        {
                            CLASS = "action.QSBBullet",
							OPTIONS = {shake = {amplitude = 2, duration = 0.17, count = 1},rail_number = 3, rail_inter_frame = 1}
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
					OPTIONS = {delay_frame = 40},
				},
				{
					CLASS = "action.QSBActorFadeOut",
					OPTIONS = {duration = 0.2, revertable = true},
				},
				{
					CLASS = "action.QSBImmuneCharge",
					OPTIONS = {enter = true, revertable = true},
				},
				{
					CLASS = "action.QSBSuicide",
				},
				{
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
    },
}

return boss_guimiandaozei_daorensisan

