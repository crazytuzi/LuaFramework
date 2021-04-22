--小舞 流星人锤 合体技
--创建人：庞圣峰
--创建时间：2018-3-14
--脚本修改--刘铭18/06/25

local xiaowu_hetiji = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
    	{
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
		        {
		            CLASS = "action.QSBDelayTime",
		            OPTIONS = {delay_time = 0.3},
		        },
                {
					CLASS = "action.QSBPlayLoopEffect",
					OPTIONS = {effect_id = "xiaowu_attack11_1_1", is_hit_effect = false},
				},
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 4.2},
                },
                {
					CLASS = "action.QSBStopLoopEffect",
					OPTIONS = {effect_id = "xiaowu_attack11_1_1", is_hit_effect = false},
				},
            },
        },
    	-- {
     --        CLASS = "action.QSBForbidNormalAttack",    -- 让英雄不普攻
     --        OPTIONS = {forbid = true, revertable = true}
     --    },
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
		},
        -- {
        --     CLASS = "action.QSBStopMove",
        -- },
		{
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},   --不会打断特效
            ARGS = {
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.1, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.3},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                },

            },
        },
        {               --竞技场黑屏
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},   --不会打断特效
            ARGS = {
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.1, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.3},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.3},
                },
                {
				    CLASS = "composite.QSBParallel",
				    ARGS = 
				    {
						{
							CLASS = "action.QSBPlayAnimation",
							OPTIONS = {animation = "attack11", is_loop = true , is_keep_animation = true},
						},
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "xiaowu_hetiji_buff"}, --合体技吸血buff
						},
					},
				},
				{
					CLASS = "action.QSBActorKeepAnimation",
					OPTIONS = {is_keep_animation = true}
				},
				{
					CLASS = "action.QSBHitTimer",
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
            ARGS = 
			{
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 4.5},
                },
				{
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
							CLASS = "action.QSBActorKeepAnimation",
							OPTIONS = {is_keep_animation = false},
						},
						-- {
						-- 	CLASS = "action.QSBActorStand",
						-- },
					},
				},
				{
					CLASS = "composite.QSBParallel",
					ARGS = 
					{
						{
							CLASS = "action.QSBRemoveBuff",
							OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
						},
						{
							CLASS = "action.QSBRemoveBuff",
							OPTIONS = {buff_id = "xiaowu_hetiji_buff"},
						},
						-- {
				  --           CLASS = "action.QSBForbidNormalAttack",
				  --           OPTIONS = {forbid = false},
				  --       },
					},
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
                    OPTIONS = {delay_time = 0.3},
                },
				{
					CLASS = "action.QSBPlaySound",
					OPTIONS = {sound_id ="xiaowu_skill"},
				},
				{
					CLASS = "action.QSBPlaySound",
					OPTIONS = {is_loop = true},
				},  
				{
					CLASS = "composite.QSBParallel",
					ARGS = 
					{
						{
							CLASS = "composite.QSBSequence",
							ARGS = 
							{          
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 0.5},
								},
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {is_hit_effect = true,  delay_per_hit = 0.005, delay_all = 0.2},
								},
							},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = 
							{          
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 1},
								},
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {is_hit_effect = true,  delay_per_hit = 0.005, delay_all = 0.2},
								},
							},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = 
							{          
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 1.5},
								},
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {is_hit_effect = true,  delay_per_hit = 0.005, delay_all = 0.2},
								},
							},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = 
							{          
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 2 },
								},
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {is_hit_effect = true,  delay_per_hit = 0.005, delay_all = 0.2},
								},
							},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = 
							{          
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 2.5},
								},
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {is_hit_effect = true,  delay_per_hit = 0.005, delay_all = 0.2},
								},
							},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = 
							{          
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 3},
								},
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {is_hit_effect = true,  delay_per_hit = 0.005, delay_all = 0.2},
								},
							},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = 
							{          
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 3.5},
								},
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {is_hit_effect = true,  delay_per_hit = 0.005, delay_all = 0.2},
								},
							},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = 
							{          
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 4},
								},
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {is_hit_effect = true,  delay_per_hit = 0.005, delay_all = 0.2},
								},
								{
									CLASS = "action.QSBStopSound",
									OPTIONS = {sound_id ="xiaowu_lxrc_sf"},
								},
							},
						},
					},
				},									
            },
        },       
    },
}

return xiaowu_hetiji