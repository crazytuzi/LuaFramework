-- 技能 黄金玳瑁普攻
-- 技能ID 53295
-- 单体远程魔法攻击
--[[
	hunling 黄金玳瑁
	ID:4110 
	升灵台
	psf 2020-4-13
]]--

local shenglt_huangjdm_pugong = {
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
                    OPTIONS = {delay_frame = 20},
                },
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {--[[effect_id = "huangjindaimao_attack01_1", ]]is_hit_effect = false, haste = true},
				},
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 21},
                },
                {
					CLASS = "action.QSBBullet",
					OPTIONS = {start_pos = {x = 120,y = 45},},
				},
            },
        },
    },
}

return shenglt_huangjdm_pugong