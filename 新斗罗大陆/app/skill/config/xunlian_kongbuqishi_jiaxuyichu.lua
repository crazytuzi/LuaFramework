-- 技能 恐怖骑士加回血BUFF
-- 技能ID 50395
-- 加回血BUFF
--[[
	boss 恐怖骑士斯科特
	ID:3311 副本68-4
	庞圣峰 2018-4-3
]]--

local boss_kongbuqishi_hot = {
    CLASS = "composite.QSBSequence",
    ARGS = {   
		{
		    CLASS = "composite.QSBParallel",
		    ARGS = {
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "boss_kongbuqishi_huixue_buff1"},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "boss_kongbuqishi_huixue_buff"},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "xunlian_kongbuqishi_huixue_buff1"},
				},
		    	-- {
		     --        CLASS = "action.QSBPlayEffect",
		     --        OPTIONS = {effect_id = "boss_kongbuqishi_huixue_buff_3", is_hit_effect = false},
		     --    },
		    },
		},
			{
				CLASS = "action.QSBAttackFinish",
			},
	},
}
return boss_kongbuqishi_hot