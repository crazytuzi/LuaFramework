
local QBaseModel = import("..models.QBaseModel")
local QShop = class("QShop",QBaseModel)

local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNotificationCenter = import("..controllers.QNotificationCenter")
local QVIPUtil = import(".QVIPUtil")
local QUIViewController = import("..ui.QUIViewController")
local QNavigationController = import("..controllers.QNavigationController")
local QQuickWay = import(".QQuickWay")

              
QShop.MYSTORY_SHOP_UPDATE_EVENT = "MYSTORY_SHOP_UPDATE_EVENT"
QShop.SHOP_ITEM_BUY_SCCESS = "SHOP_ITEM_BUY_SCCESS"
QShop.ITEM_SELL_SALE = 1
QShop.ITEM_SELL_RECOMMEND = 3
QShop.ITEM_SOUL_GEM = 2

--设置商店左右切换顺序
local swithcShop = {
		["1"] = {id = "1", preS = "814", nextS = "501"}, 
		["501"] = {id = "501", preS = "1", nextS = "3"}, 
		["3"] = {id = "3", preS = "501", nextS = "809"},
		["809"] = {id = "809", preS = "3", nextS = "812"}, 
		["812"] = {id = "812", preS = "809", nextS = "4"}, 
		["4"] = {id = "4", preS = "812", nextS = "5"}, 
		["5"] = {id = "5", preS = "4", nextS = "91"}, 
		["91"] = {id = "91", preS = "5", nextS = "601"}, 
		["601"] = {id = "601", preS = "91", nextS = "101"}, 
		["101"] = {id = "101", preS = "601", nextS = "901"},
		["901"] = {id = "901", preS = "101", nextS = "1001"},
		["1001"] = {id = "1001", preS = "901", nextS = "801"},
		["801"] = {id = "801", preS = "1001", nextS = "802"},
		["802"] = {id = "802", preS = "801", nextS = "808"},
		["808"] = {id = "808", preS = "802", nextS = "804"},
		["804"] = {id = "804", preS = "808", nextS = "805"},
		["805"] = {id = "805", preS = "804", nextS = "807"},
		["807"] = {id = "807", preS = "805", nextS = "806"},
		["806"] = {id = "806", preS = "807", nextS = "810"},
		["810"] = {id = "810", preS = "806", nextS = "811"},
		["811"] = {id = "811", preS = "810",nextS = "814"},
		["814"] = {id = "814", preS = "811",nextS = "1"},
	}

