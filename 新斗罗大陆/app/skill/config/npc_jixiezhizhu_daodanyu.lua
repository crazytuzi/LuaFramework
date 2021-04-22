local npc_pozhiyizu_zhaohuanlaolong_10_16 = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBArgsIsUnderStatus",
            OPTIONS = {is_attacker = true,reverse_result = true, status = "daodan_lockon"},
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = 
            {
                ----没有自杀标记时
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBAttackFinish",
                        },
                    },
                },
                ------有自杀标记时
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                            OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 0, trapId = "qiandigongji_yujing"},
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 1, attacker_face = false,attacker_underfoot = true,count = 2, distance = 0, trapId = "jixiezhizhu_paohong"},
                                },
                                {
                                    CLASS = "action.QSBAttackFinish",
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 40 / 24},
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBShakeScreen",
                                            OPTIONS = {amplitude = 10, duration = 0.45, count = 2,},
                                        },
                                        {
                                            CLASS = "action.QSBPlaySound",
                                            OPTIONS = {sound_id ="jixiezhizhu_attack14_1"},
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
                                    OPTIONS = {delay_time = 60 / 24},
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBShakeScreen",
                                            OPTIONS = {amplitude = 10, duration = 0.45, count = 2,},
                                        },
                                        {
                                            CLASS = "action.QSBPlaySound",
                                            OPTIONS = {sound_id ="jixiezhizhu_attack14_1"},
                                        },
                                    },
                                }, 
                            },
                        },
                    },
                },
            },
        },
	},
}
return npc_pozhiyizu_zhaohuanlaolong_10_16
