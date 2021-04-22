-- 技能 金刚狒狒大招触发
-- 技能ID 35026~30
--  陷阱共鸣
--[[
    hunling 金刚狒狒
    ID:2004
    psf 2019-6-14
]]--

local hl_jingff_dazhao_trigger = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 18},
                },
				{
					CLASS = "action.QSBPlayTrapEffect",
					OPTIONS = {effect_id = "jingangfeifei_attack01_4_2", find_by_status = true, status = "jingff_dazhao"},
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
				},
            },
        },
        --2
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
					CLASS = "action.QSBPlayTrapEffect",
					OPTIONS = {effect_id = "jingangfeifei_attack01_4_2", find_by_status = true, status = "jingff_dazhao"},
				},
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 24},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
        --3
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
					CLASS = "action.QSBPlayTrapEffect",
					OPTIONS = {effect_id = "jingangfeifei_attack01_4_2", find_by_status = true, status = "jingff_dazhao"},
				},
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 33},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return hl_jingff_dazhao_trigger