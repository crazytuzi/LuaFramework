-- --------------------------------------------------------------------
-- 主城用到的一些常量
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
CenterSceneBuild = {
    shop          = 1,            --商城
    mall          = 2,            --锻造屋
    arena         = 3,            --竞技场
    startower     = 4,            --星命塔
    summon        = 5,            --召唤
    guild         = 7,            --公会
    seerpalace    = 8,            --先知殿
    library       = 9,            --图书馆
    variety       = 10,           --杂货店
    adventure     = 11,           --冒险副口
    ladder        = 12,           --跨服天梯
    crossshow     = 13,           --跨服时空
    home          = 14,           --家园
    resonate      = 15,           --共鸣水晶
    luckytreasure = 16,           --幸运探宝

-- 以下为旧的
    study       = 666,            --观星 --暂时不用
    fuse        = 6,            --融合祭坛-- 入口已删
}

MainSceneWharf = {
    awards = 1,
    monster = 2
}

BuildItemType = {
	build = 1,
	effect = 2,
	npc = 3,
    image = 4,
}

SceneId = {
    main_scene = 1,        -- 主城
}

MainSceneStatus = {
    none = 0,
    main_scene = 1,         -- 主城
    dungeon_scene = 2,      -- 世界地图,剧情副本
    abyss_scene = 3,        -- 深渊地图
    guildwar_scene = 4,     -- 公会战地图
    expedition_scene = 5,   -- 远征地图
    godbattle_scene = 6,    -- 众神战场
    role_scene = 7,         -- 角色移动的地图
    bigworld_scene = 8,     -- 大世界
}

-- 资源兑换的
AlchemyType = {
    coin = 1,               -- 金币标签
    exp = 2,                -- 宝可梦经验标签
    energy = 3,             -- 体力
}

-- 红点来源
RedPointType = {
    item = 1,               -- 道具计算
    server = 2,             -- 服务器
    guild_donate = 3,       -- 公会捐献
    guild_red = 4,          -- 公会红包
    guild_member_red = 5,   -- 公会成员红包
    guild_join = 6,         -- 公会申请
    guild_war = 7,          -- 公会战
    guild_tech_gift = 8,    -- 公会科技礼包
    guild_lev_gift = 9,     -- 公会等级礼包
    guild_boss = 10,        -- 公会boss挑战
    guild_wish = 11,        -- 公会许愿
    guild_daily = 12,       -- 公会每日
    endless = 13,           -- 无尽试炼
    dungeonstone = 14,      -- 日常任务
    escort = 15,            -- 护送,拥有次数
    escort_awards = 16,     -- 可领取奖励
    escort_plunder = 17,    -- 被掠夺
    activity_guildboss = 18, -- 公会
    change_boss = 19, -- 挑战boss
    primus   = 20, -- 星河神殿
    heroexpedit = 21, -- 远征
}

MainSceneDataKey = {
    ["verifyios"] = "config.verifyios_main_scene_data",
    ["normal"] = "config.main_scene_data",
    ["special"] = "config.special_main_scene_data"
}