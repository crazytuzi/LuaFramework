-- 技能 小天使普攻
-- 技能ID 53294
-- 目标血量越低伤害越高
--[[
	小天使 4109
	升灵台
	psf 2020-4-13
]]--
local shenglt_xiaotianshi_pugong = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = {
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = {  
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = true},
                                },
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBArgsConditionSelector",
                                            OPTIONS = {
                                                failed_select = 5,
                                                {expression = "target:hp<target:max_hp*0.15", select = 1},
                                                {expression = "target:hp<target:max_hp*0.3", select = 2},
                                                {expression = "target:hp<target:max_hp*0.5", select = 3},
                                                {expression = "target:hp<target:max_hp*0.75", select = 4},
                                            }
                                        },
                                        {
                                            CLASS = "composite.QSBSelector",
                                            ARGS = {
                                                {
                                                    CLASS = "composite.QSBSequence",
                                                    ARGS = {
                                                        {
                                                            CLASS = "action.QSBHitTarget",
                                                            OPTIONS = {damage_scale = 3},
                                                        },
                                                        {
                                                            CLASS = "action.QSBHitTarget",
                                                            OPTIONS = {damage_scale = 2.5},
                                                        },
                                                        {
                                                            CLASS = "action.QSBHitTarget",
                                                            OPTIONS = {damage_scale = 2},
                                                        },
                                                        {
                                                            CLASS = "action.QSBHitTarget",
                                                            OPTIONS = {damage_scale = 1.5},
                                                        },
                                                        {
                                                            CLASS = "action.QSBHitTarget",
                                                        },
                                                    },
                                                },
                                            },
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shenglt_xiaotianshi_pugong