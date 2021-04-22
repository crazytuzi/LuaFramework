-- 技能 ss剑道尘心神技调整剑
-- 技能ID 39090~4
-- 调剑的表现
--[[
	魂师 剑道尘心
	ID:1056
	psf 2020-4-21
]]--
--[[
涉及BUFF:
sschenxin_pugong_buff 进入普攻状态
sschenxin_shenji_count_3 尘心剑气计数等级3
sschenxin_shenji_qianghua 尘心剑气计数for鎏金剑气
sschenxin_shenji_buff1~6 尘心身后剑气表现
sschenxin_shenji_qianghua_buff1 尘心身后鎏金剑气表现
]]

local sschenxin_shenji_trigger = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_attacker = true, buff_id = "sschenxin_shenji_count_3"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_attacker = true, buff_id = "sschenxin_shenji_qianghua"},
                },
                {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = {
                        failed_select = 8,
                        {expression = "self:has_buff:sschenxin_pugong_buff", select = 8},
                        {expression = "self:buff_num:sschenxin_shenji_count_3=1", select = 1},
                        {expression = "self:buff_num:sschenxin_shenji_count_3=2", select = 2},
                        {expression = "self:buff_num:sschenxin_shenji_count_3=3", select = 3},
                        {expression = "self:buff_num:sschenxin_shenji_count_3=4", select = 4},
                        {expression = "self:buff_num:sschenxin_shenji_count_3=5", select = 5},
                        {expression = "self:buff_num:sschenxin_shenji_count_3=6", select = 6},
                        {expression = "self:buff_num:sschenxin_shenji_count_3=7", select = 7},
                    }
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBRemoveBuffByStatus",
                                    OPTIONS = {status = "sschenxin_sj1"},--sschenxin_shenji_buff1~5
                                },
                                {
                                    CLASS = "action.QSBRemoveBuffByStatus",
                                    OPTIONS = {status = "sschenxin_sj2"},--sschenxin_shenji_qianghua_buff1~5
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_attacker = true, buff_id = "pf_sschenxin02_shenji_buff1"},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_attacker = true, buff_id = "pf_sschenxin02_shenji_buff2"},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_attacker = true, buff_id = "pf_sschenxin02_shenji_buff3"},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_attacker = true, buff_id = "pf_sschenxin02_shenji_buff4"},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_attacker = true, buff_id = "pf_sschenxin02_shenji_buff5"},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_attacker = true, buff_id = "pf_sschenxin02_shenji_buff6"},
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBRemoveBuff",
                                    OPTIONS = {buff_id = "sschenxin_shenji_qianghua"},
                                },
                                {
                                    CLASS = "action.QSBTriggerSkill",
                                    OPTIONS = {skill_id = 240089, wait_finish = false},
                                },
                            },
                        },
                    },
                }, 
                {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = {
                        failed_select = 2,
                        {expression = "self:has_buff:sschenxin_pugong_buff", select = 2},
                        {expression = "self:has_buff:pf_sschenxin02_shenji_qianghua_buff1", select = 2},
                        {expression = "self:has_buff:pf_sschenxin02_shenji_qianghua_buff2", select = 2},
                        {expression = "self:has_buff:pf_sschenxin02_shenji_qianghua_buff3", select = 2},
                        {expression = "self:has_buff:pf_sschenxin02_shenji_qianghua_buff4", select = 2},
                        {expression = "self:has_buff:pf_sschenxin02_shenji_qianghua_buff5", select = 2},
                        {expression = "self:has_buff:pf_sschenxin02_shenji_qianghua_buff6", select = 2},
                        {expression = "self:buff_num:sschenxin_shenji_qianghua>4", select = 1},
                    }
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBRemoveBuff",
                                    OPTIONS = {remove_all_same_buff_id = true, buff_id = "sschenxin_shenji_qianghua"},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_attacker = true, buff_id = "sschenxin_shenji_count_3"},
                                },
                                {
                                    CLASS = "action.QSBArgsConditionSelector",
                                    OPTIONS = {
                                        failed_select = 7,
                                        {expression = "self:buff_num:sschenxin_shenji_count_3=1", select = 1},
                                        {expression = "self:buff_num:sschenxin_shenji_count_3=2", select = 2},
                                        {expression = "self:buff_num:sschenxin_shenji_count_3=3", select = 3},
                                        {expression = "self:buff_num:sschenxin_shenji_count_3=4", select = 4},
                                        {expression = "self:buff_num:sschenxin_shenji_count_3=5", select = 5},
                                        {expression = "self:buff_num:sschenxin_shenji_count_3=6", select = 6},
                                        {expression = "self:buff_num:sschenxin_shenji_count_3=7", select = 7},
                                    }
                                },
                                {
                                    CLASS = "composite.QSBSelector",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {is_attacker = true, buff_id = "pf_sschenxin02_shenji_qianghua_buff1"},
                                        },
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {is_attacker = true, buff_id = "pf_sschenxin02_shenji_qianghua_buff2"},
                                        },
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {is_attacker = true, buff_id = "pf_sschenxin02_shenji_qianghua_buff3"},
                                        },
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {is_attacker = true, buff_id = "pf_sschenxin02_shenji_qianghua_buff4"},
                                        },
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {is_attacker = true, buff_id = "pf_sschenxin02_shenji_qianghua_buff5"},
                                        },
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {is_attacker = true, buff_id = "pf_sschenxin02_shenji_qianghua_buff6"},
                                        },
                                    },
                                }, 
                            },
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

return sschenxin_shenji_trigger

