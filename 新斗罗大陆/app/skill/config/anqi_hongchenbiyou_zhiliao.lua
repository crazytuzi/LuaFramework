-- 技能 暗器 红尘庇佑治疗
-- 技能ID 40601

local anqi_hongchenbiyou_zhiliao = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBArgsSelectTarget",
            OPTIONS = {under_status = "hongchenbiyou_self", is_teammate = true},
        },
        {
            CLASS = "action.QSBHitTarget",
        },
        {
	        CLASS = "action.QSBAttackFinish",
	    },
    },
}

return anqi_hongchenbiyou_zhiliao