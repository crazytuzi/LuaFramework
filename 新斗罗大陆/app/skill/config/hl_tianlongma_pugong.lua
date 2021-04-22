-- 技能 天龙马普攻
-- 技能ID 30008
-- 雷霆万钧：闪电链（随机弹2次），有概率给目标附带静电标记，持续很久
--[[
	hunling 天龙马
	ID:2008
	psf 2019-6-10
]]--

local hl_tianlongma_pugong = {
    CLASS = "composite.QSBParallel",
    ARGS = {
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
                    OPTIONS = {delay_frame = 7},
                },
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {--[[effect_id = "tianlongma_attack01_1",]] is_hit_effect = false, haste = true},
				},
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 20},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
							CLASS = "action.QSBJumpLaser",
							OPTIONS = {--[[effect_id = "tianlongma_attack01_2",]] attack_dummy = "dummy_weapon1", sort_layer_with_pos = true, --层级取目标
							hit_effect_id = "tianlongma_attack01_3",effect_width = 300, jump_num = 3,move_time = 0.1,duration = 0.2},
						},
                    },
                },
            },
        },
    },
}

return hl_tianlongma_pugong