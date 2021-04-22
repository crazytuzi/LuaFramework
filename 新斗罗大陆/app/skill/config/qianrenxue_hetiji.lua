-- 技能 千仞雪大招 万阳凌天 合体技
-- 技能ID 208
-- 飞到目标身边 群体晕眩 飞回去
--[[
	hero 千仞雪
	ID:1027 
	psf 2018-4-27
]]--

local qianrenxue_hetiji = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},   --不会打断特效
            ARGS = {
				{
					CLASS = "action.QSBLockTarget",
					OPTIONS = { is_lock_target = true}
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
                    OPTIONS = {delay_time = 56 / 30},
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
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 56 / 30},
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
            CLASS = "action.QSBPlaySound"
        },
		{
			CLASS = "composite.QSBParallel",
			ARGS = {
				{
					CLASS = "composite.QSBSequence",
					 ARGS = {
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBManualMode",
									OPTIONS = {enter = true, revertable = true},
								},
								{
									CLASS = "action.QSBActorStand",
								},
								{
									CLASS = "action.QSBPlayAnimation",
									OPTIONS = {animation = "attack11_1"},
								},
								{
									CLASS = "composite.QSBSequence",
									ARGS = {
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_time = 1.9},
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
							ARGS = {
								{
									CLASS = "action.QSBActorFadeIn",
									OPTIONS = {duration = 0.15, revertable = true},
								},
								{
									CLASS = "action.QSBPlayAnimation",
									OPTIONS = {animation = "attack11_2"},
								},
								{
									CLASS = "composite.QSBSequence",
									ARGS = {
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
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_frame = 28},
										},
										{
											CLASS = "action.QSBPlayAnimation",
											OPTIONS = {animation = "attack11_3"},
										},
									},
								},
							},
						},
						{
							CLASS = "action.QSBLockTarget",
							OPTIONS = { is_lock_target = false}
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
							CLASS = "action.QSBArgsPosition",
							OPTIONS = {is_attacker = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 3.35, pass_key = {"pos"}},
						},
						{
						  CLASS = "action.QSBCharge",
						  OPTIONS = {move_time = 0.01}
						},
					},
				},
			},
		},
    },
}

return qianrenxue_hetiji