--  创建人：蔡允卿
--  创建时间：2018.04.12
--  NPC：粉红娘娘
--  类型：攻击

local jiangzhufuhuo = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBAttackByBuffNum",
                    OPTIONS = {buff_id = "boss_jiangzhu_fuhuobuff", num_pre_stack_count = 3, trigger_skill_id = 50095, target_type = "target"},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
				{
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "boss_jiangzhu_fuhuobuff", is_target = true},
                },
            },
        },
    },
}

return jiangzhufuhuo