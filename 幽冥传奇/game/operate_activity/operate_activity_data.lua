 OperateActivityData = OperateActivityData or BaseClass()

--每日充值领取状态
DAILY_CHARGE_FETCH_ST = {
	CNNOT = 0,				--不可领
	CAN = 1,				--可领
	FETCHED = 2,			--已领
}

-- 达标竞技领取状态
STANDARD_SPROTS_FETCH_STATE = {
	NOT_COMPLETE = 0,				-- 未达成
	CAN_FETCH = 1,					-- 可领取
	HAVE_FETCHED = 2,				-- 已领取
	NO_CNT = 3,						-- 没有奖励指标了(已被领完)
}

PRAY_MONEY_TREE_FETCH_STATE = {
	CNNOT = 0,				--不可领
	CAN = 1,				--可领
	FETCHED = 2,			--已领
}

-- 运营活动大类
OperateActivityData.OperateActBigType = {
	SPORTS_TYPE = 1,			-- 达标竞技类
	SPORTS_RANK = 2,			-- 竞技排行
	OTHER = 3,					-- 其他
} 

-- 活动ID与事件ID对应表
OperateActivityData.ActIDEventIDMap = {
	[0] = OperateActivityEventType.SPORTS_TYPE_DATA_CHANGE,																-- 竞技类活动(特殊)
	[OPERATE_ACTIVITY_ID.DAILY_RECHARGE] = OperateActivityEventType.DAILY_CHARGE_DATA_CHANGE,							-- 每日充值
	[OPERATE_ACTIVITY_ID.TIME_LIMIT_GOODS] = OperateActivityEventType.TIME_LIMITED_GOODS_DATA_CHANGE,					-- 限时商品
	[OPERATE_ACTIVITY_ID.ACCUMULATE_RECHARGE] = OperateActivityEventType.TIME_LIMITED_HEAP_RECHARGE_CHANGE,				-- 累计充值
	[OPERATE_ACTIVITY_ID.ACCUMULATE_SPEND] = OperateActivityEventType.TIME_LIMITED_HEAP_CONSUME_CHANGE,					-- 累计消费

	[OPERATE_ACTIVITY_ID.REPEAT_CHARGE] = OperateActivityEventType.REPEAT_CHARGE_DATA_CHANGE,							-- 重复充值 
	[OPERATE_ACTIVITY_ID.SPEND_SCORE] = OperateActivityEventType.SPEND_SCORE_DATA_CHANGE,								-- 消费积分 
	[OPERATE_ACTIVITY_ID.DAY_NUM_CHARGE] = OperateActivityEventType.DAY_NUM_RECHARGE_DATA_CHANGE,						-- 天数充值 
	[OPERATE_ACTIVITY_ID.GROUP_PURCHASE] = OperateActivityEventType.GROUP_PURCHASE_DATA_CHANGE,							-- 团购活动
	[OPERATE_ACTIVITY_ID.WISH_WELL] = OperateActivityEventType.WISH_WELL_DATA_CHANGE,									-- 许愿井数据改变
	[OPERATE_ACTIVITY_ID.ADDUP_LOGIN] = OperateActivityEventType.ADDUP_LOGIN_DATA_CHANGE,								-- 累计登陆
	[OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE] = OperateActivityEventType.PRAY_MONEY_TREE_DATA_CHANGE,						-- 摇钱树信息改变
	[OPERATE_ACTIVITY_ID.TIME_LIMIT_GOODS_2] = OperateActivityEventType.TIME_LIMITED_GOODS_DATA_CHANGE_2,				-- 限时商品2
	[OPERATE_ACTIVITY_ID.JVBAO_PEN] = OperateActivityEventType.JV_BAO_PEN_DATA_CHANGE,									--聚宝盆
	[OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE_2] = OperateActivityEventType.PRAY_MONEY_TREE_DATA_CHANGE_2,					-- 摇钱树2信息改变
	[OPERATE_ACTIVITY_ID.SECRET_KEY_TREASURE] = OperateActivityEventType.SECRET_KEY_TREASURE_DATA, 						-- 秘钥宝藏数据
	[OPERATE_ACTIVITY_ID.LUCKY_BUY] = OperateActivityEventType.LUCKY_BUY_DATA, 											-- 幸运购数据
	[OPERATE_ACTIVITY_ID.DAILY_SPEND] = OperateActivityEventType.DAILY_CONSUME_CHANGE,									-- 每日累计消费
	[OPERATE_ACTIVITY_ID.DAILY_CHARGE] = OperateActivityEventType.DAILY_ACCU_CHARGE_CHANGE,								-- 每日累计充值
	[OPERATE_ACTIVITY_ID.DAY_NUM_SPEND] = OperateActivityEventType.DAY_NUM_SPEND_CHANGE,								-- 天天消费
	[OPERATE_ACTIVITY_ID.SUPER_GROUP_PURCHASE] = OperateActivityEventType.SUPER_GROUP_PURCHASE_DATA_CHANGE,				-- 超级团购活动
	[OPERATE_ACTIVITY_ID.DISCOUNT_LIMIT_BUY] = OperateActivityEventType.DISCOUNT_LIMIT_BUY_DATA_CHANGE,					-- 超值限购活动
	[OPERATE_ACTIVITY_ID.DISCOUNT_TREASURE] = OperateActivityEventType.DISCOUNT_TREASURE_DATA_CHANGE,					-- 宝物折扣活动
	[OPERATE_ACTIVITY_ID.PINGDAN_QIANGGOU] = OperateActivityEventType.PIN_DAN_DATA_CHANGE,								-- 拼单抢购活动
	[OPERATE_ACTIVITY_ID.CHARGE_GIVE_GIFT] = OperateActivityEventType.CHARGE_GIVE_GIFT_DATA,							-- 充值送礼
	[OPERATE_ACTIVITY_ID.CONSUME_GIVE_GIFT] = OperateActivityEventType.CONSUME_GIVE_GIFT_DATA,							-- 消费送礼
	[OPERATE_ACTIVITY_ID.ADDUP_LOGIN_GET_GIFT] = OperateActivityEventType.ADDUP_LOGIN_GIFT_DATA_CHANGE,					-- 新春登陆大礼
	[OPERATE_ACTIVITY_ID.ADDUP_CHARGE_PAYBACK] = OperateActivityEventType.ADDUP_RECHARGE_PAYBACK_DATA_CHANGE,			-- 累充返利
	[OPERATE_ACTIVITY_ID.ADDUP_SPEND_PAYBACK] = OperateActivityEventType.ADDUP_SPEND_PAYBACK_DATA,						-- 累消返利
	[OPERATE_ACTIVITY_ID.TIME_LIMIT_ONCE_CHARGE] = OperateActivityEventType.TIME_LIMIT_ONCE_CHARGE,						-- 限时单笔
	[OPERATE_ACTIVITY_ID.NEW_CHARGE_RANK] = OperateActivityEventType.NEW_CHARGE_RANK_DATA,								-- 新充值排行
	[OPERATE_ACTIVITY_ID.NEW_SPEND_RANK] = OperateActivityEventType.NEW_SPEND_RANK_DATA,								-- 新消费排行
	[OPERATE_ACTIVITY_ID.CONVERT_AWARD] = OperateActivityEventType.CONVERT_AWARD_DATA,									-- 奖励兑换
	[OPERATE_ACTIVITY_ID.CONTINUOUS_LOGIN] = OperateActivityEventType.CONTINUOUS_LOGIN_DATA,							-- 连续登录
	[OPERATE_ACTIVITY_ID.TEN_TIME_EXPLORE_GIVE] = OperateActivityEventType.TEN_TIME_GIVE_DATA_CHANGE,					-- 寻宝10连抽送奖
	[OPERATE_ACTIVITY_ID.SECRET_SHOP] = OperateActivityEventType.SECRET_SHOP_DATA,										-- 神秘商店
	[OPERATE_ACTIVITY_ID.WORLD_CUP_BOSS] = OperateActivityEventType.WORLD_CUP_BOSS_DATA,								-- 世界杯BOSS
	[OPERATE_ACTIVITY_ID.CONTINUOUS_ADDUP_CHARGE] = OperateActivityEventType.CONTINOUS_ADDUP_CHARGE_DATA,				-- 连续累充
	[OPERATE_ACTIVITY_ID.NEW_REPEAT_CHARGE] = OperateActivityEventType.NEW_REPEAT_CHARGE_DATA,							-- 新重复充值
	[OPERATE_ACTIVITY_ID.SPENDSCORE_EXCHANGE_PAYBACK] = OperateActivityEventType.SPENDSCORE_EXCH_PAYBACK_DATA,
	[OPERATE_ACTIVITY_ID.CONTINUOUS_ADDUP_CHARGE_NEW] = OperateActivityEventType.NEW_CONTI_ADDUP_CHARGE_DATA,
	[OPERATE_ACTIVITY_ID.LOGIN_SEND_GIFT] = OperateActivityEventType.LOGIN_SEND_GIFT_DATA,
	[OPERATE_ACTIVITY_ID.BOSS_TREASURE] = OperateActivityEventType.BOSS_TREASURE_DATA,
	[OPERATE_ACTIVITY_ID.HAPPY_SHOPPING_CART] = OperateActivityEventType.HAPPY_SHOP_CART_DATA,

}

-- 活动ID与初始配置数据函数名对应表
OperateActivityData.ActIDInitCfgFuncMap = {
	[OPERATE_ACTIVITY_ID.REPEAT_CHARGE] = "SetRepeatChargeBaseData",
	["SportsRank"] = "InitSportsRankCfgData",
	[OPERATE_ACTIVITY_ID.TIME_LIMIT_GOODS] = "InitLimitGoodsInfo",
	[OPERATE_ACTIVITY_ID.TIME_LIMIT_GOODS_2] = "InitLimitGoodsInfoTwo",
	[OPERATE_ACTIVITY_ID.YB_WHEEL] = "InitYBWheelCfgInfo",
	[OPERATE_ACTIVITY_ID.LUCK_TURN_WHEEL] = "InitLuckTurnCfgInfo",
	[OPERATE_ACTIVITY_ID.JVBAO_PEN] = "InitJvBaoPenCfgInfo",
	[OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE] = "InitPrayMoneyTreeCfgInfo",
	[OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE_2] = "InitPrayMoneyTreeCfgInfoTwo",
	[OPERATE_ACTIVITY_ID.TREASURE_DROP] = "InitTreasureDropCfgInfo",
	[OPERATE_ACTIVITY_ID.SECRET_KEY_TREASURE] = "InitSecretKeyTreasureCfgInfo",
	[OPERATE_ACTIVITY_ID.LUCKY_BUY] = "InitLuckyBuyCfgInfo",
	[OPERATE_ACTIVITY_ID.PINGDAN_QIANGGOU] = "InitPinDanQiangGouCfgData",
	[OPERATE_ACTIVITY_ID.CHARGE_GIVE_GIFT] = "InitChargeGiveGiftCfgData",
	[OPERATE_ACTIVITY_ID.CONSUME_GIVE_GIFT] = "InitConsumeGiveGiftCfgData",
	[OPERATE_ACTIVITY_ID.ADDUP_LOGIN_GET_GIFT] = "InitAddupLoginBaseInfo",
	[OPERATE_ACTIVITY_ID.TIME_LIMIT_ONCE_CHARGE] = "InitTimeLimitOnceCharge",
	[OPERATE_ACTIVITY_ID.NEW_CHARGE_RANK] = "InitNewChargeRank",
	[OPERATE_ACTIVITY_ID.NEW_SPEND_RANK] = "InitNewSpendRank",
	[OPERATE_ACTIVITY_ID.CONVERT_AWARD] = "InitConvertAwardConfig",
	[OPERATE_ACTIVITY_ID.CONTINUOUS_LOGIN] = "InitContinuousLoginBaseInfo",
	[OPERATE_ACTIVITY_ID.TEN_TIME_EXPLORE_GIVE] = "InitTenTimeExploreGiveData",
	[OPERATE_ACTIVITY_ID.NEW_REPEAT_CHARGE] = "InitNewRepeatChargeData",
	[OPERATE_ACTIVITY_ID.SPENDSCORE_EXCHANGE_PAYBACK] = "InitSpendscoreExchage",
	[OPERATE_ACTIVITY_ID.CONTINUOUS_ADDUP_CHARGE_NEW] = "InitNewContinousAddupChargeData",
	[OPERATE_ACTIVITY_ID.LOGIN_SEND_GIFT] = "InitLoginSendGiftData",
	[OPERATE_ACTIVITY_ID.ROTATE_PANEL_AWARD] = "InitRotatePanelAwardCfgInfo",
	[OPERATE_ACTIVITY_ID.LEGENDRY_REPUTATION] = "InitLegendryReputationCfgInfo",
	[OPERATE_ACTIVITY_ID.HAPPY_SHOPPING_CART] = "InitHappyShopCartData",

}

-- 活动ID与初始化或设置数据函数名对应表
OperateActivityData.ActIDInitSetFuncNameMap = {
	["SportsType"] = "SetOperateSportsTypeData",									--竞技类活动(特殊)
	["SportsRank"] = "SetSportsRankMyRankByActID",									--竞技排行类(特殊)
	[OPERATE_ACTIVITY_ID.DAILY_RECHARGE] = "SetDailyChargeData",					--每日充值
	[OPERATE_ACTIVITY_ID.TIME_LIMIT_GOODS] = "SetLimitGoodsRestTime",				--限时商品	
	[OPERATE_ACTIVITY_ID.ACCUMULATE_RECHARGE] = "InitRechargeData",					--累计充值
	[OPERATE_ACTIVITY_ID.ACCUMULATE_SPEND] = "InitConsumeData",						--累计消费
	[OPERATE_ACTIVITY_ID.REPEAT_CHARGE] = "SetRepeatChargeRestTime",				--重复充值	
	[OPERATE_ACTIVITY_ID.SPEND_SCORE] = "InitSpendScoreShopData",					--消费积分	
	[OPERATE_ACTIVITY_ID.DAY_NUM_CHARGE] = "InitDayNumRechargeData",				--天数充值	
	[OPERATE_ACTIVITY_ID.GROUP_PURCHASE] = "SetGroupPurchaseData",					--团购活动	
	[OPERATE_ACTIVITY_ID.WISH_WELL] = "SetWishWellData",							--许愿井
	[OPERATE_ACTIVITY_ID.ADDUP_LOGIN] = "InitAddupLoginData",						--累计登陆
	[OPERATE_ACTIVITY_ID.YB_WHEEL] = "SetYBWheelData",								--元宝转盘
	[OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE] = "SetPrayMoneyTreeData",					--摇钱树
	[OPERATE_ACTIVITY_ID.LUCK_TURN_WHEEL] = "SetLuckTurnData",						--幸运转盘
	[OPERATE_ACTIVITY_ID.TIME_LIMIT_GOODS_2] = "SetLimitGoodsRestTimeTwo",			--限时商品2	
	[OPERATE_ACTIVITY_ID.JVBAO_PEN] = "SetJvBaoPenData",							--聚宝盆
	[OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE_2] = "SetPrayMoneyTreeDataTwo",			--摇钱树2
	[OPERATE_ACTIVITY_ID.TREASURE_DROP] = "SetTreasureDropData",					--天降奇宝
	[OPERATE_ACTIVITY_ID.SECRET_KEY_TREASURE] = "SetSecretKeyTreasureData", 		--秘钥宝藏
	[OPERATE_ACTIVITY_ID.LUCKY_BUY] = "SetLuckyBuyData", 							--幸运购
	[OPERATE_ACTIVITY_ID.DAILY_SPEND] = "InitDailyConsumeData",						--每日累计消费
	[OPERATE_ACTIVITY_ID.DAILY_CHARGE] = "InitDailyRechargeData",					--每日累计充值
	[OPERATE_ACTIVITY_ID.DAY_NUM_SPEND] = "InitDayNumSpendData",					-- 天天消费
	[OPERATE_ACTIVITY_ID.SUPER_GROUP_PURCHASE] = "SetSuperGroupPurchaseData",		-- 超级团购活动
	[OPERATE_ACTIVITY_ID.DISCOUNT_LIMIT_BUY] = "InitDiscountLimitShopData",			-- 超值限购
	[OPERATE_ACTIVITY_ID.DISCOUNT_TREASURE] = "InitDiscountTreasureData",			-- 宝物折扣
	[OPERATE_ACTIVITY_ID.PINGDAN_QIANGGOU] = "SetPinDanQiangGouData",				-- 拼单抢购活动
	[OPERATE_ACTIVITY_ID.CHARGE_GIVE_GIFT] = "SetChargeGiveGiftData",				-- 充值送礼
	[OPERATE_ACTIVITY_ID.CONSUME_GIVE_GIFT] = "SetConsumeGiveGiftData",				-- 消费送礼
	[OPERATE_ACTIVITY_ID.ADDUP_LOGIN_GET_GIFT] = "SetAddUpLoginGetGiftData",		-- 新春登陆大礼
	[OPERATE_ACTIVITY_ID.ADDUP_CHARGE_PAYBACK] = "SetAddupRechargePaybackData",		-- 累充返利
	[OPERATE_ACTIVITY_ID.ADDUP_SPEND_PAYBACK] = "SetAddupSpendPaybackData",			-- 累消返利
	[OPERATE_ACTIVITY_ID.TIME_LIMIT_ONCE_CHARGE] = "SetTimeLimitOnceChargeData",	-- 限时单笔
	[OPERATE_ACTIVITY_ID.NEW_CHARGE_RANK] = "SetNewChargeRankData",					-- 新充值排行
	[OPERATE_ACTIVITY_ID.NEW_SPEND_RANK] = "SetNewSpendRankData",					-- 新消费排行
	[OPERATE_ACTIVITY_ID.CONVERT_AWARD] = "SetConvertAwardData",					-- 奖励兑换
	[OPERATE_ACTIVITY_ID.CONTINUOUS_LOGIN] = "SetContinuousLoginGetGiftData",		-- 连续登录
	[OPERATE_ACTIVITY_ID.TEN_TIME_EXPLORE_GIVE] = "SetTenTimeExploreGiveData",		-- 寻宝10连抽送奖
	[OPERATE_ACTIVITY_ID.SECRET_SHOP] = "SetSecretShopData",						-- 神秘商店
	[OPERATE_ACTIVITY_ID.WORLD_CUP_BOSS] = "SetWorldCupBossData",					-- 世界杯BOSS
	[OPERATE_ACTIVITY_ID.CONTINUOUS_ADDUP_CHARGE] = "SetContinousAddupChargeData",	-- 连续累充
	[OPERATE_ACTIVITY_ID.NEW_REPEAT_CHARGE] = "UpdateNewRepeatChargeData",
	[OPERATE_ACTIVITY_ID.FIRST_CHARGE_PAYBACK] = "SetFirstChargePaybackData",		-- 首充返利
	[OPERATE_ACTIVITY_ID.SPENDSCORE_EXCHANGE_PAYBACK] = "SetSpendscoreExchageData",
	[OPERATE_ACTIVITY_ID.CONTINUOUS_ADDUP_CHARGE_NEW] = "SetNewContinousAddupChargeData",
	[OPERATE_ACTIVITY_ID.LOGIN_SEND_GIFT] = "SetLoginSendGiftData",
	[OPERATE_ACTIVITY_ID.BOSS_TREASURE] = "SetBossTreasureData",
	[OPERATE_ACTIVITY_ID.ROTATE_PANEL_AWARD] = "SetRotatePanelAwardData",
	[OPERATE_ACTIVITY_ID.LEGENDRY_REPUTATION] = "SetLegendryReputationData",
	[OPERATE_ACTIVITY_ID.HAPPY_SHOPPING_CART] = "SetHappyShopCartData",

}

