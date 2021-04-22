-- 技能 鬼虎飞扑
-- 扑向目标造成AOE伤害
--[[
	boss 铁龙
	ID:3306 副本3-4
	psf 2018-2-5
]]--
local dre = 150

function m_drection(isleft)
	if isleft then 
		dre = 150
	else
		dre = -150
	end
	return false
end


local zudui_boss_tielong_tiaoyue = 
{
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
		{
			CLASS = "action.QSBPlaySound",
		}, 
		{
            CLASS = "action.QSBMultipleTrap",
            OPTIONS = {trapId = "tielong_tiaoyue_circle",count = 1, pass_key = {"pos"}},
        },       
		{
			CLASS = "action.QSBPlayAnimation",
			OPTIONS = {animation = "attack15"},
			-- ARGS = 
			-- {
			-- 	{
			-- 		CLASS = "action.QSBHitTarget",
			-- 	},
			-- },
		},
		{
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 64 / 24 },
                },                   
                {
                    CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 15, duration = 0.25, count = 2,},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 63 / 24 },
                },                   
                {
					CLASS = "action.QSBHitTarget",
				},
            },
        },
		-- {
  --           CLASS = "composite.QSBSequence",
  --           OPTIONS = {forward_mode = true},
  --           ARGS = 
  --           {
  --               {
  --                   CLASS = "action.QSBArgsIsDirectionLeft",
  --                   OPTIONS = {is_attacker = true},
  --               },
  --               {
  --                   CLASS = "composite.QSBSelector",
  --                   ARGS = 
  --                   {	
		-- 				{
		--     				CLASS = "composite.QSBSequence",
		-- 					ARGS = 
		--     				{  				
		-- 						{
		-- 							CLASS = "action.QSBApplyBuff",
		-- 						    OPTIONS = {is_target = m_drection(true), buff_id = "mianyi_suoyou_zhuangtai"},
		-- 						},
		-- 					},
		-- 				},
		-- 				{
		--     				CLASS = "composite.QSBSequence",
		-- 					ARGS = 
		--     				{  				
		-- 						{
		-- 							CLASS = "action.QSBApplyBuff",
		-- 						    OPTIONS = {is_target = m_drection(false), buff_id = "mianyi_suoyou_zhuangtai"},
		-- 						},
		-- 					},
		-- 				},
  --               	},
  --               },
  --           },	
  --       },
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
                -- {
                --     CLASS = "action.QSBArgsPosition",
                --     OPTIONS = {is_attackee = true}, -- 生成传递参数 pos = {x = 100, y = 目标的y轴}
                -- },
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1 / 24 },
                },
				{
		            CLASS = "composite.QSBSequence",
		            OPTIONS = {forward_mode = true},
		            ARGS = 
		            {
		                {
		                    CLASS = "action.QSBArgsIsDirectionLeft",
		                    OPTIONS = {is_attacker = true},
		                },
		                {
		                    CLASS = "composite.QSBSelector",
		                    ARGS = 
		                    {	
		                    	{
				    				CLASS = "composite.QSBSequence",
									ARGS = 
				    				{
				    					{
						                    CLASS = "action.QSBArgsPosition",
						                    OPTIONS = {is_attackee = true}, -- 生成传递参数 pos = {x = 100, y = 目标的y轴}
						                },
    									{
						                    CLASS = "action.QSBDelayTime",
						                    OPTIONS = {delay_time = 46 / 24, pass_key = {"pos"}},
						                },
										{
											CLASS = "action.QSBCharge", --移动向目标位置（不打断动画）
											OPTIONS = {move_time = 0.5,offset = {x= 150,y=0}},
										},	
										{
						                    CLASS = "action.QSBDelayTime",
						                    OPTIONS = {delay_time = 10 / 24},
						                },
										{
											CLASS = "action.QSBRemoveBuff",
											OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
										},
										{
											CLASS = "action.QSBAttackFinish",
										},
									},
								},
								{
				    				CLASS = "composite.QSBSequence",
									ARGS = 
				    				{
				    					{
						                    CLASS = "action.QSBArgsPosition",
						                    OPTIONS = {is_attackee = true}, -- 生成传递参数 pos = {x = 100, y = 目标的y轴}
						                },
				    					{
						                    CLASS = "action.QSBDelayTime",
						                    OPTIONS = {delay_time = 46 / 24, pass_key = {"pos"}},
						                },
										{
											CLASS = "action.QSBCharge", --移动向目标位置（不打断动画）
											OPTIONS = {move_time = 0.5,offset = {x= -150,y=0}},
										},	
										{
						                    CLASS = "action.QSBDelayTime",
						                    OPTIONS = {delay_time = 10 / 24},
						                },
										{
											CLASS = "action.QSBRemoveBuff",
											OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
										},
										{
											CLASS = "action.QSBAttackFinish",
										},
									},
								},
							},
						},
					},
				},
			},
		},
	},
}

return zudui_boss_tielong_tiaoyue
