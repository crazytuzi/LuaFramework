-- 技能 胭脂软筋蟒普攻
-- 技能ID 30002
-- 远程：单体子弹，概率中毒
--[[
	hunling 胭脂软筋蟒
	ID:2002
	psf 2019-6-10
]]--

local hl_yanzrjm_pugong = {
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
                    OPTIONS = {delay_frame = 25},
                },
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {--[[effect_id = "ruanjinmang_attack01_1", ]]is_hit_effect = false, haste = true},
				},
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 26},
                },
                {
					CLASS = "action.QSBBullet",
					OPTIONS = {start_pos = {x = 125,y = 85},},
				},
            },
        },
    },
}

return hl_yanzrjm_pugong