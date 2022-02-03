PlanesConst = PlanesConst or {}

-- 地图场景默认大小
PlanesConst.Map_Width = 7000
PlanesConst.Map_Height = 2000

-- 格子大小
PlanesConst.Grid_Width = 192
PlanesConst.Grid_Height = 96

-- 角色移动速度
PlanesConst.Move_Speed = 200

-- 显示角色周围4X4的格子
PlanesConst.Grid_Round = 9

-- 副本状态定义
PlanesConst.Dun_Status = {
    Chose = 1,  -- 待选择
    Select = 2, -- 已选择
    Close = 3,  -- 关闭
    Lock = 4,   -- 未解锁
}

-- 格子事件类型定义
PlanesConst.Evt_Type = {
    Normal = 0,     -- 空事件
    Monster = 1,    -- 怪物
    Guard = 2,      -- 守卫
    Box = 3,        -- 宝箱
    Start = 4,      -- 出生点
    Board = 5,      -- 广告牌
    Goods = 6,      -- 获得道具
    Recover = 7,    -- 英雄恢复(回复泉水)
    Portal = 8,     -- 传送门
    LeaseHero = 9,  -- 租借英雄
    Dialog = 10,     -- 奖励NPC对话
    DesBarrier = 11,-- 可破坏的障碍物
    Switch = 12,    -- 开关
    Stage = 13,     -- 升降台
    Barrier = 14,   -- 不可破坏的障碍物
    Buff = 15,      -- 可选buff列表
    Revive = 16,    -- 英雄恢复(复活祭坛)
    
}

-- 事件状态
PlanesConst.Evt_State = {
    Doing = 1, -- 未完成
    Down = 2,  -- 已完成
    None = 3,  -- 无事件
}

-- buff 品质
PlanesConst.Buff_Quility = {
    Blue = 1,   -- 蓝
    Purple = 2, -- 紫
    Orange = 3, -- 橙
}

-- 23104 协议中参数类型定义
PlanesConst.Proto_23104 = {
    _4 = 4, -- 对话id
    _5 = 5, -- 对话选项
    _6 = 6, -- 战斗阵法
    _7 = 7, -- 战斗神器
    _8 = 8, -- 战斗英雄id
    _9 = 9, -- buff_id
    _10 = 10, -- 租借英雄id
    _11 = 11, -- 战斗租借英雄id
}

-- 回复泉水的配置id
PlanesConst.Recover_Id = 9951
-- 复活祭坛的配置id
PlanesConst.Revive_Id = 9901
-- 升降台id
PlanesConst.Stage_Id = 1002
-- 升降开关id
PlanesConst.Switch_Id = 1003
-- 可破坏障碍id
PlanesConst.DesBarrier_Id = 1004

-- 红点
PlanesConst.Red_Index = {
    Login = 1, -- 每次登陆(还没选择副本、或选择的副本进度值未达100%)
    Award = 2, -- 首通奖励可领
}