function QShop:ctor()
	QShop.super.ctor(self)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	for key, value in pairs(SHOP_ID) do
		self[key] = {}
		self[key.."RefreshTime"] = nil
		self[key.."LastRefreshTime"] = q.serverTime()
		self[value.."shopState"] = false
		-- self[value.."maxPosition"] = 0
	end

	--[[
		shopId:  商店ID
		arawdsId: 奖励页商店ID
		moneyType: topBar 的显示类型与顺序
		currencyType: 当前商店消耗的货币类型
		titleName: 商店标题名称
		refreshInfo: 商店刷新消耗的相应货币 (在 token_consume 表中)
		saleState: item表中的相应商店中的出售状态 （0~1，表示对应折扣  2，表示推荐  3，表示魂力精魄）
		talkId: 商店界面NPC对话 （在 shop_talk 表中）
		quickBuy: 是否拥有一键购买
		className: 商店类名称
		hideDirection:是否隐藏左右切换
	]]
	self.shopInfo = { 
		-- 特殊商店
		{shopId = SHOP_ID.generalShop, moneyType = "money^token^energy", titleName = "杂货商店", refreshInfo = "refresh_shop", saleState = "zahuo_shop",
			proxyClass = "QGroceriesShopProxy", namePath = "ui/update_shop/shop/sp_words_zahuoshangdian.png", avatarId = 1021},
		{shopId = SHOP_ID.blackShop, moneyType = "money^token^energy", titleName = "黑市商人", refreshInfo = "refresh_shop_2", saleState = "heishi_shop",
			proxyClass = "QBalckShopProxy", namePath = "ui/update_shop/shop/sp_words_heishishangren.png", avatarId = 1013},
		{shopId = SHOP_ID.soulShop, moneyType = "money^token^soulMoney", titleName = "魂师商店", refreshInfo = "refresh_soul_shop", saleState = "yinlin_shop",
			proxyClass = "QSoulShopProxy",quickBuy = true, namePath = "ui/update_shop/shop/sp_words_hunshishangdian.png", avatarId = 1012},

		-- 商城
		{shopId = SHOP_ID.vipShop, moneyType = "", titleName = "", npc = "", refreshInfo = "", saleState = "shangcheng_shop", className = "QUIDialogMall"},
		{shopId = SHOP_ID.weekShop, moneyType = "", titleName = "", npc = "", refreshInfo = "", saleState = "shangcheng_shop", className = "QUIDialogMall"},
		{shopId = SHOP_ID.skinShop, moneyType = "", titleName = "", npc = "", refreshInfo = "", saleState = "shangcheng_shop", className = "QUIDialogMall"},
		
		-- 普通功能商店
		{shopId = SHOP_ID.arenaShop, arawdsId = SHOP_ID.arenaAwardsShop, moneyType = "money^token^arenaMoney", currencyType = "arenaMoney", titleName = "斗魂场商店", 
			refreshInfo = "refresh_arena_shop", quickBuy = true, proxyClass = "QBaseArenaShopProxy",
			namePath = "ui/update_shop/shop/sp_words_douhunchangshangdian.png", avatarId = 1028},
		{shopId = SHOP_ID.sunwellShop, arawdsId = SHOP_ID.sunwellAwardsShop, moneyType = "money^token^sunwellMoney", currencyType = "sunwellMoney", titleName = "海神岛商店",
			refreshInfo = "refresh_sunwell_shop", quickBuy = true, proxyClass = "QBaseArenaShopProxy",
			namePath = "ui/update_shop/shop/sp_words_haishendaoshangdian.png", avatarId = 1038},
		{shopId = SHOP_ID.gloryTowerShop, arawdsId = SHOP_ID.gloryTowerAwardsShop, moneyType = "money^token^towerMoney", currencyType = "towerMoney", titleName = "大魂师商店", 
			refreshInfo = "refresh_glory_shop", quickBuy = true, proxyClass = "QBaseArenaShopProxy",
			namePath = "ui/update_shop/shop/sp_words_dahunshishangdian.png", avatarId = 1033},
		{shopId = SHOP_ID.consortiaShop, arawdsId = SHOP_ID.consortiaAwardsShop, moneyType = "money^token^consortiaMoney", currencyType = "consortiaMoney", titleName = "宗门商店",
			refreshInfo = "consortia_shop", quickBuy = true, proxyClass = "QBaseArenaShopProxy",
			namePath = "ui/update_shop/shop/sp_words_zongmenshangdian.png", avatarId = 1016},
		{shopId = SHOP_ID.thunderShop, arawdsId = SHOP_ID.thunderAwardsShop, moneyType = "money^token^thunderMoney", currencyType = "thunderMoney", titleName = "杀戮商店",
			refreshInfo = "thunder_shop", quickBuy = true, proxyClass = "QBaseArenaShopProxy",
			namePath = "ui/update_shop/shop/sp_words_shalushangdian.png", avatarId = 1009},
		{shopId = SHOP_ID.invasionShop, arawdsId = SHOP_ID.invationAwardsShop, moneyType = "money^token^intrusion_money", currencyType = "intrusion_money", titleName = "魂兽商店",
			refreshInfo = "intrusion_shop", quickBuy = true, proxyClass = "QBaseArenaShopProxy",
			namePath = "ui/update_shop/shop/sp_words_hunshoushangdian.png", avatarId = 1027},
		{shopId = SHOP_ID.artifactShop, arawdsId = SHOP_ID.artifactAwardsShop, moneyType = "money^token^maritimeMoney", currencyType = "maritimeMoney", titleName = "索托商店",
			refreshInfo = "refresh_storm_shop", quickBuy = true, proxyClass = "QBaseArenaShopProxy",
			namePath = "ui/update_shop/shop/sp_words_suotuoshangdian.png", avatarId = 1017},
		-- 兑换类功能商店
		{shopId = SHOP_ID.silverShop, arawdsId = SHOP_ID.silverAwardsShop, moneyType = "money^gemstoneExchangeToken^silvermineMoney", currencyType = "silvermineMoney", titleName = "魂骨商店", 
			refreshInfo = "", talkId = SHOP_ID.silverAwardsShop, proxyClass = "QBaseSilverShopProxy", isExchangeShop = true,
			namePath = "ui/update_shop/shop/sp_words_hungushangdian.png", avatarId = 1015},
		{shopId = SHOP_ID.metalCityShop, arawdsId = SHOP_ID.metalCityAwardsShop, moneyType = "abyssExchangeToken^stormExchangeToken^stormMoney", currencyType = "stormMoney", titleName = "金属商店", 
			refreshInfo = "", talkId = SHOP_ID.metalCityAwardsShop, proxyClass = "QBaseSilverShopProxy", isExchangeShop = true,
			namePath = "ui/update_shop/shop/sp_words_jinshushangdian.png", avatarId = 1020},
		{shopId = SHOP_ID.rushBuyShop, moneyType = "token^rushBuyMoney^rushBuyScore", currencyType = "rushBuyScore", titleName = "夺宝商店",
			refreshInfo = "", talkId = SHOP_ID.rushBuyShop, proxyClass = "QBaseSilverShopProxy", isExchangeShop = true,
			namePath = "ui/update_shop/shop/sp_words_duobaoshangdian.png", avatarId = 1048},
		{shopId = SHOP_ID.dragonWarShop, arawdsId = SHOP_ID.dragonWarAwardsShop, moneyType = "money^token^dragonWarMoney", currencyType = "dragonWarMoney", titleName = "武魂争霸商店",
			refreshInfo = "", talkId = SHOP_ID.dragonWarShop, proxyClass = "QBaseSilverShopProxy", isExchangeShop = true,
			namePath = "ui/update_shop/shop/sp_words_wuhunzhengbashangdian.png", avatarId = 1026},
		{shopId = SHOP_ID.sparShop, arawdsId = nil, moneyType = "money^token^jewelryMoney", currencyType = "jewelryMoney", titleName = "地狱商店", 
			refreshInfo = "", talkId = SHOP_ID.sparShop, proxyClass = "QBaseSilverShopProxy", isExchangeShop = true,
			namePath = "ui/update_shop/shop/sp_words_diyushangdian.png", avatarId = 1036},
		{shopId = SHOP_ID.sanctuaryShop, arawdsId = SHOP_ID.sanctuaryAwardsShop, moneyType = "money^token^sanctuaryMoney", currencyType = "sanctuaryMoney", titleName = "全大陆精英赛商店", 
			refreshInfo = "", talkId = SHOP_ID.sanctuaryShop, proxyClass = "QBaseSilverShopProxy", isExchangeShop = true,
			namePath = "ui/update_shop/shop/sp_words_quandalujingyingsaishangdian.png", avatarId = 1044},
		{shopId = SHOP_ID.blackRockShop, arawdsId = SHOP_ID.blackRockAwardsShop, moneyType = "money^token^teamMoney", currencyType = "teamMoney", titleName = "传灵商店", 
			refreshInfo = "", proxyClass = "QBaseSilverShopProxy", isExchangeShop = true,
			namePath = "ui/update_shop/shop/sp_words_chuanlingshangdian.png", avatarId = 1025},
		{shopId = SHOP_ID.crystalShop, moneyType = "money^token^crystalPiece", currencyType = "crystalPiece", titleName = "魂晶商店", proxyClass = "QBaseSilverShopProxy",
			refreshInfo = "", proxyClass = "QBaseSilverShopProxy",isExchangeShop = true, namePath = "ui/update_shop/shop/sp_words_hunjingshangdian.png", avatarId = 1006},
		{shopId = SHOP_ID.mockbattleShop, arawdsId = SHOP_ID.mockbattleAwardsShop, moneyType = "money^token^mock_battle_money", currencyType = "mock_battle_money", titleName = "学院商店",
			refreshInfo = "", talkId = SHOP_ID.sanctuaryShop, proxyClass = "QBaseSilverShopProxy", isExchangeShop = true,
			namePath = "ui/update_shop/shop/sp_words_xueyuanshangdian.png", avatarId = 1046},
		{shopId = SHOP_ID.godarmShop, arawdsId = SHOP_ID.godarmAwardsShop, moneyType = "money^token^godArmMoney", currencyType = "godArmMoney", titleName = "圣柱商店", 
			refreshInfo = "", proxyClass = "QBaseSilverShopProxy", isExchangeShop = true,
			namePath = "ui/update_shop/shop/sp_words_shengzhushangdian.png", avatarId = 1023},	
		{shopId = SHOP_ID.monthSignInShop, arawdsId = nil, moneyType = "money^token^checkInMoney", currencyType = "checkInMoney", titleName = "签到商店",
			refreshInfo = "", proxyClass = "QBaseSilverShopProxy", isExchangeShop = true,
			namePath = "ui/update_shop/shop/sp_words_qiandaoshangdian.png", avatarId = 1048},

		{shopId = SHOP_ID.silvesShop, arawdsId = SHOP_ID.silvesAwardShop, moneyType = "token^silvesarenasilverMoney^silvesarenagoldMoney", currencyType = "silvesarenasilverMoney", titleName = "金魂商店",
			refreshInfo = "", proxyClass = "QBaseSilverShopProxy", isExchangeShop = true,
			namePath = "ui/update_shop/shop/sp_words_xierweisi.png", avatarId = 1013},	
		{shopId = SHOP_ID.highTeaShop	, arawdsId = nil, moneyType = "money^token", currencyType = "token", titleName = "食材商店", hideDirection = true,
			refreshInfo = "", proxyClass = "QBaseSilverShopProxy", isExchangeShop = true,
			namePath = "ui/update_shop/shop/sp_words_shicaishangdian.png", avatarId = 1003},		
		{shopId = SHOP_ID.musicShop	, arawdsId = nil, moneyType = "money^token^music_game_note", currencyType = "token", titleName = "音浪商店", hideDirection = true,
			refreshInfo = "", proxyClass = "QBaseSilverShopProxy", isExchangeShop = true,
			namePath = "ui/update_shop/shop/zi_yinlangshangdian.png", avatarId = 1059},				

	}
	
	self.itemQualityIndex = {[1] = "white", [2] = "green", [3] = "blue", [4] = "purple", [5] = "orange", [6] = "red", [7] = "yellow"}

	self.shopLastRefreshTime = {}
	
	self.proxys = {}
	
	-- 借用位置存放重生殿红点标志位
	self._trainTips = false
	self.versionPost = false  -- 版本公告

end

function QShop:didappear()
	for _,v in ipairs(self.shopInfo) do
		self:creatShopProxyByProxyClass(v)
	end
end

function QShop:creatShopProxyByProxyClass(shopInfo)
	if q.isEmpty(shopInfo) then return end

	local proxyClass = shopInfo.proxyClass
	if proxyClass == nil then
		proxyClass = "QBaseShopProxy"
	end
	local cls = import(app.packageRoot .. ".modules.shop." .. proxyClass)
	self.proxys[shopInfo.shopId] = cls.new(shopInfo.shopId)
end

function QShop:changeAwardId( shopId, arawdsId)
	-- bodya
	if not shopId then
		return
	end
	for k, v in pairs(self.shopInfo) do
		if v.shopId == shopId then
			v.arawdsId = arawdsId
		end
	end
end

function QShop:disappear()
	if self._goblinTimeHandler ~= nil then
		scheduler.unscheduleGlobal(self._goblinTimeHandler)
		self._goblinTimeHandler = nil
	end
	if self._blackTimeHandler ~= nil then
		scheduler.unscheduleGlobal(self._blackTimeHandler)
		self._blackTimeHandler = nil
	end
end

