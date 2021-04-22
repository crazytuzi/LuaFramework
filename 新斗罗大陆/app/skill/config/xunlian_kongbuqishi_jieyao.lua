local zhuzhuqing_zhenji_shanghai = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "xunlian_kongbuqishi_liuxue_chufa"},
        },
        {
            CLASS = "action.QSBArgsRandom",
            OPTIONS = {
                info = {count = 1},
                input = {
                    datas = {1,2,3,4,5,6},
                    formats = {1,1,1,1,1,1},
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
                    CLASS = "action.QSBTrap", 
                    OPTIONS = 
                    { 
                        flag = 1,
                        trapId = "xunlian_kongbuqishi_jieyao1",
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
                        flag = 2,
                        trapId = "xunlian_kongbuqishi_jieyao2",
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
                        flag = 3,
                        trapId = "xunlian_kongbuqishi_jieyao3",
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
                        flag = 4,
                        trapId = "xunlian_kongbuqishi_jieyao4",
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
                        flag = 5,
                        trapId = "xunlian_kongbuqishi_jieyao5",
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
                        flag = 6,
                        trapId = "xunlian_kongbuqishi_jieyao6",
                        args = 
                        {
                            {relative_pos = { x = 0, y = 0}} ,
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return zhuzhuqing_zhenji_shanghai