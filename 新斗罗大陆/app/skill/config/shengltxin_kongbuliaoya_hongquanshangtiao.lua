-- 技能 蓄力红圈上挑
-- 技能ID 53340
--[[
	恐怖獠牙 4129
	升灵台 "巨兽沼泽"
	psf 2020-6-28
]]--

local shenglt_kongbuliaoya_shangtiao_hongquan = {
	CLASS = "composite.QSBParallel",
	ARGS = 
	{		
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
                    ARGS = {                        
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true},
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "shenglt_kongbuliaoya_shangtiao_hongquan", is_target = false},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 65/24 },
                }, 
                {
                    CLASS = "action.QSBHitTarget",
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

return shenglt_kongbuliaoya_shangtiao_hongquan