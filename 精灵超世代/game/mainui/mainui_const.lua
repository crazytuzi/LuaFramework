MainuiConst = MainuiConst or {}

--- ui的战斗类型.......
MainuiConst.ui_fight_type = {
    normal = 0,
    main_scene = 1,
    partner = 2, 
    backpack = 3,
    drama_scene = 4,
    sky_scene = 5,
    boss = 6,
    starlife = 7,
    arena = 8,
    guild_dun = 9,
    star_tower = 10,
    endless = 11,
    sandybeachBossFight = 12, --沙滩争夺战 沙滩保卫战
    escort = 13,
    dungeon_stone = 14,
    godbattle = 15,
    hallows = 16,
    guildwar = 17, 
    primusWar = 18,
    ladderwar = 19,
    expedit_fight = 20,
    yaunzhen_fight = 21,

    eliteMatchWar = 23, --精英赛ui
    -- eliteKingMatchWar = 24, --王者赛ui

    elementWar = 25, -- 元素圣殿
    heavenwar = 27, -- 天界副本
    crossarenawar = 28, -- 跨服竞技场
    limit_exercise = 29, -- 试炼之境
    adventrueMine = 30, -- 秘矿冒险
    crosschampion = 31, -- 跨服冠军赛
    termbegins = 32, -- 开学季ui类型

    guildsecretarea = 34, --公会秘境ui类型
    areanTeam = 35, -- 组队竞技场
    trainingcamp = 36,  -- 新手训练营

    monopolywar_1 = 101, -- 大富翁第一阶段
    monopolywar_2 = 102, -- 大富翁第二阶段
    monopolywar_3 = 103, -- 大富翁第三阶段
    monopolywar_4 = 104, -- 大富翁第四阶段
    monopolyboss  = 105, -- 大富翁boss
    planeswar = 40,      -- 位面
    yearmonsterwar = 39,      -- 年兽
    whitedaywar = 41,      -- 女神试炼
    areanmanypeople = 42,      -- 多人竞技场
    practisetower = 43,    -- 试练塔活动
}

--- 主ui的下表标签,跟配置function_data.base_data 一致
MainuiConst.btn_index = {
    main_scene = 1,                 -- 主城
    partner = 2,                    -- 宝可梦
    backpack = 3,                   -- 背包
    drama_scene = 4,                -- 剧情
    esecsice = 5,                   -- 历练
    guild = 6,                      -- 联盟
    hallows = 7,                    -- 神器
    sky_scene = 990,                -- 废弃
    boss = 991,                     --
    upgrade = 992,                  --
    recharge = 993,                 --
    assistant = 994,                --
    gemstone = 996,                 --
}

MainuiConst.icon = {
    friend = 1,                 --好友
    mail = 2,                   --邮件
    daily = 3,                  --日常
    stronger = 4,               --我要变强
    rank = 5,                   -- 排行榜
    vedio = 6,                  -- 录像馆
    charge = 10,                -- 充值
    WeekAction = 11,              -- 周活动
    welfare = 12,               --福利
    action = 13,                 --活动
    champion = 14,              -- 冠军赛
    festival = 15,            -- 节日活动
    crosschampion = 16,         -- 跨服冠军赛
    escort = 17,                -- 护送图标
    godbattle = 18,             -- 众神战场
    godpartner = 19,             -- 神将折扣
    dungeon_double_time = 20,    -- 双倍时间
    combine = 21,             -- 合服活动
    guildwar = 22,
    ladder = 23,                -- 跨服天梯
    ladder_2 = 24,              -- 天梯
    limit_time_btn = 25,              -- 限时玩法按钮
    peak_champion = 26,              -- 巅峰冠军赛
    free_capture = 27,          -- 免费捕捉
    scanning = 30,              -- 战盟扫一扫
    download = 100,             -- 边玩边下
    seven_rank = 108,           --7天排行
    crossserver_rank = 109,     --跨服排行
    certify = 110,      -- 实名认证
    oppo_gotocommunity = 111, --oppo专属渠道icon
    skin_direct_purchase = 134, -- 皮肤直购icon
    day_first_charge = 501,     --每日首充
    first_charge = 502,         --首冲(旧版本)
    seven_goal = 503,   --七天目标(1--7)
    limit_recruit = 504, --限时招募
    seven_login = 505,          --七天登录
    limit_gift_entry = 506,     -- 限时礼包入口 升星礼包 和 等级礼包
    fund = 507,         -- 基金
    eight_login = 508,          --八天登录
    first_charge_new = 512,     --首冲(新版本 人物3选1的)
    open_server_recharge = 513, --开服小额充值
    first_charge_new1 = 522,     --首冲(新版本 人物是耶梦加得的)
    first_charge_new2 = 523,     --首冲(新版本 人物是利维坦的)
    first_charge_new3 = 524,     --首冲(6元送耶梦加得，100元送利维坦)
    one_cent_gift = 530,          --战力飞升礼包(0.1元礼包)
    one_yuan_gift = 531,          --战力飞升礼包(1元礼包)
    personal_gift = 802, --个人推送
    special_vip = 803, --9377 vip
    limit_time_gift = 804, -- 限时钜惠礼包
    monopoly = 805, -- 大富翁(圣夜奇境)
    return_action = 806, --回归活动
    year_monster  = 807,  --年兽按钮
    rfm_personnal_gift = 809,  --rfm个推礼包
    perfer_icon = 811, --代金券
    arena_many_people = 812,  --多人竞技场
    icon_firt1 = 900,           --首冲(3星雅典娜)
    icon_firt2 = 901,           --首冲
    icon_firt3 = 902,           --首冲
    icon_firt4 = 903,           --首冲
    icon_firt5 = 904,           --首冲
    icon_charge1 = 905,         --首冲
    icon_charge2 = 906,         --首冲
    day_charge = 907,           -- 每日充值
    festval = 908,               -- 普通节日登录
    combine_login = 909,         -- 合服登陆福利
    direct_gift = 1001,          --直购礼包
    lucky_treasure = 1002, --幸运探宝
    preferential = 1003,         -- 特惠礼包（3星直升礼包丁奥）
    other_preferential = 1004,
    festval_spring = 1101,       -- 春节登录
    festval_lover = 1102,        -- 情人节登录
    seven_goal1 = 1503,   --七天目标(8--14)
    seven_goal2 = 2503,   --七天目标(15--21)
    seven_goal3 = 3503,   --七天目标(22--28)
    seven_goal4 = 4503, --(七天目标)星梦奇缘
}

