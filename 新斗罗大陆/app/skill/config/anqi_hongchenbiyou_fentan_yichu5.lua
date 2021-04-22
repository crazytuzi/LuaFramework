-- 技能 暗器 红尘庇佑分摊伤害移除5
-- 技能ID 40609

local anqi_hongchenbiyou_fentan_yichu5 = {
    CLASS = "composite.QSBSequence",
    ARGS = {
		{
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {is_target = false, buff_id = "anqi_hongchenbiyou_fentan_yichu5"},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "hongchenbiyou_lianxie5"},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "hongchenbiyou_baoming"},
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
                    OPTIONS = {is_target = false, buff_id = "anqi_hongchenbiyou_fentan_yichu5"},
                },
            },
        },
        {
	        CLASS = "action.QSBAttackFinish",
	    },
    },
}

return anqi_hongchenbiyou_fentan_yichu5