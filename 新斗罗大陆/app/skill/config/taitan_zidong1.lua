
local jinzhan_tongyong = {
    CLASS = "composite.QSBParallel",
    ARGS = {
       {
           CLASS = "action.QSBPlaySound"
       },
       {
           CLASS = "action.QSBPlayAnimation",
       },
       {
           CLASS = "composite.QSBSequence",
           ARGS = {
               {
                   CLASS = "action.QSBDelayTime",
                   OPTIONS = {delay_frame = 0},
               },
               {
                   CLASS = "composite.QSBSequence",
                   ARGS = {  
                       {
                        CLASS = "action.QSBPlayEffect",
                        OPTIONS = {is_hit_effect = false},
                       },
                       {
                        CLASS = "action.QSBDelayTime",
                        OPTIONS = {delay_frame = 4},
                       },  
                       {
                           CLASS = "action.QSBHitTarget",
                       },
                       {
                        CLASS = "action.QSBDelayTime",
                        OPTIONS = {delay_frame = 4},
                       },  
                       {
                           CLASS = "action.QSBHitTarget",
                       },
                       {
                        CLASS = "action.QSBDelayTime",
                        OPTIONS = {delay_frame = 4},
                       },  
                       {
                           CLASS = "action.QSBHitTarget",
                       },
                       {
                        CLASS = "action.QSBDelayTime",
                        OPTIONS = {delay_frame = 4},
                       },  
                       {
                           CLASS = "action.QSBHitTarget",
                       },
                       {
                        CLASS = "action.QSBDelayTime",
                        OPTIONS = {delay_frame = 4},
                       },  
                       {
                           CLASS = "action.QSBHitTarget",
                       },
                       {
                        CLASS = "action.QSBDelayTime",
                        OPTIONS = {delay_frame = 4},
                       },  
                       {
                           CLASS = "action.QSBHitTarget",
                       },
                       {
                        CLASS = "action.QSBDelayTime",
                        OPTIONS = {delay_frame = 4},
                       },  
                       {
                           CLASS = "action.QSBHitTarget",
                       },
                       {
                        CLASS = "action.QSBDelayTime",
                        OPTIONS = {delay_frame = 4},
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
                   OPTIONS = {delay_frame = 85},
               },
               {
                   CLASS = "action.QSBAttackFinish"
               },
           },
       },
   },
}

return jinzhan_tongyong