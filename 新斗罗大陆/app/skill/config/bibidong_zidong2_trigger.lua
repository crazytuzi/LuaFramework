-- 技能 比比东自动1触发反击
-- 技能ID 399
-- 反击
--[[
	魂师 比比东
	ID:1026 
	psf 2019-7-8
]]--

local bibidong_zidong2_trigger = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
			CLASS = "action.QSBArgsIsTeammate",
		},
		{
			CLASS = "composite.QSBSelector",
			ARGS = {			
				{
					CLASS = "composite.QSBParallel",
					ARGS = 
					{
						{
							CLASS = "action.QSBArgsSelectTarget",
							OPTIONS = {under_status = "" , change_all_node_target = true},
						},
						{
							CLASS = "action.QSBActorStatus",
							OPTIONS = 
							{
								{ "target:hp_percent>0.5","target:remove_buff:bibidong_hp_lower_50"},
							},
						},
						{
							CLASS = "action.QSBBullet",	
							OPTIONS = {start_pos = {x = 175,y = 75},},
						},
						{
							CLASS = "action.QSBBullet",	
							OPTIONS = {start_pos = {x = 185,y = 85}},
						},
						{
							CLASS = "action.QSBActorStatus",
							OPTIONS = 
							{
								{ "target:hp_percent<0.55","target:apply_buff:bibidong_hp_lower_50"},
							},
						},
						{
							CLASS = "action.QSBAttackFinish",
						},
					},
				},
				{
					CLASS = "composite.QSBParallel",
					ARGS = 
					{
						{
							CLASS = "action.QSBActorStatus",
							OPTIONS = 
							{
								{ "target:hp_percent>0.5","target:remove_buff:bibidong_hp_lower_50"},
							},
						},
						{ 
							CLASS = "action.QSBBullet",	
							OPTIONS = {start_pos = {x = 175,y = 75}},
						},
						{
							CLASS = "action.QSBBullet",	
							OPTIONS = {start_pos = {x = 185,y = 85}},
						},
						{
							CLASS = "action.QSBActorStatus",
							OPTIONS = 
							{
								{ "target:hp_percent<0.55","target:apply_buff:bibidong_hp_lower_50"},
							},
						},
						{
							CLASS = "action.QSBAttackFinish",
						},
					},
				},
			},
		},	
		{
			CLASS = "action.QSBAttackFinish",
		},
    },
}


return bibidong_zidong2_trigger

