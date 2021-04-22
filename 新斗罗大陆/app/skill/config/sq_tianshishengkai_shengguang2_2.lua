-- 技能 神器 天使圣铠天使圣光
-- 技能ID 2020174

local tianshishengkai_shengguang = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        --护盾，根据hp_percent计算护盾值，absorb_on_every_target = true一定要加上，不然护盾值会除以上阵英雄数量，
        --buff_data配置里:absorb_render_heal_percent/护盾吸血系数,absorb_render_damage_percent/护盾反伤系数
        {
            CLASS = "action.QSBPlayGodSkillAnimation",
            OPTIONS = {is_god_arm = true, is_ss = true},
        },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = 
        --     {
        --         -- {
        --         --     CLASS = "action.QSBDelayTime",
        --         --     OPTIONS = {delay_frame = 7},
        --         -- },
        --         {
        --             CLASS = "action.QSBPlayEffect",
        --             OPTIONS = {effect_id = "sq_tianshishengkai_attack01_1" ,is_hit_effect = false},          --捶地水花
        --         },
        --     },
        -- },
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
                                    OPTIONS = {effect_id = "sq_tianshishengkai_attack01_5", pos  = {x = 380 , y = 340}, front_layer = true},     --特效1
                                },
                            },                              
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "sq_tianshishengkai_attack01_4", pos  = {x = 900 , y = 340}, front_layer = true},     --特效1
                                },
                            },
                        },
                    },
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBArgsFindTargets", 
                    OPTIONS = {teammate_and_self = true, just_hero = true},
                },
                {
                    CLASS = "action.QSBAddAbsorb",
                    OPTIONS = {absorb_buff_id = "sq_tianshishengkai_buff2",hp_percent = 0.16, just_hero = true, absorb_on_every_target = true,pass_key = {"selectTargets"}},
                },
                {
                    CLASS = "action.QSBChangeHealAndRevertDamageByHP",
                    OPTIONS = {absorb_buff_id = "sq_tianshishengkai_buff2", heal_revert_min_cofficient = 1.0, heal_revert_max_cofficient = 1.0,render_damage_limit = 0.16,absorb_render_damage_percent=0,absorb_render_heal_percent=0.5},
                },
            },
        },
    },
}

return tianshishengkai_shengguang