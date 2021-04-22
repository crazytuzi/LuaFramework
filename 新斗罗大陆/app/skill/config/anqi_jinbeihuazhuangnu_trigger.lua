-- 技能 暗器 紧背花装弩触发技
-- 技能ID 40046
-- 射一箭
--[[
	暗器 紧背花装弩
	ID:1505
	psf 2018-8-16
]]--

local anqi_jinbeihuazhuangnu_trigger = {
    CLASS = "composite.QSBSequence",
    ARGS = {
		{
            CLASS = "action.QSBPlayMountSkillAnimation",
        },
		{
			CLASS = "action.QSBBullet",
			OPTIONS = {flip_follow_y = true,check_target_by_skill = true},
		},
		{
			CLASS = "composite.QSBParallel",
			ARGS = 
			{
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "anqi_jinbeihuazhuangnu_buff_1"},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "anqi_jinbeihuazhuangnu_buff_2"},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "anqi_jinbeihuazhuangnu_buff_3"},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "anqi_jinbeihuazhuangnu_buff_4"},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "anqi_jinbeihuazhuangnu_buff_5"},
				},
			},
		},
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return anqi_jinbeihuazhuangnu_trigger