-- 更新商店数据
function QShop:updateComplete(stores)
	for _,value in pairs(stores) do
		-- 是否屏蔽道具（主要是碎片）
		self:checkHeroSwitch(value)

		for key, shopID in pairs(SHOP_ID) do
			if shopID == tostring(value.id) then
				self:checkItemState(value, shopID, key)
				if tostring(value.id) == SHOP_ID.blackShop or tostring(value.id) == SHOP_ID.goblinShop then
					self:dispatchEvent({name = QShop.MYSTORY_SHOP_UPDATE_EVENT})
				end
				break
			end
		end
		if tonumber(value.id) >= 101 and tonumber(value.id) <= 199 then
			self["gloryTowerShop"] = clone(value)
			value.id = SHOP_ID.gloryTowerShop
			self:checkItemState(value, SHOP_ID.gloryTowerShop, "gloryTowerShop")
		elseif tonumber(value.id) >= 401 and tonumber(value.id) <= 417 then
			self["gloryTowerFreeShop"] = clone(value)
			self:checkItemState(value, SHOP_ID.gloryTowerFreeShop, "gloryTowerFreeShop")
		end
	end
end

--获取商店物品信息
function QShop:getStoresById(shopId)
	for key, shopID in pairs(SHOP_ID) do
		if shopID == shopId then
			return self[key].shelves
		end
	end
end

--获取手动刷新次数
function QShop:getRefreshCountById(shopId)
	for key, shopID in pairs(SHOP_ID) do
		if shopID == shopId then
			return self[key].buyRefreshCount
		end
	end
end

--获取自动刷新时间
function QShop:getRefreshAtTime(shopId)
	for key, shopID in pairs(SHOP_ID) do
		if shopID == shopId then
			return self[key].refreshedAt
		end
	end
end

--获取免费刷新时间, 免费刷新次数
function QShop:getFreeRefreshInfo(shopId)
	for key, shopID in pairs(SHOP_ID) do
		if shopID == shopId then
			return self[key].freeRefreshedAt, self[key].freeRefreshedCount
		end
	end
end

--获取奖励商店信息
function QShop:getAwardsShopById(shopId)
	for key, shopID in pairs(SHOP_ID) do
		if shopID == shopId then
			return self[key].award_buy_pos
		end
	end
end

-- 设置免费刷新时间, 免费刷新次数
function QShop:setFreeRefreshInfo(shopId, refreshTime, refreshcount)
	for key, shopID in pairs(SHOP_ID) do
		if shopID == shopId then
			self[key].freeRefreshedAt = refreshTime
			self[key].freeRefreshedCount = refreshcount
		end
	end
end

-- 设置免费刷新时间, 免费刷新次数
function QShop:setFreeRefreshInfo(shopId, refreshTime, refreshcount)
	for key, shopID in pairs(SHOP_ID) do
		if shopID == shopId then
			self[key].freeRefreshedAt = refreshTime
			self[key].freeRefreshedCount = refreshcount
		end
	end
end

-- 设置奖励商店小红点是否显示
function QShop:setAwardsShopState(shopId, state)
	if state == nil then 
		self[shopId.."shopState"] = true
	else
		self[shopId.."shopState"] = state
	end
end

--通过shopId获取proxy对象
function QShop:getProxyById(shopId)
	print("通过shopId获取proxy对象---",shopId)
	print(self.proxys[shopId])
	if self.proxys[shopId] == nil then
		local shopInfo = self:getShopResousceByShopId(shopId)
		self:creatShopProxyByProxyClass(shopInfo)
	end

	return self.proxys[shopId]
end

-- 根据奖励商店id获取商店是否被点击
function QShop:getAwardsShopState(shopId)
	return self[shopId.."shopState"] or false
end

function QShop:getShopInfoFromServerById(shopId)
	if shopId == nil then return end

	app:getClient():getStores(shopId, function(data)
	end)
end

function QShop:getBlackShopIsUnlock(currentLevel, isVip)
	local isUnlockLevel = app.unlock:getConfigByKey("UNLOCK_SHOP_2").team_level
	if isVip then 
		isUnlockLevel = app.unlock:getConfigByKey("UNLOCK_SHOP_2").vip_level
	end

	local unlock = app.tip:getUnlockTutorial()
	if currentLevel >= isUnlockLevel and unlock["black"] == 0 then
		unlock["black"] = 1
		app.tip:setUnlockTutorial(unlock)
		
		if self.blackShop == nil or self.blackShop.shelves == nil then
			self:getShopInfoFromServerById(SHOP_ID.blackShop)
		end
	end
end

function QShop:checkItemState(stores, shopId, key)
	if next(stores) == nil then return end

	if stores.shelves ~= nil then
		local shopInfo = self:getShopResousceByShopId(shopId)
		if shopInfo ~= nil and shopInfo.saleState ~= "" then
			for i = 1, #stores.shelves, 1 do
				if shopId == SHOP_ID.weekShop then
					stores.shelves[i].sellState = QShop.ITEM_SELL_SALE
					stores.shelves[i].sale = QVIPUtil:getWeekShopDiscount(i-1) or 1  
				else
					local goodInfo = QStaticDatabase:sharedDatabase():getGoodsGroupByGroupId(stores.shelves[i].good_group_id)
					local j = 1
					local discount = 1
					while goodInfo["type_"..j] do
						if goodInfo["money_num_"..j] == stores.shelves[i].cost and ((goodInfo["id_"..j] and goodInfo["id_"..j] == stores.shelves[i].id) or (goodInfo["id_"..j] == nil and goodInfo["type_"..j] ~= nil)) then
							discount = goodInfo["money_discount_"..j]
							break
						end
						j = j + 1
					end

					stores.shelves[i].sale = discount
					
					local itemsInfo = QStaticDatabase:sharedDatabase():getItemByID(stores.shelves[i].id)
					if itemsInfo ~= nil and itemsInfo[shopInfo.saleState] ~= nil then
						if itemsInfo[shopInfo.saleState] < 1 then
							stores.shelves[i].sellState = QShop.ITEM_SELL_SALE
						elseif itemsInfo[shopInfo.saleState] == 2 then
							stores.shelves[i].sellState = QShop.ITEM_SOUL_GEM
						elseif itemsInfo[shopInfo.saleState] == 1 then
							stores.shelves[i].sellState = QShop.ITEM_SELL_RECOMMEND
						else
							stores.shelves[i].sellState = 4
						end
					else
						stores.shelves[i].sellState = 4 
					end
				end
			end
		end

		local index = 1
		for i = 1, #stores.shelves, 1 do
			stores.shelves[i].position = i - 1
		end
		if shopId ~= SHOP_ID.weekShop and shopId ~= SHOP_ID.vipShop and shopInfo ~= nil and shopInfo.saleState ~= nil then
			table.sort(stores.shelves, function(a, b)
					return a.sellState < b.sellState
				end)
		end
	end

	self[key] = clone(stores)
end

--关闭特殊商店
function QShop:closeMystoryShop(shopId)
	if shopId == SHOP_ID.goblinShop then
		self["goblinShop"] = {}
	elseif shopId == SHOP_ID.blackShop then
		self["blackShop"] = {}
	end
end

--获取神秘商店开启时间
function QShop:getOpenAtTime(shopId)
	if shopId == SHOP_ID.goblinShop then
		return self["goblinShop"].openedAt
	elseif shopId == SHOP_ID.blackShop then
		return self["blackShop"].openedAt
	end
end

--检查是否存在特殊商店
function QShop:checkMystoryStore(shopId)
	if shopId == SHOP_ID.goblinShop then
		if self["goblinShop"].shelves ~= nil then
			return true
		end
		return false
	elseif shopId == SHOP_ID.blackShop then
		if self["blackShop"].shelves ~= nil then
			return true
		end
		return false
	end
end

function QShop:checkShopRedTips()
	if app.unlock:getUnlockShop() and self:checkCanRefreshShop(SHOP_ID.generalShop) and self:checkHeroShopRedTipUnlock() then
		return true
	end

	if app.unlock:getUnlockHeroStore() and self:checkCanRefreshShop(SHOP_ID.soulShop) and self:checkHeroShopRedTipUnlock() then
		return true
	end

	if app.unlock:getUnlockShop2() then
		if QVIPUtil:enableBlackMarketPermanent() then
			if self:checkCanRefreshShop(SHOP_ID.blackShop) and self:checkMystoryStore(SHOP_ID.blackShop) then
				return true
			else
				return false
			end
		elseif self:checkMystoryStoreTimeOut(SHOP_ID.blackShop) and self:checkMystoryStore(SHOP_ID.blackShop) and 
			self:checkBlackIsNeedRedTips(SHOP_ID.blackShop) then

			return true
		end
	end

	return false
