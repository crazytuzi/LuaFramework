-- 技能 小狒狒强化金刚狒狒
-- 技能ID 53281
--[[
	挖宝狒狒 4102
	升灵台
	psf 2020-4-13
]]--

local shenglt_xiaoff_qianghua = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBRandomTrap",
            OPTIONS = {trapId = "shenglt_jingff_pugong_trap",interval_time = 0.25,count = 2}
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 18},
                },
				{
					CLASS = "action.QSBPlayTrapEffect",
					OPTIONS = {effect_id = "shenglt_jingangfeifei_attack01_4_2", find_by_status = true, status = "jingff_dazhao"},
				},
			},
		},
		--1
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 21},
                },
				{
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {damage_scale = 0.1},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 41},
                },
				{
					CLASS = "action.QSBPlayTrapEffect",
					OPTIONS = {effect_id = "shenglt_jingangfeifei_attack01_4_2", find_by_status = true, status = "jingff_dazhao"},
				},
				{
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {damage_scale = 0.1},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 71},
                },
				{
					CLASS = "action.QSBPlayTrapEffect",
					OPTIONS = {effect_id = "shenglt_jingangfeifei_attack01_4_2", find_by_status = true, status = "jingff_dazhao"},
				},
				{
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {damage_scale = 0.5},
				},
            },
        },
		--2
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 111},
                },
				{
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {damage_scale = 0.5},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 131},
                },
				{
					CLASS = "action.QSBPlayTrapEffect",
					OPTIONS = {effect_id = "shenglt_jingangfeifei_attack01_4_2", find_by_status = true, status = "jingff_dazhao"},
				},
				{
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {damage_scale = 0.5},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 161},
                },
				{
					CLASS = "action.QSBPlayTrapEffect",
					OPTIONS = {effect_id = "shenglt_jingangfeifei_attack01_4_2", find_by_status = true, status = "jingff_dazhao"},
				},
				{
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {damage_scale = 2},
				},
            },
        },
		--3
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 201},
                },
				{
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {damage_scale = 1},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 221},
                },
				{
					CLASS = "action.QSBPlayTrapEffect",
					OPTIONS = {effect_id = "shenglt_jingangfeifei_attack01_4_2", find_by_status = true, status = "jingff_dazhao"},
				},
				{
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {damage_scale = 1},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 251},
                },
				{
					CLASS = "action.QSBPlayTrapEffect",
					OPTIONS = {effect_id = "shenglt_jingangfeifei_attack01_4_2", find_by_status = true, status = "jingff_dazhao"},
				},
				{
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {damage_scale = 3},
				},
            },
        },
    },
}

return shenglt_xiaoff_qianghua