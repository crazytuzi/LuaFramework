-- 技能 暗器 烈寒双针触发技
-- 技能ID 40071
-- 放陷阱
--[[
	暗器 烈寒双针
	ID:1509
	psf 2018-8-16
]]--

local anqi_liehanshuangzhen_trigger = {
    CLASS = "composite.QSBSequence",
    ARGS = {
		{
			CLASS = "action.QSBHitTarget",
		},
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return anqi_liehanshuangzhen_trigger