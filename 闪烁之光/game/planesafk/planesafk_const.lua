-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      位面改版 参考afk的 后端 国辉 策划 中建
-- <br/>Create: 2020-02-05
-- --------------------------------------------------------------------
PlanesafkConst = PlanesafkConst or {}


-- 格子大小
PlanesafkConst.Grid_Width = 184
PlanesafkConst.Grid_Height = 140



-- 格子事件类型定义
PlanesafkConst.Evt_Type = {
    Normal = 0,      -- 空事件
    Monster = 1,     -- 怪物
    Guard = 2,       -- 守卫
    Recover = 3,     -- 英雄恢复(回复泉水)
    Revive = 4,      -- 英雄恢复(复活祭坛)
    LeaseHero = 5,   -- 租借英雄
    Buff = 6,        -- 可选buff列表 遗物
    Businessman = 7, -- 商人
    Occurrence = 8,  -- 矿点
}

-- buff 品质
PlanesafkConst.Buff_Quility = {
    Blue = 1,   -- 蓝
    Purple = 2, -- 紫
    Orange = 3, -- 橙
}

-- 23104 协议中参数类型定义
PlanesafkConst.Proto_28600 = {
    _1 = 1, -- 战斗阵法
    _2 = 2, -- 战斗神器
    _3 = 3, -- 战斗英雄id
    _4 = 4, -- 战斗租借英雄id
    _5 = 5, -- 选择遗物
    _6 = 6, -- 商人点击前往
    _7 = 7, -- 商人购买
    _8 = 8, -- 商人点击离开
    _9 = 9, -- 租借选择英雄id
}

-- 回复泉水的配置id
PlanesafkConst.Recover_Id = 9951
-- 复活祭坛的配置id
PlanesafkConst.Revive_Id = 9901

