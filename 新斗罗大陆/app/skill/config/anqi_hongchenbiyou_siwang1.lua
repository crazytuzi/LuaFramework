-- 技能 暗器 红尘庇佑死亡移除1
-- 技能ID 40596

local anqi_hongchenbiyou_siwang1 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_huifu_chufa1"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_huifu_yichu1"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_xixue1"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "hongchenbiyou_zhiliao_chucun1"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_jianshang1"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_zengshang1"},
        },
        {
	        CLASS = "action.QSBAttackFinish",
	    },
    },
}

return anqi_hongchenbiyou_siwang1