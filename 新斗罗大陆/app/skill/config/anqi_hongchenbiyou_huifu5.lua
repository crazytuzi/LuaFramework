-- 技能 暗器 红尘庇佑吸血恢复触发5
-- 技能ID 40585

local anqi_hongchenbiyou_huifu5 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "anqi_hongchenbiyou_xixue5"},
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "hongchenpihu_attack02_1_2", is_hit_effect = false},
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "hongchenpihu_attack02_1_1", is_hit_effect = false},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {is_teammate = true, under_status = "hongchenbiyou_self"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = {"hongchenbiyou_zhiliao_chucun5","hongchenbiyou_chucun_yichu"}},
                },
            },
        },
        {
	        CLASS = "action.QSBAttackFinish",
	    },
    },
}

return anqi_hongchenbiyou_huifu5