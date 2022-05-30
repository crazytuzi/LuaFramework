MonopolyConst = MonopolyConst or {}

MonopolyConst.Tile_Width = 64   -- 格子宽度（对角线）
MonopolyConst.Tile_Height = 32  -- 格子高度（对角线）

MonopolyConst.Board_Width = 2895 	-- 棋盘（格子区域）宽度
MonopolyConst.Board_Height = 1785	-- 棋盘（格子区域）高度

MonopolyConst.Move_Speed = 150  -- 角色移动速度

-- 格子事件定义
MonopolyConst.Event_Type = {
    Normal = 1,     -- 普通地面
    Trap = 2,       -- 陷阱
    Award = 3,      -- 南瓜大礼包
    Morra = 4,     -- 强者的对决
    Dialog = 5,    -- 神秘事件
    Redbag = 6,     -- 天降红包
    Boss = 7,       -- 大BOSS
    Advance = 8,    -- 前进
    Buff = 9,       -- 伏特加
    Wish = 10,      -- 祝福
    Medicine = 11,  -- 魔女的药锅
    End = 12,       -- 终点
    Flag = 13,      -- flag
    Start = 14,     -- 起点
}

-- 排行榜tab按钮类型定义
MonopolyConst.Rank_Type = {
    Guild = 1, -- 联盟排行
    Personal = 2, -- 个人排行
    Award = 3, -- 奖励一览
}

MonopolyConst.Sub_Type = {
    Step_1 = 1, -- 阶段一
    Step_2 = 2, -- 阶段二
    Step_3 = 3, -- 阶段三
    Step_4 = 4, -- 阶段四
    Boss = 5,   -- boss
}

-- 大富翁buff定义
MonopolyConst.Buff_Info = {
    [1] = {"monopolyboard_1020", 8}, -- 伤害加成buff
    [2] = {"monopolyboard_1021", 10}, -- 战斗胜利buff
    [3] = {"monopolyboard_1022", 9}, -- 奖励翻倍buff
    [4] = {"monopolyboard_1023", 11}, -- flag
}