local pf_ssdaimubai01_zidong2_ex = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBArgsIsUnderStatus",
            OPTIONS = {is_attacker = true,status = "zsdmb_bs"},
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS =
                    {
                        {
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = false, effect_id = "pf_ssdaimubai01_attack13_1"},
						},
						{
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack13"},
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS =
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 20 / 30 },
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "pf_ssdaimubai01_attack13_2"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 41 / 30 },
                                },
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 3, duration = 0.4, count = 3,},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 38 / 30},
                                },                              
                                {
                                    CLASS = "action.QSBArgsIsDirectionLeft",
                                    OPTIONS = {is_attacker = true},
                                },
                                {
                                    CLASS = "composite.QSBSelector",
                                    ARGS = 
                                    {   
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "composite.QSBParallel",
                                                    ARGS =
                                                    {
                                                        {
                                                            CLASS = "action.QSBTrap",  
                                                            OPTIONS = 
                                                            { 
                                                                trapId = "pf_ssdaimubai01_lgb2",
                                                                args = 
                                                                {
                                                                    {delay_time = 0 / 30 , relative_pos = { x = -200, y = 0}} ,
                                                                    {delay_time = 4 / 30 , relative_pos = { x = -300, y = 85}} ,
                                                                    {delay_time = 4 / 30 , relative_pos = { x = -300, y = -85}} ,
                                                                    {delay_time = 4 / 30, relative_pos = { x = -375, y = 0}} ,
                                                                    {delay_time = 8 / 30 , relative_pos = { x = -475, y = 135}} ,
                                                                    {delay_time = 8 / 30 , relative_pos = { x = -475, y = -135}} ,
                                                                    {delay_time = 8 / 30 , relative_pos = { x = -550, y = 0}} ,
                                                                    -- {delay_time = 5 / 30, relative_pos = { x = 240, y = 120}} ,
                                                                    -- {delay_time = 3 / 30, relative_pos = { x = -240, y = 120}},
                                                                },
                                                            },
                                                        },
                                                        {
                                                            CLASS = "action.QSBTrap",  
                                                            OPTIONS = 
                                                            { 
                                                                trapId = "pf_ssdaimubai01_lgbx2",
                                                                args = 
                                                                {
                                                                    {delay_time = 0 / 30 , relative_pos = { x = -200, y = 0}} ,
                                                                    {delay_time = 4 / 30 , relative_pos = { x = -300, y = 85}} ,
                                                                    {delay_time = 4 / 30 , relative_pos = { x = -300, y = -85}} ,
                                                                    {delay_time = 4 / 30, relative_pos = { x = -375, y = 0}} ,
                                                                    {delay_time = 8 / 30 , relative_pos = { x = -475, y = 135}} ,
                                                                    {delay_time = 8 / 30 , relative_pos = { x = -475, y = -135}} ,
                                                                    {delay_time = 8 / 30 , relative_pos = { x = -550, y = 0}} ,
                                                                    -- {delay_time = 5 / 30, relative_pos = { x = 240, y = 120}} ,
                                                                    -- {delay_time = 3 / 30, relative_pos = { x = -240, y = 120}},
                                                                },
                                                            },
                                                        },
                                                    },
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "composite.QSBParallel",
                                                    ARGS =
                                                    {
                                                        {
                                                            CLASS = "action.QSBTrap",  
                                                            OPTIONS = 
                                                            { 
                                                                trapId = "pf_ssdaimubai01_lgb2",
                                                                args = 
                                                                {
                                                                    {delay_time = 0 / 30 , relative_pos = { x = 200, y = 0}} ,
                                                                    {delay_time = 4 / 30 , relative_pos = { x = 300, y = 85}} ,
                                                                    {delay_time = 4 / 30 , relative_pos = { x = 300, y = -85}} ,
                                                                    {delay_time = 4 / 30, relative_pos = { x = 375, y = 0}} ,
                                                                    {delay_time = 8 / 30 , relative_pos = { x = 475, y = 135}} ,
                                                                    {delay_time = 8 / 30 , relative_pos = { x = 475, y = -135}} ,
                                                                    {delay_time = 8 / 30 , relative_pos = { x = 550, y = 0}} ,
                                                                    -- {delay_time = 5 / 30, relative_pos = { x = 240, y = 120}} ,
                                                                    -- {delay_time = 3 / 30, relative_pos = { x = -240, y = 120}},
                                                                },
                                                            },
                                                        },
                                                        {
                                                            CLASS = "action.QSBTrap",  
                                                            OPTIONS = 
                                                            { 
                                                                trapId = "pf_ssdaimubai01_lgbx2",
                                                                args = 
                                                                {
                                                                    {delay_time = 0 / 30 , relative_pos = { x = 200, y = 0}} ,
                                                                    {delay_time = 4 / 30 , relative_pos = { x = 300, y = 85}} ,
                                                                    {delay_time = 4 / 30 , relative_pos = { x = 300, y = -85}} ,
                                                                    {delay_time = 4 / 30, relative_pos = { x = 375, y = 0}} ,
                                                                    {delay_time = 8 / 30 , relative_pos = { x = 475, y = 135}} ,
                                                                    {delay_time = 8 / 30 , relative_pos = { x = 475, y = -135}} ,
                                                                    {delay_time = 8 / 30 , relative_pos = { x = 550, y = 0}} ,
                                                                    -- {delay_time = 5 / 30, relative_pos = { x = 240, y = 120}} ,
                                                                    -- {delay_time = 3 / 30, relative_pos = { x = -240, y = 120}},
                                                                },
                                                            },
                                                        },
                                                    },
                                                },
                                            },
                                        },
                                    },
                                },
                            },
                        },                        
                        -- {
                        --     CLASS = "action.QSBPlaySound",
                        -- },
                    },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS =
                    {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack13"},
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS =
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 1 / 30 },
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "pf_ssdaimubai01_attack13_1"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS =
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 20 / 30 },
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "pf_ssdaimubai01_attack13_2"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 41 / 30 },
                                },
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 3, duration = 0.4, count = 3,},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 38 / 30},
                                },
                                {
                                    CLASS = "action.QSBArgsIsDirectionLeft",
                                    OPTIONS = {is_attacker = true},
                                },
                                {
                                    CLASS = "composite.QSBSelector",
                                    ARGS = 
                                    {   
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "composite.QSBParallel",
                                                    ARGS =
                                                    {
                                                        {
                                                            CLASS = "action.QSBTrap",  
                                                            OPTIONS = 
                                                            { 
                                                                trapId = "pf_ssdaimubai01_lgb2",
                                                                args = 
                                                                {
                                                                    {delay_time = 0 / 30 , relative_pos = { x = -200, y = 0}} ,
                                                                    {delay_time = 4 / 30, relative_pos = { x = -375, y = 0}} ,
                                                                    {delay_time = 8 / 30 , relative_pos = { x = -550, y = 0}} ,
                                                                    -- {delay_time = 5 / 30, relative_pos = { x = 240, y = 120}} ,
                                                                    -- {delay_time = 3 / 30, relative_pos = { x = -240, y = 120}},
                                                                },
                                                            },
                                                        },
                                                        {
                                                            CLASS = "action.QSBTrap",  
                                                            OPTIONS = 
                                                            { 
                                                                trapId = "pf_ssdaimubai01_lgbx2",
                                                                args = 
                                                                {
                                                                    {delay_time = 0 / 30 , relative_pos = { x = -200, y = 0}} ,
                                                                    {delay_time = 4 / 30, relative_pos = { x = -375, y = 0}} ,
                                                                    {delay_time = 8 / 30 , relative_pos = { x = -550, y = 0}} ,
                                                                    -- {delay_time = 5 / 30, relative_pos = { x = 240, y = 120}} ,
                                                                    -- {delay_time = 3 / 30, relative_pos = { x = -240, y = 120}},
                                                                },
                                                            },
                                                        },
                                                    },
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "composite.QSBParallel",
                                                    ARGS =
                                                    {
                                                        {
                                                            CLASS = "action.QSBTrap",  
                                                            OPTIONS = 
                                                            { 
                                                                trapId = "pf_ssdaimubai01_lgb2",
                                                                args = 
                                                                {
                                                                    {delay_time = 0 / 30 , relative_pos = { x = 200, y = 0}} ,
                                                                    {delay_time = 4 / 30, relative_pos = { x = 375, y = 0}} ,
                                                                    {delay_time = 8 / 30 , relative_pos = { x = 550, y = 0}} ,
                                                                    -- {delay_time = 5 / 30, relative_pos = { x = 240, y = 120}} ,
                                                                    -- {delay_time = 3 / 30, relative_pos = { x = -240, y = 120}},
                                                                },
                                                            },
                                                        },
                                                        {
                                                            CLASS = "action.QSBTrap",  
                                                            OPTIONS = 
                                                            { 
                                                                trapId = "pf_ssdaimubai01_lgbx2",
                                                                args = 
                                                                {
                                                                    {delay_time = 0 / 30 , relative_pos = { x = 200, y = 0}} ,
                                                                    {delay_time = 4 / 30, relative_pos = { x = 375, y = 0}} ,
                                                                    {delay_time = 8 / 30 , relative_pos = { x = 550, y = 0}} ,
                                                                    -- {delay_time = 5 / 30, relative_pos = { x = 240, y = 120}} ,
                                                                    -- {delay_time = 3 / 30, relative_pos = { x = -240, y = 120}},
                                                                },
                                                            },
                                                        },
                                                    },
                                                },
                                            },
                                        },
                                    },
                                },
                            },
                        },
                        -- {
                        --     CLASS = "action.QSBPlaySound",
                        -- },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return pf_ssdaimubai01_zidong2_ex