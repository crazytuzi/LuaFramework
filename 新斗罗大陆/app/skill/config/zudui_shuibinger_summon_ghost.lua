-- 技能 水冰儿召唤冰鸟武魂(钻石)
-- 技能ID 50364
-- 召唤放置陷阱的NPC
--[[
	boss 水冰儿
	ID:3285 副本6-12
	psf 2018-3-30
]]--

local zudui_shuibinger_summon_ghost = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
		{
			CLASS = "action.QSBPlayAnimation",
		},
		{
             CLASS = "composite.QSBSequence",
             ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 38},
				},
				{
					CLASS = "action.QSBSummonGhosts",
					OPTIONS = {actor_id = 3901, life_span = 25,number = 1, no_fog = true, use_render_texture = false, hp_percent = 1},
				},
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 17},
				},
				{
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return zudui_shuibinger_summon_ghost