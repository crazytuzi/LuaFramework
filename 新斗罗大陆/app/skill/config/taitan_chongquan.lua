
local taitan_chongquan = {
    CLASS = "composite.QSBSequence",
     ARGS = {
         {
             CLASS = "action.QSBLockTarget",
             OPTIONS = {is_lock_target = true, revertable = true},
         },
         {
             CLASS = "action.QSBApplyBuff",
             OPTIONS = {buff_id = "taitan_chongfeng_buff"},
         }, 
         {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attack12",is_loop = true},
         },
         {
             CLASS = "action.QSBManualMode",
             OPTIONS = {enter = true, revertable = true},
         },
         {
             CLASS = "action.QSBApplyBuff",
             OPTIONS = {is_target = true, buff_id = "chongfeng_tongyong_xuanyun"},
         },      
         {
             CLASS = "action.QSBMoveToTarget",
             OPTIONS = {is_position = true},
         },
         {
             CLASS = "action.QSBRemoveBuff",
             OPTIONS = {buff_id = "taitan_chongfeng_buff"},
         },
         {
             CLASS = "composite.QSBParallel",
             ARGS = {
                 {
                      CLASS = "composite.QSBSequence",
                      ARGS = {
                        
                         {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 15},
                         },
                         {
                             CLASS = "action.QSBAttackFinish"
                         },
                     },
                 },
                 {
                     CLASS = "composite.QSBParallel",
                     ARGS = {
                         {
                             CLASS = "action.QSBPlayEffect",
                             OPTIONS = {is_hit_effect = true},
                         },
                         -- {
                         --     CLASS = "action.QSBPlayEffect",
                         --     OPTIONS = {is_hit_effect = false, effect_id = "charge_2"},
                         -- },
                         {
                              CLASS = "action.QSBHitTarget",
                         },
                         -- {
                         --     CLASS = "action.QSBApplyBuff",
                         --     OPTIONS = {is_target = true, buff_id = "chongfeng_tongyong_xuanyun"},
                         -- },
                     },
                 },
                 -- {
                 --     CLASS = "composite.QSBParallel",
                 --     ARGS = {
                 --         {
                 --             CLASS = "action.QSBPlayEffect",
                 --             OPTIONS = {is_hit_effect = false, effect_id = "charge_2"},
                 --         },
                 --         {
                 --              CLASS = "action.QSBHitTarget",
                 --         }
                 --     },
                 -- },
             },
         },
         {
             CLASS = "action.QSBLockTarget",
             OPTIONS = {is_lock_target = false},
         },
         {
             CLASS = "action.QSBManualMode",
             OPTIONS = {exit = true},
         },
     },
 }

return taitan_chongquan