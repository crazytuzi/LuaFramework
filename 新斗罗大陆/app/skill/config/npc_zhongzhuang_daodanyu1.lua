local zidan_tongyong = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBPlayAnimation",
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 21 / 24},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jiqiren_daodan_yujing",
                                args = 
                                {
                                    {delay_time = 1 / 24 , pos = { x = 1200, y = 520}} ,
                                    {delay_time = 3 / 24 , pos = { x = 1010, y = 520}} ,
                                    {delay_time = 5 / 24 , pos = { x = 820, y = 520}} ,
                                    {delay_time = 7 / 24 , pos = { x = 630, y = 520}} ,
                                    {delay_time = 9 / 24 , pos = { x = 440, y = 520}} ,
                                    {delay_time = 11 / 24 , pos = { x = 250, y = 520}} ,
                                    {delay_time = 13 / 24 , pos = { x = 100, y = 520}} ,
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jiqiren_daodan_yujing",
                                args = 
                                {
                                    {delay_time = 13 / 24 , pos = { x = 1200, y = 150}} ,
                                    {delay_time = 11 / 24 , pos = { x = 1010, y = 150}} ,
                                    {delay_time = 9 / 24 , pos = { x = 820, y = 150}} ,
                                    {delay_time = 7 / 24 , pos = { x = 630, y = 150}} ,
                                    {delay_time = 5 / 24 , pos = { x = 440, y = 150}} ,
                                    {delay_time = 3 / 24 , pos = { x = 250, y = 150}} ,
                                    {delay_time = 1 / 24 , pos = { x = 100, y = 150}} ,
                                },
                            },
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
                    OPTIONS = {delay_time = 42 / 24},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jiqiren_daodan_yujing",
                                args = 
                                {
                                    {delay_time = 1 / 24 , pos = { x = 1200, y = 450}} ,
                                    {delay_time = 3 / 24 , pos = { x = 1010, y = 450}} ,
                                    {delay_time = 5 / 24 , pos = { x = 820, y = 450}} ,
                                    {delay_time = 7 / 24 , pos = { x = 630, y = 450}} ,
                                    {delay_time = 9 / 24 , pos = { x = 440, y = 450}} ,
                                    {delay_time = 11 / 24 , pos = { x = 250, y = 450}} ,
                                    {delay_time = 13 / 24 , pos = { x = 100, y = 450}} ,
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jiqiren_daodan_yujing",
                                args = 
                                {
                                    {delay_time = 13 / 24 , pos = { x = 1200, y = 220}} ,
                                    {delay_time = 11 / 24 , pos = { x = 1010, y = 220}} ,
                                    {delay_time = 9 / 24 , pos = { x = 820, y = 220}} ,
                                    {delay_time = 7 / 24 , pos = { x = 630, y = 220}} ,
                                    {delay_time = 5 / 24 , pos = { x = 440, y = 220}} ,
                                    {delay_time = 3 / 24 , pos = { x = 250, y = 220}} ,
                                    {delay_time = 1 / 24 , pos = { x = 100, y = 220}} ,
                                },
                            },
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
                    OPTIONS = {delay_time = 204 / 24},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBShakeScreen",
                            OPTIONS = {amplitude = 12, duration = 0.35, count = 2},
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
                    OPTIONS = {delay_time = 216 / 24},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBShakeScreen",
                            OPTIONS = {amplitude = 12, duration = 0.35, count = 2},
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
                    OPTIONS = {delay_time = 192 / 24},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jiqiren_daodan2",
                                args = 
                                {
                                    {delay_time = 1 / 24 , pos = { x = 1200, y = 520}} ,
                                    {delay_time = 4 / 24 , pos = { x = 1010, y = 520}} ,
                                    {delay_time = 7 / 24 , pos = { x = 820, y = 520}} ,
                                    {delay_time = 10 / 24 , pos = { x = 630, y = 520}} ,
                                    {delay_time = 13 / 24 , pos = { x = 440, y = 520}} ,
                                    {delay_time = 16 / 24 , pos = { x = 250, y = 520}} ,
                                    {delay_time = 19 / 24 , pos = { x = 100, y = 520}} ,
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jiqiren_daodan1",
                                args = 
                                {
                                    {delay_time = 19 / 24 , pos = { x = 1200, y = 150}} ,
                                    {delay_time = 16 / 24 , pos = { x = 1010, y = 150}} ,
                                    {delay_time = 13 / 24 , pos = { x = 820, y = 150}} ,
                                    {delay_time = 10 / 24 , pos = { x = 630, y = 150}} ,
                                    {delay_time = 7 / 24 , pos = { x = 440, y = 150}} ,
                                    {delay_time = 4 / 24 , pos = { x = 250, y = 150}} ,
                                    {delay_time = 1 / 24 , pos = { x = 100, y = 150}} ,
                                },
                            },
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
                    OPTIONS = {delay_time = 204 / 24},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jiqiren_daodan3",
                                args = 
                                {
                                    {delay_time = 1 / 24 , pos = { x = 1200, y = 520}} ,
                                    {delay_time = 3 / 24 , pos = { x = 1100, y = 520}} ,
                                    {delay_time = 5 / 24 , pos = { x = 1000, y = 520}} ,
                                    {delay_time = 7 / 24 , pos = { x = 900, y = 520}} ,
                                    {delay_time = 9 / 24 , pos = { x = 800, y = 520}} ,
                                    {delay_time = 11 / 24 , pos = { x = 700, y = 520}} ,
                                    {delay_time = 13 / 24 , pos = { x = 600, y = 520}} ,
                                    {delay_time = 15 / 24 , pos = { x = 500, y = 520}} ,
                                    {delay_time = 17 / 24 , pos = { x = 400, y = 520}} ,
                                    {delay_time = 19 / 24 , pos = { x = 300, y = 520}} ,
                                    {delay_time = 21 / 24 , pos = { x = 200, y = 520}} ,
                                    {delay_time = 23 / 24 , pos = { x = 100, y = 520}} ,
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jiqiren_daodan3",
                                args = 
                                {
                                    {delay_time = 23 / 24 , pos = { x = 1200, y = 150}} ,
                                    {delay_time = 21 / 24 , pos = { x = 1100, y = 150}} ,
                                    {delay_time = 19 / 24 , pos = { x = 1000, y = 150}} ,
                                    {delay_time = 17 / 24 , pos = { x = 900, y = 150}} ,
                                    {delay_time = 15 / 24 , pos = { x = 800, y = 150}} ,
                                    {delay_time = 13 / 24 , pos = { x = 700, y = 150}} ,
                                    {delay_time = 11 / 24 , pos = { x = 600, y = 150}} ,
                                    {delay_time = 9 / 24 , pos = { x = 500, y = 150}} ,
                                    {delay_time = 7 / 24 , pos = { x = 400, y = 150}} ,
                                    {delay_time = 5 / 24 , pos = { x = 300, y = 150}} ,
                                    {delay_time = 3 / 24 , pos = { x = 200, y = 150}} ,
                                    {delay_time = 1 / 24 , pos = { x = 100, y = 150}} ,
                                },
                            },
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
                    OPTIONS = {delay_time = 216 / 24},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jiqiren_daodan3",
                                args = 
                                {
                                    {delay_time = 1 / 24 , pos = { x = 1200, y = 450}} ,
                                    {delay_time = 3 / 24 , pos = { x = 1100, y = 450}} ,
                                    {delay_time = 5 / 24 , pos = { x = 1000, y = 450}} ,
                                    {delay_time = 7 / 24 , pos = { x = 900, y = 450}} ,
                                    {delay_time = 9 / 24 , pos = { x = 800, y = 450}} ,
                                    {delay_time = 11 / 24 , pos = { x = 700, y = 450}} ,
                                    {delay_time = 13 / 24 , pos = { x = 600, y = 450}} ,
                                    {delay_time = 15 / 24 , pos = { x = 500, y = 450}} ,
                                    {delay_time = 17 / 24 , pos = { x = 400, y = 450}} ,
                                    {delay_time = 19 / 24 , pos = { x = 300, y = 450}} ,
                                    {delay_time = 21 / 24 , pos = { x = 200, y = 450}} ,
                                    {delay_time = 23 / 24 , pos = { x = 100, y = 450}} ,
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jiqiren_daodan3",
                                args = 
                                {
                                    {delay_time = 23 / 24 , pos = { x = 1200, y = 220}} ,
                                    {delay_time = 21 / 24 , pos = { x = 1100, y = 220}} ,
                                    {delay_time = 19 / 24 , pos = { x = 1000, y = 220}} ,
                                    {delay_time = 17 / 24 , pos = { x = 900, y = 220}} ,
                                    {delay_time = 15 / 24 , pos = { x = 800, y = 220}} ,
                                    {delay_time = 13 / 24 , pos = { x = 700, y = 220}} ,
                                    {delay_time = 11 / 24 , pos = { x = 600, y = 220}} ,
                                    {delay_time = 9 / 24 , pos = { x = 500, y = 220}} ,
                                    {delay_time = 7 / 24 , pos = { x = 400, y = 220}} ,
                                    {delay_time = 5 / 24 , pos = { x = 300, y = 220}} ,
                                    {delay_time = 3 / 24 , pos = { x = 200, y = 220}} ,
                                    {delay_time = 1 / 24 , pos = { x = 100, y = 220}} ,
                                },
                            },
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
                    OPTIONS = {delay_time = 204 / 24},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jiqiren_daodan2",
                                args = 
                                {
                                    {delay_time = 1 / 24 , pos = { x = 1200, y = 450}} ,
                                    {delay_time = 4 / 24 , pos = { x = 1010, y = 450}} ,
                                    {delay_time = 7 / 24 , pos = { x = 820, y = 450}} ,
                                    {delay_time = 10 / 24 , pos = { x = 630, y = 450}} ,
                                    {delay_time = 13 / 24 , pos = { x = 440, y = 450}} ,
                                    {delay_time = 16 / 24 , pos = { x = 250, y = 450}} ,
                                    {delay_time = 19 / 24 , pos = { x = 100, y = 450}} ,
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jiqiren_daodan1",
                                args = 
                                {
                                    {delay_time = 19 / 24 , pos = { x = 1200, y = 220}} ,
                                    {delay_time = 16 / 24 , pos = { x = 1010, y = 220}} ,
                                    {delay_time = 13 / 24 , pos = { x = 820, y = 220}} ,
                                    {delay_time = 10 / 24 , pos = { x = 630, y = 220}} ,
                                    {delay_time = 7 / 24 , pos = { x = 440, y = 220}} ,
                                    {delay_time = 4 / 24 , pos = { x = 250, y = 220}} ,
                                    {delay_time = 1 / 24 , pos = { x = 100, y = 220}} ,
                                },
                            },
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
                    OPTIONS = {delay_time = 41 / 24},
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
    },
}
return zidan_tongyong