-- 活动ID与更新数据函数名对应表
OperateActivityData.ActIDUpdateFuncNameMap = {
	[OPERATE_ACTIVITY_ID.DAILY_RECHARGE] = "SetDailyChargeData",					--每日充值
	[OPERATE_ACTIVITY_ID.TIME_LIMIT_GOODS] = "SetLimitGoodsRestTime",				--限时商品	
	[OPERATE_ACTIVITY_ID.ACCUMULATE_RECHARGE] = "UpdateRechargeData",				--累计充值
	[OPERATE_ACTIVITY_ID.ACCUMULATE_SPEND] = "UpdateConsumeData",					--累计消费
	[OPERATE_ACTIVITY_ID.REPEAT_CHARGE] = "SetRepeatChargeRestTime",				--重复充值	
	[OPERATE_ACTIVITY_ID.SPEND_SCORE] = "UpdateSpendScoreData",						--消费积分	
	[OPERATE_ACTIVITY_ID.DAY_NUM_CHARGE] = "UpdateDayNumRechargeData",				--天数充值	
	[OPERATE_ACTIVITY_ID.WISH_WELL] = "SetWishWellData",							--许愿井
	[OPERATE_ACTIVITY_ID.ADDUP_LOGIN] = "UpdateAddupLoginData",						--累计登陆
	[OPERATE_ACTIVITY_ID.YB_WHEEL] = "UpdateYBWheelData",							--元宝转盘
	[OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE] = "UpdatePrayMoneyTreeData",				--摇钱树
	[OPERATE_ACTIVITY_ID.LUCK_TURN_WHEEL] = "UpdateLuckTurnData",					--幸运转盘
	[OPERATE_ACTIVITY_ID.TIME_LIMIT_GOODS_2] = "SetLimitGoodsRestTimeTwo",			--限时商品2
	[OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE_2] = "UpdatePrayMoneyTreeDataTwo",			--摇钱树2
	[OPERATE_ACTIVITY_ID.TREASURE_DROP] = "UpdateTreasureDropData",					--天降奇宝
	[OPERATE_ACTIVITY_ID.SECRET_KEY_TREASURE] = "UpdateSecretKeyTreasureData",  	--秘钥宝藏
	[OPERATE_ACTIVITY_ID.LUCKY_BUY] = "SetLuckyBuyData", 							--幸运购
	[OPERATE_ACTIVITY_ID.DAILY_SPEND] = "UpdateDailyConsumeData",					--每日累计消费
	[OPERATE_ACTIVITY_ID.DAILY_CHARGE] = "UpdateDailyRechargeData",					--每日累计充值
	[OPERATE_ACTIVITY_ID.DAY_NUM_SPEND] = "UpdateDayNumSpendData",					--天天消费
	[OPERATE_ACTIVITY_ID.DISCOUNT_LIMIT_BUY] = "UpdateDiscountLimitData",			--超值限购	
	[OPERATE_ACTIVITY_ID.DISCOUNT_TREASURE] = "UpdateDiscountTreasureData",			-- 宝物折扣
	[OPERATE_ACTIVITY_ID.PINGDAN_QIANGGOU] = "UpdatePinDanQiangGouData",			-- 拼单抢购活动
	[OPERATE_ACTIVITY_ID.CHARGE_GIVE_GIFT] = "UpdateChargeGiveGiftData",			-- 充值送礼
	[OPERATE_ACTIVITY_ID.CONSUME_GIVE_GIFT] = "UpdateConsumeGiveGiftData",			-- 消费送礼
	[OPERATE_ACTIVITY_ID.TIME_LIMIT_ONCE_CHARGE] = "SetTimeLimitOnceChargeData",	-- 限时单笔
	[OPERATE_ACTIVITY_ID.NEW_CHARGE_RANK] = "SetNewChargeRankData",					-- 新充值排行
	[OPERATE_ACTIVITY_ID.NEW_SPEND_RANK] = "SetNewSpendRankData",					-- 新消费排行
	[OPERATE_ACTIVITY_ID.CONVERT_AWARD] = "UpdateConvertAwardData",					-- 奖励兑换
	[OPERATE_ACTIVITY_ID.CONTINUOUS_LOGIN] = "UpdateContinuousLoginData",			-- 连续登录
	[OPERATE_ACTIVITY_ID.TEN_TIME_EXPLORE_GIVE] = "UpdateTenTimeExploreGiveData",	-- 寻宝10连抽送奖
	[OPERATE_ACTIVITY_ID.SECRET_SHOP] = "SetSecretShopData",						-- 神秘商店
	[OPERATE_ACTIVITY_ID.WORLD_CUP_BOSS] = "UpdateWorldCupBossData",				-- 世界杯BOSS
	[OPERATE_ACTIVITY_ID.CONTINUOUS_ADDUP_CHARGE] = "SetContinousAddupChargeData",	-- 连续累充
	[OPERATE_ACTIVITY_ID.NEW_REPEAT_CHARGE] = "UpdateNewRepeatChargeData",
	[OPERATE_ACTIVITY_ID.FIRST_CHARGE_PAYBACK] = "SetFirstChargePaybackData",		-- 首充返利
	[OPERATE_ACTIVITY_ID.SPENDSCORE_EXCHANGE_PAYBACK] = "SetSpendscoreExchageData",
	[OPERATE_ACTIVITY_ID.CONTINUOUS_ADDUP_CHARGE_NEW] = "UpdateNewContinousAddupCharge",
	[OPERATE_ACTIVITY_ID.LOGIN_SEND_GIFT] = "UpdateLoginSendGift",
	[OPERATE_ACTIVITY_ID.BOSS_TREASURE] = "SetBossTreasureData",
	[OPERATE_ACTIVITY_ID.ROTATE_PANEL_AWARD] = "UpdateRotatePanelAwardData",
	[OPERATE_ACTIVITY_ID.LEGENDRY_REPUTATION] = "UpdateLegendryReputationData",
	[OPERATE_ACTIVITY_ID.HAPPY_SHOPPING_CART] = "UpdateHappyShopCart",

}

-- 活动ID与清理数据函数名对应表
OperateActivityData.ActIDClearFuncNameMap = {
	["SportsType"] = "ClearSportsTypeActDataByActID",								--竞技类活动(特殊)
	["SportsRank"] = "ClearSportsRankDataByActID",									--竞技排行类活动(特殊)
	[OPERATE_ACTIVITY_ID.DAILY_RECHARGE] = "ClearDailyChargeData",					--每日充值
	[OPERATE_ACTIVITY_ID.TIME_LIMIT_GOODS] = "ClearLimitGoodsData",					--限时商品	
	[OPERATE_ACTIVITY_ID.ACCUMULATE_RECHARGE] = "ClearRechargeData",				--累计充值
	[OPERATE_ACTIVITY_ID.ACCUMULATE_SPEND] = "ClearConsumeData",					--累计消费
	[OPERATE_ACTIVITY_ID.REPEAT_CHARGE] = "ClearRepeatChargeData",					--重复充值	
	[OPERATE_ACTIVITY_ID.SPEND_SCORE] = "ClearSpendScoreData",						--消费积分	
	[OPERATE_ACTIVITY_ID.DAY_NUM_CHARGE] = "ClearDayNumChargeData",					--天数充值	
	[OPERATE_ACTIVITY_ID.GROUP_PURCHASE] = "ClearGroupPurchaseData",				--团购活动	
	[OPERATE_ACTIVITY_ID.WISH_WELL] = "ClearWishWellData",							--许愿井
	[OPERATE_ACTIVITY_ID.ADDUP_LOGIN] = "ClearAddupLoginData",						--累计登陆
	[OPERATE_ACTIVITY_ID.YB_WHEEL] = "ClearYBWheelData",							--元宝转盘
	[OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE] = "ClearPrayMoneyTreeData",				--摇钱树
	[OPERATE_ACTIVITY_ID.LUCK_TURN_WHEEL] = "ClearLuckTurnData",					--幸运转盘
	[OPERATE_ACTIVITY_ID.TIME_LIMIT_GOODS_2] = "ClearLimitGoodsDataTwo",			--限时商品2
	[OPERATE_ACTIVITY_ID.JVBAO_PEN] = "ClearJvBaoPenData",							--聚宝盆
	[OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE_2] = "ClearPrayMoneyTreeDataTwo",			--摇钱树2
	[OPERATE_ACTIVITY_ID.TREASURE_DROP] = "ClearTreasureDropData",					--天降奇宝
	[OPERATE_ACTIVITY_ID.SECRET_KEY_TREASURE] = "ClearSecretKeyTreasureData", 		--秘钥宝藏
	[OPERATE_ACTIVITY_ID.LUCKY_BUY] = "ClearLuckyBuyData", 							--幸运购
	[OPERATE_ACTIVITY_ID.DAILY_SPEND] = "ClearDailyConsumeData",					--每日累计消费
	[OPERATE_ACTIVITY_ID.DAILY_CHARGE] = "ClearDailyRechargeData",					--每日累计充值
	[OPERATE_ACTIVITY_ID.DAY_NUM_CHARGE] = "ClearDayNumSpendData",					--天天消费
	[OPERATE_ACTIVITY_ID.SUPER_GROUP_PURCHASE] = "ClearSuperGroupPurchaseData",		--超级团购活动	
	[OPERATE_ACTIVITY_ID.DISCOUNT_LIMIT_BUY] = "ClearDiscountLimitData",			--超值限购
	[OPERATE_ACTIVITY_ID.DISCOUNT_TREASURE] = "ClearDiscountTreasureData",			-- 宝物折扣
	[OPERATE_ACTIVITY_ID.PINGDAN_QIANGGOU] = "ClearPinDanQiangGouData",				-- 拼单抢购活动
	[OPERATE_ACTIVITY_ID.CHARGE_GIVE_GIFT] = "ClearChargeGiveGiftData",				-- 充值送礼
	[OPERATE_ACTIVITY_ID.CONSUME_GIVE_GIFT] = "ClearConsumeGiveGiftData",			-- 消费送礼
	[OPERATE_ACTIVITY_ID.ADDUP_LOGIN_GET_GIFT] = "ClearAddupLoginGetGiftData",		-- 新春大礼
	[OPERATE_ACTIVITY_ID.TIME_LIMIT_ONCE_CHARGE] = "ClearTimeLimitOnceChargeData",	-- 限时单笔
	[OPERATE_ACTIVITY_ID.NEW_CHARGE_RANK] = "ClearNewChargeRankData",				-- 新充值排行
	[OPERATE_ACTIVITY_ID.NEW_SPEND_RANK] = "ClearNewSpendRankData",					-- 新消费排行
	[OPERATE_ACTIVITY_ID.BOSS_ATK_INCOME] = "ClearBossAtkIncome",					-- 怪物来袭
	[OPERATE_ACTIVITY_ID.CONVERT_AWARD] = "ClearConvertAwardData",
	[OPERATE_ACTIVITY_ID.CONTINUOUS_LOGIN] = "ClearContinuousLoginGetGiftData",		-- 连续登录
	[OPERATE_ACTIVITY_ID.TEN_TIME_EXPLORE_GIVE] = "ClearTenTimeExploreGiveData",	-- 寻宝10连抽送奖
	[OPERATE_ACTIVITY_ID.SECRET_SHOP] = "ClearSecretShopData",						-- 神秘商店
	[OPERATE_ACTIVITY_ID.CONTINUOUS_ADDUP_CHARGE] = "ClearContinousAddupChargeData",-- 连续累充
	[OPERATE_ACTIVITY_ID.SPENDSCORE_EXCHANGE_PAYBACK] = "ClearSpendscoreExchageData",
	[OPERATE_ACTIVITY_ID.CONTINUOUS_ADDUP_CHARGE_NEW] = "ClearNewContinousAddupChargeData",
	[OPERATE_ACTIVITY_ID.LOGIN_SEND_GIFT] = "ClearLoginSendGiftData",
	[OPERATE_ACTIVITY_ID.BOSS_TREASURE] = "ClearBossTreasureData",
	[OPERATE_ACTIVITY_ID.ROTATE_PANEL_AWARD] = "ClearRotatePanelAwardData",
	[OPERATE_ACTIVITY_ID.LEGENDRY_REPUTATION] = "ClearLegendryReputationData",
	[OPERATE_ACTIVITY_ID.HAPPY_SHOPPING_CART] = "ClearHappyShopCartData",	

}

-- 活动ID与提醒名对应表
OperateActivityData.ActIDRemindNameMap = {
	[OPERATE_ACTIVITY_ID.DAILY_RECHARGE] = RemindName.OpActDailyCharge,							-- 每日充值
	[OPERATE_ACTIVITY_ID.TIME_LIMIT_GOODS] = RemindName.OpActLimitGoods,						-- 限时商品
	[OPERATE_ACTIVITY_ID.ACCUMULATE_RECHARGE] = RemindName.OpActAccuCharge,						-- 累计充值
	[OPERATE_ACTIVITY_ID.ACCUMULATE_SPEND] = RemindName.OpActAccuSpend,							-- 累计消费

	[OPERATE_ACTIVITY_ID.EXP_SPORTS] = RemindName.OpActExpSports,								-- 经验竞技
	[OPERATE_ACTIVITY_ID.BOSS_SPORTS] = RemindName.OpActBossSports,								-- Boss积分竞技
	[OPERATE_ACTIVITY_ID.BLOOD_SPORTS] = RemindName.OpActBloodSports,							-- 血符值竞技
	[OPERATE_ACTIVITY_ID.SHIELD_SPORTS] = RemindName.OpActShieldSports,							-- 神盾值竞技
	[OPERATE_ACTIVITY_ID.DIAMOND_SPORTS] = RemindName.OpActDiamondSports,						-- 宝石值竞技
	[OPERATE_ACTIVITY_ID.SEALBEAD_SPORTS] = RemindName.OpActSealBeadSports,						-- 魂珠值竞技
	[OPERATE_ACTIVITY_ID.INJECT_SPORTS] = RemindName.OpActInjectSports,							-- 灵气值竞技
	[OPERATE_ACTIVITY_ID.SWING_SPORTS] = RemindName.OpActSwingSports,							-- 翅膀祝福值竞技
	[OPERATE_ACTIVITY_ID.SOUL_STONE_SPORTS] = RemindName.OpActSoulStoneSports,					-- 魂石竞技

	[OPERATE_ACTIVITY_ID.REPEAT_CHARGE] = RemindName.OpActRepeatCharge,							-- 重复充值 
	[OPERATE_ACTIVITY_ID.SPEND_SCORE] = RemindName.OpActSpendScore,								-- 消费积分 
	[OPERATE_ACTIVITY_ID.DAY_NUM_CHARGE] = RemindName.OpActDayNumCharge,						-- 天数充值 
	[OPERATE_ACTIVITY_ID.GROUP_PURCHASE] = RemindName.OpActGroupPurchase,						-- 团购活动

	[OPERATE_ACTIVITY_ID.DAILY_EXP_SPORTS] = RemindName.OpActDailyExpSports,					-- 每日经验竞技			
	[OPERATE_ACTIVITY_ID.DAILY_BOSS_SPORTS] = RemindName.OpActDailyBossSports,					-- 每日Boss积分竞技	
	[OPERATE_ACTIVITY_ID.DAILY_BLOOD_SPORTS] = RemindName.OpActDailyBloodSports,				-- 每日血符值竞技		
	[OPERATE_ACTIVITY_ID.DAILY_SHIELD_SPORTS] = RemindName.OpActDailyShieldSports,				-- 每日神盾值竞技		
	[OPERATE_ACTIVITY_ID.DAILY_DIAMOND_SPORTS] = RemindName.OpActDailyDiamondSports,			-- 每日宝石值竞技		
	[OPERATE_ACTIVITY_ID.DAILY_SEALBEAD_SPORTS] = RemindName.OpActDailySealBeadSports,			-- 每日魂珠值竞技		
	[OPERATE_ACTIVITY_ID.DAILY_INJECT_SPORTS] = RemindName.OpActDailyInjectSports,				-- 每日灵气值竞技		
	[OPERATE_ACTIVITY_ID.DAILY_SWING_SPORTS] = RemindName.OpActDailySwingSports,				-- 每日翅膀祝福值竞技	
	[OPERATE_ACTIVITY_ID.DAILY_SOUL_STONE_SPORTS] = RemindName.OpActDailySoulStoneSports,		-- 每日魂石竞技						

	[OPERATE_ACTIVITY_ID.WISH_WELL] = RemindName.OpActWishWell,									-- 运营活动-许愿井
	[OPERATE_ACTIVITY_ID.ADDUP_LOGIN] = RemindName.OpActAddupLogin,								-- 运营活动-累计登陆
	[OPERATE_ACTIVITY_ID.YB_WHEEL] = RemindName.OpActYBWheel,									-- 运营活动-元宝转盘
	[OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE] = RemindName.OpActPrayTree,							-- 摇钱树
	[OPERATE_ACTIVITY_ID.LUCK_TURN_WHEEL] = RemindName.OpActLuckTurn,							-- 幸运转盘
	[OPERATE_ACTIVITY_ID.TIME_LIMIT_GOODS_2] = RemindName.OpActLimitGoods2,						-- 限时商品2
	[OPERATE_ACTIVITY_ID.JVBAO_PEN] = RemindName.OpActJvBaoPen,									-- 聚宝盆
	[OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE_2] = RemindName.OpActPrayTree2,						-- 摇钱树2
	[OPERATE_ACTIVITY_ID.SECRET_KEY_TREASURE] = RemindName.OpActSecretKey,						-- 秘钥宝藏
	[OPERATE_ACTIVITY_ID.DAILY_SPEND] = RemindName.OpActDailySpend,								-- 每日累计消费
	[OPERATE_ACTIVITY_ID.DAILY_CHARGE] = RemindName.OpActDailyAccuCharge,						-- 每日累计充值
	[OPERATE_ACTIVITY_ID.DAY_NUM_SPEND] = RemindName.OpActDayNumSpend,							--天天消费
	[OPERATE_ACTIVITY_ID.SUPER_GROUP_PURCHASE] = RemindName.OpActSuperGroupPurchase,			-- 超级团购活动
	[OPERATE_ACTIVITY_ID.DISCOUNT_LIMIT_BUY] = RemindName.OpActDiscountLimitBuy,				-- 超值限购
	[OPERATE_ACTIVITY_ID.DISCOUNT_TREASURE] = RemindName.OpActDiscountTreasure,					-- 宝物折扣
	[OPERATE_ACTIVITY_ID.CHARGE_GIVE_GIFT] = RemindName.OpActChargeGiveGift,					-- 充值送礼
	[OPERATE_ACTIVITY_ID.CONSUME_GIVE_GIFT] = RemindName.OpActConsumeGiveGift,					-- 消费送礼
	[OPERATE_ACTIVITY_ID.ADDUP_LOGIN_GET_GIFT] = RemindName.OpActAddupLoginGetGift,				-- 新春大礼
	[OPERATE_ACTIVITY_ID.TIME_LIMIT_ONCE_CHARGE] = RemindName.OpActTimeLimitOnceCharge, 		-- 限时单笔
	[OPERATE_ACTIVITY_ID.NEW_CHARGE_RANK] = RemindName.OpActNewChargeRank,						-- 新充值排行
	[OPERATE_ACTIVITY_ID.NEW_SPEND_RANK] = RemindName.OpActNewSpendRank,						-- 新消费排行
	[OPERATE_ACTIVITY_ID.CONVERT_AWARD] = RemindName.OpActConvertAward,
	[OPERATE_ACTIVITY_ID.CONTINUOUS_LOGIN] = RemindName.OpActContinuousLogin,					-- 连续登录
	[OPERATE_ACTIVITY_ID.TREASURE_DROP] = RemindName.OpActTreasureDrop,
	[OPERATE_ACTIVITY_ID.PINGDAN_QIANGGOU] = RemindName.OpActPindan,
	[OPERATE_ACTIVITY_ID.ADDUP_CHARGE_PAYBACK] = RemindName.OpActAddupChargePayback,			-- 累充返利
	[OPERATE_ACTIVITY_ID.ADDUP_SPEND_PAYBACK] = RemindName.OpActAddupSpendPayback,				-- 累消返利
	[OPERATE_ACTIVITY_ID.TEN_TIME_EXPLORE_GIVE] = RemindName.OpActTenTimeGive,					-- 寻宝10连抽送奖
	[OPERATE_ACTIVITY_ID.SECRET_SHOP] = RemindName.OpActSecretShop,								-- 神秘商店
	[OPERATE_ACTIVITY_ID.WORLD_CUP_BOSS] = RemindName.OpActWorldCupBoss,						-- 世界杯BOSS
	[OPERATE_ACTIVITY_ID.CONTINUOUS_ADDUP_CHARGE] = RemindName.OpActContiAddupCharge, 			-- 连续累充
	[OPERATE_ACTIVITY_ID.NEW_REPEAT_CHARGE] = RemindName.OpActNewRepeatCharge,					-- 新重复充值
	[OPERATE_ACTIVITY_ID.SPENDSCORE_EXCHANGE_PAYBACK] = RemindName.OpActSpendscoreExchPayback,	-- 消费积分兑换返利券
	[OPERATE_ACTIVITY_ID.CONTINUOUS_ADDUP_CHARGE_NEW] = RemindName.OpActNewContiAddupCharge,
	[OPERATE_ACTIVITY_ID.LOGIN_SEND_GIFT] = RemindName.OpActLoginSendGift,
	[OPERATE_ACTIVITY_ID.BOSS_TREASURE] = RemindName.OpActBossTreasure,
	[OPERATE_ACTIVITY_ID.ROTATE_PANEL_AWARD] = RemindName.OpActRotatePanelAward,
	[OPERATE_ACTIVITY_ID.LEGENDRY_REPUTATION] = RemindName.OpActLegendryReputation,
	[OPERATE_ACTIVITY_ID.HAPPY_SHOPPING_CART] = RemindName.OpActHappyShopCart,

}

