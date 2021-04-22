
local jinzhan_tongyong = {
    CLASS = "composite.QSBParallel",
    ARGS = {
       {
           CLASS = "action.QSBPlaySound"
       },
       {
           CLASS = "action.QSBPlayEffect",
           OPTIONS = {is_hit_effect = false},
       },
       {
           CLASS = "action.QSBPlayAnimation",
       },
       {
           CLASS = "composite.QSBSequence",
           ARGS = {
               {
                   CLASS = "action.QSBDelayTime",
                   OPTIONS = {delay_frame = 30},
               },
               {
                   CLASS = "composite.QSBParallel",
                   ARGS = {  
                       {
                           CLASS = "action.QSBPlayEffect",
                           OPTIONS = {is_hit_effect = true},
                       },
                       {
                        CLASS = "action.QSBDelayTime",
                        OPTIONS = {delay_frame = 120},
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
                   OPTIONS = {delay_frame = 70},
               },
               {
                   CLASS = "action.QSBAttackFinish"
               },
           },
       },
       {
        CLASS = "composite.QSBSequence",
        ARGS = 
        {
            {
                CLASS = "action.QSBDelayTime",
                OPTIONS = {delay_time = 11 / 24 },
            },
            -- {
            --  CLASS = "action.QSBSelectTarget",
            --  OPTIONS = {range_max = true},
            -- },
            {
                CLASS = "action.QSBArgsIsDirectionLeft",
                OPTIONS = {is_attacker = true},
            },
            {
                CLASS = "composite.QSBSelector",
                ARGS = 
                {   
                    {
                        CLASS = "composite.QSBSequence",
                        ARGS = 
                        {
                            {
                                CLASS = "action.QSBArgsPosition",
                                OPTIONS = {is_attackee = true},
                            },
                            -- {
                            --     CLASS = "action.QSBDelayTime",
                            --     OPTIONS = {delay_frame = 82, pass_key = {"pos"}},
                            -- },
                            {
                                CLASS = "action.QSBCharge", --移动向目标位置（不打断动画）
                                OPTIONS = {move_time = 10 / 24,offset = {x= 150,y=0}},
                            },
                        }, 
                    },
                    {
                        CLASS = "composite.QSBSequence",
                        ARGS = 
                        {
                            {
                                CLASS = "action.QSBArgsPosition",
                                OPTIONS = {is_attackee = true},
                            },
                            -- {
                            --     CLASS = "action.QSBDelayTime",
                            --     OPTIONS = {delay_frame = 82, pass_key = {"pos"}},
                            -- },
                            {
                                CLASS = "action.QSBCharge", --移动向目标位置（不打断动画）
                                OPTIONS = {move_time = 10 / 24,offset = {x= -150,y=0}},
                            },
                        }, 
                    },
                },
            },
        },
    },
   },
}

return jinzhan_tongyong