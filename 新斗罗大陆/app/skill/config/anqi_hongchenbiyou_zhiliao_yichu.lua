-- 技能 暗器 红尘庇佑治疗移除
-- 技能ID 40602

local anqi_hongchenbiyou_zhiliao_yichu = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBRemoveBuff", 
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_xixue1"} 
        },
        {
            CLASS = "action.QSBRemoveBuff", 
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_xixue2"} 
        },
        {
            CLASS = "action.QSBRemoveBuff", 
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_xixue3"} 
        },
        {
            CLASS = "action.QSBRemoveBuff", 
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_xixue4"} 
        },
        {
            CLASS = "action.QSBRemoveBuff", 
            OPTIONS = {teammate_and_self = true, buff_id = "anqi_hongchenbiyou_xixue5"} 
        },
        {
            CLASS = "action.QSBRemoveBuff", 
            OPTIONS = {is_target = false, buff_id = "hongchenbiyou_zhiliao_chucun1"} 
        },
        {
            CLASS = "action.QSBRemoveBuff", 
            OPTIONS = {is_target = false, buff_id = "hongchenbiyou_zhiliao_chucun2"} 
        },
        {
            CLASS = "action.QSBRemoveBuff", 
            OPTIONS = {is_target = false, buff_id = "hongchenbiyou_zhiliao_chucun3"} 
        },
        {
            CLASS = "action.QSBRemoveBuff", 
            OPTIONS = {is_target = false, buff_id = "hongchenbiyou_zhiliao_chucun4"} 
        },
        {
            CLASS = "action.QSBRemoveBuff", 
            OPTIONS = {is_target = false, buff_id = "hongchenbiyou_zhiliao_chucun5"} 
        },
        {
	        CLASS = "action.QSBAttackFinish",
	    },
    },
}

return anqi_hongchenbiyou_zhiliao_yichu