-- 获取一个表的key值和value值对调的表
function GetOperActKVReverseMap(src_map)
	local reverse_map = {}
	for k, v in pairs(src_map) do
		reverse_map[v] = k
	end

	return reverse_map
end

-- 提醒名与活动ID对应表
OperateActivityData.RemindNameActIDMap = GetOperActKVReverseMap(OperateActivityData.ActIDRemindNameMap)

-- 提醒名与提醒函数名对应表
OperateActivityData.RemindNameRemindFucNameMap = {
	["SportsTypeActs"] = "IsStandardSportsNeedRemindByActId",									-- 竞技类活动
	[RemindName.OpActDailyCharge] = "IsDailyChargeNeedRemind",									-- 每日充值
	[RemindName.OpActLimitGoods] = "IsLimitGoodsNeedRemind",									-- 限时商品
	[RemindName.OpActAccuCharge] = "IsRechargeNeedRemind",										-- 累计充值
	[RemindName.OpActAccuSpend] = "IsConsumeNeedRemind",										-- 累计消费
	[RemindName.OpActRepeatCharge] = "IsRepeatChargeNeedRemind",								-- 重复充值
	[RemindName.OpActSpendScore] = "IsSpendScoreNeedRemind",									-- 消费积分
	[RemindName.OpActDayNumCharge] = "IsDayNumRechargeNeedRemind",								-- 天数充值
	[RemindName.OpActGroupPurchase] = "IsGroupPurchaseNeedRemind",								-- 团购活动
	[RemindName.OpActWishWell] = "IsWishWellNeedRemind",										-- 运营活动-许愿井
	[RemindName.OpActAddupLogin] = "IsAddupLoginNeedRemind",									-- 运营活动-累计登陆
	[RemindName.OpActYBWheel] = "IsYBWheelNeedRemind",											-- 运营活动-元宝转盘
	[RemindName.OpActPrayTree] = "IsPrayMoneyTreeRemind",										-- 摇钱树
	[RemindName.OpActLuckTurn] = "IsLuckTurnNeedRemind",										-- 运营活动-幸运转盘
	[RemindName.OpActLimitGoods2] = "IsLimitGoodsNeedRemindTwo",								-- 限时商品2
	[RemindName.OpActJvBaoPen] = "IsJvBaoPenNeedRemind",										-- 聚宝盆
	[RemindName.OpActPrayTree2] = "IsPrayMoneyTreeRemindTwo",									-- 摇钱树2
	[RemindName.OpActSecretKey] = "IsSecretKeyTreasureNeedRemind",								-- 秘钥宝藏
	[RemindName.OpActDailyAccuCharge] = "IsDailyRechargeNeedRemind",							-- 每日累计充值
	[RemindName.OpActDailySpend] = "IsDailyConsumeNeedRemind",									-- 每日累计消费
	[RemindName.OpActDayNumSpend] = "IsDayNumSpendNeedRemind",									-- 天天消费
	[RemindName.OpActSuperGroupPurchase] = "IsSuperGroupPurchaseNeedRemind",					-- 超级团购活动
	[RemindName.OpActDiscountLimitBuy] = "IsDiscountLimitNeedRemind",							-- 超值限购
	[RemindName.OpActDiscountTreasure] = "IsDiscountTreasureNeedRemind",						-- 宝物折扣
	[RemindName.OpActChargeGiveGift] = "IsChargeGiveGiftNeedRemind",							-- 充值送礼
	[RemindName.OpActConsumeGiveGift] = "IsConsumeGiveGiftNeedRemind",							-- 消费送礼
	[RemindName.OpActAddupLoginGetGift] = "IsAddupLoginGetGiftNeedRemind",						-- 新春大礼
	[RemindName.OpActTimeLimitOnceCharge] = "IsTimeLimitOnceChargeNeedRemind", 					-- 限时单笔
	[RemindName.OpActNewChargeRank] = "IsNewChargeRankNeedRemind",								-- 新充值排行
	[RemindName.OpActNewSpendRank] = "IsNewSpendRankNeedRemind",								-- 新消费排行
	[RemindName.OpActConvertAward] = "IsConvetAwardNeedRemind",
	[RemindName.OpActContinuousLogin] = "IsContinuousLoginGetGiftNeedRemind",	
	[RemindName.OpActTreasureDrop] = "IsTreasureDropNeedRemind",
	[RemindName.OpActPindan] = "IsPinDanQiangGouNeedRemind",
	[RemindName.OpActAddupChargePayback] = "IsAddupChargePaybackNeedRemind",
	[RemindName.OpActAddupSpendPayback] = "IsAddupSpendPaybackNeedRemind",
	[RemindName.OpActTenTimeGive] = "IsTenTimeExploreGiveNeedRemind",							-- 寻宝10连抽送奖	
	[RemindName.OpActSecretShop] = "IsSecretShopNeedRemind",									-- 神秘商店	
	[RemindName.OpActWorldCupBoss] = "IsWorldCupBossNeedRemind",								-- 世界杯BOSS	
	[RemindName.OpActContiAddupCharge] = "IsContinousAddupCharNeedRemind", 						-- 连续累充	
	[RemindName.OpActNewRepeatCharge] = "IsNewRepeatChargeNeedRemind",							-- 新重复充值
	[RemindName.OpActSpendscoreExchPayback] = "IsSpnedscoreExchangeNeedRemind",
	[RemindName.OpActNewContiAddupCharge] = "IsNewContinousAddupCharNeedRemind",
	[RemindName.OpActLoginSendGift] = "IsLoginSendGiftNeedRemind",
	[RemindName.OpActBossTreasure] = "IsBossTreasureNeedRemind",
	[RemindName.OpActRotatePanelAward] = "IsRotatePanelAwardNeedRemind",
	[RemindName.OpActLegendryReputation] = "IsLegendryReputationNeedRemind",
	[RemindName.OpActHappyShopCart] = "IsHappyShopCartNeedRemind",
}

-- 界面中点击后消除红点的活动记录表
OPERATE_CLICKED_NO_REMIND = {
	[OPERATE_ACTIVITY_ID.DAILY_RECHARGE] = 0,
}

function OperateActivityData:__init()
	if OperateActivityData.Instance then
		ErrorLog(" OperateActivityData] Attemp to create a singleton twice !")
	end
 	OperateActivityData.Instance = self
 	self.open_acts_list = {}				-- 开放活动列表
 	self.operate_acts_configs = {}			-- 运营活动配置

 	self.sports_type_data_t = {}			-- 达标竞技类活动数据

 	self.sports_rank_cfg_t = {}				-- 竞技排行活动配置数据
 	self.turn_place = 1
 	self.remind_list = {}

 	self.charge_give_gift_open_info = {standard_flag = 0, opened_day = 1, my_money = 0,}
 	self.consume_give_gift_open_info = {standard_flag = 0, opened_day = 1, my_money = 0,}
	self.alert_view = Alert.New()
	self.alert_view:SetShowCheckBox(true)
	self.alert_view2 = Alert.New()
	self.boss_treasure_refr_cost_first = 10
	self.boss_treasure_refr_cost_add = 10
end

function OperateActivityData:__delete()
 	OperateActivityData.Instance = nil
 	if self.alert_view ~= nil then
		self.alert_view:DeleteMe()
		self.alert_view = nil 
	end
	if self.alert_view2 ~= nil then
		self.alert_view2:DeleteMe()
		self.alert_view2 = nil 
	end
	if self.daily_online_timer then
		GlobalTimerQuest:CancelQuest(self.daily_online_timer)
		self.daily_online_timer = nil
	end
end

function OperateActivityData:GetAlertWnd()
	self.alert_view:SetOkFunc(nil)
	return self.alert_view
end

function OperateActivityData:GetAlertWndTwo()
	return self.alert_view2
end

function OperateActivityData:SetOpenActsList(protocol)
	self.open_acts_list = protocol.open_acts_list
	if not next(self.open_acts_list) then return end
	-- 请求获取开放活动的配置
	for k, v in pairs(self.open_acts_list) do
		OperateActivityCtrl.Instance:ReqOperateActCfg(v.cmd_id, v.act_id)
	end
end

function OperateActivityData:GetAllOpenActsList()
	return self.open_acts_list
end

-- 是否在通用面板显示的活动
function OperateActivityData.IsCommonPanelShowAct(act_id)
	if act_id == OPERATE_ACTIVITY_ID.FIRST_CHARGE_PAYBACK or act_id == OPERATE_ACTIVITY_ID.LOGIN_SEND_GIFT or 
		act_id == OPERATE_ACTIVITY_ID.BOSS_TREASURE or act_id == OPERATE_ACTIVITY_ID.DEFEND_CITY or 
		act_id == OPERATE_ACTIVITY_ID.ROTATE_PANEL_AWARD or act_id == OPERATE_ACTIVITY_ID.LEGENDRY_REPUTATION then  
		--[[
		or act_id == OPERATE_ACTIVITY_ID.CHARGE_GIVE_GIFT or 
		act_id == OPERATE_ACTIVITY_ID.CONSUME_GIVE_GIFT or act_id == OPERATE_ACTIVITY_ID.ADDUP_LOGIN_GET_GIFT or
		act_id == OPERATE_ACTIVITY_ID.YB_SEND_GIFT or act_id == OPERATE_ACTIVITY_ID.PROSPERY_RED_EVEV or
		act_id == OPERATE_ACTIVITY_ID.ADDUP_CHARGE_PAYBACK
		--]]
		return false
	end
	return true
end

-- 是否是新春活动
function OperateActivityData.IsSpringFestival(act_id)
	if act_id == OPERATE_ACTIVITY_ID.ADDUP_LOGIN_GET_GIFT or act_id == OPERATE_ACTIVITY_ID.YB_SEND_GIFT or 
		act_id == OPERATE_ACTIVITY_ID.PROSPERY_RED_EVEV or act_id == OPERATE_ACTIVITY_ID.ADDUP_CHARGE_PAYBACK then
		return true
	elseif act_id == OPERATE_ACTIVITY_ID.CHARGE_GIVE_GIFT or act_id == OPERATE_ACTIVITY_ID.CONSUME_GIVE_GIFT then
		return OperateActivityData.Instance:IsShowChargeConsumeGiveAct(act_id)
	end
	return false
end

-- 是否是国庆活动
function OperateActivityData.IsNationalDayAct(act_id)
	if act_id == OPERATE_ACTIVITY_ID.LOGIN_SEND_GIFT or 
		act_id == OPERATE_ACTIVITY_ID.BOSS_TREASURE or act_id == OPERATE_ACTIVITY_ID.DEFEND_CITY or 
		act_id == OPERATE_ACTIVITY_ID.ROTATE_PANEL_AWARD or act_id == OPERATE_ACTIVITY_ID.LEGENDRY_REPUTATION then  
		return true
	end
	return false
end

function OperateActivityData:IsShowChargeConsumeGiveAct(act_id)
	if act_id == OPERATE_ACTIVITY_ID.CHARGE_GIVE_GIFT then
		return self.charge_give_gift_open_info.opened_day < 2 or self.charge_give_gift_open_info.standard_flag == 1
	elseif act_id == OPERATE_ACTIVITY_ID.CONSUME_GIVE_GIFT then
		return self.consume_give_gift_open_info.opened_day < 2 or self.consume_give_gift_open_info.standard_flag == 1
	end
end

-- 通用面板展示的活动
function OperateActivityData:GetCommonShowActList()
	local show_list = {}
	for k, v in ipairs(self.open_acts_list) do
		if OperateActivityData.IsCommonPanelShowAct(v.act_id) then
			if v.act_id ~= OPERATE_ACTIVITY_ID.CHARGE_GIVE_GIFT and v.act_id ~= OPERATE_ACTIVITY_ID.CONSUME_GIVE_GIFT then
				table.insert(show_list, v)
			else
				if self:IsShowChargeConsumeGiveAct(v.act_id) then
					table.insert(show_list, v)
				end
			end
		end
	end
	return show_list
end

-- 新春活动面板展示的活动
function OperateActivityData:GetSpringFestivalActList()
	local show_list = {}
	for k, v in ipairs(self.open_acts_list) do
		if OperateActivityData.IsSpringFestival(v.act_id) then
			if v.act_id ~= OPERATE_ACTIVITY_ID.CHARGE_GIVE_GIFT and v.act_id ~= OPERATE_ACTIVITY_ID.CONSUME_GIVE_GIFT then
				table.insert(show_list, v)
			else
				if self:IsShowChargeConsumeGiveAct(v.act_id) then
					table.insert(show_list, v)
				end
			end
		end
	end
	return show_list
end

-- 国庆活动面板展示的活动
function OperateActivityData:GetNationalDayActList()
	local show_list = {}
	for k, v in ipairs(self.open_acts_list) do
		if OperateActivityData.IsNationalDayAct(v.act_id) then
			table.insert(show_list, v)
		end
	end
	return show_list
end

function OperateActivityData:CheckActIsOpen(act_id)
	for k, v in pairs(self.open_acts_list) do
		if v.act_id == act_id then
			return true
		end
	end

	return false
end

-- 获取某一开放活动的cmd_id
function OperateActivityData:GetOneOpenActCmdID(act_id)
	for k, v in pairs(self.open_acts_list) do
		if v.act_id == act_id then
			return v.cmd_id
		end
	end
end

-- 把服务端返回的字符串转换成Table
function OperateActivityData.StrToTable(str)
	local str2 = "return" .. str
	local func = loadstring(str2)
	if type(func) ~= "function" then
		print("错误，请确认是函数！！！")
		return
	end

	local cfg = func()
	if type(cfg) == "table" then
		return cfg
	end

end

function OperateActivityData:SetOperateActCfg(protocol)
	local cfg = OperateActivityData.StrToTable(protocol.act_config)
	if cfg then
		self.operate_acts_configs[protocol.act_id] = cfg
		local func = nil
		if OperateActivityData.GetOperateActBigType(protocol.act_id) == OperateActivityData.OperateActBigType.SPORTS_RANK then
			func = OperateActivityData.ActIDInitCfgFuncMap["SportsRank"]
			if nil ~= self[func] then
				self[func](self, protocol.act_id)
			end
		else
			func = OperateActivityData.ActIDInitCfgFuncMap[protocol.act_id]
			if nil ~= self[func] then
				self[func](self)
			end
		end

		--请求获取活动数据
		OperateActivityCtrl.Instance:ReqOperateActData(protocol.cmd_id, protocol.act_id)
	end

	if cfg then
		for k, v in pairs(self.open_acts_list) do
			if cfg.act_id == v.act_id then
				v.act_name = cfg.act_name
				v.act_desc = cfg.act_desc
			end
		end
	end

	-- 按活动ID排序，ID小的排在前面
	local function sort_list()
		return function(a, b)
			local order_a = 100
			local order_b = 100
			if a.act_id == 53 then
				order_a = order_a + 10000
			elseif b.act_id == 53 then
				order_b = order_b + 10000
			else
				if a.act_id < b.act_id then
					order_a = order_a + 100
				elseif a.act_id > b.act_id then
					order_b = order_b + 100
				end
			end

			return order_a > order_b
		end
	end
	table.sort(self.open_acts_list, sort_list())

	if self.add_act_flag then
		GlobalEventSystem:Fire(OperateActivityEventType.ADD_OPEN_ACT)
		self.add_act_flag = false
	end
end

function OperateActivityData:GetActCfgByActID(act_id)
	return self.operate_acts_configs[act_id]
end

-- 根据活动ID抛出对应事件
function OperateActivityData:FireEventByActId(act_id)
	if OperateActivityData.GetOperateActBigType(act_id) == OperateActivityData.OperateActBigType.SPORTS_TYPE then
		if ViewManager.Instance:IsOpen(ViewName.OperateActivity) and OperateActivityCtrl.Instance.view:GetShowIndex() == act_id then
			GlobalEventSystem:Fire(OperateActivityData.ActIDEventIDMap[0])
		end
	else
		if OperateActivityData.ActIDEventIDMap[act_id] then
			GlobalEventSystem:Fire(OperateActivityData.ActIDEventIDMap[act_id])
		end
	end

