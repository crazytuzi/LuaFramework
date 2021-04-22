
local shengltxin_cuimoniaowang_zhaohuan = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 10},
                }, 
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false},
                },
            },
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
                    OPTIONS = {delay_frame = 10},
                }, 
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {is_teammate = true, max_distance = true, change_all_node_target = true},
                },
                {
                    CLASS = "action.QSBSummonGhosts",
                    OPTIONS = {actor_id = 4161, life_span = 6, number = 1, hp_percent = 0.5, relative_pos = {x = 5, y = 0},  is_attacked_ghost =false,enablehp = false},
                },
                -- {
				-- 	CLASS = "action.QSBTrap", 
				-- 	OPTIONS = 
				-- 	{ 
				-- 		trapId = "shengltxin_cuimoniaowang_tuteng",is_attackee = true,
				-- 		args = 
				-- 		{
				-- 			{delay_time = 0 , relative_pos = { x = 5, y = 0}} ,
				-- 		},
				-- 	},
				-- },
                {
                    CLASS = "action.QSBRemoveBuff",     
                    OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
                },
            },
        },
    },
}

return shengltxin_cuimoniaowang_zhaohuan