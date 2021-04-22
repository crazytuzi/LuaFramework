-- 技能 翠魔鸟王大招
-- 技能ID 35092~96
-- 鲜血仪式：召唤翠魔图腾，提升全体友方魂师25%攻击，并激发饮血渴望：魂师攻击将消耗伤害量10%的图腾储量，等额治疗全体友方；魂师治疗可补充治疗量20%的图腾储量。 
--（单次治疗或储量提升，不超过魂灵攻击的100%）
-- 持续施法，直至图腾储量耗尽，最多持续15秒。
--[[
	hunling 翠魔鸟王
	ID:2010
	psf 2019-10-8
]]--

local hl_cuimoniaowang_dazhao = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},   --不会打断特效
            ARGS = 
            {
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
                    OPTIONS = {delay_frame = 58},
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
                    OPTIONS = {delay_frame = 58},
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
			CLASS = "action.QSBPauseCooldown",
			OPTIONS = {resume = false,revertable = true},
		},
		--------------动作
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
					CLASS = "action.QSBPlayAnimation",
					OPTIONS = {animation = "attack11_1",no_stand = true},
				},
                {
					CLASS = "action.QSBPlayAnimation",
					OPTIONS = {animation = "attack11_2", is_loop = true , is_keep_animation = true,no_stand = true},
				},
				{
					CLASS = "action.QSBActorKeepAnimation",
					OPTIONS = {is_keep_animation = true}
				},
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 45},
                },
				{
                    CLASS = "action.QSBWaitSaveTreatClear",
					OPTIONS = {buff_id = "hl_cuimoniaowang_buff_2"},--
                },
				{
					CLASS = "composite.QSBParallel",
					ARGS = {
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "hl_cuimoniaowang_attack11_1_2",is_hit_effect = false, haste = true},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "hl_cuimoniaowang_attack11_2_2",is_hit_effect = false, haste = true},
						},
					},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "hl_cuimoniaowang_dazhao_buff1_2"},--
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "hl_cuimoniaowang_dazhao_buff2_2"},--
				},
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 10},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "hl_cuimoniaowang_dazhao_buff"},--
				},
				{
					CLASS = "composite.QSBParallel",
					ARGS = {
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "hl_cuimoniaowang_finish_buff",teammate_and_self = true},
						},
						{
							CLASS = "action.QSBShowStorage",
							OPTIONS = {exit = true},
						},
						{
							CLASS = "action.QSBActorKeepAnimation",
							OPTIONS = {is_keep_animation = false},
						},
						{
							CLASS = "action.QSBPlayAnimation",
							OPTIONS = {animation = "attack11_3", no_stand = true},
						},
					},
				},
				{
					CLASS = "action.QSBPauseCooldown",
					OPTIONS = {resume = true},
				},
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 15},
                },
				{
					CLASS = "action.QSBArgsConditionSelector",
					OPTIONS = {
						failed_select = 2,
						{expression = "self:has_buff:hl_cuimoniaowang_dazhao_buff1_2=1", select = 1},
					}
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = {
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								{
									CLASS = "composite.QSBParallel",
									ARGS = {
										{
											CLASS = "action.QSBPlayEffect",
											OPTIONS = {effect_id = "hl_cuimoniaowang_attack11_1_2",is_hit_effect = false, haste = true},
										},
										{
											CLASS = "action.QSBPlayEffect",
											OPTIONS = {effect_id = "hl_cuimoniaowang_attack11_2_2",is_hit_effect = false, haste = true},
										},
									},
								},
								{
									CLASS = "action.QSBRemoveBuff",
									OPTIONS = {buff_id = "hl_cuimoniaowang_dazhao_buff1_2"},--
								},
								{
									CLASS = "action.QSBRemoveBuff",
									OPTIONS = {buff_id = "hl_cuimoniaowang_dazhao_buff2_2"},--
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_frame = 10},
								},
								{
									CLASS = "action.QSBRemoveBuff",
									OPTIONS = {buff_id = "hl_cuimoniaowang_dazhao_buff"},--
								},
								{
									CLASS = "composite.QSBParallel",
									ARGS = {
										{
											CLASS = "action.QSBApplyBuff",
											OPTIONS = {buff_id = "hl_cuimoniaowang_finish_buff",teammate_and_self = true},
										},
										{
											CLASS = "action.QSBShowStorage",
											OPTIONS = {exit = true},
										},
										{
											CLASS = "action.QSBActorKeepAnimation",
											OPTIONS = {is_keep_animation = false},
										},
										{
											CLASS = "action.QSBPlayAnimation",
											OPTIONS = {animation = "attack11_3", no_stand = true},
										},
									},
								},
							},
						},
					},
				},
				{
					CLASS = "action.QSBPauseCooldown",
					OPTIONS = {resume = true},
				},
				{
					CLASS = "action.QSBAttackFinish",
				},
            },
        },
		--------------
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 3},
                },
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "hl_cuimoniaowang_attack11_1_1",is_hit_effect = false, haste = true},
				},
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 20},
                },
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "hl_cuimoniaowang_attack11_2_1",is_hit_effect = false, haste = true},
				},
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 20},
                },
				{
                    CLASS = "action.QSBArgsIsDirectionLeft",
                    OPTIONS = {is_attacker = true},
                },
				{
					CLASS = "composite.QSBSelector",
					ARGS = {
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBTrap", 
									OPTIONS = 
									{ 
										trapId = "hl_cuimoniaowang_tuteng_l",
										args = 
										{
											{delay_time = 0 , relative_pos = { x = 0, y = 0}} ,
										},
									},
								},
								{
									CLASS = "action.QSBShowStorage",
									OPTIONS = {enter = true, limit = 40,offset={x=-18,y=10},buff_id="hl_cuimoniaowang_buff_2",revertable = true},
								},
							},
						},
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBTrap", 
									OPTIONS = 
									{ 
										trapId = "hl_cuimoniaowang_tuteng_r",
										args = 
										{
											{delay_time = 0 , relative_pos = { x = 0, y = 0}} ,
										},
									},
								},
								{
									CLASS = "action.QSBShowStorage",
									OPTIONS = {enter = true, limit = 40,offset={x=18,y=10},buff_id="hl_cuimoniaowang_buff_2",revertable = true},
								},
							},
						},
					},
				},
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "hl_cuimoniaowang_dazhao_buff1_2"},--
				},
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "hl_cuimoniaowang_dazhao_buff2_2"},--
				},
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 2.2},
                },
				{
					CLASS = "action.QSBArgsConditionSelector",
					OPTIONS = {
						failed_select = 2,
						{expression = "self:has_buff:hl_cuimoniaowang_dazhao_buff1_2=1", select = 1},
					}
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = {
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "hl_cuimoniaowang_dazhao_buff"},--
						},
					},
				},
            },
        },
		
    },
}

return hl_cuimoniaowang_dazhao