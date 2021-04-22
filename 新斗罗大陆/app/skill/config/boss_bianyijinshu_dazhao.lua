-- 技能 变异金属大招
-- 技能ID 35076~80
-- 磁力链接：召唤金属之盾为全体友方提供【磁力链接】。受到的伤害降低x%，受到伤害的x%将分摊给其他队友。
--[[
    hunling 变异金属
    ID:2009 
    psf 2019-7-28
]]--

local boss_bianyijinshu_dazhao = {
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
        -- {
        --     CLASS = "action.QSBActorStatus",
        --     OPTIONS = 
        --     {
        --        { "bianyijinshu_kuosan", "trigger_skill:52138","under_status"},
        --     }
        -- },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 55},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "boss_bianyijinshu_dazhao_buff", teammate_and_self = true},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 55},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 111,y = 100}, ignore_hit = true, effect_id = "hl_bianyijinshu_attack11_2", speed = 1800},
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
                    OPTIONS = {effect_id = "hl_bianyijinshu_attack11_1", is_hit_effect = false, haste = true},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 55},
                },
                {
                    CLASS = "action.QSBTriggerSkill",
                    OPTIONS = {skill_id = 52137, target_type="skill_target"},
                },
            },
        },
    },
}

return boss_bianyijinshu_dazhao