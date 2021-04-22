-- 技能 象甲宗召唤陷阱放置者
-- 技能ID 50376
-- 召唤放置陷阱的NPC
--[[
	boss 象甲宗
	ID:3282 副本6-4
	psf 2018-3-30
]]--

local boss_xiangjiazong_summon_trapsetter = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {is_target = false, buff_id = "boss_special_mark"},--加上BOSS标记
		},
        {
             CLASS = "composite.QSBSequence",
             ARGS = {
				{
					CLASS = "action.QSBSummonGhosts",
					OPTIONS = {actor_id = 3289, life_span = 120,number = 1, absolute_pos = {x = 450, y = 800}, no_fog = true, --[[inrange = true,]] use_render_texture = false},
				},
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
    },
}

return boss_xiangjiazong_summon_trapsetter