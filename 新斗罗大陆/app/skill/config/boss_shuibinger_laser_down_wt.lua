-- 技能 水冰儿冰霜激光(下)
-- 技能ID 50659
-- 闪现到下半屏,释放激光
--[[
	boss 水冰儿
	ID:3176 智慧试炼
	psf 2018-5-31
]]--

local boss_shuibinger_laser_down_wt = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "boss_test_attack_buff",no_cancel = true},
        },
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				---闪现到下面
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBActorStand",
								},
								{
									CLASS = "action.QSBActorFadeOut",
									OPTIONS = {duration = 0.15, revertable = true},
								},
							},
						},
						{
							CLASS = "action.QSBTeleportToAbsolutePosition",
							OPTIONS = {pos={x = 1200,y = 275},verify_flip = true},
						},
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {is_hit_effect = true},
								},
								{
									CLASS = "action.QSBActorFadeIn",
									OPTIONS = {duration = 0.15, revertable = true},
								},
							},
						},
					},
				},
				-- 放激光
				{
					CLASS = "composite.QSBParallel",
					ARGS = {
						{
							CLASS = "action.QSBPlaySound",
						},  
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_frame = 7},
								},
								{
									CLASS = "action.QSBPlayLoopEffect",
									OPTIONS = {effect_id = "shuibinger_attack11_hongkuang", is_hit_effect = false, follow_actor_animation = true},
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_frame = 60},
								},
								{
									CLASS = "action.QSBStopLoopEffect",
									 OPTIONS = {effect_id = "shuibinger_attack11_hongkuang"},
								},
							},
						},					
						{
							 CLASS = "composite.QSBSequence",
							 ARGS = {
								{
									CLASS = "action.QSBPlayAnimation",
									ARGS = {
										{
											CLASS = "composite.QSBParallel",
											ARGS = {
												{
													CLASS = "action.QSBPlayEffect",
													OPTIONS = {is_hit_effect = true},
												},
												{
													CLASS = "action.QSBPlayEffect",
													OPTIONS = {is_hit_effect = false},
												},
												{
													CLASS = "action.QSBHitTarget",
												},
											},
										},
									},
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
					},
				},
			},
		},

		
    },
}

return boss_shuibinger_laser_down_wt