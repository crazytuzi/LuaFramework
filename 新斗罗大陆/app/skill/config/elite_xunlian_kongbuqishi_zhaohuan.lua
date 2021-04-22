local elite_xunlian_kongbuqishi_zhaohuan = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack12"},       
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.4},
                        },
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack12"},       
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.4},
                        },
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack15"},       
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
                            OPTIONS = {delay_time = 6},
                        },
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_shanghai"},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 1},
                        },
                        {
                            CLASS = "action.QSBArgsRandom",
                            OPTIONS = {
                                info = {count = 1},
                                input = {
                                    datas = {1,2,3,4,5},
                                    formats = {1,1,1,1,1},
                                },
                                output = {output_type = "data"},
                                args_translate = { select = "number"}
                            },
                        },
                        {
                            CLASS = "composite.QSBSelectorByNumber",
                            ARGS = 
                            {
                                {
                                    CLASS = "composite.QSBParallel",
                                    OPTIONS = {flag = 1},
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBTrap", 
                                            OPTIONS = 
                                            { 
                                                trapId = "xunlian_kongbuqishi_qiang1",
                                                args = 
                                                {
                                                    {relative_pos = { x = 0, y = 0}} ,
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBTrap", 
                                            OPTIONS = 
                                            { 
                                                trapId = "xunlian_kongbuqishi_kuang1",
                                                args = 
                                                {
                                                    {relative_pos = { x = 0, y = 0}} ,
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBSummonMonsters",
                                            OPTIONS = {wave = -1,attacker_level = true},
                                        },
                                    },
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    OPTIONS = {flag = 2},
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBTrap", 
                                            OPTIONS = 
                                            { 
                                                trapId = "xunlian_kongbuqishi_qiang2",
                                                args = 
                                                {
                                                    {relative_pos = { x = 0, y = 0}} ,
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBTrap", 
                                            OPTIONS = 
                                            { 
                                                trapId = "xunlian_kongbuqishi_kuang2",
                                                args = 
                                                {
                                                    {relative_pos = { x = 0, y = 0}} ,
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBSummonMonsters",
                                            OPTIONS = {wave = -2,attacker_level = true},
                                        },
                                    },
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    OPTIONS = {flag = 3},
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBTrap", 
                                            OPTIONS = 
                                            { 
                                                trapId = "xunlian_kongbuqishi_qiang3",
                                                args = 
                                                {
                                                    {relative_pos = { x = 0, y = 0}} ,
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBTrap", 
                                            OPTIONS = 
                                            { 
                                                trapId = "xunlian_kongbuqishi_kuang3",
                                                args = 
                                                {
                                                    {relative_pos = { x = 0, y = 0}} ,
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBSummonMonsters",
                                            OPTIONS = {wave = -3,attacker_level = true},
                                        },
                                    },
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    OPTIONS = {flag = 4},
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBTrap", 
                                            OPTIONS = 
                                            { 
                                                trapId = "xunlian_kongbuqishi_qiang4",
                                                args = 
                                                {
                                                    {relative_pos = { x = 0, y = 0}} ,
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBTrap", 
                                            OPTIONS = 
                                            { 
                                                trapId = "xunlian_kongbuqishi_kuang4",
                                                args = 
                                                {
                                                    {relative_pos = { x = 0, y = 0}} ,
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBSummonMonsters",
                                            OPTIONS = {wave = -4,attacker_level = true},
                                        },
                                    },
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    OPTIONS = {flag = 5},
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBTrap", 
                                            OPTIONS = 
                                            { 
                                                trapId = "xunlian_kongbuqishi_qiang5",
                                                args = 
                                                {
                                                    {relative_pos = { x = 0, y = 0}} ,
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBTrap", 
                                            OPTIONS = 
                                            { 
                                                trapId = "xunlian_kongbuqishi_kuang5",
                                                args = 
                                                {
                                                    {relative_pos = { x = 0, y = 0}} ,
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBSummonMonsters",
                                            OPTIONS = {wave = -5,attacker_level = true},
                                        },
                                    },
                                },
                            },
                        },
                    },
                }
            },
        },
    },
}
return elite_xunlian_kongbuqishi_zhaohuan