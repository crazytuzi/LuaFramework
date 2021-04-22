local boss_niumang_dazhao = 
{
	CLASS = "composite.QSBParallel",
    ARGS = 
    {
        -- {
        --     CLASS = "action.QSBLockTarget",     --锁定目标
        --     OPTIONS = {is_lock_target = true, revertable = true},
        -- },
    	{
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attack02"},
        },
        {
            CLASS = "action.QSBBullet",
            OPTIONS = {is_target = true ,start_pos = {x =0,y = 100}},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 24 / 24},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "nengliangqiu_diancihuan2" , is_target = true},
                },
            },
        },
    	{
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
            	{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 120 / 24},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "nengliangqiu_xiyin" , is_hit_effect = false},
                        },
                        {
                            CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                            OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = false,count = 1, distance = 0, trapId = "diancihuan_xianjing"},
                        },
                    },
                },
                -- {
                --     CLASS = "action.QSBLockTarget",     --锁定目标
                --     OPTIONS = {is_lock_target = false},
                -- },
                {
                    CLASS = "action.QSBAttackFinish",
                },
			},
		},
	},
}
return boss_niumang_dazhao