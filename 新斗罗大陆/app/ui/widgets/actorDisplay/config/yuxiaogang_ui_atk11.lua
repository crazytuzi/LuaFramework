local shifa_tongyong = 
-- {
--      CLASS = "composite.QUIDBSequence",
--      ARGS = 
--      {        
--         {
--             CLASS = "composite.QUIDBParallel",
--             ARGS = 
--             {
--                 {
--                     CLASS = "composite.QUIDBSequence",
--                     ARGS = 
--                          {
--                             {
--                                 CLASS = "action.QUIDBDelayTime",
--                                 OPTIONS = {delay_frame = 1},
--                             },
--                            	{
-- 					            CLASS = "action.QUIDBPlayAnimation",
-- 					            OPTIONS = {animation = "attack11"},
-- 					        },
--                         },
--                 },
--                 {
--                     CLASS = "composite.QUIDBSequence",
--                     ARGS = 
--                          {
--                             {
--                                 CLASS = "action.QUIDBDelayTime",
--                                 OPTIONS = {delay_frame = 18},
--                             },
--                             {
--                                 CLASS = "action.QUIDBPlayEffect",
--                                 OPTIONS = {is_hit_effect = false, effect_id = "yuxiaogang_shengli_ui"},
--                                 }, 
--                         },
--                 },
                
                
--             },
--         },
        
--     },
-- }
{
     CLASS = "composite.QUIDBParallel",
     ARGS = 
     {
        {
            CLASS = "action.QUIDBPlaySound"
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 1},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "attack11"},
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 18},
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "yuxiaogang_dazhao_atk11_1_ui", is_hit_effect = false},
                },
            },
        },
        
    },
}
return shifa_tongyong