-- 技能 蓄力治疗
-- 技能ID 53302
--[[
	六瓣仙兰
	ID:4116 
	升灵台
	psf 2020-4-13
]]--

local shenglt_liubanxianlan_pugong = {
	CLASS = "composite.QSBParallel",
	ARGS = {
		{
			CLASS = "action.QSBPlayAnimation",
			OPTIONS = {animation = "walk", is_loop = true},
		},
		{
			CLASS = "action.QSBActorKeepAnimation",
			OPTIONS = {is_keep_animation = true},
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
					CLASS = "action.QSBArgsIsTeammate",
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = 
					{
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {is_hit_effect = false},
								},
								{
									CLASS = "action.QSBPlayAnimation",
									OPTIONS = {animation = "attack12"},
									ARGS = {
										{
											CLASS = "composite.QSBParallel",
											ARGS = {  
												{
													CLASS = "action.QSBPlayEffect",
													OPTIONS = {is_hit_effect = true},
												},
												{
													CLASS = "action.QSBHitTarget",
													OPTIONS = {is_auto_choose_target = false},
												},
											},
										},
									},
								},
							},
						},
						{
							CLASS = "action.QSBPlayAnimation",
							OPTIONS = {animation = "attack01"},
							ARGS = {
								{
									CLASS = "composite.QSBParallel",
									ARGS = {  
										{
											CLASS = "action.QSBActorStatus",
											OPTIONS = 
											{
												{ "self:hp_percent>0", "self:increase_hp:maxHp*1"},
											}
										},
									},
								},
							},
						},
					},
				},
				{
					CLASS = "action.QSBActorKeepAnimation",
					OPTIONS = {is_keep_animation = false},
				},
				{
					CLASS = "action.QSBAttackFinish"
				},
            },
        },
	},	
}

return shenglt_liubanxianlan_pugong