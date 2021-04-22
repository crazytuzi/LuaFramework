-- 技能 暗器 红尘庇佑死亡移除2
-- 技能ID 40597

local anqi_hongchenbiyou_siwang2 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_huifu_chufa2"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_huifu_yichu2"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_xixue2"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "hongchenbiyou_zhiliao_chucun2"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_jianshang2"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_zengshang2"},
        },
        {
	        CLASS = "action.QSBAttackFinish",
	    },
    },
}

return anqi_hongchenbiyou_siwang2