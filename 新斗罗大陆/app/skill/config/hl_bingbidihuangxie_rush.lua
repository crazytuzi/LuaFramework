-- 技能 坦克通用冲锋
--[[ 
    因为坦克冲锋后会触发一个AOE拉仇恨
	所以不能直接把晕眩BUFF写配表里
	需要脚本里手动加.
]]
-- 就是给niugao_chidunchongfeng改个名

local tank_chongfeng = {
    CLASS = "composite.QSBSequence",
    OPTIONS = {forward_mode = true},
    ARGS = {
        {
            CLASS = "action.QSBLockTarget",     --锁定目标
            OPTIONS = {is_lock_target = true, revertable = true},
        },
        {
            CLASS = "action.QSBStopMove",
        },
        {
            CLASS = "action.QSBApplyBuff",      --加速
            OPTIONS = {buff_id = "tongyongchongfeng_buff1"},
        },
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "walk", is_loop = true},       
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
            CLASS = "action.QSBRemoveBuff",     --去除加速
            OPTIONS = {buff_id = "tongyongchongfeng_buff1"},
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
            },
        },
        {
            CLASS = "action.QSBLockTarget",
            OPTIONS = {is_lock_target = false},
        },
    },
}

return tank_chongfeng