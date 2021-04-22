-- 技能 月关召唤玄冰草全屏冰冻
-- 技能ID 50422
-- 全屏冰冻
--[[
	boss 月关的玄冰草
	ID:3338 副本7--4
	psf 2018-4-6
]]--

local npc_bajiaoxuanmingcao_quanchangbingdong = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
					ARGS = {
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
					},
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
					OPTIONS = {delay_time = 0.85},
				},
				{
					CLASS = "action.QSBApplyBuffMultiple",
					OPTIONS = {target_type = "enemy", buff_id = "boss_yueguan_bajiaoxuanbingcao_freeze_debuff",},
				},
            },
        },
    },
}

return npc_bajiaoxuanmingcao_quanchangbingdong

