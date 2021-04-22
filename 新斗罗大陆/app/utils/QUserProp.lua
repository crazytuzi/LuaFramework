--
-- Author: wkwang
-- Date: 2014-11-12 10:08:45
-- 玩家属性类
--  *      "name":"xxxx",                                  // 玩家名称
--  *      "nickname":"xxxx",                              // 玩家昵称
--  *      "avatar":"xxxx",                                // 玩家头像
--  *      "title":"xxxx",                                 // 玩家称号
--  *      "exp":10,                                       // 战队经验
--  *      "totalRechargeToken":10,                        // 充值总数               
--  *      "level":10,                                     // 战队等级
--  *      "session":"...",                                // 本次登陆session id
--  *      "energyRefreshedAt",                            // 体力刷新时间
--  *      "skillTickets",                                 // 技能券
--  *      "skillTicketsRefreshedAt",                      // 技能券刷新时间
--  *      "money":10,                                     // 玩家金魂币数量
--  *      "energy":10,                                    // 玩家体力
--  *      "glyphsMoney":10,                               // 技能体技
--  *      "token":10,                                     // 玩家代币
--  *      "soulMoney":10,                                 // 英灵币(碎片)
--  *	   "crystalPiece":10							   // 水晶币
--  *      "trainMoney":10,                                // 培养石
--  *      "towerMoney":10,                                // 大魂师币
--  *      "enchantScore":10,                              // 觉醒宝箱积分
--  *      "userConsortia":table                           // 玩家宗门信息
--  *      "UserConsortiaSkill":table                      // 玩家宗门技能信息
--  *	   "intrusion_token_refresh_at"					   // 入侵令牌刷新时间
--  *      "todayBuyIntrusionTokenCount"				   // 入侵令牌今日购买次数
--  *	   "defaultActorId"					   			   // 玩家展示魂师
--  * 	   "payIsSandbox"								   // 沙盒模式
--  * 	   "changeNicknameCount"						   // 玩家改名次数	
--  *
--  *      "todayMoneyBuyCount":0,                         // 今天金魂币购买次数
--  *      "todayEnergyBuyCount":0,                        // 今天体力购买次数
--  *      "todaySkillImprovedCount":0,                    // 今天技能升级多少次

--  *      "todayAdvancedDrawCount":0,                      // 今天在酒馆高级召唤次数
--  *      "todayRefreshShop501Count":0,                    // 今天刷新英灵商店次数
--  *      "todayEquipBreakthroughCount":0,                 // 今天突破装备次数
--  *      "todayHeroTrainCount":0,                        	// 今天培养魂师次数
--  *      "todayHeroExpCount":0,                    		// 今天对任意魂师使用经验物品
--  *      "todayRefreshShopCount":0,                       // 今天刷新普通商店次数
--  *      "todayTowerFightCount":0,                        // 今天魂师大赛战斗次数
--  *      "todayThunderFightCount":0,                    	// 今天雷电王座战斗次数
--  *      "todayAdvancedBreakthroughCount":0,              // 今天突破饰品次数
--  *	   "todayIntrusionShareCount":0, 					// 今天要塞分享次数
--	*      "todayIntrusionBoxOpenCount":0,					//今天要塞宝箱开启次数
--	*      "todayMaritimeShipCount":0,						//海商运送次数 
--	*      "todayMonopolyMoveCount":0,						//今天大富翁掷骰子次数
--  *
--  *      "todayLuckyDrawAnyCount":5,                     // 今天任意抽奖次数
--  *      "todayLuckyDrawFreeCount":6,                    // 今天免费宝箱次数
--  *      "totalLuckyDrawAdvanceCount":100                // 高级抽奖总次数
--  *      "totalLuckyDrawNormalCount":100                	// 普通抽奖总次数
--  *      "luckyDrawRefreshedAt":1231231,                 // 普通宝箱最后刷新时间
--  *      "luckyDrawAdvanceRefreshedAt":12312,            // 黄金宝箱最后刷新时间
 -- *      "luckyDrawDirectionalFreeBuyAt":12312,           // 豪华召唤最后刷新时间
--  *      "luckyDrawDirectionalIntegral":12312,            // 豪华召唤星魂积分
--  *      "luckyDrawDirectionalBuyCount":12312,            // 今天豪华召唤次数
--- *      "myselfLuckyDrawDirectionalRank",                 // 今天豪华排名
--  *      "dailyTeamLevel":12312,            		        // 每天凌晨5点用户的等级
--  *      "declaration":12312,            		        	// 个性宣言

 -- *      "addupDungeonPassCount":123                     // 累计普通副本通关次数
 -- *      "addupDungeonElitePassCount":123                // 累计精英副本通关次数
 -- *      "addupLuckydrawCount":123                       // 累计普通宝箱次数
 -- *      "addupLuckydrawAdvanceCount":123                // 累计黄金宝箱次数
 -- *      "addupPurchasedToken":123                       // 累计购买了代币数
 -- *      "addupBuyEnergyCount":123                       // 累计购买体力次数
 -- *      "addupBuyMoneyCount":123                        // 累计购买金魂币次数 
 -- *      "towerAvatarAccountFloor":123                   // 上次结算时间魂师大赛排名 
 -- *      "enchantFreeBuyAt":123                          // 上一次免费购买觉醒宝箱的时间
 -- *      "zuoqiFreeSummonAt":123							// 上一次免费购买暗器宝箱的时间
 -- *      "collectedHeros":123                         	// 玩家历史拥有的魂师
 -- *      "collectedZuoqis":123                         	// 玩家历史拥有的暗器
 -- *      "gloryCompetitionWeekRank":123                  // 玩家上周荣耀跨服战排名
 -- *      "nightmareDungeonPassCount":123                  // 噩梦副本总通关数

 -- *      "fomation":123                        		   // 副本战队信息
 -- *      "gloryCompetitionTopRank"                       //魂师大赛争霸赛 最高排名
 -- *      "loginDaysCount"                                //累计登录天数 
 -- *      "stormTopRank"                                   //风暴斗魂场 最高排名 
 -- *      "userTelephoneInfo"                                   //玩家手机绑定信息
 -- *      "godArmMoney"									//神器币
 -- *      "enchantLuckyDrawCount"									//觉醒宝箱抽取次数
 
--
local QBaseModel = import("..models.QBaseModel")
local QUserProp = class("QUserProp",QBaseModel)
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QUIViewController = import("..ui.QUIViewController")
local QNotificationCenter = import("..controllers.QNotificationCenter")
local QQuickWay = import("..utils.QQuickWay")
local QVIPUtil = import("..utils.QVIPUtil")
local QLoginHistory = import("..utils.QLoginHistory")

QUserProp.EVENT_USER_PROP_CHANGE = "EVENT_USER_PROP_CHANGE"
QUserProp.EVENT_SPECIAL_TIME_REFRESH = "EVENT_SPECIAL_TIME_REFRESH"
QUserProp.CHEST_IS_FREE = "CHEST_IS_FREE"
QUserProp.EVENT_TIME_REFRESH = "EVENT_TIME_REFRESH" --整点时间刷新
QUserProp.EVENT_GLYPH_LEVEL_UP = "EVENT_GLYPH_LEVEL_UP" --体技升级
QUserProp.EVENT_NEW_GLYPH = "EVENT_NEW_GLYPH" --解锁新体技
QUserProp.EVNET_CONSORTIA_CHANGE = "EVNET_CONSORTIA_CHANGE" --宗门信息更新

