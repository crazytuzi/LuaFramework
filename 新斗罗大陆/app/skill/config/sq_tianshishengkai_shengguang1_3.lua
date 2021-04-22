-- 技能 神器 天使圣铠天使圣光
-- 技能ID 2020175

local tianshishengkai_shengguang = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        --降低初始怒气值
        {
            CLASS = "action.QSBPlayGodSkillAnimation",
            OPTIONS = {is_god_arm = true, is_ss = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "sq_tianshishengkai_pve_buff3",teammate_and_self = true},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 10},
                },
                {
                    CLASS = "action.QSBChangeRage", 
                    OPTIONS = {rage_value = -150,all_enemy = true},
                },
            },
        },
        --降低受击回怒系数
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 10},
                },
                {
                    CLASS = "action.QSBArgsFindTargets",
                    OPTIONS = {my_enemies = true, just_hero = true},
                },
                {
                    CLASS = "action.QSBChangeRageCofficient", 
                    OPTIONS = {change_cofficient_name = "beattack_coefficient",change_cofficient_value = 0.85},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true},
            ARGS = 
            {
                {
                    CLASS = "action.QSBArgsIsHero",
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
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "sq_tianshishengkai_attack01_3", pos  = {x = 380 , y = 340}, front_layer = true},     --特效1
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = "sq_tianshishengkai_debuff1", all_enemy = true},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = "sq_tianshishengkai_shengguang2_3_buff",teammate_and_self = true},
                                },
                            },                              
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "sq_tianshishengkai_attack01_2", pos  = {x = 900 , y = 340}, front_layer = true},     --特效1
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = "sq_tianshishengkai_debuff1", all_enemy = true},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = "sq_tianshishengkai_shengguang2_3_buff",teammate_and_self = true},
                                },
                            },
                        },
                    },
                },
            },
        },
    },
}

return tianshishengkai_shengguang