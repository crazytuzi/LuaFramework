-- Author: qinyuanji
-- 2015/03/04
-- This class is for VIP wrapping configurations

local QVIPUtil = class("QVIPUtil")
local QStaticDatabase = import("..controllers.QStaticDatabase")

QVIPUtil.AWARD_PURCHASED = "AWARD_PURCHASED"

-- 得到当前用户VIP等级
function QVIPUtil:VIPLevel( ... )
	if remote.user.totalRechargeToken and self.totalRechargeToken ~= remote.user.totalRechargeToken then
		self.totalRechargeToken = remote.user.totalRechargeToken
		self.vipLevel = self:getVIPLevel(remote.user.totalRechargeToken)
	end
	
	return self.vipLevel or 0
end

-- 判断当前是否是VIP满级
function QVIPUtil:isVIPMaxLevel( ... )
	return self:VIPLevel() >= self:getMaxLevel()
end

-- 获得总共充值的数量
function QVIPUtil:recharged( ... )
	return remote.user.totalRechargeToken
end

-- 获得总共充值的数量
function QVIPUtil:rechargedRMBNum( ... )
	return remote.user.newTotalRecharge
end

function QVIPUtil:getMaxLevel( ... )
	if self.maxLevel == nil then
		self.maxLevel = table.nums(QStaticDatabase:sharedDatabase():getVIP()) - 1
	end
	return self.maxLevel
end

--需要充值钻石数
function QVIPUtil:cash(level)
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve cash exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].cash
end

--根据充值的钻石得到VIP等级
function QVIPUtil:getVIPLevel(cash)
	local vipLevel = 0
	local vipTable = {}
	for k, v in pairs(QStaticDatabase:sharedDatabase():getVIP()) do
		table.insert(vipTable, v)
	end

	table.sort(vipTable, function (x, y)
		return x.vip < y.vip
	end)

	for k, v in ipairs(vipTable) do
		if cash < v.cash then
			return vipLevel - 1, cash
		end
		vipLevel = vipLevel + 1
	end

	return self:getMaxLevel(), cash
end

--赠送扫荡劵数
function QVIPUtil:getFreeSweepCount(level)
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve sweep coupon exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].sweep_coupon or 0
end

--购买体力/金魂币次数上限
-- vType: ITEM_TYPE.ENERY - enery ITEM_TYPE.MONEY - money
function QVIPUtil:getBuyVirtualCount(vType, level)
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve buy energy count exceed maximum VIP level")
	end
	if vType  == ITEM_TYPE.ENERGY  then
		return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].energy_limit
	elseif vType == ITEM_TYPE.SUNWAR_REVIVE_COUNT then
		return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].battlefield_revive_times
	elseif vType == ITEM_TYPE.SOCIATY_CHAPTER_TIMES then
		return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].sociaty_chapter_times
	elseif vType == ITEM_TYPE.SILVERMINE_LIMIT then
		return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].silvermine_limit
	elseif vType == ITEM_TYPE.GOLDPICKAXE_TIMES then
		return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].huangjinkuanggao_times
	elseif vType == ITEM_TYPE.PLUNDER_TIMES then
		return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].gh_ykz_ld_times
	else
		return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].money_limit
	end
end

--根据字段获取次数
function QVIPUtil:getCountByWordField(field, level)
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)][field] or 0
end

--可重置精英关卡次数
function QVIPUtil:getResetEliteDungeonCount( level )
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve elite dungeon count exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].dungeon_elite_limit
end

--技能点上限
function QVIPUtil:getSkillPointCount( level )
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve maximum skill point exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].skill_points_limit
end

--黑铁酒吧购买次数
function QVIPUtil:getBarMaxCount( level )
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].dwarf_cellar or 0
end

--藏宝海湾购买次数
function QVIPUtil:getSeaMaxCount( level )
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].bppty_bay or 0
end

--力量试炼购买次数
function QVIPUtil:getStengthMaxCount( level )
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].strength_trial or 0
end

--智慧试炼购买次数
function QVIPUtil:getIntellectMaxCount( level )
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].sapiential_trial or 0
end

