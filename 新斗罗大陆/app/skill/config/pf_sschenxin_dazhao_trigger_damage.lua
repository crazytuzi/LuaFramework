-- 技能 ss剑道尘心高级皮肤大招失败伤害
-- 技能ID 574
-- 全屏多段
--[[
	魂师 剑道尘心
	ID:1056
        psf 2020-4-21
	螺笛 2020-5-13
]]--


local sschenxin_dazhao_trigger_damage = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBArgsSelectTarget",
            OPTIONS = {under_status = "sschenxin_dazhao2",change_all_node_target = true}
        },
        {
            CLASS = "action.QSBArgsConditionSelector",
            OPTIONS = {
                failed_select = 3,
                {expression = "self:buff_num:sschenxin_dazhao_lose_count=2", select = 2},
                {expression = "self:buff_num:sschenxin_dazhao_lose_count=1", select = 1},
            }
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_sschenxin01_attack11_3_13", is_hit_effect = true},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_sschenxin01_attack11_3_12", is_hit_effect = true},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_sschenxin01_attack11_3_11", is_hit_effect = true},
                },
            },
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "sschenxin_dazhao_lose_count"},
        },
        {
            CLASS = "action.QSBHitTarget",
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sschenxin_dazhao_trigger_damage

