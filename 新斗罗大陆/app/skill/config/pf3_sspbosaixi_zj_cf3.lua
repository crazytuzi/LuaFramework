local sspbosaixi_zj_cf3 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {   
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {is_target = false ,buff_id = "pf3_sspbosaixi_zj1_jt1"},      --真技1监听1？？？？？
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {is_target = false ,buff_id = "pf3_sspbosaixi_zj2_jt1"},      --真技2监听1？？？？？
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {is_target = false ,buff_id = "pf3_sspbosaixi_zj3_jt1"},      --真技3监听1？？？？？
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time =  3.5 },
                },
                {
                    CLASS = "action.QSBActorStatus",
                    OPTIONS = 
                    {
                       { "hp_percent>0","increase_hp:self:maxHp*0.45"},
                    },
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBArgsIsUnderStatus",
                    OPTIONS = {is_attacker = true,status = "sspbosaixi_zj3_jt2"},
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBAttackFinish",
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBRemoveBuff",
                                    OPTIONS = {is_target = false, buff_id = "pf3_sspbosaixi_zj3_jt1",no_cancel = true},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = false, buff_id = "pf3_sspbosaixi_zj3_jt2", no_cancel = true},
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
        {                                           --真技3上护盾，伤害转护盾，优先抵消伤害，无视穿盾
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "pf3_sspbosaixi_zj3_buff1", no_cancel = true},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time =  2 },
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = 
                    {
                        target_buff_id = "pf3_sspbosaixi_zj3_debuff1", --[[每次弹射命中时目标上的buff]]                                          
                        attack_dummy = "dummy_center",
                        flip_follow_y = true, 
                        effect_id = "pf3_sspbosaixi_zj_03", 
                        damage_scale_back_self = 3 ,
                        speed = 800,
                        length_threshold = 100,
                        is_bezier2 = true, 
                        start_pos = {x = -50,y = -30}, 
                        hit_effect_id = "pf3_sspbosaixi_zj_04", 
                        jump_info = 
                        { 
                            jump_number = 6,
                            near_first = false,
                            random_get_new_target = true, --[[随机弹射开关]]
                            jump_self = true,--[[回弹自己开关]]
                            -- jump_self_buffid = "sspbosaixi_zj3_buff3", --[[回弹到自己上的buff]]
                        }, 
                        rail_number = 1, 
                        rail_inter_frame = 1
                    },
                },
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = 
			{
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 20},
                },
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = false, effect_id = "pf3_sspbosaixi_zj_05"},
				},   
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = false, effect_id = "pf3_sspbosaixi_zj_02"},
				},          
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 20},
                },
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = false, effect_id = "pf3_sspbosaixi_zj_01"},
				}, 
				
			},
		},
    },
}

return sspbosaixi_zj_cf3