function QUserProp:ctor()
	QUserProp.super.ctor(self)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
	--初始化属性值
	self.props = {}
	table.insert(self.props, "name") --玩家名称
	table.insert(self.props, "userId") --玩家ID
	table.insert(self.props, "nickname") --玩家昵称
	table.insert(self.props, "avatar") --玩家头像
	table.insert(self.props, "championCount") --希尔维斯巅峰赛冠军次数
	table.insert(self.props, "soulTrial") --玩家战队称号
	table.insert(self.props, "title") --玩家头像
	table.insert(self.props, "vip") --vip等级
  	table.insert(self.props, "totalRechargeToken") --充值总数
  	table.insert(self.props, "newTotalRecharge") --充值RMB总金额
  	table.insert(self.props, "exp") --战队经验
	table.insert(self.props, "level") --战队等级
	table.insert(self.props, "isLoginFrist") --标志是否曾经登录过，如果登录过后面的重连则做区服的验证 看不懂的话找徐卿
	table.insert(self.props, "session") --本次登陆session id
	table.insert(self.props, "energyRefreshedAt") --体力刷新时间
	table.insert(self.props, "skillTickets") --技能券
	table.insert(self.props, "skillTicketsRefreshedAt") --技能券刷新时间
	table.insert(self.props, "skillTicketsReset") --技能券购买次数
	table.insert(self.props, "energy") --玩家体力 
	table.insert(self.props, "userCreatedAt") --玩家创建时间
	table.insert(self.props, "arenaRank") --玩家斗魂场排名
	table.insert(self.props, "fundStatus") --基金状态:0未买，1已买
	table.insert(self.props, "fundBuyCount") --购买开服基金人数
	table.insert(self.props, "userConsortia") --玩家宗门信息
	table.insert(self.props, "userConsortiaSkill") --玩家宗门技能信息
	table.insert(self.props, "defaultActorId") --玩家展示魂师
	table.insert(self.props, "defaultSkinId") --玩家展示魂师皮肤
	table.insert(self.props, "heroMaxLevel") --魂师的最高等级 随着战队等级更新
	table.insert(self.props, "openServerTime") --开服时间
	table.insert(self.props, "realOpenServerTime") --开服时间精确到具体时间点
	table.insert(self.props, "myGameAreaName") --区服名称
	table.insert(self.props, "isBuyFirstDraw") --是不是首抽
	table.insert(self.props, "payIsSandbox") -- 沙盒模式
	table.insert(self.props, "userType") -- 用户账号类型（0普通 1GM 2指导员 3福利号）
	table.insert(self.props, "changeNicknameCount") -- 用户改名次数
	table.insert(self.props, "maxHisTopnForce") --用户的历史最高战力
	table.insert(self.props, "localForce") --本地保存战力
	table.insert(self.props, "cacheForce") --本地缓存战力，用于酒馆类暂时不显示战力变化QUIDialogFloatForce
	table.insert(self.props, "celebrityHallCurRank") --当前名人堂排名 -server更新

	table.insert(self.props, "todayMoneyBuyCount") --今天金魂币购买次数 -server更新
	table.insert(self.props, "todayEnergyBuyCount") --今天体力购买次数 -server更新
	table.insert(self.props, "todayMoneyBuyLastTime") --今天金魂币购买最后一次时间 -本地更新
	table.insert(self.props, "todaySkillImprovedCount") --今天技能升级多少次 -本地更新
	table.insert(self.props, "dungeonSeaBuyCount") --今天藏宝海湾购买次数 -server更新
	table.insert(self.props, "dungeonBarBuyCount") --今天黑铁酒吧购买次数 -server更新
	table.insert(self.props, "dungeonStrengthBuyCount") --今天力量试炼购买次数 -server更新
	table.insert(self.props, "dungeonSapientialBuyCount") --今天智慧试炼购买次数 -server更新
	table.insert(self.props, "todaydungeonSeaBuyLastTime") --今天藏宝海湾购买最后一次时间 -本地更新
	table.insert(self.props, "todaydungeonBarBuyLastTime") --今天黑铁酒吧购买最后一次时间 -本地更新
	table.insert(self.props, "todaydungeonStrengthBuyLastTime") --今天力量试炼购买最后一次时间 -本地更新
	table.insert(self.props, "todaydungeonIntellectBuyLastTime") --今天智慧试炼购买最后一次时间 -本地更新
	table.insert(self.props, "todayBuyIntrusionTokenCount") -- 入侵令牌今日购买次数 -本地更新
	table.insert(self.props, "todayTokenConsume") --今天消耗符石的次数 -本地更新
	table.insert(self.props, "todayRecharge") --今天累积充值额度 --本地更新
	table.insert(self.props, "todaymealTimes") --今天累积领取餐点 --本地更新


	table.insert(self.props, "todayAdvancedDrawCount") --今天在酒馆高级召唤次数 -本地更新
	table.insert(self.props, "todayRefreshShop501Count") --今天刷新英灵商店次数 -本地更新
	table.insert(self.props, "todayEquipBreakthroughCount") --今天突破装备次数 -本地更新
	table.insert(self.props, "todayHeroTrainCount") --今天培养魂师次数 -本地更新
	table.insert(self.props, "todayHeroExpCount") --今天对任意魂师使用经验物品 -本地更新
	table.insert(self.props, "todayRefreshShopCount") --今天刷新普通商店次数 -本地更新
	table.insert(self.props, "todayTowerFightCount") --今天魂师大赛战斗次数 -本地更新
	table.insert(self.props, "todayThunderFightCount") --今天雷电王座战斗次数 -本地更新
	table.insert(self.props, "todayAdvancedBreakthroughCount") --今天突破饰品次数 -本地更新
	table.insert(self.props, "todayIntrusionShareCount") --今天要塞分享次数
	table.insert(self.props, "todaySendEnergyCount") --今天要塞分享次数
	table.insert(self.props, "todayIntrusionBoxOpenCount") --今天要塞宝箱开启次数
	table.insert(self.props, "todayBattlefieldFightCount") --今日海神岛挑战次数 
	table.insert(self.props, "todaySilverMineOccupyCount") --今日魂兽森林狩猎次数 
	table.insert(self.props, "todayGlyphImproveCount") --今日体技升级次数

	table.insert(self.props, "todayLuckyDrawAnyCount") --今天任意抽奖次数 -本地更新
	table.insert(self.props, "todayLuckyDrawFreeCount") --今天免费宝箱次数 -server更新
	table.insert(self.props, "totalLuckyDrawAdvanceCount") --高级抽奖总次数 -server更新
	table.insert(self.props, "totalLuckyDrawNormalCount") --普通抽奖总次数 -server更新
	table.insert(self.props, "luckyDrawRefreshedAt") --普通宝箱最后刷新时间 -server更新
	table.insert(self.props, "luckyDrawAdvanceRefreshedAt") --黄金宝箱最后刷新时间 -server更新
	table.insert(self.props, "luckyAdvanceHalfPriceRefreshAt") --高级抽奖半价刷新时间 -server更新
	table.insert(self.props, "luckydrawAdvanceTotalScore") --高级抽奖总积分 -server更新
	table.insert(self.props, "luckydrawAdvanceRewardRow") --高级抽奖轮次 -server更新
	table.insert(self.props, "luckydrawAdvanceRewardGotBoxs") --高级抽奖积分已领取 -server更新
	-- table.insert(self.props, "luckyDrawDirectionalFreeBuyAt") --豪华召唤最后刷新时间 -server更新
	-- table.insert(self.props, "luckyDrawDirectionalIntegral") --豪华召唤星魂积分 -server更新
	-- table.insert(self.props, "luckyDrawDirectionalBuyCount") --今天豪华召唤次数 -server更新
	-- table.insert(self.props, "myselfLuckyDrawDirectionalRank") -- 豪华召唤我的排名
	table.insert(self.props, "sunwarLastFightAt") --太阳井最后一次战斗时间 -本地更新
	table.insert(self.props, "societyDungeonLastFightAt") --宗门副本最后一次战斗时间 -本地更新
	table.insert(self.props, "intrusion_token_refresh_at") --入侵令牌刷新时间 -本地更新

	table.insert(self.props, "addupDungeonPassCount") --累计普通副本通关次数 -本地更新
	table.insert(self.props, "addupDungeonElitePassCount") --累计精英副本通关次数 -本地更新
	table.insert(self.props, "addupLuckydrawCount") --累计普通宝箱次数 -本地更新
	table.insert(self.props, "addupLuckydrawAdvanceCount") --累计黄金宝箱次数 -本地更新
	table.insert(self.props, "addupPurchasedToken") --累计购买了代币数 -server更新
	table.insert(self.props, "addupBuyEnergyCount") --累计购买体力次数 -本地更新
	table.insert(self.props, "addupBuyMoneyCount") --累计购买金魂币次数 -本地更新
	table.insert(self.props, "thunderHistoryMaxStar") --雷电王座最高星数 -本地更新	
	table.insert(self.props, "towerMaxFloor") --挑战魂师大赛 -本地更新	
	table.insert(self.props, "thunderFightCount") --挑战雷电王座胜利次数 -本地更新		
	table.insert(self.props, "towerAvatarAccountFloor") --上次结算时间魂师大赛排名 -server更新
	table.insert(self.props, "enchantFreeBuyAt") --上一次免费购买觉醒宝箱的时间 -server更新
	table.insert(self.props, "zuoqiFreeSummonAt") --上一次免费购买觉醒宝箱的时间 -server更新
	table.insert(self.props, "magicHerbFreeSummonAt") --上一次免费购买仙品宝箱的时间 -server更新
	table.insert(self.props, "gloryCompetitionWeekRank") -- 玩家上周荣耀跨服战排名 -server更新
	table.insert(self.props, "nightmareDungeonPassCount") -- 噩梦副本总通关数 -server更新
	table.insert(self.props, "todayNightmareDungeonFightCount") -- 噩梦副本今日通关数 -server更新
	table.insert(self.props, "collectedHeros") -- 玩家历史拥有的魂师 -本地更新 
	table.insert(self.props, "collectedZuoqis") -- 玩家历史拥有的暗器 -本地更新 
	table.insert(self.props, "todayMaritimeShipCount") -- 海商运送次数 -server更新 
	table.insert(self.props, "todayMetalCityFightCount") -- 金属之城每日战斗次数 -server更新
	table.insert(self.props, "totalMetalCityFightCount") -- 金属之城总战斗次数 -server更新
	table.insert(self.props, "todayMonopolyMoveCount") -- 大富翁掷骰子次数 -server更新

	table.insert(self.props, "allActivityDungeonFightCount") --活动试炼战斗胜利次数 -本地更新	
	table.insert(self.props, "allSunwellMoney") --累计获得决战太阳井币 -本地更新	
	table.insert(self.props, "allConsortiaMoney") --宗门累计获得宗门币 -本地更新	
	table.insert(self.props, "allSilvermineMoney") --累计获得银魂兽区币 -本地更新	
	table.insert(self.props, "allMoney") --金魂币累计 -本地更新	
	table.insert(self.props, "useToken") --钻石累计消耗 -后台更新（推送）	
	table.insert(self.props, "getToken") --钻石充值累计获取 -后台更新（推送）
	table.insert(self.props, "giftToken") --钻石赠送累计 -后台更新（推送）
	table.insert(self.props, "allDragonWarMoney") -- 龙战币 -server更新

	table.insert(self.props, "todayActivity1_1Count") --今天活动副本1 打斗次数 -server更新
	table.insert(self.props, "todayActivity2_1Count") --今天活动副本2 打斗次数 -server更新
	table.insert(self.props, "todayActivity3_1Count") --今天活动副本1 打斗次数 -server更新
	table.insert(self.props, "todayActivity4_1Count") --今天活动副本2 打斗次数 -server更新

	table.insert(self.props, "todayArenaFightCount") --斗魂场今日战斗次数 -本地更新
	table.insert(self.props, "addupArenaFightCount") --斗魂场总共战斗次数 -本地更新
	table.insert(self.props, "todayStormFightCount") --风暴斗魂场今日战斗次数 -本地更新
	table.insert(self.props, "todaySotoTeamFightCount") --云顶之战今日战斗次数 -本地更新
	table.insert(self.props, "totalSotoTeamFightCount") --云顶之战总的战斗次数 -本地更新
	table.insert(self.props, "sotoTeamTopRank") --云顶之战最高排名 -本地更新
	
	table.insert(self.props, "arenaTopRank") --斗魂场最高排名 -server更新
	table.insert(self.props, "todayEquipEnchantCount") --今天装备觉醒次数 -本地更新
	table.insert(self.props, "todayEquipEnhanceCount") --今天装备强化次数 -本地更新
	table.insert(self.props, "todayAdvancedEnhanceCount") --今天饰品强化次数 -本地更新
	table.insert(self.props, "todayArenaWorshipCount") --今天斗魂场膜拜次数 -本地更新
	table.insert(self.props, "todayWelfareCount")	--福利副本今天攻打次数 --本地更新
	table.insert(self.props, "dailyTeamLevel")	--每天凌晨5点用户的等级 --本地更新
	table.insert(self.props, "dailyTaskRewardInfo")	--每日任务积分奖励领取进度 --server更新
	table.insert(self.props, "dailyTaskRewardIntegral")	--每日任务积分 --server更新

	table.insert(self.props, "declaration") --个性宣言 
	table.insert(self.props, "calnivalPoints")	--嘉年华七日活动积分 --server更新
	table.insert(self.props, "gotCalnivalPrizeIds")	--嘉年华七日已领取积分奖励 --server更新
	table.insert(self.props, "celebration_points")	--嘉年华十四日活动积分 --server更新
	table.insert(self.props, "gotCelebrationPrizeIds")	--嘉年华十四日已领取积分奖励 --server更新
	table.insert(self.props, "gotEnterRewards")	--七日登录奖励 --server更新
	table.insert(self.props, "handBookCommentCount") -- 魂师图鉴今日评论的次数 -server更新
	
	table.insert(self.props, "gotCommonCalnivalPrizeIds") --对应7日嘉年华已领取奖励 普通
    table.insert(self.props, "gotCommonCelebrationPrizeIds") --对应半月庆典已领取奖励 普通 
    table.insert(self.props, "gotSpecialCalnivalPrizeIds") --对应7日嘉年华已领取奖励 特权 
    table.insert(self.props, "gotSpecialCelebrationPrizeIds") --对应半月庆典已领取奖励 特权 
    table.insert(self.props, "calnivalPrizeIsActive") --嘉年华充值是否激活 
    table.insert(self.props, "celebrationPrizeIsActive") --半月庆典充值是否激活

	table.insert(self.props, "mobileAuth") --手机是否绑定
	table.insert(self.props, "mobileAward") --手机认证奖励是否领取
	table.insert(self.props, "wechatAward") --微信是否认证

	table.insert(self.props, "archaeologyInfo") --考古学信息
	table.insert(self.props, "ArchaeologyId") --考古学进度ID

	table.insert(self.props, "fomation") --副本战队信息

	table.insert(self.props, "gloryCompetitionTopRank")
	table.insert(self.props, "loginDaysCount")
	table.insert(self.props, "stormTopRank")
	table.insert(self.props, "heroSkins")   --英雄皮肤列表

	table.insert(self.props, "refineMoney") -- 洗炼石
	table.insert(self.props, "isRechargeFeedbackOpen") -- 是否开启封测返利

	-- 下面是客户端自己添加的属性
	table.insert(self.props, "c_todayNormalPass") --今天普通关卡通关次数 -本地更新
	table.insert(self.props, "c_todayElitePass") --今天精英关卡通关次数 -本地更新
	table.insert(self.props, "c_allStarNormalPass") --普通副本累积星星 -本地更新
	table.insert(self.props, "c_allStarElitePass") --精英副本累积星星 -本地更新
	table.insert(self.props, "c_allStarCount") --累计星星数量 -本地更新
	table.insert(self.props, "c_useMoney") --累计消耗金魂币 -本地更新
	table.insert(self.props, "c_thunderResetCount") --雷电王座重置次数 -本地更新
	table.insert(self.props, "c_fortressFightCount") --要塞攻打次数 -本地更新
	table.insert(self.props, "c_towerFightCount") --魂师大赛挑战次数 -本地更新
	table.insert(self.props, "c_buyInvasionCount") --购买征讨令数量 -本地更新
	table.insert(self.props, "c_resetSoulShopCount") --英灵商店重置次数 -本地更新
	table.insert(self.props, "c_soulShopConsumeCount") --英灵商店购买次数 -本地更新
	table.insert(self.props, "c_systemRefreshTime") --统一的系统刷新时间
	table.insert(self.props, "c_specialRefreshTime") --特殊的系统刷新时间


	table.insert(self.props, "achievements") -- 已经完成的成就
	table.insert(self.props, "missedAchievements") -- 已经完成未领取奖励的成就
	table.insert(self.props, "addupDungeonWelfarePassCount") -- 累计史诗副本通关次数
	table.insert(self.props, "todayDragonWarFightCount") -- 今日巨龙之战参与次数
	table.insert(self.props, "todaySparFieldPassCount") -- 今日晶石场通关次数

	table.insert(self.props, "allToken") -- 累计符石
	table.insert(self.props, "advanceDrawHeroCount") -- 高级付费召唤魂师数量（影响第一次高级付费首抽）
	table.insert(self.props, "artifactFreeBuyAt") -- 武魂真身召唤最后免费购买时间

	table.insert(self.props, "activityForceCalculateDay") -- 战力比拼活动的结束时间
	table.insert(self.props, "unlockAvatarFlag") -- 活动解锁头像标记
	table.insert(self.props, "freeRedPacketFlag") -- 领取每日任务积分奖励时，是否得到了一次免费最小钻石红包发放次数
	table.insert(self.props, "heroCombinationCount") -- 宿命激活数
	table.insert(self.props, "heroCombinationRank") -- 宿命激活排名
	table.insert(self.props, "todayZuoqiSummonCount") -- 每日暗器宝箱购买次数
	table.insert(self.props, "todayFightClubCount")	--每日搏击俱乐部直升挑战次数 
	table.insert(self.props, "dungeonPassAwards")	--通关奖励领取记录 
	table.insert(self.props, "userTelephoneInfo")	--玩家手机绑定信息 
	table.insert(self.props, "isWarmBloodServer")	--是否热血服
	table.insert(self.props, "warmBloodVipCanExtend")	--是否热血服可继承VIP
	table.insert(self.props, "warmBloodVipGet")	--是否热血服已领取 
	table.insert(self.props, "soulGuideLevel")	--魂导科技等级
	table.insert(self.props, "serverMergeAt") --合服时间
	table.insert(self.props, "enchantLuckyDrawCount") --合服时间
	table.insert(self.props, "todayChatCount") -- 今日发言次数


	table.insert(self.props, "todayWorldBossFightCount") -- 今日魔鲸累积攻打次数
	table.insert(self.props, "todayWorldBossBuyCount") -- 今日魔鲸购买攻打次数
	table.insert(self.props, "todayUnionPlunderFightCount") -- 今日极北之地攻打次数
	table.insert(self.props, "todayUnionPlunderBuyCount") -- 今日极北之地购买攻打次数
	table.insert(self.props, "todayConsortiaWarFightCount") -- 今日宗门战攻打次数
	table.insert(self.props, "todayConsortiaWarDestoryFlagCount") -- 今日宗门战摧毁旗帜次数
	table.insert(self.props, "todayMockBattleTurnCount") -- 今日模拟赛开启轮次次数
	table.insert(self.props, "todayMockBattleFightCount") -- 今日模拟赛战斗次数
	table.insert(self.props, "todayMockBattleShopCount") -- 今日模拟赛商店购买次数

	table.insert(self.props, "todaySanctuarySignUpCount") -- 今日全大陆精英赛报名次数
	table.insert(self.props, "todaySanctuaryFightCount") -- 今日全大陆精英赛战斗次数
	table.insert(self.props, "todaySanctuaryBetCount") -- 今日全大陆精英赛投注次数
	table.insert(self.props, "todaySanctuaryShopCount") -- 今日全大陆精英赛商店购买次数

	table.insert(self.props, "todayTotemChallengeFightCount") -- 今日圣柱挑战战斗次数
	table.insert(self.props, "todayTotemChallengeChapterCount") -- 今日圣柱挑战章节通关次数
	table.insert(self.props, "todayTotemChallengeShopCount") -- 今日圣柱挑战商店购买次数

	table.insert(self.props, "todayBlackFightCount")	--	今日传灵塔战斗胜利次数
	table.insert(self.props, "needShowThemeFormalPicture")	-- 主题曲正式活动弹脸通知
	table.insert(self.props, "todaySoulTowerFightCount")	--	今日升灵台战斗胜利次数

	table.insert(self.props, "todayOfferRewardCount")	--	今日魂师派遣任务次数
	table.insert(self.props, "todaySilvesArenaChallengeFightCount")	--	今日西尔维斯战场挑战次数
	table.insert(self.props, "todayShareCount")	--	分享次数
	table.insert(self.props, "todaySilvesArenaPeakStakeCount")	--	希尔维斯押注

	table.insert(self.props, "receivedCdk") --是否领取过应用宝霸权活动ckd奖励
	table.insert(self.props, "monthCardSupplementResponse") --月卡补领信息


	table.insert(self.props, "todayMetalAbyssFightCount")	--	金属深渊战斗


	self.useToken = 0
	self.getToken = 0
	self.giftToken = 0
	self.c_useMoney = 0
	self.c_thunderResetCount = 0
	self.c_fortressFightCount = 0
	self.c_towerFightCount = 0
	self.c_buyInvasionCount = 0
	self.c_resetSoulShopCount = 0
	self.c_soulShopConsumeCount = 0
	self.c_systemRefreshTime = 0
	self.c_specialRefreshTime = 0
	self.todayTokenConsume = 0

	self.currentLoginTime = 0     --本次登录时间

	self._timeProps = {}
