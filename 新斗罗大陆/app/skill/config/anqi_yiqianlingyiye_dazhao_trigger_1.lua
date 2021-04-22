-- 技能 暗器 一千零一夜 大招触发扎针
-- 技能ID 40301~40305
-- 触发三次扎针技能40306
--[[
	暗器 一千零一夜
	ID:1520
	psf 2019-2-16
]]--

local anqi_yiqianlingyiye_dazhao_trigger_1 = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
			CLASS = "action.QSBHitTarget",
		},
		{
			CLASS = "action.QSBHitTarget",
		},
		{
			CLASS = "action.QSBHitTarget",
		},
		-- {
			-- CLASS = "action.QSBDelayTime",
			-- OPTIONS = {delay_frame = 1},
		-- },
		-- {
			-- CLASS = "action.QSBTriggerSkill",
			-- OPTIONS = {skill_id = 40307,target_type="skill_target",wait_finish = true}
		-- },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return anqi_yiqianlingyiye_dazhao_trigger_1