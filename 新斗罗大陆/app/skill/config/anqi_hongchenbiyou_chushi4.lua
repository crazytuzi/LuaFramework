-- 技能 暗器 红尘庇佑初始上buff4
-- 技能ID 40594

local anqi_hongchenbiyou_chushi4 = 
{
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {is_target = false, buff_id = "anqi_hongchenbiyou_chushi4"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {highest_attack_teammate = true, buff_id = {"anqi_hongchenbiyou_huifu_chufa4", "anqi_hongchenbiyou_jianshang4", 
                    "anqi_hongchenbiyou_zengshang4", "anqi_hongchenbiyou_biaoji_fentan", "anqi_hongchenbiyou_fentan_yichu4", "anqi_hongchenbiyou_biaoji_duiyou"}},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_target = false, buff_id = {"anqi_hongchenbiyou_huifu_yichu4", "anqi_hongchenbiyou_jianshang4", "anqi_hongchenbiyou_zengshang4", 
                    "anqi_hongchenbiyou_biaoji_ziji", "anqi_hongchenbiyou_fentan_chufa4", "anqi_hongchenbiyou_biaoji_fentan"}},
                },
            },
        },
        {
	        CLASS = "action.QSBAttackFinish",
	    },
    },
}

return anqi_hongchenbiyou_chushi4