end

function QUserProp:didappear()
	self._remoteProxy = cc.EventProxy.new(remote)
	self._remoteProxy:addEventListener(remote.TIME_UPDATE_EVENT, handler(self, self.timeUpdateHandler))

	-- self._markProxy = cc.EventProxy.new(remote.mark)
	-- self._markProxy:addEventListener(remote.mark.EVENT_UPDATE, handler(self, self.markUpdateHandler))

    QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.VIP_RECHARGED, self.rechargeHandler, self)

	--插入钱包
	local wallet = QStaticDatabase:sharedDatabase():getResource()
	for _,wallet in pairs(wallet) do
		table.insert(self.props, wallet.name) --玩家斗魂场排名
		self[wallet.name] = nil
	end

	local config = QStaticDatabase:sharedDatabase():getConfiguration()
	self.c_systemRefreshTime = tonumber(config["SYSTEM_RESET_TIME"].value) or 5
	self.c_specialRefreshTime = tonumber(config["SYSTEM_RESET_TIME_SPECIAL"].value) or 21

	-- self:updateTime(q.serverTime())
	self:updateSpecialTime(q.serverTime())
end

function QUserProp:disappear()
	if self._timeRefreshHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeRefreshHandler)
		self._timeRefreshHandler = nil
	end
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
	if self._remoteProxy ~= nil then
		self._remoteProxy:removeAllEventListeners()
		self._remoteProxy = nil
	end
	if self._markProxy ~= nil then
		self._markProxy:removeAllEventListeners()
		self._markProxy = nil
	end
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.VIP_RECHARGED, self.rechargeHandler, self)
end

