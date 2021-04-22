local npc_pozhiyizu_zhaohuanlaolong_10_16 = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBArgsIsUnderStatus",
            OPTIONS = {is_attacker = true,reverse_result = true, status = "dianjiang"},
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
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                                {
                                    CLASS = "action.QSBRemoveBuff",
                                    OPTIONS = {buff_id = "jinshu_dianjiang"},
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
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "jinshuboss2_attack20_4" ,is_hit_effect = false},
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