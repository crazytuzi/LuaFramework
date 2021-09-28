

NetMsg_ERROR =  {

  RET_ERROR = 0,
  RET_OK = 1,
  RET_SERVER_MAINTAIN = 2, --服务器维护
  RET_USER_NOT_EXIST = 3, --玩家不存在
  RET_LOGIN_REPEAT = 4, --重复登陆
  RET_USER_NAME_REPEAT = 5, --创建角色时,玩家名字重复
  RET_CHAT_OUT_OF_LENGTH = 6, -- 聊天 - 话太多
  RET_CHAT_CHAN_INEXISTENCE = 7, -- 聊天 - 频道不存在
  RET_ITEM_BAG_FULL = 8, --物品背包满
  RET_FRIEND_FULL_1 = 9, -- 自己好友已满
  RET_FRIEND_FULL_2 = 10, -- 对方好友已满
  RET_STAGEDUNGEON_OVERLIMIT = 11,--副本超过挑战次数
  RET_NOT_ENOUGH_VIT = 12,--体力不足
  RET_STAGEBOX_REWARDED = 13,--副本类宝箱奖励已经领取
  RET_FASTEXECUTE_LOCK = 14,--秒杀CD中
  RET_CHAPTERACHVRWD_ALREAD_FINISHED = 15,--章节星星奖励已经领取
  RET_NOT_ENOUGH_STAR = 16,--章节星星总数不够
  RET_CHAPTERBOX_REWARDED = 17,--章节宝箱奖励已经领取
  RET_NOT_ENOUGH_CHAPTERBOX_STAR = 18,--章节宝箱星星数不够
  RET_NOT_ENOUGH_GOLD = 19,--元宝不足
  RET_NOT_ENOUGH_MONEY = 20,--银两数量不足
  RET_KNIGHT_BAG_FULL = 21, --卡牌背包满
  RET_EQUIP_BAG_FULL = 22, --装备背包满
  RET_DUNGEON_NOT_FINISHED = 23,--副本未通过
  RET_IS_NOT_UP_TO_LEVEL = 24,--等级不够
  RET_NOT_ENOUGH_SPIRIT = 25,--精力不够
  RET_VIP_SHOP_UP_LIMIT = 26, --购买到达上限
  RET_NOT_ENOUGH_PRESTIGE = 27,--声望不够
  RET_KNIGHT_NOT_EXIST = 28,--武将不存在
  RET_CANNOT_UPGRADE_MAINROLE = 29,--主将不可强化
  RET_KNIGHT_LEVEL_EXCEED_MAINROLE = 30,--强化武将等级超过主将
  RET_MAINROLE_CANNOT_BE_UPGRADE = 31,--主将不可用作强化材料
  RET_BE_UPGRADE_KNIGHT_NOT_EXIST = 32,--强化材料武将不存在
  RET_BE_UPGRADE_KNIGHT_REPEAT = 33,--强化材料武将重复
  RET_ONTEAM_KNIGHT_CANNOT_BE_UPGRADE = 34,--出阵武将不可作为强化材料
  RET_KNIGHT_ADVANCED_LEVEL_EXCEED_LIMIT = 35,--武将升阶等级已经达到最大
  RET_KNIGHT_ADVANCED_NOT_ENOUGH_NUM = 36,--武将升阶需求卡牌数量不足
  RET_ADVANCED_COST_KNIGHT_ERR = 37,--武将升阶材料卡牌id不对
  RET_ONTEAM_KNIGHT_CANNOT_BE_ADVANCED = 38,--出阵武将不可当作升阶材料
  RET_ITEM_NUM_NOT_ENOUGH = 39,--道具数量不足
  RET_FRONT_SKILL_NOTLEARNED = 40,--前置技能未学习
  RET_SKILL_REACH_MAXLEVEL = 41,--技能达到满级
  RET_NOT_ENOUGH_SKILLPOINT = 42,--技能点不足
  RET_SKILL_NOT_FOUND = 43,--技能未找到
  RET_NOT_ENOUGH_PEER_SKILL = 44,--同类型技能不够导致无法洗技能
  RET_ILLEAGAL_SKILL_SLOT = 45,--技能槽位错误
  RET_KNIGHT_TRAINING_VALUE_EXCEED_LIMIT = 46,--武将历练值超过限制
  RET_ILLEGAL_RESET_SLOT = 47,--洗技能所洗槽位不为空
  RET_STORYDUNGEON_OVERLIMIT = 48,--剧情副本次数超过限制
  RET_SGZAWARD_ALREAD_FINISHED = 49,--三国志奖励已经领取
  RET_EQIUP_NOT_EXIST = 50, --装备不存在
  RET_EQUIP_LEVEL_EXCEED_LIMIT = 51,--装备强化等级超过限制
  RET_EQUIP_REFINING_LEVEL_EXCEED_LIMIT = 52,--装备精炼等级超过限制
  RET_ITEM_TYPE_ERROR = 53,--道具类型不对
  RET_KNIGHT_HALO_LEVEL_EXCEED_LIMIT = 54,--武将光环等级已经达到最大
  RET_KNIGHT_HALO_ADVANCE_LEVEL_NOT_REACH = 55,--武将光环等级不够
  RET_MYSTICAL_SHOP_UP_LIMIT = 56, --神秘商店购买到达上限
  RET_NOT_ENOUGH_ESSENCE = 57,  --精魄数量不足
  RET_REBEL_NOT_VAILD = 58, --叛军无效
  RET_NOT_ENOUGH_BATTLE_TOKEN = 59, --没有足够的出征令
  RET_NO_FIND_REBEL_EXPLOIT_AWARD = 60, --没找到叛军奖励ID
  RET_TREASURE_BAG_FULL = 61,  --宝物背包已满
  RET_KNIGHT_CANNOT_BE_ADVANCED = 62,--武将不能被升阶
  RET_TREASURE_NOT_EXIST = 63, --宝物不存在
  RET_BE_UPGRADE_TREASURE_REPEAT = 64,--强化材料宝物重复
  RET_TREASURE_REFINING_NOT_ENOUGH_NUM = 65,--精炼材料宝物数据不足
  RET_TREASURE_FRAGMENT_NOT_ENOUGH = 66,--宝物碎片数量不足
  RET_REBEL_NOT_PUBLIC = 67, --叛军没公开
  RET_REBEL_NOT_FRIEND = 68, --不是自己好友的叛军
  RET_TREASURE_IN_FIGHT_POSTION = 69,--宝物出阵中
  RET_TREASURE_CANNOT_STRENGTH = 70,--该宝物不能被强化或精炼
  RET_NOT_ENOUGH_MEDAL = 71,--没有足够的勋章
  RET_NOT_ENOUGH_TOWERSCORE = 72,-- 没有足够试练塔积分
  RET_ARENA_RANK_LOCK = 73,--竞技场排名已更新
  RET_EQUIP_NOT_EXIST = 74,--装备不在
  RET_NOT_SKILL_NOTENOUGH_ITEM = 75,--装备学习所需道具不足
  RET_ILLEGAL_SKILL_LEVEL = 76,--重置技能 技能等级非法
  RET_USER_DATA_LOCK = 77,--玩家数据更新中
  RET_TREASURE_FRAGMENT_ROBBED = 78,--宝物碎片已被抢夺
  RET_USER_OFFLINE = 79,-- 玩家已下线
  RET_NOT_FRIEND = 80,-- 对方不是你的好友
  RET_SCORE_SHOP_UP_LIMIT = 81, --积分商城购买到达上限
  RET_SCORE_SHOP_NO_ARENA_LIMIT = 82, --积分商城未达到竞技场排名需求
  RET_SCORE_SHOP_NO_TOWER_LIMIT = 83, --积分商城未达到闯关层数需求
  RET_VIP_DUNGEON_NOT_OPEN = 84, -- VIP副本未开启
  RET_VIP_DUNGEON_MAX_COUNT = 85, -- VIP副本次数用完
  RET_VIP_LEVEL_NOT_ENOUGH = 86, -- VIP等级不够
  RET_CHAT_HIGH_FREQUENCY = 87, -- 聊天太频繁
  RET_HUODONG_OVER = 88, -- 活动结束
  RET_MONTHCARD_ALREADY_USED = 89, -- 月卡已经使用过了
  RET_WORSHIP_CD = 90, -- 祭拜关公cd
  RET_DAILYMISSION_PROGRESS_ERROR = 91,--每日任务进度不足
  RET_DAILIYMISSION_ALREAD_FINISH = 92,--每日任务奖励已经领取
  RET_DAILIYMISSION_BOX_ALREAD_FINISH = 93,--每日任务宝箱奖励已经领取
  RET_DAILIYMISSION_BOX_NOT_ENOUGH_POINT = 94,--每日任务宝箱奖励点数不够
  RET_RESET_COUNT_MAX = 95,--重置次数达到上限
  RET_CHAT_FORBID = 96,  -- 被禁言
  RET_LOGIN_BAN_USER = 97,--被封号了
  RET_KNIGHT_LEVEL_NOT_REACH = 98,--武将等级不够
  RET_LOGIN_TOKEN_TIME_OUT = 99,
  RET_LOGIN_BAN_USER2 = 100,--不在白名单
  RET_USER_IN_FORBID_BATTLE_TIME = 101,--玩家在免战状态不能抢夺
  RET_ARENA_RANK_NOT_REACH_20 = 102,--竞技场排名20名之后不能直接挑战前10名
  RET_GIFT_CODE_ERR = 103, --错误的礼品码
  RET_VERSION_ERR = 104, --客户端版本错误
  RET_HOF_SIGN_LENGTH_ERROR = 105, --名人堂签名过长
  RET_HOF_SIGN_GOLD_ERROR = 106, --名人堂改签名元宝不足
  RET_SERVER_NOT_OPEN = 107,--服务器还未开放
  RET_FUND_BUY_TIME_EXPIRE = 108,--基金购买时间过期
  RET_FUND_BUY_REPEATE = 109,--基金购买重复
  RET_USER_NOT_BUY_FUND = 110, --玩家未购买基金
  RET_FUND_WEAL_TIME_EXPIRE = 111,--基金福利领取时间过期
  RET_FUND_HAS_AWARD = 112,--基金奖励已经领取
  RET_FUND_HAS_WEAL = 113, --基金福利已经领取
  RET_FUND_CANNOT_WEAL = 114, --基金福利领取条件未达成
  RET_ACTIVITY_STATUS_NO_PERMIT = 115, --活动奖励条件不可领取
  RET_ACTIVITY_DEC_NOT_ENOUGHT = 116, --活动奖励兑换物品不足
  RET_ACTIVITY_SELL_ALREADY_BOUGHT = 117, --活动限购已经参与
  RET_ACTIVITY_SELL_MAX = 118, --活动限购已经被抢购完了
  RET_ACTIVITY_CLOSED= 119, --活动已经结束
  RET_RIOT_ASSISTED = 120, --暴动已被解决
  RET_GC_TIME_OUT = 121,--礼品码时间过期
  RET_GC_NOT_ENOUGH_PARAM = 122, --礼品码缺少参数
  RET_GC_PARAM_ERR = 123, --参数错误
  RET_GC_ACT_CODE_NOT_USE = 124, --活动批次的码失效
  RET_GC_CODE_NOT_USE = 125, --码已经失效
  RET_GC_CODE_NOT_EXIST = 126, --码不存在
  RET_GC_ACT_TIMEOUT = 127, --活动过期
  RET_GC_CODE_USE_MORE_TIME = 128, --码超过使用次数
  RET_GC_ACT_CODE_ERR = 129, --活动游戏编码错误
  RET_GC_USER_ERR = 130, --用户名非该码绑定用户
  RET_GC_VERIFY_CODE_ERR = 131, --校验码错误
  RET_CORP_NOT_EXIST = 132, --军团不存在
  RET_CORP_NAME_ILLEGAL = 133, --非法军团名
  RET_CORP_NAME_REPEAT = 134, --军团名已存在
  RET_JOIN_CORP_EXIST= 135, --申请的军团已存在
  RET_JOIN_CORP_MAX = 136, --申请的军团数量到达上限
  RET_QUIT_CORP_INCD = 137, --退出军团时间CD中（在玩家主动退出 或者 军团长T人时候提示）
  RET_CORP_MEMBER_FULL = 138, --军团人数已满
  RET_CORP_AUTH_NO_PERMIT = 139, --军团权限不够
  RET_USER_HAS_JOINED_ANOTHER_CORP = 140, --玩家已经加入另外个军团
  RET_CORP_FRAME_DEMAND_NOT_MEET = 141, --军团边框条件不满足
  RET_CORP_VLEADER_FULL= 142, --军团副军团人数满了
  RET_DISMISS_MEMBER_ILLEGAL= 143, --军团人数大于最小解散军团人数
  RET_CORP_WORSHIP_ALREADY_DONE = 144, --已经做过军团贡献
  RET_CORP_WORSHIP_AWARD_GOT = 145, --已经领过军团贡献奖励
  RET_CORP_WORSHIP_POINT_ILLEGAL = 146, --军团贡献奖励点数不足 无法领取奖励
  RET_NOT_ENOUGH_CORP_POINT = 147, --军团点数不足
  RET_CA_AWARD_TIMES_EXCEED_LIMIT = 148, --可配置活动奖励次数超过限制
  RET_CA_AWARD_TIMES_EXCEED_SERVER_LIMIT = 149, --可配置活动全服奖励次数超过限制
  RET_CA_QUEST_ISNOT_COMPLETE = 150, --可配置活动奖励不可领取
  RET_CA_AWARD_ID_ERROR = 151, --可配置活动奖励ID错误
  RET_KNIGHT_NUM_NOT_ENOUGH = 152, --卡牌数量不足
  RET_EQUIP_NUM_NOT_ENOUGH = 153, --装备数量不足
  RET_TREASURE_NUM_NOT_ENOUGH = 154, --宝物数量不足
  RET_CA_AWARD_TIMENOT_REACH = 155, --可配置任务奖励领取时间未到
  RET_CORP_NOT_IN_EXCHANGE_TIME = 156, --弹劾军团长 时间未到
  RET_CORP_LEADER_CANNOT_QUIT = 157, --军团长不能退出军团
  RET_CORP_SHOP_REQUEST_OVERDUE = 158, --军团商店ID不存在 请求过期
  RET_USER_HAS_NO_CORP = 159, --玩家没有军团
  RET_USER_HAS_CORP = 160, --玩家已经有军团
  RET_DRESS_LEVEL_EXCEED_LIMIT = 161,--时装强化等级超过限制
  RET_DRESS_NOT_EXIST = 162,--时装不在
  RET_CORP_SHOP_HAS_BOUGHT = 163, --玩家已经购买了该军团商城道具
  RET_CORP_SET_CHAPTER_ILLEGAL = 164, --设置军团章节信息条件不足
  RET_CORP_CHAPTER_EXECUTE_MAX = 165, --最大军团副本执行次数
  RET_CORP_CHAPTER_INFORMATION_ERROR = 166, --军团副本信息错误 信息过期
  RET_CORP_CHAPTER_FINISHED = 167, --军团副本已经结束
  RET_CORP_CHAPTER_DUNGEON_NOT_FINISH = 168, --军团副本没通关
  RET_CORP_CHAPTER_DUNGEON_NO_AWARD = 169, --该玩家没有军团副本奖励
  RET_CORP_CHAPTER_AWARD_HAS_GOT = 170, --该玩家已经领取的军团副本奖励
  RET_HOLIDAY_AWARD_TIMES_EXCEED_LIMIT = 171, --节日活动领奖次数超过限制
  RET_HOLIDAY_EVENT_IS_NOT_OPEN = 172, --节日活动还未开放
  RET_ITEM_IS_EXPIRE = 173, --道具已过期
  RET_CORP_CHAPTER_AWARD_BELONG_TO_OTHERS= 174, --这个蛋已经被别人砸了
  RET_CORP_ANNOUNCEMENT_ILLEGAL = 175, --非法军团对外公告
  RET_CORP_NOTIFICATION_ILLEGAL = 176, --非法军团对内公告
  RET_GIFT_CODE_OP_TOO_FAST = 177, --礼品码操作过快
  RET_JOIN_CORP_INCD = 178, --加入军团时间CD中
  RET_JOIN_CORP_USER_REQUEST_NOT_EXIST = 179, --玩家军团申请不存在
  RET_CORP_WORSHIP_MAX_COUNT = 180, --军团祭天达到最大值
  RET_SERVER_USER_OVER_CEILING = 181, --服务器到达承载上线
  RET_CORP_SHOP_NO_LEFT = 182, --军团商城物品已经售完
  RET_DISMISS_CORP_INCD = 183, --解散军团时间CD中
  RET_VIP_DUNGEON_RESET_ERROR= 184, --无法购买日常副本次数
  RET_RECHARGE_BACK_ENDED = 185, --冲返活动已经结束
  RET_RECHARGE_BACK_REQUEST_ILLEGAL = 186, --请求过于频繁
  RET_RECHARGE_BACK_FAILED_FINISHED = 187, --冲返领取失败已经在别的服务器领取过
  RET_RECHARGE_BACK_FAILED = 188, --冲返领取失败
  RET_AWAKEN_ITEM_BAG_FULL = 189, --觉醒道具包裹已满
  RET_NOT_ENOUGH_WHEEL = 190,--转盘积分不足
  RET_NOT_ENOUGH_WHEEL_TOTAL = 191,--转盘总积分不足
  RET_AWAKEN_ITEM_NOT_ENOUGH = 192, --觉醒道具数量不足
  RET_KNIGHT_CANNOT_AWAKEN = 193, --武将不能觉醒
  RET_KNIGHT_AWAKEN_ITEM_POS_ERROR = 194, --武将觉醒道具位置不对
  RET_AWAKEN_ITEM_NOT_EXIST = 195, --觉醒道具不存在
  RET_KNIGHT_AWAKEN_LEVEL_EXCEED_LIMIT = 196, --武将觉醒等级超过限制
  RET_KNIGHT_AWAKEN_ITEM_NOT_COMPLETE = 197, --武将觉醒道具未集齐
  RET_AWAKEN_KNIGHT_NOT_ENOUGH = 198, --武将觉醒材料卡牌数量不足
  RET_AWAKEN_COST_KNIGHT_ERR = 199, --武将觉醒材料卡牌不对
  RET_ONTEAM_KNIGHT_CANNOT_BE_AWAKEN = 200, --出阵武将不可作为觉醒材料
  RET_NOT_ENOUGH_SOUL = 201,-- 没有足够神魂
  RET_CORP_REQUEST_MAX = 202,--该军团申请已满
  RET_CORP_DUNGEON_RESET_MAX = 203,--军团副本购买次数达到上限
  RET_TITLE_IN_USE = 204, --称号已装备
  RET_TITLE_IS_EXPIRED = 205, --称号已过期
  RET_NOT_ENOUGH_CONTEST_POINT= 206, --比武勋章不足
  RET_NOT_ENOUGH_CORPPOINT_TOTAL = 207,--军团点数不足
  RET_NOT_ENOUGH_CONTESTWINS_TOTAL = 208,--比武连胜次数不足
  RET_TIME_DUNGEON_NOT_OPEN = 209, --限时副本未开放
  RET_TIME_DUNGEON_IS_COMPLETED = 210, --限时副本挑战已完成
  RET_GAME_TIME_ERROR1 = 211,--转盘活动已结束
  RET_GAME_TIME_ERROR2 = 212,--大富翁活动已结束
  RET_PAY_PRICE_TYPE_NIL = 213,--未知价格类型
  RET_GAME_TIME_ERROR0 = 214,--当前没有活动开启
  RET_USER_CHAT_NOT_EXIST = 215, --在线列表中无此玩家
  RET_MAIL_LONG = 216, --邮件长度超长
  RET_HARD_CHAPTER_ROIT_ERROR = 217, --精英副本状态错误
  RET_BATTLE_TOO_FREQUENT = 218,--战斗请求太频繁
  RET_USER_RECOVER = 219,--玩家数据需要恢复
  RET_CREATE_LIMIT = 220,--同一ip建号数量达到上限
  RET_CLIENT_REQUEST_ERROR = 221, --客户端请求错误
  RET_REBEL_BOSS_NOT_OPEN = 222,--叛军BOSS活动未开启
  RET_CHALLENGE_COUNT_NOT_ENOUGH = 223, --叛军BOSS挑战次数不足
  RET_REBEL_BOSS_NOT_REPEAT_AWARD = 224, --叛军奖励已经领取
  RET_REBEL_BOSS_DIE = 225, --叛军BOSS已死亡
  RET_LOGIN_BLACKCARD_USER = 226,--黑卡封禁用户
  RET_REBEL_BOSS_GROUP_EXIST = 227, --阵营已经选择过
  RET_SPREAD_USER_LVL_LIMIT = 228,--推广玩家等级不够
  RET_SPREAD_MAX_COUNT = 229,--推广玩家达到最大数
  RET_SPREAD_DRAW_ERROR = 230,--推广奖励领取不成功
  RET_SPREAD_NOT_ENOUGH = 231,--推广积分不够
  RET_RICE_ROB_TIME_END = 232, --粮草抢夺时间结束了
  RET_RICE_ROB_NOT_OPEN = 233, --粮草抢夺活动未开放
  RET_USER_NOT_JOIN_RICE_ROB = 234, --玩家未加入粮草战
  RET_RICE_RIVALS_FLUSH_IN_CD = 235, --对手匹配CD中
  RET_RICE_ROB_TOKEN_NOT_ENOUGH = 236, --抢粮剩余次数不足
  RET_RICE_ROB_IN_CD = 237, --抢粮CD时间中
  RET_USER_NOT_IN_RICE_RIVALS = 238, --对方不在对手列表中
  RET_RICE_REVENGE_TOKEN_NOT_ENOUGH = 239, --复仇令不足
  RET_RICE_ENEMY_NOT_EXIST = 240, --仇人不存在
  RET_RICE_ENEMY_CANNOT_REVENGED = 241, --不能复仇
  RET_RICE_ACHIEVEMENT_ID_ERROR = 242, --成就ID错误
  RET_RICE_ACHIEVEMEN_NOT_REACH = 243, --成就未达成
  RET_RICE_ENEMY_NOT_NEED_REVENGE = 244, --不需要复仇
  RET_SHOPTIME_GOODS_NOT_ENOUGH = 245,--限时优惠商店商品不足
  RET_SHOPTIME_ACTIVITY_NOT_START = 246,--限时优惠未开始
  RET_OUTLET_SHOP_UP_LIMIT = 247,--限时优惠商店购买到达上限
  RET_OUTLET_SHOP_REWARD_HAS_AWARD = 248,--限时优惠商店全服福利已经领取
  RET_OUTLET_SHOP_REWARD_CAN_NOT_WELFARE = 249,--限时优惠商店全服福利不能领取
  RET_NOT_RICE_RANK_AWARD_TIME = 250, --非粮草战排行榜领奖时间
  RET_RICE_RANK_AWARD_HAS_RECEIVED = 251, --粮草排行榜奖励已经领取
  RET_RICE_RANK_NOT_AWARD = 252, --粮草排行没有奖励
  RET_RICE_TOKEN_EXCEED_BUY_LIMIT = 253, --粮草令牌购买次数超过限制
  RET_RICE_TOKEN_BUY_PRICE_ERROR = 254, --粮草令牌价格错误
  RET_OUTLET_SHOP_RECHARGE_NOT_FIND_ID = 255,--限时优惠商店未找到充值id
  RET_OUTLET_SHOP_GET_GOODS_ERROR = 256,--限时优惠商店未找到商品
  RET_SPREAD_INVALID_INPUT = 257,--推广非法输入
  RET_REGISTER_SPREAD_ERROR = 258,--已经注册
  RET_REGISTERING_SPREAD    = 259,--正在建立注册关系，请稍等
  RET_REGISTERING_ERROR     = 260,--注册失败(新老玩家不在同一个跨服上)
	RET_REBEL_BOSS_REFRESH_TOO_FREQUENT = 261, --叛军BOSS刷新请求太频繁
	RET_REBEL_BOSS_BATTLE_TOO_FREQUENT = 262, --叛军BOSS战斗请求太频繁
	RET_REBEL_BOSS_REWARD_NO_PERMIT = 263, --奖励不可领取
  RET_REGISTER_CONNECT_CROSS_ERROR     = 264,--注册时连跨服失败
	RET_REBEL_BOSS_CORP_REWARD_NOT_PERMIT = 265,--无法领取，每次活动只可领取1次军团奖励
  RET_RICE_RANK_ACHIEVEMENT_RECEIVED = 266, --粮草战成就奖励已领取
  RET_CORP_CHAPTER_AWARD_FINISHED = 267, --玩家已经领取过军团章节奖励
  RET_CORP_CHAPTER_DUNGEON_NOT_OPEN = 268, --军团副本未开启 不能攻打
  RET_MONTH_FUND_ACTIVITY_CFG_ERROR = 269, --月基金配置出错
  RET_MONTH_FUND_ACTIVITY_NOT_START = 270, --月基金未开始
  RET_MONTH_FUND_NOT_FIND_USER_DATA = 271, --月基金找不到玩家数据
  RET_MONTH_FUND_NOT_IN_AWARD_TIME = 272, --月基金不在领取奖励时间
  RET_MONTH_FUND_AWARD_HAS_ACQUIRED = 273, --月基金奖励已经领取过了
  RET_MONTH_FUND_HAVE_NOT_BUY_BEFORE = 274, --没有购买过月基金
  RET_CUSTOM_ACTIVITY_LEVEL_NOT_MATCH = 275, --可配置活动等级不匹配
  RET_CUSTOM_ACTIVITY_VIP_NOT_MATCH = 276, --可配置活动vip等级不匹配
  RET_MAIL_STRANGER_LEVEL = 277, --给陌生人发邮件等级不足
  RET_MAIL_STRANGER_COUNT = 278, --今天给陌生人发邮件已达到次数限制
  RET_ROOKIE_INACTIVE = 279, --新手光环活动已关闭
  RET_THEME_DROP_ZY_CHANGE			= 280,	--限时抽将阵营已变
  RET_THEME_DROP_TIMES_LACK			= 281,	--限时抽将次数不足
  RET_THEME_DROP_KNIGHT_ERROR		= 282,	--限时抽将主题将不符合
  RET_THEME_DROP_SV_LACK			= 283,	--限时抽将缺少星运值
  RET_GROUP_BUY_PURCHASE_COUNT_LIMIT = 284, --限时团购购买次数不足
  RET_GROUP_BUY_GET_TASK_AWARD_ID_ERROR = 285, --限时团购领奖Id错误
  RET_GROUP_BUY_GET_TASK_AWARD_SELF_SCORE_NOT_ENOUGH = 286, --限时团购领奖个人积分不足
  RET_GROUP_BUY_GET_TASK_AWARD_MAX_SCORE_NOT_ENOUGH = 287, --限时团购领奖全服最高积分不足
  RET_GROUP_BUY_TASK_AWARD_GET_BEFORE = 288,--限时团购奖励已经领取过
  RET_GROUP_BUY_TASK_AWARD_BACK_GOLD_ERROR = 289,--限时团购返还元宝出错
  RET_GROUP_BUY_VIP_LEVLE_NOT_ENOUGH = 290,--限时团购vip等级不足
  RET_GROUP_BUY_LEVLE_NOT_ENOUGH = 291,--限时团购等级不足
  RET_GROUP_BUY_NOT_IN_BUY_TIME = 292,--限时团购不在购买状态
  RET_GROUP_BUY_USER_DATA_ERROR = 293,--限时团购玩家数据异常
  RET_GROUP_BUY_NOT_IN_ACTIVITY_TIME = 294,--限时团购不在活动时间
  RET_GROUP_BUY_NOT_IN_AWARD_TIME = 295,--限时团购不在领奖时间
  RET_GROUP_BUY_USER_DATA_NOT_LOAD = 296,--限时团购玩家数据异常
  RET_PICTURE_FRAME_ID_ERROR		= 297,--更换头像框ID错误
  RET_PET_BAG_FULL = 298, --宠物背包满
  RET_PET_NOT_EXIST = 299, --宠物不存在
  RET_PET_IS_IN_FIGHT = 300, --宠物已上阵
  RET_BATTLE_FIELD_GONEXT_ERROR = 301,--远征进入下一关条件不满足
  RET_BATTLE_FIELD_RESET_ERROR = 302,--远征无法重置
  RET_BATTLE_FIELD_OUTOFDATE = 303,--远征信息过期
  RET_BATTLE_FIELD_AWARD_ERROR = 304,--远征领奖错误
  RET_BATTLE_FIELD_CHALLENGE_ERROR= 305,--远征关卡已经挑战过
  RET_BATTLE_FIELD_LOADING = 306,--远征关卡载入中
  RET_BATTLE_FIELD_SHOP_UP_LIMIT = 307,
  RET_CORP_DUNGEON_AWARD_OVER_DIFF = 308,--军团奖励领取异常 利用工作室
  RET_FIGHT_SCORE_NOT_ENOUGH = 309,--兽魂数量不足
  RET_DELAY_RELOAD_ERROR = 310,--正在努力加载数据，请稍后
  RET_CORP_TECH_ID_NOT_OPEN = 311,--军团科技未开放（军团等级不够）
  RET_CORP_TECH_ID_NOT_EXIST = 312, --军团科技id错误
  RET_CORP_TECH_ID_REACH_MAX_LEVEL = 313, --军团科技达到最高等级
  RET_CORP_TECH_ID_USER_LEVEL_REACH_CORP_LEVEL = 314, --军团科技 玩家科技等级达到军团科技等级
  RET_CORP_TECH_CORP_EXP_NOT_ENOUGH = 315, --军团科技研发，军团经验不足
  RET_CORP_UP_LEVEL_REACH_MAX_LEVEL = 316, --军团升级到达最高等级
  RET_CORP_UP_LEVEL_NOT_ENOUGH_EXP = 317, --军团升级经验不足
  RET_CROSS_PVP_RANK_LIMIT_ERROR = 318, --跨服夺帅竞技场排名条件不符
  RET_CROSS_PVP_INSPIRE_COUNT_LIMIT = 319, --跨服夺帅鼓舞达到上限
  RET_CROSS_RANK_BUSY = 320, --排行榜正在结算
  RET_GAME_TIME_ERROR3 = 321,--奇门八卦活动已结束
  RET_CROSS_PVP_FLOWER_SELF_ILLEGAL = 322, --不能给自己鲜花鸡蛋
  RET_CROSS_PVP_STAGE_ILLEGAL = 323, --请求的战场不存在
  RET_CROSS_PVP_FLOWER_TYPE_ILLEGAL = 324, --鲜花鸡蛋类型错误
  RET_CROSS_PVP_CONFIG_ERROR = 325, --跨服夺帅配置异常
  RET_CROSS_PVP_SLAVE_DATA_ERROR = 326, --跨服夺帅数据异常
  RET_CROSS_PVP_INSPIRE_TYPE_ILLEGAL = 327, --跨服夺帅鼓舞类型错误
  RET_CROSS_PVP_GET_AWARD_ERROR = 328, --跨服夺帅领奖出错
  RET_CROSS_PVP_FLOWER_COUNT_TOO_MUCH = 329, --跨服夺帅投注次数太多
  RET_SPECIAL_HOLIDAY_TASK_NOT_FINISHED = 330, --长假活动，中秋国庆领奖任务未完成
  RET_SPECIAL_HOLIDAY_TASK_NOT_IN_TIME = 331, --中秋国庆活动已过
  RET_SPECIAL_HOLIDAY_TASK_FINISHED = 332, --中秋活动奖励已领取
  RET_SPECIAL_HOLIDAY_SALE_REACH_MAX = 333, --中秋活动兑换达到最大次数
  RET_SPECIAL_HOLIDAY_SALE_PRICE_NOT_ENOUGH = 334, --中秋活动兑换资源不足
  RET_SPECIAL_HOLIDAY_SALE_NOT_IN_TIME = 335, --中秋活动兑换 时间不对
  RET_BULLET_SCREEN_IN_CD = 336, --发送弹幕CD中
  RET_BULLET_SCREEN_CONTENT_ILLEGAL = 337, --发送弹幕内容错误
  RET_BULLET_SCREEN_BUSY = 338, --弹幕系统繁忙
  RET_EXPANSIVE_DUNGEON_STAGE_NOT_OPEN = 339, --关卡未开启
  RET_EXPANSIVE_DUNGEON_CHAPTER_NOT_OPEN = 340, --章节未开启
  RET_HAVE_GET_MAX_STAR = 341, --已三星通关
  RET_HAS_GET_CHAPTER_AWARD = 342, --已经领取过章节奖励
  RET_BATTLE_ON_SLOT_KNIGHT_ERROR = 343, --战斗缺少上阵侠客
  RET_EXPANSIVE_DUNGEON_SHOP_BUY_COUNT_ERROR = 344, --资料片副本商品购买次数不足
  RET_EXPANSIVE_DUNGEON_SHOP_ITEM_NOT_EXIST = 345, --资料片副本商品不存在
  RET_EXPANSIVE_DUNGEON_SHOP_CHAPTER_NOT_FINISH = 346, --资料片副本章节未完成
  RET_FRAGMENT_COMPOUND_NOT_ENOUGH = 347, --合成碎片不足
  RET_OLDER_PLAYER_VIP_AWARD = 348, --已经领取过老玩家VIP奖励
  RET_NOT_OLDER_PLAYER = 349, --不是老玩家
  RET_OLDER_PLAYER_LEVEL_AWARD = 350, --已经领取过老玩家等级奖励
  RET_GET_OLDER_PLAYER_INFO = 351, --已经在获取老玩家数据
  RET_EXPANSIVE_DUNGEON_NOT_START = 352, --资料片副本未开启
  RET_ACCOUNT_BINDING_REWARDED = 353, --社交账号绑定奖励已领取
  RET_CONNECT_CROSS_ERROR = 354, --连跨服失败
  RET_NOT_ENOUGH_KSOUL = 355, --将灵不足
  RET_NOT_ENOUGH_KSOUL_POINT = 356, --灵玉不足
  RET_ACTIVE_DEMAND_NOT_MEET = 357, --条件不足 无法激活
  RET_HAS_ALREAD_ACTIVE = 358, --已经激活
  RET_KSOUL_SHOP_ITEM_BUYED = 359, --灵玉商店物品已购买
  RET_KSOUL_SHOP_ITEM_NOT_EXIST = 360, --灵玉商店物品不存在
  RET_KSOUL_SUMMON_ERROR = 361, --点将错误
  RET_KSOUL_SUMMON_POINT_NOT_ENOUGH = 362, --点将奇遇点不足
  RET_KSOUL_SUMMON_EXCHANGE_MAX = 363, --点将奇遇最大次数
  RET_CITY_ALL_NO_OPEN = 364,		-- 城池未都攻下
  RET_CITY_PATROL_CONFIG = 365, -- 城池巡逻配置错误
  RET_CITY_TECH_CONFIG = 367,	-- 城池科技配置错误
  RET_CITY_TECHUP_TIME_NO_ATTACH = 368,	-- 城池科技升级巡逻时间但没达到
  RET_CITY_TECHUP_CONSUME_NO_ATTACH = 369,	-- 城池科技升级消耗品不足
  RET_KNIGHT_GOD_NO_ATTACH_POTENTIALITY = 370, -- 化神, 武将没有达到化神的潜质
  RET_KNIGHT_GOD_CONFIG	= 371,					-- 化神, 化神神脉配置错误
  RET_KNIGHT_GOD_CONSUME_NO_ENOUGH = 372,		-- 化神, 化神消耗不足
  RET_KNIGHT_TRANSFORM_NO_SAME_GROUP_LEVEL = 373, -- 八卦镜跨阵营转换等级不足
  RET_DAYS_SEVEN_COMP_NO_IN_AWARD_TIME = 374, -- 开服七日战力比拼不在领奖时间内
  RET_NOT_ENOUGH_KSOUL_SUMMON_SCORE = 375, -- 奇遇点不足 
  RET_DAYS_SEVEN_COMP_RANK_IS_EMPTY = 376, -- 开服七日战力比拼榜是空
  RET_DAYS_SEVEN_COMP_NO_ON_RANK = 377, -- 开服七日战力比拼你不在榜上
  RET_DAYS_SEVEN_COMP_CONF_EROR = 378, -- 开服七日战力比配置异常
  RET_DAYS_SEVEN_COMP_HAD_AWARD = 379, -- 开服七日战力比拼你已经领奖
  RET_DAYS_SEVEN_COMP_SWITCH_CLOSE = 380, -- 开服七日战力比拼活动开关关闭
  RET_SHARE_FRIEND_AWARD_NO_LOAD_CONF = 381, -- 新马服FB好友分享配置没有加载
  RET_SHARE_FRIEND_AWARD_NO_LOAD_DATA = 382, -- 新马服FB好友分享数据没有加载
  RET_SHARE_FRIEND_AWARD_CONF_ERROR   = 383, -- 新马服FB好友分享配置错误
  RET_SHARE_FRIEND_AWARD_HAVE_AWARD	  = 384, -- 新马服FB好友分享当日奖励已将领取
  RET_FORTUNE_TODAY_TIMES_MAX		  = 385, -- 招财符今日招财次数已达上限
  RET_FORTUNE_BOX_TIMES_NO_ENOUGH	  = 386, -- 招财符抽宝箱招财次数不够
  RET_FORTUNE_BOX_ID_NO_EXIST		  = 387, -- 招财符抽宝箱id不存在
  RET_FORTUNE_BOX_ID_HAD_AWARD		  = 388, -- 招财符抽宝箱id今日已领
  RET_FORTUNE_BOX_AWARD_CONF_ERROR	  = 389, -- 招财符抽宝箱配置问题

---------------------------------------我 叫 分 隔 符-------------------------------------------------
  --1000以上共享用 和crosspk同步 不然尼玛转换就想死了
  RET_CORP_CROSS_PK_STATE_ERROR = 1000, --跨服军团状态错误
  RET_CORP_CROSS_PK_HAS_APPLY= 1001, --跨服军团已经报名
  RET_CORP_CROSS_PK_HAS_NOT_APPLY= 1002, --跨服军团未报名
  RET_CORP_CROSS_PK_DEMAND_NOT_MEET = 1004, --跨服军团报名条件不满足
  RET_CORP_CROSS_PK_ENCOURAGE_OVER_MAX = 1005, --跨服鼓舞超过军团最大次数
  RET_CORP_CROSS_PK_ENCOURAGE_OVER_MEMBERMAX = 1006, --跨服鼓舞超过玩家最大次数
  RET_CORP_CROSS_PK_IN_REFRESH_CD = 1007, --跨服战斗刷新CD中
  RET_CORP_CROSS_PK_IN_PK_CD = 1008, --跨服战斗CD中
  RET_CORP_CROSS_PK_NOT_IN_PK_CD = 1009, --不在跨服战斗CD中 不用重置
  RET_CORP_CROSS_PK_FIELD_NOT_EXIT = 1010, --战场不存在
  RET_CORP_QUERY_ERROR = 1011, --查询异常
  RET_CORP_CROSS_PK_CORP_NOT_EXIT = 1012, --军团不存在
  RET_CORP_CROSS_PK_CORP_MEMBER_MAX_CHALLENGE= 1013, --军团挑战玩家打到最大次数
  RET_CORP_CROSS_PK_CORP_SET_FIREON_ERROR = 1014, --不能设置自己为集火目标
  RET_CORP_CROSS_PK_CORP_STATE_LOCK = 1015, --军团战状态锁定中
  RET_CORP_CROSS_PK_SERVER_ERROR = 1016, --跨服服务器失联
  RET_CORP_CROSS_PK_RESET_MAX = 1017, --跨服战战斗重置达到上限
  RET_USER_CROSS_PK_SERVER_ERROR = 1018,--比武服务器战场信息错误
  RET_USER_CROSS_PK_STATE_ERROR = 1019,--比武状态错误
  RET_USER_CROSS_PK_GROUP_ERROR  = 1020,--比武玩家未选择阵营
  RET_USER_CROSS_PK_REFRESH_ERROR = 1021,--比武玩家没有刷新次数
  RET_USER_CROSS_PK_FREQUENCE_ERROR = 1022,--比武玩家请求列表频繁
  RET_USER_CROSS_PK_BATTLE_ERROR = 1023,--比武玩家请求战斗错误
  RET_USER_CROSS_PK_USER_CHALLENGED = 1024,--比武玩家已经挑战过了
  RET_USER_CROSS_PK_USER_NO_CHALLENGE= 1025,--比武玩家没有挑战次数
  RET_USER_CROSS_PK_GET_ENEMY_ERROR = 1026,--比武玩家获取对手信息失败
  RET_USER_CROSS_PK_ARENA_NO_INVITATION = 1027,--没有邀请资格
  RET_USER_CROSS_PK_ARENA_BET_ERROR = 1028,--投注错误
  RET_USER_CROSS_PK_ARENA_HAS_SERVER_AWARD = 1029,--已经领取过全服奖励
  RET_USER_CROSS_PK_ARENA_AWARD_NOT_PREPARED= 1030,--奖励初始化中
  RET_USER_CROSS_PK_ARENA_AWARD_ILLEGAL= 1031,--奖励条件不满足
  RET_USER_CROSS_PK_ARENA_NOT_OPEN = 1032,--争霸赛未开启
  RET_USER_CROSS_PK_ARENA_BET_INIT = 1033,--投注初始化中
  RET_USER_CROSS_PK_ARENA_BET_FINISH = 1034,--投注结算中
  RET_USER_CROSS_PK_ARENA_CHALLENGE_ERROR = 1035,--挑战信息错误
  RET_USER_CROSS_PK_ARENA_CHALLENGE_LOCK = 1036,--正在被挑战
  RET_USER_CROSS_PK_ARENA_BET_MAX = 1037,--投注超过上限
  RET_USER_CROSS_PK_ARENA_BET_AWARD_FINISH = 1038,--已经领取过投注奖励
  RET_USER_CROSS_PK_GET_USER_INFO_FAILED = 1039,--玩家信息获取失败
  RET_USER_CROSS_GB_NOT_IN_AWARD_TIME = 1040,--不在团购领奖时间内
  RET_USER_CROSS_GB_NOT_IN_AWARD_RANK = 1041,--不在团购排行榜奖励中
  RET_USER_CROSS_GB_GET_RANK_AWARD_BEFORE = 1042,--团购奖励已经领取过

  RET_TEAM_PVP_CROSS_SERVER_ERROR = 1100, -- 组队pvp，跨服服务器失联
  RET_TEAM_PVP_HAS_TEAM = 1101, --组队PVP,已经有队伍
  RET_TEAM_PVP_JOINING_TEAM = 1102, -- 组队pvp, 在自动匹配队伍中
  RET_TEAM_PVP_NOT_IN_TEAM = 1103, -- 组队pvp，不在队伍中
  RET_TEAM_PVP_NOT_TEAM_LEADER = 1104, --组队pvp，不是队长
  RET_TEAM_PVP_KICK_NO_TEAM_MEMBER = 1105, -- 组队pvp，踢的人不在队伍中_
  RET_TEAM_PVP_CAN_NOT_KICK_SELF = 1106, --组队pvp，不能踢自己
  RET_TEAM_PVP_INVITE_TARGET_NOT_ONLINE = 1107, --组队pvp，邀请对象不在线
  RET_TEAM_PVP_INVITE_TARGET_NOT_FRIEND = 1108, --组队pvp，邀请对象非好友
  RET_TEAM_PVP_INVITOR_QUIT_TEAM = 1109, -- 组队pvp，邀请人已退出
  RET_TEAM_PVP_INVITE_TICKET_INVALID = 1110, -- 组队pvp，无效邀请
  RET_TEAM_PVP_TEAM_FULL = 1111, -- 组队pvp，队伍已满
  RET_TEAM_PVP_ALREADY_INVITING_NPC = 1112, -- 组队pvp，已经在邀请NPC了
  RET_TEAM_PVP_TEAM_NOT_FULL = 1113, --组队pvp，队伍未满
  RET_TEAM_PVP_TEAM_IS_MATCHING = 1114, -- 组队pvp，已经在匹配其他队伍中
  RET_TEAM_PVP_TEAM_MEMBERS_DISAGREE = 1115, -- 组队pvp，有队员不同意出战
  RET_TEAM_PVP_CHANGE_POSITION_INVALID = 1116, -- 组队pvp，换位置无效
  RET_TEAM_PVP_TEAM_IS_NOT_MATCHING = 1117, -- 组队pvp，队伍不在匹配其他队伍
  RET_TEAM_PVP_USER_LEVEL_NOT_ENOUGH = 1118, -- 组队pvp，玩家等级不足
  RET_TEAM_PVP_NPC_SEARCH_CD = 1119, -- 组队pvp，npc  cd中
  RET_TEAM_PVP_NOT_ENOUGH_SCORE = 1120, -- 组队pvp商店，积分不足
  RET_TEAM_PVP_NOT_ENOUGH_HONOR = 1121, -- 组队pvp商店，荣誉不足

  --!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!上面别加游戏服的RET 游戏服的RET方放在1000以内!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  --------------------------slave master -----------------------------------------
  RET_CROSS_PVP_APPLY_FULL = 2000,--跨服报名已满
  RET_CROSS_PVP_ROLE_EXIST = 2001,--跨服战已经报名
  RET_CROSS_PVP_NO_EXIST_ACT_ID = 2002,--跨服赛区不存在
  RET_CROSS_PVP_NO_FIND_ROOM = 2003,--跨服房间不存在
  RET_SERVER_BUSY = 2004,--跨服服务器繁忙
  RET_CROSS_PVP_NO_FIND_RESOURCE = 2005,--跨服资源点错误
  RET_CROSS_PVP_NO_EXIST_ID = 2006,--跨服挑战对象不存在
  RET_PVP_LOCK = 2007,--资源点因为攻击被锁
  RET_PVP_COLDDOWN = 2008,--玩家处于冷却时间
  RET_PVPING = 2009,--玩家正在攻击资源
  RET_PVP_OCCUPY = 2010,--玩家已经占领了一个资源点
  RET_PVP_M2M = 2011,--玩家自己攻击自己
  RET_CROSS_PVP_STATE_ERROR = 2012,--跨服PVP状态错误
  RET_CROSS_PVP_LEVEL_ERROR = 2013,--跨服报名等级不满足
  RET_CROSS_PVP_TYPE_ERROR = 2014,--跨服报名战场不存在
  RET_CROSS_PVP_BUFF_MAX = 2015,--BUFF已最大
  RET_CROSS_PVP_BUFF_TYPE_ERROR = 2016,--BUFF类型错误
  RET_FLOWER_EGG_TYPE_ERROR = 2017,--鲜花鸡蛋类型错误
  RET_CROSS_PVP_NO_BET = 2018,--该轮没有鲜花鸡蛋押注
  RET_FLOWER_EGG_ONLY_ONE = 2019,--鲜花--鸡蛋只能押一个人
  RET_FLOWEREGG_AWARDED = 2020,--鲜花鸡蛋奖励已经领取了
  RET_FLOWEREGG_NOT_MEET = 2021,--鲜花鸡蛋奖励条件不满足
  RET_CROSS_PVP_RANK_GOT_AWARD = 2022,--已经领取过排行奖励
  RET_CROSS_PVP_NOT_OB = 2023,--不在OB列表内
  --!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!上面别加游戏服的RET 游戏服的RET方放在1000以内!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
}
NetMsg_ERROR.data={
	{id="0", msg="未知错误(ret=0)"},
	{id="1", msg=""},
	{id="2", msg="服务器维护"},
	{id="3", msg="玩家不存在"},
	{id="4", msg="重复登陆"},
	{id="5", msg="创建角色时,玩家名字重复"},
	{id="6", msg="聊天-话太多"},
	{id="7", msg="聊天-频道不存在"},
	{id="8", msg="物品背包满"},
	{id="9", msg="自己好友已满"},
	{id="10", msg="对方好友已满"},
	{id="11", msg="副本超过挑战次数"},
	{id="12", msg="体力不足"},
	{id="13", msg="副本类宝箱奖励已经领取"},
	{id="14", msg="秒杀CD中"},
	{id="15", msg="章节星星奖励已经领取"},
	{id="16", msg="章节星星总数不够"},
	{id="17", msg="章节宝箱奖励已经领取"},
	{id="18", msg="章节宝箱星星数不够"},
	{id="19", msg="元宝不足"},
	{id="20", msg="银两数量不足"},
	{id="21", msg="卡牌背包满"},
	{id="22", msg="装备背包满"},
	{id="23", msg="副本未通过"},
	{id="24", msg="等级不够"},
	{id="25", msg="精力不够"},
	{id="26", msg="购买到达上限"},
	{id="27", msg="声望不够"},
	{id="28", msg="武将不存在"},
	{id="29", msg="主将不可强化"},
	{id="30", msg="强化武将等级超过主将"},
	{id="31", msg="主将不可用作强化材料"},
	{id="32", msg="强化材料武将不存在"},
	{id="33", msg="强化材料武将重复"},
	{id="34", msg="出阵武将不可作为强化材料"},
	{id="35", msg="武将升阶等级已经达到最大"},
	{id="36", msg="武将升阶需求卡牌数量不足"},
	{id="37", msg="武将升阶材料卡牌id不对"},
	{id="38", msg="出阵武将不可当作升阶材料"},
	{id="39", msg="道具数量不足"},
	{id="40", msg="前置技能未学习"},
	{id="41", msg="技能达到满级"},
	{id="42", msg="技能点不足"},
	{id="43", msg="技能未找到"},
	{id="44", msg="同类型技能不够导致无法洗技能"},
	{id="45", msg="技能槽位错误"},
	{id="46", msg="武将历练值超过限制"},
	{id="47", msg="洗技能所洗槽位不为空"},
	{id="48", msg="剧情副本次数超过限制"},
	{id="49", msg="三国志奖励已经领取"},
	{id="50", msg="装备不存在"},
	{id="51", msg="装备强化等级超过限制"},
	{id="52", msg="装备精炼等级超过限制"},
	{id="53", msg="道具类型不对"},
	{id="54", msg="武将光环等级已经达到最大"},
	{id="55", msg="武将光环等级不够"},
	{id="56", msg="神秘商店购买到达上限"},
	{id="57", msg="精魄数量不足"},
	{id="58", msg="叛军无效"},
	{id="59", msg="没有足够的出征令"},
	{id="60", msg="没找到叛军奖励ID"},
	{id="61", msg="宝物背包已满"},
	{id="62", msg="武将不能被升阶"},
	{id="63", msg="宝物不存在"},
	{id="64", msg="强化材料宝物重复"},
	{id="65", msg="精炼材料宝物数据不足"},
	{id="66", msg="宝物碎片数量不足"},
	{id="67", msg="叛军没公开"},
	{id="68", msg="不是自己好友的叛军"},
	{id="69", msg="宝物出阵中"},
	{id="70", msg="该宝物不能被强化或精炼"},
	{id="71", msg="没有足够的勋章"},
	{id="72", msg="没有足够试练塔积分"},
	{id="73", msg="竞技场排名已更新"},
	{id="74", msg="装备不在"},
	{id="75", msg="装备学习所需道具不足"},
	{id="76", msg="重置技能技能等级非法"},
	{id="77", msg="玩家数据更新中"},
	{id="78", msg="宝物碎片已被抢夺"},
	{id="79", msg="玩家已下线"},
	{id="80", msg="对方不是你的好友"},
	{id="81", msg="积分商城购买到达上限"},
	{id="82", msg="积分商城未达到竞技场排名需求"},
	{id="83", msg="积分商城未达到闯关层数需求"},
	{id="84", msg="VIP副本未开启"},
	{id="85", msg="VIP副本次数用完"},
	{id="86", msg="VIP等级不够"},
	{id="87", msg="聊天太频繁"},
	{id="88", msg="活动结束"},
	{id="89", msg="月卡已经使用过了"},
	{id="90", msg="祭拜关公cd"},
	{id="91", msg="每日任务进度不足"},
	{id="92", msg="每日任务奖励已经领取"},
	{id="93", msg="每日任务宝箱奖励已经领取"},
	{id="94", msg="每日任务宝箱奖励点数不够"},
	{id="95", msg="重置次数达到上限"},
	{id="96", msg="被禁言"},
	{id="97", msg="被封号了"},
	{id="98", msg="武将等级不够"},
	{id="99", msg=""},
	{id="100", msg="不在白名单"},
	{id="101", msg="玩家在免战状态不能抢夺"},
	{id="102", msg="竞技场排名20名之后不能直接挑战前10名"},
	{id="103", msg="错误的礼品码"},
	{id="104", msg="客户端版本错误"},
	{id="105", msg="名人堂签名过长"},
	{id="106", msg="名人堂改签名元宝不足"},
	{id="107", msg="服务器还未开放"},
	{id="108", msg="基金购买时间过期"},
	{id="109", msg="基金购买重复"},
	{id="110", msg="玩家未购买基金"},
	{id="111", msg="基金福利领取时间过期"},
	{id="112", msg="基金奖励已经领取"},
	{id="113", msg="基金福利已经领取"},
	{id="114", msg="基金福利领取条件未达成"},
	{id="115", msg="活动奖励条件不可领取"},
	{id="116", msg="活动奖励兑换物品不足"},
	{id="117", msg="活动限购已经参与"},
	{id="118", msg="活动限购已经被抢购完了"},
	{id="119", msg="活动已经结束"},
	{id="120", msg="暴动已被解决"},
	{id="121", msg="礼品码时间过期"},
	{id="122", msg="礼品码缺少参数"},
	{id="123", msg="参数错误"},
	{id="124", msg="活动批次的码失效"},
	{id="125", msg="码已经失效"},
	{id="126", msg="码不存在"},
	{id="127", msg="活动过期"},
	{id="128", msg="码超过使用次数"},
	{id="129", msg="活动游戏编码错误"},
	{id="130", msg="用户名非该码绑定用户"},
	{id="131", msg="校验码错误"},
	{id="132", msg="军团不存在"},
	{id="133", msg="非法军团名"},
	{id="134", msg="军团名已存在"},
	{id="135", msg="申请的军团已存在"},
	{id="136", msg="申请的军团数量到达上限"},
	{id="137", msg="退出军团时间CD中（在玩家主动退出或者军团长T人时候提示）"},
	{id="138", msg="军团人数已满"},
	{id="139", msg="军团权限不够"},
	{id="140", msg="玩家已经加入另外个军团"},
	{id="141", msg="军团边框条件不满足"},
	{id="142", msg="军团副军团人数满了"},
	{id="143", msg="军团人数大于最小解散军团人数"},
	{id="144", msg="已经做过军团贡献"},
	{id="145", msg="已经领过军团贡献奖励"},
	{id="146", msg="军团贡献奖励点数不足无法领取奖励"},
	{id="147", msg="军团点数不足"},
	{id="148", msg="可配置活动奖励次数超过限制"},
	{id="149", msg="可配置活动全服奖励次数超过限制"},
	{id="150", msg="可配置活动奖励不可领取"},
	{id="151", msg="可配置活动奖励ID错误"},
	{id="152", msg="卡牌数量不足"},
	{id="153", msg="装备数量不足"},
	{id="154", msg="宝物数量不足"},
	{id="155", msg="可配置任务奖励领取时间未到"},
	{id="156", msg="弹劾军团长时间未到"},
	{id="157", msg="军团长不能退出军团"},
	{id="158", msg="军团商店ID不存在请求过期"},
	{id="159", msg="玩家没有军团"},
	{id="160", msg="玩家已经有军团"},
	{id="161", msg="时装强化等级超过限制"},
	{id="162", msg="时装不在"},
	{id="163", msg="玩家已经购买了该军团商城道具"},
	{id="164", msg="设置军团章节信息条件不足"},
	{id="165", msg="最大军团副本执行次数"},
	{id="166", msg="军团副本信息错误信息过期"},
	{id="167", msg="军团副本已经结束"},
	{id="168", msg="军团副本没通关"},
	{id="169", msg="该玩家没有军团副本奖励"},
	{id="170", msg="该玩家已经领取的军团副本奖励"},
	{id="171", msg="节日活动领奖次数超过限制"},
	{id="172", msg="节日活动还未开放"},
	{id="173", msg="道具已过期"},
	{id="174", msg="这个蛋已经被别人砸了"},
	{id="175", msg="非法军团对外公告"},
	{id="176", msg="非法军团对内公告"},
	{id="177", msg="礼品码操作过快"},
	{id="178", msg="加入军团时间CD中"},
	{id="179", msg="玩家军团申请不存在"},
	{id="180", msg="军团祭天达到最大值"},
	{id="181", msg="服务器到达承载上线"},
	{id="182", msg="军团商城物品已经售完"},
	{id="183", msg="解散军团时间CD中"},
	{id="184", msg="无法购买日常副本次数"},
	{id="185", msg="冲返活动已经结束"},
	{id="186", msg="请求过于频繁"},
	{id="187", msg="冲返领取失败已经在别的服务器领取过"},
	{id="188", msg="冲返领取失败"},
	{id="189", msg="觉醒道具包裹已满"},
	{id="190", msg="转盘积分不足"},
	{id="191", msg="转盘总积分不足"},
	{id="192", msg="觉醒道具数量不足"},
	{id="193", msg="武将不能觉醒"},
	{id="194", msg="武将觉醒道具位置不对"},
	{id="195", msg="觉醒道具不存在"},
	{id="196", msg="武将觉醒等级超过限制"},
	{id="197", msg="武将觉醒道具未集齐"},
	{id="198", msg="武将觉醒材料卡牌数量不足"},
	{id="199", msg="武将觉醒材料卡牌不对"},
	{id="200", msg="出阵武将不可作为觉醒材料"},
	{id="201", msg="没有足够神魂"},
	{id="202", msg="该军团申请已满"},
	{id="203", msg="军团副本购买次数达到上限"},
	{id="204", msg="称号已装备"},
	{id="205", msg="称号已过期"},
	{id="206", msg="比武勋章不足"},
	{id="207", msg="军团点数不足"},
	{id="208", msg="比武连胜次数不足"},
	{id="209", msg="限时副本未开放"},
	{id="210", msg="限时副本挑战已完成"},
	{id="211", msg="转盘活动已结束"},
	{id="212", msg="大富翁活动已结束"},
	{id="213", msg="未知价格类型"},
	{id="214", msg="当前没有活动开启"},
	{id="215", msg="在线列表中无此玩家"},
	{id="216", msg="邮件长度超长"},
	{id="217", msg="精英副本状态错误"},
	{id="218", msg="战斗请求太频繁"},
	{id="219", msg="玩家数据需要恢复"},
	{id="220", msg="同一ip建号数量达到上限"},
	{id="221", msg="客户端请求错误"},
	{id="222", msg="叛军BOSS活动未开启"},
	{id="223", msg="叛军BOSS挑战次数不足"},
	{id="224", msg="叛军奖励已经领取"},
	{id="225", msg="叛军BOSS已死亡"},
	{id="226", msg="黑卡封禁用户"},
	{id="227", msg="阵营已经选择过"},
	{id="228", msg="推广玩家等级不够"},
	{id="229", msg="推广玩家达到最大数"},
	{id="230", msg="推广奖励领取不成功"},
	{id="231", msg="推广积分不够"},
	{id="232", msg="粮草抢夺时间结束了"},
	{id="233", msg="粮草抢夺活动未开放"},
	{id="234", msg="玩家未加入粮草战"},
	{id="235", msg="对手匹配CD中"},
	{id="236", msg="抢粮剩余次数不足"},
	{id="237", msg="抢粮CD时间中"},
	{id="238", msg="对方不在对手列表中"},
	{id="239", msg="复仇令不足"},
	{id="240", msg="仇人不存在"},
	{id="241", msg="不能复仇"},
	{id="242", msg="成就ID错误"},
	{id="243", msg="成就未达成"},
	{id="244", msg="不需要复仇"},
	{id="245", msg="限时优惠商店商品不足"},
	{id="246", msg="限时优惠未开始"},
	{id="247", msg="限时优惠商店购买到达上限"},
	{id="248", msg="限时优惠商店全服福利已经领取"},
	{id="249", msg="限时优惠商店全服福利不能领取"},
	{id="250", msg="非粮草战排行榜领奖时间"},
	{id="251", msg="粮草排行榜奖励已经领取"},
	{id="252", msg="粮草排行没有奖励"},
	{id="253", msg="粮草令牌购买次数超过限制"},
	{id="254", msg="粮草令牌价格错误"},
	{id="255", msg="限时优惠商店未找到充值id"},
	{id="256", msg="限时优惠商店未找到商品"},
	{id="257", msg="推广非法输入"},
	{id="258", msg="已经注册"},
	{id="259", msg="正在建立注册关系，请稍等"},
	{id="260", msg="注册失败(新老玩家不在同一个跨服上)"},
	{id="261", msg="叛军BOSS刷新请求太频繁"},
	{id="262", msg="叛军BOSS战斗请求太频繁"},
	{id="263", msg="奖励不可领取"},
	{id="264", msg="注册时连跨服失败"},
	{id="265", msg="无法领取，每次活动只可领取1次军团奖励"},
	{id="266", msg="粮草战成就奖励已领取"},
	{id="267", msg="玩家已经领取过军团章节奖励"},
	{id="268", msg="军团副本未开启不能攻打"},
	{id="269", msg="月基金配置出错"},
	{id="270", msg="月基金未开始"},
	{id="271", msg="月基金找不到玩家数据"},
	{id="272", msg="月基金不在领取奖励时间"},
	{id="273", msg="月基金奖励已经领取过了"},
	{id="274", msg="没有购买过月基金"},
	{id="275", msg="可配置活动等级不匹配"},
	{id="276", msg="可配置活动vip等级不匹配"},
	{id="277", msg="给陌生人发邮件等级不足"},
	{id="278", msg="今天给陌生人发邮件已达到次数限制"},
	{id="279", msg="新手光环活动已关闭"},
	{id="280", msg="限时抽将阵营已变"},
	{id="281", msg="限时抽将次数不足"},
	{id="282", msg="限时抽将主题将不符合"},
	{id="283", msg="限时抽将缺少星运值"},
	{id="284", msg="限时团购购买次数不足"},
	{id="285", msg="限时团购领奖Id错误"},
	{id="286", msg="限时团购领奖个人积分不足"},
	{id="287", msg="限时团购领奖全服最高积分不足"},
	{id="288", msg="限时团购奖励已经领取过"},
	{id="289", msg="限时团购返还元宝出错"},
	{id="290", msg="限时团购vip等级不足"},
	{id="291", msg="限时团购等级不足"},
	{id="292", msg="限时团购不在购买状态"},
	{id="293", msg="限时团购玩家数据异常"},
	{id="294", msg="限时团购不在活动时间"},
	{id="295", msg="限时团购不在领奖时间"},
	{id="296", msg="限时团购玩家数据异常"},
	{id="297", msg="更换头像框ID错误"},
	{id="298", msg="宠物背包满"},
	{id="299", msg="宠物不存在"},
	{id="300", msg="宠物已上阵"},
	{id="301", msg="远征进入下一关条件不满足"},
	{id="302", msg="远征无法重置"},
	{id="303", msg="远征信息过期"},
	{id="304", msg="远征领奖错误"},
	{id="305", msg="远征关卡已经挑战过"},
	{id="306", msg="远征关卡载入中"},
	{id="307", msg=""},
	{id="308", msg="军团奖励领取异常利用工作室"},
	{id="309", msg="兽魂数量不足"},
	{id="310", msg="正在努力加载数据，请稍后"},
	{id="311", msg="军团科技未开放（军团等级不够）"},
	{id="312", msg="军团科技id错误"},
	{id="313", msg="军团科技达到最高等级"},
	{id="314", msg="军团科技玩家科技等级达到军团科技等级"},
	{id="315", msg="军团科技研发，军团经验不足"},
	{id="316", msg="军团升级到达最高等级"},
	{id="317", msg="军团升级经验不足"},
	{id="318", msg="跨服夺帅竞技场排名条件不符"},
	{id="319", msg="跨服夺帅鼓舞达到上限"},
	{id="320", msg="排行榜正在结算"},
	{id="321", msg="奇门八卦活动已结束"},
	{id="322", msg="不能给自己鲜花鸡蛋"},
	{id="323", msg="请求的战场不存在"},
	{id="324", msg="鲜花鸡蛋类型错误"},
	{id="325", msg="跨服夺帅配置异常"},
	{id="326", msg="跨服夺帅数据异常"},
	{id="327", msg="跨服夺帅鼓舞类型错误"},
	{id="328", msg="跨服夺帅领奖出错"},
	{id="329", msg="跨服夺帅投注次数太多"},
	{id="330", msg="长假活动，中秋国庆领奖任务未完成"},
	{id="331", msg="中秋国庆活动已过"},
	{id="332", msg="中秋活动奖励已领取"},
	{id="333", msg="中秋活动兑换达到最大次数"},
	{id="334", msg="中秋活动兑换资源不足"},
	{id="335", msg="中秋活动兑换时间不对"},
	{id="336", msg="发送弹幕CD中"},
	{id="337", msg="发送弹幕内容错误"},
	{id="338", msg="弹幕系统繁忙"},
	{id="339", msg="关卡未开启"},
	{id="340", msg="章节未开启"},
	{id="341", msg="已三星通关"},
	{id="342", msg="已经领取过章节奖励"},
	{id="343", msg="战斗缺少上阵侠客"},
	{id="344", msg="资料片副本商品购买次数不足"},
	{id="345", msg="资料片副本商品不存在"},
	{id="346", msg="资料片副本章节未完成"},
	{id="347", msg="合成碎片不足"},
	{id="348", msg="已经领取过老玩家VIP奖励"},
	{id="349", msg="不是老玩家"},
	{id="350", msg="已经领取过老玩家等级奖励"},
	{id="351", msg="已经在获取老玩家数据"},
	{id="352", msg="资料片副本未开启"},
	{id="353", msg="社交账号绑定奖励已领取"},
	{id="354", msg="连跨服失败"},
	{id="355", msg="将灵不足"},
	{id="356", msg="灵玉不足"},
	{id="357", msg="条件不足无法激活"},
	{id="358", msg="已经激活"},
	{id="359", msg="灵玉商店物品已购买"},
	{id="360", msg="灵玉商店物品不存在"},
	{id="361", msg="点将错误"},
	{id="362", msg="点将奇遇点不足"},
	{id="363", msg="点将奇遇最大次数"},
	{id="364", msg="城池未都攻下"},
	{id="365", msg="城池巡逻配置错误"},
	{id="367", msg="城池科技配置错误"},
	{id="368", msg="城池科技升级巡逻时间但没达到"},
	{id="369", msg="城池科技升级消耗品不足"},
	{id="370", msg="化神,武将没有达到化神的潜质"},
	{id="371", msg="化神,化神神脉配置错误"},
	{id="372", msg="化神,化神消耗不足"},
	{id="373", msg="八卦镜跨阵营转换等级不足"},
	{id="374", msg="开服七日战力比拼不在领奖时间内"},
	{id="375", msg="奇遇点不足"},
	{id="376", msg="开服七日战力比拼榜是空"},
	{id="377", msg="开服七日战力比拼你不在榜上"},
	{id="378", msg="开服七日战力比配置异常"},
	{id="379", msg="开服七日战力比拼你已经领奖"},
	{id="380", msg="开服七日战力比拼活动开关关闭"},
	{id="381", msg="新马服FB好友分享配置没有加载"},
	{id="382", msg="新马服FB好友分享数据没有加载"},
	{id="383", msg="新马服FB好友分享配置错误"},
	{id="384", msg="新马服FB好友分享当日奖励已将领取"},
	{id="385", msg="招财符今日招财次数已达上限"},
	{id="386", msg="招财符抽宝箱招财次数不够"},
	{id="387", msg="招财符抽宝箱id不存在"},
	{id="388", msg="招财符抽宝箱id今日已领"},
	{id="389", msg="招财符抽宝箱配置问题"},
	{id="1000", msg="跨服军团状态错误"},
	{id="1001", msg="跨服军团已经报名"},
	{id="1002", msg="跨服军团未报名"},
	{id="1004", msg="跨服军团报名条件不满足"},
	{id="1005", msg="跨服鼓舞超过军团最大次数"},
	{id="1006", msg="跨服鼓舞超过玩家最大次数"},
	{id="1007", msg="跨服战斗刷新CD中"},
	{id="1008", msg="跨服战斗CD中"},
	{id="1009", msg="不在跨服战斗CD中不用重置"},
	{id="1010", msg="战场不存在"},
	{id="1011", msg="查询异常"},
	{id="1012", msg="军团不存在"},
	{id="1013", msg="军团挑战玩家打到最大次数"},
	{id="1014", msg="不能设置自己为集火目标"},
	{id="1015", msg="军团战状态锁定中"},
	{id="1016", msg="跨服服务器失联"},
	{id="1017", msg="跨服战战斗重置达到上限"},
	{id="1018", msg="比武服务器战场信息错误"},
	{id="1019", msg="比武状态错误"},
	{id="1020", msg="比武玩家未选择阵营"},
	{id="1021", msg="比武玩家没有刷新次数"},
	{id="1022", msg="比武玩家请求列表频繁"},
	{id="1023", msg="比武玩家请求战斗错误"},
	{id="1024", msg="比武玩家已经挑战过了"},
	{id="1025", msg="比武玩家没有挑战次数"},
	{id="1026", msg="比武玩家获取对手信息失败"},
	{id="1027", msg="没有邀请资格"},
	{id="1028", msg="投注错误"},
	{id="1029", msg="已经领取过全服奖励"},
	{id="1030", msg="奖励初始化中"},
	{id="1031", msg="奖励条件不满足"},
	{id="1032", msg="争霸赛未开启"},
	{id="1033", msg="投注初始化中"},
	{id="1034", msg="投注结算中"},
	{id="1035", msg="挑战信息错误"},
	{id="1036", msg="正在被挑战"},
	{id="1037", msg="投注超过上限"},
	{id="1038", msg="已经领取过投注奖励"},
	{id="1039", msg="玩家信息获取失败"},
	{id="1040", msg="不在团购领奖时间内"},
	{id="1041", msg="不在团购排行榜奖励中"},
	{id="1042", msg="团购奖励已经领取过"},
	{id="1100", msg="组队pvp，跨服服务器失联"},
	{id="1101", msg="组队PVP,已经有队伍"},
	{id="1102", msg="组队pvp,在自动匹配队伍中"},
	{id="1103", msg="组队pvp，不在队伍中"},
	{id="1104", msg="组队pvp，不是队长"},
	{id="1105", msg="组队pvp，踢的人不在队伍中_"},
	{id="1106", msg="组队pvp，不能踢自己"},
	{id="1107", msg="组队pvp，邀请对象不在线"},
	{id="1108", msg="组队pvp，邀请对象非好友"},
	{id="1109", msg="组队pvp，邀请人已退出"},
	{id="1110", msg="组队pvp，无效邀请"},
	{id="1111", msg="组队pvp，队伍已满"},
	{id="1112", msg="组队pvp，已经在邀请NPC了"},
	{id="1113", msg="组队pvp，队伍未满"},
	{id="1114", msg="组队pvp，已经在匹配其他队伍中"},
	{id="1115", msg="组队pvp，有队员不同意出战"},
	{id="1116", msg="组队pvp，换位置无效"},
	{id="1117", msg="组队pvp，队伍不在匹配其他队伍"},
	{id="1118", msg="组队pvp，玩家等级不足"},
	{id="1119", msg="组队pvp，npccd中"},
	{id="1120", msg="组队pvp商店，积分不足"},
	{id="1121", msg="组队pvp商店，荣誉不足"},
	{id="2000", msg="跨服报名已满"},
	{id="2001", msg="跨服战已经报名"},
	{id="2002", msg="跨服赛区不存在"},
	{id="2003", msg="跨服房间不存在"},
	{id="2004", msg="跨服服务器繁忙"},
	{id="2005", msg="跨服资源点错误"},
	{id="2006", msg="跨服挑战对象不存在"},
	{id="2007", msg="资源点因为攻击被锁"},
	{id="2008", msg="玩家处于冷却时间"},
	{id="2009", msg="玩家正在攻击资源"},
	{id="2010", msg="玩家已经占领了一个资源点"},
	{id="2011", msg="玩家自己攻击自己"},
	{id="2012", msg="跨服PVP状态错误"},
	{id="2013", msg="跨服报名等级不满足"},
	{id="2014", msg="跨服报名战场不存在"},
	{id="2015", msg="BUFF已最大"},
	{id="2016", msg="BUFF类型错误"},
	{id="2017", msg="鲜花鸡蛋类型错误"},
	{id="2018", msg="该轮没有鲜花鸡蛋押注"},
	{id="2019", msg="鲜花鸡蛋只能押一个人"},
	{id="2020", msg="鲜花鸡蛋奖励已经领取了"},
	{id="2021", msg="鲜花鸡蛋奖励条件不满足"},
	{id="2022", msg="已经领取过排行奖励"},
	{id="2023", msg="不在OB列表内"},
}


