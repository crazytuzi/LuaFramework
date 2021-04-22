local hl_sanyanjinni_dazhao_trigger3 = 
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
                                    OPTIONS = {buff_id = {"hl_sanyanjinni_dazhaomianyi_buff", "hl_sanyanjinni_dazhao_buff_1", "hl_sanyanjinni_dazhao_buff_2", "hl_sanyanjinni_dazhao_buff_3"}, teammate = true},
                                },
                                {
                                    CLASS = "action.QSBApplyTeamabsorb",
                                    OPTIONS = { attack_percent = 9, hp_percent = 0.36, decrease_hp_by_absorb_toal = 0.65,damage_limit_percent = 0.25,duration = 8,dragon_modifier=1,pve_cofficient=1},
                                },
                                {
                                    CLASS = "action.QSBRemoveBuff",
                                    OPTIONS = {buff_id = {"hl_sanyanjinni_dazhaomianyi_buff", "hl_sanyanjinni_dazhao_buff_1", "hl_sanyanjinni_dazhao_buff_2", "hl_sanyanjinni_dazhao_buff_3"}, teammate_and_self = true},
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
                                    OPTIONS = {buff_id = {"hl_sanyanjinni_dazhaomianyi_buff", "hl_sanyanjinni_dazhao_buff_1", "hl_sanyanjinni_dazhao_buff_2", "hl_sanyanjinni_dazhao_buff_3" , "hl_sanyanjinni_dazhao_pve_buff_4"}, teammate = true},
                                },
                                {
                                    CLASS = "action.QSBApplyTeamabsorb",
                                    OPTIONS = { attack_percent = 36, hp_percent = 0.24, decrease_hp_by_absorb_toal = 3.125,damage_limit_percent = 1,duration = 8,dragon_modifier=1,pve_cofficient=1},
                                },
                                {
                                    CLASS = "action.QSBRemoveBuff",
                                    OPTIONS = {buff_id = {"hl_sanyanjinni_dazhaomianyi_buff", "hl_sanyanjinni_dazhao_buff_1", "hl_sanyanjinni_dazhao_buff_2", "hl_sanyanjinni_dazhao_buff_3"}, teammate_and_self = true},
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
return hl_sanyanjinni_dazhao_trigger3