end


--====================嗨购一车begin=====================
function OperateActivityData:InitHappyShopCartData()
	self.happy_shop_cart_cfg = {}
	self.happy_shop_cart_data = {settled_cnt = 0, shop_cart_list = {},}
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.HAPPY_SHOPPING_CART] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.HAPPY_SHOPPING_CART].config
	if cfg then
		self.happy_shop_cart_cfg = cfg
		self.happy_shop_cart_cfg.discount_num_info = {}
		for k, v in ipairs(self.happy_shop_cart_cfg.discountList) do
			self.happy_shop_cart_cfg.discount_num_info[v.num] = v.discount
		end
	end
end

function OperateActivityData:SetHappyShopCartData(data)
	self.happy_shop_cart_data.settled_cnt = data.settled_cnt
	self.happy_shop_cart_data.shop_cart_list = data.shop_cart_list
end

function OperateActivityData:UpdateHappyShopCart(data)
	if data.oper_type == 1 then
		table.insert(self.happy_shop_cart_data.shop_cart_list, data.idx)
	elseif data.oper_type == 2 then
		for k, v in ipairs(self.happy_shop_cart_data.shop_cart_list) do
			if v == data.idx then
				table.remove(self.happy_shop_cart_data.shop_cart_list, k)
				break
			end
		end
	end
end

function OperateActivityData:IsHappyShopCartNeedRemind()
	if not self.happy_shop_cart_cfg then return false end
	local own_money = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
	for k, v in ipairs(self.happy_shop_cart_cfg.ItemList) do
		if own_money >= v.costNum then
			return true
		end
	end
	return false
end

function OperateActivityData:GetHappyShopCartCfg()
	return self.happy_shop_cart_cfg
end

function OperateActivityData:GetHappyShopCartShopItemList()
	return self.happy_shop_cart_cfg and self.happy_shop_cart_cfg.ItemList
end

function OperateActivityData:GetHappyShopCartCostMoneyInfo()
	local total_cost = 0
	local discount_cost = 0
	local discount_info = 0
	if self.happy_shop_cart_data then
		local item_num = #self.happy_shop_cart_data.shop_cart_list
		local shop_item_list = self.happy_shop_cart_cfg.ItemList
		discount_info = self.happy_shop_cart_cfg.discount_num_info[item_num] or 0
		for _, v in pairs(self.happy_shop_cart_data.shop_cart_list) do
			if shop_item_list[v] then
				total_cost = total_cost + shop_item_list[v].costNum
			end
		end
		if discount_info > 0 then
			discount_cost = math.ceil(total_cost * discount_info)
		end
	end

	return total_cost, discount_cost, discount_info*10
end

function OperateActivityData:GetHappyShopCartRestCnt()
	if self.happy_shop_cart_cfg then
		return math.max(0, self.happy_shop_cart_cfg.limitBuyNum - self.happy_shop_cart_data.settled_cnt)
	end
	return 0
end

function OperateActivityData:GetHappyShopCartHasCnt()
	if self.happy_shop_cart_data then
		return #self.happy_shop_cart_data.shop_cart_list
	end
	return 0
end

function OperateActivityData:GetHappyShopCanInputCnt()
	if self.happy_shop_cart_data then
		return self.happy_shop_cart_cfg.limitItemNum - #self.happy_shop_cart_data.shop_cart_list
	end
	return 0
end

function OperateActivityData:GetHappyShopCartListData()
	return self.happy_shop_cart_data and self.happy_shop_cart_data.shop_cart_list or {}
end

function OperateActivityData:GetHappyShopOneItemCfgByIdx(idx)
	return self.happy_shop_cart_cfg and self.happy_shop_cart_cfg.ItemList[idx]
end

function OperateActivityData:ClearHappyShopCartData()
	
end
--====================嗨购一车end=====================

--------------------------------名动传奇begin---------------------------------------
function OperateActivityData:InitLegendryReputationCfgInfo()
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.LEGENDRY_REPUTATION] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.LEGENDRY_REPUTATION].config
	self.legendry_reputation_my_money = 0
	self.legendry_reputation_my_rank = 0
	self.allserver_rank_max_cnt = 5
	if cfg then
		local gold_cfg = cfg.Gold
		self.legendry_reputation_personal_data = cfg.Rewards
		self.legendry_reputation_allserver_rank = cfg.Awards
		self.allserver_rank_max_cnt = #self.legendry_reputation_allserver_rank
		for k, v in ipairs(self.legendry_reputation_personal_data) do
			v.state = 0
			v.idx = k
			v.gold_cond = gold_cfg[k] and gold_cfg[k] or gold_cfg[#gold_cfg]
			v.personal = true
		end
	end
end

function OperateActivityData:GetLegendryReputationNeddMinCond()
	local need_min_value = 5000
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.LEGENDRY_REPUTATION] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.LEGENDRY_REPUTATION].config
	if cfg then
		need_min_value = cfg.needMinValue
	end	
	return string.format(Language.OperateActivity.LegendryReputation[1], need_min_value)
end

function OperateActivityData:GetLegendryReputationAllSerInfo()
	return self.legendry_reputation_allserver_rank
end

function OperateActivityData:GetLegendryReputationPersonalInfo()
	return self.legendry_reputation_personal_data
end

function OperateActivityData:GetLegendryReputationMyMoney()
	return string.format(Language.OperateActivity.LegendryReputation[2], self.legendry_reputation_my_money)
end

function OperateActivityData:GetLegendryReputationMyMoneyCnt()
	return self.legendry_reputation_my_money
end

function OperateActivityData:GetLegendryReputationMyRank()
	if self.legendry_reputation_my_rank > 0 and self.legendry_reputation_my_rank <= self.allserver_rank_max_cnt then
		return string.format(Language.OperateActivity.LegendryReputation[3], self.legendry_reputation_my_rank)
	end
	return Language.OperateActivity.NotInRank
end

function OperateActivityData:SetLegendryReputationData(data)
	if not self.legendry_reputation_allserver_rank then return end
	self.legendry_reputation_my_money = data.my_money
	self.legendry_reputation_my_rank = data.my_rank
	local tmp
	for k, v in ipairs(data.state_t) do
		tmp = self.legendry_reputation_personal_data[k]
		if tmp then
			tmp.state = v
		end
	end

	for k, v in ipairs(data.allserver_rank) do
		tmp = self.legendry_reputation_allserver_rank[k]
		if tmp then
			tmp.player_name = v
		end
	end
	GlobalEventSystem:Fire(OperateActivityEventType.LEGENDRY_REPUTATION_ALLDATA)
end

function OperateActivityData:UpdateLegendryReputationData(data)
	local tmp = self.legendry_reputation_personal_data[data.idx]
	if tmp then
		tmp.state = data.state
	end
	GlobalEventSystem:Fire(OperateActivityEventType.LEGENDRY_REPUTATION_PERSONAL_DATA)
end

function OperateActivityData:IsLegendryReputationNeedRemind()
	if not self.legendry_reputation_personal_data then return false end
	for i,v in ipairs(self.legendry_reputation_personal_data) do
		if v.state == 1 then
			return true
		end
	end
	return false
end

function OperateActivityData:ClearLegendryReputationData()
	
end
--------------------------------名动传奇end---------------------------------------

--------------------------------万宝轮盘begin---------------------------------------
function OperateActivityData:InitRotatePanelAwardCfgInfo()
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.ROTATE_PANEL_AWARD] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.ROTATE_PANEL_AWARD].config
	self.own_can_rotate_cnt = 0
	self.rotate_panel_target_idx = 0
	if cfg then
		self.rotate_panel_award_cfg_info = {}
		self.rotate_panel_award_cfg_info.first_refe_cost = cfg.firstRefreshCost
		self.rotate_panel_award_cfg_info.refresh_cost_add = cfg.refreshCostAdd
		self.rotate_panel_award_cfg_info.per_cnt_need_gold = cfg.everyCountNeedGold
		self.rotate_panel_award_cfg_info.icons_bag = cfg.ItemList
		for k, v in ipairs(self.rotate_panel_award_cfg_info.icons_bag) do
			v.item_id = v.id
			v.num = v.count
			v.is_bind = v.bind
		end
	end
end

function OperateActivityData:GetRotatePanelAwardCfgInfo()
	local data = {}
	if self.rotate_panel_award_cfg_info then
		for k, v in ipairs(self.rotate_panel_award_data.item_list) do
			data[k] = self.rotate_panel_award_cfg_info.icons_bag[v.idx]
			data[k].state = v.state
		end
	end
	return data
end

function OperateActivityData:GetRotatePanelOneAwardCfg(idx)
	if self.rotate_panel_award_cfg_info then
		return self.rotate_panel_award_cfg_info.icons_bag[idx]
	end
end

function OperateActivityData:SetRotatePanelAwardData(data)
	if not self.rotate_panel_award_cfg_info then return end
	self.rotate_panel_award_data = data
	self.own_can_rotate_cnt = math.floor(data.my_money / self.rotate_panel_award_cfg_info.per_cnt_need_gold) - data.use_cnt
	GlobalEventSystem:Fire(OperateActivityEventType.ROTATE_PANEL_AWARD_TOTAL_DATA)
end

function OperateActivityData:UpdateRotatePanelAwardData(data)
	if data.oper_type == 1 then
		self:SetRotatePanelAwardTargetIdx(data.idx)
		self.own_can_rotate_cnt = math.floor(self.rotate_panel_award_data.my_money / self.rotate_panel_award_cfg_info.per_cnt_need_gold) - data.use_cnt
		GlobalEventSystem:Fire(OperateActivityEventType.ROTATE_PANEL_AWARD_BEGIN_ROTATE)
	elseif data.oper_type == 2 then
		self:SetRotatePanelAwardTargetIdx(data.idx)
		if self.rotate_panel_target_idx > 0 then
			self.rotate_panel_award_data.item_list[self.rotate_panel_target_idx].state = data.state
			GlobalEventSystem:Fire(OperateActivityEventType.ROTATE_PANEL_RESULT_BACK, data.pop_flag, self.rotate_panel_target_idx, data.state)
		end
	end
end

function OperateActivityData:GetRotatePanelTipTxt()
	if self.own_can_rotate_cnt > 0 then
		return string.format(Language.OperateActivity.RotatePanelAward[1], self.own_can_rotate_cnt)
	else
		local less_cnt = self.rotate_panel_award_data.my_money % self.rotate_panel_award_cfg_info.per_cnt_need_gold
		less_cnt = less_cnt > 0 and less_cnt or self.rotate_panel_award_cfg_info.per_cnt_need_gold
		return string.format(Language.OperateActivity.RotatePanelAward[2], less_cnt)
	end
end

function OperateActivityData:SetRotatePanelAwardTargetIdx(item_idx)
	if self.rotate_panel_award_data then
		self.rotate_panel_target_idx = self.rotate_panel_award_data.itemidx_to_showidx[item_idx]
	end
end

function OperateActivityData:GetRotatePanelTurnTargetIdx()
	return self.rotate_panel_target_idx
end

function OperateActivityData:GetRotatePanelRefreNeedMoney()
	if self.rotate_panel_award_data then
		return self.rotate_panel_award_cfg_info.first_refe_cost+self.rotate_panel_award_data.refr_cnt*self.rotate_panel_award_cfg_info.refresh_cost_add
	end
end

function OperateActivityData:IsRotatePanelAwardNeedRemind()
	if self.rotate_panel_award_cfg_info then
		return self.own_can_rotate_cnt > 0
	end
	return false
end

function OperateActivityData:ClearRotatePanelAwardData()
	
end

--------------------------------万宝轮盘end---------------------------------------


-- =============守卫主城 begin------
function OperateActivityData:GetDefendCityData()
	local boss_atk_income_data = {}
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.DEFEND_CITY] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.DEFEND_CITY].config
	if not cfg then return end
	local boss_list_cfg = cfg.BossList
	local monster_cfg = nil
	for k, v in ipairs(boss_list_cfg) do
		monster_cfg = BossData.GetMosterCfg(v.boss[1].monsterId)
		local temp_cfg = {
							desc = v.desc,
							mob_time_list = v.mob_time_list,
							name = monster_cfg and monster_cfg.name or "",
							icon = (monster_cfg and monster_cfg.icon and monster_cfg.icon > 0) and monster_cfg.icon or 1,
							awards = {},
						}
		temp_cfg.awards = ItemData.AwardsToItems(v.awards)
		table.insert(boss_atk_income_data, temp_cfg)
	end

	return boss_atk_income_data
end

function OperateActivityData:GetDefendCityRefreshTime(time_list)
	if not time_list then return "" end
	local time, time_str = nil, ""
	local now_time = ActivityData.GetNowShortTime()
	for k, v in ipairs(time_list) do
		if now_time < v then
			time = v
			break
		end
	end

	if not time then
		local _, remain_time = self:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.DEFEND_CITY)
		local is_last_day = remain_time <= 24 * 3600
		if not is_last_day then
			time_str = Language.OperateActivity.BossAtkIncomeRefrTime[1] .. 
				string.format(Language.OperateActivity.BossAtkIncomeRefrTime[3], TimeUtil.FormatSecond2Str(time_list[1], 2))
		else
			time_str = Language.OperateActivity.BossAtkIncomeRefrTime[1] .. Language.OperateActivity.BossAtkIncomeRefrTime[4]
		end
	else
		time_str = Language.OperateActivity.BossAtkIncomeRefrTime[1] .. 
			string.format(Language.OperateActivity.BossAtkIncomeRefrTime[2], TimeUtil.FormatSecond2Str(time, 2))
	end

	return time_str

end

function OperateActivityData:ClearDefendCity()

end
--======================守卫主城end=======================

--====================BOSS宝藏begin======================
function OperateActivityData:GetBossTreasureCfg()
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.BOSS_TREASURE] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.BOSS_TREASURE].config
	if not cfg then return end
	return cfg
end

function OperateActivityData:SetBossTreasureData(data)
	self.boss_treasure_refr_cd = data.refr_cd + Status.NowTime
	self.boss_treasure_hand_refr_cnt = data.hand_refr_cnt
	self.boss_suipian_id = 1981
	local cfg = self:GetBossTreasureCfg()
	if not cfg then return end
	self.boss_treasure_item_show_num = cfg.drawNum
	self.boss_treasure_items = {}
	local idx = 0
	self.boss_treasure_refr_cost_first = cfg.firstRefreshCost
	self.boss_treasure_refr_cost_add = cfg.refreshCostAdd
	local item_list = cfg.ItemList
	for k, v in pairs(data.items_info) do
		local tmp = {
						cfg_data = item_list[k],
						index = k,
						buy_num = v,
					}
		if tmp.cfg_data.consume[1].id > 0 then
			self.boss_suipian_id = tmp.cfg_data.consume[1].id
		end
		self.boss_treasure_items[idx] = tmp
		idx = idx + 1
	end
end

function OperateActivityData:GetBossTreasureItemsData()
	return self.boss_treasure_items
end

function OperateActivityData:GetBossTreasureRefrCD()
	return self.boss_treasure_refr_cd or Status.NowTime
end

function OperateActivityData:GetBossTreasureRefrCost()
	local cost = self.boss_treasure_refr_cost_first + self.boss_treasure_hand_refr_cnt * self.boss_treasure_refr_cost_add
	return cost
end

function OperateActivityData:GetBossTreasureShowItemNum()
	return self.boss_treasure_item_show_num or 4
end

function OperateActivityData:IsBossTreasureNeedRemind()
	if not self.boss_treasure_items then return false end
	local own_cnt, obj_attr,item_id = 0, nil, nil
	for k, v in pairs(self.boss_treasure_items) do
		if v.cfg_data.discpriceType >= 0 then 
			local obj_attr = ShopData.GetMoneyObjAttrIndex(v.cfg_data.discpriceType)
			own_cnt = RoleData.Instance:GetAttr(obj_attr)
			if own_cnt >= v.cfg_data.consume[1].count then
				return true
			end
		else
			if ItemData.Instance:GetItemNumInBagById(v.cfg_data.consume[1].id) >= v.cfg_data.consume[1].count then
				return true
			end
		end
	end
	return false
end

function OperateActivityData:GetBossTreasureBosssuipianId()
	return self.boss_suipian_id or 1981
end

function OperateActivityData:IsBosssuipianItem(id)
	return id == self.boss_suipian_id
end

function OperateActivityData:ClearBossTreasureData()

end

--=========================BOSS宝藏end============================


--====================登陆送礼begin=====================
function OperateActivityData:InitLoginSendGiftData()
	self.login_send_gift_remind_t = {}
	self.login_send_gift_data = {total_day = 10, cur_day = 1, info_list = {}}
	self.online_time = 0
	self.fix_server_time = 0
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.LOGIN_SEND_GIFT] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.LOGIN_SEND_GIFT].config
	if cfg then
		self.login_send_gift_data.total_day = #cfg.Rewards
		self.login_send_gift_data.cur_day = 1
		local show_len = #cfg.showReward
		for i,v1 in ipairs(cfg.Rewards) do
			self.login_send_gift_data.info_list[i] = {awar_info = {}, day = i, state = 0, online_time = -2, award_stage = #v1, check_num = #v1}
			self.login_send_gift_data.info_list[i].show_id = cfg.showReward[i] and cfg.showReward[i].id or cfg.showReward[show_len].id
			for k, v in ipairs(v1) do
				local info = {online = v.online, cost_money = v.goldGetConsumes[1].count}
				info.awards = ItemData.AwardsToItems(v.awards)
				info.idx = k
				info.day = i
				info.state = DAILY_CHARGE_FETCH_ST.CNNOT
				info.client_rank = 1
				info.rest_time = 0
				table.insert(self.login_send_gift_data.info_list[i].awar_info, info)
			end
		end		
	end
end

function OperateActivityData:SetLoginSendGiftData(data)
	self.fix_server_time = TimeCtrl.Instance:GetServerTime()
	self.login_send_gift_data.cur_day = data.cur_day
	for i,v1 in ipairs(data.award_info) do
		self.login_send_gift_data.info_list[i].online_time = v1.online_time
		self.login_send_gift_data.info_list[i].check_num = self.login_send_gift_data.info_list[i].award_stage
		if v1.online_time >= 0 then
			self.online_time = v1.online_time
		end
		local fetched_cnt = 0
		for k, v in ipairs(v1.state_t) do
			local info = self.login_send_gift_data.info_list[i].awar_info[k]
			if info then
				info.state = v
				if v == DAILY_CHARGE_FETCH_ST.FETCHED then
					fetched_cnt = fetched_cnt + 1
					self.login_send_gift_data.info_list[i].check_num = self.login_send_gift_data.info_list[i].check_num - 1
				elseif v == DAILY_CHARGE_FETCH_ST.CAN then
					self.login_send_gift_data.info_list[i].check_num = self.login_send_gift_data.info_list[i].check_num - 1
				end
				if v == DAILY_CHARGE_FETCH_ST.CNNOT then
					info.client_rank = 1
				elseif v == DAILY_CHARGE_FETCH_ST.FETCHED then
					info.client_rank = 0
				else
					info.client_rank = 2
				end
			end
		end
		if fetched_cnt >= self.login_send_gift_data.info_list[i].award_stage then
			self.login_send_gift_data.info_list[i].state = DAILY_CHARGE_FETCH_ST.FETCHED
		end
	end	
	if self.daily_online_timer == nil and self.login_send_gift_data.info_list[data.cur_day] and self.login_send_gift_data.info_list[data.cur_day].check_num > 0 then
		self.daily_online_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateLoginSendOnlineAwarInfo, self), 1)
	end		
