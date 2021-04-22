
local pf_mhtangchen_ex = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound",
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = 
             {
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai", is_target = false, no_cancel = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "tangchen_xiuluofuti_ex", is_target = false},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "tangchen_xiuluofuti_ex_hetiji", is_target = false},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "tangchen_zhongjie_huifu", is_target = false, no_cancel = true},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    { 
                        {
                            CLASS = "action.QSBPlayAnimation",
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pl_xiuluo_tangcheng_attack11_1", is_hit_effect = false},
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 17},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {start_pos = {x = 150,y = 50}},
                                },
                                {
                                    CLASS = "action.QSBRemoveBuff",
                                    OPTIONS = {buff_id = "tangchen_dazhao_jishi", is_target = false},
                                },
                            },
                        },
                    },
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
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {buff_id = "tangchen_dazhao_jishi_hetiji", is_target = false},
                        },
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {buff_id = "tangchen_zhongjie_huifu", is_target = false},
                        },
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai", is_target = false},
                        },
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {buff_id = "pf_tangchen_xiuluofuti_buff", is_target = false},
                        },
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {buff_id = "pf_tangchen_xiuluofuti_buff_hetiji", is_target = false},
                        },
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return pf_mhtangchen_ex