end

function QShop:checkFuncShopRedTips(shopId)
	local shopInfo = remote.stores:getShopResousceByShopId(shopId)
  	if remote.stores:checkCanRefreshShop(shopId) or remote.stores:checkAwardsShopCanBuyByShopId(shopInfo.arawdsId) then
  		return true
  	end
  	return false
end

function QShop:checkMallRedTips()
	local config = QStaticDatabase:sharedDatabase():getConfiguration()
	if self:checkVipShopRedTips() then
		return true
	elseif self:checkCanRefreshShop2(SHOP_ID.itemShop) then
		return true
	-- elseif remote.stores:checkWeekShopUnlock() and self:checkCanrefreshWeekMall() then
	-- 	return true
	elseif app.unlock:getUnlockEnchant() and 
		(remote.user.enchantIsFree or (not app.unlock:getUnlockSeniorRedPoint() and remote.items:getItemsNumByID(config["ENCHANT_BOX_KEY"].value) > 0 and (remote.user.enchantLuckyDrawCount or 0) < 100)) then
		return true
	elseif app.unlock:getUnlockMount() and (remote.user.mountIsFree or (not app.unlock:getUnlockSeniorRedPoint() and remote.items:getItemsNumByID(162) > 0)) then
		return true
	elseif app.unlock:getUnlockGemStone() and remote.stores:getSaleByShopItemId(SHOP_ID.itemShop, GEMSTONE_SHOP_ID) == 0 then
		return true
	elseif remote.magicHerb:checkMagicHerbUnlock() and (remote.user.magicHerbIsFree or (not app.unlock:getUnlockSeniorRedPoint() and remote.items:getItemsNumByID(MAGIC_HERB_ID) > 0)) then
		return true
	elseif remote.stores:checkSkinShopUnlock() and remote.stores:checkSkinShopRedPoint() then
		return true
	end
	return false
end	

function QShop:checkShopCanBuyById(shopId)
	if shopId == nil then return false end
	local storeItems = self:getStoresById(shopId)

	if storeItems == nil then return false end
	for key, value in pairs(storeItems) do
		if value.count ~= 0 then
			return true
		end
	end
	return false
end

function QShop:checkBlackIsNeedRedTips(shopId)
	local lastRefreshTime = self:getLastShopGetTimeById(shopId)
	local opentTime = self["blackShop"].openedAt or 0
	if lastRefreshTime < opentTime then 
		return true
	end 
	return false
end

--检查特殊商店存在是否超时
function QShop:checkMystoryStoreTimeOut(shopId)
	local time = q.serverTime()

	if shopId ~= SHOP_ID.blackShop then
		return true
	end

	--获取商店停留时间
	local stayTime = QStaticDatabase.sharedDatabase():getGroupIdByShopId(shopId).period_hour
	stayTime = stayTime * 60 * 60

	local opentTime = self["blackShop"].openedAt or 0
	if shopId == SHOP_ID.blackShop then
		if QVIPUtil:enableBlackMarketPermanent() then
			return true
		end
		local CDTime = opentTime/1000 + stayTime - 5
		if time < CDTime then
			return true
		end

		return false
	end
end

--根据商店ID保存相应商店下个刷新节点
function QShop:setNextRefershTime(shopId, time)	
	for key, shopID in pairs(SHOP_ID) do
		if shopID == shopId then
			self[key.."RefreshTime"] = time
			break
		end
	end
end

--根据商店ID获取相应商店下个刷新节点
function QShop:getNextRefershTime(shopId)
	for key, shopID in pairs(SHOP_ID) do
		if shopID == shopId then
			return self[key.."RefreshTime"]
		end
	end
end

--根据商店ID判断当前商店是否需要刷新
function QShop:checkCanRefreshShop(shopId)
	if self:checkShopCanBuyById(shopId) == false then
		return false
	end

	return self:checkCanRefreshShop2(shopId)
end

function QShop:checkCanRefreshShop2(shopId)
	local lastRefreshTime = self:getLastShopGetTimeById(shopId)/1000
	local beforeTime, nextTime = self:checkedShopBeforeRefreshTime(shopId)
	if lastRefreshTime < beforeTime then
		return true
	end
	return false