function QUserProp:clone()
	local userProp = {}
	for _,propName in pairs(self.props) do
		userProp[propName] = self[propName]
	end
	return userProp
end

--更新属性数据
function QUserProp:update(data, ispatch, isprint)
	local isUpdate = false
	local energyIsUpdate = false
	local resource = QStaticDatabase.sharedDatabase():getResource()
	for _,propName in pairs(self.props) do
		if data[propName] ~= nil and self[propName] ~= data[propName] then
			isUpdate = true
			self:updateBeforeHandler(propName, data[propName])
			self[propName] = data[propName]
			self:updateAfterHandler(propName, data[propName])
			for _, value in pairs( resource ) do
				if value.name == propName then
					if value.item then
						local tbl = {}
						table.insert(tbl, {type = value.item, count = data[propName]})
						remote.items:setItems(tbl)
					end
				end
			end
			if propName == "energy" then
				energyIsUpdate = true
			end
		end
	end
	if energyIsUpdate == true then
		self:timerForChange("energy", (self.energyRefreshedAt or 0)/1000, global.config.energy_refresh_interval, (self.energy or 0), global.config.max_energy)
	end
	if data.wallet ~= nil then
		isUpdate = true
		self:update(data.wallet, false)
	end

	if data.userConsortia then
		if data.userConsortia.consortiaId and data.userConsortia.consortiaId ~= "" then
			app.taskEvent:updateTaskEventProgress(app.taskEvent.UNION_STATE_EVENT, 1)
		end
		self:dispatchEvent({name = QUserProp.EVNET_CONSORTIA_CHANGE})
	end

    if data.dailyTask ~= nil then
   	 	self:update(data.dailyTask,false)
    end
    
    if data.userExtension ~= nil then
        self:update(data.userExtension,false)
    end

    if data.getLuckyDrawScorePrizeResponse ~= nil then
        self:update(data.getLuckyDrawScorePrizeResponse, true)
    end

	if isUpdate == true and ispatch ~= false then
		self:dispatchEvent({name = QUserProp.EVENT_USER_PROP_CHANGE})
		self:checkLuckyDrawFree()
		self:checkLoginHistory(data)
	end
	return isUpdate
