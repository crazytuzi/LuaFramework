

local longjuanfeng_shanghai = {
    CLASS = "composite.QSBSequence",
    ARGS = {   
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
		},
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "stand", is_loop = true},
                },
                {
                    CLASS = "action.QSBActorKeepAnimation",
                    OPTIONS = {is_keep_animation = true}
                },
                {
                    CLASS = "action.QSBHitTimer",
					OPTIONS = {duration_time = 30 ,interval_time = 0.2},
                },
            },
        },

		{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
		},
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBActorKeepAnimation",
                    OPTIONS = {is_keep_animation = false}
                },
                {
                    CLASS = "action.QSBActorStand",
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return longjuanfeng_shanghai