-- 技能 暗器 袖箭触发技
-- 技能ID 180107
-- 射一箭
--[[
	暗器 袖箭
	ID:1501 
	psf 2018-8-15
]]--

local anqi_xiujian_trigger = {
    CLASS = "composite.QSBSequence",
    ARGS = {
		{
            CLASS = "action.QSBPlayMountSkillAnimation",
        },
		{
			CLASS = "action.QSBBullet",
			OPTIONS = {flip_follow_y = true},
		},
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return anqi_xiujian_trigger