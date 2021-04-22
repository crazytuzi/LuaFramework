-- 技能 暗器 红尘庇佑储存治疗移除
-- 技能ID 40610

local anqi_hongchenbiyou_chucun_yichu = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBRemoveBuff", 
            OPTIONS = {is_target = false, buff_id = "hongchenbiyou_zhiliao_chucun1"}, 
        },
        {
            CLASS = "action.QSBRemoveBuff", 
            OPTIONS = {is_target = false, buff_id = "hongchenbiyou_zhiliao_chucun2"}, 
        },
        {
            CLASS = "action.QSBRemoveBuff", 
            OPTIONS = {is_target = false, buff_id = "hongchenbiyou_zhiliao_chucun3"}, 
        },
        {
            CLASS = "action.QSBRemoveBuff", 
            OPTIONS = {is_target = false, buff_id = "hongchenbiyou_zhiliao_chucun4"}, 
        },
        {
            CLASS = "action.QSBRemoveBuff", 
            OPTIONS = {is_target = false, buff_id = "hongchenbiyou_zhiliao_chucun5"}, 
        },
        {
	        CLASS = "action.QSBAttackFinish",
	    },
    },
}

return anqi_hongchenbiyou_chucun_yichu