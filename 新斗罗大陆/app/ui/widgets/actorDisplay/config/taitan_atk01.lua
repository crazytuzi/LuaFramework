
local jinzhan_tongyong = {
    CLASS = "composite.QUIDBParallel",
    ARGS = {
       {
           CLASS = "action.QUIDBPlayEffect",
           OPTIONS = {effect_id = "taitan_attack01_1_ui"},
       },
       {
           CLASS = "action.QUIDBPlayAnimation",
           OPTIONS = {animation = "attack01"},
       },
    --    {
    --        CLASS = "composite.QUIDBSequence",
    --        ARGS = {
    --            {
    --                CLASS = "action.QUIDBDelayTime",
    --                OPTIONS = {delay_frame = 14},
    --            },
    --            {
    --                CLASS = "composite.QUIDBParallel",
    --                ARGS = {  
    --                    {
    --                        CLASS = "action.QUIDBPlayEffect",
    --                        OPTIONS = {is_hit_effect = true},
    --                    },
    --                    {
    --                        CLASS = "action.QUIDBHitTarget",
    --                    },
    --                },
    --            },
    --        },
    --    },
      
   },
}

return jinzhan_tongyong