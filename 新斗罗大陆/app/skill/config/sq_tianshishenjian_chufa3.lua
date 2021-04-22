-- 技能 神器 海神套装庇护触发5
-- 技能ID 2020162

local anqi_hongchenbiyou_baohu1 = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBArgsFindTargets",
                    OPTIONS = {my_enemies = true, just_hero = true},
                },
                {
                    CLASS = "action.QSBChangeRageCofficient", 
                    OPTIONS = {change_cofficient_name = "beattack_coefficient",change_cofficient_value = 0.82},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = {
                        failed_select = 1,
                        {expression = "target:has_buff:pve_zuojia_shanghaibeishu", select = 2},
                    }
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBTianShiShengJian",
                            OPTIONS = 
                            {
                                first_trigger_time = 5, --第一次施放时间
                                duration = 360, --持续时间
                                interval = 20, --第一次之后间隔释放时间
                                effect1_first_time = 3.5,
                                effect2_first_time = 3.5,
                                effect3_first_time = 4.7,
                                left_effect1_id = "sq_tianshishengjian_attack01_1",
                                left_effect2_id = "sq_tianshishengjian_attack01_2",
                                left_effect3_id = "sq_tianshishengjian_attack01_5",
                                right_effect1_id = "sq_tianshishengjian_attack01_3",
                                right_effect2_id = "sq_tianshishengjian_attack01_4",
                                right_effect3_id = "sq_tianshishengjian_attack01_6",
                                left_effect1_pos = {x=200,y=340},
                                left_effect2_pos = {x=200,y=340},
                                left_effect3_pos = {x=640,y=340},
                                right_effect1_pos = {x=900,y=340},
                                right_effect2_pos = {x=900,y=340},
                                right_effect3_pos = {x=640,y=340},
                                damage_percent = "5;10", --攻击力最高的魂师施放伤害等同于当前攻击力的百分比（PVP/PVE）
                                convert_treat_percent = 0, --根据造成伤害恢复的生命值百分比
                                change_rage_value = -180, --降低的敌方全体怒气
                                rage_increase_coefficient_final_value = -0--降低怒气最高的魂师的怒气获取
                            },
                        },
                        {
                            CLASS = "action.QSBTianShiShengJian",
                            OPTIONS = 
                            {
                                first_trigger_time = 5, --第一次施放时间
                                duration = 360, --持续时间
                                interval = 16, --第一次之后间隔释放时间
                                effect1_first_time = 3.5,
                                effect2_first_time = 3.5,
                                effect3_first_time = 4.7,
                                left_effect1_id = "sq_tianshishengjian_attack01_1",
                                left_effect2_id = "sq_tianshishengjian_attack01_2",
                                left_effect3_id = "sq_tianshishengjian_attack01_5",
                                right_effect1_id = "sq_tianshishengjian_attack01_3",
                                right_effect2_id = "sq_tianshishengjian_attack01_4",
                                right_effect3_id = "sq_tianshishengjian_attack01_6",
                                left_effect1_pos = {x=200,y=340},
                                left_effect2_pos = {x=200,y=340},
                                left_effect3_pos = {x=640,y=340},
                                right_effect1_pos = {x=900,y=340},
                                right_effect2_pos = {x=900,y=340},
                                right_effect3_pos = {x=640,y=340},
                                damage_percent = "5;30", --攻击力最高的魂师施放伤害等同于当前攻击力的百分比（PVP/PVE）
                                convert_treat_percent = 0, --根据造成伤害恢复的生命值百分比
                                change_rage_value = -180, --降低的敌方全体怒气
                                rage_increase_coefficient_final_value = -0--降低怒气最高的魂师的怒气获取
                            },
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = { buff_id = "sq_tianshishenjian_chufa3_buff"},
        },
    },
}

return anqi_hongchenbiyou_baohu1