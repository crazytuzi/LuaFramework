-- 技能 牛天冲锋
-- 技能ID 544
-- 冲锋后获得免疫位移BUFF
--[[
	hero 牛天
	ID:1052 
	psf 2020-2-11
]]--

local ssniutian_beidong1 = {
    CLASS = "composite.QSBSequence",
    OPTIONS = {forward_mode = true},
    ARGS = {
        {
            CLASS = "action.QSBLockTarget",     --锁定目标
            OPTIONS = {is_lock_target = true, revertable = true},
        },
        {
            CLASS = "action.QSBManualMode",     --进入手动模式
            OPTIONS = {enter = true, revertable = true},
        },
        {
            CLASS = "action.QSBStopMove",
        },
        {
            CLASS = "action.QSBApplyBuff",      --加速
            OPTIONS = {buff_id = {"pf_sstianqingniumang01_chongfeng", "mianyi_suoyou_zhuangtai"}},
        },
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attack12", is_loop = true},       
        }, 
        {
            CLASS = "action.QSBActorKeepAnimation",
            OPTIONS = {is_keep_animation = true}
        },
        {
            CLASS = "action.QSBMoveToTarget",
            OPTIONS = {is_position = true},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                     CLASS = "composite.QSBSequence",
                     ARGS = {
                        {
                            CLASS = "action.QSBReloadAnimation",
                        },
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
                     CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBApplyBuff",      
                    OPTIONS = {buff_id = "1s_stun", is_target = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",      
                    OPTIONS = {buff_id = "ssniutian_beidong1_buff"},
                },
            },
        },
        {
            CLASS = "action.QSBMoveToTarget",
            OPTIONS = {is_position = true},
        },
		--不晕眩
        -- {
            -- CLASS = "action.QSBApplyBuff",
            -- OPTIONS = {buff_id = "chongfeng_tongyong_xuanyun", is_target = true},
        -- },
        {
            CLASS = "action.QSBRemoveBuff",     --去除加速
            OPTIONS = {buff_id = "pf_sstianqingniumang01_chongfeng"},
        },
        {
            CLASS = "action.QSBRemoveBuff",     --去除加速
            OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
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

return ssniutian_beidong1