
local bosaixi_zhenji_zidong1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = 
             {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    { 
                        {
                            CLASS = "action.QSBPlayAnimation",
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 34},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {start_pos = {x = 80,y = 80}, enemy_lowest_hp_percent = true},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 38},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {start_pos = {x = 80,y = 80}, enemy_lowest_hp_percent = true},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 42},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {start_pos = {x = 80,y = 80}, enemy_lowest_hp_percent = true},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 46},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {start_pos = {x = 80,y = 80}, enemy_lowest_hp_percent = true},
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return bosaixi_zhenji_zidong1

