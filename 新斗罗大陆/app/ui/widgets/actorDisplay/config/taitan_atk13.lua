
local jinzhan_tongyong = {
    CLASS = "composite.QUIDBParallel",
    ARGS = {
      
       {
           CLASS = "action.QUIDBPlayAnimation",
           OPTIONS = {animation = "attack13"},
       },
       {
           CLASS = "composite.QUIDBSequence",
           ARGS = {
               {
                   CLASS = "action.QUIDBDelayTime",
                   OPTIONS = {delay_frame = 0},
               },
               {
                   CLASS = "composite.QUIDBSequence",
                   ARGS = {  
                       {
                        CLASS = "action.QUIDBPlayEffect",
                        OPTIONS = {effect_id = "taitan_attack13_1_ui"},
                       },
                    --    {
                    --     CLASS = "action.QUIDBDelayTime",
                    --     OPTIONS = {delay_frame = 4},
                    --    },  
                    --    {
                    --        CLASS = "action.QUIDBHitTarget",
                    --    },
                    --    {
                    --     CLASS = "action.QUIDBDelayTime",
                    --     OPTIONS = {delay_frame = 4},
                    --    },  
                    --    {
                    --        CLASS = "action.QUIDBHitTarget",
                    --    },
                    --    {
                    --     CLASS = "action.QUIDBDelayTime",
                    --     OPTIONS = {delay_frame = 4},
                    --    },  
                    --    {
                    --        CLASS = "action.QUIDBHitTarget",
                    --    },
                    --    {
                    --     CLASS = "action.QUIDBDelayTime",
                    --     OPTIONS = {delay_frame = 4},
                    --    },  
                    --    {
                    --        CLASS = "action.QUIDBHitTarget",
                    --    },
                    --    {
                    --     CLASS = "action.QUIDBDelayTime",
                    --     OPTIONS = {delay_frame = 4},
                    --    },  
                    --    {
                    --        CLASS = "action.QUIDBHitTarget",
                    --    },
                    --    {
                    --     CLASS = "action.QUIDBDelayTime",
                    --     OPTIONS = {delay_frame = 4},
                    --    },  
                    --    {
                    --        CLASS = "action.QUIDBHitTarget",
                    --    },
                    --    {
                    --     CLASS = "action.QUIDBDelayTime",
                    --     OPTIONS = {delay_frame = 4},
                    --    },  
                    --    {
                    --        CLASS = "action.QUIDBHitTarget",
                    --    },
                    --    {
                    --     CLASS = "action.QUIDBDelayTime",
                    --     OPTIONS = {delay_frame = 4},
                    --    },  
                    --    {
                    --        CLASS = "action.QUIDBHitTarget",
                    --    },
                      
                   },
               },
           },
       },
   },
}

return jinzhan_tongyong