--可购买斗魂场门票次数
function QVIPUtil:getArenaResetCount( level )
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve arena reset count exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].arena_times_limit
end



function  QVIPUtil:getGloryArenaResetCount( level )
	-- body
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve Glory Arena  reset count exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].competion_times_limit
	
end

function  QVIPUtil:getStormArenaResetCount( level )
	-- body
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve storm Arena  reset count exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].storm_arena_times
end

function  QVIPUtil:getSotoTeamResetCount( level )
	-- body
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve soto team reset count exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].soto_team_times_limit
end

function  QVIPUtil:getGoldPickaxeCount( level )
	-- body
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve storm Arena  reset count exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].huangjinkuanggao_times
	
end


--太阳井重置次数
function QVIPUtil:getSunwellResetCount( level )
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve sunwell reset count exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].sunwell_times
end

--史诗副本挑战最大次数
function QVIPUtil:getWelfareCount( level )
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve welfare battle count exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].fuli_times
end


--开启扫荡关卡功能(使用钻石扫荡关卡)
function QVIPUtil:canUseTokenSweep( level )
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve canUseTokenSweep exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].switch_token_sweep
end

function QVIPUtil:getUseTokenSweepUnlockLevel(  )
	local tokenSweep = {}
	for k, v in pairs(QStaticDatabase:sharedDatabase():getVIP()) do
		table.insert(tokenSweep, k)
	end
	table.sort(tokenSweep, function (x, y)
		return tonumber(x) < tonumber(y)
	end)
	for _, v in ipairs(tokenSweep) do
		if QStaticDatabase:sharedDatabase():getVIP()[tostring(v)].switch_token_sweep == true then
			return v
		end
	end
	return #tokenSweep
end

--可购买技能强化点数
function QVIPUtil:canBuySkillPoint( level )
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve canBuySkillPoint exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].switch_skill_points
end

function QVIPUtil:getBuySkillPointUnlockLevel(  )
	local skillPointLevel = {}
	for k, v in pairs(QStaticDatabase:sharedDatabase():getVIP()) do
		table.insert(skillPointLevel, k)
	end
	table.sort(skillPointLevel, function (x, y)
		return tonumber(x) < tonumber(y)
	end)
	for _, v in ipairs(skillPointLevel) do
		if QStaticDatabase:sharedDatabase():getVIP()[tostring(v)].switch_skill_points == true then
			return v
		end
	end
	return #skillPointLevel
end

-- 通过SHOPID得到VIP
-- 如果得不到返回nil
function QVIPUtil:getVIPLevelByShopId(shopId)
	local goodInfo = QStaticDatabase:sharedDatabase():getGoodsGroupByGroupId(shopId)
	return goodInfo.vip_buy
end

function QVIPUtil:getShopIdByVIP(level)
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve canBuySkillPoint exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].shop_permission
end

--重置斗魂场CD开关
function QVIPUtil:canResetArenaCD( level )
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve canResetArenaCD exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].switch_arena_cd
end

function QVIPUtil:getcanResetArenaCDUnlockLevel(  )
	local arenaCD = {}
	for k, v in pairs(QStaticDatabase:sharedDatabase():getVIP()) do
		table.insert(arenaCD, k)
	end
	table.sort(arenaCD, function (x, y)
		return tonumber(x) < tonumber(y)
	end)
	for _, v in ipairs(arenaCD) do
		if QStaticDatabase:sharedDatabase():getVIP()[tostring(v)].switch_arena_cd == true then
			return tonumber(v)
		end
	end
	return #arenaCD
end
--一键扫荡10次关卡
function QVIPUtil:canSweepTenTimes( level )
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve canSweepTenTimes exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].switch_sweep_ten_times
end

function QVIPUtil:getcanSweepTenTimesUnlockLevel(  )
	local sweep = {}
	for k, v in pairs(QStaticDatabase:sharedDatabase():getVIP()) do
		table.insert(sweep, k)
	end
	table.sort(sweep, function (x, y)
		return tonumber(x) < tonumber(y)
	end)
	for _, v in ipairs(sweep) do
		if QStaticDatabase:sharedDatabase():getVIP()[tostring(v)].switch_sweep_ten_times == true then
			return tonumber(v)
		end
	end
	return #sweep
