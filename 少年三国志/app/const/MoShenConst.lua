local MoShenConst = {
    
--[[
    普通攻击为 mode = 1
    全力一击为 mode = 2
    ]]
    ATTACK_REBEL={
        NORMAL = 1,
        SPECIAL = 2
    },
    
--[[
	攻击倍数
    ]]
    ATTACK_MULTIPLE={
        NORMAL = 1,
        SPECIAL = 2.5
    },

    -- 阵营
    GROUP = {
        WEI = 1,
        SHU = 2,
        WU  = 3,
        QUN = 4,
    },

    -- 世界Boss的几个阶段
    REBEL_BOSS_STAGE = {
        FINISH = 0, -- 结束/预览阶段
        START = 1, -- 正式开始阶段
    },

    -- 排行榜模式
    REBEL_BOSS_RANK_MODE = {
        HONOR = 1,      --荣誉排行榜
        MAX_HARM = 2,   --最高伤害排行榜
    },

    -- 奖励模式
    REBEL_BOSS_AWARD_MODE = {
        HONOR = 1, --击杀血量奖励
        BOSS_LEVEL = 2, --Boss等级
        LEGION = 3,  --军团奖励
    },

    -- 奖励类型
    AWARD_STATE = {
        CAN_CLAIM = 1,  -- 可领取
        UNFINISH = 2,   -- 未完成
        CLAIMED = 3,    -- 已领取
    }

}
return MoShenConst

