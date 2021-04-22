-- 技能 暗器 一千零一夜 对怒气最高目标扎针
-- 技能ID 40297
-- 对怒气最高目标上BUFF anqi_yiqianlingyiye_time_trigger_debuff_2
--[[
	暗器 一千零一夜
	ID:1520
	psf 2019-2-16
]]--

local anqi_yiqianlingyiye_time_trigger_2 = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {highest_rage_enemy = true, buff_id = "anqi_yiqianlingyiye_time_trigger_debuff_2"},
		},
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return anqi_yiqianlingyiye_time_trigger_2