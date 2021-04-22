
local prologue_tangsan_dazhao = {
   CLASS = "composite.QSBParallel",
    ARGS = {

		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBPlaySound",
					OPTIONS = {revertable = true,},
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			OPTIONS = {forward_mode = true},
			ARGS = {
				{
		            CLASS = "action.QSBLockTarget",     --锁定目标
		            OPTIONS = {is_lock_target = true, revertable = true},
		        },
		        {
		            CLASS = "action.QSBManualMode",     --进入手动模式
		            OPTIONS = {enter = true, revertable = true},
		        },
		        {
		            CLASS = "action.QSBStopMove",
		        },
		        {
		            CLASS = "action.QSBApplyBuff",      --加速
		            OPTIONS = {buff_id = "tongyongchongfeng_buff1"},
		        },
		        {
		            CLASS = "action.QSBPlayAnimation",
		            OPTIONS = {animation = "attack11_2", is_loop = true},       
		        }, 
		        {
		            CLASS = "action.QSBActorKeepAnimation",
		            OPTIONS = {is_keep_animation = true}
		        },
		        {
		            CLASS = "action.QSBMoveToTarget",
		            OPTIONS = {is_position = true, effect_id = "chengtangsan_attack11_2_1", effect_interval = 150, scale_actor_face = 1},
		        },
		  --       {
				-- 	CLASS = "composite.QSBParallel",
				-- 	ARGS = {
				-- 		{
		  --                   CLASS = "action.QSBPlayLoopEffect",
		  --                   OPTIONS = {follow_actor_animation = true, effect_id = "chengtangsan_attack11_2_1"},
		  --               },
		  --               {
		  --                   CLASS = "action.QSBPlayLoopEffect",
		  --                   OPTIONS = {follow_actor_animation = true, effect_id = "tangsan_chongfong_1"},
		  --               },
		  --               {
				-- 			CLASS = "composite.QSBSequence",
				-- 			ARGS = {
				-- 				{
				--                     CLASS = "action.QSBDelayTime",
				--                     OPTIONS = {delay_frame = 6 / 24 * 30},
				--                 },
				-- 				{
				--                     CLASS = "action.QSBPlayLoopEffect",
				--                     OPTIONS = {follow_actor_animation = true, effect_id = "chengtangsan_attack11_2_1"},
				--                 },
				-- 			},
				-- 		},
				-- 		{
				-- 			CLASS = "composite.QSBSequence",
				-- 			ARGS = {
				-- 				{
				--                     CLASS = "action.QSBDelayTime",
				--                     OPTIONS = {delay_frame = 12 / 24 * 30},
				--                 },
				-- 				{
				--                     CLASS = "action.QSBPlayLoopEffect",
				--                     OPTIONS = {follow_actor_animation = true, effect_id = "chengtangsan_attack11_2_1"},
				--                 },
				-- 			},
				-- 		},
				-- 		{
				-- 			CLASS = "composite.QSBSequence",
				-- 			ARGS = {
				-- 				{
				--                     CLASS = "action.QSBDelayTime",
				--                     OPTIONS = {delay_frame = 18 / 24 * 30},
				--                 },
				-- 				{
				--                     CLASS = "action.QSBPlayLoopEffect",
				--                     OPTIONS = {follow_actor_animation = true, effect_id = "chengtangsan_attack11_2_1_1"},
				--                 },
				-- 			},
				-- 		},
				-- 		{
				-- 			CLASS = "composite.QSBSequence",
				-- 			ARGS = {
				-- 				{
				--                     CLASS = "action.QSBDelayTime",
				--                     OPTIONS = {delay_frame = 24 / 24 * 30},
				--                 },
				-- 				{
				--                     CLASS = "action.QSBPlayLoopEffect",
				--                     OPTIONS = {follow_actor_animation = true, effect_id = "chengtangsan_attack11_2_1_2"},
				--                 },
				-- 			},
				-- 		},
				-- 	},
				-- },
		        -- {
		        --     CLASS = "composite.QSBParallel",
		        --     ARGS = {
		        --         {
		        --              CLASS = "composite.QSBSequence",
		        --              ARGS = {
		        --                 {
		        --                     CLASS = "action.QSBReloadAnimation", --重新载入动画
		        --                 },
		        --                 {
		        --                     CLASS = "action.QSBActorKeepAnimation", --保持某个动作
		        --                     OPTIONS = {is_keep_animation = false}
		        --                 },
		        --                 {
		        --                     CLASS = "action.QSBActorStand",
		        --                 },
		                        
		        --             },
		        --         },
		        --     },
		        -- },
		        {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 50000},
                },
		        {
		            CLASS = "action.QSBLockTarget",
		            OPTIONS = {is_lock_target = false},
		        },
		        {
		            CLASS = "action.QSBManualMode",
		            OPTIONS = {exit = true},
		        },
		        {
                    CLASS = "action.QSBAttackFinish"
                },
			},
		},
		-- {
		-- 	CLASS = "composite.QSBSequence",
		-- 	ARGS = {
		-- 		{
		-- 			CLASS = "action.QSBApplyBuff",
		-- 			OPTIONS = {buff_id = "tangsan_htc_dazhao_buff"},-- 上免疫控制buff
		-- 		},
		-- 		{
  --                   CLASS = "action.QSBDelayTime",
  --                   OPTIONS = {delay_time = 4.2},
  --               },
		-- 		{
		-- 			CLASS = "action.QSBRemoveBuff",
		-- 			OPTIONS = {buff_id = "tangsan_htc_dazhao_buff"},-- 下免疫控制buff
		-- 		},
		-- 	},
		-- },
    },
}

return prologue_tangsan_dazhao