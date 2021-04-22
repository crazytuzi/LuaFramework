-- 技能 神器 天使圣铠天使圣光
-- 技能ID 2020173

local tianshishengkai_shengguang = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        --护盾，根据hp_percent计算护盾值，absorb_on_every_target = true一定要加上，不然护盾值会除以上阵英雄数量，
        --buff_data配置里:absorb_render_heal_percent/护盾吸血系数,absorb_render_damage_percent/护盾反伤系数
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_frame = 7},
                -- },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "sq_tianshishengkai_attack01_2" ,is_hit_effect = false,not_cancel_with_skill = true},          --捶地水花
                },
            },
        },
        {

            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBArgsFindTargets", 
                    OPTIONS = {teammate_and_self = true, just_hero = true, args_translate = {selectTargets = "targets"}},
                },
                {
                    CLASS = "action.QSBAddAbsorb",
                    OPTIONS = {absorb_buff_id = "sq_tianshishengkai_buff1",hp_percent = 0.3, just_hero = true, absorb_on_every_target = true},
                },
            },
        },
    },
}

return tianshishengkai_shengguang