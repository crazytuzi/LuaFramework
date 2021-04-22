-- 技能 暗器 红尘庇佑死亡移除4
-- 技能ID 40599

local anqi_hongchenbiyou_siwang4 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_huifu_chufa4"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_huifu_yichu4"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_fentan_yichu4"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_fentan_chufa4"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_xixue4"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "hongchenbiyou_zhiliao_chucun4"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_biaoji_fentan"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_jianshang4"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_zengshang4"},
        },
        {
	        CLASS = "action.QSBAttackFinish",
	    },
    },
}

return anqi_hongchenbiyou_siwang4