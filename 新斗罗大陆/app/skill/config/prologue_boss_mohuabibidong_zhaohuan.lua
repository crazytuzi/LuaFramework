--序章比比东AI
--创建人：张义
--创建时间：2018年4月9日22:45:25
--修改时间：


local prologue_boss_mohuabibidong_zhaohuan = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false},
        },
        {
        	CLASS = "composite.QSBSequence",
            ARGS = 
            {
	        	{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 26 / 24 * 30},
	            },
	            {
	            	CLASS = "action.QSBSummonMonsters",
	            	OPTIONS = {wave = -1},
	            },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 34 / 24 * 30},
                },
                {
                    CLASS = "action.QSBSummonMonsters",
                    OPTIONS = {wave = -2},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 42 / 24 * 30},
                },
                {
                    CLASS = "action.QSBSummonMonsters",
                    OPTIONS = {wave = -3},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 50 / 24 * 30},
                },
                {
                    CLASS = "action.QSBSummonMonsters",
                    OPTIONS = {wave = -4},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 58 / 24 * 30},
                },
                {
                    CLASS = "action.QSBSummonMonsters",
                    OPTIONS = {wave = -5},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 66 / 24 * 30},
                },
                {
                    CLASS = "action.QSBSummonMonsters",
                    OPTIONS = {wave = -6},
                },
            },
        },
    },
}

return prologue_boss_mohuabibidong_zhaohuan