-- 技能 暗器 红尘庇佑初始上buff1
-- 技能ID 40591

local anqi_hongchenbiyou_chushi1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {is_target = false, buff_id = "anqi_hongchenbiyou_chushi1"},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {highest_attack_teammate = true, buff_id = {"anqi_hongchenbiyou_huifu_chufa1", "anqi_hongchenbiyou_jianshang1", "anqi_hongchenbiyou_zengshang1", "anqi_hongchenbiyou_biaoji_fentan"}},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = {"anqi_hongchenbiyou_huifu_yichu1", "anqi_hongchenbiyou_jianshang1", "anqi_hongchenbiyou_zengshang1", 
            "anqi_hongchenbiyou_biaoji_ziji", "anqi_hongchenbiyou_biaoji_fentan"}},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return anqi_hongchenbiyou_chushi1