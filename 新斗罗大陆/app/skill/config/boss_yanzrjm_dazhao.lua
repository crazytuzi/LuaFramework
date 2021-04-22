-- 技能 胭脂软筋蟒大招
-- 技能ID 35006
-- 单体魅惑
--[[
    hunling 胭脂软筋蟒
    ID:2002
    psf 2019-6-10
]]--

local hl_yanzrjm_dazhao = {
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
                    OPTIONS = {delay_frame = 17},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "ruanjinmang_attack11_1", is_hit_effect = false, haste = true},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 42},
                },
                {
                    CLASS = "action.QSBBullet",
                },
            },
        },
    },
}

return hl_yanzrjm_dazhao