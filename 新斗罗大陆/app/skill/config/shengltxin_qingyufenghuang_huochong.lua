--枪骑兵冲锋
--NPC ID: 10015 10016 10017
--技能ID: 50302


local shengltxin_qingyufenghuang_huochong = {
    CLASS = "composite.QSBSequence",
    ARGS = {
		{
            CLASS = "composite.QSBParallel",--冲锋
            ARGS = {
				{
					CLASS = "composite.QSBSequence",--冲锋
					ARGS = {
						{
							CLASS = "action.QSBLockTarget",
							OPTIONS = {is_lock_target = true, revertable = true},
						},
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {is_target = true, buff_id = "xunlian_bianyi_niumang_chongfeng_biaoji"},
						},
						{
							CLASS = "action.QSBManualMode",
							OPTIONS = {enter = true, revertable = true},
						},    
						{
							CLASS = "action.QSBPlayAnimation",
							OPTIONS = { is_loop = true, is_keep_animation = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 25},
						},
						{
							CLASS = "action.QSBActorFadeOut",
							OPTIONS = {duration = 0.05, revertable = true},
						},
						{
							CLASS = "action.QSBPlayLoopEffect",
							OPTIONS = {effect_id = "shenglt_qingyufenghuang_attack11", is_hit_effect = false},
						},
						{
							CLASS = "action.QSBMoveToTarget",
							OPTIONS = {is_position = true, is_range = true},
						},
						{
							CLASS = "action.QSBActorFadeIn", revertable = true,
							OPTIONS = {duration = 0.05},
						},
						{
							CLASS = "action.QSBApplyBuff",      
							OPTIONS = {buff_id = "chongfeng_tongyong_xuanyun", is_target = true},
						},
						{
							CLASS = "action.QSBStopLoopEffect",
							OPTIONS = {effect_id = "shenglt_qingyufenghuang_attack11", is_hit_effect = false},
						},
						{
							CLASS = "action.QSBHitTarget",
						},
						{
							CLASS = "action.QSBActorStatus",
							OPTIONS = 
							{
							   { "self:hp>0","apply_buff:shengltxin_qingyufenghuang_debuff"},--给自己加破甲易伤buff
							},
						},
						{
							CLASS = "action.QSBPlayEffect",--冲到脸上爆炸
							OPTIONS = {is_hit_effect = false},
						},
						{
							CLASS = "action.QSBRemoveBuff", 
							OPTIONS = {is_target = true, buff_id = "xunlian_bianyi_niumang_chongfeng_biaoji"},
						},
						{
							CLASS = "action.QSBRemoveBuff",
							OPTIONS = {buff_id = "shengltxin_qingyufenghuang_chongci"},
						},
						{
							CLASS = "action.QSBRemoveBuff",
							OPTIONS = {buff_id = "shengltxin_qingyufenghuang_chongci"},
						},
						{
							CLASS = "action.QSBRemoveBuff",
							OPTIONS = {buff_id = "shengltxin_qingyufenghuang_chongci"},
						},
						{
							CLASS = "action.QSBRemoveBuff",
							OPTIONS = {buff_id = "shengltxin_qingyufenghuang_chongci"},
						},
						{
							CLASS = "action.QSBRemoveBuff",
							OPTIONS = {buff_id = "shengltxin_qingyufenghuang_chongci"},
						},
						{
							CLASS = "action.QSBRemoveBuff",
							OPTIONS = {buff_id = "shengltxin_qingyufenghuang_chongci"},
						},
					},
				},
				{
					CLASS = "composite.QSBSequence",--加速度BUFF
					ARGS = {
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "shengltxin_qingyufenghuang_chongci"},
						}, 
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.01},
						},
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "shengltxin_qingyufenghuang_chongci"},
						}, 
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.01},
						},
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "shengltxin_qingyufenghuang_chongci"},
						}, 
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.01},
						},
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "shengltxin_qingyufenghuang_chongci"},
						}, 
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.01},
						},{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "shengltxin_qingyufenghuang_chongci"},
						}, 
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.02},
						},
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "shengltxin_qingyufenghuang_chongci"},
						}, 
					},
				},
			},
		},
		-- {
            -- CLASS = "action.QSBHitTimer",
        -- },
		-- {
            -- CLASS = "composite.QSBSequence",--火冲特效
            -- ARGS = {
				
            -- },
        -- },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBActorKeepAnimation",
                    OPTIONS = {is_keep_animation = false}
                },
                {
                    CLASS = "action.QSBActorStand",
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
		{
			CLASS = "action.QSBLockTarget",
			OPTIONS = {is_lock_target = false},
		},
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {exit = true},
        },
    },
}

return shengltxin_qingyufenghuang_huochong

