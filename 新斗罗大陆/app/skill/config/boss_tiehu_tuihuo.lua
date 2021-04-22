-- 技能 推火
-- 向前方推出火焰
--[[
	boss 铁虎
	ID:3304 副本3-4
	psf 2018-1-22
]]--

local boss_tiehu_tuihuo = {
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
					OPTIONS = {delay_frame = 26},
				},
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {is_tornado = true, tornado_size = {width = 115, height = 450}, start_pos = {x = 0, y = 75, is_animation = false}},
				},
			},
		},
    },
}

return boss_tiehu_tuihuo    