end

function QUserProp:checkLoginHistory(data)
	if data.level or data.avatar or data.nickname then
		QLoginHistory.changeLoginHistory(true)
	end
end

function QUserProp:updateBeforeHandler(propName, value)
	if propName == "money" then
		if self[propName] ~= nil and self[propName] > value then
			self.c_useMoney = self.c_useMoney + (self[propName] - value)
		end
		if self[propName] ~= nil and self[propName] < value then
			self["allMoney"] = self:getPropForKey("allMoney") + value - self[propName]
		end
	end
	if propName == "level" then
		if self[propName] ~= nil and self[propName] < value then
			app.unlock:checkUnlockByLevel(self[propName], value)
		end
	end
	if propName == "totalRechargeToken" then
		
	end
	if propName == "sunwellMoney" then
		if self[propName] ~= nil and self[propName] < value then
			self["allSunwellMoney"] = self:getPropForKey("allSunwellMoney") + value - self[propName]
		end
	end
	if propName == "consortiaMoney" then
		if self[propName] ~= nil and self[propName] < value then 
			self["allConsortiaMoney"] = self:getPropForKey("allConsortiaMoney") + value - self[propName]
		end
	end
	if propName == "silvermineMoney" then
		if self[propName] ~= nil and self[propName] < value then 
			self["allSilvermineMoney"] = self:getPropForKey("allSilvermineMoney") + value - self[propName]
		end
	end
	if propName == "dragonWarMoney" then
		if self[propName] ~= nil and self[propName] < value then 
			self["allDragonWarMoney"] = self:getPropForKey("allDragonWarMoney") + value - self[propName]
		end
	end
end

function QUserProp:updateAfterHandler(propName, value)
	if propName == "level" then
		self.heroMaxLevel = QStaticDatabase:sharedDatabase():getTeamConfigByTeamLevel(self.level).hero_limit or 1
	end
end

--获取自己的历史最高战力
function QUserProp:getHistoryTopForce()
	local force = remote.herosUtil:getMostHeroBattleForce()
	return math.max(self.maxHisTopnForce, force)
end

--[[
	后台推送符石变化更新
	增加分类型1充值、类型2赠送
]]
function QUserProp:updateTokenChange(response)
	if response.changeValue > 0 then
		if response.tokenType == 1 then
			self:update({getToken = (self:getPropForKey("getToken") + response.changeValue)})
		end
		if response.tokenType == 2 then
			self:update({giftToken = (self:getPropForKey("giftToken") + response.changeValue)})
		end
	else
		local tbl = {}
		tbl["useToken"] = self:getPropForKey("useToken") - response.changeValue
		tbl["todayTokenConsume"] = self:getPropForKey("todayTokenConsume") - response.changeValue
		remote.activity:updateLocalDataByType(200, math.abs(response.changeValue))

        app.taskEvent:updateTaskEventProgress(app.taskEvent.TKOEN_CONSUME_EVENT, math.abs(response.changeValue), false, false)
		
		self:update(tbl, true , true)
	end
end

-- function QUserProp:updateDailyTask(response)
-- 	-- body

-- end

