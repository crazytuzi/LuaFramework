-- 技能 暗器 火龙镖触发技
-- 技能ID 40096
-- 打一下
--[[
	暗器 火龙镖
	ID:1507
	psf 2018-8-20
]]--

local anqi_huolongbiao_trigger = {
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

return anqi_huolongbiao_trigger