end
-- 皮肤商店红点判断
function QShop:checkSkinShopRedPoint()
	--策划后面说去掉红点
	-- local isTouch = app:getUserOperateRecord():compareCurrentTimeWithRecordeTime("SKIN_SHOP_READ")
	-- print("isTouch----",isTouch)
	-- if isTouch then
	-- 	local shopItems = remote.exchangeShop:getShopInfoById(SHOP_ID.skinShop)
	-- 	local showShopItems = {}
	-- 	local userLevel = remote.user.level or 0
	-- 	local vipLevel = QVIPUtil:VIPLevel() or 0	
	-- 	for i = 1, #shopItems do
	-- 		if userLevel >= shopItems[i].team_minlevel and userLevel <= shopItems[i].team_maxlevel and vipLevel >= shopItems[i].vip_id and
	-- 			remote.heroSkin:checkItemSkinIsHave(shopItems[i].item_id) == remote.heroSkin.ITEM_SKIN_NORMAL then
	-- 				showShopItems[#showShopItems+1] = shopItems[i]
	-- 		end
	-- 	end
	-- 	for _,v in pairs(showShopItems) do
	-- 		local haveNum = remote.items:getItemsNumByID(v.resource_item_1)
	-- 		if haveNum >= tonumber(v.resource_number_1) then
	-- 			return true
	-- 		end
	-- 	end
	-- end

	return false
end

function QShop:checkShopCanTutorial(shopId)
	local lastRefreshTime = self:getLastShopGetTimeById(shopId)/1000
	if self:checkHeroShopRedTipUnlock() and lastRefreshTime == 0 then
		return true
	end
	return false
end

function QShop:checkHeroShopRedTipUnlock()
	local config = QStaticDatabase:sharedDatabase():getConfiguration()
	if remote.user.level >= config["HEOR_SHOP_TUTORIAL_LEVEL"].value then
		return true
	end
	return false
end

--获取奖励商店上次调用shop_get 的时间
function QShop:getLastShopGetTimeById(shopId)
	for key, shopID in pairs(SHOP_ID) do
		if shopID == shopId then
			return self[key].last_call_get_shop_time or 0 
		end
	end
end

--计算普通商店个刷新时间点
function QShop:checkedShopBeforeRefreshTime(shopId)
	local lastTime = 0
	local nextTime = 0
	local refreshWord = ""

	local nowTime = q.serverTime()
	local timeInfo = QStaticDatabase.sharedDatabase():getGeneralShopRefreshTimeByID(shopId)
	if timeInfo == nil or timeInfo == "" then
		return lastTime, nextTime, refreshWord
	end
	local refreshTime = string.split(timeInfo, ";")
	local midnight = q.getTimeForHMS("24", "00", "00")

	local gapTime = {}
	gapTime[#gapTime+1] = q.getTimeForHMS(tostring(remote.user.c_systemRefreshTime), "00", "00") + 10
	for i = 1, #refreshTime, 1 do
		refreshTime[i] = string.split(refreshTime[i], ":")
		gapTime[#gapTime+1] = q.getTimeForHMS(refreshTime[i][1], refreshTime[i][2], refreshTime[i][3]) + 10
	end

	if next(gapTime) ~= nil then
		for i = 1, #gapTime, 1 do
			if gapTime[i+1] ~= nil and nowTime > gapTime[i] and nowTime <= gapTime[i+1] then
				lastTime = gapTime[i] 
				nextTime = gapTime[i+1] 
				refreshWord = refreshTime[i] ~= nil and "今日"..tostring(refreshTime[i][1]).."点" or ""
				break
			elseif gapTime[i+1] == nil then
				lastTime = gapTime[i] 
				nextTime = gapTime[1] + 24 * 3600
				refreshWord = refreshTime[1] ~= nil and "明日"..tostring(refreshTime[1][1]).."点" or ""
				break
			elseif nowTime < gapTime[i] then
				lastTime = gapTime[i] - 24 * 3600 
				nextTime = gapTime[i]
				refreshWord = refreshTime[i] ~= nil and "今日"..tostring(refreshTime[i][1]).."点" or ""
				break
			end
		end
	end

	return lastTime, nextTime, refreshWord
end

function QShop:getGloryFreeShopIdByFloor(floor)
	if floor == 1 then
		return 101, 401
	elseif floor == 2 then
		return 102, 402
	else
		return 103, 400 + tonumber(floor)
	end
end

function QShop:getShopResousceByShopId(shopId)
	local shopId = tostring(shopId)
	for key, value in pairs(self.shopInfo) do
		if value.shopId == shopId then
			return value
		end
	end
end 

function QShop:moveNextShop(shopId, direction, pushShop, quickBuy)
	if shopId == nil then return end
	
	if pushShop == nil then
		pushShop = true
	end

	if swithcShop[shopId] == nil then
		return true
	end

	if quickBuy == nil then
		quickBuy = false
	end
	local curShop = swithcShop[shopId]
	local nextShop = swithcShop[curShop.nextS]

	if direction == "left" then
		nextShop = swithcShop[curShop.preS]
	end

	while swithcShop[shopId].id ~= nextShop.id do
		local unlock, shopInfo = self:checkShopUnlockByShopId(nextShop.id)
		print("[QShop:moveNextShop()]", unlock, nextShop.id)
		local canQuickBuy = false
		if quickBuy then 
			local shopData = self:getShopResousceByShopId(nextShop.id)
			local unlockQuickBuy = false 
			if shopData.quickBuy then
				local shopInfo = QStaticDatabase:sharedDatabase():getShopDataByID(nextShop.id)
				if q.isEmpty(shopInfo) == false then
					local unlockData = app.unlock:getConfigByKey(shopInfo.unlock_shop) or {}
					local configLevel = QStaticDatabase:sharedDatabase():getConfiguration()["show_button"].value or 0
					unlockQuickBuy = remote.user.level >= (unlockData.team_level or 0) + configLevel
				else
					print("shopInfo is nil, current shop is "..shopId .. ", next shopId is "..nextShop.id)
				end
			end
			if unlockQuickBuy and shopData.quickBuy then
				canQuickBuy = true
			end
		end

		if unlock and (quickBuy == false or canQuickBuy == true) then
			local temp = true
			if nextShop.id == "3" and (next(shopInfo) == nil or self:checkMystoryStoreTimeOut(nextShop.id) == false) then
				temp = false
			elseif nextShop.id == "601" and (not remote.user.userConsortia.consortiaId or remote.user.userConsortia.consortiaId == "") then
				temp = false
			end
			if temp then
				if pushShop and quickBuy == false then
					-- self:pushNextShop(nextShop.id)
				end
				return false, nextShop.id
			end
		end
		if direction == "left" then
			nextShop = swithcShop[nextShop.preS]
		else
			nextShop = swithcShop[nextShop.nextS]
		end
	end

	return true
end

function QShop:pushNextShop(shopId)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER, nil)
	self:openShopDialog(shopId)
end

function QShop:openShopDialog(shopId,callBack)
	if shopId == nil then return end
	print("打开的商店IDshopId=",shopId)
	-- local shopInfo = self:getShopResousceByShopId(shopId)
	-- local className = shopInfo.className or "QUIDialogStore"
	self.firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if self.firstDialog and self.firstDialog.class.__cname == "QUIDialogArenaStore" then
		if self.firstDialog.openQucikShopByShopId then
			self.firstDialog:openQucikShopByShopId(shopId)
		end
	else
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogArenaStore", options = {type = shopId, callback = callBack}}, {options = {noScheduler = true}})
	end
end

function QShop:checkShopNeedItemByShopId(shopId)
	local storesInfo = self:getStoresById(shopId)
	if storesInfo == nil then return true end
    for i = 1, #storesInfo, 1 do 
    	if storesInfo[i].id ~= 0 then
    		return self:checkItemIsNeed(storesInfo[i].id, storesInfo[i].count)
		end
    end
    return false
end

function QShop:checkMaterialIsNeed(itemId, itemNum)
	local items = QStaticDatabase:sharedDatabase():getItemByID(itemId)
	if items == nil then return false end
	if items.type == ITEM_CONFIG_TYPE.MATERIAL then
		local equMaterial = remote.herosUtil:getAllHeroBreakNeedItem(true)
        if equMaterial[itemId] ~= nil and equMaterial[itemId] > 0 and itemNum > 0 then
        	return true 
        end
    end
    return false
end

function QShop:checkItemIsNeed(itemId, itemNum)
	local items = QStaticDatabase:sharedDatabase():getItemByID(itemId)
	if items == nil then return false end
	if items.type == ITEM_CONFIG_TYPE.MATERIAL then
		local equMaterial = remote.herosUtil:getAllHeroBreakNeedItem(true)
        if equMaterial[itemId] ~= nil and equMaterial[itemId] > 0 and itemNum > 0 then
        	return true 
        end
    elseif items.type == ITEM_CONFIG_TYPE.SOUL then
    	local actorId = QStaticDatabase:sharedDatabase():getActorIdBySoulId(itemId)
    	return remote.herosUtil:checkHeroIsNeed(actorId)
    end
    return false
end

function QShop:checkAwardsShopCanBuyByShopId(awardsShopId)
	local awardsInfo = QStaticDatabase:sharedDatabase():getItemsByShopAwardsId(awardsShopId)
	if awardsInfo == nil then return end

	local sellInfo = self:getAwardsShopById(tostring(awardsShopId))
	if sellInfo == nil or sellInfo == "" then 
		sellInfo = {}
	end
	sellInfo = string.split(sellInfo, ";")

	local index = 1
	local canBuy = false
	local condition = 0
	local currency = 9999999999
	local isRedTip = false
	local maxPosition = 0

	for i = 1, #awardsInfo, 1 do
		local canBuy, condition, currency = self:checkAwardsCanBuy(awardsInfo[i])
		if canBuy then
			for i = 1, #sellInfo, 1 do
				if tonumber(sellInfo[i]) == index-1 then
					canBuy = false
				end
			end
		end

		if canBuy then
			return true, condition, currency
		end
		index = index + 1
	end
	return false, condition, currency
end

-- 检查vip商城小红点
function QShop:checkVipShopRedTips()
	if ENABLE_CHARGE() == false then 
		return false
	end

	local vipItem = self:getStoresById(SHOP_ID.vipShop)
	if vipItem == nil then return false end

	for i = 1, #vipItem, 1 do
		local goodInfo = QStaticDatabase:sharedDatabase():getGoodsGroupByGroupId(vipItem[i].good_group_id)
		if goodInfo == nil then break end
		if vipItem[i].count > 0 and (goodInfo.vip_buy or 0) <= QVIPUtil:VIPLevel() then
			return true
		end
	end
	return false
end

-- 检查每周礼包商城小红点
function QShop:checkCanrefreshWeekMall()
	local lastRefreshTime = self:getLastShopGetTimeById(SHOP_ID.weekShop)/1000
	local beforeTime = q.date("*t", q.serverTime())
	if beforeTime.wday < 2 or (beforeTime.wday == 2 and beforeTime.hour < 5) then
		beforeTime.day = beforeTime.day - beforeTime.wday - 5
	else
		beforeTime.day = beforeTime.day - beforeTime.wday + 2
	end
    beforeTime.hour = 5
    beforeTime.min = 0
    beforeTime.sec = 0
    beforeTime = q.OSTime(beforeTime)

    QPrintTable(q.date("*t", beforeTime))

	if lastRefreshTime < beforeTime then
		return true
	end
	return false
end

-- 检查每周礼包商城是否解锁
-- return true is Unlock
function QShop:checkWeekShopUnlock()
	-- xurui: close week shop
	if true then return false end

    local unlockTime = q.date("*t", (remote.user.openServerTime or 0)/1000)
    unlockTime.day = unlockTime.day + 7
    unlockTime.hour = 5
    unlockTime.min = 0
    unlockTime.sec = 0
    unlockTime = q.OSTime(unlockTime) or 0

    if q.serverTime() >= unlockTime then
    	return true
    end
	return false
end

function QShop:checkSkinShopUnlock()
	local nowTime = q.serverTime()
	local openServerTime = (remote.user.openServerTime or 0) / 1000
	local offsetTime = (nowTime - openServerTime) / DAY
	if offsetTime > 0 then 
		return true
	else
		return false
	end
end

function QShop:checkShopCurrencyQuickWay(currencyType)
	if currencyType == ITEM_TYPE.RUSH_BUY_MONEY then
		app:vipAlert({title = "6元夺宝", textType = VIPALERT_TYPE.NO_RUSH_BUY_MONEY}, false)
	elseif currencyType == ITEM_TYPE.TOKEN_MONEY then
		QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, currencyType, nil, nil, false)
	else
		QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, currencyType, nil, nil, false)
	end
