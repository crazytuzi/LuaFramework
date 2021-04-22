-- 技能 暗器 红尘庇佑双倍灼烧1
-- 技能ID 40586

local anqi_hongchenbiyou_zhuoshao1 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBPlayMountSkillAnimation",
        },
		{
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "anqi_hongchenbiyou_zhuoshao1"},
        },
        {
	        CLASS = "action.QSBAttackFinish",
	    },
    },
}

return anqi_hongchenbiyou_zhuoshao1