local __index_id = { 
	[0] = 1,
	[1] = 2,
	[2] = 3,
	[3] = 4,
	[4] = 5,
	[5] = 6,
	[6] = 7,
	[7] = 8,
	[8] = 9,
	[9] = 10,
	[10] = 11,
	[11] = 12,
	[12] = 13,
	[13] = 14,
	[14] = 15,
	[15] = 16,
	[16] = 17,
	[17] = 18,
	[18] = 19,
	[19] = 20,
	[20] = 21,
	[21] = 22,
	[22] = 23,
	[23] = 24,
	[24] = 25,
	[25] = 26,
	[26] = 27,
	[27] = 28,
	[28] = 29,
	[29] = 30,
	[30] = 31,
	[31] = 32,
	[32] = 33,
	[33] = 34,
	[34] = 35,
	[35] = 36,
	[36] = 37,
	[37] = 38,
	[38] = 39,
	[39] = 40,
	[40] = 41,
	[41] = 42,
	[42] = 43,
	[43] = 44,
	[44] = 45,
	[45] = 46,
	[46] = 47,
	[47] = 48,
	[48] = 49,
	[49] = 50,
	[50] = 51,
	[51] = 52,
	[52] = 53,
	[53] = 54,
	[54] = 55,
	[55] = 56,
	[56] = 57,
	[57] = 58,
	[58] = 59,
	[59] = 60,
	[60] = 61,
	[61] = 62,
	[62] = 63,
	[63] = 64,
	[64] = 65,
	[65] = 66,
	[66] = 67,
	[67] = 68,
	[68] = 69,
	[69] = 70,
	[70] = 71,
	[71] = 72,
	[72] = 73,
	[73] = 74,
	[74] = 75,
	[75] = 76,
	[76] = 77,
	[77] = 78,
	[78] = 79,
	[79] = 80,
	[80] = 81,
	[81] = 82,
	[82] = 83,
	[83] = 84,
	[84] = 85,
	[85] = 86,
	[86] = 87,
	[87] = 88,
	[88] = 89,
	[89] = 90,
	[90] = 91,
	[91] = 92,
	[92] = 93,
	[93] = 94,
	[94] = 95,
	[95] = 96,
	[96] = 97,
	[97] = 98,
	[98] = 99,
	[99] = 100,
	[100] = 101,
	[101] = 102,
	[102] = 103,
	[103] = 104,
	[104] = 105,
	[105] = 106,
	[106] = 107,
	[107] = 108,
	[108] = 109,
	[109] = 110,
	[110] = 111,
	[111] = 112,
	[112] = 113,
	[113] = 114,
	[114] = 115,
	[115] = 116,
	[116] = 117,
	[117] = 118,
	[118] = 119,
	[119] = 120,
	[120] = 121,
	[121] = 122,
	[122] = 123,
	[123] = 124,
	[124] = 125,
	[125] = 126,
	[126] = 127,
	[127] = 128,
	[128] = 129,
	[129] = 130,
	[130] = 131,
	[131] = 132,
	[132] = 133,
	[133] = 134,
	[134] = 135,
	[135] = 136,
	[136] = 137,
	[137] = 138,
	[138] = 139,
	[139] = 140,
	[140] = 141,
	[141] = 142,
	[142] = 143,
	[143] = 144,
	[144] = 145,
	[145] = 146,
	[146] = 147,
	[147] = 148,
	[148] = 149,
	[149] = 150,
	[150] = 151,
	[151] = 152,
	[152] = 153,
	[153] = 154,
	[154] = 155,
	[155] = 156,
	[156] = 157,
	[157] = 158,
	[158] = 159,
	[159] = 160,
	[160] = 161,
	[161] = 162,
	[162] = 163,
	[163] = 164,
	[164] = 165,
	[165] = 166,
	[166] = 167,
	[167] = 168,
	[168] = 169,
	[169] = 170,
	[170] = 171,
	[171] = 172,
	[172] = 173,
	[173] = 174,
	[174] = 175,
	[175] = 176,
	[176] = 177,
	[177] = 178,
	[178] = 179,
	[179] = 180,
	[180] = 181,
	[181] = 182,
	[182] = 183,
	[183] = 184,
	[184] = 185,
	[185] = 186,
	[186] = 187,
	[187] = 188,
	[188] = 189,
	[189] = 190,
	[190] = 191,
	[191] = 192,
	[192] = 193,
	[193] = 194,
	[194] = 195,
	[195] = 196,
	[196] = 197,
	[197] = 198,
	[198] = 199,
	[199] = 200,
	[200] = 201,
	[201] = 202,
	[202] = 203,
	[203] = 204,
	[204] = 205,
	[205] = 206,
	[206] = 207,
	[207] = 208,
	[208] = 209,
	[209] = 210,
	[210] = 211,
	[211] = 212,
	[212] = 213,
	[213] = 214,
	[214] = 215,
	[215] = 216,
	[216] = 217,
	[217] = 218,
	[218] = 219,
	[219] = 220,
	[220] = 221,
	[221] = 222,
	[222] = 223,
	[223] = 224,
	[224] = 225,
	[225] = 226,
	[226] = 227,
	[227] = 228,
	[228] = 229,
	[229] = 230,
	[230] = 231,
	[231] = 232,
	[232] = 233,
	[233] = 234,
	[234] = 235,
	[235] = 236,
	[236] = 237,
	[237] = 238,
	[238] = 239,
	[239] = 240,
	[240] = 241,
	[241] = 242,
	[242] = 243,
	[243] = 244,
	[244] = 245,
	[245] = 246,
	[246] = 247,
	[247] = 248,
	[248] = 249,
	[249] = 250,
	[250] = 251,
	[251] = 252,
	[252] = 253,
	[253] = 254,
	[254] = 255,
	[255] = 256,
	[256] = 257,
	[257] = 258,
	[258] = 259,
	[259] = 260,
	[260] = 261,
	[261] = 262,
	[262] = 263,
	[263] = 264,
	[264] = 265,
	[265] = 266,
	[266] = 267,
	[267] = 268,
	[268] = 269,
	[269] = 270,
	[270] = 271,
	[271] = 272,
	[272] = 273,
	[273] = 274,
	[274] = 275,
	[275] = 276,
	[276] = 277,
	[277] = 278,
	[278] = 279,
	[279] = 280,
	[280] = 281,
	[281] = 282,
	[282] = 283,
	[283] = 284,
	[284] = 285,
	[285] = 286,
	[286] = 287,
	[287] = 288,
	[288] = 289,
	[289] = 290,
	[290] = 291,
	[291] = 292,
	[292] = 293,
	[293] = 294,
	[294] = 295,
	[295] = 296,
	[296] = 297,
	[297] = 298,
	[298] = 299,
	[299] = 300,
	[300] = 301,
	[301] = 302,
	[302] = 303,
	[303] = 304,
	[304] = 305,
	[305] = 306,
	[306] = 307,
	[307] = 308,
	[308] = 309,
	[309] = 310,
	[310] = 311,
	[311] = 312,
	[312] = 313,
	[313] = 314,
	[314] = 315,
	[315] = 316,
	[316] = 317,
	[317] = 318,
	[318] = 319,
	[319] = 320,
	[320] = 321,
	[321] = 322,
	[322] = 323,
	[323] = 324,
	[324] = 325,
	[325] = 326,
	[326] = 327,
	[327] = 328,
	[328] = 329,
	[329] = 330,
	[330] = 331,
	[331] = 332,
	[332] = 333,
	[333] = 334,
	[334] = 335,
	[335] = 336,
	[336] = 337,
	[337] = 338,
	[338] = 339,
	[339] = 340,
	[340] = 341,
	[341] = 342,
	[342] = 343,
	[343] = 344,
	[344] = 345,
	[345] = 346,
	[346] = 347,
	[347] = 348,
	[348] = 349,
	[349] = 350,
	[350] = 351,
	[351] = 352,
	[352] = 353,
	[353] = 354,
	[354] = 355,
	[355] = 356,
	[356] = 357,
	[357] = 358,
	[358] = 359,
	[359] = 360,
	[360] = 361,
	[361] = 362,
	[362] = 363,
	[363] = 364,
	[364] = 365,
	[365] = 366,
	[367] = 367,
	[368] = 368,
	[369] = 369,
	[370] = 370,
	[371] = 371,
	[372] = 372,
	[373] = 373,
	[374] = 374,
	[375] = 375,
	[376] = 376,
	[377] = 377,
	[378] = 378,
	[379] = 379,
	[380] = 380,
	[381] = 381,
	[382] = 382,
	[383] = 383,
	[384] = 384,
	[385] = 385,
	[386] = 386,
	[387] = 387,
	[388] = 388,
	[389] = 389,
	[1000] = 390,
	[1001] = 391,
	[1002] = 392,
	[1004] = 393,
	[1005] = 394,
	[1006] = 395,
	[1007] = 396,
	[1008] = 397,
	[1009] = 398,
	[1010] = 399,
	[1011] = 400,
	[1012] = 401,
	[1013] = 402,
	[1014] = 403,
	[1015] = 404,
	[1016] = 405,
	[1017] = 406,
	[1018] = 407,
	[1019] = 408,
	[1020] = 409,
	[1021] = 410,
	[1022] = 411,
	[1023] = 412,
	[1024] = 413,
	[1025] = 414,
	[1026] = 415,
	[1027] = 416,
	[1028] = 417,
	[1029] = 418,
	[1030] = 419,
	[1031] = 420,
	[1032] = 421,
	[1033] = 422,
	[1034] = 423,
	[1035] = 424,
	[1036] = 425,
	[1037] = 426,
	[1038] = 427,
	[1039] = 428,
	[1040] = 429,
	[1041] = 430,
	[1042] = 431,
	[1100] = 432,
	[1101] = 433,
	[1102] = 434,
	[1103] = 435,
	[1104] = 436,
	[1105] = 437,
	[1106] = 438,
	[1107] = 439,
	[1108] = 440,
	[1109] = 441,
	[1110] = 442,
	[1111] = 443,
	[1112] = 444,
	[1113] = 445,
	[1114] = 446,
	[1115] = 447,
	[1116] = 448,
	[1117] = 449,
	[1118] = 450,
	[1119] = 451,
	[1120] = 452,
	[1121] = 453,
	[2000] = 454,
	[2001] = 455,
	[2002] = 456,
	[2003] = 457,
	[2004] = 458,
	[2005] = 459,
	[2006] = 460,
	[2007] = 461,
	[2008] = 462,
	[2009] = 463,
	[2010] = 464,
	[2011] = 465,
	[2012] = 466,
	[2013] = 467,
	[2014] = 468,
	[2015] = 469,
	[2016] = 470,
	[2017] = 471,
	[2018] = 472,
	[2019] = 473,
	[2020] = 474,
	[2021] = 475,
	[2022] = 476,
	[2023] = 477,
}


function NetMsg_ERROR.getMsg(ret)
    local item = NetMsg_ERROR.data[__index_id[ret]]
	if item then
    	return item
	end
	return nil
end

return NetMsg_ERROR
