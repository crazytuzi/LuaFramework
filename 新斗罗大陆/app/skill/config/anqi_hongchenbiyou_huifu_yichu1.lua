-- 技能 暗器 红尘庇佑吸血移除1
-- 技能ID 40577

local anqi_hongchenbiyou_huifu_yichu1 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBPlayMountSkillAnimation",
        },
		{
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {is_target = false, buff_id = "anqi_hongchenbiyou_huifu_yichu1"},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "hongchenbiyou_lianxie1"},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_target = false, buff_id = "anqi_hongchenbiyou_huifu_yichu1"},
                },
            },
        },
        {
	        CLASS = "action.QSBAttackFinish",
	    },
    },
}

return anqi_hongchenbiyou_huifu_yichu1