
local npc_boss_kresh = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {   
     ------------------------     克雷什     ---------------------------------


     ----------------------  免疫控制状态   --------------------------------
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval=0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 201103},
                },
            },
        },
        
       --------------------      召唤       -------------------------
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 60,first_interval=5}, 
                },
                -- {
                --     CLASS = "action.QAIAttackEnemyOutOfDistance",--选择一个多少距离之外的目标执行某个行为
                --     OPTIONS = {current_target_excluded = true},
                -- },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200301},
                },
                -- {
                --     CLASS = "action.QAIIgnoreHitLog",
                --     OPTIONS = {store = true},
                -- },
                -- {
                --     CLASS = "action.QAITrackTarget",
                --     OPTIONS = {interval = 3},
                -- },
            },
        },
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 20,first_interval=10 + 7},
        --         },
        --         {
        --             CLASS = "action.QAIAcceptHitLog",
        --             OPTIONS = {restore = true},
        --         },
        --         {
        --             CLASS = "action.QAITrackTarget",
        --             OPTIONS = {disable = true},
        --         },
        --     },
        -- },  
      
       -------------------   阶段二血量降低到50%的技能  -----------------------------------
       
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIHPLost",
                    OPTIONS = {hp_less_then = {0.5},only_trigger_once = false},        -- 多少血量一下触发一次,only_trigger_once是否重复触发
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200003},          -- 召唤
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIHPLost",
                    OPTIONS = {hp_less_then = {0.45},only_trigger_once = false},        -- 多少血量一下触发一次,only_trigger_once是否重复触发
                },
                -- {
                --     CLASS = "action.QAIAttackEnemyOutOfDistance",       --选择一个多少距离之外的目标执行某个行为
                --     OPTIONS = {current_target_excluded = true},         --current_target_excluded：当前目标排除在外
                -- },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200301},          -- 旋转
                },
                -- {
                --     CLASS = "action.QAIIgnoreHitLog",   --忽略仇恨列表，锁定攻击当前目标（除非当前目标死了）。
                --     OPTIONS = {store = true},
                -- },
                -- {
                --     CLASS = "action.QAITrackTarget",    -- 一根筋
                --     OPTIONS = {interval = 3},
                -- },
                -- {
                --     CLASS = "action.QAITimer",
                --     OPTIONS = {interval = 7, max_hit = 1}, -- 延迟时间 ，max_hit：触发次数限制
                -- },
                -- {
                --     CLASS = "action.QAIAcceptHitLog",   -- 使得ai取消忽略仇恨列表，取消锁定当前目标，
                --     OPTIONS = {restore = true},
                -- },
                -- {
                --     CLASS = "action.QAITrackTarget",    -- 一根筋
                --     OPTIONS = {disable = true},         -- disable: 值为true时取消连线，直到下次执行QAITrackTarget。
                -- },
             
            },
        },
       
        ------------------  以下是旋转修正  ------------------------------
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {check_skill_id = 200301},
                },
                {
                    CLASS = "action.QAITimeSpan",
                    OPTIONS = {from = 0.0, to = 1.1, relative = true},
                },
                {
                    CLASS = "action.QAINPCStayMode",
                    OPTIONS = {stay = true}
                },
                {
                    CLASS = "action.QAIStopMoving",
                },
                {
                    CLASS = "action.QAIResult",
                    OPTIONS = {result = false},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {check_skill_id = 200301},
                },
                {
                    CLASS = "action.QAITimeSpan",
                    OPTIONS = {from = 1.1, to = nil, relative = true},
                },
                {
                    CLASS = "action.QAINPCStayMode",
                    OPTIONS = {stay = false}
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {check_skill_id = 200301, reverse_result = true},
                },
                {
                    CLASS = "action.QAINPCStayMode",
                    OPTIONS = {stay = false}
                },
                {
                    CLASS = "action.QAIResult",
                    OPTIONS = {result = false}
                },
            },
        },
    ------------------------ 以上是旋转修正 ------------------------------------------------

        {
            CLASS = "action.QAIAttackByHitlog",
        },
        {
            CLASS = "composite.QAISelector",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsAttacking",
                },
                {
                    CLASS = "action.QAIBeatBack",
                },
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                },
            },
        },
    },
}

return npc_boss_kresh