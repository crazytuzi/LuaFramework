GuildConst = GuildConst or {} 

-- 公会初始窗体的标签页下表
GuildConst.init_type = {
    create = 1,
    list = 2,
    serach = 3
}

GuildConst.list_type = {
    total = 1,
    search = 2
}

GuildConst.post_type = {
    leader = 1,     -- 会长
    assistant = 2,  -- 副会长
    member = 3      -- 普通成员
}

-- 公会相关红点的处理
GuildConst.red_index = {
    apply = 1,              -- 公会申请
    boss_times = 2,         -- 公会副本挑战次数
    boss_kill = 3,          -- 公会副本击杀宝箱
    boss_first = 4,         -- 公会副本首通
    donate = 5,             -- 捐献
    voyage_escort = 6,      -- 远航护送
    voyage_interaction = 7, -- 远航互助
    voyage_order = 8,       -- 登录的时候订单
    voyage_temp_escort = 9, -- 零时的护送红点
    donate_activity = 10,   -- 公会捐献宝箱
    red_bag = 12,           -- 公会红包
    goal_action = 13,       -- 公会活跃
    guildwar_match = 14,    -- 公会战匹配成功
    guildwar_start = 15,    -- 公会战开战
    guildwar_count = 16,    -- 公会战挑战次数
    guildwar_log = 17,      -- 公会战日志
    guildwar_box = 18,      -- 公会战宝箱
    notice = 19,            -- 公会公告
    skill_2 = 1002,         -- 公会技能
    skill_3 = 1003,         -- 公会技能
    skill_4 = 1004,         -- 公会技能
    skill_5 = 1005,         -- 公会技能
    pvp_skill_2 = 2002,     -- 公会pvp技能
    pvp_skill_3 = 2003,     -- 公会pvp技能
    pvp_skill_4 = 2004,     -- 公会pvp技能
    pvp_skill_5 = 2005,     -- 公会pvp技能
    guild_secret_area = 20, -- 公会秘境 
    all_skill = 21,         -- 公会所有技能每天首次
}

GuildConst.status = {
	normal = 0,
	un_activity = 1,
	activity = 2,
	finish = 3
}

--公会下标类型
GuildConst.show_type = {
    all = 0,            -- 全部
    guild_war = 1,      -- 公会战情况
    guild_donate = 2,   -- 公会捐献情况
    guild_voyage = 3    -- 公会副本情况
} 

--公会图标类型
GuildConst.icon_type = {
    guild_icon_type_1 = 1,      -- 公会秘境
    guild_icon_type_2 = 2,      -- 公会技能
    guild_icon_type_3 = 3,      -- 公会宝库
    guild_icon_type_4 = 4,       -- 公会副本
    guild_icon_type_5 = 5,      -- 公会商店
    guild_icon_type_6 = 6,       -- 公会战
    guild_icon_type_7 = 7,       -- 公会活跃
    guild_icon_type_8 = 8,       -- 公会捐献
    guild_icon_type_9 = 9       -- 公会红包
} 