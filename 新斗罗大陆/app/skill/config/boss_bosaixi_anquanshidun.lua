local boss_bosaixi_anquanshidun = {
CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                   CLASS = "action.QSBApplyBuff",
                   OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
                },
                {
                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "bosaixi_anquanshidun1"} ,
                },
                {
                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "bosaixi_anquanshidun2"} ,
                },
                {
                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "bosaixi_anquanshidun3"} ,
                },
                {
                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "bosaixi_anquanshidun4"} ,
                },
                {
                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "bosaixi_anquanshidun5"} ,
                },
                {
                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "bosaixi_anquanshidun6"} ,
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },                
            },
        },
    },
}

return boss_bosaixi_anquanshidun