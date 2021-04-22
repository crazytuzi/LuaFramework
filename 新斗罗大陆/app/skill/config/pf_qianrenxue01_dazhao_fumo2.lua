-- 技能 千仞雪大招 万阳凌天
-- 技能ID 200
-- 击退闪砸地
--[[
	hero 千仞雪
	ID:1027 
	psf 2018-4-27
]]--

local pf_qianrenxue_dazhao_fumo2 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},   --不会打断特效
            ARGS = 
            {
				{
					CLASS = "action.QSBLockTarget",
					OPTIONS = { is_lock_target = true,revertable = true}
				},
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 2.5},
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
            ARGS = 
            {
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 2.5},
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
                    OPTIONS = {delay_frame = 15},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_qianrenxue_attack11_1", is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 75},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_qianrenxue_attack11_3", is_hit_effect = false},
                },   
            },
        },
        {
			CLASS = "action.QSBPlaySound",
			OPTIONS = {sound_id ="qianrenxue_skill"},
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
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
						},
						{
							CLASS = "composite.QSBParallel",
							ARGS = 
							{
								{
									CLASS = "action.QSBManualMode",
									OPTIONS = {enter = true, revertable = true},
								},
								{
									CLASS = "action.QSBActorStand",
								},
								{
									CLASS = "action.QSBPlaySound",
								},
								{
									CLASS = "action.QSBPlayAnimation",
									OPTIONS = {animation = "attack11",no_stand = true},
								},
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {effect_id = "pf_qianrenxue_attack02_1", is_hit_effect = false},
								},
								{
									CLASS = "composite.QSBSequence",
									ARGS = 
									{
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_frame = 16},
										},
										{
											CLASS = "action.QSBDragActor",
											OPTIONS = {pos_type = "self" , pos = {x = 300,y = 0} , duration = 0.4, flip_with_actor = true },
										},
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_frame = 50},
										},
										{
											CLASS = "action.QSBActorFadeOut",
											OPTIONS = {duration = 0.09, revertable = true},
										},
									},
								},
							},
						},
						{
						  CLASS = "action.QSBTeleportToTargetBehind",
						  OPTIONS = {verify_flip = true},
						},
						{
							CLASS = "composite.QSBParallel",
							ARGS = 
							{
								{
									CLASS = "action.QSBActorFadeIn",
									OPTIONS = {duration = 0.15, revertable = true},
								},
								-- {
								-- 	CLASS = "action.QSBPlaySound",
								-- 	OPTIONS = {sound_id ="qianrenxue_wylt_sj"},
								-- },
								{
									CLASS = "action.QSBPlayAnimation",
									OPTIONS = {animation = "attack11_2",no_stand = true},
								},
								{
									CLASS = "action.QSBPlaySound",
									OPTIONS = {sound_id ="qianrenxue_attack11_4_sf"},
								},
								{
									CLASS = "composite.QSBSequence",
									ARGS = 
									{
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_frame = 4},
										},
										{
											CLASS = "action.QSBShakeScreen",
										},
										{
											CLASS = "action.QSBHitTarget",
										},
										------千仞雪附魔触发治疗陷阱
										{
											CLASS = "action.QSBApplyBuff",
											OPTIONS = {is_target = false, buff_id = "fumo_qianrenxue_mark"},
										},
										{
											CLASS = "action.QSBTrap", 
											OPTIONS = 
											{ 
												trapId = "qianrenxue_dazhao_treat_trap_fumo2",
												args = 
												{
													{delay_time = 0 , relative_pos = { x = 0, y = 0}} ,
												},
											},
										},
										-------------
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_frame = 28},
										},
										{
											CLASS = "action.QSBPlayAnimation",
											OPTIONS = {animation = "attack11_3",no_stand = true},
										},
										-- {
										-- 	CLASS = "action.QSBPlayAnimation",
										-- 	OPTIONS = {animation = "attack14_3",no_stand = true},
										-- },
										{
											CLASS = "action.QSBRemoveBuff",
											OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
										},
										{
											CLASS = "action.QSBLockTarget",
											OPTIONS = { is_lock_target = false}
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
				-- {
					-- CLASS = "composite.QSBSequence",
					 -- ARGS = {
						-- {
							-- CLASS = "action.QSBArgsPosition",
							-- OPTIONS = {is_attacker = true},
						-- },
						-- {
							-- CLASS = "action.QSBDelayTime",
							-- OPTIONS = {delay_time = 3.35, pass_key = {"pos"}},
						-- },
						-- {
						  -- CLASS = "action.QSBCharge",
						  -- OPTIONS = {move_time = 0.01}
						-- },
					-- },
				-- },
			},
		},
    },
}

return pf_qianrenxue_dazhao_fumo2