local hl_sanyanjinni_dazhao_trigger1 = 
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {           
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = 
                    {
                        failed_select = -1,
                        {expression = "self:is_pvp=true", select = 1},
                        {expression = "self:is_pvp=false", select = 2},

                    },
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = 
                    {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {

                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = {"hl_sanyanjinni_dazhao_buff_1", "hl_sanyanjinni_dazhao_buff_2", "hl_sanyanjinni_dazhao_buff_3"}, teammate = true},
                                },
                                {
                                    CLASS = "action.QSBApplyTeamabsorb",
                                    OPTIONS = { attack_percent = 7.4, hp_percent = 0.29, decrease_hp_by_absorb_toal = 0.375,damage_limit_percent = 0.25,duration = 8,dragon_modifier=1,pve_cofficient=1},
                                },
                                {
                                    CLASS = "action.QSBRemoveBuff",
                                    OPTIONS = {buff_id = {"hl_sanyanjinni_dazhao_buff_1", "hl_sanyanjinni_dazhao_buff_2", "hl_sanyanjinni_dazhao_buff_3"}, teammate_and_self = true},
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
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = {"hl_sanyanjinni_dazhao_buff_1", "hl_sanyanjinni_dazhao_buff_2", "hl_sanyanjinni_dazhao_buff_3", "hl_sanyanjinni_dazhao_pve_buff_2"}, teammate = true},
                                },
                                {
                                    CLASS = "action.QSBApplyTeamabsorb",
                                    OPTIONS = { attack_percent = 28, hp_percent = 0.1875, decrease_hp_by_absorb_toal = 1.875,damage_limit_percent = 1,duration = 8,dragon_modifier=1,pve_cofficient=1},
                                },
                                {
                                    CLASS = "action.QSBRemoveBuff",
                                    OPTIONS = {buff_id = {"hl_sanyanjinni_dazhao_buff_1", "hl_sanyanjinni_dazhao_buff_2", "hl_sanyanjinni_dazhao_buff_3"}, teammate_and_self = true},
                                },
                                {
                                    CLASS = "action.QSBAttackFinish",
                                },
                            },
                        },
                    },
                },
            },
        }
return hl_sanyanjinni_dazhao_trigger1