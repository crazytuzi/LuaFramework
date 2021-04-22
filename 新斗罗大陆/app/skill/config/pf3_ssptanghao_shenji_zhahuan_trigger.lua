-- 技能 唐昊神技炸环
-- 技能ID 39131
-- 判断我方是否只剩唐昊和阿银,或二者之一阵亡
--[[
    魂师 昊天唐昊
    ID:1058
    psf 2020-7-28
]]--

local ZHAHUAN = 
{
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBRemoveBuffByStatus",
            OPTIONS = {status = "ssptanghao_zhahuan"},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = {"ssptanghao_shenji_wudi_buff","ssptanghao_shenji_zhahuan_debuff"}},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_ssptanghao03_shenji_3", is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_ssptanghao03_shenji_3_1", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "action.QSBPlayGodSkillAnimation",
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {CLASS = "action.QSBRemoveBuffByStatus",OPTIONS = {status = "sschenxin_dazhao3"},},
                {CLASS = "action.QSBRemoveBuffByStatus",OPTIONS = {status = "sschenxin_zhenji_debuff"},},
                {CLASS = "action.QSBRemoveBuffByStatus",OPTIONS = {status = "sszhuzhuqing_sj_stun"},},
                {CLASS = "action.QSBRemoveBuffByStatus",OPTIONS = {status = "stun"},},
                {CLASS = "action.QSBRemoveBuffByStatus",OPTIONS = {status = "stun_charge"},},
                {CLASS = "action.QSBRemoveBuffByStatus",OPTIONS = {status = "silence"},},
                {CLASS = "action.QSBRemoveBuffByStatus",OPTIONS = {status = "time_stop"},},
                {CLASS = "action.QSBRemoveBuffByStatus",OPTIONS = {status = "freeze"},},
                {CLASS = "action.QSBRemoveBuffByStatus",OPTIONS = {status = "fall"},},
                {CLASS = "action.QSBRemoveBuffByStatus",OPTIONS = {status = "winding_of_cane"},},
                {CLASS = "action.QSBRemoveBuffByStatus",OPTIONS = {status = "fear"},},
                {CLASS = "action.QSBRemoveBuffByStatus",OPTIONS = {status = "sheep"},},
                {CLASS = "action.QSBRemoveBuffByStatus",OPTIONS = {status = "sheep_1"},},
                {CLASS = "action.QSBRemoveBuffByStatus",OPTIONS = {status = "sheep_2"},},
                {CLASS = "action.QSBRemoveBuffByStatus",OPTIONS = {status = "sheep_3"},},
            },
        },
        {
            CLASS = "action.QSBTriggerSkill",   
            OPTIONS = {skill_id = 2639132, skill_level =1},
        },
    },
}

local ssptanghao_shenji_zhahuan_trigger = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBArgsConditionSelector",
            OPTIONS = {
                failed_select = 2,
                {expression = "self:self_teammates_num<2", select = 1},
                {expression = "self:hp<self:max_hp*0.35", select = 1},
                {expression = "self:has_buff:pf3_ssptanghao_shenji_zhahuan_buff1", select = 1},
            }
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = {
                ZHAHUAN,
                {
                    CLASS = "action.QSBClearSkillCD",
                    OPTIONS = {skill_id = 2639131},
                },
            },
        }, 
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return ssptanghao_shenji_zhahuan_trigger