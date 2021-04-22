-- 技能 暗器 红尘庇佑死亡移除5
-- 技能ID 50600

local anqi_hongchenbiyou_siwang5 = {
    CLASS = "composite.QSBSequence",
    ARGS = {
		{
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_huifu_chufa5"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_huifu_yichu5"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_fentan_yichu5"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_fentan_chufa5"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_xixue5"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "hongchenbiyou_zhiliao_chucun5"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_biaoji_fentan"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_jianshang5"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_zengshang5"},
        },
        {
	        CLASS = "action.QSBAttackFinish",
	    },
    },
}

return anqi_hongchenbiyou_siwang5