--固定时间点刷新
function QUserProp:refreshTimeAtNormalTime()
	local updateTbl = {}
	printInfo("~~~~~~~~ refresh the game some count at 5:00 AM ~~~~~~~~~~")
	updateTbl["todayMoneyBuyCount"] = 0
	updateTbl["todayEnergyBuyCount"] = 0
	-- updateTbl["todayMoneyBuyLastTime"] = nil
	updateTbl["todaySkillImprovedCount"] = 0
	updateTbl["todaydungeonSeaBuyLastTime"] = 0
	updateTbl["todaydungeonBarBuyLastTime"] = 0
	updateTbl["todaydungeonStrengthBuyLastTime"] = 0
	updateTbl["todaydungeonIntellectBuyLastTime"] = 0
	updateTbl["todayBuyIntrusionTokenCount"] = 0
	updateTbl["todayTokenConsume"] = 0
	
	updateTbl["todayLuckyDrawAnyCount"] = 0
	-- updateTbl["luckyDrawDirectionalBuyCount"] = 0
	-- updateTbl["todayLuckyDrawFreeCount"] = 0
	-- updateTbl["totalLuckyDrawAdvanceCount"] = 0
	updateTbl["todayArenaFightCount"] = 0
	updateTbl["todayRefreshShopCount"] = 0
	updateTbl["todayStormFightCount"] = 0
	updateTbl["todayAdvancedDrawCount"] = 0
	updateTbl["todayRefreshShop501Count"] = 0
	updateTbl["todayEquipBreakthroughCount"] = 0
	updateTbl["todayHeroTrainCount"] = 0
	updateTbl["todayHeroExpCount"] = 0
	updateTbl["todayTowerFightCount"] = 0
	updateTbl["todayThunderFightCount"] = 0
	updateTbl["todayAdvancedBreakthroughCount"] = 0
	updateTbl["todayIntrusionShareCount"] = 0
	updateTbl["todaySendEnergyCount"] = 0
	updateTbl["todayIntrusionBoxOpenCount"] = 0
	updateTbl["todayBattlefieldFightCount"] = 0 
	updateTbl["todaySotoTeamFightCount"] = 0 
	
	updateTbl["todayEquipEnchantCount"] = 0
	updateTbl["todayEquipEnhanceCount"] = 0
	updateTbl["todayAdvancedEnhanceCount"] = 0
	updateTbl["todayArenaWorshipCount"] = 0
	updateTbl["todayWelfareCount"] = 0
	updateTbl["dailyTeamLevel"] = self.level
	
	updateTbl["todayActivity1_1Count"] = 0
	updateTbl["todayActivity2_1Count"] = 0
	updateTbl["todayActivity3_1Count"] = 0
	updateTbl["todayActivity4_1Count"] = 0

	updateTbl["dungeonSeaBuyCount"] = 0
	updateTbl["dungeonBarBuyCount"] = 0
	updateTbl["dungeonStrengthBuyCount"] = 0
	updateTbl["dungeonSapientialBuyCount"] = 0

	updateTbl["c_todayNormalPass"] = 0
	updateTbl["c_todayElitePass"] = 0

	updateTbl["dailyTaskRewardInfo"] = {}
	updateTbl["dailyTaskRewardIntegral"] = 0
	updateTbl["todayGlyphImproveCount"] = 0
	updateTbl["todayZuoqiSummonCount"] = 0
	updateTbl["todayMetalCityFightCount"] = 0
	updateTbl["todayMonopolyMoveCount"] = 0

	updateTbl["todayWorldBossFightCount"] = 0
	updateTbl["todayWorldBossBuyCount"] = 0
	updateTbl["todayUnionPlunderFightCount"] = 0
	updateTbl["todayUnionPlunderBuyCount"] = 0
	updateTbl["todayConsortiaWarFightCount"] = 0
	updateTbl["todayConsortiaWarDestoryFlagCount"] = 0
	updateTbl["todayMockBattleTurnCount"] = 0
	updateTbl["todayMockBattleFightCount"] = 0
	updateTbl["todayMockBattleShopCount"] = 0
	updateTbl["todaySanctuarySignUpCount"] = 0
	updateTbl["todaySanctuaryFightCount"] = 0
	updateTbl["todaySanctuaryBetCount"] = 0
	updateTbl["todaySanctuaryShopCount"] = 0
	updateTbl["todayTotemChallengeChapterCount"] = 0
	updateTbl["todayTotemChallengeFightCount"] = 0
	updateTbl["todayTotemChallengeShopCount"] = 0
	updateTbl["todaySilvesArenaChallengeFightCount"] = 0
	updateTbl["todayShareCount"] = 0
	updateTbl["todaySilvesArenaPeakStakeCount"] = 0

	updateTbl["todayBlackFightCount"] = 0
	updateTbl["todaySoulTowerFightCount"] = 0
	updateTbl["todayOfferRewardCount"] = 0
	updateTbl["todayMetalAbyssFightCount"] = 0
	
	--@Author: xurui
	-- 将雷电王座数据置空，下次进入雷电王座重新拉取数据
	remote.thunder.thunderInfo = nil
	-- 史诗副本通关次数置空
	remote.welfareInstance._passCount = 0
	remote.daily:updateComplete(nil, nil, 0)
	
	--重置斗魂场的积分信息
	remote.arena:setDailyScore(0)
	remote.arena:resetDailyRewardInfo()

	remote.sunWar:newDayUpdate()
	
	remote.union:newDayUpdate()

	remote.unionDragonWar:newDayUpdate()

	remote.stormArena:refreshDailyInfo()
	
	self:update(updateTbl)
end

function QUserProp:refreshTimeAtZeroTime()
	--充值活动中每日充值的记录
	remote.activity:resetDayCharge()
	remote.activity:updateLocalDataByType(502, 1)
	remote.items:updateOverdueItems()

	self:addPropNumForKey("loginDaysCount")
	self:update({todayRecharge = 0})
end

-- @Author: xurui   特殊时间点刷新
function QUserProp:updateSpecialTime(time)
	local specialrefreshTime = q.refreshTime(self.c_specialRefreshTime) + DAY
	if self._specialTimeRefreshHandler ~= nil then
		scheduler.unscheduleGlobal(self._specialTimeRefreshHandler)
		self._specialTimeRefreshHandler = nil
		self:refreshTimeAtSpecialTime()
		self:dispatchEvent({name = QUserProp.EVENT_SPECIAL_TIME_REFRESH})
	end

	self._specialTimeRefreshHandler = scheduler.performWithDelayGlobal(function()
			self:updateSpecialTime(q.serverTime())
		end,(specialrefreshTime - time))
end

function QUserProp:refreshTimeAtSpecialTime()
	-- 重置斗魂场刷新次数
	printInfo("~~~~~~~~ refresh the game some count at 21:00 PM ~~~~~~~~~~")
	remote.arena.arenaRefreshTimes = 0
end

--获取属性数据
function QUserProp:getPropForKey(key)
	return self[key] or 0
end

--属性数量自增
function QUserProp:addPropNumForKey(key, value)
	if value == nil then value = 1 end
	if self[key] == nil then
		self[key] = value
	else
		self[key] = self[key] + value
	end
	remote.task:addPropNumForKey(key, value) -- 每周任务需要记录以区分
	self:dispatchEvent({name = QUserProp.EVENT_USER_PROP_CHANGE})
end

--固定时间变化
function QUserProp:timerForChange(name, startTime, stepTime, value, totalValue)
	if self._timeProps == nil then
		self._timeProps = {}
	end
	if self._timeProps[name] == nil then
		self._timeProps[name] = {}
	else
		return 
	end

	local currTime = q.serverTime()
	local isAddProp = false
	while true do
		if value >= totalValue then
			break
		elseif (currTime - startTime) >= stepTime then
			startTime = startTime + stepTime
			value = value + 1
			isAddProp = true
		else
			startTime = currTime - startTime
			break
		end
	end
	if isAddProp then
		self:addPropNumForKey(name)
	end

	if value >= totalValue then
		if self._timeProps[name] ~= nil then
			self._timeProps[name] = nil
		end
	end

	if table.nums(self._timeProps) == 0 then
		if self._timeHandler ~= nil then
			scheduler.unscheduleGlobal(self._timeHandler)
			self._timeHandler = nil
		end
		return 
	end
	if self._timeProps[name] == nil then return end
	self._timeProps[name].startTime = startTime
	self._timeProps[name].stepTime = stepTime
	self._timeProps[name].value = value
	self._timeProps[name].totalValue = totalValue
	if self._timeHandler == nil then
		self._timeFun = function ()
			isAddProp = false
			for name,propVlaue in pairs(self._timeProps) do
				if propVlaue.value >= propVlaue.totalValue then
					self._timeProps[name] = nil
				elseif propVlaue.startTime < stepTime then
					propVlaue.startTime = propVlaue.startTime + 1
				else
					propVlaue.startTime = 0
					propVlaue.value = self:getPropForKey(name)
					isAddProp = true
				end
			end
			if isAddProp then
				self:addPropNumForKey(name)
			end
			if table.nums(self._timeProps) == 0 then
				scheduler.unscheduleGlobal(self._timeHandler)
				self._timeHandler = nil
			end
		end
		self._timeHandler = scheduler.scheduleGlobal(self._timeFun, 1)
	end
