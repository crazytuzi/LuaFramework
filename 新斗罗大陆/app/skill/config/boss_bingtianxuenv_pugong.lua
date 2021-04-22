-- 技能 冰天雪女普攻
-- 技能ID 30007
-- 冰极无双：随机多子弹技能，有概率给目标上一层【冰锁】状态，降低目标回怒速度，持续X秒（冰锁最多可叠加3层）
--[[
    hunling 冰天雪女
    ID:2007 
    psf 2019-6-10
]]--

local hl_bingtianxuenv_pugong = {
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
                    OPTIONS = {delay_frame = 13},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {--[[effect_id = "bingtianxuenv_attack01_1",]] is_hit_effect = false, haste = true},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 15},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 111,y = 100},},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 25},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 111,y = 100},},
                },
            },
        },
    },
}

return hl_bingtianxuenv_pugong