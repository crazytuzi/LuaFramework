--枪骑兵冲锋
--NPC ID: 10015 10016 10017
--技能ID: 50302


local npc_qiangqibing_chongfeng = {
   CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBLockTarget",								--锁定当前攻击目标
            OPTIONS = {is_lock_target = true, revertable = true},
        },
		{
			CLASS = "action.QSBPlayAnimation",
			 OPTIONS = {animation = "attack06_1"},
		},
		{
			CLASS = "action.QSBPlayAnimation",
			OPTIONS = { animation = "attack06_2", is_loop = true, is_keep_animation = true},
		},
        {
            CLASS = "action.QSBApplyBuff",								--添加冲锋加速BUFF
            OPTIONS = {buff_id = "shengltxin_zishamoniao_chongfeng"},
        }, 
        {
            CLASS = "action.QSBManualMode",								--进入手动模式
            OPTIONS = {enter = true, revertable = true},
        },
        {
			CLASS = "action.QSBCharge", 								--不知
			OPTIONS = {move_time = 0.5},
		},
		{
            CLASS = "action.QSBApplyBuff",								--添加冲锋眩晕BUFF
            OPTIONS = {is_target = true, buff_id = "chongfeng_tongyong_xuanyun"},
        }, 
        {
            CLASS = "action.QSBRemoveBuff",								--移除加速BUFF
            OPTIONS = {buff_id = "shengltxin_zishamoniao_chongfeng"},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                     CLASS = "composite.QSBSequence",
                     ARGS = {
                        -- {
                            -- CLASS = "action.QSBDelayTime",
                            -- OPTIONS = {delay_time = 0.5},
                        -- },
                        {
                            CLASS = "action.QSBActorKeepAnimation",
                            OPTIONS = {is_keep_animation = false},
                        },
                        {
                            CLASS = "action.QSBAttackFinish"
                        },
                    },
                },


                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true},
                        },  
                        {
                            CLASS = "action.QSBDecreaseHpByCostHp",
                            OPTIONS = {is_hit_effect = true, mode = "current_hp_percent", value = 0.7, multiply_cofficient = 0.5},
                        },
                    },
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

return npc_qiangqibing_chongfeng

