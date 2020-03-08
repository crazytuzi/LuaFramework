-- 奖券使用之后对应描述
ChouJiang.tbDayLotteryDate = 
{
    [5] = "2月3日",
    [8] = "2月6日",
    [11] = "2月9日",
}

-- 只支持到分
ChouJiang.szDayTime = "22:00"
-- 活动开始后哪几天进行抽奖
ChouJiang.tbExecuteDay = {5,8,11}

ChouJiang.szOpenNewInfomationKey = "NYLottery"

ChouJiang.szHitNewInfomationKey = "NYLotteryResult"
-- 大奖第几天开启
ChouJiang.nBigExecuteDay = 21
-- 大奖开奖时间点
ChouJiang.szBigDayTime = "22:00"
-- 开关
ChouJiang.bOpen = true
-- 是否不发奖励展示最新消息
ChouJiang.bNotSendOpenNewInfo = false

-- 小奖奖励
ChouJiang.tbDayAward = 
{
    ["OpenLevel39"] = 
    {
         [1] = {
            -- [1] = 1 为抽奖数量
            -- [2] = {{"item",2161,1}} 奖励内容
            -- [3] = true 是否限制小号不能得
            -- [4] = 是否发布世界公告
            -- [5] = 是否发布家族公告
            -- [6] = 周卡状态
            -- [7] = vip限制{min,max}
            -- 可以配置多条数量一样条件逐步放宽，只会抽一条配置的数量（*每行条件数量要保持一致，除非有特殊需求）
            {[1] = 1, [2] = {{"item", 7441, 1}}, [3] = false, [4] = false, [5] = true, [6] = true, [7] = {5,15}},   ----全满足条件
            {[1] = 1, [2] = {{"item", 7441, 1}}, [3] = false, [4] = false, [5] = true, [7] = {5,15}},               ----仅不满足周卡状态
            {[1] = 1, [2] = {{"item", 7441, 1}}, [3] = false, [4] = false, [5] = true, [6] = true},                 ----仅不满足vip限制
            {[1] = 1, [2] = {{"item", 7441, 1}}, [3] = true, [4] = false, [5] = true},                              ----不满足周卡vip非小号
        };
        [2] = {
            {[1] = 3, [2] = {{"item", 2400, 1}}, [3] = false, [4] = false, [5] = true, [6] = true, [7] = {5}},   
            {[1] = 3, [2] = {{"item", 2400, 1}}, [3] = false, [4] = false, [5] = true, [7] = {5}},
            {[1] = 3, [2] = {{"item", 2400, 1}}, [3] = false, [4] = false, [5] = true, [6] = true},
            {[1] = 3, [2] = {{"item", 2400, 1}}, [3] = false, [4] = false, [5] = true},
        };
        [3] = {
            {[1] = 10, [2] = {{"item", 2169, 1}}, [3] = false, [4] = false, [5] = true, [6] = true, [7] = {5}},
            {[1] = 10, [2] = {{"item", 2169, 1}}, [3] = false, [4] = false, [5] = true, [7] = {5}},
            {[1] = 10, [2] = {{"item", 2169, 1}}, [3] = false, [4] = false, [5] = true, [6] = true},
            {[1] = 10, [2] = {{"item", 2169, 1}}, [3] = false, [4] = false, [5] = true},
        };
        [4] = {
            {[1] = 50, [2] = {{"item", 5415, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
    };
    ["OpenLevel69"] = 
    {
         [1] = {
            -- [1] = 1 为抽奖数量
            -- [2] = {{"item",2161,1}} 奖励内容
            -- [3] = true 是否限制小号不能得
            -- [4] = 是否发布世界公告
            -- [5] = 是否发布家族公告
            -- [6] = 周卡状态
            -- [7] = vip限制{min,max}
            -- 可以配置多条数量一样条件逐步放宽，只会抽一条配置的数量（*每行条件数量要保持一致，除非有特殊需求）
            {[1] = 1, [2] = {{"item", 7441, 1}}, [3] = false, [4] = false, [5] = true, [6] = true, [7] = {5,15}},   ----全满足条件
            {[1] = 1, [2] = {{"item", 7441, 1}}, [3] = false, [4] = false, [5] = true, [7] = {5,15}},               ----仅不满足周卡状态
            {[1] = 1, [2] = {{"item", 7441, 1}}, [3] = false, [4] = false, [5] = true, [6] = true},                 ----仅不满足vip限制
            {[1] = 1, [2] = {{"item", 7441, 1}}, [3] = true, [4] = false, [5] = true},                              ----不满足周卡vip非小号
        };
        [2] = {
            {[1] = 3, [2] = {{"item", 2400, 1}}, [3] = false, [4] = false, [5] = true, [6] = true, [7] = {5}},   
            {[1] = 3, [2] = {{"item", 2400, 1}}, [3] = false, [4] = false, [5] = true, [7] = {5}},
            {[1] = 3, [2] = {{"item", 2400, 1}}, [3] = false, [4] = false, [5] = true, [6] = true},
            {[1] = 3, [2] = {{"item", 2400, 1}}, [3] = false, [4] = false, [5] = true},
        };
        [3] = {
            {[1] = 10, [2] = {{"item", 2169, 1}}, [3] = false, [4] = false, [5] = true, [6] = true, [7] = {5}},
            {[1] = 10, [2] = {{"item", 2169, 1}}, [3] = false, [4] = false, [5] = true, [7] = {5}},
            {[1] = 10, [2] = {{"item", 2169, 1}}, [3] = false, [4] = false, [5] = true, [6] = true},
            {[1] = 10, [2] = {{"item", 2169, 1}}, [3] = false, [4] = false, [5] = true},
        };
        [4] = {
            {[1] = 50, [2] = {{"item", 5415, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
    };
    ["OpenLevel79"] = 
    {
         [1] = {
            -- [1] = 1 为抽奖数量
            -- [2] = {{"item",2161,1}} 奖励内容
            -- [3] = true 是否限制小号不能得
            -- [4] = 是否发布世界公告
            -- [5] = 是否发布家族公告
            -- [6] = 周卡状态
            -- [7] = vip限制{min,max}
            -- 可以配置多条数量一样条件逐步放宽，只会抽一条配置的数量（*每行条件数量要保持一致，除非有特殊需求）
            {[1] = 1, [2] = {{"item", 7442, 1}}, [3] = false, [4] = false, [5] = true, [6] = true, [7] = {5,15}},   ----全满足条件
            {[1] = 1, [2] = {{"item", 7442, 1}}, [3] = false, [4] = false, [5] = true, [7] = {5,15}},               ----仅不满足周卡状态
            {[1] = 1, [2] = {{"item", 7442, 1}}, [3] = false, [4] = false, [5] = true, [6] = true},                 ----仅不满足vip限制
            {[1] = 1, [2] = {{"item", 7442, 1}}, [3] = true, [4] = false, [5] = true},                              ----不满足周卡vip非小号
        };
        [2] = {
            {[1] = 3, [2] = {{"item", 2400, 1}}, [3] = false, [4] = false, [5] = true, [6] = true, [7] = {5}},   
            {[1] = 3, [2] = {{"item", 2400, 1}}, [3] = false, [4] = false, [5] = true, [7] = {5}},
            {[1] = 3, [2] = {{"item", 2400, 1}}, [3] = false, [4] = false, [5] = true, [6] = true},
            {[1] = 3, [2] = {{"item", 2400, 1}}, [3] = false, [4] = false, [5] = true},
        };
        [3] = {
            {[1] = 10, [2] = {{"item", 2169, 1}}, [3] = false, [4] = false, [5] = true, [6] = true, [7] = {5}},
            {[1] = 10, [2] = {{"item", 2169, 1}}, [3] = false, [4] = false, [5] = true, [7] = {5}},
            {[1] = 10, [2] = {{"item", 2169, 1}}, [3] = false, [4] = false, [5] = true, [6] = true},
            {[1] = 10, [2] = {{"item", 2169, 1}}, [3] = false, [4] = false, [5] = true},
        };
        [4] = {
            {[1] = 50, [2] = {{"item", 5415, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
    };
    ["OpenLevel89"] = 
    {
         [1] = {
            -- [1] = 1 为抽奖数量
            -- [2] = {{"item",2161,1}} 奖励内容
            -- [3] = true 是否限制小号不能得
            -- [4] = 是否发布世界公告
            -- [5] = 是否发布家族公告
            -- [6] = 周卡状态
            -- [7] = vip限制{min,max}
            -- 可以配置多条数量一样条件逐步放宽，只会抽一条配置的数量（*每行条件数量要保持一致，除非有特殊需求）
            {[1] = 1, [2] = {{"item", 2795, 1}}, [3] = false, [4] = false, [5] = true, [6] = true, [7] = {5,15}},   ----全满足条件
            {[1] = 1, [2] = {{"item", 2795, 1}}, [3] = false, [4] = false, [5] = true, [7] = {5,15}},               ----仅不满足周卡状态
            {[1] = 1, [2] = {{"item", 2795, 1}}, [3] = false, [4] = false, [5] = true, [6] = true},                 ----仅不满足vip限制
            {[1] = 1, [2] = {{"item", 2795, 1}}, [3] = true, [4] = false, [5] = true},                              ----不满足周卡vip非小号
        };
        [2] = {
            {[1] = 3, [2] = {{"item", 3179, 1}}, [3] = false, [4] = false, [5] = true, [6] = true, [7] = {5}},   
            {[1] = 3, [2] = {{"item", 3179, 1}}, [3] = false, [4] = false, [5] = true, [7] = {5}},
            {[1] = 3, [2] = {{"item", 3179, 1}}, [3] = false, [4] = false, [5] = true, [6] = true},
            {[1] = 3, [2] = {{"item", 3179, 1}}, [3] = false, [4] = false, [5] = true},
        };
        [3] = {
            {[1] = 10, [2] = {{"item", 2169, 1}}, [3] = false, [4] = false, [5] = true, [6] = true, [7] = {5}},
            {[1] = 10, [2] = {{"item", 2169, 1}}, [3] = false, [4] = false, [5] = true, [7] = {5}},
            {[1] = 10, [2] = {{"item", 2169, 1}}, [3] = false, [4] = false, [5] = true, [6] = true},
            {[1] = 10, [2] = {{"item", 2169, 1}}, [3] = false, [4] = false, [5] = true},
        };
        [4] = {
            {[1] = 50, [2] = {{"item", 5415, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
    };
    ["OpenLevel99"] = 
    {
         [1] = {
            -- [1] = 1 为抽奖数量
            -- [2] = {{"item",2161,1}} 奖励内容
            -- [3] = true 是否限制小号不能得
            -- [4] = 是否发布世界公告
            -- [5] = 是否发布家族公告
            -- [6] = 周卡状态
            -- [7] = vip限制{min,max}
            -- 可以配置多条数量一样条件逐步放宽，只会抽一条配置的数量（*每行条件数量要保持一致，除非有特殊需求）
            {[1] = 1, [2] = {{"item", 2795, 1}}, [3] = false, [4] = false, [5] = true, [6] = true, [7] = {5,16}},   ----全满足条件
            {[1] = 1, [2] = {{"item", 2795, 1}}, [3] = false, [4] = false, [5] = true, [7] = {5,16}},               ----仅不满足周卡状态
            {[1] = 1, [2] = {{"item", 2795, 1}}, [3] = false, [4] = false, [5] = true, [6] = true},                 ----仅不满足vip限制
            {[1] = 1, [2] = {{"item", 2795, 1}}, [3] = true, [4] = false, [5] = true},                              ----不满足周卡vip非小号
        };
        [2] = {
            {[1] = 3, [2] = {{"item", 3179, 1}}, [3] = false, [4] = false, [5] = true, [6] = true, [7] = {5}},   
            {[1] = 3, [2] = {{"item", 3179, 1}}, [3] = false, [4] = false, [5] = true, [7] = {5}},
            {[1] = 3, [2] = {{"item", 3179, 1}}, [3] = false, [4] = false, [5] = true, [6] = true},
            {[1] = 3, [2] = {{"item", 3179, 1}}, [3] = false, [4] = false, [5] = true},
        };
        [3] = {
            {[1] = 10, [2] = {{"item", 2169, 1}}, [3] = false, [4] = false, [5] = true, [6] = true, [7] = {5}},
            {[1] = 10, [2] = {{"item", 2169, 1}}, [3] = false, [4] = false, [5] = true, [7] = {5}},
            {[1] = 10, [2] = {{"item", 2169, 1}}, [3] = false, [4] = false, [5] = true, [6] = true},
            {[1] = 10, [2] = {{"item", 2169, 1}}, [3] = false, [4] = false, [5] = true},
        };
        [4] = {
            {[1] = 50, [2] = {{"item", 5415, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
    };
    ["OpenLevel109"] = 
    {
         [1] = {
            -- [1] = 1 为抽奖数量
            -- [2] = {{"item",2161,1}} 奖励内容
            -- [3] = true 是否限制小号不能得
            -- [4] = 是否发布世界公告
            -- [5] = 是否发布家族公告
            -- [6] = 周卡状态
            -- [7] = vip限制{min,max}
            -- 可以配置多条数量一样条件逐步放宽，只会抽一条配置的数量（*每行条件数量要保持一致，除非有特殊需求）
            {[1] = 1, [2] = {{"item", 2794, 1}}, [3] = false, [4] = false, [5] = true, [6] = true, [7] = {5,16}},   ----全满足条件
            {[1] = 1, [2] = {{"item", 2794, 1}}, [3] = false, [4] = false, [5] = true, [7] = {5,16}},               ----仅不满足周卡状态
            {[1] = 1, [2] = {{"item", 2794, 1}}, [3] = false, [4] = false, [5] = true, [6] = true},                 ----仅不满足vip限制
            {[1] = 1, [2] = {{"item", 2794, 1}}, [3] = true, [4] = false, [5] = true},                              ----不满足周卡vip非小号
        };
        [2] = {
            {[1] = 3, [2] = {{"item", 1396, 2}}, [3] = false, [4] = false, [5] = true, [6] = true, [7] = {5}},   
            {[1] = 3, [2] = {{"item", 1396, 2}}, [3] = false, [4] = false, [5] = true, [7] = {5}},
            {[1] = 3, [2] = {{"item", 1396, 2}}, [3] = false, [4] = false, [5] = true, [6] = true},
            {[1] = 3, [2] = {{"item", 1396, 2}}, [3] = false, [4] = false, [5] = true},
        };
        [3] = {
            {[1] = 10, [2] = {{"item", 3693, 1}}, [3] = false, [4] = false, [5] = true, [6] = true, [7] = {5}},
            {[1] = 10, [2] = {{"item", 3693, 1}}, [3] = false, [4] = false, [5] = true, [7] = {5}},
            {[1] = 10, [2] = {{"item", 3693, 1}}, [3] = false, [4] = false, [5] = true, [6] = true},
            {[1] = 10, [2] = {{"item", 3693, 1}}, [3] = false, [4] = false, [5] = true},
        };
        [4] = {
            {[1] = 50, [2] = {{"item", 5415, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
    };
    ["OpenLevel119"] = 
    {
         [1] = {
            -- [1] = 1 为抽奖数量
            -- [2] = {{"item",2161,1}} 奖励内容
            -- [3] = true 是否限制小号不能得
            -- [4] = 是否发布世界公告
            -- [5] = 是否发布家族公告
            -- [6] = 周卡状态
            -- [7] = vip限制{min,max}
            -- 可以配置多条数量一样条件逐步放宽，只会抽一条配置的数量（*每行条件数量要保持一致，除非有特殊需求）
            {[1] = 1, [2] = {{"item", 6148, 1}}, [3] = false, [4] = false, [5] = true, [6] = true, [7] = {5,16}},   ----全满足条件
            {[1] = 1, [2] = {{"item", 6148, 1}}, [3] = false, [4] = false, [5] = true, [7] = {5,16}},               ----仅不满足周卡状态
            {[1] = 1, [2] = {{"item", 6148, 1}}, [3] = false, [4] = false, [5] = true, [6] = true},                 ----仅不满足vip限制
            {[1] = 1, [2] = {{"item", 6148, 1}}, [3] = true, [4] = false, [5] = true},                              ----不满足周卡vip非小号
        };
        [2] = {
            {[1] = 3, [2] = {{"item", 1396, 2}}, [3] = false, [4] = false, [5] = true, [6] = true, [7] = {5}},   
            {[1] = 3, [2] = {{"item", 1396, 2}}, [3] = false, [4] = false, [5] = true, [7] = {5}},
            {[1] = 3, [2] = {{"item", 1396, 2}}, [3] = false, [4] = false, [5] = true, [6] = true},
            {[1] = 3, [2] = {{"item", 1396, 2}}, [3] = false, [4] = false, [5] = true},
        };
        [3] = {
            {[1] = 10, [2] = {{"item", 2169, 1}}, [3] = false, [4] = false, [5] = true, [6] = true, [7] = {5}},
            {[1] = 10, [2] = {{"item", 2169, 1}}, [3] = false, [4] = false, [5] = true, [7] = {5}},
            {[1] = 10, [2] = {{"item", 2169, 1}}, [3] = false, [4] = false, [5] = true, [6] = true},
            {[1] = 10, [2] = {{"item", 2169, 1}}, [3] = false, [4] = false, [5] = true},
        };
        [4] = {
            {[1] = 50, [2] = {{"item", 5415, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
    };
    ["OpenLevel129"] = 
    {
         [1] = {
            -- [1] = 1 为抽奖数量
            -- [2] = {{"item",2161,1}} 奖励内容
            -- [3] = true 是否限制小号不能得
            -- [4] = 是否发布世界公告
            -- [5] = 是否发布家族公告
            -- [6] = 周卡状态
            -- [7] = vip限制{min,max}
            -- 可以配置多条数量一样条件逐步放宽，只会抽一条配置的数量（*每行条件数量要保持一致，除非有特殊需求）
            {[1] = 1, [2] = {{"item", 6148, 1}}, [3] = false, [4] = false, [5] = true, [6] = true, [7] = {5,16}},   ----全满足条件
            {[1] = 1, [2] = {{"item", 6148, 1}}, [3] = false, [4] = false, [5] = true, [7] = {5,16}},               ----仅不满足周卡状态
            {[1] = 1, [2] = {{"item", 6148, 1}}, [3] = false, [4] = false, [5] = true, [6] = true},                 ----仅不满足vip限制
            {[1] = 1, [2] = {{"item", 6148, 1}}, [3] = true, [4] = false, [5] = true},                              ----不满足周卡vip非小号
        };
        [2] = {
            {[1] = 3, [2] = {{"item", 2804, 10}}, [3] = false, [4] = false, [5] = true, [6] = true, [7] = {5}},   
            {[1] = 3, [2] = {{"item", 2804, 10}}, [3] = false, [4] = false, [5] = true, [7] = {5}},
            {[1] = 3, [2] = {{"item", 2804, 10}}, [3] = false, [4] = false, [5] = true, [6] = true},
            {[1] = 3, [2] = {{"item", 2804, 10}}, [3] = false, [4] = false, [5] = true},
        };
        [3] = {
            {[1] = 10, [2] = {{"item", 2169, 1}}, [3] = false, [4] = false, [5] = true, [6] = true, [7] = {5}},
            {[1] = 10, [2] = {{"item", 2169, 1}}, [3] = false, [4] = false, [5] = true, [7] = {5}},
            {[1] = 10, [2] = {{"item", 2169, 1}}, [3] = false, [4] = false, [5] = true, [6] = true},
            {[1] = 10, [2] = {{"item", 2169, 1}}, [3] = false, [4] = false, [5] = true},
        };
        [4] = {
            {[1] = 50, [2] = {{"item", 5415, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
    };
    ["OpenLevel139"] = 
    {
         [1] = {
            -- [1] = 1 为抽奖数量
            -- [2] = {{"item",2161,1}} 奖励内容
            -- [3] = true 是否限制小号不能得
            -- [4] = 是否发布世界公告
            -- [5] = 是否发布家族公告
            -- [6] = 周卡状态
            -- [7] = vip限制{min,max}
            -- 可以配置多条数量一样条件逐步放宽，只会抽一条配置的数量（*每行条件数量要保持一致，除非有特殊需求）
            {[1] = 1, [2] = {{"item", 6148, 1}}, [3] = false, [4] = false, [5] = true, [6] = true, [7] = {5,16}},   ----全满足条件
            {[1] = 1, [2] = {{"item", 6148, 1}}, [3] = false, [4] = false, [5] = true, [7] = {5,16}},               ----仅不满足周卡状态
            {[1] = 1, [2] = {{"item", 6148, 1}}, [3] = false, [4] = false, [5] = true, [6] = true},                 ----仅不满足vip限制
            {[1] = 1, [2] = {{"item", 6148, 1}}, [3] = true, [4] = false, [5] = true},                              ----不满足周卡vip非小号
        };
        [2] = {
            {[1] = 3, [2] = {{"item", 7067, 1}}, [3] = false, [4] = false, [5] = true, [6] = true, [7] = {5}},   
            {[1] = 3, [2] = {{"item", 7067, 1}}, [3] = false, [4] = false, [5] = true, [7] = {5}},
            {[1] = 3, [2] = {{"item", 7067, 1}}, [3] = false, [4] = false, [5] = true, [6] = true},
            {[1] = 3, [2] = {{"item", 7067, 1}}, [3] = false, [4] = false, [5] = true},
        };
        [3] = {
            {[1] = 10, [2] = {{"item", 2804, 5}}, [3] = false, [4] = false, [5] = true, [6] = true, [7] = {5}},
            {[1] = 10, [2] = {{"item", 2804, 5}}, [3] = false, [4] = false, [5] = true, [7] = {5}},
            {[1] = 10, [2] = {{"item", 2804, 5}}, [3] = false, [4] = false, [5] = true, [6] = true},
            {[1] = 10, [2] = {{"item", 2804, 5}}, [3] = false, [4] = false, [5] = true},
        };
        [4] = {
            {[1] = 50, [2] = {{"item", 5415, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
    };
}    

-- 大奖奖励
ChouJiang.tbBigAward = 
{
    ["OpenLevel39"] = 
    {
        [1] = {
            -- [1] = 1 为抽奖数量
            -- [2] = {{"item",2161,1}} 奖励内容
            -- [3] = true 是否限制小号不能得
            -- [4] = 是否发布世界公告
            -- [5] = 是否发布家族公告
            -- [6] = 周卡状态
            -- [7] = vip限制{min,max}
            [1] = {[1] = 1, [2] = {{"item", 3743, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},      
        };
        [2] = {
            [1] = {[1] = 2, [2] = {{"item", 3741, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},
        };
        [3] = {
            [1] = {[1] = 3, [2] = {{"item", 3739, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},
        };
        [4] = {
            [1] = {[1] = 10, [2] = {{"item", 3180, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
        [5] = {
            [1] = {[1] = 50, [2] = {{"item", 2165, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
        [6] = {
            [1] = {[1] = 100, [2] = {{"Contrib", 10000}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };                
    };
    ["OpenLevel79"] = 
    {
        [1] = {
            [1] = {[1] = 1, [2] = {{"item", 3752, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},      
        };
        [2] = {
            [1] = {[1] = 2, [2] = {{"item", 3756, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},
        };
        [3] = {
            [1] = {[1] = 3, [2] = {{"item", 3760, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},
        };
        [4] = {
            [1] = {[1] = 10, [2] = {{"item", 3180, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
        [5] = {
            [1] = {[1] = 50, [2] = {{"item", 2165, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
        [6] = {
            [1] = {[1] = 100, [2] = {{"Contrib", 10000}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };                
    };
    ["OpenLevel89"] = 
    {
        [1] = {
            [1] = {[1] = 1, [2] = {{"item", 3753, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},      
        };
        [2] = {
            [1] = {[1] = 2, [2] = {{"item", 3757, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},
        };
        [3] = {
            [1] = {[1] = 3, [2] = {{"item", 3761, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},
        };
        [4] = {
            [1] = {[1] = 10, [2] = {{"item", 3180, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
        [5] = {
            [1] = {[1] = 50, [2] = {{"item", 2165, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
        [6] = {
            [1] = {[1] = 100, [2] = {{"Contrib", 10000}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };                
    };
    ["OpenLevel99"] = 
    {
        [1] = {
            [1] = {[1] = 1, [2] = {{"item", 3754, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},      
        };
        [2] = {
            [1] = {[1] = 2, [2] = {{"item", 3758, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},
        };
        [3] = {
            [1] = {[1] = 3, [2] = {{"item", 3762, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},
        };
        [4] = {
            [1] = {[1] = 10, [2] = {{"item", 3180, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
        [5] = {
            [1] = {[1] = 50, [2] = {{"item", 2165, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
        [6] = {
            [1] = {[1] = 100, [2] = {{"Contrib", 10000}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };                
    };
    ["OpenLevel109"] = 
    {
        [1] = {
            [1] = {[1] = 1, [2] = {{"item", 3755, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},      
        };
        [2] = {
            [1] = {[1] = 2, [2] = {{"item", 3759, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},
        };
        [3] = {
            [1] = {[1] = 3, [2] = {{"item", 3763, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},
        };
        [4] = {
            [1] = {[1] = 10, [2] = {{"item", 3180, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
        [5] = {
            [1] = {[1] = 50, [2] = {{"item", 2165, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
        [6] = {
            [1] = {[1] = 100, [2] = {{"Contrib", 10000}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };                
    };
    ["OpenLevel119"] = 
    {
        [1] = {
            [1] = {[1] = 1, [2] = {{"item", 7444, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},      
        };
        [2] = {
            [1] = {[1] = 2, [2] = {{"item", 7447, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},
        };
        [3] = {
            [1] = {[1] = 3, [2] = {{"item", 7450, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},
        };
        [4] = {
            [1] = {[1] = 10, [2] = {{"item", 3180, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
        [5] = {
            [1] = {[1] = 50, [2] = {{"item", 2165, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
        [6] = {
            [1] = {[1] = 100, [2] = {{"Contrib", 10000}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };                
    };
    ["OpenLevel129"] = 
    {
        [1] = {
            [1] = {[1] = 1, [2] = {{"item", 7445, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},      
        };
        [2] = {
            [1] = {[1] = 2, [2] = {{"item", 7448, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},
        };
        [3] = {
            [1] = {[1] = 3, [2] = {{"item", 7451, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},
        };
        [4] = {
            [1] = {[1] = 10, [2] = {{"item", 3180, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
        [5] = {
            [1] = {[1] = 50, [2] = {{"item", 2165, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
        [6] = {
            [1] = {[1] = 100, [2] = {{"Contrib", 10000}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };                
    };
    ["OpenLevel139"] = 
    {
        [1] = {
            [1] = {[1] = 1, [2] = {{"item", 10263, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},      
        };
        [2] = {
            [1] = {[1] = 2, [2] = {{"item", 10266, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},
        };
        [3] = {
            [1] = {[1] = 3, [2] = {{"item", 10269, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},
        };
        [4] = {
            [1] = {[1] = 10, [2] = {{"item", 3180, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
        [5] = {
            [1] = {[1] = 50, [2] = {{"item", 2165, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
        [6] = {
            [1] = {[1] = 100, [2] = {{"Contrib", 10000}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };                
    };
    ["OpenLevel149"] = 
    {
        [1] = {
            [1] = {[1] = 1, [2] = {{"item", 10264, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},      
        };
        [2] = {
            [1] = {[1] = 2, [2] = {{"item", 10267, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},
        };
        [3] = {
            [1] = {[1] = 3, [2] = {{"item", 10270, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},
        };
        [4] = {
            [1] = {[1] = 10, [2] = {{"item", 3180, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
        [5] = {
            [1] = {[1] = 50, [2] = {{"item", 2165, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
        [6] = {
            [1] = {[1] = 100, [2] = {{"Contrib", 10000}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };                
    };
    ["OpenLevel159"] = 
    {
        [1] = {
            [1] = {[1] = 1, [2] = {{"item", 10265, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},      
        };
        [2] = {
            [1] = {[1] = 2, [2] = {{"item", 10268, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},
        };
        [3] = {
            [1] = {[1] = 3, [2] = {{"item", 10271, 1}}, [3] = true, [4] = false, [5] = true, [6] = false},
        };
        [4] = {
            [1] = {[1] = 10, [2] = {{"item", 3180, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
        [5] = {
            [1] = {[1] = 50, [2] = {{"item", 2165, 1}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };
        [6] = {
            [1] = {[1] = 100, [2] = {{"Contrib", 10000}}, [3] = true, [4] = false, [5] = false, [6] = false},
        };                
    };
                	
}

--参与奖
--[[
    [1] = 发奖百分比，所有项总和为1;
    [2] = 奖励;
    [3] = 是否优先在大号池子中抽;
]]
ChouJiang.tbDayAVAward = 
{
    ["OpenLevel39"] = 
    {
        [1] = {[1] = 1,[2] = {{"item", 224, 1}},[3] = false},
    };
}

--大奖参与奖
ChouJiang.tbBigAVAward = 
{
    ["OpenLevel39"] = 
    {
        [1] = {[1] = 1,[2] = {{"item", 3738, 1}},[3] = false},
    };
}

-- 比如说第一天领过特等奖第二天就不能领特等奖和一等奖
ChouJiang.tbDayRejectRank = 
{
    [1] = {2};
    [2] = {1};
}

--小奖奖励展示
ChouJiang.tbDayShowAward = 
{
    {"OpenLevel39", {
        [1] = {szRankSprite = "Reword_04",szEggSprite = "icon_egg04",szCount= "共1名",tbAward = {"item", 7441, 1}};
        [2] = {szRankSprite = "Reword_01",szEggSprite = "icon_egg03",szCount= "共3名",tbAward = {"item", 2400, 1}};
        [3] = {szRankSprite = "Reword_02",szEggSprite = "icon_egg02",szCount= "共10名",tbAward = {"item", 2169, 1}};
        [4] = {szRankSprite = "Reword_03",szEggSprite = "icon_egg01",szCount= "共50名",tbAward = {"item", 5415, 1}};
        [5] = {tbAward = {"item", 224, 1}};
    }};
    {"OpenLevel69", {
        [1] = {szRankSprite = "Reword_04",szEggSprite = "icon_egg04",szCount= "共1名",tbAward = {"item", 7441, 1}};
        [2] = {szRankSprite = "Reword_01",szEggSprite = "icon_egg03",szCount= "共3名",tbAward = {"item", 2400, 1}};
        [3] = {szRankSprite = "Reword_02",szEggSprite = "icon_egg02",szCount= "共10名",tbAward = {"item", 2169, 1}};
        [4] = {szRankSprite = "Reword_03",szEggSprite = "icon_egg01",szCount= "共50名",tbAward = {"item", 5415, 1}};
        [5] = {tbAward = {"item", 224, 1}};
    }}; 
    {"OpenLevel79", {
        [1] = {szRankSprite = "Reword_04",szEggSprite = "icon_egg04",szCount= "共1名",tbAward = {"item", 7442, 1}};
        [2] = {szRankSprite = "Reword_01",szEggSprite = "icon_egg03",szCount= "共3名",tbAward = {"item", 2400, 1}};
        [3] = {szRankSprite = "Reword_02",szEggSprite = "icon_egg02",szCount= "共10名",tbAward = {"item", 2169, 1}};
        [4] = {szRankSprite = "Reword_03",szEggSprite = "icon_egg01",szCount= "共50名",tbAward = {"item", 5415, 1}};
        [5] = {tbAward = {"item", 224, 1}};
    }};
    {"OpenLevel89", {
        [1] = {szRankSprite = "Reword_04",szEggSprite = "icon_egg04",szCount= "共1名",tbAward = {"item", 2795, 1}};
        [2] = {szRankSprite = "Reword_01",szEggSprite = "icon_egg03",szCount= "共3名",tbAward = {"item", 3179, 1}};
        [3] = {szRankSprite = "Reword_02",szEggSprite = "icon_egg02",szCount= "共10名",tbAward = {"item", 2169, 1}};
        [4] = {szRankSprite = "Reword_03",szEggSprite = "icon_egg01",szCount= "共50名",tbAward = {"item", 5415, 1}};
        [5] = {tbAward = {"item", 224, 1}};
    }};
    {"OpenLevel99", {
        [1] = {szRankSprite = "Reword_04",szEggSprite = "icon_egg04",szCount= "共1名",tbAward = {"item", 2795, 1}};
        [2] = {szRankSprite = "Reword_01",szEggSprite = "icon_egg03",szCount= "共3名",tbAward = {"item", 3179, 1}};
        [3] = {szRankSprite = "Reword_02",szEggSprite = "icon_egg02",szCount= "共10名",tbAward = {"item", 2169, 1}};
        [4] = {szRankSprite = "Reword_03",szEggSprite = "icon_egg01",szCount= "共50名",tbAward = {"item", 5415, 1}};
        [5] = {tbAward = {"item", 224, 1}};
    }};
    {"OpenLevel109", {
        [1] = {szRankSprite = "Reword_04",szEggSprite = "icon_egg04",szCount= "共1名",tbAward = {"item", 2794, 1}};
        [2] = {szRankSprite = "Reword_01",szEggSprite = "icon_egg03",szCount= "共3名",tbAward = {"item", 1396, 2}};
        [3] = {szRankSprite = "Reword_02",szEggSprite = "icon_egg02",szCount= "共10名",tbAward = {"item", 3693, 1}};
        [4] = {szRankSprite = "Reword_03",szEggSprite = "icon_egg01",szCount= "共50名",tbAward = {"item", 5415, 1}};
        [5] = {tbAward = {"item", 224, 1}};
    }};
    {"OpenLevel119", {
        [1] = {szRankSprite = "Reword_04",szEggSprite = "icon_egg04",szCount= "共1名",tbAward = {"item", 6148, 1}};
        [2] = {szRankSprite = "Reword_01",szEggSprite = "icon_egg03",szCount= "共3名",tbAward = {"item", 1396, 2}};
        [3] = {szRankSprite = "Reword_02",szEggSprite = "icon_egg02",szCount= "共10名",tbAward = {"item", 2169, 1}};
        [4] = {szRankSprite = "Reword_03",szEggSprite = "icon_egg01",szCount= "共50名",tbAward = {"item", 5415, 1}};
        [5] = {tbAward = {"item", 224, 1}};
    }};
    {"OpenLevel129", {
        [1] = {szRankSprite = "Reword_04",szEggSprite = "icon_egg04",szCount= "共1名",tbAward = {"item", 6148, 1}};
        [2] = {szRankSprite = "Reword_01",szEggSprite = "icon_egg03",szCount= "共3名",tbAward = {"item", 2804, 10}};
        [3] = {szRankSprite = "Reword_02",szEggSprite = "icon_egg02",szCount= "共10名",tbAward = {"item", 2169, 1}};
        [4] = {szRankSprite = "Reword_03",szEggSprite = "icon_egg01",szCount= "共50名",tbAward = {"item", 5415, 1}};
        [5] = {tbAward = {"item", 224, 1}};
    }};
    {"OpenLevel139", {
        [1] = {szRankSprite = "Reword_04",szEggSprite = "icon_egg04",szCount= "共1名",tbAward = {"item", 6148, 1}};
        [2] = {szRankSprite = "Reword_01",szEggSprite = "icon_egg03",szCount= "共3名",tbAward = {"item", 7067, 1}};
        [3] = {szRankSprite = "Reword_02",szEggSprite = "icon_egg02",szCount= "共10名",tbAward = {"item", 2804, 5}};
        [4] = {szRankSprite = "Reword_03",szEggSprite = "icon_egg01",szCount= "共50名",tbAward = {"item", 5415, 1}};
        [5] = {tbAward = {"item", 224, 1}};
    }};
}

--大奖奖励展示
ChouJiang.tbBigShowAward = 
{
    {"OpenLevel39", {
        [1] = {szRankSprite = "Reword_04",szEggSprite = "icon_egg04",szCount= "共1名",tbAward = {"item", 3743, 1}};
        [2] = {szRankSprite = "Reword_01",szEggSprite = "icon_egg03",szCount= "共2名",tbAward = {"item", 3741, 1}};
        [3] = {szRankSprite = "Reword_02",szEggSprite = "icon_egg02",szCount= "共3名",tbAward = {"item", 3739, 1}};
        [4] = {szRankSprite = "Reword_03",szEggSprite = "icon_egg01",szCount= "共10名",tbAward = {"item", 3180, 1}};
        [5] = {szCount= "共50名",tbAward = {"item", 2165, 1}};
        [6] = {szCount= "共100名",tbAward = {"Contrib", 10000}};
        [7] = {tbAward = {"item", 3738, 1}};
    }};
    {"OpenLevel79", {
        [1] = {szRankSprite = "Reword_04",szEggSprite = "icon_egg04",szCount= "共1名",tbAward = {"item", 3752, 1}};
        [2] = {szRankSprite = "Reword_01",szEggSprite = "icon_egg03",szCount= "共2名",tbAward = {"item", 3756, 1}};
        [3] = {szRankSprite = "Reword_02",szEggSprite = "icon_egg02",szCount= "共3名",tbAward = {"item", 3760, 1}};
        [4] = {szRankSprite = "Reword_03",szEggSprite = "icon_egg01",szCount= "共10名",tbAward = {"item", 3180, 1}};
        [5] = {szCount= "共50名",tbAward = {"item", 2165, 1}};
        [6] = {szCount= "共100名",tbAward = {"Contrib", 10000}};
        [7] = {tbAward = {"item", 3738, 1}};
    }};
    {"OpenLevel89", {
        [1] = {szRankSprite = "Reword_04",szEggSprite = "icon_egg04",szCount= "共1名",tbAward = {"item", 3753, 1}};
        [2] = {szRankSprite = "Reword_01",szEggSprite = "icon_egg03",szCount= "共2名",tbAward = {"item", 3757, 1}};
        [3] = {szRankSprite = "Reword_02",szEggSprite = "icon_egg02",szCount= "共3名",tbAward = {"item", 3761, 1}};
        [4] = {szRankSprite = "Reword_03",szEggSprite = "icon_egg01",szCount= "共10名",tbAward = {"item", 3180, 1}};
        [5] = {szCount= "共50名",tbAward = {"item", 2165, 1}};
        [6] = {szCount= "共100名",tbAward = {"Contrib", 10000}};
        [7] = {tbAward = {"item", 3738, 1}};
    }};
    {"OpenLevel99", {
        [1] = {szRankSprite = "Reword_04",szEggSprite = "icon_egg04",szCount= "共1名",tbAward = {"item", 3754, 1}};
        [2] = {szRankSprite = "Reword_01",szEggSprite = "icon_egg03",szCount= "共2名",tbAward = {"item", 3758, 1}};
        [3] = {szRankSprite = "Reword_02",szEggSprite = "icon_egg02",szCount= "共3名",tbAward = {"item", 3762, 1}};
        [4] = {szRankSprite = "Reword_03",szEggSprite = "icon_egg01",szCount= "共10名",tbAward = {"item", 3180, 1}};
        [5] = {szCount= "共50名",tbAward = {"item", 2165, 1}};
        [6] = {szCount= "共100名",tbAward = {"Contrib", 10000}};
        [7] = {tbAward = {"item", 3738, 1}};
    }};
    {"OpenLevel109", {
        [1] = {szRankSprite = "Reword_04",szEggSprite = "icon_egg04",szCount= "共1名",tbAward = {"item", 3755, 1}};
        [2] = {szRankSprite = "Reword_01",szEggSprite = "icon_egg03",szCount= "共2名",tbAward = {"item", 3759, 1}};
        [3] = {szRankSprite = "Reword_02",szEggSprite = "icon_egg02",szCount= "共3名",tbAward = {"item", 3763, 1}};
        [4] = {szRankSprite = "Reword_03",szEggSprite = "icon_egg01",szCount= "共10名",tbAward = {"item", 3180, 1}};
        [5] = {szCount= "共50名",tbAward = {"item", 2165, 1}};
        [6] = {szCount= "共100名",tbAward = {"Contrib", 10000}};
        [7] = {tbAward = {"item", 3738, 1}};
    }};
    {"OpenLevel119", {
        [1] = {szRankSprite = "Reword_04",szEggSprite = "icon_egg04",szCount= "共1名",tbAward = {"item", 7444, 1}};
        [2] = {szRankSprite = "Reword_01",szEggSprite = "icon_egg03",szCount= "共2名",tbAward = {"item", 7447, 1}};
        [3] = {szRankSprite = "Reword_02",szEggSprite = "icon_egg02",szCount= "共3名",tbAward = {"item", 7450, 1}};
        [4] = {szRankSprite = "Reword_03",szEggSprite = "icon_egg01",szCount= "共10名",tbAward = {"item", 3180, 1}};
        [5] = {szCount= "共50名",tbAward = {"item", 2165, 1}};
        [6] = {szCount= "共100名",tbAward = {"Contrib", 10000}};
        [7] = {tbAward = {"item", 3738, 1}};
    }};
    {"OpenLevel129", {
        [1] = {szRankSprite = "Reword_04",szEggSprite = "icon_egg04",szCount= "共1名",tbAward = {"item", 7445, 1}};
        [2] = {szRankSprite = "Reword_01",szEggSprite = "icon_egg03",szCount= "共2名",tbAward = {"item", 7448, 1}};
        [3] = {szRankSprite = "Reword_02",szEggSprite = "icon_egg02",szCount= "共3名",tbAward = {"item", 7451, 1}};
        [4] = {szRankSprite = "Reword_03",szEggSprite = "icon_egg01",szCount= "共10名",tbAward = {"item", 3180, 1}};
        [5] = {szCount= "共50名",tbAward = {"item", 2165, 1}};
        [6] = {szCount= "共100名",tbAward = {"Contrib", 10000}};
        [7] = {tbAward = {"item", 3738, 1}};
    }};
    {"OpenLevel139", {
        [1] = {szRankSprite = "Reword_04",szEggSprite = "icon_egg04",szCount= "共1名",tbAward = {"item", 10263, 1}};
        [2] = {szRankSprite = "Reword_01",szEggSprite = "icon_egg03",szCount= "共2名",tbAward = {"item", 10266, 1}};
        [3] = {szRankSprite = "Reword_02",szEggSprite = "icon_egg02",szCount= "共3名",tbAward = {"item", 10269, 1}};
        [4] = {szRankSprite = "Reword_03",szEggSprite = "icon_egg01",szCount= "共10名",tbAward = {"item", 3180, 1}};
        [5] = {szCount= "共50名",tbAward = {"item", 2165, 1}};
        [6] = {szCount= "共100名",tbAward = {"Contrib", 10000}};
        [7] = {tbAward = {"item", 3738, 1}};
    }};
    {"OpenLevel149", {
        [1] = {szRankSprite = "Reword_04",szEggSprite = "icon_egg04",szCount= "共1名",tbAward = {"item", 10264, 1}};
        [2] = {szRankSprite = "Reword_01",szEggSprite = "icon_egg03",szCount= "共2名",tbAward = {"item", 10267, 1}};
        [3] = {szRankSprite = "Reword_02",szEggSprite = "icon_egg02",szCount= "共3名",tbAward = {"item", 10270, 1}};
        [4] = {szRankSprite = "Reword_03",szEggSprite = "icon_egg01",szCount= "共10名",tbAward = {"item", 3180, 1}};
        [5] = {szCount= "共50名",tbAward = {"item", 2165, 1}};
        [6] = {szCount= "共100名",tbAward = {"Contrib", 10000}};
        [7] = {tbAward = {"item", 3738, 1}};
    }};
    {"OpenLevel159", {
        [1] = {szRankSprite = "Reword_04",szEggSprite = "icon_egg04",szCount= "共1名",tbAward = {"item", 10265, 1}};
        [2] = {szRankSprite = "Reword_01",szEggSprite = "icon_egg03",szCount= "共2名",tbAward = {"item", 10268, 1}};
        [3] = {szRankSprite = "Reword_02",szEggSprite = "icon_egg02",szCount= "共3名",tbAward = {"item", 10271, 1}};
        [4] = {szRankSprite = "Reword_03",szEggSprite = "icon_egg01",szCount= "共10名",tbAward = {"item", 3180, 1}};
        [5] = {szCount= "共50名",tbAward = {"item", 2165, 1}};
        [6] = {szCount= "共100名",tbAward = {"Contrib", 10000}};
        [7] = {tbAward = {"item", 3738, 1}};
    }};
}


for i,v in ipairs(ChouJiang.tbExecuteDay) do
	assert(ChouJiang.tbDayLotteryDate[v],"no lottery day setting")
end

function ChouJiang:GetLastExeDay(nStartTime)
    local nLastExeDay = 0
    local tbExecuteDay = ChouJiang.tbExecuteDay
    local nPassDay = self:GetPassDay(nStartTime)
    if nPassDay < 0 then
       return nLastExeDay
    end
    local tbTime = Lib:SplitStr(ChouJiang.szDayTime, ":")
    local nHour,nMin = unpack(tbTime)
    local tbNowTime = os.date("*t", GetTime());
    local nNowHour,nNowMin = tbNowTime.hour, tbNowTime.min
    local bCross = (nNowHour * 60 * 60 + nNowMin * 60) >= (nHour * 60 * 60 + nMin * 60)
    local nHitIndex = 0
    for nIndex,nExecuteDay in ipairs(tbExecuteDay) do
        if nPassDay <= nExecuteDay then
            nLastExeDay = nExecuteDay
        	nHitIndex = nIndex
            break
        end
    end
    -- 抽奖当天过了抽奖时间点，往前推进一个抽奖点
    nLastExeDay = (bCross and nPassDay == nLastExeDay) and (tbExecuteDay[nHitIndex + 1] or 0) or nLastExeDay
    return nLastExeDay
end

-- 以活动开始时间做校准的天数，活动开始那一天算第一天
function ChouJiang:GetPassDay(nStartTime)
	nStartTime = nStartTime or 0
    local nPassDay = -1
    if nStartTime == 0 then
        return nPassDay
    end
    local nNowDay = Lib:GetLocalDay()
    local nStartDay = Lib:GetLocalDay(nStartTime)
    local nPassDay = nNowDay - nStartDay + 1                        -- 活动第几天
    return nPassDay
end

function ChouJiang:GetRankDes(nRank)
    nRank = nRank - 1
    if nRank == 0 then
        return "特等奖"
    end
    if nRank < 0 then
        return "未知"
    end
    local szRank = Lib:Transfer4LenDigit2CnNum(nRank) or "未知"
    return string.format("%s等奖", szRank)
end

function ChouJiang:GetAwardSetting(tbFrameAward)
    local szFrame = Lib:GetMaxTimeFrame(tbFrameAward)
    return tbFrameAward[szFrame]
end