end

-- 在非商城界面购买道具商城的物品
function QShop:buyMallItemById(itemId, callBack)	
	local shopInfo = self:getStoresById(SHOP_ID.itemShop)
	local itemInfo = {}
	for i = 1, #shopInfo do
		if itemId == shopInfo[i].id then
			itemInfo = shopInfo[i]
			break
		end
	end
	if next(itemInfo) == nil then return end

	local maxCount = QVIPUtil:getMallItemMaxCountByVipLevel(itemInfo.good_group_id, QVIPUtil:VIPLevel())
	assert(maxCount, "shop_limit_".. itemInfo.good_group_id .. " is null! when vip is ".. QVIPUtil:VIPLevel())
	if maxCount - itemInfo.buy_count <= 0 then
		if QVIPUtil:VIPLevel() < QVIPUtil:getMaxLevel() then
			app:vipAlert({content="购买次数已达上限，提升VIP等级可提高购买次数上限"}, false)
		else
			app.tip:floatTip("今日的购买次数已用完")
		end
		return
	end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMallDetail", 
		options = {shopId = SHOP_ID.itemShop, itemInfo = itemInfo, maxNum = maxCount, pos = itemInfo.position, callBack = callBack}})
end

-- 获取商店中的所有物品（去重）
function QShop:getShopAllItemsByShopId(shopId)
	if shopId == nil then return {} end
	local shopData = QStaticDatabase:sharedDatabase():getShopDataByID(shopId)

	local shopItems = {}
	local index = 1
	while shopData["good_group_"..index] do
		local items = QStaticDatabase:sharedDatabase():getGoodsGroupByGroupId(shopData["good_group_"..index])
		local i = 1
		while items["type_"..i] do
			local id = items["id_"..i]
			if items["id_"..i] == nil then
				id = items["type_"..i]
			end
			local moneyNum = (items["money_num_"..i] or 0) / (items["num_"..i] / 1)
			if db:checkItemShields(items["id_"..i]) then
				print("被屏蔽英雄id: "..items["id_"..i])
			elseif shopItems[id] == nil then
				shopItems[id] = {}
				shopItems[id][1] = {id = items["id_"..i], itemType = items["type_"..i], count = items["num_"..i], moneyType = items["money_type_"..i], moneyNum = moneyNum}
			elseif shopItems[id][1].moneyType ~= items["money_type_"..i] then
				shopItems[id][2] = {id = items["id_"..i], itemType = items["type_"..i], count = items["num_"..i], moneyType = items["money_type_"..i], moneyNum = moneyNum}
			end
			i = i + 1
		end
		index = index + 1
	end

	local items = {}
	for _, value in pairs(shopItems) do
		table.insert(items, value)
	end
	table.sort(items, function(a, b)
			local itemsInfo1 = QStaticDatabase:sharedDatabase():getItemByID(a[1].id)
			if itemsInfo1 == nil then
				itemsInfo1 = remote.items:getWalletByType(a[1].itemType)
			end
			local itemsInfo2 = QStaticDatabase:sharedDatabase():getItemByID(b[1].id)
			if itemsInfo2 == nil then
				itemsInfo2 = remote.items:getWalletByType(b[1].itemType)
			end

			if itemsInfo1.type == ITEM_CONFIG_TYPE.SOUL and itemsInfo2.type ~= ITEM_CONFIG_TYPE.SOUL then
				return true
			elseif itemsInfo1.type ~= ITEM_CONFIG_TYPE.SOUL and itemsInfo2.type == ITEM_CONFIG_TYPE.SOUL then
				return false
			elseif itemsInfo1.type == ITEM_CONFIG_TYPE.SOUL and itemsInfo2.type == ITEM_CONFIG_TYPE.SOUL then
				local actorId1 = QStaticDatabase:sharedDatabase():getActorIdBySoulId(itemsInfo1.id)
				local characher1 = QStaticDatabase:sharedDatabase():getCharacterByID(actorId1)
				local actorId2 = QStaticDatabase:sharedDatabase():getActorIdBySoulId(itemsInfo2.id)
				local characher2 = QStaticDatabase:sharedDatabase():getCharacterByID(actorId2)

				return characher1.aptitude > characher2.aptitude
			elseif itemsInfo1.colour ~= itemsInfo2.colour then
			 	return itemsInfo1.colour > itemsInfo2.colour
			else
				return itemsInfo1.id > itemsInfo2.id
			end
		end)

	local newItems = {}
	for _, value in pairs(items) do
		if value[1].moneyType == "token" then
			table.insert(newItems, value[2])
			table.insert(newItems, value[1])
		else
			table.insert(newItems, value[1])
			table.insert(newItems, value[2])
		end
	end

	return newItems
end



