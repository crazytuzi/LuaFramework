-- 技能 死亡旋转 转完头晕
-- 技能ID 53301
--[[
	深渊玳瑁
	ID:4128 
	升灵台 "巨兽沼泽"
	psf 2020-6-22
]]--

local shenglt_shenyuandaimao_xuanzhuan = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {        
        -- 上免疫控制buff
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "shenglt_shenyuandaimao_xuanzhuan_buff"},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack11", no_stand = true},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack13", is_loop = true,is_keep_animation = true},
                },
                {
                    CLASS = "action.QSBActorKeepAnimation",
                    OPTIONS = {is_keep_animation = true}
                },
                {
                    CLASS = "action.QSBHitTimer",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.75 },
                },
                {
                    CLASS = "action.QSBMoveToTarget",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 240 / 24 },
                },
                {
                    CLASS = "action.QSBActorKeepAnimation",
                    OPTIONS = {is_keep_animation = false},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1 / 24 },
                },
                {
                    CLASS = "action.QSBStopMove",
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack13_2", is_loop = true},
                },
                {
                    CLASS = "action.QSBActorKeepAnimation",
                    OPTIONS = {is_keep_animation = true}
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_target = false , buff_id = "shenglt_shenyuandaimao_debuff"},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 240 / 24 },
                },
                {
                    CLASS = "action.QSBActorKeepAnimation",
                    OPTIONS = {is_keep_animation = false},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1 / 24 },
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack13_3"},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "shenglt_shenyuandaimao_debuff"},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "shenglt_shenyuandaimao_xuanzhuan_buff"},
                },
                {
                    CLASS = "action.QSBActorStand",
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
    },
}

return shenglt_shenyuandaimao_xuanzhuan