end

--检查战队是否升级
function QUserProp:checkTeamUp( isFromRobot, callback )
    self.haveTutorial = false
    if remote.oldUser ~= nil and remote.oldUser.level < remote.user.level then

    	app:sendGameEvent(GAME_EVENTS.GAME_EVENT_ROLE_LEVEL_UP, true)

    	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.EVENT_USER_TEAM_UP, oldLevel = remote.oldUser.level, newLevel = remote.user.level})
    	
        local options = {}
        local oldUser = remote.oldUser
        remote.oldUser = nil
        options["level"]=oldUser.level
        options["level_new"]=remote.user.level
		local database = QStaticDatabase:sharedDatabase()
        local energy = 0
        local award = 0
		for i = (oldUser.level),remote.user.level-1,1 do
        	local config = database:getTeamConfigByTeamLevel(i)
	        if config ~= nil then
	            energy = energy + config.energy
	            award = award + config.token
	        end
		end
		energy = remote.user.energy - energy
		if energy < 0 then energy = 0 end
        options["energy"]=energy
        options["energy_new"]=remote.user.energy
        options["award"]=award
        options["isFromRobot"]=isFromRobot
        options.callback = callback
        local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTeamUp", options = options}, {isPopCurrentDialog = false})

        self.haveTutorial = dialog:getTutorialStated()

        self:dealSomethingWhenTeamUp()
        return true
    end
    return false
end

-- 升到某些等级会
function QUserProp:dealSomethingWhenTeamUp()
	app.master:checkClearBlackRecord()
end

function QUserProp:getSkillTicketConfig()
	local skillCountConfig = QStaticDatabase:sharedDatabase():getTokenConsumeByType("skill")
	if skillCountConfig[self.skillTicketsReset + 1] == nil then
		return skillCountConfig[#skillCountConfig]
	else
		return skillCountConfig[self.skillTicketsReset + 1]
	end
end

--酒馆免费倒计时
function QUserProp:checkLuckyDrawFree()
  	self.silverIsFree = false
  	self.goldIsFree = false
  	self.orientIsFree = false
  	self.enchantIsFree = false
  	self.mountIsFree = false
  	self.magicHerbIsFree = false

  	--高级召唤
  	local config = QStaticDatabase:sharedDatabase():getConfiguration()
  	local currTime = q.serverTime()
  	local lastTime = (remote.user.luckyDrawAdvanceRefreshedAt or 0)/1000
	local halfTime = (remote.user.luckyAdvanceHalfPriceRefreshAt or 0)/1000

	self._goldLastRefreshTime = q.date("*t", q.serverTime())
	if self._goldLastRefreshTime.hour < 5 then
		lastTime = lastTime + DAY
		halfTime = halfTime + DAY
	end
	self._goldLastRefreshTime.hour = 5
	self._goldLastRefreshTime.min = 0
	self._goldLastRefreshTime.sec = 0
	self._goldLastRefreshTime = q.OSTime(self._goldLastRefreshTime)
    
  	if lastTime <= self._goldLastRefreshTime  then
    	self.goldIsFree = true
  	elseif halfTime <= self._goldLastRefreshTime then
  		local isShowTips = app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.GOLE_CHEST_HALF, 5)
		if isShowTips then
			self.goldIsFree = true
		end
	else
    	self:goldTimeHandler()
  	end 
  	
  	-- 普通召唤
  	self._silverCount = config.LUCKY_DRAW_COUNT.value or 0 -- 白银宝箱的次数
  	self._silverTime = config.LUCKY_DRAW_TIME.value or 0 -- 白银宝箱的CD时间

  	self._freeSilverCount = remote.user.todayLuckyDrawFreeCount or 0
  	self._silverLastTime = (remote.user.luckyDrawRefreshedAt or 0)/1000
  	self._silverCDTime = self._silverTime * 60
  
  	if q.refreshTime(remote.user.c_systemRefreshTime) > self._silverLastTime then
    	self._freeSilverCount = self._silverCount
  	else
    	self._freeSilverCount = self._silverCount - self._freeSilverCount 
  	end

  	if self._freeSilverCount == self._silverCount or (self._freeSilverCount > 0 and (currTime - self._silverLastTime) >= self._silverCDTime) then
    	self.silverIsFree = true
  	else
    	self:silverTimeHandler()
  	end 
  
  	-- 商城召唤
    self._orientRfreshTime = q.date("*t", q.serverTime())
    if self._orientRfreshTime.hour < 5 then 
    	self._orientRfreshTime.day = self._orientRfreshTime.day - 1
    end
    self._orientRfreshTime.hour = 5
    self._orientRfreshTime.min = 0
    self._orientRfreshTime.sec = 0
    self._orientRfreshTime = q.OSTime(self._orientRfreshTime) or 0
    
    --觉醒
    local enchantRefreshTime = (self["enchantFreeBuyAt"] or 0)/1000
    if self._orientRfreshTime > enchantRefreshTime then
  		self.enchantIsFree = true
  	else
  		self:orientTimeHandler("enchant")
    end 
   
    --暗器
    local mountRefreshTime = (self["zuoqiFreeSummonAt"] or 0)/1000
    if self._orientRfreshTime > mountRefreshTime then
  		self.mountIsFree = true
  	else
  		self:orientTimeHandler("mount")
    end

    --仙品
    local magicHerbRefreshTime = (self["magicHerbFreeSummonAt"] or 0)/1000
    if self._orientRfreshTime > magicHerbRefreshTime then
  		self.magicHerbIsFree = true
  	else
  		self:orientTimeHandler("magicHerb")
    end 
end

function QUserProp:goldTimeHandler()
  	if self._goldTimeHandler ~= nil then
    	scheduler.unscheduleGlobal(self._goldTimeHandler)
    	self._goldTimeHandler = nil
  	end 

	local refreshTime = self._goldLastRefreshTime
	local currentTime = q.serverTime()
	refreshTime = refreshTime < currentTime and refreshTime+(24*3600) or refreshTime
	if refreshTime > 0 then
		self._goldTimeHandler = scheduler.performWithDelayGlobal(function()
		      	if self._goldTimeHandler ~= nil then
		        	scheduler.unscheduleGlobal(self._goldTimeHandler)
		      	end 
		      	self.goldIsFree = true
		      	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUserProp.CHEST_IS_FREE})  
			end, refreshTime-currentTime)
	end
end

function QUserProp:silverTimeHandler()
  if self._silverTimeHandler ~= nil then
    scheduler.unscheduleGlobal(self._silverTimeHandler)
    self._silverTimeHandler = nil
  end 
  if self._freeSilverCount > 0 then
    self._silverTimeFun = function ()
      local offsetTime = q.serverTime() - self._silverLastTime
      if offsetTime < self._silverCDTime then
        self._silverTimeHandler = scheduler.performWithDelayGlobal(self._silverTimeFun,1)
--        local date = q.timeToHourMinuteSecond(self._silverCDTime - offsetTime)
--        printInfo("白银"..date)
      else
        if self._silverTimeHandler ~= nil then
          scheduler.unscheduleGlobal(self._silverTimeHandler)
        end 
        self.silverIsFree = true
        QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUserProp.CHEST_IS_FREE})  
      end
    end
    self._silverTimeFun()
  end
end