end

--永久召唤地精商人
function QVIPUtil:enableGoblinPermanent( level )
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve enableGoblinPermanent exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].switch_shop_1_permanent
end

--永久召唤黑市商人
function QVIPUtil:enableBlackMarketPermanent( level )
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve enableBlackMarketPermanent exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].switch_shop_2_permanent
end

--太阳井宝箱金魂币增加50%开关
function QVIPUtil:sunwellMoneyBonus( level )
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve sunwellMoneyBonus exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].switch_sunwell_money
end

--装备一键强化开关
function QVIPUtil:oneClickEnhance( level )
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve oneClickEnhance exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].switch_enhance_one
end

--装备全部强化开关
function QVIPUtil:allEnhance( level )
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve allEnhance exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].switch_enhance_all
end

--装备一键觉醒开关
function QVIPUtil:oneClickEnchant( level )
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve oneClickEnchant exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].switch_enchant_immediate
end

--定向酒馆显示开关
function QVIPUtil:showDirectionalTavern( level )
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve oneClickEnchant exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].unlock_direction_display
end

--定向酒馆购买开关
function QVIPUtil:showDirectionalTavernBuyBtn( level )
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve oneClickEnchant exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].unlock_direction_purchase
end

function QVIPUtil:getoneClickEnchantUnlockLevel(  )
	local enchant = {}
	for k, v in pairs(QStaticDatabase:sharedDatabase():getVIP()) do
		table.insert(enchant, k)
	end
	table.sort(enchant, function (x, y)
		return tonumber(x) < tonumber(y)
	end)
	for _, v in ipairs(enchant) do
		if QStaticDatabase:sharedDatabase():getVIP()[tostring(v)].switch_enchant_immediate == true then
			return v
		end
	end
	return #enchant
end

--根据vip等级获取道具商城物品最大数量
function QVIPUtil:getMallItemMaxCountByVipLevel(goodGroupId, level)
	if level == nil or goodGroupId == nil then return 0 end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(level)]["shop_limit_".. goodGroupId]
end 

--根据VIP等级获得培养次数的限制
function QVIPUtil:getTrainingTimeByVipLevel(level)
	if level  == nil then return nil end

	local trainOnce = QStaticDatabase:sharedDatabase():getVIP()[tostring(level)].train_1times
	local train5Times = QStaticDatabase:sharedDatabase():getVIP()[tostring(level)].train_5times
	local train10Times = QStaticDatabase:sharedDatabase():getVIP()[tostring(level)].train_10times

	return trainOnce, train5Times, train10Times
end

--根据培养次数得到解锁VIP的等级
function QVIPUtil:getTrainingTimesUnlockLevel(times)
	local trainingTimes = {}
	local column = "train_" .. times .. "times"
	for k, v in pairs(QStaticDatabase:sharedDatabase():getVIP()) do
		table.insert(trainingTimes, k)
	end
	table.sort(trainingTimes, function (x, y)
		return tonumber(x) < tonumber(y)
	end)
	for _, v in ipairs(trainingTimes) do
		if QStaticDatabase:sharedDatabase():getVIP()[tostring(v)][column] == true then
			return v
		end
	end
	return #trainingTimes
end

--根据VIP等级得到要塞入侵令牌购买次数
function QVIPUtil:getInvasionTokenBuyCount( level )
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve sunwell reset count exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].intrusion_token
end

--获取可以刷新斗魂场的次数
function QVIPUtil:getArenaRefreshCount( level )
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].arenarefresh_limit or 0
end

function QVIPUtil:getGloryArenaRefreshCount( level )
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].competionrefresh_limit or 0
end

function QVIPUtil:getStormArenaRefreshCount( level )
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].storm_arena_refresh_limit or 0
end

function QVIPUtil:getSotoTeamRefreshCount( level )
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].storm_arena_refresh_limit or 0
end

--获取魂师大赛免费刷新次数
function QVIPUtil:getTowerFreeRefreshCount( level )
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].tower_free_refresh_limit or 0
end

