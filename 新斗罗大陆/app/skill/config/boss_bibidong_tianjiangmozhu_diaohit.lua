-- 技能 BOSS比比东 天降魔蛛叼起来
-- 技能ID 50841
-- 击飞
--[[
	boss 比比东 
	ID:3681 副本14-16
	psf 2018-7-5
]]--

local boss_bibidong_tianjiangmozhu_diaoanim = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
			CLASS = "action.QSBHitTarget",
		},
		{
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 0.75},
				},
				{
					CLASS = "action.QSBActorFadeOut",
				},
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 2},
				},
				{
					CLASS = "action.QSBActorFadeIn",
				},
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return boss_bibidong_tianjiangmozhu_diaoanim	