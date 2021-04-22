-- 技能 暗器 诸葛神弩触发技
-- 技能ID 40216~40220
-- 附加连射BUFF
--[[
	暗器 诸葛神弩
	ID:1516
	psf 2018-10-30
]]--

local anqi_zhugeshennu_trigger = {
    CLASS = "composite.QSBSequence",
    ARGS = {
		{
            CLASS = "action.QSBPlayMountSkillAnimation",
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false},
                },
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = true},
				},
				{
					CLASS = "action.QSBHitTarget",
				},
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return anqi_zhugeshennu_trigger