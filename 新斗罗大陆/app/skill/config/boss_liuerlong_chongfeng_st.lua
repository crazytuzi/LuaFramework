-- 技能 BOSS柳二龙冲锋
-- 技能ID 50651
-- 冲向目标
--[[
	boss 柳二龙 
	ID:3175 力量试炼
	psf 2018-5-31
]]--

local boss_liuerlong_chongfeng_st = {
   CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBLockTarget",
            OPTIONS = {is_lock_target = true, revertable = true},
        },  
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                     CLASS = "composite.QSBSequence",
                     ARGS = {
                        {
                            CLASS = "action.QSBPlayAnimation",
							OPTIONS = {animation = "attack12"},
                        },
                        {
                            CLASS = "action.QSBAttackFinish"
                        },
                    },
                },
				{
					CLASS = "action.QSBCharge", 
					OPTIONS = {move_time = 0.5},
				},
            },
        },
        {
            CLASS = "action.QSBLockTarget",
            OPTIONS = {is_lock_target = false},
        },
    },
}

return boss_liuerlong_chongfeng_st

