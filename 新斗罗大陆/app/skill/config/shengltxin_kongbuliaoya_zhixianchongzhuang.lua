-- 技能 蓄力直线冲锋
-- 技能ID 53335
--[[
	恐怖獠牙 4129
	升灵台 "巨兽沼泽"
	psf 2020-6-22
]]--

local shenglt_kongbuliaoya_zhixianchongzhuang = {
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
        {
			CLASS = "composite.QSBSequence",
			OPTIONS = {revertable = true},
			ARGS = 
			{
				{
					CLASS = "action.QSBArgsIsLeft",
					OPTIONS = {is_attacker = true},
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = {
						{
							CLASS = "action.QSBRoledirection",
							OPTIONS = {direction = "right"},
						},
						{
							CLASS = "action.QSBRoledirection",
							OPTIONS = {direction = "left"},
						},
					},
				},
			},
		},		
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 44/24 },
                }, 
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack11" },
                },
            },
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "shenglt_kongbuliaoya_chongzhuang_hongkuang", is_target = false},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 62/24 },
                }, 
                {
					CLASS = "action.QSBHeroicalLeap",
                    OPTIONS = {distance = 950, move_time = 10/24, interval_time = 1/3, is_hit_target = true, bound_height = 40},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 77 / 24 },
                }, 
                {
					CLASS = "action.QSBAttackFinish",
				},
            },
        },
	},
}

return shenglt_kongbuliaoya_zhixianchongzhuang