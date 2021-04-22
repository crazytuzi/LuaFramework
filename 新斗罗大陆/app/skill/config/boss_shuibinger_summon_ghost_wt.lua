-- 技能 水冰儿召唤冰鸟武魂(钻石)
-- 技能ID 50657
-- 召唤放置陷阱的NPC
--[[
	boss 水冰儿
	ID:3176 智慧试炼
	psf 2018-5-31
]]--

local boss_shuibinger_summon_ghost_wt = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
			CLASS = "action.QSBPlayAnimation",
			OPTIONS = {animation = "attack13"},
		},
		{
             CLASS = "composite.QSBSequence",
             ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 1.2},
				},
				{
					CLASS = "action.QSBSummonGhosts",
					OPTIONS = {actor_id = 3177, life_span = 25,number = 1, no_fog = true, use_render_texture = false, hp_percent = 1,absolute_pos = {x = 600, y = 350}},
				},
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 0.6},
				},
				{
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return boss_shuibinger_summon_ghost_wt