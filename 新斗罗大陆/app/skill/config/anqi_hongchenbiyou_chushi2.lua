-- 技能 暗器 红尘庇佑初始上buff2
-- 技能ID 40592

local anqi_hongchenbiyou_chushi2 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {is_target = false, buff_id = "anqi_hongchenbiyou_chushi2"},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {highest_attack_teammate = true, buff_id = {"anqi_hongchenbiyou_huifu_chufa2", "anqi_hongchenbiyou_jianshang2", "anqi_hongchenbiyou_zengshang2", "anqi_hongchenbiyou_biaoji_fentan"}},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = {"anqi_hongchenbiyou_huifu_yichu2", "anqi_hongchenbiyou_jianshang2", "anqi_hongchenbiyou_zengshang2", 
            "anqi_hongchenbiyou_biaoji_ziji", "anqi_hongchenbiyou_biaoji_fentan"}},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return anqi_hongchenbiyou_chushi2