function QUserProp:orientTimeHandler(orientType)
  	if self[orientType.."TimeHandler"] ~= nil then
    	scheduler.unscheduleGlobal(self[orientType.."TimeHandler"])
    	self[orientType.."TimeHandler"] = nil
  	end 

	local refreshTime = self._orientRfreshTime+(24*3600)
	local currentTime = q.serverTime()
	if refreshTime > 0 then
		self[orientType.."TimeHandler"] = scheduler.performWithDelayGlobal(function()
		      	if self[orientType.."TimeHandler"] ~= nil then
		        	scheduler.unscheduleGlobal(self[orientType.."TimeHandler"])
		      	end 
		      	if orientType == "enchant" then
		      		self.enchantIsFree = true
		      	elseif orientType == "mount" then
		      		self.mountIsFree = true
		      	end
			end, refreshTime-currentTime)
	end
end

function QUserProp:getChestState()
  	if self.silverIsFree == true or self.goldIsFree == true or self.orientIsFree == true then
    	return true
	elseif remote.items:getItemsNumByID(23) >= 10 or remote.items:getItemsNumByID(24) >= 10 then
		return true
	elseif remote.items:getItemsNumByID(24) >= 1 and (remote.user.level or 0) <= 20 then
		return true
  	else
    	return false 
  	end
end

function QUserProp:checkPropEnough(propName, needNum)
	local result = true
	if self[propName] == nil then
		result = false
	end
	if self[propName] < needNum then
		result = false
	end
	if result == false then
    	QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.ENERGY)
		-- local typeName = remote.items:getItemType(propName)
		-- app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBuyVirtual", options = {typeName=typeName, enough=false}})
	end
	return result
end

function QUserProp:timeUpdateHandler()
	self:updateSpecialTime(q.serverTime())
end

--加入工会时判定加入时间  返回ture表示可加入
function QUserProp:checkJoinUnionCdAndTips()
	local joinCD = QStaticDatabase.sharedDatabase():getConfigurationValue("ENTER_SOCIETY") * 60 
	local leave_at  = 0
	if remote.user.userConsortia.leave_at and remote.user.userConsortia.leave_at >0 then
		joinCD = remote.user.userConsortia.leave_at/1000 + joinCD - q.serverTime()	
		if joinCD > 0 then
			app.tip:floatTip(string.format("%d小时%d分钟内无法加入宗门", math.floor(joinCD/(60*60)), math.floor((joinCD/60)%60))) 
			return false
		end
	end

	return true
end



--[[
	记录上次服务器时间，遇到整点差则抛出事件
]]
function QUserProp:serverTimeUpdate(serverTime)
	serverTime = serverTime/1000
	if self._serverTime ~= nil then
		if (serverTime - self._serverTime) >= DAY then
			self:_timeEventHandler()
		else
			local oldHour = tonumber(q.date("%H",self._serverTime))
			local hour = tonumber(q.date("%H",serverTime))
			if oldHour ~= hour then
				while true do
					oldHour = oldHour + 1
					if oldHour == 24 then oldHour = 0 end
					self:_timeEventHandler(oldHour)
					if oldHour == hour then break end
				end
			end
		end
	end
	self._serverTime = serverTime
end

function QUserProp:_timeEventHandler(time)
	if time == nil or time == 5 then
		self:refreshTimeAtNormalTime()
	end
	if time == nil or time == 0 then
		self:refreshTimeAtZeroTime()
	end
	self:dispatchEvent({name = QUserProp.EVENT_TIME_REFRESH, time = time})
end

function QUserProp:sendEventGlyphLevelUp( actorId, skillId, skillLevel )
	self:dispatchEvent({name = QUserProp.EVENT_GLYPH_LEVEL_UP, actorId = actorId, skillId = skillId, skillLevel = skillLevel})
end

function QUserProp:sendEventNewGlyph( actorId, skillId )
	self:dispatchEvent({name = QUserProp.EVENT_NEW_GLYPH, actorId = actorId, skillId = skillId})
end

--充值
function QUserProp:rechargeHandler(event)
	-- if event.type == 4 then return end
	self:addPropNumForKey("todayRecharge", event.amount)
end

--获取TopN战力
function QUserProp:getTopNForce(isLocal)
	local heroForce = remote.herosUtil:getMostHeroBattleForce(isLocal)
	local elfForce = 0--remote.elf:getTopNForce(isLocal)
	return heroForce + elfForce
end


--构造一个自己的Fighter Table
function QUserProp:makeFighterByTeamKey(teamKey, teamNum)
	local selfFighter = {}
	selfFighter.name = remote.user.nickname
	selfFighter.game_area_name = remote.user.myGameAreaName or ""
	selfFighter.avatar = remote.user.avatar
	selfFighter.championCount = remote.user.championCount
	selfFighter.consortiaName = remote.user.userConsortia and remote.user.userConsortia.consortiaName
	selfFighter.collectedHero = remote.user.collectedHeros
	selfFighter.defaultActorId = remote.user.defaultActorId
	selfFighter.defaultSkinId = remote.user.defaultSkinId
	selfFighter.topnForce = remote.user:getTopNForce()
	selfFighter.userId = remote.user.userId
	selfFighter.game_area = remote.user.myGameAreaName
	selfFighter.level = remote.user.level
	selfFighter.nightmareDungeonPassCount = remote.user.nightmareDungeonPassCount
	selfFighter.heroTeamGlyphs = remote.herosUtil:getGlyphTeamProp() -- todo
	selfFighter.name = remote.user.nickname
	selfFighter.archaeology = remote.user.archaeologyInfo
	selfFighter.actorIds = {} 
	selfFighter.title = remote.user.title
	selfFighter.soulTrial = remote.user.soulTrial
	selfFighter.vip = QVIPUtil:VIPLevel() 
	selfFighter.consortiaId = remote.user.userConsortia and remote.user.userConsortia.consortiaId
	if teamKey == nil then
		teamKey = remote.teamManager.INSTANCE_TEAM
	end
	selfFighter.force = remote.teamManager:getBattleForceForAllTeam(teamKey)
	selfFighter.heroSkins = remote.user.heroSkins
	selfFighter.collectedZuoqi = remote.user.collectedZuoqis
	selfFighter.userTitle = remote.headProp:getHeadList()
	selfFighter.dragonDesignInfo = remote.dragonTotem:getDragonTotem()

	local teamVO = remote.teamManager:getTeamByKey(teamKey)

	if teamNum == 1 then
		selfFighter.heros = self:getHerosFun(teamVO:getTeamActorsByIndex(1))
		selfFighter.alternateHeros = self:getHerosFun(teamVO:getTeamAlternatesByIndex(1))
		selfFighter.subheros = self:getHerosFun(teamVO:getTeamActorsByIndex(2))
		selfFighter.sub2heros = self:getHerosFun(teamVO:getTeamActorsByIndex(3))
		selfFighter.sub3heros = self:getHerosFun(teamVO:getTeamActorsByIndex(4))
	elseif teamNum == 2 then
		selfFighter.main1Heros = self:getHerosFun(teamVO:getTeamActorsByIndex(1))
		selfFighter.sub1heros = self:getHerosFun(teamVO:getTeamActorsByIndex(2))
	elseif teamNum == 3 then
		selfFighter.mainHeros3 = self:getHerosFun(teamVO:getTeamActorsByIndex(1))
		selfFighter.subheros3 = self:getHerosFun(teamVO:getTeamActorsByIndex(2))
	end

	return selfFighter
end

function QUserProp:getHerosFun(actorIds)
	local heroInfos = {}
	if actorIds == nil then return heroInfos end
	for _,actorId in ipairs(actorIds) do
		local heroInfo  = remote.herosUtil:getHeroByID(actorId)
		table.insert(heroInfos, heroInfo)
	end
	return heroInfos
end

return QUserProp