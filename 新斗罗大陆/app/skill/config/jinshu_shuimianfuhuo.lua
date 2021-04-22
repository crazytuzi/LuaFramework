--  创建人：蔡允卿
--  创建时间：2018.04.12
--  NPC：粉红娘娘
--  类型：攻击
--  修改:刘铭，06/28
local shuimianfuhuo = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBReviveMograine",
                    OPTIONS ={startBuff = "shuimian_debuff", endBuff = "fuchouzhinu", startAnimation = "attack11", endAnimation = "attack13", reviveTime = 1.5, attackTime = 2.5,isChangeHp = false, reviveActorID = 3747 },
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 6 },
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayByAttack",
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {all_enemy = true, buff_id = "shuimian_debuff"},
                        },
                    },
                },
            },
        },
    },
}

return shuimianfuhuo