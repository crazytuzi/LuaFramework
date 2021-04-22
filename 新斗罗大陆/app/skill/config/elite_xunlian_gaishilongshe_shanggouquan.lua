-- 技能 BOSS盖世龙蛇上勾拳
-- ID 50310
-- 两下攻击,一下拉近(触发50415),一下击飞
--[[
	boss 盖世龙蛇
	ID:3246 副本2-4
	psf 2018-4-4
]]--

local elite_xunlian_gaishilongshe_shanggouquan = 
{
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
		},
		{
			CLASS = "action.QSBPlaySound",
		}, 
		{
			CLASS = "composite.QSBSequence",
			OPTIONS = {revertable = true},
			ARGS = 
			{		
				{
					CLASS = "action.QSBPlayAnimation",
				},
				{
					CLASS = "action.QSBAttackFinish",
				},
			},	
		},
		{
			CLASS = "composite.QSBSequence",
			OPTIONS = {revertable = true},
			ARGS = 
			{		
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 20},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
                {
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
				},
            },
        },
		-- {
		-- 	CLASS = "composite.QSBSequence",
		-- 	OPTIONS = {revertable = true},
		-- 	ARGS = 
		-- 	{		
		-- 		{
  --                   CLASS = "action.QSBDelayTime",
  --                   OPTIONS = {delay_frame = 18},
  --               },
		-- 		{
  --                   CLASS = "action.QSBTriggerSkill",
		-- 			OPTIONS = { skill_id = 50415,wait_finish = true},
  --               }, 
		-- 		{
  --                   CLASS = "action.QSBDelayTime",
  --                   OPTIONS = {delay_frame = 16},
  --               },
				-- {
    --                 CLASS = "action.QSBHitTarget",
    --             },
				-- {
				-- 	CLASS = "action.QSBRemoveBuff",
				-- 	OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
				-- },
		-- 	},	
		-- },
	},
}

return elite_xunlian_gaishilongshe_shanggouquan
