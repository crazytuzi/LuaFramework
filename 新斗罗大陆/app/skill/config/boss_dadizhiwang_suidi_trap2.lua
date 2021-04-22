
--大地之王碎地（陷阱2）
--用于召唤大地之王碎地的第二个陷阱
--创建人：庞圣峰
--创建时间：2018-1-4

local boss_dadizhiwang_suidi_trap2 = {
     CLASS = "composite.QSBSequence",
     ARGS = {
		{
			CLASS = "action.QSBHitTarget",
		},
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return boss_dadizhiwang_suidi_trap2