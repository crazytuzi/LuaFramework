-- 技能 暗器 红尘庇佑初始上buff5
-- 技能ID 40595

local anqi_hongchenbiyou_chushi5 = 
{
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {is_target = false, buff_id = "anqi_hongchenbiyou_chushi5"},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {highest_attack_teammate = true, buff_id = {"anqi_hongchenbiyou_huifu_chufa5", "anqi_hongchenbiyou_jianshang5",
                             "anqi_hongchenbiyou_zengshang5", "anqi_hongchenbiyou_biaoji_fentan", "anqi_hongchenbiyou_fentan_yichu5", "anqi_hongchenbiyou_biaoji_duiyou"}},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_target = false, buff_id = {"anqi_hongchenbiyou_huifu_yichu5", "anqi_hongchenbiyou_jianshang5", "anqi_hongchenbiyou_zengshang5", 
                            "anqi_hongchenbiyou_biaoji_ziji", "anqi_hongchenbiyou_fentan_chufa5", "anqi_hongchenbiyou_biaoji_fentan"}},
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

return anqi_hongchenbiyou_chushi5