---部分页面的跳转需要进到主城中去
MainuiConst.sub_type = {
    arena_call = 1,
    dungeon_auto = 2,
    partner_zhenfa = 3,
    forge_house = 4, -- 锻造屋
    guild_boss = 5,
    guild_skill = 501, --公会技能界面
    startower = 6,
    partnersummon = 7,
    champion_call = 8,
    endless = 9,
    escort = 10,
    dungeonstone = 11,
    endless = 12,
    wonderful = 13,
    godbattle = 14,
    world_boss = 15,
    function_icon = 16,      -- 跳转特殊点击图标操作
    limit_action = 17,
    guildwar = 18,
    primuswar = 19,
    ladderwar = 20,
    expedit_fight = 21,  -- 远征
    adventure = 22,         -- 冒险
    -- adventruemine = 96,         -- 矿脉冒险

    eliteMatchWar = 23, --精英赛ui
    -- eliteKingMatchWar = 24, --王者赛赛ui

    seerpalace = 25, --先知殿
    elementWar = 26, --元素圣殿
    heavenwar = 27,  -- 天界副本
    crossarenawar = 28, -- 跨服竞技场
    limitexercise = 29, -- 试炼之境
    homeworld = 30, -- 家园
    crosschampion = 31, -- 跨服竞技场
    peakchampion = 37, -- 巅峰冠军赛

    guildsecretarea = 34, -- 跨服竞技场
    arenateam = 35,  -- 组队竞技场
    planeswar = 40, --位面
    whitedaywar = 41, --女神试炼

    arenamanypeople = 42, --多人竞技场

    planes_rank = 80, --位面迷踪(活动)

    monopolywar_1 = 89,       -- 大富翁阶段一
    monopolywar_2 = 88,       -- 大富翁阶段一
    monopolywar_3 = 87,       -- 大富翁阶段一
    monopolywar_4 = 86,       -- 大富翁阶段一
    monopolyboss  = 85,       -- 大富翁boss

    limitexercise = 99,  --试练之境
    termbegins = 98,     --开学季
    termbeginsboss = 97, --开学季boss
    adventruemine = 96,  -- 矿脉冒险
}


--- 主ui图标分主要部分,包括下面6个以及充值,另外就是function_data那些.
MainuiConst.function_type = {
    main = 1,
    other = 2
}

-- 0结束，1开始， 2准备
MainuiConst.icon_status = {
    over = 0,
    prepare = 1,
    start = 2
}

MainuiConst.item_exhibition_type = {
    item_type =  1, --道具类型 默认是这个
    partner_type = 2 -- 伙伴类型 
}

-- 通用的获得物品界面，打开来源
MainuiConst.item_open_type = {
    normal = 1,     -- 普通
    seerpalace = 2, -- 先知召唤获得
    heavendial = 3, -- 神装转盘
}

