-- 技能 千仞雪神圣之剑
-- 技能ID 204
-- 前方矩形AOE,给命中者上标记, 之后根据标记数回血
--[[
	hero 千仞雪
	ID:1027 
	psf 2018-8-11
]]--

local qianrenxue_zidong2 = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBPlaySound",
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = {
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = {  
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = true},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
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
							OPTIONS = {delay_time = 1.5},
						},
						{
							CLASS = "action.QSBAttackByBuffNum",
							OPTIONS = {buff_id = "qianrenxue_zidong2_buff",min_num = 0,max_num = 5,num_pre_stack_count = 1,trigger_skill_id = 287,target_type = "enemy"},
						},
					},
				},
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return qianrenxue_zidong2