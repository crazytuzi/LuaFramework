-- --------------------------------------------------------------------
-- 众神战场一些常量配置
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------

GodBattleConstants = GodBattleConstants or {}

--- 阵容常量
GodBattleConstants.camp = {
    god = 1,
    devil = 2
}

--- 战场中的效果
GodBattleConstants.buff = {
    normal = 0,             -- 普通
    cont_win = 1,           -- 边胜（变身)
    cont_lose = 2,          -- 边败（特效)
    legendary = 3,          -- 超神（特效)
    camp_change = 9,        -- 阵营落后（变身)
}

--- 众神之战的报名面板类型
GodBattleConstants.panel_type = {
    apply = 1,              -- 准备阶段的报名面板
    resurgence = 2,         -- 阵亡复活时候的报名面板
}

--- 众神之战的报名状态
GodBattleConstants.apply_status = {
    un_apply = 0,           -- 未报名
    apply = 1,              -- 已报名
    in_game = 2,            -- 活动中
    auto_enter = 3,         -- 自动进入
}

--- 众神之战的角色更新状态类型
GodBattleConstants.update_type = {
    total = 0,              -- 全部
    add = 1,                -- 增加
    update = 2,             -- 更新
    do_nil = 3,             -- 更新角色事件
}

GodBattleConstants.role_status = {
    normal = 0,             -- 角色状态
    fight = 1,              -- 战斗
    stop = 2,               -- 眩晕
}