end

function OperateActivityData:UpdateLoginSendGift(data)
	local mydata = self.login_send_gift_data.info_list[data.day]
	if mydata and mydata.awar_info[data.awar_idx] then
		mydata.awar_info[data.awar_idx].state = data.state
		local fetched_cnt = 0
		for k, v in ipairs(mydata.awar_info) do
			if v.state == DAILY_CHARGE_FETCH_ST.FETCHED then
				fetched_cnt = fetched_cnt + 1
				-- mydata.check_num = mydata.check_num - 1
			elseif v.state == DAILY_CHARGE_FETCH_ST.CAN then
				-- mydata.check_num = mydata.check_num - 1
			end
		end
		if fetched_cnt >= mydata.award_stage then
			mydata.state = DAILY_CHARGE_FETCH_ST.FETCHED
		end
		if data.state == DAILY_CHARGE_FETCH_ST.CNNOT then
			mydata.awar_info[data.awar_idx].client_rank = 1
		elseif data.state == DAILY_CHARGE_FETCH_ST.FETCHED then
			mydata.awar_info[data.awar_idx].client_rank = 0
		else
			mydata.awar_info[data.awar_idx].client_rank = 2
		end
	end	
end

function OperateActivityData:IsLoginSendGiftNeedRemind()
	if not self.login_send_gift_data then return false end
	for i,v in ipairs(self.login_send_gift_data.info_list) do
		for k, v2 in ipairs(v.awar_info) do
			if (v.online_time > 0 and v2.state == DAILY_CHARGE_FETCH_ST.CAN) or (v.online_time == -1 and v2.state ~= DAILY_CHARGE_FETCH_ST.FETCHED) then
				return true
			end
		end
	end
	return false
end

function OperateActivityData:GetLoginSendGiftOneDayIsRemind(day)
	local mydata = self.login_send_gift_data.info_list[day]
	if mydata and mydata.awar_info then
		local online_time = mydata.online_time
		for k, v in ipairs(mydata.awar_info) do
			if (online_time > 0 and v.state == DAILY_CHARGE_FETCH_ST.CAN) or (online_time == -1 and v.state ~= DAILY_CHARGE_FETCH_ST.FETCHED) then
				return true
			end
		end
	end
	return false
end

OperateActivityData.LoginSendGiftPerPageCnt = 5
function OperateActivityData:GetLoginSendGiftMinMaxRemindPage()
	if not self.login_send_gift_data then return 1,1 end
	local min,max=0,0
	local cur_day = self.login_send_gift_data.cur_day
	local data_list = self.login_send_gift_data.info_list
	for i = 1, cur_day, 1 do
		local v = data_list[i]
		for k, v2 in ipairs(v.awar_info) do
			if (i == cur_day and v2.state == DAILY_CHARGE_FETCH_ST.CAN) or (i < cur_day and v2.state ~= DAILY_CHARGE_FETCH_ST.FETCHED) then
				if min == 0 then
					min = i
				end
				max = i
				break
			end
		end
	end
	if min > 0 and max > 0 then
		return math.ceil(min/OperateActivityData.LoginSendGiftPerPageCnt), math.ceil(max/OperateActivityData.LoginSendGiftPerPageCnt)
	else
		return 0, 0
	end
end

function OperateActivityData:GetLoginSendGiftData()
	return self.login_send_gift_data
end

function OperateActivityData:GetLoginSendGiftTotalDay()
	return self.login_send_gift_data.total_day or 10
end

function OperateActivityData:GetLoginSendGiftDayListData()
	local idx = 0
	local data_t = {}
	for k, v in ipairs(self.login_send_gift_data.info_list) do
		data_t[idx] = v
		idx = idx + 1
	end
	return data_t
end

function OperateActivityData:GetLoginSendGiftAwards(index)
	return self.login_send_gift_data.info_list[index] and self.login_send_gift_data.info_list[index].awar_info or {}
end

function OperateActivityData:GetLoginSendGiftDataByDay(day)
	return self.login_send_gift_data and self.login_send_gift_data.info_list[day]
end

function OperateActivityData:GetLoginSendGiftCurDay()
	return self.login_send_gift_data and self.login_send_gift_data.cur_day or 1
end

function OperateActivityData:ClearLoginSendGiftData()
	if self.daily_online_timer then
		GlobalTimerQuest:CancelQuest(self.daily_online_timer)
		self.daily_online_timer = nil
	end
end

function OperateActivityData:UpdateLoginSendOnlineAwarInfo()
	if self.online_time < 0 then return end
	local online_time = self:GetOnlineTime()
	if self:IsLoginSendNeedReqAwarInfo(online_time) then
		local act_id = OPERATE_ACTIVITY_ID.LOGIN_SEND_GIFT
		local cmd_id = self:GetOneOpenActCmdID(act_id)
		if cmd_id then
			OperateActivityCtrl.Instance:ReqOperateActData(cmd_id, act_id)
		end
	end

end

--客户端设置在线奖励剩余时间
function OperateActivityData:ClientSetOnlinAwarRestTime(online_time)
	if not self.login_send_gift_data or not self.login_send_gift_data.cur_day then return 0 end
	for k, v in ipairs(self.login_send_gift_data.info_list[self.login_send_gift_data.cur_day].awar_info) do
		v.rest_time = v.online - online_time > 0 and (v.online - online_time) or 0
	end
end

--获取在线时间（秒）
function OperateActivityData:GetOnlineTime()
	local server_time = TimeCtrl.Instance:GetServerTime()
	local online_time = self.online_time + server_time - self.fix_server_time
	return online_time
end

-- --是否有可领取的在线奖励
-- function OperateActivityData:IsHaveAwarNeedFetch(online_time)
-- 	for i, v in ipairs(self.online_info) do
-- 		if v.state ~= ONLINE_AWARD_FETCH_STATE.FETCHED and 
-- 			online_time >= v.time_cond then
-- 			return true
-- 		end
-- 	end

-- 	return false
-- end

--是否需要请求每日在线信息
function OperateActivityData:IsLoginSendNeedReqAwarInfo(online_time)
	if not self.login_send_gift_data then return false end
	local mydata = self.login_send_gift_data.info_list[self.login_send_gift_data.cur_day]
	if mydata then 
	    local need_check_num = mydata.award_stage
	    for k, v in ipairs(mydata.awar_info) do
	    	if v.state == DAILY_CHARGE_FETCH_ST.CAN or v.state == DAILY_CHARGE_FETCH_ST.FETCHED then
	    		need_check_num = need_check_num - 1
	    	end
	    end
	    mydata.check_num = need_check_num
		if self.daily_online_timer and need_check_num <= 0 then
			GlobalTimerQuest:CancelQuest(self.daily_online_timer)
			self.daily_online_timer = nil
		end
	end
	for i, v in ipairs(self.login_send_gift_data.info_list[self.login_send_gift_data.cur_day].awar_info) do
		if online_time >= v.online 
			and v.state ~= ONLINE_AWARD_FETCH_STATE.FETCHED and 
			not v.has_checked then
			v.has_checked = true
			return true
		end
	end
	return false
end

--====================登陆送礼end=====================

function OperateActivityData.GetOperateActBigType(act_id)
	-- 达标竞技类活动
	if act_id == OPERATE_ACTIVITY_ID.EXP_SPORTS or act_id == OPERATE_ACTIVITY_ID.BOSS_SPORTS or
		   act_id == OPERATE_ACTIVITY_ID.BLOOD_SPORTS or act_id == OPERATE_ACTIVITY_ID.SHIELD_SPORTS or
		   act_id == OPERATE_ACTIVITY_ID.DIAMOND_SPORTS or act_id == OPERATE_ACTIVITY_ID.SEALBEAD_SPORTS or
		   act_id == OPERATE_ACTIVITY_ID.INJECT_SPORTS or act_id == OPERATE_ACTIVITY_ID.SWING_SPORTS or

		   act_id == OPERATE_ACTIVITY_ID.DAILY_EXP_SPORTS or act_id == OPERATE_ACTIVITY_ID.DAILY_BOSS_SPORTS or
		   act_id == OPERATE_ACTIVITY_ID.DAILY_BLOOD_SPORTS or act_id == OPERATE_ACTIVITY_ID.DAILY_SHIELD_SPORTS or
		   act_id == OPERATE_ACTIVITY_ID.DAILY_DIAMOND_SPORTS or act_id == OPERATE_ACTIVITY_ID.DAILY_SEALBEAD_SPORTS or
		   act_id == OPERATE_ACTIVITY_ID.DAILY_INJECT_SPORTS or act_id == OPERATE_ACTIVITY_ID.DAILY_SWING_SPORTS or 
		   act_id == OPERATE_ACTIVITY_ID.SOUL_STONE_SPORTS or act_id == OPERATE_ACTIVITY_ID.DAILY_SOUL_STONE_SPORTS then

		   return OperateActivityData.OperateActBigType.SPORTS_TYPE
	-- 达标竞技排行榜
	elseif act_id == OPERATE_ACTIVITY_ID.EXP_SPORTS_RANK or act_id == OPERATE_ACTIVITY_ID.BOSS_SPORTS_RANK or
		   act_id == OPERATE_ACTIVITY_ID.BLOOD_SPORTS_RANK or act_id == OPERATE_ACTIVITY_ID.SHIELD_SPORTS_RANK or
		   act_id == OPERATE_ACTIVITY_ID.DIAMOND_SPORTS_RANK or act_id == OPERATE_ACTIVITY_ID.SEALBEAD_SPORTS_RANK or
		   act_id == OPERATE_ACTIVITY_ID.INJECT_SPORTS_RANK or act_id == OPERATE_ACTIVITY_ID.SWING_SPORTS_RANK or

		   act_id == OPERATE_ACTIVITY_ID.DAILY_EXP_SPORTS_RANK or act_id == OPERATE_ACTIVITY_ID.DAILY_BOSS_SPORTS_RANK or
		   act_id == OPERATE_ACTIVITY_ID.DAILY_BLOOD_SPORTS_RANK or act_id == OPERATE_ACTIVITY_ID.DAILY_SHIELD_SPORTS_RANK or
		   act_id == OPERATE_ACTIVITY_ID.DAILY_DIAMOND_SPORTS_RANK or act_id == OPERATE_ACTIVITY_ID.DAILY_SEALBEAD_SPORTS_RANK or
		   act_id == OPERATE_ACTIVITY_ID.DAILY_INJECT_SPORTS_RANK or act_id == OPERATE_ACTIVITY_ID.DAILY_SWING_SPORTS_RANK or
		   act_id == OPERATE_ACTIVITY_ID.RECHARGE_RANK or act_id == OPERATE_ACTIVITY_ID.SPEND_RANK or
		   act_id == OPERATE_ACTIVITY_ID.GREATE_RECHARGE_RANK or act_id == OPERATE_ACTIVITY_ID.GREATE_SPEND_RANK or
		   act_id == OPERATE_ACTIVITY_ID.SOUL_STONE_SPORTS_RANK or act_id == OPERATE_ACTIVITY_ID.DAILY_SOUL_STONE_SPORTS_RANK or 
		   act_id == OPERATE_ACTIVITY_ID.BLOOD_SPORTS_RANK_2 or act_id == OPERATE_ACTIVITY_ID.SHIELD_SPORTS_RANK_2 or act_id == OPERATE_ACTIVITY_ID.DIAMOND_SPORTS_RANK_2 or
		   act_id == OPERATE_ACTIVITY_ID.SEALBEAD_SPORTS_RANK_2 or act_id == OPERATE_ACTIVITY_ID.INJECT_SPORTS_RANK_2 or
		   act_id == OPERATE_ACTIVITY_ID.SOUL_STONE_SPORTS_RANK_2 then

		   return OperateActivityData.OperateActBigType.SPORTS_RANK
	end

	return OperateActivityData.OperateActBigType.OTHER
end

-- 竞技排行类型(1:非货币类 2:货币类)
function OperateActivityData.GetSportsRankType(act_id)
	if act_id == OPERATE_ACTIVITY_ID.EXP_SPORTS_RANK or act_id == OPERATE_ACTIVITY_ID.BOSS_SPORTS_RANK or
		   act_id == OPERATE_ACTIVITY_ID.BLOOD_SPORTS_RANK or act_id == OPERATE_ACTIVITY_ID.SHIELD_SPORTS_RANK or
		   act_id == OPERATE_ACTIVITY_ID.DIAMOND_SPORTS_RANK or act_id == OPERATE_ACTIVITY_ID.SEALBEAD_SPORTS_RANK or
		   act_id == OPERATE_ACTIVITY_ID.INJECT_SPORTS_RANK or act_id == OPERATE_ACTIVITY_ID.SWING_SPORTS_RANK or

		   act_id == OPERATE_ACTIVITY_ID.DAILY_EXP_SPORTS_RANK or act_id == OPERATE_ACTIVITY_ID.DAILY_BOSS_SPORTS_RANK or
		   act_id == OPERATE_ACTIVITY_ID.DAILY_BLOOD_SPORTS_RANK or act_id == OPERATE_ACTIVITY_ID.DAILY_SHIELD_SPORTS_RANK or
		   act_id == OPERATE_ACTIVITY_ID.DAILY_DIAMOND_SPORTS_RANK or act_id == OPERATE_ACTIVITY_ID.DAILY_SEALBEAD_SPORTS_RANK or
		   act_id == OPERATE_ACTIVITY_ID.DAILY_INJECT_SPORTS_RANK or act_id == OPERATE_ACTIVITY_ID.DAILY_SWING_SPORTS_RANK or
		   act_id == OPERATE_ACTIVITY_ID.SOUL_STONE_SPORTS_RANK or act_id == OPERATE_ACTIVITY_ID.DAILY_SOUL_STONE_SPORTS_RANK then

		   return 1

	elseif act_id == OPERATE_ACTIVITY_ID.RECHARGE_RANK or act_id == OPERATE_ACTIVITY_ID.SPEND_RANK or
		   act_id == OPERATE_ACTIVITY_ID.GREATE_RECHARGE_RANK or act_id == OPERATE_ACTIVITY_ID.GREATE_SPEND_RANK then
		return 2

	elseif act_id == OPERATE_ACTIVITY_ID.BLOOD_SPORTS_RANK_2 or act_id == OPERATE_ACTIVITY_ID.SHIELD_SPORTS_RANK_2 or 
		act_id == OPERATE_ACTIVITY_ID.DIAMOND_SPORTS_RANK_2 or act_id == OPERATE_ACTIVITY_ID.SEALBEAD_SPORTS_RANK_2 or
		act_id == OPERATE_ACTIVITY_ID.INJECT_SPORTS_RANK_2 or act_id == OPERATE_ACTIVITY_ID.SOUL_STONE_SPORTS_RANK_2 then
		return 3
	end
end

function OperateActivityData.GetChargeOrSpendStr(act_id)
	local str = ""
	if act_id == OPERATE_ACTIVITY_ID.RECHARGE_RANK or act_id == OPERATE_ACTIVITY_ID.GREATE_RECHARGE_RANK or
	 act_id == OPERATE_ACTIVITY_ID.BLOOD_SPORTS_RANK_2 or 
	 act_id == OPERATE_ACTIVITY_ID.SHIELD_SPORTS_RANK_2 or 
	 act_id == OPERATE_ACTIVITY_ID.DIAMOND_SPORTS_RANK_2 or 
	 act_id == OPERATE_ACTIVITY_ID.SEALBEAD_SPORTS_RANK_2 or
	 act_id == OPERATE_ACTIVITY_ID.INJECT_SPORTS_RANK_2 or
	 act_id == OPERATE_ACTIVITY_ID.SOUL_STONE_SPORTS_RANK_2 then
		str = Language.OperateActivity.RechargeOrSpend[1]
	elseif act_id == OPERATE_ACTIVITY_ID.SPEND_RANK or act_id == OPERATE_ACTIVITY_ID.GREATE_SPEND_RANK then
		str = Language.OperateActivity.RechargeOrSpend[2]
	end
	return str
end

-- 是否是每日竞技类
function OperateActivityData.IsDailySports(act_id)

	if act_id == OPERATE_ACTIVITY_ID.DAILY_EXP_SPORTS or act_id == OPERATE_ACTIVITY_ID.DAILY_BOSS_SPORTS or
	   act_id == OPERATE_ACTIVITY_ID.DAILY_BLOOD_SPORTS or act_id == OPERATE_ACTIVITY_ID.DAILY_SHIELD_SPORTS or
	   act_id == OPERATE_ACTIVITY_ID.DAILY_DIAMOND_SPORTS or act_id == OPERATE_ACTIVITY_ID.DAILY_SEALBEAD_SPORTS or
	   act_id == OPERATE_ACTIVITY_ID.DAILY_INJECT_SPORTS or act_id == OPERATE_ACTIVITY_ID.DAILY_SWING_SPORTS or 
	   act_id == OPERATE_ACTIVITY_ID.DAILY_SOUL_STONE_SPORTS then

	   return true
	end

	return false
end

-- 设置运营活动数据
function OperateActivityData:SetOperateActData(data)
	local func = nil
	local act_big_type = OperateActivityData.GetOperateActBigType(data.act_id)
	if act_big_type == OperateActivityData.OperateActBigType.SPORTS_TYPE then 						-- ====达标竞技类活动
		func = OperateActivityData.ActIDInitSetFuncNameMap["SportsType"]
	elseif act_big_type == OperateActivityData.OperateActBigType.SPORTS_RANK then 					-- =====达标竞技类活动排行
		  func = OperateActivityData.ActIDInitSetFuncNameMap["SportsRank"]
	else 																							-- =====其他零散的活动
		func = OperateActivityData.ActIDInitSetFuncNameMap[data.act_id]
	end

	if func then
		if self[func] then
			self[func](self, data)
		end
	end																							
	OperateActivityCtrl.Instance:DoRemindByActID(data.act_id)
	self:FireEventByActId(data.act_id)

end

