--MysteryShopManager.lua
--/*-----------------------------------------------------------------
 --* Module:  MysteryShopManager.lua
 --* Author:  HE Ningxu
 --* Modified: 2014年5月14日
 --* Purpose: Implementation of the class MysteryShopManager
 -------------------------------------------------------------------*/

require ("system.trade.MystUserInfo")
 
MysteryShopManager = class(nil, Singleton, Timer)

function MysteryShopManager:__init()
	self._mysteryshopActive = 1
	self._user = {} 				--运行时ID
	--{ [2 魂值神秘] = { [1 最低等级]={lmax=最高等级 [4 货币类型 魂值] = {{物品1信息}{物品2信息} 所有的这个等级的记录} {} } } }
	self._source = {}				
	self._shop = {}
	
	self._bookShopInfoNums = 0 								--书店商城配置的商品信息条数
	self:loadMystConfig()

	--_shop存放每个等级随机  4个元宝商城物品  6个魂值商城物品
	--{ [3 元宝神秘] = { [1 最低等级]={lmax=最高等级 [4 货币类型 魂值] = {{物品1信息}{物品2信息}  规定4条 }  }
	self._shop = self:updateAll()
	self._loadBlackMall = false
	--self._nextRefreshTick = self:getNextRefreshTick() 	--下次刷新的时间戳
	self._timeTick = time.toedition("day") 					--日期时间戳
	self._lastRefreshTime = {}
	self._lastRefreshTime[1] = self:lastRefreshHour() 		--{神秘商店最近的一次刷新时间(小时)}

	self._updateMinite = 0  								--math.random(5) --神秘商店随机刷新
	--if self._updateMinite < 1 then
		--self._updateMinite = 1
	--end

	self._speInfo = {0} 									--记录神秘商店一些特殊信息 {[麒麟ID] = 坐骑ID}

	g_listHandler:addListener(self)
	gTimerMgr:regTimer(self,1000,1000)
	print("MysteryShopManager Timer ID: ", self._timerID_, self._updateMinite)
end

function MysteryShopManager:lastRefreshHour()
	local nowHour = tonumber(os.date("%H"))
	if nowHour < 12 then
		return 0
	end
	return 12
end

function MysteryShopManager:setIsLoadBlackMyst(value)
	self._loadBlackMall = value
end

function MysteryShopManager:getIsLoadBlackMyst()
	return self._loadBlackMall
end

function MysteryShopManager:onloadMystShopData(data)
	if data then
		local dataTmp = unserialize(data)
		if dataTmp.blackTick == self._timeTick and dataTmp.blackRH == self._lastRefreshTime[1] then
			if dataTmp.black and table.size(dataTmp.black) > 0 then
				if self._shop[MYSTERYSHOP_BLACK] then
					self._shop[MYSTERYSHOP_BLACK] = table.deepcopy(dataTmp.black)
					self._loadBlackMall = true
					return
				end
			end
		end
	end
	
	self:cast2DBMystShopData()
	self._loadBlackMall = true
end

function MysteryShopManager:cast2DBMystShopData()
	local balckMallData = {}
	balckMallData.black = self._shop[MYSTERYSHOP_BLACK]
	balckMallData.blackTick = self._timeTick
	balckMallData.blackRH = self._lastRefreshTime[1]

	updateCommonData(COMMON_DATA_ID_MYSTSHOP,balckMallData)
end

function MysteryShopManager:getBlackMystData(minLevel)
	if self._shop[MYSTERYSHOP_BLACK] and self._shop[MYSTERYSHOP_BLACK][minLevel] then
		return self._shop[MYSTERYSHOP_BLACK][minLevel]
	end
end

function MysteryShopManager:getBookMystData(minLevel)
	if self._shop[MYSTERYSHOP_BOOK] and self._shop[MYSTERYSHOP_BOOK][minLevel] then
		return self._shop[MYSTERYSHOP_BOOK][minLevel]
	end
end

function MysteryShopManager.loadDBData(player, cacha_buf, roleSid)
	g_mystShopMgr:loadDBDataImpl(player, cacha_buf, roleSid)
end

function MysteryShopManager:loadDBDataImpl(player, cacha_buf, roleSid)
	if not player then return end
	local SID = player:getSerialID()
	local UID = player:getID()

	local User = self:getUserInfo(SID)
	if not User then
		User = MystUserInfo(UID, SID)
		self._user[SID] = User
	end
	
	if User then
		User:loadDB(cacha_buf)
	end
end

function MysteryShopManager:onLevelChanged(player)
	if player then
		local SID = player:getSerialID()
		local User = self:getUserInfo(SID)
		if User then
			User:upLevelInit(player)
		end
	end
end

function MysteryShopManager:getRand(all, num)
	local ret = {}
	local mark = {}

	--短时间内取到大量不重复随机数
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	for p = 1, num do
	
		local randMax = 0
		for i, v in pairs(all or {}) do
			if v and not mark[i] then
				randMax = randMax + tonumber(v.prob)
			end
		end

		local rand = math.random(randMax)
		for i = 1, #all do
			if all[i] and not mark[i] then
				if rand <= tonumber(all[i].prob) then
					ret[p] = all[i]
					mark[i] = true
					break
				else
					rand = rand - tonumber(all[i].prob)
				end
			end
		end
	end
	return ret
end

function MysteryShopManager:getShop(group, index)
	local tmp = group.shop
	local ret = {}
	if MYSTERYSHOP_SMELTER == index then
		--ret[1] = self:getRand(tmp[1], MYSTERYSHOP_3_INGOT_ITEM_NUM)
		ret[4] = self:getRand(tmp[4], MYSTERYSHOP_3_SOUL_ITEM_NUM) 	--20160108   神秘商城  熔炼值商品
	end

	if MYSTERYSHOP_BLACK == index then
		ret[1] = self:getRand(tmp[1], MYSTERYSHOP_4_INGOT_ITEM_NUM)
	end

	if MYSTERYSHOP_BOOK == index then
		ret[3] = self:getRand(tmp[3], self._bookShopInfoNums)
	end

	ret.lmax = group.lmax
	return ret
end

function MysteryShopManager:updateAll()
	local shop = {}
	for i, v in pairs(self._source) do  	--i  2魂值神秘商店  3元宝vip神秘商店
		if not shop[i] then
			shop[i] = {}
		end
		for l, w in pairs(v) do       		--l  最低等级
			shop[i][l] = table.deepcopy(self:getShop(w, i))
		end
	end
	return shop
end

function MysteryShopManager:updateSingle(id)
	local shop = {}
	for i, v in pairs(self._source) do
		if i==id then
			if not shop[i] then
				shop[i] = {}
			end

			for l, w in pairs(v) do       		--l  最低等级
				shop[i][l] = table.deepcopy(self:getShop(w, i))
			end
		end
	end
	return shop[id]
end


function MysteryShopManager:update()
	local nowHour = tonumber(os.date("%H"))
	if 0==nowHour or 12==nowHour or 18==nowHour then
		local nowMinite = tonumber(os.date("%M"))
		local nowSecond = tonumber(os.date("%S"))

		if self._updateMinite==nowMinite and 1==nowSecond then
			self._timeTick = time.toedition("day")
			self._lastRefreshTime[1] = nowHour
			
			if 12==nowHour or 18==nowHour then
				self._shop[MYSTERYSHOP_BLACK] = self:updateSingle(MYSTERYSHOP_BLACK) 		--只更新黑市商人 
				self:cast2DBMystShopData()
			end

			if 0==nowHour or 12==nowHour then
				self._shop[MYSTERYSHOP_SMELTER] = self:updateSingle(MYSTERYSHOP_SMELTER)    --只更新神秘商城
			end
			
			for i,v in pairs(self._user) do
				local user = self:getUserInfo(i)
				if user then
					if 0==nowHour or 12==nowHour then
						user:setOpenSmelterMall(0)
						user:ShopInit(MYSTERYSHOP_SMELTER)
						local playerTmp = g_entityMgr:getPlayer(i)
						if playerTmp then
							if playerTmp:getLevel() >= g_configMgr:getNewFuncLevel(14) then
								user:sendSmelterMallNew(true)
							end
						end
						user:Req(MYSTERYSHOP_SMELTER)
					end
					
					if 12==nowHour or 18==nowHour then
						user:clearMystRoleLimit()
						user:initBlackMystData()
						user:Req(MYSTERYSHOP_BLACK)
					end
				end
			end
		end
	end
end

function MysteryShopManager:startMysteryShop(player)
	if not player then return end
	local UID = player:getID()
	local SID = player:getSerialID()
	local user = self:getUserInfo(SID)
	if user then
		user:ShopInit(3)
	end
end

--玩家上线
function MysteryShopManager:onPlayerLoaded(player)
	if not player then
		return
	end
	local UID = player:getID()
	local SID = player:getSerialID()
	
	local user = self:getUserInfo(SID)
	if not user then
		user = MystUserInfo(UID, SID)
		self._user[SID] = user
	end

	if player:getLevel() >= g_configMgr:getNewFuncLevel(14) then
		if user:getIsNewData() then
			user:sendSmelterMallNew(true)
		end
	end
end

--玩家掉线
function MysteryShopManager:onPlayerInactive(player)
	if not player then return end

	local UID = player:getID()
	local SID = player:getSerialID()
	local user = self._user[SID]
	if user then
		user:setUpdateDB(true)
		user:cast2DB()
	end
end

--玩家离线
function MysteryShopManager:onPlayerOffLine(player)
	if not player then return end

	local UID = player:getID()
	local SID = player:getSerialID()
	local user = self._user[SID]
	if user then
		user:setUpdateDB(true)
		user:cast2DB()
	end

	if self._user[SID] then
		self._user[SID] = nil
	end
end

--切换到本world
function MysteryShopManager:switchIn(UID,isData,refresh,shop,version,date,buyInfo)
end

function MysteryShopManager:getUserInfo(SID)
	return self._user[SID]
end

function MysteryShopManager:loadMystConfig()
	if package.loaded["data.MysteryShopDB"] then
		package.loaded["data.MysteryShopDB"] = nil
	end
	self._source = {}
	
	local ShopDatas = require "data.MysteryShopDB"
	for _, record in pairs(ShopDatas or {}) do
		if not self._source[record.q_shop] then   		--record.q_shop 1元宝VIP神秘商店  2魂值神秘商城
			self._source[record.q_shop] = {}
		end
		if MYSTERYSHOP_BOOK == tonumber(record.q_shop) then
			self._bookShopInfoNums = self._bookShopInfoNums + 1
		end

		local tar = self._source[record.q_shop]
		local lmin = record.q_lmin 			--等级下限
		if tar[lmin] then 
			self:importType(tar[lmin], record)
		else
			tar[lmin] = {}
			tar[lmin].lmax = record.q_lmax 	--等级上限
			tar[lmin].shop = {[1] = {}, [2] = {}, [3] = {}, [4] = {}}
			self:importType(tar[lmin], record)
		end
	end
	--self._smelterShoplvl = g_configMgr:getNewFuncLevel(14)
end

function MysteryShopManager:importType(tar, rec)
	local data = StrSplit(rec.q_type..",", ",")
	for i,v in pairs(data) do
		table.insert(tar.shop[tonumber(v)], self:importRecord(tonumber(v), rec))
	end
end

function MysteryShopManager:importRecord(tab, rec)
	local tmp = {}
	local sellnum = 0
	if rec.q_all_limit and tonumber(rec.q_all_limit)>0 then
		sellnum = tonumber(rec.q_all_limit)
	elseif rec.q_num then
		sellnum = tonumber(rec.q_countNum)
	else
	end

	tmp.num = sellnum 										--当前剩余个数
	tmp.sellnum = sellnum 									--原本出售个数
	tmp.itemID = tonumber(rec.q_itemID) 					--道具ID
	tmp.limit = tonumber(rec.q_all_limit) or -1  			--全服限购
	tmp.isBind = (tonumber(rec.Is_bd) or 0) + 1 			--1代表不绑定  2代表绑定
	tmp.roleLimit = tonumber(rec.q_role_limit or -1) 		--个人限购
	tmp.spe = tonumber(rec.q_special or 0) 					--是否是特殊道具 例如 坐骑

	if tab == 1 then
		tmp.prob = tonumber(rec.q_ingotprob or 1) 			--价格
		tmp.price = rec.q_ingot 							--出现的几率
		return tmp
	end
	
	if tab == 2 then
		tmp.prob = tonumber(rec.q_cashprob or 1)
		tmp.price = rec.q_cash
		return tmp
	end
	
	if tab == 3 then
		tmp.prob = tonumber(rec.q_moneyprob or 1)
		tmp.price = rec.q_money or 1
		return tmp
	end
	
	if tab == 4 then
		tmp.prob = tonumber(rec.hzjl or 1)
		tmp.price = tonumber(rec.hz or 1)
		return tmp
	end
end

function MysteryShopManager:getNextRefreshTick()
	local nowHour = os.date("%H")
	local addDay = 0
	local nextRefreshHour = nowHour
	if nowHour%2==0 then
		nextRefreshHour = nextRefreshHour + 2
	else
		nextRefreshHour = nextRefreshHour + 1
	end

	if nextRefreshHour>=24 then
		nextRefreshHour = 0
		addDay = 1
	end

	local cur_timestamp = os.time()
 	local one_hour_timestamp = 24*60*60
 	local temp_time = cur_timestamp + one_hour_timestamp * addDay
 	local temp_date = os.date("*t", temp_time)
 	local timeTick = os.time({year=temp_date.year, month=temp_date.month, day=temp_date.day, hour=nextRefreshHour})
 	return timeTick
end

function MysteryShopManager:onPlayerCharge(player, ingot, czType)
end

function MysteryShopManager:openMysteryShop(player)
end

function MysteryShopManager:getMystItemInfo(mallID, moneyType, itemID)
	if mallID < 0 or moneyType < 0 then
		return {}
	end

	if self._source[mallID] then
		if self._source[mallID][1] and self._source[mallID][1].shop then
			local ItemListTmp = self._source[mallID][1].shop
			for i,v in pairs(ItemListTmp[moneyType] or {}) do
				if v.itemID == itemID then
					return v
				end
			end
		end
	end
	return {}
end

function MysteryShopManager:getMystSpeInfo()
	return self._speInfo
end

function MysteryShopManager:setMystSpeInfo(value)
	if value then
		self._speInfo = value
	end
end

function MysteryShopManager:getLastRefreshTime(Type)
	if self._lastRefreshTime and self._lastRefreshTime[Type] then
		return self._lastRefreshTime[Type]
	end
	return 1
end

function MysteryShopManager:setMysteryshopActive(value)
	self._mysteryshopActive = tonumber(value)
end

function MysteryShopManager:getMysteryshopActive()
	return self._mysteryshopActive
end

function MysteryShopManager.getInstance()
	return MysteryShopManager()
end

g_mystShopMgr = MysteryShopManager.getInstance()