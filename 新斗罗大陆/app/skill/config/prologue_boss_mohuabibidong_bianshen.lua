--序章BOSS 魔化比比东 变身
--变回人形，然后消失
--创建人：庞圣峰
--创建时间：2018-3-13

local prologue_boss_mohuabibidong_bianshen = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
            CLASS = "action.QSBUncancellable",    
        },
        -- {
            -- CLASS = "action.QSBImmuneCharge",
            -- OPTIONS = {enter = true, revertable = true},
        -- },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                -- {
                    -- CLASS = "action.QSBImmuneCharge",
                    -- OPTIONS = {enter = false},
                -- },
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {   
						{
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 72/24},
                        },
                        -- {
                            -- CLASS = "action.QSBImmuneCharge",
                            -- OPTIONS = {enter = true, revertable = true},
                        -- },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_target = false},
        },
		{
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "prologue_mohuabibidong_bianshen_buff"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {exit = true},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return prologue_boss_mohuabibidong_bianshen
