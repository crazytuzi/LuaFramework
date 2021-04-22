-- 技能 千仞雪神圣之剑
-- 技能ID 204
-- 前方矩形AOE,给命中者上标记, 之后根据标记数回血
--[[
	hero 千仞雪
	ID:1027 
	psf 2018-8-11
]]--

local pf_qianrenxue02_zidong2 = 
{
    CLASS = "composite.QSBParallel",
    ARGS =
    {
        { 
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlaySound",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 7/3},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 0},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_qianrenxue_attack14_1", is_hit_effect = false},
                },               
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS =
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 40},
                },               
                {
                    CLASS = "action.QSBHitTarget",
                },                     
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_time = 1.5},
                -- },
                {
                    CLASS = "action.QSBAttackByBuffNum",
                    OPTIONS = {buff_id = "qianrenxue_zidong2_buff",min_num = 0,max_num = 5,num_pre_stack_count = 1,trigger_skill_id = 287,target_type = "enemy"},
                },
                -- {
                --     CLASS = "action.QSBAttackFinish",
                -- },          
            },  
        },
    },    
}

return pf_qianrenxue02_zidong2