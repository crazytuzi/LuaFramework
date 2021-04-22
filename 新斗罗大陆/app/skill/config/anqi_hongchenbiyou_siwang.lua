-- 技能 暗器 红尘庇佑减伤移除
-- 技能ID 40603

local anqi_hongchenbiyou_siwang = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBRemoveBuff", 
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_jianshang1"} 
        },
        {
            CLASS = "action.QSBRemoveBuff", 
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_jianshang2"} 
        },
        {
            CLASS = "action.QSBRemoveBuff", 
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_jianshang3"} 
        },
        {
            CLASS = "action.QSBRemoveBuff", 
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_jianshang4"} 
        },
        {
            CLASS = "action.QSBRemoveBuff", 
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_jianshang5"} 
        },
        {
            CLASS = "action.QSBRemoveBuff", 
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_huifu_chufa1"} 
        },
        {
            CLASS = "action.QSBRemoveBuff", 
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_huifu_chufa2"} 
        },
        {
            CLASS = "action.QSBRemoveBuff", 
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_huifu_chufa3"} 
        },
        {
            CLASS = "action.QSBRemoveBuff", 
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_huifu_chufa4"} 
        },
        {
            CLASS = "action.QSBRemoveBuff", 
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_huifu_chufa5"} 
        },
        {
            CLASS = "action.QSBRemoveBuff", 
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_fentan_chufa3"} 
        },
        {
            CLASS = "action.QSBRemoveBuff", 
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_fentan_chufa4"} 
        },
        {
            CLASS = "action.QSBRemoveBuff", 
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_fentan_chufa5"} 
        },
        {
	        CLASS = "action.QSBAttackFinish",
	    },
    },
}

return anqi_hongchenbiyou_siwang