--获取魂师大赛可购买攻打次数
function QVIPUtil:getTowerBuyCount( level )
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].tower_buy_fight_times_limit or 0
end

--活动副本是否可扫荡
function QVIPUtil:getActivityQuickFight()
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve oneClickEnchant exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].activity_quick_fight
end

--获取活动副本可扫荡的vip等级
function QVIPUtil:getcanActivityQuickFight( ... )
	local quickFight = {}
	for k, v in pairs(QStaticDatabase:sharedDatabase():getVIP()) do
		table.insert(quickFight, k)
	end
	table.sort(quickFight, function (x, y)
		return tonumber(x) < tonumber(y)
	end)
	for _, v in ipairs(quickFight) do
		if QStaticDatabase:sharedDatabase():getVIP()[tostring(v)].activity_quick_fight == true then
			return tonumber(v)
		end
	end
	return #quickFight
end

--斗魂场是否可扫荡
function QVIPUtil:getArenaQuickFight()
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve oneClickEnchant exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].arena_quick_fight
end

--获取斗魂场可扫荡的vip等级
function QVIPUtil:getcanArenaQuickFight( ... )
	local quickFight = {}
	for k, v in pairs(QStaticDatabase:sharedDatabase():getVIP()) do
		table.insert(quickFight, k)
	end
	table.sort(quickFight, function (x, y)
		return tonumber(x) < tonumber(y)
	end)
	for _, v in ipairs(quickFight) do
		if QStaticDatabase:sharedDatabase():getVIP()[tostring(v)].arena_quick_fight == true then
			return tonumber(v)
		end
	end
	return #quickFight
end

--雷电王座是否可扫荡
function QVIPUtil:getThunderQuickFight()
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve oneClickEnchant exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].thunder_quick_fight
end

--获取雷电王座可扫荡的vip等级
function QVIPUtil:getcanThunderQuickFight( ... )
	local quickFight = {}
	for k, v in pairs(QStaticDatabase:sharedDatabase():getVIP()) do
		table.insert(quickFight, k)
	end
	table.sort(quickFight, function (x, y)
		return tonumber(x) < tonumber(y)
	end)
	for _, v in ipairs(quickFight) do
		if QStaticDatabase:sharedDatabase():getVIP()[tostring(v)].thunder_quick_fight == true then
			return tonumber(v)
		end
	end
	return #quickFight
end

--活动副本是否可以无cd
function QVIPUtil:getActivityNoCD()
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
		print("retrieve oneClickEnchant exceed maximum VIP level")
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].huodongben_CD
end

--斗魂场积分失败奖励
function QVIPUtil:getArenaFailScore(level)
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].arena_fail_integral
end

--太阳海神岛购买复活的次数
function QVIPUtil:getSunWarBuyReviveCount(level)
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].battlefield_revive_times
end

--每周礼包购买折扣
function QVIPUtil:getWeekShopDiscount(level)
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].shop_week_discount
end

--宗门副本购买攻击次数
function QVIPUtil:getSocietyDungeonBuyFightCount(level)
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].sociaty_chapter_times
end

--魂兽森林购买占领次数
function QVIPUtil:getSilverMineBuyFightCount(level)
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].silvermine_limit
end

--世界boss购买挑战次数
function QVIPUtil:getWorldBossBuyFightCount(level)
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].yaosai_boss_times
end

--世界boss购买挑战次数
function QVIPUtil:getBlackRockBuyAwardsCount(level)
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].blackrock_award
end

--跨服魂兽森林购买掠夺次数
function QVIPUtil:getPlunderLootCount(level)
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].gh_ykz_ld_times
end

--海商购买运送次数
function QVIPUtil:getMaritimeTransportCount(level)
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].maritime_num
end

--海商购买掠夺次数
function QVIPUtil:getMaritimeRobberyCount(level)
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].maritime_plunder
end

--龙战购买挑战次数
function QVIPUtil:getDragonWarCount(level)
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].sociaty_dragon_fight_times
end

--海商购买掠夺次数
function QVIPUtil:getMockBattleTicketCount(level)
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)].mock_battle_times
end


return QVIPUtil