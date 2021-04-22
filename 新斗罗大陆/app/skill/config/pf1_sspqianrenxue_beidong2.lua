
local pf_qiandaoliu_dazhao = 
{
        CLASS = "composite.QSBSequence",
        OPTIONS = {forward_mode = true},
        ARGS = {
            {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = {
                        failed_select = 1,
                        {expression = "self:self_teammates_num=1", select = 1},
                        {expression = "self:self_teammates_num=2", select = 2},
                        {expression = "self:self_teammates_num=3", select = 3},
                        {expression = "self:self_teammates_num>3", select = 4},
                    }
                },
            {
                CLASS = "composite.QSBSelector",
                ARGS = {
                    {
                        CLASS = "action.QSBApplyBuff",
                        OPTIONS = {is_target = false, buff_id = "pf1_sspqianrenxue_bd2_teammate_buff"},
                    },
                      {
                        CLASS = "action.QSBApplyBuff",
                        OPTIONS = {is_target = false, buff_id = "pf1_sspqianrenxue_bd2_teammate_buff1"},
                    },
                      {
                        CLASS = "action.QSBApplyBuff",
                        OPTIONS = {is_target = false, buff_id = "pf1_sspqianrenxue_bd2_teammate_buff2"},
                    },
                      {
                        CLASS = "action.QSBApplyBuff",
                        OPTIONS = {is_target = false, buff_id = "pf1_sspqianrenxue_bd2_teammate_buff3"},
                    },
                },
            },
            {
                CLASS = "action.QSBAttackFinish"
            },            
        },
}
return pf_qiandaoliu_dazhao