function QShop:getShopAllItemsByShopId2(shopId)
	if shopId == nil then return {} end
	local shopData = QStaticDatabase:sharedDatabase():getShopDataByID(shopId)

	local shopItems = {}
	local index = 1
	while shopData["good_group_"..index] do
		local items = QStaticDatabase:sharedDatabase():getGoodsGroupByGroupId(shopData["good_group_"..index])

		local i = 1
		while items["type_"..i] do
			local id = items["id_"..i]
			local itemType = remote.items:getItemType(items["type_"..i])
			if items["id_"..i] == nil then
				id = itemType
			end
			if itemType ~= nil and not db:checkItemShields(items["id_"..i]) then
				local moneyNum =(items["money_num_"..i] or 0) / (items["num_"..i] / 1)
				-- moneyNum = tonumber(string.format("%.2f",moneyNum))
				if shopItems[id] == nil then
					shopItems[id] = {}
					shopItems[id][1] = {id = items["id_"..i], itemType = items["type_"..i], count = items["num_"..i], moneyType = items["money_type_"..i], moneyNum = moneyNum ,sale = items["money_discount_"..i] or 1}
				else
					local ifHadSameType = false
					for _ ,value in pairs(shopItems[id]) do
						if value.moneyType == items["money_type_"..i] then
							if value.sale == items["money_discount_"..i] then
								ifHadSameType = true
							end
						end
					end
					if ifHadSameType == false then
						shopItems[id][#shopItems[id] + 1] = {id = items["id_"..i], itemType = items["type_"..i], count = items["num_"..i], moneyType = items["money_type_"..i], moneyNum = moneyNum,sale = items["money_discount_"..i] or 1}
					end
				end
			end
			i = i + 1
		end
		index = index + 1
	end

	local items = {}
	for _, value in pairs(shopItems) do
		table.insert(items, value)
	end

	local newItems = {}
	for _, value in pairs(items) do
		if value[1].moneyType == "token" and value[1].sale == 1 then
			table.insert(newItems, value[2])
			table.insert(newItems, value[1])
			table.insert(newItems, value[3])
			table.insert(newItems, value[4])
		elseif value[1].moneyType == "token" and value[1].sale ~= 1 then
			table.insert(newItems, value[2])
			table.insert(newItems, value[3])
			table.insert(newItems, value[1])
			table.insert(newItems, value[4])
		elseif value[1].moneyType ~= "token" and value[2] and value[2].sale == 1 then
			table.insert(newItems, value[1])
			table.insert(newItems, value[2])
			table.insert(newItems, value[3])
			table.insert(newItems, value[4])
		elseif value[1].moneyType ~= "token" and value[2] and value[2].sale ~= 1 then
			table.insert(newItems, value[1])
			table.insert(newItems, value[3])
			table.insert(newItems, value[2])
			table.insert(newItems, value[4])
		else
			table.insert(newItems, value[1])
			table.insert(newItems, value[2])
			table.insert(newItems, value[3])
			table.insert(newItems, value[4])
		end
	end
	return newItems
end

function QShop:checkQuickBuyItemById(shopId, chooseItems, isShowQucikWay)
	if shopId == nil then return {} end

	local shopItems = clone(self:getStoresById(shopId))
	if shopItems == nil then return {} end

	local quickItemToken = nil
	local quickItemCurrency = nil
	local buyToken = 0
	local buyCurrency = 0
	local buyItems = {}
	for _, value in pairs(shopItems) do
		local id = value.id
		if value.itemType ~= "item" then 
			id = value.itemType
		end

		if value.count > 0 and chooseItems[id] and  (
			 ( chooseItems[id][1] and chooseItems[id][1].moneyType == string.lower(value.moneyType)  and tostring(chooseItems[id][1].moneyNum) == string.format(tonumber(value.cost)/tonumber(value.count)) ) or
			 ( chooseItems[id][2] and chooseItems[id][2].moneyType == string.lower(value.moneyType)  and tostring(chooseItems[id][2].moneyNum) == string.format(tonumber(value.cost)/tonumber(value.count)) ) or
			 ( chooseItems[id][3] and chooseItems[id][3].moneyType == string.lower(value.moneyType)  and tostring(chooseItems[id][3].moneyNum) == string.format(tonumber(value.cost)/tonumber(value.count)) ) or 
			 ( chooseItems[id][4] and chooseItems[id][4].moneyType == string.lower(value.moneyType)  and tostring(chooseItems[id][4].moneyNum) == string.format(tonumber(value.cost)/tonumber(value.count)) ) )then

			local currencyInfo = remote.items:getWalletByType(value.moneyType)
			local money = remote.user[currencyInfo.name] or 0
			
			if value.moneyType == "TOKEN" then
				if money >= buyToken + value.cost then
					buyToken = buyToken + value.cost
					buyItems[#buyItems+1] = value
				elseif (quickItemToken == nil or quickItemToken.cost < value.cost) then
					quickItemToken = value
					quickItemToken.quickName = currencyInfo.name
				end
			else
				if money >= buyCurrency + value.cost then
					buyCurrency = buyCurrency + value.cost
					buyItems[#buyItems+1] = value
			 	elseif (quickItemCurrency == nil or quickItemCurrency.cost < value.cost) then
					quickItemCurrency = value
					quickItemCurrency.quickName = currencyInfo.name
				end
			end
		end
	end

	if isShowQucikWay and (quickItemCurrency or quickItemToken) and next(buyItems) == nil then
		local name = nil
		if quickItemCurrency then
			name = quickItemCurrency.quickName
		elseif quickItemToken then
			name = quickItemToken.quickName
		end
		--self:checkShopCurrencyQuickWay(name)
		return {}, false
	end

	local canBuy = true
	if quickItemCurrency or quickItemToken then
		canBuy = false
	end

	return buyItems, canBuy, buyToken, buyCurrency, quickItemCurrency, quickItemToken
end

function QShop:getShopRefreshToken(refreshCount, refreshType)
	local tokeNum = 0
	local refreshInfo = QStaticDatabase:sharedDatabase():getTokenConsumeByType(refreshType)
	if refreshInfo ~= nil then
		for _, value in pairs(refreshInfo) do
			if value.consume_times == refreshCount + 1 then
				return value.money_num, value.money_type
			end
		end
	end
	return refreshInfo[#refreshInfo].money_num, refreshInfo[#refreshInfo].money_type
end

function QShop:getQuickBuyShopTitleById(shopId)
    local iconPath = QResPath("shop_quick_buy_title_"..tostring(shopId))
    iconPath = QSpriteFrameByPath(iconPath[1])
	return iconPath
end

-- 获取宝箱折扣 isTrueSale是否实际折扣
function QShop:getSaleByShopItemId(shopId, itemId, isTrueSale)
	local shopItems = self:getStoresById(shopId or SHOP_ID.itemShop) or {}
	local itemInfo
	for i, v in pairs(shopItems) do
		if v.id == itemId then
			itemInfo = v
			break
		end
	end
	return self:getSaleByShopItemInfo(itemInfo, isTrueSale)
end

-- 获取宝箱折扣 isTrueSale是否实际折扣
function QShop:getSaleByShopItemInfo(itemInfo, isTrueSale)
	if not itemInfo or not next(itemInfo) then
		return 0
	end

	local goodInfo = QStaticDatabase:sharedDatabase():getGoodsGroupByGroupId(itemInfo.good_group_id)
	local oldMoney = goodInfo.money_num_1 or 0
   	local realMoney = self:getBuyMoneyByBuyCount(itemInfo.buy_count, itemInfo.good_group_id)

   	local sale = 0
   	if isTrueSale then
   		sale = math.floor(realMoney/oldMoney * 100)/10
   	else
		local discount = {0, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5}
		sale = realMoney/oldMoney * 10
		for i = 2, #discount do
			if sale < discount[i] then
				sale = discount[i-1]
				break
			end
		end
	end

	return sale
end

function QShop:getBuyMoneyByBuyCount(buyCount, goodGroupId)
	local moneyInfo = QStaticDatabase:sharedDatabase():getTokenConsumeByType(tostring(goodGroupId))
	if moneyInfo ~= nil then
		for _, value in pairs(moneyInfo) do
			if value.consume_times == buyCount + 1 then
				return value.money_num
			end
		end
		return moneyInfo[#moneyInfo].money_num
	end

	return 0
end

function QShop:checkVipAwardRedTips()
	local shopItems = self:getStoresById(SHOP_ID.vipShop)
	if shopItems ~= nil then
		for i = 1, #shopItems, 1 do
			local vipLevel = QVIPUtil:getVIPLevelByShopId(shopItems[i].good_group_id)
			if shopItems[i].count > 0 and vipLevel and vipLevel <= QVIPUtil:VIPLevel() then
				return true
			end
		end
	end

	return false
end

-- 道具屏蔽
function QShop:checkHeroSwitch(value)
	local shelves = value.shelves or {}
	for i, v in pairs(shelves) do
		if db:checkItemShields(v.id) then
	       v.id = -1
	    end
	end
    return false
end

function QShop:checkShopUnlockByShopId(shopId)
	if shopId == nil then return end

	if shopId == "1" then
		return app.unlock:getUnlockShop(), self["generalShop"]
	elseif shopId == "2" then
		return app.unlock:getUnlockShop1(), self["goblinShop"]
	elseif shopId == "3" then
		return (app.unlock:getUnlockShop2() and self:checkMystoryStore(SHOP_ID.blackShop)), self["blackShop"]
	elseif shopId == "4" then
		return app.unlock:getUnlockArena(), self["arenaShop"]
	elseif shopId == "5" then
		return app.unlock:checkLock("UNLOCK_SUNWELL"), self["sunwellShop"]
	elseif shopId == "501" then
		return app.unlock:getUnlockHeroStore(), self["soulShop"]
	elseif shopId == "101" then
		return app.unlock:getUnlockGloryTower(), self["gloryTowerShop"]
	elseif shopId == "601" then
		return app.unlock:checkLock("UNLOCK_UNION"), self["consortiaShop"]
	elseif shopId == "91" then
		return app.unlock:getUnlockThunder(), self["thunderShop"]
	elseif shopId == "1001" then
		return app.unlock:getUnlockInvasion(), self["invasionShop"]
	elseif shopId == "801" then
		return app.unlock:getUnlockSilverMine(), nil
	elseif shopId == "802" then
		return app.unlock:checkLock("UNLOCK_METALCITY"), nil
	elseif shopId == "808" then
		return app.unlock:checkLock("UNLOCK_BLACKROCK"), nil
	elseif shopId == "804" then
		local imp = remote.activityRounds:getRushBuy()
		if imp and imp.isOpen then
			return true, nil
		end
	elseif shopId == "805" then
		return remote.unionDragonWar:checkDragonWarUnlock()
	elseif shopId == "806" then
		return app.unlock:checkLock("UNLOCK_FIGHT_CLUB")
	elseif shopId == "807" then
		return app.unlock:checkLock("UNLOCK_SANCTRUARY")
	elseif shopId == "901" then
		return app.unlock:checkLock("UNLOCK_ARTIFACT")
	elseif shopId == "809" then
		local nowTime = q.serverTime()
		local openServerTime = (remote.user.openServerTime or 0) / 1000
		local offsetTime = (nowTime - openServerTime) / DAY
		if offsetTime > 14 then 
			return remote.crystal:getIsOpenCrystalShop(),nil
		else
			return false,nil
		end
	elseif shopId == SHOP_ID.monthSignInShop then
		return remote.monthSignIn:isNewMonthSignInOpen(),nil
	elseif shopId == SHOP_ID.mockbattleShop then
		return remote.mockbattle:checkMockBattleIsUnLock() and remote.mockbattle:checkIsInSeason()
	elseif shopId == SHOP_ID.godarmShop then
		return remote.totemChallenge:checkTotemChallengeUnlock()
	elseif shopId == SHOP_ID.monthSignInShop then
		return remote.monthSignIn:checkMonthSignInIsOpen()
	elseif shopId == SHOP_ID.silvesShop then
		return remote.silvesArena:checkUnlock()
	end
end 


function QShop:checkAwardsCanBuy(awardsInfo,opStr)
	local canBuy = false
	local condition = 0
	local currency = 9999999999
	if awardsInfo.term == "jjc_rank" then
		condition = remote.user.arenaTopRank or 9999999999
		canBuy = condition <= tonumber(awardsInfo.team_num) 
		currency = remote.user.arenaMoney or 0
	elseif awardsInfo.term == "star" then
		condition = remote.sunWar:getLastPassedWave() or 0
		canBuy = condition >= tonumber(awardsInfo.team_num)
		currency = remote.user.sunwellMoney or 0
	elseif awardsInfo.term == "honor_rank" then
		condition = remote.user.towerMaxFloor or 0
		canBuy = condition >= tonumber(awardsInfo.team_num)
		currency = remote.user.towerMoney or 0
	elseif awardsInfo.term == "honor_rank_2" then
		condition = remote.user.gloryCompetitionTopRank or 9999999999
		canBuy = condition <= tonumber(awardsInfo.team_num)
		currency = remote.user.towerMoney or 0
	elseif awardsInfo.term == "scoiety_level" then
		condition = remote.union.consortia.level or 0
		canBuy = condition >= tonumber(awardsInfo.team_num)
		currency = remote.user.towerMoney or 0
	elseif awardsInfo.term == "leidian_star" then
		condition = remote.user.thunderHistoryMaxStar or 0
		canBuy = condition >= tonumber(awardsInfo.team_num)
		currency = remote.user.thunderMoney or 0
	elseif awardsInfo.term == "intrusion_damage" then
		condition = remote.invasion:getSelfInvasion().historyMaxHurt or 0
		canBuy = condition >= tonumber(awardsInfo.team_num)   
		currency = remote.user.intrusion_money or 0
	elseif awardsInfo.term  == "silvermine_level" then
		condition = remote.silverMine:getMiningLv() or 0
		canBuy = condition >= tonumber(awardsInfo.team_num)
		currency = remote.user.silvermineMoney or 0
	elseif awardsInfo.term  == "num" then
		condition = remote.metalCity:getMetalCityMyInfo().metalNum or 0
		canBuy = condition >= tonumber(awardsInfo.team_num)
		currency = remote.user.stormMoney or 0
	elseif awardsInfo.term  == "black_rock_integral" then
		condition = (remote.blackrock:getMyInfo() or {}).totalScore or 0
		canBuy = condition >= tonumber(awardsInfo.team_num)
		currency = remote.user.teamMoney or 0
	elseif awardsInfo.term  == "sociaty_dan" then
		condition = (remote.unionDragonWar:getMyDragonFighterInfo() or {}).maxFloor or 0
		canBuy = condition >= tonumber(awardsInfo.team_num)
		currency = remote.user.dragonWarMoney or 0
	elseif awardsInfo.term  == "spar_lev" then
		condition = remote.sparField:getSparFieldLevel()
		canBuy = condition >= tonumber(awardsInfo.team_num)
		currency = remote.user.jewelryMoney or 0
	elseif awardsInfo.term  == "suotuo_rank" then
		condition = remote.user.stormTopRank or 10000000
		canBuy = condition <= tonumber(awardsInfo.team_num)
		currency = remote.user.maritimeMoney or 0
	elseif awardsInfo.term  == "sanctuary_money" then
		condition = remote.sanctuary:getTotalBetMoney() or 0
		canBuy = condition >= tonumber(awardsInfo.team_num)
		currency = remote.user.sanctuaryMoney or 0
	elseif awardsInfo.term == "mock_battle_integral" then
		condition = remote.mockbattle:getMockBattleUserInfo().maxScore or  0
		canBuy = condition >= tonumber(awardsInfo.team_num) 
		currency = remote.mockbattle:getMockBattleUserInfo().maxScore or 0
	elseif awardsInfo.term == "totemchallenge" then
		condition = remote.totemChallenge:getTotemUserDungeonInfo().fightSuccessCount or  0
		canBuy = condition >= tonumber(awardsInfo.team_num) 
		currency = remote.totemChallenge:getTotemUserDungeonInfo().fightSuccessCount or 0

	elseif awardsInfo.term == "silves_arena_gold_money" then
		-- condition = remote.user.silvesarenagoldMoney or 0
		-- canBuy = condition >= tonumber(awardsInfo.team_num)
		-- currency = remote.user.silvesarenagoldMoney or 0
	elseif awardsInfo.term == "silves_arena_silver_money" then
		condition = remote.silvesArena:getTotalSilvesArenaMoneyCount()
		canBuy = condition >= tonumber(awardsInfo.team_num)
		currency = remote.user.silvesarenasilverMoney
	end
 
	return canBuy, condition, currency
end

function QShop:checkShopCanBuy(shopInfo)
	if tonumber(shopInfo.shop_id) == tonumber(SHOP_ID.blackRockShop) then
		return remote.blackrock:checkShopIdCanBeBuy(shopInfo.condition_num)
	end

	if tonumber(shopInfo.shop_id) == tonumber(SHOP_ID.monthSignInShop) then
		return remote.monthSignIn:checkShopIdCanBeBuy(shopInfo.condition_num)
	end

	return true
end
-- 检查等级区间是否有新物品展示
function QShop:checkNewShopGoodsView(shopId)
	if shopId == nil then return false end
	local teamLevelMin = 0 
	local teamLevelMax = 0 
	local shopData = QStaticDatabase:sharedDatabase():getShopDataByID(shopId)
	if  shopData["good_group_1"] then
		teamLevelMin,teamLevelMax = QStaticDatabase:sharedDatabase():getGoodsLevleIntervalByGroupId(shopData["good_group_1"])
	end

	local teamLevleInterval = app:getUserOperateRecord():getTeamLevleInterval()

	if teamLevleInterval == nil then 
		app:getUserOperateRecord():setTeamLevleInterval(teamLevelMin,teamLevelMax)
	end
	
	teamLevleInterval = app:getUserOperateRecord():getTeamLevleInterval()

	print("teamLevleInterval.teamLevelMax=",teamLevleInterval.teamLevelMax)
	if remote.user.level > teamLevleInterval.teamLevelMax then
		app:getUserOperateRecord():setTeamLevleInterval(teamLevelMin,teamLevelMax)
		return true
	end

	return false
end

return QShop
