
local ultra_power_infusion_troll_lokamil = {
    CLASS = "composite.QSBParallel",
    ARGS = {
    {
        CLASS = "composite.QSBSequence",
        ARGS = {
            {
                CLASS = "action.QSBPlayAnimation",
                OPTIONS = {animation = "attack11"},
            },
            {
                CLASS = "action.QSBAttackFinish"
            },
        },
    },
    {
        CLASS = "composite.QSBSequence",
        ARGS = {
            {
                CLASS = "action.QSBDelayTime",
                OPTIONS = {delay_frame = 34},
            },
            {
                CLASS = "action.QSBHitTarget",
            },
        },
    },
    {
    	CLASS = "composite.QSBSequence",
    	ARGS = {
    		{
    			CLASS = "action.QSBShowActor",
                OPTIONS = {is_attacker = true, turn_on = true, time = 1, revertable = true},
    		},
            {
                CLASS = "action.QSBBulletTime",
                OPTIONS = {turn_on = true, revertable = true},
            },
    		{
    			CLASS = "action.QSBDelayTime",
    			OPTIONS = {delay_frame = 34},
    		},
            {
                CLASS = "action.QSBBulletTime",
                OPTIONS = {turn_on = false},
            },
    		{
    			CLASS = "action.QSBShowActor",
                OPTIONS = {is_attacker = true, turn_on = false, time = 0.3},
    		},
    	},
	},
    {                   -- 竞技场黑屏
        CLASS = "composite.QSBSequence",
        ARGS = {
            {
                CLASS = "action.QSBShowActorArena",
                OPTIONS = {is_attacker = true, turn_on = true, time = 1, revertable = true},
            },
            {
                CLASS = "action.QSBBulletTimeArena",
                OPTIONS = {turn_on = true, revertable = true},
            },
            {
                CLASS = "action.QSBDelayTime",
                OPTIONS = {delay_frame = 34},
            },
            {
                CLASS = "action.QSBBulletTimeArena",
                OPTIONS = {turn_on = false},
            },
            {
                CLASS = "action.QSBShowActorArena",
                OPTIONS = {is_attacker = true, turn_on = false, time = 0.3},
            },
        },
    },
},
}

return ultra_power_infusion_troll_lokamil
