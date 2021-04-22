-- 技能 金刚狒狒强化攻击
-- 技能ID 53276
--[[
	金刚狒狒 4101
	升灵台
	psf 2020-4-13
]]--

local shenglt_jingff_dazhao = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack011", is_loop = true},
                },
                {
                    CLASS = "action.QSBActorKeepAnimation",
                    OPTIONS = {is_keep_animation = true},
                },
            },
        },
        {
			CLASS = "action.QSBTriggerSkill",
			OPTIONS = {skill_id = 53277, target_type = "skill_target", wait_finish = false},
		},
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 18},
                },
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "shenglt_jingangfeifei_attack11_1", is_hit_effect = false, haste = true},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 108},
                },
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "shenglt_jingangfeifei_attack11_1", is_hit_effect = false, haste = true},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 198},
                },
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "shenglt_jingangfeifei_attack11_1", is_hit_effect = false, haste = true},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 270},
                },
                {
                    CLASS = "action.QSBActorKeepAnimation",
                    OPTIONS = {is_keep_animation = false},
                },
				{
					CLASS = "action.QSBAttackFinish",
				},
            },
        },
		--1
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 21},
                },
				{
					CLASS = "action.QSBHitTarget",
					OPTIONS = {multiple_area_scale = 0.75,damage_scale = 0.1},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 41},
                },
				{
					CLASS = "action.QSBHitTarget",
					OPTIONS = {multiple_area_scale = 1,damage_scale = 0.1},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 71},
                },
				{
					CLASS = "action.QSBHitTarget",
					OPTIONS = {multiple_area_scale = 1.25,damage_scale = 1},
				},
            },
        },
		--2
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 111},
                },
				{
					CLASS = "action.QSBHitTarget",
					OPTIONS = {multiple_area_scale = 0.75,damage_scale = 0.5},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 131},
                },
				{
					CLASS = "action.QSBHitTarget",
					OPTIONS = {multiple_area_scale = 1,damage_scale = 0.5},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 161},
                },
				{
					CLASS = "action.QSBHitTarget",
					OPTIONS = {multiple_area_scale = 1.25,damage_scale = 2},
				},
            },
        },
		--3
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 201},
                },
				{
					CLASS = "action.QSBHitTarget",
					OPTIONS = {multiple_area_scale = 0.75,damage_scale = 1},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 221},
                },
				{
					CLASS = "action.QSBHitTarget",
					OPTIONS = {multiple_area_scale = 1,damage_scale = 1},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 251},
                },
				{
					CLASS = "action.QSBHitTarget",
					OPTIONS = {multiple_area_scale = 1.25,damage_scale = 3},
				},
            },
        },

    },
}

return shenglt_jingff_dazhao