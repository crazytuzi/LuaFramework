local zhuzhuqing_zhenji_shanghai = {
CLASS = "composite.QSBSequence",
ARGS = 
{
    {
        CLASS = "action.QSBArgsIsDirectionLeft",
        OPTIONS = {is_attacker = true},
    },
    {
        CLASS = "composite.QSBSelector",
        ARGS = 
        {
            {
                CLASS = "composite.QSBSequence",
                ARGS = 
                {
                    {
                        CLASS = "action.QSBArgsRandom",
                        OPTIONS = {
                            info = {count = 1},
                            input = {
                                datas = {1,2,3},
                                formats = {2,2,2},
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
                                CLASS = "action.QSBSummonGhosts",
                                OPTIONS = {
                                    flag = 1, actor_id = 1040, life_span = 10,number = 1, no_fog = true,relative_pos = {x = -125, y = 0}, 
                                    appear_skill = 359,--[[入场技能]]direction = "right",
                                    percents = {attack = 1, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                    extends_level_skills = {359}, same_target = true, clean_new_wave = true
                                },
                            },
                            {
                                CLASS = "action.QSBSummonGhosts",
                                OPTIONS = {
                                    flag = 2, actor_id = 1040, life_span = 10,number = 1, no_fog = true,relative_pos = {x = -125, y = 0}, 
                                    appear_skill = 360,--[[入场技能]]direction = "right",
                                    percents = {attack = 1, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                    extends_level_skills = {360}, same_target = true, clean_new_wave = true
                                },
                            },
                            {
                                CLASS = "action.QSBSummonGhosts",
                                OPTIONS = {
                                    flag = 3, actor_id = 1040, life_span = 10,number = 1, no_fog = true,relative_pos = {x = -125, y = 0}, 
                                    appear_skill = 361,--[[入场技能]]direction = "right",
                                    percents = {attack = 1, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                    extends_level_skills = {361}, same_target = true, clean_new_wave = true
                                },
                            },
                            {
                                CLASS = "action.QSBSummonGhosts",
                                OPTIONS = {
                                    flag = 4, actor_id = 1040, life_span = 10,number = 1, no_fog = true,relative_pos = {x = -125, y = 0}, 
                                    appear_skill = 362,--[[入场技能]]direction = "right",
                                    percents = {attack = 1, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                    extends_level_skills = {362}, same_target = true, clean_new_wave = true
                                },
                            },
                            {
                                CLASS = "action.QSBSummonGhosts",
                                OPTIONS = {
                                    flag = 5, actor_id = 1040, life_span = 10,number = 1, no_fog = true,relative_pos = {x = -125, y = 0}, 
                                    appear_skill = 363,--[[入场技能]]direction = "right",
                                    percents = {attack = 1, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                    extends_level_skills = {363}, same_target = true, clean_new_wave = true
                                },
                            },
                        },
                    },
                    {
                        CLASS = "action.QSBAttackFinish",
                    },
                },
            },
            {
                CLASS = "composite.QSBSequence",
                ARGS = 
                {
                    {
                        CLASS = "action.QSBArgsRandom",
                        OPTIONS = {
                            info = {count = 1},
                            input = {
                                datas = {1,2,3},
                                formats = {2,2,2},
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
                                CLASS = "action.QSBSummonGhosts",
                                OPTIONS = {
                                    flag = 1, actor_id = 1040, life_span = 10,number = 1, no_fog = true,relative_pos = {x = 125, y = 0}, 
                                    appear_skill = 359,--[[入场技能]]direction = "left",
                                    percents = {attack = 1, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                    extends_level_skills = {359}, same_target = true, clean_new_wave = true
                                },
                            },
                            {
                                CLASS = "action.QSBSummonGhosts",
                                OPTIONS = {
                                    flag = 2, actor_id = 1040, life_span = 10,number = 1, no_fog = true,relative_pos = {x = 125, y = 0}, 
                                    appear_skill = 360,--[[入场技能]]direction = "left",
                                    percents = {attack = 1, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                    extends_level_skills = {360}, same_target = true, clean_new_wave = true
                                },
                            },
                            {
                                CLASS = "action.QSBSummonGhosts",
                                OPTIONS = {
                                    flag = 3, actor_id = 1040, life_span = 10,number = 1, no_fog = true,relative_pos = {x = 125, y = 0}, 
                                    appear_skill = 361,--[[入场技能]]direction = "left",
                                    percents = {attack = 1, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                    extends_level_skills = {361}, same_target = true, clean_new_wave = true
                                },
                            },
                            {
                                CLASS = "action.QSBSummonGhosts",
                                OPTIONS = {
                                    flag = 4, actor_id = 1040, life_span = 10,number = 1, no_fog = true,relative_pos = {x = 125, y = 0}, 
                                    appear_skill = 362,--[[入场技能]]direction = "left",
                                    percents = {attack = 1, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                    extends_level_skills = {362}, same_target = true, clean_new_wave = true
                                },
                            },
                            {
                                CLASS = "action.QSBSummonGhosts",
                                OPTIONS = {
                                    flag = 5, actor_id = 1040, life_span = 10,number = 1, no_fog = true,relative_pos = {x = 125, y = 0}, 
                                    appear_skill = 363,--[[入场技能]]direction = "left",
                                    percents = {attack = 1, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                    extends_level_skills = {363}, same_target = true, clean_new_wave = true
                                },
                            },
                        },
                    },
                    {
                        CLASS = "action.QSBAttackFinish",
                    },
                },
            },
        },
    },
},
}

return zhuzhuqing_zhenji_shanghai