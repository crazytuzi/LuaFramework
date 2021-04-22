
local open_dragon_buff = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "open_dragon_buff_1"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "open_dragon_buff_2"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "open_dragon_buff_3"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "open_dragon_buff_4"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "open_dragon_buff_5"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "open_dragon_buff_6"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "open_dragon_buff_7"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "open_dragon_buff_8"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "open_dragon_buff_9"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "open_dragon_buff_10"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "open_dragon_buff_11"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "open_dragon_buff_12"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "open_dragon_buff_13"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "open_dragon_buff_14"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "open_dragon_buff_15"},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
},
}

return open_dragon_buff