-- 数据多余最大数量时从后面删除多出的数据
function OperateActivityData:DelListOverFloodCnt(record_list, del_cnt)
	for i = 1, del_cnt, 1 do
		table.remove(record_list, #record_list)
	end
end

-- 操作后更新运营活动数据(达标竞技类/团购不在此更新，在SetOperateActData中更新)
function OperateActivityData:UpdateOperateActData(data)
	local func = OperateActivityData.ActIDUpdateFuncNameMap[data.act_id]
	if func then
		if self[func] then
			self[func](self, data)
		end
	end	
	OperateActivityCtrl.Instance:DoRemindByActID(data.act_id)										
	self:FireEventByActId(data.act_id)
end

function OperateActivityData:DeleteAct(del_data)
	if del_data.act_id > 0 then 					--删除单个活动
		for k, v in ipairs(self.open_acts_list) do
			if v.act_id == del_data.act_id then
				table.remove(self.open_acts_list, k)
				self:ClearActDataByActID(del_data.act_id)
				break
			end
		end
	else 											--删除一批(cmd_id相同的)活动
		local del_cmd_id = del_data.cmd_id
		local idx = 1
		while nil ~= self.open_acts_list[idx] do
			if self.open_acts_list[idx].cmd_id == del_cmd_id then
				local data = table.remove(self.open_acts_list, idx)
				self:ClearActDataByActID(data.act_id)
			else
				idx = idx + 1
			end
		end	

		-- for i = #self.open_acts_list, 1, -1 do
		-- 	if self.open_acts_list[i] and 
		-- 		self.open_acts_list[i].cmd_id == del_cmd_id then

		-- 		local data = table.remove(self.open_acts_list, i)
		-- 		self:ClearActDataByActID(data.act_id)
		-- 	end
		-- end
	end

	GlobalEventSystem:Fire(OperateActivityEventType.DELETE_CLOSE_ACT)
end

function OperateActivityData:AddOpenAct(add_act)
	if not self:CheckActIsOpen(add_act.act_id) then
		OperateActivityCtrl.Instance:ReqOperateActCfg(add_act.cmd_id, add_act.act_id)
		table.insert(self.open_acts_list, add_act)
		self.add_act_flag = true
	end
end

function OperateActivityData:UpdateActConfig(update_config_info)
	if self:CheckActIsOpen(update_config_info.act_id) then
		OperateActivityCtrl.Instance:ReqOperateActCfg(update_config_info.cmd_id, update_config_info.act_id)
	end
end

--根据活动ID获取活动剩余时间
function OperateActivityData:GetActRemainTimeStrByActId(act_id)
	local time_str, remain_time = "", 0
	if self.operate_acts_configs[act_id] then
		local end_time = self.operate_acts_configs[act_id].end_time
		local cur_time = TimeCtrl.Instance:GetServerTime() or os.time()
		remain_time = end_time - cur_time
		if remain_time > 0 then
			time_str = TimeUtil.FormatSecond2Str(remain_time, 1)
		end
	end
	return time_str, remain_time
end

function OperateActivityData:ClearActDataByActID(act_id)
	self.operate_acts_configs[act_id] = nil
	local func = nil
	local act_big_type = OperateActivityData.GetOperateActBigType(act_id)
	if act_big_type == OperateActivityData.OperateActBigType.SPORTS_TYPE then 						-- ====达标竞技类活动
		func = OperateActivityData.ActIDClearFuncNameMap["SportsType"]
	elseif act_big_type == OperateActivityData.OperateActBigType.SPORTS_RANK then 					-- =====达标竞技类活动排行
		func = OperateActivityData.ActIDClearFuncNameMap["SportsRank"]
	else 																							-- =====其他零散的活动
		func = OperateActivityData.ActIDClearFuncNameMap[act_id]
	end
	if func then
		if self[func] then
			if act_big_type == OperateActivityData.OperateActBigType.SPORTS_TYPE or
				act_big_type == OperateActivityData.OperateActBigType.SPORTS_RANK then

				self[func](self, act_id)
			else
				self[func](self)
			end
		end
	end																													
end

-- ==========每日充值begin---------
function OperateActivityData:SetDailyChargeData(data)
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.DAILY_RECHARGE] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.DAILY_RECHARGE].config
	self.daily_charge_data = nil
	if cfg then 
		self.daily_charge_data = {	
									cmd_id = data.cmd_id,
									act_id = data.act_id,
									target_money = 0,
									awards = {},
									maxGrade = #cfg.Rewards,
									state = data.state,
									grade = data.grade,
								}
		self.daily_charge_data.target_money = cfg.Gold[data.grade] or 0
		self.daily_charge_data.awards = ItemData.AwardsToItems(cfg.Rewards[data.grade])
	end
end

function OperateActivityData:GetDailyChargeData()
	return self.daily_charge_data
end

function OperateActivityData:IsDailyChargeNeedRemind()
	if not self.daily_charge_data 
		or not self.operate_acts_configs[OPERATE_ACTIVITY_ID.DAILY_RECHARGE] then 
		return false 
	end
	if not self.daily_charge_first then
		self.daily_charge_first = true
		OPERATE_CLICKED_NO_REMIND[OPERATE_ACTIVITY_ID.DAILY_RECHARGE] = math.min(OPERATE_CLICKED_NO_REMIND[OPERATE_ACTIVITY_ID.DAILY_RECHARGE] + 1, 1) 
	else
		if self.daily_charge_data.state == DAILY_CHARGE_FETCH_ST.CAN then
			OPERATE_CLICKED_NO_REMIND[OPERATE_ACTIVITY_ID.DAILY_RECHARGE] = math.min(OPERATE_CLICKED_NO_REMIND[OPERATE_ACTIVITY_ID.DAILY_RECHARGE] + 1, 1) 
		else
			OPERATE_CLICKED_NO_REMIND[OPERATE_ACTIVITY_ID.DAILY_RECHARGE] = math.max(OPERATE_CLICKED_NO_REMIND[OPERATE_ACTIVITY_ID.DAILY_RECHARGE] - 1, 0)
		end
	end
	local award_cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.DAILY_RECHARGE].config.Rewards
	return self.daily_charge_data.grade <= #award_cfg and self.daily_charge_data.state ~= DAILY_CHARGE_FETCH_ST.FETCHED and 
	(OPERATE_CLICKED_NO_REMIND[OPERATE_ACTIVITY_ID.DAILY_RECHARGE] == nil or OPERATE_CLICKED_NO_REMIND[OPERATE_ACTIVITY_ID.DAILY_RECHARGE] > 0)
end

function OperateActivityData:ClearDailyChargeData()
	self.daily_charge_data = nil
end

-- =============每日充值end----------

--==========达标竞技类活动begin----

--设置达标竞技类活动数据
function OperateActivityData:SetOperateSportsTypeData(data)
	if nil == self.sports_type_data_t[data.act_id] then
		self:InitSportsTypeData(data)
	else
		self:UpdateSportsTypeData(data)
	end

end

function OperateActivityData:InitSportsTypeData(data)
	local cfg = self.operate_acts_configs[data.act_id] and self.operate_acts_configs[data.act_id].config.Awards
	if not cfg then return end
	local data_t = {value = data.value, awards_info = {}}
	for k, v in ipairs(cfg) do
		local info = data.awar_info[k]
		local t = {
						cmd_id = data.cmd_id,
						act_id = data.act_id,
						state = info and info.state or 0,
						awards = {},
						rest_cnt = info and info.rest_cnt or 0,
						max_cnt = v.maxCount,
						desc = v.desc,
						icon = v.icon,
					}
		if t.max_cnt == -1 then
			t.state = info.state
		else
			t.state = t.rest_cnt > 0 and info.state or STANDARD_SPROTS_FETCH_STATE.NO_CNT
		end
		
		if v.mailReward and v.mailReward == 1 then
			t.top1_role_id = data.top1_role_id
			t.top1_name = data.top1_name
		end
		t.awards = ItemData.AwardsToItems(v.awards)
		table.insert(data_t.awards_info, t)
	end
	self.sports_type_data_t[data.act_id] = data_t
end

function OperateActivityData:UpdateSportsTypeData(update_data)
	if nil == self.sports_type_data_t[update_data.act_id] then return end
	self.sports_type_data_t[update_data.act_id].value = update_data.value
	for k, v in pairs(self.sports_type_data_t[update_data.act_id].awards_info) do
		if v.top1_name and v.top1_role_id then
			v.top1_role_id = update_data.top1_role_id
			v.top1_name = update_data.top1_name
		end
		local info = update_data.awar_info[k]
		if info then
			v.rest_cnt = info.rest_cnt or 0
			if v.max_cnt == -1 then
				v.state = info.state
			else
				v.state = v.rest_cnt > 0 and info.state or STANDARD_SPROTS_FETCH_STATE.NO_CNT
			end
		end
	end
end

--根据活动ID获取达标竞技类活动的数据
function OperateActivityData:GetStandardSportsDataByActId(act_id)
	return self.sports_type_data_t[act_id]
end

function OperateActivityData:IsStandardSportsNeedRemindByActId(act_id)
	if not self.sports_type_data_t[act_id] then return false end
	for k, v in pairs(self.sports_type_data_t[act_id].awards_info) do
		if k ~= 1 and v.state == STANDARD_SPROTS_FETCH_STATE.CAN_FETCH then
			return true
		end
	end

	return false
end

function OperateActivityData:ClearSportsTypeActDataByActID(act_id)
	self.sports_type_data_t[act_id] = nil
end

--==========达标竞技end----

-- 获取达标竞技属性点名称
function OperateActivityData.GetAttrNameByActID(act_id)
	if act_id == OPERATE_ACTIVITY_ID.EXP_SPORTS or act_id == OPERATE_ACTIVITY_ID.DAILY_EXP_SPORTS then
		return Language.OperateActivity.AttrName[1]
	elseif act_id == OPERATE_ACTIVITY_ID.BOSS_SPORTS or act_id == OPERATE_ACTIVITY_ID.DAILY_BOSS_SPORTS then 
		return Language.OperateActivity.AttrName[2]
	elseif act_id == OPERATE_ACTIVITY_ID.BLOOD_SPORTS or act_id == OPERATE_ACTIVITY_ID.DAILY_BLOOD_SPORTS or act_id == OPERATE_ACTIVITY_ID.BLOOD_SPORTS_RANK_2 then
		return Language.OperateActivity.AttrName[3]
	elseif act_id == OPERATE_ACTIVITY_ID.SHIELD_SPORTS or act_id == OPERATE_ACTIVITY_ID.DAILY_SHIELD_SPORTS or act_id == OPERATE_ACTIVITY_ID.SHIELD_SPORTS_RANK_2 then
		return Language.OperateActivity.AttrName[4]
	elseif act_id == OPERATE_ACTIVITY_ID.DIAMOND_SPORTS or act_id == OPERATE_ACTIVITY_ID.DAILY_DIAMOND_SPORTS or act_id == OPERATE_ACTIVITY_ID.DIAMOND_SPORTS_RANK_2 then
		return Language.OperateActivity.AttrName[5]
	elseif act_id == OPERATE_ACTIVITY_ID.SEALBEAD_SPORTS or act_id == OPERATE_ACTIVITY_ID.DAILY_SEALBEAD_SPORTS or act_id == OPERATE_ACTIVITY_ID.SEALBEAD_SPORTS_RANK_2 then
		return Language.OperateActivity.AttrName[6]
	elseif act_id == OPERATE_ACTIVITY_ID.INJECT_SPORTS or act_id == OPERATE_ACTIVITY_ID.DAILY_INJECT_SPORTS or act_id == OPERATE_ACTIVITY_ID.INJECT_SPORTS_RANK_2 then
		return Language.OperateActivity.AttrName[7]
	elseif act_id == OPERATE_ACTIVITY_ID.SWING_SPORTS or act_id == OPERATE_ACTIVITY_ID.DAILY_SWING_SPORTS then
		return Language.OperateActivity.AttrName[8]
	elseif act_id == OPERATE_ACTIVITY_ID.SOUL_STONE_SPORTS or act_id == OPERATE_ACTIVITY_ID.DAILY_SOUL_STONE_SPORTS or act_id == OPERATE_ACTIVITY_ID.SOUL_STONE_SPORTS_RANK_2 or act_id == OPERATE_ACTIVITY_ID.SOUL_STONE_SPORTS_RANK_2 then
		return Language.OperateActivity.AttrName[9]
	end
end

-- 获取竞技类活动和排行图标ID
function OperateActivityData.GetSportsAndRankIconIDByActID(act_id)
	if act_id == OPERATE_ACTIVITY_ID.EXP_SPORTS or act_id == OPERATE_ACTIVITY_ID.DAILY_EXP_SPORTS or
	   act_id == OPERATE_ACTIVITY_ID.EXP_SPORTS_RANK or act_id == OPERATE_ACTIVITY_ID.DAILY_EXP_SPORTS_RANK  then
		return 1
	elseif act_id == OPERATE_ACTIVITY_ID.BOSS_SPORTS or act_id == OPERATE_ACTIVITY_ID.DAILY_BOSS_SPORTS or
		   act_id == OPERATE_ACTIVITY_ID.BOSS_SPORTS_RANK or act_id == OPERATE_ACTIVITY_ID.DAILY_BOSS_SPORTS_RANK then 
		return 2
	elseif act_id == OPERATE_ACTIVITY_ID.BLOOD_SPORTS or act_id == OPERATE_ACTIVITY_ID.DAILY_BLOOD_SPORTS or
		   act_id == OPERATE_ACTIVITY_ID.BLOOD_SPORTS_RANK or act_id == OPERATE_ACTIVITY_ID.DAILY_BLOOD_SPORTS_RANK then
		return 3
	elseif act_id == OPERATE_ACTIVITY_ID.SHIELD_SPORTS or act_id == OPERATE_ACTIVITY_ID.DAILY_SHIELD_SPORTS or
		   act_id == OPERATE_ACTIVITY_ID.SHIELD_SPORTS_RANK or act_id == OPERATE_ACTIVITY_ID.DAILY_SHIELD_SPORTS_RANK then
		return 4
	elseif act_id == OPERATE_ACTIVITY_ID.DIAMOND_SPORTS or act_id == OPERATE_ACTIVITY_ID.DAILY_DIAMOND_SPORTS or
		   act_id == OPERATE_ACTIVITY_ID.DIAMOND_SPORTS_RANK or act_id == OPERATE_ACTIVITY_ID.DAILY_DIAMOND_SPORTS_RANK then
		return 5
	elseif act_id == OPERATE_ACTIVITY_ID.SEALBEAD_SPORTS or act_id == OPERATE_ACTIVITY_ID.DAILY_SEALBEAD_SPORTS or
		   act_id == OPERATE_ACTIVITY_ID.SEALBEAD_SPORTS_RANK or act_id == OPERATE_ACTIVITY_ID.DAILY_SEALBEAD_SPORTS_RANK then
		return 6
	elseif act_id == OPERATE_ACTIVITY_ID.INJECT_SPORTS or act_id == OPERATE_ACTIVITY_ID.DAILY_INJECT_SPORTS or
		   act_id == OPERATE_ACTIVITY_ID.INJECT_SPORTS_RANK or act_id == OPERATE_ACTIVITY_ID.DAILY_INJECT_SPORTS_RANK then
		return 7
	elseif act_id == OPERATE_ACTIVITY_ID.SWING_SPORTS or act_id == OPERATE_ACTIVITY_ID.DAILY_SWING_SPORTS or
		   act_id == OPERATE_ACTIVITY_ID.SWING_SPORTS_RANK or act_id == OPERATE_ACTIVITY_ID.DAILY_SWING_SPORTS_RANK  then
		return 8
	elseif act_id == OPERATE_ACTIVITY_ID.RECHARGE_RANK or act_id == OPERATE_ACTIVITY_ID.GREATE_RECHARGE_RANK or 
		act_id == OPERATE_ACTIVITY_ID.SPEND_RANK or act_id == OPERATE_ACTIVITY_ID.GREATE_SPEND_RANK or 
		act_id == OPERATE_ACTIVITY_ID.NEW_SPEND_RANK or act_id == OPERATE_ACTIVITY_ID.NEW_CHARGE_RANK then
		return 9
	elseif act_id == OPERATE_ACTIVITY_ID.SOUL_STONE_SPORTS or act_id == OPERATE_ACTIVITY_ID.DAILY_SOUL_STONE_SPORTS or 
		act_id == OPERATE_ACTIVITY_ID.SOUL_STONE_SPORTS_RANK or act_id == OPERATE_ACTIVITY_ID.DAILY_SOUL_STONE_SPORTS_RANK then
		return 10
	elseif act_id == OPERATE_ACTIVITY_ID.BLOOD_SPORTS_RANK_2 then
		return 11
	elseif act_id == OPERATE_ACTIVITY_ID.SHIELD_SPORTS_RANK_2 then
		return 12
	elseif act_id == OPERATE_ACTIVITY_ID.DIAMOND_SPORTS_RANK_2 then
		return 13
	elseif act_id == OPERATE_ACTIVITY_ID.SEALBEAD_SPORTS_RANK_2 then
		return 14
	elseif act_id == OPERATE_ACTIVITY_ID.INJECT_SPORTS_RANK_2 then
		return 1
	elseif act_id == OPERATE_ACTIVITY_ID.SOUL_STONE_SPORTS_RANK_2 then
		return 16
	end
	return 1
end

-- ====================竞技排行类活动=======================
function OperateActivityData:InitSportsRankCfgData(act_id)
	local cfg = self.operate_acts_configs[act_id] and self.operate_acts_configs[act_id].config
	if cfg then
		if not self.sports_rank_cfg_t[act_id] then
			self.sports_rank_cfg_t[act_id] = {}
			for k, v in ipairs(cfg.Awards) do
				local temp_cfg = {
									desc = v.desc,
									icon = v.icon,
									cond = v.cond,
									act_id = act_id,
									awards = {},
									need_min_value = v.needMinValue,
									need_min_charge = v.needRechargeValue,
									rank_des = v.rankDes,
								}
				temp_cfg.awards = ItemData.AwardsToItems(v.awards)
				table.insert(self.sports_rank_cfg_t[act_id], temp_cfg)
			end
		end
	end
end

function OperateActivityData:GetSportsRankCfgByActID(act_id)
	return self.sports_rank_cfg_t[act_id]
end

function OperateActivityData:SetSportsRankMyRankByActID(data)
	self.sports_rank_my_ranks = self.sports_rank_my_ranks or {}
	self.sports_rank_my_ranks[data.act_id] = data.my_rank
	self.sports_rank_my_money = self.sports_rank_my_money or {}
	self.sports_rank_my_value = self.sports_rank_my_value or {}
	if data.cur_money then
		self.sports_rank_my_money[data.act_id] = data.cur_money
	end 

	if data.value then
		self.sports_rank_my_value[data.act_id] = data.value
	end
end

function OperateActivityData:GetSportsRankMyRankByActID(act_id)
	return self.sports_rank_my_ranks[act_id] or 0
end

function OperateActivityData:GetSportsRankMyMoneyByActID(act_id)
	return self.sports_rank_my_money[act_id]
end

function OperateActivityData:GetSportsRankMyValuByActID(act_id)
	return self.sports_rank_my_value[act_id]
end

function OperateActivityData:ClearSportsRankDataByActID(act_id)
	self.sports_rank_cfg_t[act_id] = nil
	self.sports_rank_my_ranks[act_id] = nil
	self.sports_rank_my_money[act_id] = nil
	self.sports_rank_my_value[act_id] = nil
end

--=================奖励兑换begind====================
-- 获取不同类型货币属性值对应枚举值
function OperateActivityData.GetMoneyObjAttrIndex(money_type)
	if money_type == tagAwardType.qatBindMoney then
		return OBJ_ATTR.ACTOR_BIND_COIN
	elseif money_type == tagAwardType.qatMoney then
		return OBJ_ATTR.ACTOR_COIN
	elseif money_type == tagAwardType.qatBindYb then
		return OBJ_ATTR.ACTOR_BIND_GOLD
	elseif money_type == tagAwardType.qatYuanbao then
		return OBJ_ATTR.ACTOR_GOLD
	end
end

