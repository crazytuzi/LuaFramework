
local guimei_fumo_1 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
			CLASS = "composite.QSBParallel",
			ARGS = {
				{
					CLASS = "action.QSBPlayAnimation",
					OPTIONS = {animation = "attack11"},
				},
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = false, effect_id = "pf_guimei02_attack11_1",haste = true},
				}, 
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 110},
						},
						{
							CLASS = "action.QSBHitTarget",
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 3.5},
						},
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "pf_guimei02_fumo_2", all_enemy = true},
						},
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "pf_guimei02_fumo_2x", all_enemy = true},
						},
					},
				},
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 133},
						},
						{
							CLASS = "action.QSBAttackFinish"
						},
					},
				},
			},
		},
        {
        	CLASS = "composite.QSBSequence",
        	ARGS = {
        		{
        			CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.4, revertable = true},
        		},
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = true, revertable = true},
                },
				{
					CLASS = "action.QSBSyncActorTimeGearForEffect",
				},
        		{
        			CLASS = "action.QSBDelayTime",
        			OPTIONS = {delay_frame = 110},
        		},
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = false},
                },
        		{
        			CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.3},
        		},
        	},
    	},
        {                   -- 竞技场黑屏
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.4, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true, revertable = true},
                },
				{
					CLASS = "action.QSBSyncActorTimeGearForEffect",
				},
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 110},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.3},
                },
            },
        },
    	{
    		CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 110},
                },
                {
                    CLASS = "action.QSBPlaySceneEffect",
                    OPTIONS = {effect_id = "pf_guimei02_attack11_1_2_2", pos  = {x = 640 , y = 360},ground_layer = true},
                },
        	},
    	},
        {
            CLASS = "action.QSBPlaySound",
            OPTIONS = {sound_id ="pf_guimei02_skill"},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 110},
                },
                {
                    CLASS = "action.QSBPlaySceneEffect",
                    OPTIONS = {effect_id = "pf_guimei02_attack11_1_3", pos  = {x = 640 , y = 360}, ground_layer = true},
                },
            },
        },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_frame = 0},
        --         },
        --         {
        --             CLASS = "action.QSBPlayEffect",
        --             OPTIONS = {is_hit_effect = false, effect_id = "devouring_plague_1_3"},
        --         }, 
        --     },
        -- },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 110},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = true, effect_id = "pf_guimei02_attack11_1_2"},
                }, 
            },
        },
    },
}

return guimei_fumo_1
