-- 技能 BOSS死亡魔蛛 召唤
-- 技能ID 50870
-- 召唤小蜘蛛
--[[
	boss 死亡魔蛛
	ID:3698
	psf 2018-7-19
]]--

local shifa_tongyong = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {enemy = true, buff_id = "anqi_feitianshenzhua_diecen_buff1",remove_all_same_buff_id = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {enemy = true, buff_id = "anqi_feitianshenzhua_diecen_buff2",remove_all_same_buff_id = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {enemy = true, buff_id = "anqi_feitianshenzhua_diecen_buff3",remove_all_same_buff_id = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {enemy = true, buff_id = "anqi_feitianshenzhua_diecen_buff4",remove_all_same_buff_id = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {enemy = true, buff_id = "anqi_feitianshenzhua_diecen_buff5",remove_all_same_buff_id = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "anqi_feitianshenzhua_jishu_buff1",remove_all_same_buff_id = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "anqi_feitianshenzhua_jishu_buff2",remove_all_same_buff_id = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "anqi_feitianshenzhua_jishu_buff3",remove_all_same_buff_id = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "anqi_feitianshenzhua_jishu_buff4",remove_all_same_buff_id = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "anqi_feitianshenzhua_jishu_buff5",remove_all_same_buff_id = true},
                },
            },
        },
    },
}

local liuerlong_zhenji_trigger = 
{
	CLASS = "composite.QSBSequence",
	ARGS =
	{
		{
            CLASS = "action.QSBArgsIsUnderStatus",
            OPTIONS = {is_attackee = true, status = "feitian_jueyuan2", reverse_result = true},
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = {
               shifa_tongyong,
            },
        },
		{
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "anqi_feitianshenzhua_diecen_buff5",attacker_target = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "anqi_feitianshenzhua_jishu_buff5"},
        },
        {
			CLASS = "action.QSBAttackByBuffNum",
			OPTIONS = { buff_id = "anqi_feitianshenzhua_diecen_buff5",num_pre_stack_count = 4, trigger_skill_id = 40342,target_type = "actor_target" }
		},
        {
			CLASS = "action.QSBAttackFinish",
		},
	},
}
return liuerlong_zhenji_trigger