function OperateActivityData:InitConvertAwardConfig()
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.CONVERT_AWARD] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.CONVERT_AWARD].config
	if not cfg or not next(cfg) then return end
	self.convert_award_data = {}
	local job = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	local items_list = cfg.itemList or {}
	for i, v in ipairs(items_list) do
		local temp = {idx = i, awards_t = {}, rest_cnt = 0, convert_item = {}, convert_money = {}, can_convert = false}
		temp.awards_t = ItemData.AwardsToItems(v.awards)
		for k_2, v_2 in ipairs(v.consumes) do
			if v_2.type == 0 then
				table.insert(temp.convert_item, {item_id = v_2.id, num = v_2.count, is_bind = v_2.bind})
			else
				local item_cfg, big_type = ItemData.Instance:GetItemConfig(ItemData.Instance:GetVirtualItemId(v_2.type))
				local icon_id = item_cfg and item_cfg.icon or 0
				table.insert(temp.convert_money, {icon_id = icon_id, count = v_2.count, 
					money_attr = OperateActivityData.GetMoneyObjAttrIndex(v_2.type)})
			end
		end
		table.insert(self.convert_award_data, temp)
	end
end

function OperateActivityData:SetConvertAwardData(data)
	if not self.convert_award_data then return end
	for k, v in ipairs(self.convert_award_data) do
		local data = data.awar_info[v.idx]
		if data then
			v.rest_cnt = data.rest_cnt
		end
	end
	self:SetConvertAwardCanConvert()
end

function OperateActivityData:GetConvertAwardData()
	return self.convert_award_data
end

function OperateActivityData:UpdateConvertAwardData(data)
	-- self.own_spend_score = data.value
	local idx = data.idx
	local rest_cnt = data.rest_cnt 
	for k, v in pairs(self.convert_award_data) do
		if v.idx == idx then
			v.rest_cnt = rest_cnt
			break
		end
	end
	self:SetConvertAwardCanConvert()
end

function OperateActivityData:IsConvetAwardNeedRemind()
	if not self.convert_award_data or not next(self.convert_award_data) then return false end
	self:SetConvertAwardCanConvert()
	for k, v in pairs(self.convert_award_data) do
		if v.can_convert then
			return true
		end
	end
	return false
end

function OperateActivityData:SetConvertAwardCanConvert()
	if not self.convert_award_data or not next(self.convert_award_data) then return false end
	local own_money = 0 
	local own_item_num = 0
	local need_item_cnt = 0
	local match_item_cnt = 0
	local is_item_match = false
	local is_money_match = true
	for _, v in pairs(self.convert_award_data) do
		need_item_cnt = #v.convert_item
		match_item_cnt = 0
		is_money_match = true
		is_item_match = false
		for _, v_2 in pairs(v.convert_item) do
			own_item_num = ItemData.Instance:GetItemNumInBagById(v_2.item_id)
			if v_2.num <= own_item_num then
				match_item_cnt = match_item_cnt + 1
			end
		end
		is_item_match = match_item_cnt == need_item_cnt

		for _, v_2 in pairs(v.convert_money) do
			own_money = RoleData.Instance:GetAttr(v_2.money_attr)
			is_money_match = own_money >= v_2.count
		end
		v.can_convert = is_money_match and is_item_match and (v.rest_cnt == -1 or v.rest_cnt > 0)
	end

end

function OperateActivityData:ClearConvertAwardData()
	self.convert_award_data = nil
end

--=================奖励兑换end====================

--------------------------------元宝转盘begin---------------------------------------
function OperateActivityData:InitYBWheelCfgInfo()
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.YB_WHEEL] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.YB_WHEEL].config
	if cfg then
		self.yb_wheel_cfg_info = {}
		self.yb_wheel_cfg_info.per_play_cost = cfg.everyPlayCosumeScore
		self.yb_wheel_cfg_info.save_count = cfg.saveCount
		self.yb_wheel_cfg_info.icons_bag = {}
		for k, v in ipairs(cfg.itemList) do
			self.yb_wheel_cfg_info.icons_bag[k] = v.icon
		end
	end
end

function OperateActivityData:GetYBWheelCfgInfo()
	return self.yb_wheel_cfg_info
end


function OperateActivityData:SetYBWheelData(data)
	if not self.yb_wheel_cfg_info then return end

	self.cur_own_yb_score = data.cur_yb_score
	
	self.yb_wheel_record_list = self.yb_wheel_record_list or {}
	for _, v in ipairs(data.record_list) do
		table.insert(self.yb_wheel_record_list, 1, v)
	end

	-- 超出最大数量限制，从后面删除多出的
	local recor_list_len = #self.yb_wheel_record_list
	if recor_list_len > self.yb_wheel_cfg_info.save_count then
		local no_need_cnt = recor_list_len - self.yb_wheel_cfg_info.save_count
		self:DelListOverFloodCnt(self.yb_wheel_record_list, no_need_cnt)
	end

	GlobalEventSystem:Fire(OperateActivityEventType.YB_WHEEL_RECORD_DATA_CHANGE)
end

function OperateActivityData:UpdateYBWheelData(data)
	self.cur_own_yb_score = data.cur_yb_score 
	if data.oper_type == 1 or data.oper_type == 3 then
		self.turn_place = data.awar_idx

		GlobalEventSystem:Fire(OperateActivityEventType.YB_WHEEL_TURN_PLACE_CHANGE)
	end
end

function OperateActivityData:GetCurOwnYBScore()
	return self.cur_own_yb_score or 0
end

function OperateActivityData:GetYBWheelRecordList()
	return self.yb_wheel_record_list
end

function OperateActivityData:GetYBWheelTurnPlace()
	return self.turn_place or 1
end

function OperateActivityData:IsYBWheelNeedRemind()
	if self.yb_wheel_cfg_info then
		return self.cur_own_yb_score >= self.yb_wheel_cfg_info.per_play_cost
	end
	return false
end

function OperateActivityData:ClearYBWheelData()
	self.yb_wheel_cfg_info = nil
	self.yb_wheel_record_list = nil
	self.cur_own_yb_score = nil
	self.turn_place = nil
end

--------------------------------元宝转盘end---------------------------------------

--------------------------------幸运转盘begin---------------------------------------
function OperateActivityData:InitLuckTurnCfgInfo()
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.LUCK_TURN_WHEEL] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.LUCK_TURN_WHEEL].config
	if cfg then
		self.luck_turn_cfg_info = {}
		self.luck_turn_cfg_info.per_play_cost = cfg.everyPlayCosumeScore
		self.luck_turn_cfg_info.save_count = cfg.saveCount
		self.luck_turn_cfg_info.icons_bag = {}
		for k, v in ipairs(cfg.itemList) do
			self.luck_turn_cfg_info.icons_bag[k] = {icon = v.icon}
		end
	end
end

function OperateActivityData:GetLuckTurnCfgInfo()
	return self.luck_turn_cfg_info
end


function OperateActivityData:SetLuckTurnData(data)
	if not self.luck_turn_cfg_info then return end

	self.luck_own_score = data.cur_yb_score
	
	self.luck_turn_record_list = self.luck_turn_record_list or {}
	for _, v in ipairs(data.record_list) do
		table.insert(self.luck_turn_record_list, 1, v)
	end

	-- 超出最大数量限制，从后面删除多出的
	local recor_list_len = #self.luck_turn_record_list
	if recor_list_len > self.luck_turn_cfg_info.save_count then
		local no_need_cnt = recor_list_len - self.luck_turn_cfg_info.save_count
		self:DelListOverFloodCnt(self.luck_turn_record_list, no_need_cnt)
	end

	GlobalEventSystem:Fire(OperateActivityEventType.LUCK_TURN_WHEEL_RECORD_DATA_CHANGE)
end

function OperateActivityData:UpdateLuckTurnData(data)
	self.luck_own_score = data.cur_yb_score 
	if data.oper_type == 1 or data.oper_type == 3 then
		self.luck_turn_place = data.awar_idx

		GlobalEventSystem:Fire(OperateActivityEventType.LUCK_TURN_WHEEL_TURN_PLACE_CHANGE)
	end
end

function OperateActivityData:GetLuckOwnYBScore()
	return self.luck_own_score or 0
end

function OperateActivityData:GetLuckTurnRecordList()
	return self.luck_turn_record_list
end

function OperateActivityData:GetLuckTurnPlace()
	return self.luck_turn_place or 1
end

function OperateActivityData:IsLuckTurnNeedRemind()
	if self.luck_turn_cfg_info then
		return self.luck_own_score >= self.luck_turn_cfg_info.per_play_cost
	end
	return false
end

function OperateActivityData:ClearLuckTurnData()
	self.luck_turn_cfg_info = nil
	self.luck_turn_record_list = nil
	self.luck_own_score = nil
	self.luck_turn_place = nil
end

--------------------------------幸运转盘end---------------------------------------

-------------------------------------聚宝盆begin-------------------------------------------
function OperateActivityData:InitJvBaoPenCfgInfo()
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.JVBAO_PEN] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.JVBAO_PEN].config
	if cfg then
		self.jv_bao_pen_cfg = {}
		self.jv_bao_pen_cfg.max_cnt = cfg.maxCount
		self.jv_bao_pen_cfg.save_count = cfg.saveCount
		self.jv_bao_pen_cfg.awards_info = cfg.awrads
		self.jv_bao_cur_award_info = nil
		self.jv_bao_charged_money = 0
		self.jv_bao_rest_cnt = cfg.maxCount
		self.jv_bao_record_list = {}
	end
end

function OperateActivityData:SetJvBaoPenData(data)
	if not self.jv_bao_pen_cfg then return end
	self.jv_bao_charged_money = data.charge_money
	self.jv_bao_rest_cnt = self.jv_bao_pen_cfg.max_cnt - data.used_cnt
	self.jv_bao_cur_award_info = self.jv_bao_pen_cfg.awards_info[data.used_cnt + 1] and self.jv_bao_pen_cfg.awards_info[data.used_cnt + 1]
	self.jv_bao_record_list = self.jv_bao_record_list or {}
	for _, v in pairs(data.record_list) do
		table.insert(self.jv_bao_record_list, 1, v)
	end

	local record_cnt = #self.jv_bao_record_list
	if record_cnt > self.jv_bao_pen_cfg.save_count then
		local no_need_cnt = record_cnt - self.jv_bao_pen_cfg.save_count
		self:DelListOverFloodCnt(self.jv_bao_record_list, no_need_cnt)
	end
end

function OperateActivityData:ClearJvBaoPenData()
	self.jv_bao_pen_cfg = nil
	self.jv_bao_record_list = nil
	self.jv_bao_charged_money = 0
	self.jv_bao_record_list = nil
	self.jv_bao_rest_cnt = 0
	self.jv_bao_cur_award_info = nil
end

function OperateActivityData:GetJvBaoPenData()
	return self.jv_bao_rest_cnt or 10, self.jv_bao_cur_award_info, self.jv_bao_record_list, self.jv_bao_charged_money or 0
end

function OperateActivityData:IsJvBaoPenNeedRemind()
	if self.jv_bao_cur_award_info == nil then return false end
	local role_own_yb = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
	return self.jv_bao_charged_money >= self.jv_bao_cur_award_info.needRechargeGoldNum and role_own_yb >= self.jv_bao_cur_award_info.costGoldNum
end

-------------------------------------聚宝盆end-------------------------------------------

-- ----------------------------天降奇宝begin---------------------------------
function OperateActivityData:InitTreasureDropCfgInfo()
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.TREASURE_DROP] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.TREASURE_DROP].config
	if cfg then
		self.treasure_drop_cfg = {}
		self.treasure_drop_rest_items_cnt = 24
		self.treasure_drop_cfg.default_count = cfg.DefaultCount
		self.treasure_drop_cfg.cost_money = cfg.CostMoney
		self.treasure_drop_cfg.max_count = cfg.maxCount
		self.treasure_drop_cfg.item_list = cfg.itemList
		self.treasure_drop_cfg.special_item_list = cfg.itemSpeicialList
		self.treasure_drop_cfg.refr_per_cost = cfg.RefreshCostMoney
		-- PrintTable(cfg.itemSpeicialList)
		self.treasure_per_col_fetched_cnt = {0, 0, 0, 0, 0, 0}
		self.treasure_drop_show_award_list = {}
		self.cur_delete_treasure_idx = 0
	end
end

function OperateActivityData:GetTreasureDropCfg()
	return self.treasure_drop_cfg
end

function OperateActivityData:GetTreasureDropCostMoney()
	return self.treasure_drop_cfg and self.treasure_drop_cfg.cost_money or 0
end

function OperateActivityData:GetTreasureDropRefrPerCost()
	return self.treasure_drop_cfg and self.treasure_drop_cfg.refr_per_cost or 0
end

function OperateActivityData:SetTreasureDropData(data)
	if self.treasure_drop_cfg == nil then return end
	self.treasure_drop_show_award_list = {}
	self.treasure_drop_rest_use_time = data.rest_use_time
	self.treasure_drop_add_one_rest_time = data.add_one_rest_time
	if self.treasure_drop_add_one_rest_time > 0 then
		self.treasure_drop_add_one_rest_time = self.treasure_drop_add_one_rest_time + Status.NowTime
		if self.check_treasure_drop_timer == nil then
			self.check_treasure_drop_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.CheckTreasureDropAddOneRestTime, self), 1)
		end
	else
		if self.check_treasure_drop_timer then
			GlobalTimerQuest:CancelQuest(self.check_treasure_drop_timer)
			self.check_treasure_drop_timer = nil
		end
	end

	for k, v in ipairs(data.award_pool_info) do
		local pool = nil
		for k2, v2 in ipairs(v) do
			if v2.is_special == 1 then
				pool = self.treasure_drop_cfg.special_item_list[k]
			else 
				pool = self.treasure_drop_cfg.item_list[k]
			end
			if pool then
				local awar_cfg = pool[v2.awar_id]
				if awar_cfg then
					v2.award = {item_id = awar_cfg.id, num = awar_cfg.count, is_bind = awar_cfg.bind}
				end
			end
		end
	end
	self.treasure_drop_show_award_list = data.award_pool_info

	self:SetTreasureDropPerColNotVisCount()
	GlobalEventSystem:Fire(OperateActivityEventType.TREASURE_DROP_AWARD_POOL_DATA)
end

function OperateActivityData:GetTreasureDropShowAwardList()
	return self.treasure_drop_show_award_list
end

function OperateActivityData:GetTreasureDropRestUseTime()
	return self.treasure_drop_rest_use_time
end

function OperateActivityData:SetTreasureDropPerColNotVisCount()
	self.treasure_per_col_fetched_cnt = {0, 0, 0, 0, 0, 0}
	self.treasure_drop_rest_items_cnt = 24
	for k, v in ipairs(self.treasure_drop_show_award_list) do
		for k2, v2 in ipairs(v) do
			if v2.state == 1 then
				self.treasure_per_col_fetched_cnt[k2] = self.treasure_per_col_fetched_cnt[k2] + 1
				self.treasure_drop_rest_items_cnt = self.treasure_drop_rest_items_cnt - 1
			end
		end
	end
end

function OperateActivityData:GetTreasureDropRefrCost()
	local cost = 0
	if self.treasure_drop_cfg and self.treasure_drop_cfg.refr_per_cost and self.treasure_drop_rest_items_cnt then
		cost = self.treasure_drop_cfg.refr_per_cost * self.treasure_drop_rest_items_cnt
	end
	return cost
end

function OperateActivityData:GetTreasureDropPerColFetchedInfo()
	return self.treasure_per_col_fetched_cnt
end

function OperateActivityData:IsTreasureDropHasFetchedAward()
	if not self.treasure_per_col_fetched_cnt then return false end
	for k, v in pairs(self.treasure_per_col_fetched_cnt) do
		if v > 0 then
			return true
		end
	end

	return false
end

function OperateActivityData:CheckTreasureDropAddOneRestTime()
	if self.treasure_drop_add_one_rest_time > 0 then
		local rest_time = self.treasure_drop_add_one_rest_time - Status.NowTime
		if rest_time <= 0 then
			local act_id = OPERATE_ACTIVITY_ID.TREASURE_DROP
			local cmd_id = self:GetOneOpenActCmdID(act_id)
			if cmd_id then
				OperateActivityCtrl.Instance:ReqOperateActData(cmd_id, act_id)
			end
		end
	end
end

function OperateActivityData:GetTreasureDropAddOneRestTime()
	local rest_time_str = nil
	if self.treasure_drop_add_one_rest_time > 0 then
		local rest_time = self.treasure_drop_add_one_rest_time - Status.NowTime
		rest_time_str = TimeUtil.FormatSecond2Str(rest_time > 0 and rest_time or 0, 1)
	end

	return rest_time_str
end

function OperateActivityData:UpdateTreasureDropData(data)
	self.treasure_drop_rest_use_time = data.rest_use_time
	self.treasure_drop_add_one_rest_time = data.add_one_rest_time
	if self.treasure_drop_add_one_rest_time > 0 then
		self.treasure_drop_add_one_rest_time = self.treasure_drop_add_one_rest_time + Status.NowTime
		if self.check_treasure_drop_timer == nil then
			self.check_treasure_drop_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.CheckTreasureDropAddOneRestTime, self), 1)
		end
	else
		if self.check_treasure_drop_timer then
			GlobalTimerQuest:CancelQuest(self.check_treasure_drop_timer)
			self.check_treasure_drop_timer = nil
		end
	end
	self.treasure_drop_show_award_list[data.pool_idx][data.award_pos].state = data.state
	self.cur_delete_treasure_idx = (data.pool_idx - 1) * 6 + data.award_pos
	self:SetTreasureDropPerColNotVisCount()
	local this_col_del_cnt = self.treasure_per_col_fetched_cnt[data.award_pos]
	-- print("cur_del, awar_pos, col_del_cnt, state", data.pool_idx, data.award_pos, this_col_del_cnt, data.state)

	GlobalEventSystem:Fire(OperateActivityEventType.TREASURE_DROP_CHOUJIANG_BACK, data.pool_idx, data.award_pos, this_col_del_cnt)
end

function OperateActivityData:GetCurDeleteTreasureIndex()
	return self.cur_delete_treasure_idx
end

function OperateActivityData:ClearTreasureDropData()
	if self.check_treasure_drop_timer then
		GlobalTimerQuest:CancelQuest(self.check_treasure_drop_timer)
		self.check_treasure_drop_timer = nil
	end
	self.treasure_drop_cfg = nil
	self.treasure_per_col_fetched_cnt = nil
	self.treasure_drop_show_award_list = nil
	self.cur_delete_treasure_idx = nil
	self.treasure_drop_rest_use_time = nil
	self.treasure_drop_add_one_rest_time = nil

end

function OperateActivityData:IsTreasureDropNeedRemind()
	return self.treasure_drop_rest_use_time and self.treasure_drop_rest_use_time > 0
end

-- -------------------------天降奇宝end-------------------------------

