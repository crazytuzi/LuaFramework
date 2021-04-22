-- 技能 恐怖骑士加回血BUFF
-- 技能ID 50395
-- 加回血BUFF
--[[
	boss 恐怖骑士斯科特
	ID:3311 副本68-4
	庞圣峰 2018-4-3
]]--

local boss_kongbuqishi_hot = {
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
					OPTIONS = {delay_frame = 38},
				},
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "boss_kongbuqishi_huixue_buff",no_cancel = true},
				},
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 6},
				},
				{
					CLASS = "action.QSBHitTimer",
				},
            },
        },
    },
}

return boss_kongbuqishi_hot