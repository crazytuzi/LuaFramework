--BOSS人面魔蛛小怪召唤自杀
--召唤-1，然后自杀
--创建人：庞圣峰
--创建时间：2018-1-4

local boss_renmianmozhu_xiaoguaizhaohuanzisha = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
        -- {
            -- CLASS = "action.QSBPlayEffect",
            -- OPTIONS = {is_hit_effect = false},
        -- },
        {
        	CLASS = "composite.QSBSequence",
            ARGS = 
            {
	        	{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 1.6},
	            },
	            {
	            	CLASS = "action.QSBSummonMonsters",
	            	OPTIONS = {wave = -2},
	            },
				{
					CLASS = "action.QSBSuicide", 
				},
            },
        },
		
	},
}

return boss_renmianmozhu_xiaoguaizhaohuanzisha