-- ----------------------------秘钥宝藏begin---------------------------------
function OperateActivityData:InitSecretKeyTreasureCfgInfo()
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.SECRET_KEY_TREASURE] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.SECRET_KEY_TREASURE].config
	if cfg then
		-- PrintTable(cfg)
		self.secret_key_can_buy = 0 				-- 是否可购买
		self.secret_key_cur_num = 0 				-- 当前数字
		self.secret_key_active_degree = 0 			-- 活跃度值
		self.secret_key_cost_money = 0 				-- 已花费的钱
		self.secret_key_get_cnt = 0 				-- 获得次数
		self.secret_key_used_cnt = 0 				-- 已使用次数
		self.secret_key_buy_cnt = 0 				-- 已购买次数
		self.secret_key_score = 0 					-- 积分
		self.secret_key_num_pool_info = {}
		for i = 1, 49 do
			local tmp = {state = 0, num = i}
			table.insert(self.secret_key_num_pool_info, tmp)
		end

		self.secret_key_treasure_cfg = {}
		self.secret_key_treasure_cfg.first_buy_cost = cfg.firstBuyCountCost		-- 第一次购买消耗
		self.secret_key_treasure_cfg.per_buy_add_cost = cfg.preCountAddCost		-- 购买消耗累加基数(第二次开始)
		self.secret_key_treasure_cfg.chose_num_cost = cfg.ChoiceNumCostScore

		self.secret_key_event_data = {}		-- 事件达成信息
		for k, v in ipairs(cfg.eventList) do
			v.str = string.format(Language.OperateActivity.SecretKeyTreasureEventStr[v.eventType], v.eventNum)
			v.state = 0
			table.insert(self.secret_key_event_data, v)
		end

		self.secret_key_line_award_data = {}		-- 每条线对应奖励数据
		for k, v in ipairs(cfg.lineList) do
			local tmp = {state = 0,}
			tmp.award = ItemData.AwardsToItems(v.awards)[1]
			self.secret_key_line_award_data[k] = tmp
		end

		self.secret_key_line_achieve_data = {}	-- 连线达成信息
		for k, v in ipairs(cfg.exLineAwards) do
			tmp = {str = "", state = 0, awards = {}, line_num = v.lineNum,}
			tmp.str = string.format(Language.OperateActivity.SecretKeyTreasureLineAchieve, v.lineNum)
			tmp.awards = ItemData.AwardsToItems(v.awards)
			table.insert(self.secret_key_line_achieve_data, tmp)
		end
	end
end

function OperateActivityData:GetSecretKeyTreasureCfg()
	return self.secret_key_treasure_cfg
end

function OperateActivityData:GetSerectKeyNumPoolData()
	return self.secret_key_num_pool_info
end

function OperateActivityData:GetSecretKeyEventData()
	return self.secret_key_event_data
end

function OperateActivityData:GetSecretKeyLineAwardData()
	return self.secret_key_line_award_data
end

function OperateActivityData:GetSecretKeyLineAchieveData()
	return self.secret_key_line_achieve_data
end

function OperateActivityData:GetSecretKeyCurNum()
	return self.secret_key_cur_num					
end

function OperateActivityData:GetSecretkeyScore()
	return self.secret_key_score
end

function OperateActivityData:GetSecretkeyGetCnt()
	return self.secret_key_get_cnt
end

function OperateActivityData:GetSecretkeyUsedCnt()
	return self.secret_key_used_cnt
end

function OperateActivityData:GetSecretkeyBuyCnt()
	return self.secret_key_buy_cnt
end

function OperateActivityData:GetSecretkeyCanBuy()
	return self.secret_key_can_buy
end

function OperateActivityData:SetSecretKeyTreasureData(data)
	if self.secret_key_treasure_cfg == nil then return end
	-- print("设置秘钥宝藏")
	-- PrintTable(data)
	self:SetSecretKeyTreasureTotalData(data)

end

function OperateActivityData:UpdateSecretKeyTreasureData(data)
	-- print("更新秘钥宝藏")
	-- PrintTable(data)
	self.secret_key_cur_num = data.get_num
	self:SetSecretKeyTreasureTotalData(data)
	
end

function OperateActivityData:SetSecretKeyTreasureTotalData(data)
	self.secret_key_can_buy = data.can_buy
	self.secret_key_active_degree = data.today_active_degree
	self.secret_key_cost_money = data.cost_money
	self.secret_key_get_cnt = data.get_cnt
	self.secret_key_used_cnt = data.used_cnt
	self.secret_key_buy_cnt = data.buy_cnt
	self.secret_key_score = data.rest_score

	for k, v in ipairs(data.line_achieve_info) do
		local ac_data = self.secret_key_line_achieve_data[v.awar_pos]
		if ac_data then
			ac_data.state = v.state
		end
	end

	for k, v in ipairs(data.line_award_info) do
		local aw_data = self.secret_key_line_award_data[v.awar_pos]
		if aw_data then
			aw_data.state = v.state
		end
	end
	if data.get_num then
		self.secret_key_num_pool_info[data.get_num].state = 1
	else
		for k, v in ipairs(self.secret_key_num_pool_info) do
			if data.got_number_info[k] then
				v.state = 1
			end
		end
	end

	for k, v in pairs(self.secret_key_event_data) do
		if v.eventType == 1 and data.today_active_degree >= v.eventNum then
			v.state = 1
		elseif v.eventType == 2 and data.cost_money >= v.eventNum then
			v.state = 1
		end
	end
end

function OperateActivityData:IsSecretKeyTreasureNeedRemind()
	if not self.secret_key_treasure_cfg 
		or not self.operate_acts_configs[OPERATE_ACTIVITY_ID.SECRET_KEY_TREASURE] or 
		self:IsSecretKeyAllNumFetched() then 
		return false 
	end
	return self.secret_key_used_cnt < self.secret_key_get_cnt
end

function OperateActivityData:IsSecretKeyAllNumFetched()
	for k, v in ipairs(self.secret_key_num_pool_info) do
		if v.state == 0 then
			return false
		end
	end

	return true
end

function OperateActivityData:ClearSecretKeyTreasureData()
	self.secret_key_can_buy = 0 				-- 是否可购买
	self.secret_key_cur_num = 0 				-- 当前数字
	self.secret_key_active_degree = 0 			-- 活跃度值
	self.secret_key_cost_money = 0 				-- 已花费的钱
	self.secret_key_get_cnt = 0 				-- 获得次数
	self.secret_key_used_cnt = 0 				-- 已使用次数
	self.secret_key_buy_cnt = 0 				-- 已购买次数
	self.secret_key_score = 0 					-- 积分
	self.secret_key_num_pool_info = nil
	self.secret_key_treasure_cfg = nil
	self.secret_key_line_award_data = nil
	self.secret_key_line_achieve_data = nil

end

-- -------------------------秘钥宝藏end-------------------------------

--====================充值送礼begin====================
function OperateActivityData:InitChargeGiveGiftCfgData()
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.CHARGE_GIVE_GIFT] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.CHARGE_GIVE_GIFT].config
	self.charge_give_show_awards_list = {}			-- 每日展示奖励列表
	self.charge_give_all_fetch_state_list = {}		-- 每日奖励领取状态列表
	if cfg then
		local job = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
		self.charge_give_gift_req_num = cfg.rechargeGoldNum
		local all_awards_cfg = cfg.dailyReward
		if all_awards_cfg then
			for k, v in ipairs(all_awards_cfg) do
				local one_day_awards = {special_award = nil , normal_awards = {}}
				for k_2, v_2 in ipairs(v) do
					if v_2.is_special then
						one_day_awards.special_award = {item_id = v_2.id, num = v_2.count, is_bind = v_2.bind}
					else
						if (nil == v_2.job and nil == v_2.sex) or (v_2.job and v_2.sex and v_2.job == job and v_2.sex == sex) or
							(v_2.job and v_2.sex == nil and v_2.job == job) or (v_2.job == nil and v_2.sex and v_2.sex == sex) then
							local item_info = {
												item_id = v_2.type == 0 and v_2.id or ItemData.Instance:GetVirtualItemId(v_2.type), 
												num = v_2.count, is_bind = v_2.bind,
											}
							table.insert(one_day_awards.normal_awards, item_info)
						end
					end
				end
				local state_info = {state = 0}
				self.charge_give_all_fetch_state_list[k] = state_info
				self.charge_give_show_awards_list[k] = one_day_awards
			end
		end
	end
end

function OperateActivityData:SetChargeGiveGiftData(data)
	-- print("充值送礼--------", data.opened_day, data.standard_flag)
	if self.charge_give_all_fetch_state_list then
		for k, v in ipairs(self.charge_give_all_fetch_state_list) do
			local tmp = data.fetch_state_t[k]
			if tmp then
				v.state = tmp.state
			end
		end
	end
	if self.charge_give_gift_open_info.standard_flag ~= data.standard_flag then
		self.charge_give_gift_open_info.standard_flag = data.standard_flag
	end
	if self.charge_give_gift_open_info.opened_day ~= data.opened_day then
		self.charge_give_gift_open_info.opened_day = data.opened_day
	end
	if self.charge_give_gift_open_info.my_money ~= data.my_money then
		self.charge_give_gift_open_info.my_money = data.my_money
	end
end

function OperateActivityData:UpdateChargeGiveGiftData(data)
	self.charge_give_gift_open_info.opened_day = data.opened_day
	if self.charge_give_all_fetch_state_list then
		for k, v in ipairs(self.charge_give_all_fetch_state_list) do
			if k == data.opened_day then
				v.state = data.state
				break
			end
		end
	end
end

function OperateActivityData:IsChargeGiveGiftNeedRemind()
	if not self.charge_give_all_fetch_state_list then return false end
	for k, v in ipairs(self.charge_give_all_fetch_state_list) do
		if v.state == 1 then
			return true
		end
	end
	return false
end

function OperateActivityData:ClearChargeGiveGiftData()

end

function OperateActivityData:GetChargeGiveOneDayAwards(index)
	return self.charge_give_show_awards_list[index]
end

function OperateActivityData:GetChargeGiveAllFetchStateList()
	return self.charge_give_all_fetch_state_list or {}
end

function OperateActivityData:GetChargeGiveOpenInfo()
	return self.charge_give_gift_open_info
end

--====================充值送礼end====================


--====================消费送礼begin====================
function OperateActivityData:InitConsumeGiveGiftCfgData()
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.CONSUME_GIVE_GIFT] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.CONSUME_GIVE_GIFT].config
	self.consume_give_show_awards_list = {}			-- 每日展示奖励列表
	self.consume_give_all_fetch_state_list = {}		-- 每日奖励领取状态列表
	if cfg then
		local job = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
		self.charge_give_gift_req_num = cfg.rechargeGoldNum
		local all_awards_cfg = cfg.dailyReward
		if all_awards_cfg then
			for k, v in ipairs(all_awards_cfg) do
				local one_day_awards = {special_award = nil , normal_awards = {}}
				for k_2, v_2 in ipairs(v) do
					if v_2.is_special then
						one_day_awards.special_award = {item_id = v_2.id, num = v_2.count, is_bind = v_2.bind}
					else
						if (nil == v_2.job and nil == v_2.sex) or (v_2.job and v_2.sex and v_2.job == job and v_2.sex == sex) or
							(v_2.job and v_2.sex == nil and v_2.job == job) or (v_2.job == nil and v_2.sex and v_2.sex == sex) then
							local item_info = {
												item_id = v_2.type == 0 and v_2.id or ItemData.Instance:GetVirtualItemId(v_2.type), 
												num = v_2.count, is_bind = v_2.bind,
											}
							table.insert(one_day_awards.normal_awards, item_info)
						end
					end
				end
				local state_info = {state = 0}
				self.consume_give_all_fetch_state_list[k] = state_info
				self.consume_give_show_awards_list[k] = one_day_awards
			end
		end
	end
end

function OperateActivityData:SetConsumeGiveGiftData(data)
	-- print("消费送礼--------", data.opened_day, data.standard_flag)
	if self.consume_give_all_fetch_state_list then
		for k, v in ipairs(self.consume_give_all_fetch_state_list) do
			local tmp = data.fetch_state_t[k]
			if tmp then
				v.state = tmp.state
			end
		end
	end
	if self.consume_give_gift_open_info.standard_flag ~= data.standard_flag then
		self.consume_give_gift_open_info.standard_flag = data.standard_flag
	end
	if self.consume_give_gift_open_info.opened_day ~= data.opened_day then
		self.consume_give_gift_open_info.opened_day = data.opened_day
	end
	if self.consume_give_gift_open_info.my_money ~= data.my_money then
		self.consume_give_gift_open_info.my_money = data.my_money
	end
end

function OperateActivityData:UpdateConsumeGiveGiftData(data)
	self.consume_give_gift_open_info.opened_day = data.opened_day
	if self.consume_give_all_fetch_state_list then
		for k, v in ipairs(self.consume_give_all_fetch_state_list) do
			if k == data.opened_day then
				v.state = data.state
				break
			end
		end
	end
end

function OperateActivityData:IsConsumeGiveGiftNeedRemind()
	if not self.consume_give_all_fetch_state_list then return false end
	for k, v in ipairs(self.consume_give_all_fetch_state_list) do
		if v.state == 1 then
			return true
		end
	end
	return false
end

function OperateActivityData:ClearConsumeGiveGiftData()

end

function OperateActivityData:GetConsumeGiveOneDayAwards(index)
	return self.consume_give_show_awards_list[index]
end

function OperateActivityData:GetConsumeGiveAllFetchStateList()
	return self.consume_give_all_fetch_state_list or {}
end

function OperateActivityData:GetConsumeGiveOpenInfo()
	return self.consume_give_gift_open_info
end

--====================消费送礼end====================


--====================寻宝10连抽送奖begin====================
function OperateActivityData:InitTenTimeExploreGiveData()
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.TEN_TIME_EXPLORE_GIVE] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.TEN_TIME_EXPLORE_GIVE].config
	self.ten_time_explore_cnt = 0			-- 10连抽次数
	self.ten_time_explore_unit = 1
	self.ten_time_explore_data = {}
	if cfg then
		self.ten_time_explore_unit = cfg.nCount
		for k, v in ipairs(cfg.Rewards) do
			local tmp = {desc = cfg.Describe[k] or "", awards = {}, state = 0, idx = k, need_cnt = cfg.Gold[k] / cfg.nCount,}
			tmp.awards = ItemData.AwardsToItems(v)
			table.insert(self.ten_time_explore_data, tmp)
		end
	end
end

function OperateActivityData:SetTenTimeExploreGiveData(data)
	-- print("寻宝10连抽送奖--------", data.opened_day, data.standard_flag)
	if self.ten_time_explore_data then
		self.ten_time_explore_cnt = data.count
		for k, v in ipairs(self.ten_time_explore_data) do
			local state = data.state_t[k]
			if state then
				v.state = state
			end
		end
	end
end

function OperateActivityData:UpdateTenTimeExploreGiveData(data)
	if self.ten_time_explore_data then
		for k, v in ipairs(self.ten_time_explore_data) do
			if k == data.idx then
				v.state = data.state
				break
			end
		end
	end
end

function OperateActivityData:IsTenTimeExploreGiveNeedRemind()
	if not self.ten_time_explore_data then return false end
	for k, v in ipairs(self.ten_time_explore_data) do
		if v.state == 1 then
			return true
		end
	end
	return false
end

function OperateActivityData:ClearTenTimeExploreGiveData()

end

function OperateActivityData:GetTenTimeExploreGiveData()
	return self.ten_time_explore_data or {}
end

function OperateActivityData:GetTenTimeExploreGiveCnt()
	return self.ten_time_explore_cnt
end

function OperateActivityData:GetTenTimeExploreGiveUnit()
	return self.ten_time_explore_unit
end

--====================寻宝10连抽送奖end====================

--===========提醒=============
function OperateActivityData:GetRemindNumByRemindName(remind_name)
	local remind_num = 0
	local act_id = OperateActivityData.RemindNameActIDMap[remind_name]		-- 与活动ID保持一致
	if  not self:CheckActIsOpen(act_id) then
	 	return 0
	end

	local cfg = self.operate_acts_configs[act_id]
	if nil == cfg then return 0 end
	local func = nil
	local is_sports_type = OperateActivityData.IsStandardSprotsRemindName(remind_name)
	if is_sports_type then
		func = OperateActivityData.RemindNameRemindFucNameMap["SportsTypeActs"]
	else
		func = OperateActivityData.RemindNameRemindFucNameMap[remind_name]
	end

	if func then
		if self[func] then
			if is_sports_type then
				remind_num = self[func](self, act_id) and 1 or 0
			else
				remind_num = self[func](self) and 1 or 0
			end
		end
	end
	self.remind_list[act_id] = remind_num > 0
	return  remind_num
end

function OperateActivityData.IsStandardSprotsRemindName(remind_name)
	-- 时段达标竞技
	if remind_name == RemindName.OpActExpSports or remind_name == RemindName.OpActBossSports or
	   remind_name == RemindName.OpActBloodSports or remind_name == RemindName.OpActShieldSports or
	   remind_name == RemindName.OpActDiamondSports or remind_name == RemindName.OpActSealBeadSports or
	   remind_name == RemindName.OpActInjectSports or remind_name == RemindName.OpActSwingSports or
	   remind_name == RemindName.OpActSoulStoneSports or
	--每日达标竞技
	   remind_name == RemindName.OpActDailyExpSports or remind_name == RemindName.OpActDailyBossSports or
	   remind_name == RemindName.OpActDailyBloodSports or remind_name == RemindName.OpActDailyShieldSports or
	   remind_name == RemindName.OpActDailyDiamondSports or  remind_name == RemindName.OpActDailySealBeadSports or
	   remind_name == RemindName.OpActDailyInjectSports or remind_name == RemindName.OpActDailySwingSports or 
	   remind_name == RemindName.OpActDailySoulStoneSports then

		return true
	end

	return false
end

function OperateActivityData:GetRemindList()
	return self.remind_list
end

--主界面是否显示运营活动icon图标
function OperateActivityData:IsMainuiActivityIconShow()
	local count = 0
	for k, v in ipairs(self.open_acts_list) do
		if OperateActivityData.IsCommonPanelShowAct(v.act_id) then
			if v.act_id ~= OPERATE_ACTIVITY_ID.CHARGE_GIVE_GIFT and v.act_id ~= OPERATE_ACTIVITY_ID.CONSUME_GIVE_GIFT then
				return true
			else
				if self:IsShowChargeConsumeGiveAct(v.act_id) then
					count = count + 1
				end
			end
		end
	end
	return count > 0
end

function OperateActivityData:SetFirstChargePaybackData(data)
	self.first_charge_payback_state = data.fetch_state
end

--主界面是否显示首充返利icon
function OperateActivityData:IsShowFirstChargePayback()
	if self.first_charge_payback_state and self.first_charge_payback_state == 2 then
		return false
	end
	for k, v in ipairs(self.open_acts_list) do
		if v.act_id == OPERATE_ACTIVITY_ID.FIRST_CHARGE_PAYBACK	then
			return true
		end
	end
	return false
end

--主界面是否显示新春活动icon
function OperateActivityData:IsShowSpringFestival()
	for k, v in ipairs(self.open_acts_list) do
		if OperateActivityData.IsSpringFestival(v.act_id) then
			return true
		end
	end
	return false
end
 
--主界面是否显示国庆活动icon
function OperateActivityData:IsShowNationalDayActIcon()
	for k, v in ipairs(self.open_acts_list) do
		if OperateActivityData.IsNationalDayAct(v.act_id) then
			return true
		end
	end
	return false
end