-- 技能 月关召唤菊花怪临终加血
-- 技能ID 50421
-- 死前加攻
--[[
	boss 月关的紫色菊花怪
	ID:3337 副本7--4
	psf 2018-4-6
]]--

local boss_yueguan_juhuaguai_jiagong = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
            CLASS = "action.QSBLockTarget",
            OPTIONS = {is_lock_target = true, revertable = true},
        },
        {
            CLASS = "action.QSBPlaySound"
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
					OPTIONS = {animation = "dead"}
                },

            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 35},
				},
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {is_target = true, buff_id = "boss_yueguan_juhuaguai_jiagong_buff", no_cancel = true},--加攻BUFF
				},
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 15},
				},
				{
					CLASS = "action.QSBSuicide",
				},
				{
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
    },
}

return boss_yueguan_juhuaguai_jiagong

