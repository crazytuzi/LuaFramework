-- 技能 暗器 红尘庇佑初始上buff3
-- 技能ID 40593

local anqi_hongchenbiyou_chushi3 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {is_target = false, buff_id = "anqi_hongchenbiyou_chushi3"},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {highest_attack_teammate = true, buff_id = {"anqi_hongchenbiyou_huifu_chufa3", "anqi_hongchenbiyou_jianshang3",
             "anqi_hongchenbiyou_zengshang3", "anqi_hongchenbiyou_biaoji_fentan", "anqi_hongchenbiyou_fentan_yichu3", "anqi_hongchenbiyou_biaoji_duiyou"}},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = {"anqi_hongchenbiyou_huifu_yichu3", "anqi_hongchenbiyou_jianshang3", "anqi_hongchenbiyou_zengshang3", 
            "anqi_hongchenbiyou_biaoji_ziji", "anqi_hongchenbiyou_fentan_chufa3", "anqi_hongchenbiyou_biaoji_fentan"}},
        },
        {
	        CLASS = "action.QSBAttackFinish",
	    },
    },
}

return anqi_hongchenbiyou_chushi3