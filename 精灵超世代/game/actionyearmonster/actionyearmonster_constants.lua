-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      年兽活动 后端 国辉  策划 中建
-- <br/>Create: 2020-01-03
-- --------------------------------------------------------------------
ActionyearmonsterConstants = ActionyearmonsterConstants or {}


ActionyearmonsterConstants.Move_Speed = 300

-- ActionyearmonsterConstants.TabType = {
--     eChapter = 1 , -- 关卡页签
--     eBoss    = 2 , -- boss页签
-- }


-- 格子事件类型定义
ActionyearmonsterConstants.Evt_Type = {
    Normal          = 0,    -- 空事件
    Monster         = 1,    -- 怪物
    Start           = 2,    -- 出生点
    Board           = 3,    -- 广告牌 告示牌
    Goods           = 4,    -- 获得道具
    Dialog          = 5,    -- 奖励NPC对话
    DesBarrier      = 6,    -- 可破坏的障碍物
    Barrier         = 7,    -- 不可破坏的障碍物
    Character       = 8,    -- 获取文字
    Tribute         = 9,    -- 获取贡品  (和获取道具一样)
    Fireworks       = 10,   -- 获取烟花  (和获取道具一样)
    RedBag          = 11,   -- 获取红包
    YearMonster     = 12,   -- 年兽 
    GoldYearMonster = 13,   -- 黄金年兽     
    YearMonster_nothit = 14,   -- 年兽(不可挑战)     
    GoldYearMonster_nothit = 15,   -- 黄金年兽 (不可挑战)    
}


-- 23104 协议中参数类型定义
ActionyearmonsterConstants.Proto_28203 = {
    _1 = 1,  --  战斗阵法
    _2 = 2,  --  战斗神器
    _3 = 3,  --  战斗自己的宝可梦
    _4 = 4, --   跳过战斗
    -- _5 = 5, -- 对话选项
    -- _6 = 6, -- 战斗阵法
    -- _7 = 7, -- 战斗神器
    -- _8 = 8, -- 战斗宝可梦id
    -- _9 = 9, -- buff_id
    -- _10 = 10, -- 租借宝可梦id
    -- _11 = 11, -- 战斗租借宝可梦id
}


-- 28205 协议中参数类型定义
ActionyearmonsterConstants.Proto_28205 = {
    Board       = 1,    --  告示牌id
    Dialog      = 2,  --  npc对话id
    DesBarrier  = 3,  --  可破坏道具
    Goods       = 4,  --    背包道具
    YearMonster       = 5,  --    大年兽
    GoldYearMonster       = 6,  --    金年兽
}

ActionyearmonsterConstants.evt_redbag = 10701 -- 红包id

ActionyearmonsterConstants.evt_limit_monster_not_hit = 19001 -- 限时年兽主格子(不可挑战)
ActionyearmonsterConstants.evt_limit_monster_hit = 19003 -- 限时年兽主格子(可挑战)
ActionyearmonsterConstants.evt_gold_monster_not_hit = 19051 -- 金色年兽主格子(可挑战)
ActionyearmonsterConstants.evt_gold_monster_hit = 19053 -- 金年兽主格子(可挑战)

ActionyearmonsterConstants.evt_limit_monster_not_hit_2 = 19002 -- 限时年兽副格子(不可挑战)
ActionyearmonsterConstants.evt_limit_monster_hit_2 = 19004 -- 限时年兽副格子(可挑战)
ActionyearmonsterConstants.evt_gold_monster_not_hit_2 = 19052 -- 金色年兽副格子(可挑战)
ActionyearmonsterConstants.evt_gold_monster_hit_2 = 19054 -- 金年兽富格子(可挑战)

