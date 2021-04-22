-- 技能 ss剑道尘心神技伤害
-- 技能ID 39085~8
-- 全屏多段
--[[
	魂师 剑道尘心
	ID:1056
	psf 2020-4-21
]]--

local sschenxin_shenji_pugong_damage = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBArgsIsDirectionLeft",
            OPTIONS = {is_attacker = true},
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = {
                {
					CLASS = "action.QSBPlaySceneEffect",
					OPTIONS = {effect_id = "sschenxin_attack02_3", pos  = {x = 640 , y = 340},front_layer = true},
                },
                {
					CLASS = "action.QSBPlaySceneEffect",
					OPTIONS = {effect_id = "sschenxin_attack02_3r", pos  = {x = 640 , y = 340},front_layer = true},
                },
            },
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "sschenxin_attack01_3", is_hit_effect = true},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_frame = 2},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "sschenxin_attack01_3", is_hit_effect = true},
                },
                {
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {damage_scale = 0.9},
                },
            },
        },
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_frame = 3},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "sschenxin_attack01_3", is_hit_effect = true},
                },
                {
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {damage_scale = 1.4},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sschenxin_shenji_pugong_damage

