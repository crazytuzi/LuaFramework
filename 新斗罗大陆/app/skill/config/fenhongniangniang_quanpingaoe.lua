--  创建人：刘悦璘
--  创建时间：2017.09.05
--  NPC：谋士兵
--  类型：攻击
local fenhongniangniang_quanpingaoe = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBTeleportToAbsolutePosition",
            OPTIONS = {pos={x = 1100,y = 300}},
        },
        {
            CLASS = "action.QSBRoledirection",
            OPTIONS = {direction = "left"},
        },    
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = 
                    {
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false},
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
                   ARGS = 
                   {
                        {
                          CLASS = "action.QSBDelayTime",
                          OPTIONS = {delay_time = 0.3},
                        }, 
                        {
                          CLASS = "action.QSBPlaySceneEffect",
                          OPTIONS = {effect_id = "fenhongniangniang_attack16_3", pos  = {x = 270 , y = 230}, ground_layer = true},
                        },
                   },
               },
               {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.6},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.5},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.5},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                        -- {
                        --     CLASS = "action.QSBDelayTime",
                        --     OPTIONS = {delay_time = 0.5},
                        -- },
                        -- {
                        --     CLASS = "action.QSBHitTarget",
                        -- },
                        -- {
                        --     CLASS = "action.QSBDelayTime",
                        --     OPTIONS = {delay_time = 0.5},
                        -- },
                        -- {
                        --     CLASS = "action.QSBHitTarget",
                        -- },
                    },               
                },
            },
        },  
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}
return fenhongniangniang_quanpingaoe