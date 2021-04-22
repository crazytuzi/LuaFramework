
local pf_tangchen_pugong1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_frame = 6},
                -- },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pl_tangcheng_attack01_1", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 14},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 125,y = 115}, effect_id = "pl_tangcheng_attack1_2", speed = 1500, hit_effect_id = "ssmahongjun_attack01_3"},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 16},
                },
                {
                    CLASS = "action.QSBActorStatus",
                    OPTIONS = 
                    {
                       { "target:xiuluo","target:apply_buff:tangchen_xiuluozhiling_die","under_status"},
                    },
                },
                {
                    CLASS = "action.QSBActorStatus",
                    OPTIONS = 
                    {
                       { "xiuluozhiliao","apply_buff:tangchen_xiuluozhiling_zhiliao_die","under_status"},
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return pf_tangchen_pugong1

