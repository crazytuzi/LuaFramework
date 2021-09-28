--公共定义

return
{
	--拾取类型
	ePickUp_XP = 0,
	ePickUp_Item = 1,
	ePickUp_Money = 2,
	ePickUp_Prestige = 3,	--声望

	--进入场景实体类型
	eClsTypeNone = 0,
	eClsTypePlayer = 1,
	eClsTypeNpc = 2,
	eClsTypeMonster = 3,
	eClsTypeMpw = 4, --掉落
	eClsTypeMagic = 5,

	Channel_ID_Privacy	= 1,		--私聊
	Channel_ID_Team		= 2,	--队伍频道
	Channel_ID_Faction	= 3,		--帮派
	Channel_ID_World	= 4,		--世界频道(广播)
	Channel_ID_Bugle	= 5,		--小喇叭
	Channel_ID_System	= 6,		--系统公告
	Channel_ID_Area		= 7,		--附近

    -- NPC 枚举
    NPC_ID_ZHONGZHOU_DRUGSTORE      = 10389,        -- 中州药店掌柜
    NPC_ID_SHADOW_PAVILION          = 10395,        -- 幽影阁门人
    NPC_ID_DRAGON_SLIAYER           = 10396,        -- 屠龙传说接引人
    NPC_ID_WARBAND_MANAGER          = 11100,        -- 战队管理员
    NPC_ID_JINLANSHIZHE             = 10480,        -- 义结金兰

    -- NPC Option 枚举
    NPC_OPTION_OK = 1,                          -- 好的


    -------------------------------------------------------------------------
    -- 悬赏任务特殊id
    REWARD_TASK_ID_NULL                 = 31009,    -- 针对主线引导的悬赏空任务id
    -------------------------------------------------------------------------
    -- 任务完成目标
    TASK_TARGET_PUBLISH_REWARD_TASK     = 34,       -- 34	发布悬赏任务 	次数
    TASK_TARGET_ACCEPT_REWARD_TASK      = 35,       -- 35	接取悬赏任务	 次数
    TASK_TARGET_FINISH_REWARD_TASK      = 36,       -- 36	完成悬赏任务 	次数
    TASK_TARGET_GOT_REWARD_TASK         = 60,       -- 60	领取悬赏任务奖励 	次数 
    -------------------------------------------------------------------------
    
    -------------------------------------------------------------------------
    -- 怪物 id
    BROADSWORD_GRUARDS_ID               = 200,      -- 大刀侍卫[屠龙传说]

    PVP3V3_OTHER_BARTIZAN_ID            = 652,      -- 对方箭塔
    PVP3V3_OTHER_CAMP_ID                = 653,      -- 对方大营
    PVP3V3_SELF_BARTIZAN_ID             = 655,      -- 本方箭塔
    PVP3V3_SELF_CAMP_ID                 = 654,      -- 本方大营
    MULTI_GUARD_PRINCESS_ID             = 9002,     -- 多人守卫公主
    -------------------------------------------------------------------------

    -- 副本类型
    CARBON_TOWER                        = 3,
    CARBON_MULTI_GUARD                  = 5,        -- 多人守卫
    CARBON_DRAGON_SLIAYER               = 6,        -- 屠龙传说
    CARBON_MINE                         = 7,        -- 滴血挖矿
    CARBON_PRINCESS                     = 8,        -- 服务器模拟的守护公主
    CARBON_DART                         = 10,       -- 服务器模拟的运送物资

    -- 屠龙传说副本id
    DRAGON_GENERAL_GRAVE                = 6000,     -- 将军坟
    DRAGON_MACHINE_HOLE                 = 6001,     -- 机关洞
    DRAGON_SNAKE_VALLEY                 = 6002,     -- 蛇魔谷
    DRAGON_DEVIL_TEMPLE                 = 6003,     -- 逆魔古刹
    DRAGON_BLOOD_CITY                   = 6004,     -- 铁血魔城
    DRAGON_BABEL                        = 6005,     -- 通天塔
    DRAGON_ASURA_SHRINE                 = 6006,     -- 修罗神殿

    DRAGON_HUNT_ELIT_ONE                = 7201,     -- 猎杀精英一[类似将军坟]
    DRAGON_HUNT_ELIT_TWO                = 7202,
    DRAGON_HUNT_ELIT_THREE              = 7203,
    DRAGON_HUNT_ELIT_FOUR               = 7204,
    DRAGON_HUNT_ELIT_FIVE               = 7205,
    DRAGON_HUNT_ELIT_SIX                = 7206,
    DRAGON_HUNT_ELIT_SEVEN              = 7207,

    -- 邮件id
    MAIL_MULTI_GUARD                    = 59,       -- 多人守卫奖励邮件

    -- 物品 id
    -------------------------------------------------------------------------
    ITEM_ID_TOWN_SIGIL                  = 1020,     -- 镇魔符

    ITEM_ID_IRON_ORE_PURTY1             = 1301,     -- 铁矿（纯度1）
    -------------------------..1~10....------------------------------------
    ITEM_ID_IRON_ORE_PURTY10            = 1310,     -- 铁矿（纯度10）
    ITEM_ID_BLACK_IRON_ORE_PURTY1       = 1401,     -- 黑铁矿（纯度1）
    -------------------------..1~10....------------------------------------
    ITEM_ID_BLACK_IRON_ORE_PURTY10      = 1410,     -- 黑铁矿（纯度10）

    ITEM_ID_JUINOR_BOUNTY_SCROLL        = 9007,     -- 普通悬赏卷轴
    ITEM_ID_SENIOR_BOUNTY_SCROLL        = 9008,     -- 高级悬赏卷轴
    ITEM_ID_EXTREME_BOUNTY_SCROLL       = 9009,     -- 至尊悬赏卷轴

    ITEM_ID_SMART_WATER                 = 20025,    -- 金创药
    ITEM_ID_MAGIC_POTION                = 20028,    -- 魔法药
    ITEM_ID_SUN_POTION                  = 20035,    -- 太阳神水
    ITEM_ID_GREATER_SUN_POTION          = 20036,    -- 强效太阳神水

    ITEM_ID_EXP                         = 444444,   -- 经验
    ITEM_ID_PRESTIGE                    = 777777,   -- 声望

    -------------------------------------------------------------------------
    -- 坐骑ID
    RIDE_ID_GOLDEN_HORSE                = 3101,     -- 黄金宝马 [不大于此id都不可骑战]
    RIDE_ID_FLARING_FIRE_KYLIN          = 3102,     -- 炽焰麒麟
    RIDE_ID_SANTO_PANTHER               = 8888,     -- 城主黑豹
    -------------------------------------------------------------------------
    

    -- TAG
    TAG_3V3_MATCHINGOPPONENT            = 500001,   -- 竞技场匹配弹窗
    TAG_MULTI_CARBON_MASK               = 500002,   -- 多人守卫死亡过多全屏蒙蔽
    TAG_3V3_INVITE_INTO_TEAM            = 500003,   -- 3v3 邀请玩家进入队伍弹窗
    TAG_CHAR_TEXT                       = 500004,   -- 主角技能效果飘字

    TAG_RUNE_ATTACK_BUFF                = 400001,   -- 符文攻击BUFF特效
    TAG_RUNE_DEF_BUFF                   = 400002,   -- 符文防御BUFF特效
    TAG_RUNE_RECOVER_BUFF               = 400003,   -- 符文回血BUFF特效
    TAG_REWARD_TASK_DIALOG              = 400004,   -- 悬赏任务弹出的发布对话窗口
    TAG_3V3_TEAM_INFO_DIALOG            = 400005,   -- 战队信息对话框
    TAG_3V3_TEAM_ADD_MEMBER_DIALOG      = 400006,   -- 战队信息对话框
    TAG_3V3_CREATE_TEAM_DIALOG          = 400007,   -- 创建战队对话框
    TAG_3V3_RANK_ORDER_DIALOG           = 400008,   -- 战队排名对话框
    TAG_3V3_PLAYERSINFO_CONTENT         = 400009,   -- 3V3竞技场玩家状态面板上的信息节点
    PARTIAL_TAG_3V3_TEAM_INFO_DIALOG    = 400010,   -- 战队信息对话框Partial tag
    PARTIAL_TAG_EQUIP_MAKE_DIALOG_TEMP  = 100,      -- 打造界面对话窗口的tag偏移offset
    PARTIAL_TAG_SMELTER_DIALOG_TEMP     = 101,      -- 熔炼界面对话窗口的tag偏移offset
    TAG_LABEL_IN_MENU_BUTTON            = 9,        -- 按钮上label的tag
    TAG_SUB_NODE_BUTTON                 = 101,      -- 底部按钮的base tag
    TAG_INDEX_SUB_NODE_EQUIP            = 3,        -- 装备按钮的tag offset
    TAG_RED_DOT                         = 15,       -- 红点的tag
    TAG_SUB_NODE_BG                     = 15,       -- sub node的bg
    TAG_BUTTON_RONGLIAN                 = 15,       -- 熔炼按钮的tag
    TAG_BUTTON_DAZAO                    = 527,       -- 打造按钮的tag
    TAG_BUTTON_HECHENG                  = 528,       -- 合成按钮的tag
    TAG_SMELTER_NODE                    = 158,       -- 熔炼界面的tag
    TAG_RONGLIAN_SELECT_COVER           = 19,       -- 熔炼界面选择cover的tag
    TAG_SMELTER_RONGLIAN_SHOP_BTN       = 21,       -- 熔炼界面熔炼商城按钮tag
    TAG_SMELTER_RONGLIAN_SHOP_MENU      = 22,       -- 熔炼界面熔炼商城按钮Menu tag
    TAG_CHAT_PRIVATECHATLISTVIEW        = 15,       -- 私聊人名列表
    TAG_MA_DIALOG_QUESTIONANDANSWER     = 16,       -- 迷仙阵问答dialog tag
    TAG_MA_DIALOG_NAUGHTYBOX            = 17,       -- 迷仙阵小鬼抽奖dialog tag

    ZVALUE_UI = 200,                                --全屏界面层级

    --特殊地图id
    MAPID_DARTFB = 5003,                            --1-n模拟护镖
}