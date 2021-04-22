--大地之王碎地
--重击地面，使脚下的地表碎裂，玩家踩上扣血减速，boss踩上加攻加防
--创建人：庞圣峰
--创建时间：2018-1-4

local boss_dadizhiwang_suidi = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBPlayAnimation",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                    },
                },
            },
        },
		{
            CLASS = "action.QSBTriggerSkill",
			OPTIONS = {skill_id = 50141, wait_finish = true}, --放置另一个trap
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return boss_dadizhiwang_suidi