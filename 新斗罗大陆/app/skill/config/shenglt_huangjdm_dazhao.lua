-- 技能 黄金玳瑁大招
-- 技能ID 53296
-- 单体护盾
--[[
	hunling 黄金玳瑁
	ID:4110 
	升灵台
	psf 2020-4-13
]]--

local shenglt_huangjdm_dazhao = {
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
				{
					CLASS = "action.QSBLockTarget",
					OPTIONS = { is_lock_target = false}
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
					OPTIONS = {effect_id = "shenglt_huangjindaimao_attack11_1", is_hit_effect = false, haste = true},
				},
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 14},
                },
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "shenglt_huangjdm_dazhao_buff"},
				},
            },
        },
    },
}

return shenglt_huangjdm_dazhao