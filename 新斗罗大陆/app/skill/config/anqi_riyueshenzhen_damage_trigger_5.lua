-- 技能 暗器 日月交辉引爆
-- 技能ID 40656~40660
-- 目标每层anqi_riyueshenzhen_ri_debuff和anqi_riyueshenzhen_yue_debuff造成一次hit
-- 每对日月BUFF额外造成百分比血量伤害
-- 3级日针的hit对无法移动目标伤害提升;5级月针hit附加anqi_riyueshenzhen_yueshi_debuff
--[[
	暗器 日月神针
	ID:1531
	psf 2020-6-2
]]--


local function HP_DAMAGE(num_min) 
	local hp_damge
	hp_damge ={
		CLASS = "action.QSBDecreaseHpByTargetProp",
		OPTIONS = {is_max_hp_percent = true, hp_percent = 0.25 * num_min, attacker_attack_limit = 12.75 * num_min,test = num_min},
	}
	return hp_damge
end

local function YUE_DAMAGE(num_ri) 
	local yue_damge ={}
	yue_damge = 
	{
		CLASS = "composite.QSBSequence",
		ARGS = 
		{
			--月针结算
			{
				CLASS = "action.QSBArgsConditionSelector",
				OPTIONS = {
					failed_select = 4,
					{expression = "target:buff_num:anqi_riyueshenzhen_yue_debuff=1", select = 1},
					{expression = "target:buff_num:anqi_riyueshenzhen_yue_debuff=2", select = 2},
					{expression = "target:buff_num:anqi_riyueshenzhen_yue_debuff>2", select = 3},
				}
			},
			{
				CLASS = "composite.QSBSelector",
				ARGS = {
					{
						CLASS = "composite.QSBSequence",
						ARGS = 
						{
							{
								CLASS = "action.QSBHitTarget",
							},
							{
								CLASS = "action.QSBApplyBuff",
								OPTIONS = {buff_id = "anqi_riyueshenzhen_yueshi_debuff", is_target = true},
							},
							{
								CLASS = "action.QSBArgsConditionSelector",
								OPTIONS = {
									failed_select = 2,
									{expression = "self:is_boss=true", select = 1},
								}
							},
							{
								CLASS = "composite.QSBSelector",
								ARGS = {
									HP_DAMAGE(math.min(num_ri,1)),
									HP_DAMAGE(math.min(num_ri,1)*2),
								},
							},
						},
					},
					{
						CLASS = "composite.QSBSequence",
						ARGS = 
						{
							{
								CLASS = "action.QSBHitTarget",
								OPTIONS = {damage_scale = 2},
							},
							{
								CLASS = "action.QSBApplyBuff",
								OPTIONS = {buff_id = {"anqi_riyueshenzhen_yueshi_debuff","anqi_riyueshenzhen_yueshi_debuff"}, is_target = true},
							},
							{
								CLASS = "action.QSBArgsConditionSelector",
								OPTIONS = {
									failed_select = 2,
									{expression = "self:is_boss=true", select = 1},
								}
							},
							{
								CLASS = "composite.QSBSelector",
								ARGS = {
									HP_DAMAGE(math.min(num_ri,2)),
									HP_DAMAGE(math.min(num_ri,2)*2),
								},
							},
						},
					},
					{
						CLASS = "composite.QSBSequence",
						ARGS = 
						{
							{
								CLASS = "action.QSBHitTarget",
								OPTIONS = {damage_scale = 3},
							},
							{
								CLASS = "action.QSBApplyBuff",
								OPTIONS = {buff_id = {"anqi_riyueshenzhen_yueshi_debuff","anqi_riyueshenzhen_yueshi_debuff","anqi_riyueshenzhen_yueshi_debuff"}, is_target = true},
							},
							{
								CLASS = "action.QSBArgsConditionSelector",
								OPTIONS = {
									failed_select = 2,
									{expression = "self:is_boss=true", select = 1},
								}
							},
							{
								CLASS = "composite.QSBSelector",
								ARGS = {
									HP_DAMAGE(math.min(num_ri,2)),
									HP_DAMAGE(math.min(num_ri,2)*2),
								},
							},
						},
					},
				},
			},
		},
	}
	return yue_damge
end

local anqi_riyueshenzhen_damage_trigger = 
{
	CLASS = "composite.QSBSequence",
	ARGS = 
	{
		{
			CLASS = "action.QSBRemoveBuffByStatus",	
			OPTIONS = {status = "riyueshenzhen_count"},
		},
		--日针结算
		{
			CLASS = "action.QSBArgsConditionSelector",
			OPTIONS = {
				failed_select = 4,
				{expression = "target:buff_num:anqi_riyueshenzhen_ri_debuff=1", select = 1},
				{expression = "target:buff_num:anqi_riyueshenzhen_ri_debuff=2", select = 2},
				{expression = "target:buff_num:anqi_riyueshenzhen_ri_debuff>2", select = 3},
			}
		},
		{
			CLASS = "composite.QSBSelector",
			ARGS = {
				{
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
							CLASS = "action.QSBArgsConditionSelector",
							OPTIONS = {
								failed_select = 2,
								{expression = "target:is_can_control_move", select = 1},
							}
						},
						{
							CLASS = "composite.QSBSelector",
							ARGS = {
								{
									CLASS = "action.QSBHitTarget",
								},
								{
									CLASS = "action.QSBHitTarget",
									OPTIONS = {damage_scale = 1.5,property_promotion = { critical_chance = 0.1}},
								},
							},
						},
						YUE_DAMAGE(1), 
					},
				},
				{
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
							CLASS = "action.QSBArgsConditionSelector",
							OPTIONS = {
								failed_select = 2,
								{expression = "target:is_can_control_move", select = 1},
							}
						},
						{
							CLASS = "composite.QSBSelector",
							ARGS = {
								{
									CLASS = "action.QSBHitTarget",
									OPTIONS = {damage_scale = 2},
								},
								{
									CLASS = "action.QSBHitTarget",
									OPTIONS = {damage_scale = 3,property_promotion = { critical_chance = 0.1}},
								},
							},
						},
						YUE_DAMAGE(2), 
					},
				},
				{
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
							CLASS = "action.QSBArgsConditionSelector",
							OPTIONS = {
								failed_select = 2,
								{expression = "target:is_can_control_move", select = 1},
							}
						},
						{
							CLASS = "composite.QSBSelector",
							ARGS = {
								{
									CLASS = "action.QSBHitTarget",
									OPTIONS = {damage_scale = 3},
								},
								{
									CLASS = "action.QSBHitTarget",
									OPTIONS = {damage_scale = 4.5,property_promotion = { critical_chance = 0.1}},
								},
							},
						},
						YUE_DAMAGE(3), 
					},
				},
				YUE_DAMAGE(0), 
			},
		},
		{
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {effect_id = "riyueshenzhen_attack01_3", is_hit_effect = true},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return anqi_riyueshenzhen_damage_trigger

