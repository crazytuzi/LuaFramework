local shifa_tongyong = {
     CLASS = "composite.QSBSequence",
     ARGS = {
                {
                    CLASS = "action.QSBExpression",
                    OPTIONS = {expStr = "isBlockDamageSign = {target:block_f > random}"},
                },
                {
                    CLASS = "action.QSBExpression",
                    OPTIONS = {expStr = "value = {0.23* (1 - 0.5 * isBlock)}, isBlockDamageSign = {isBlock}", get_black_board = {isBlock = "isBlockDamageSign"}}

                },
                {
                    CLASS = "action.QSBDecreaseHpWtihoutLog",
                    OPTIONS = {mode = "max_hp_percent", ignore_absorb = true,target = true, showDamage = true, notWtihoutLog = true},
                },

        -- {
        --     CLASS = "action.QSBRemoveBuff",
        --     OPTIONS = {buff_id = "dugubo_zhenji_die", remove_all_same_buff_id = true},
        -- },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shifa_tongyong