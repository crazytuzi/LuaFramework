local npc_wugui_xuanzhuan = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {        
        -- 上免疫控制buff
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
        },
        
        -- {
        --     CLASS = "action.QSBPlaySound"
        -- },
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attack12"},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 45 / 24 },
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack11", no_stand = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 15 / 24 },
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack13", is_loop = true},
                },
                {
                    CLASS = "action.QSBActorKeepAnimation",
                    OPTIONS = {is_keep_animation = true}
                },
                {
                    CLASS = "action.QSBHitTimer",
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
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
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

return npc_wugui_xuanzhuan
