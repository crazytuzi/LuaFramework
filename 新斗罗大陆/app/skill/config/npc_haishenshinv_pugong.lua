-- 技能 海神侍女普攻
-- ID 50903
--[[
	海神侍女
	ID:3711 3712
	psf 2018-7-26
]]--


local npc_haishenshinv_pugong = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound",
        },
        {
            CLASS = "composite.QSBSequence",
             ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
		{
            CLASS = "composite.QSBSequence",
             ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 23},
				},
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {flip_follow_y = true},
				},
            },
        },
    },
}

return npc_haishenshinv_pugong