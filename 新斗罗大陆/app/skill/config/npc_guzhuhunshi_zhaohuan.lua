--  创建人：刘悦璘
--  创建时间：2018.03.22
--  NPC：孤竹魂师
--  类型：召唤
local npc_guzhuhunshi_zhaohuan = 
{
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
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
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.8},
                },
                {
                    CLASS = "action.QSBSummonMonsters",
                    OPTIONS = {wave = -1, attacker_level = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",     
                    OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
                },
            },
        },
    },
}
return npc_guzhuhunshi_zhaohuan