-- 技能 暗器 红尘庇佑死亡移除3
-- 技能ID 40598

local anqi_hongchenbiyou_siwang3 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_huifu_chufa3"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_huifu_yichu3"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_fentan_yichu3"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_fentan_chufa3"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_xixue3"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "hongchenbiyou_zhiliao_chucun3"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_biaoji_fentan"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_jianshang3"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_zengshang3"},
        },
        {
	        CLASS = "action.QSBAttackFinish",
	    },
    },
}

return anqi_hongchenbiyou_siwang3