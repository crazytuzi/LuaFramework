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
    CLASS = "composite.QUIDBParallel",
    ARGS =
    {
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 3},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "attack14"},
                },            
            },
        },
      
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = 
            {
              
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "qianrenxue_attack14_1_ui"},
                },               
            },
        },
    },    
}

return pf_qianrenxue02_zidong2