-- 技能 变异金属普攻
-- 技能ID 30009
-- 冰极无双：子弹技能，有概率给友方血量最低目标上一层【护盾】状态，降低收到伤害，持续X秒
--[[
	hunling 变异金属
	ID:2009 
	psf 2019-7-25
]]--

local hl_bianyijinshu_pugong5 = {
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBArgsRandom",
            OPTIONS = {
                info = {count = 1},
                input = {
                    datas = {1,2},
                    formats = {3,2},
                },
                output = {output_type = "data"},
                args_translate = { select = "number"}
            },
        },
        {
            CLASS = "composite.QSBSelectorByNumber",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBParallel",
                    OPTIONS = {flag = 1},
                    ARGS = {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                    OPTIONS = {animation = "attack01"},
                                },
                                {
                                    CLASS = "action.QSBAttackFinish",
                                },
                            },
                        },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = {
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --             OPTIONS = {delay_time = 0.4},
                        --         },
                        --         {
                        --             CLASS = "action.QSBPlayEffect",
                        --             OPTIONS = {effect_id = "hl_bianyijinshu_attack01_1", is_hit_effect = false, haste = true},
                        --         },
                        --     },
                        -- },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.41},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {start_pos = {x = 111,y = 100}, effect_id = "hl_bianyijinshu_attack01_2", speed = 1200, hit_effect_id = "hl_bianyijinshu_attack01_3"},
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "composite.QSBParallel",
                    OPTIONS = {flag = 2},
                    ARGS = {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                    OPTIONS = {animation = "attack02"},
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
                                    OPTIONS = {delay_frame = 13},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "hl_bianyijinshu_attack02_1", is_hit_effect = false, haste = true},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.54},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {start_pos = {x = 111,y = 100}, effect_id = "hl_bianyijinshu_attack01_2", speed = 1200, hit_effect_id = "hl_bianyijinshu_attack01_3"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.82},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {start_pos = {x = 111,y = 100}, target_teammate_lowest_hp_percent = true, ignore_hit = true,
                                    effect_id = "hl_bianyijinshu_attack01_2", speed = 1200, hit_effect_id = "hl_bianyijinshu_attack01_3"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 16},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = "hl_bianyijinshu_pugong_buff5", lowest_hp_teammate = true},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 16},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = "hl_bianyijinshu_biaoji", is_target = false, no_cancel = true},
                                },
                            },
                        },
                    },
                },
            },
        },
    },
}

return hl_bianyijinshu_pugong5