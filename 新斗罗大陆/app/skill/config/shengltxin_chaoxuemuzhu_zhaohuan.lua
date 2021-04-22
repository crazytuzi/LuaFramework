-- 技能 BOSS巢穴母蛛 召唤魔蛛
-- 技能ID 950836
-- 召唤-1
--[[
	boss 巢穴母蛛
	ID:3681 升灵台
	psf 2018-7-5
]]--

local boss_chaoxuemuzhu_zhaohuan1= {
    CLASS = "composite.QSBParallel",
    ARGS = {


    	{
    		CLASS = "composite.QSBSequence",
    		ARGS = {
                    {
                        CLASS = "action.QSBApplyBuff",
                        OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"}
                    },

    		    	{
    					CLASS = "action.QSBPlayAnimation",
    					OPTIONS = {animation = "attack13"},
    				},
    				{
						CLASS = "action.QSBSummonMonsters",
						OPTIONS = {wave = -1,attacker_level = true},
					},
						
					{
						CLASS = "action.QSBAttackFinish",
					},

                    {
                        CLASS = "action.QSBRemoveBuff",
                        OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"}
                    },


    		},
    	},
    	

    	{
    		CLASS = "action.QSBPlayEffect",
    		OPTIONS = { effect_id = "shenglt_dxmz_attack02_1"},
    	},
    	

		
		
    },

}

return boss_chaoxuemuzhu_zhaohuan1