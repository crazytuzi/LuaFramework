-- 技能 金刚狒狒大招
-- 技能ID 35021~25
-- 砸三下 陷阱共鸣
--[[
    hunling 金刚狒狒
    ID:2004
    psf 2019-6-14
]]--

local hl_jingff_dazhao = {
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
                    OPTIONS = {delay_frame = 18},
                },
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "jingangfeifei_attack11_1", is_hit_effect = false, haste = true},
				},
            },
        },
		
        {
            CLASS = "action.QSBTriggerSkill",
            OPTIONS = {skill_id = 52118, target_type = "skill_target", wait_finish = false},
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
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 42},
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
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 73},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
    },
}

return hl_jingff_dazhao