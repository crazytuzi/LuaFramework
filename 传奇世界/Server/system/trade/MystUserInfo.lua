--MystUserInfo.lua
--/*-----------------------------------------------------------------
 --* Module:  MystUserInfo.lua
 --* Author:  HE Ningxu
 --* Modified: 2014年12月02日
 --* Purpose: Implementation of the class MystUserInfo
 -------------------------------------------------------------------*/

MystUserInfo = class()

local prop = Property(MystUserInfo)
prop:accessor("UID")
prop:accessor("SID")
prop:accessor("LoadDB", false)
prop:accessor("UpdateDB", false)

function MystUserInfo:__init(UID, SID)
	prop(self, "UID", UID)
	prop(self, "SID", SID)
	
	--self._refresh = {0, 0, 0, 0}
	self._shop = {}
	--self._date = {} 				--{2016, 1, 13}

	--self._firstItemType = 0 		--神秘商城第一件物品类型  1元宝 4魂值
	--self._mysterItemShow = 3    	--神秘商店会显示多少件物品
	--self._buyCount = 0           	--今天神秘商店购买了多少次
	--self._chargeInfo = {0,0}		--充值金额  是否开启神秘商店
	self._timeTick = time.toedition("day")
	self._refreshHour = 1 			--神秘商店 最近刷新的时间点
	self._openSmelterMall = 1 		--1代表数据更新后已经打开过		0代表还未打开
	self._isNewData = false 		--拉取数据库数据时，如果角色有新数据，先用变量存储，角色进入场景在发送给他
	self._roleLimit = {black = {}} 	--个人限购数据

	self:initBlackMystData()
	self:initBookMystData()
end

function MystUserInfo:initBlackMystData()
	local player = g_entityMgr:getPlayer(self:getUID())
	if not player then return end
	--local lvl = player:getLevel()
	--if lvl >= TRADE_BLACK_MALL_LEVEL_LIMIT then
		self._shop[MYSTERYSHOP_BLACK] = g_mystShopMgr:getBlackMystData(1)
	--end
end

function MystUserInfo:initBookMystData()
	local bookShopData = g_mystShopMgr:getBookMystData(1)
	--排序
	for i=1,4 do
		if bookShopData[i] then
			table.sort(bookShopData[i], function(a,b) return a.itemID < b.itemID end)
		end
	end
	self._shop[MYSTERYSHOP_BOOK] = bookShopData
end

function MystUserInfo:ShopInit(id)
	local player = g_entityMgr:getPlayer(self:getUID())
	if player then
		local lvl = player:getLevel()
		if lvl < g_configMgr:getNewFuncLevel(14) then
			return
		end

		if MYSTERYSHOP_SMELTER == id then
			if not self._shop[id] then
				self._shop[id] = {}
			end

			--从g_mystShopMgr._shop中得到 相应商城  相应等级 的商品信息
			for l, v in pairs(g_mystShopMgr._shop[id] or table.empty) do
				if v.lmax then
					if l <= lvl and lvl <= v.lmax then						
						self._shop[id] = table.deepcopy(v)
					end
				else
					for a,b in pairs(v or {}) do
						local lvlmax = b.lmax or 99
						if l <= lvl and lvl <= lvlmax then						
							self._shop[id] = table.deepcopy(b)
						end
					end
				end				
			end

			local lastRefreshTime = g_mystShopMgr:getLastRefreshTime(1)
			self._timeTick = time.toedition("day") --tonumber(lastRefreshTime)
			self._refreshHour = tonumber(lastRefreshTime)
			self:setUpdateDB(true)
			self:cast2DB()
		else
			print("MystUserInfo:ShopInit id err",id)
		end
	end
end

function MystUserInfo:upLevelInit(player)
	if player:getLevel() >= g_configMgr:getNewFuncLevel(14) and not self:getLoadDB() then
		self:ShopInit(MYSTERYSHOP_SMELTER)
		self:setLoadDB(true)
	end
end

function MystUserInfo:getSmelterMall()
	return self._openSmelterMall
end

function MystUserInfo:setOpenSmelterMall(value)
	self._openSmelterMall = value
end

function MystUserInfo:getIsNewData()
	return self._isNewData
end

function MystUserInfo:sendSmelterMallNew(isNew)
	local retData = {}
	retData.mallType = MYSTERYSHOP_SMELTER
	retData.isNew = isNew
	fireProtoMessage(self:getUID(),TRADE_SC_CHECK_NEW_RET,"MallCheckNewRet",retData)
end

function MystUserInfo:Req(id)
	if self:getLoadDB() == false then return end
	if not self._shop[id] then
    	self._shop[id] = {}
    end

	if MYSTERYSHOP_SMELTER==id then
		if not self._shop[id][1] then
    		self._shop[id][1] = {}
    	end

		if not self._shop[id][4] then
    		self._shop[id][4] = {}
    	end

    	if #self._shop[id][4]<=0 then
    		self:ShopInit(MYSTERYSHOP_SMELTER)
    	end
    	self:mysteryShopReq(id)
    	return
	end
	
	if MYSTERYSHOP_BLACK==id then
		if #self._shop[id]==0 or not self._shop[id][1] then
			self:initBlackMystData()
		end
		if not g_mystShopMgr:getIsLoadBlackMyst() then
			g_mystShopMgr:cast2DBMystShopData()
			g_mystShopMgr:setIsLoadBlackMyst(true)
		end
		self:blackMystReq(id)
		return
	end

	if MYSTERYSHOP_BOOK==id then
		if #self._shop[id]==0 or not self._shop[id][3] then
			self:initBookMystData()
		end
		self:bookMystReq(id)
		return
	end
end

function MystUserInfo:Refresh(id)
end

function MystUserInfo:RefreshFree(id)
	local player = g_entityMgr:getPlayer(self:getUID())
	if not player then return end
	local lvl = player:getLevel()
--[[
	if 2==id then
		if lvl<9 then return end
	elseif 3==id then
		if lvl<20 then return end
	end
]]
	for i, v in pairs(g_mystShopMgr._source[id]) do
		if i <= lvl and lvl <= v.lmax then
			self._shop[id] = table.deepcopy(g_mystShopMgr:getShop(v, id))
			break
		end
	end
	self:setUpdateDB(true)
	self:cast2DB()
	self:Req(id)
end

function MystUserInfo:BuyRet()
	local retData = {}
	retData.buyRet = true
	retData.needMoreIngot = 0
	retData.buyCountLeft = 0
	fireProtoMessage(self:getUID(),TRADE_SC_MYSTBUY_RET,"MysteryShopBuyRetProtocol",retData)
end

--购买
function MystUserInfo:Buy(id, Type, Index, ItemID, buyNum)
	if self:getLoadDB() == false then
		print("Buy Myst LoadDB false")
        return
    end

    local player = g_entityMgr:getPlayer(self:getUID())
	if not player then return end
	local RoleSID = player:getSerialID()
	local level = player:getLevel()

	--if 4==id then
		--if level < TRADE_BLACK_MALL_LEVEL_LIMIT then
			--g_tradeMgr:sendErrMsg2Client(self:getUID(), TRADE_ERR_OPERATE_LEVEL_LIMIT, 1, {TRADE_BLACK_MALL_LEVEL_LIMIT})
			--return
		--end
	--end

	if not self._shop[id] or not self._shop[id][Type] or not self._shop[id][Type][Index] then return end
	if self._shop[id][Type][Index].itemID ~= ItemID then
		--商品信息已变更
		g_tradeMgr:sendErrMsg2Client(self:getUID(), TRADE_ERR_ITEM_CHANGED, 0, {})
		return
	end

	--如果配置了全服限购  num存放的是全服限购剩余数目
	if self._shop[id][Type][Index].sellnum > 0 then
		if self._shop[id][Type][Index].num - buyNum < 0 then
			g_tradeMgr:sendErrMsg2Client(self:getUID(), TRADE_ERR_ITEM_SELL, 0, {})
			return
		end
	end

	--判断单人每次刷新间限购
	local roleLimit = self._shop[id][Type][Index].roleLimit
	if roleLimit > 0 then
		if not self._roleLimit.black then
			self._roleLimit.black = {}
		end
		if not self._roleLimit.black[ItemID] then
			self._roleLimit.black[ItemID] = 0
		end
		if self._roleLimit.black[ItemID] + buyNum > roleLimit then
			g_tradeMgr:sendErrMsg2Client(self:getUID(), TRADE_ERR_OVER_LIMIT, 0, {})
			return
		end
	end

	local item = self._shop[id][Type][Index]
	if not item or not item.price or not item.num then
		return
	end

	local price = item.price * buyNum
	if MYSTERYSHOP_SMELTER == id then 			--熔炼神秘商店	一份物品可能有多个  但价格已经是多个的价格了
		price = item.price
	end
	
	--local num = item.num or 0
	if price <= 0 then
		g_tradeMgr:sendErrMsg2Client(self:getUID(), TRADE_MALL_FAIL, 0, {})
		return
	end

	local itemMgr = player:getItemMgr()
	if not itemMgr then return end
	local freeSlots = itemMgr:getEmptySize(BAG_INDEX_BAG)
	if freeSlots < 1 then
		g_tradeMgr:sendErrMsg2Client(self:getUID(), TRADE_ERR_BAG_NOSLOT, 0, {})
		return
	end
--[[
	if item.spe and item.spe > 0 then
		if player:getLevel() < g_configMgr:getNewFuncLevel(1) then
			g_rideServlet:sendErrMsg2Client(self:getUID(), -2, 0)
			return
		end

		local rideID = item.spe
		if rideID <= 0 then return end

		local ret3 = g_rideMgr:hasRide(RoleSID, rideID)
		if ret3 then 
			g_rideServlet:sendErrMsg2Client(self:getUID(), RIDE_ERR_HAS_SAME, 0)
			return
		end
	end
]]	

	if Type == 1 then 				--元宝购物
    	local money = player:getIngot()
    	--if money<price+needmoreIngot then
    	if not isIngotEnough(player, price) then
			g_tradeMgr:sendErrMsg2Client(self:getUID(), TRADE_ERR_INGOT, 0, {})
			return
		end

    	local moneySource = 0
		if MYSTERYSHOP_SMELTER == id then
			moneySource = 31
		elseif MYSTERYSHOP_BLACK == id then
			moneySource = LOG_SOURCE_BLACK_MALL
		else
		end
		--player:setIngot(player:getIngot()-price-needmoreIngot)
		--costIngot(player, price, moneySource)
		local context = {mystMallID=id,moneyType=Type,itemIndex=Index,itemID=ItemID,buyNums=buyNum}
		local ret = g_tPayMgr:TPayScriptUseMoney(player,price,moneySource,"Myst black trade",0,0,"MystUserInfo.BuyCallBack", serialize(context)) 
		if ret ~= 0 then
			g_tradeMgr:sendErrMsg2Client2(self:getUID(), EVENT_COPY_SETS, -57, 0, {})
		end
		return
	end
	
	if Type == 4 then 				--魂值购物
		local money = player:getSoulScore()
		if money < price then
			g_tradeMgr:sendErrMsg2Client(self:getUID(), TRADE_ERR_SOUL_SCORE, 0, {})
			return
		end
		--player:setSoulScore(money-price)
		--g_logManager:writeMoneyChange(RoleSID,"",6,31,player:getSoulScore(),price,2)
	end

	if Type == 3 then 				--金币购物
		local money = player:getMoney()
		if not isMoneyEnough(player, price) then
		--if money<price then
			g_tradeMgr:sendErrMsg2Client(self:getUID(), TRADE_ERR_MONEY, 0, {})
			return
		end
		--player:setMoney(money-price)
		--g_logManager:writeMoneyChange(RoleSID,"",1,LOG_SOURCE_BOOK_SHOP,player:getMoney(),price,2)
	end
	self:BuyThen(id, Type, Index, ItemID, buyNum)
end

function MystUserInfo:BuyThen(id, Type, Index, ItemID, buyNum)
	local player = g_entityMgr:getPlayer(self:getUID())
	if not player then return false end
	local roleSID = player:getSerialID()

	local item = self._shop[id][Type][Index]
	if not item or not item.price or not item.num then
		return false
	end

	
	local price = item.price * buyNum
	if MYSTERYSHOP_SMELTER == id then 			--熔炼神秘商店	一份物品可能有多个  但价格已经是多个的价格了
		price = item.price
	end
	--local num = item.num or 0
	local itemBind = true

	if 1 == Type then
		itemBind = false
		g_achieveSer:costIngot(roleSID, price)
		--消费记录
		g_PayRecord:Record(self:getUID(), -price, CURRENCY_INGOT, 30)
		--活跃度标记
		g_normalMgr:activeness(self:getUID(), ACTIVENESS_TYPE.INGOT)
		--任务标记
		g_taskMgr:NotifyListener(player, "onUseIngot")
	end
--[[
	if item.spe and item.spe > 0 then
		local rideID = item.spe
		if rideID<=0 then
			return false
		end
		local ret = g_rideMgr:addNewRide(self:getUID(), rideID)
		if not ret then return false end
	else
]]		
		local itemMgr = player:getItemMgr()
		if not itemMgr then return false end
		local succeed = itemMgr:addBagItem(item.itemID, buyNum, itemBind, errorCode)
		if false == succeed then
			g_tradeMgr:sendErrMsg2Client(self:getUID(), TRADE_ERR_BAG_NOSLOT, 0, {})
			return false
		end
	--end

	if self._shop[id][Type][Index].sellnum > 0 then
		self._shop[id][Type][Index].num = self._shop[id][Type][Index].num - buyNum
	end

	local saveDB = false
	--判断单人每次刷新间限购
	local roleLimit = self._shop[id][Type][Index].roleLimit
	if roleLimit > 0 then
		if not self._roleLimit.black[ItemID] then
			self._roleLimit.black[ItemID] = 0
		end
		self._roleLimit.black[ItemID] = self._roleLimit.black[ItemID] + buyNum
		saveDB = true
	end

	--Tlog[ItemFlow]
	local logmallType = 0
	if MYSTERYSHOP_SMELTER == id then
		if Type == 4 then 				--魂值购物
			local money = player:getSoulScore()
			player:setSoulScore(money - price)
			g_logManager:writeMoneyChange(roleSID,"",6,31,player:getSoulScore(),price,2)
			g_tlogMgr:TlogSmelterMallFlow(player, item.itemID, buyNum, price)
		end

		g_taskMgr:NotifyListener(player, "onBuyMysGood")
		saveDB = true

		logmallType = 7
		g_logManager:writePropChange(roleSID,1,31,item.itemID,0,buyNum,1)
	elseif MYSTERYSHOP_BLACK==id then
		g_mystShopMgr:cast2DBMystShopData()

		logmallType = 10
		g_logManager:writePropChange(roleSID,1,LOG_SOURCE_BLACK_MALL,item.itemID,0,buyNum,0)
	elseif MYSTERYSHOP_BOOK == id then
		if Type == 3 then 				--金币购物
			local money = player:getMoney()
			player:setMoney(money - price)
			g_logManager:writeMoneyChange(roleSID,"",1,LOG_SOURCE_BOOK_SHOP,player:getMoney(),price,2)
		end

		logmallType = 11
		g_logManager:writePropChange(roleSID,1,LOG_SOURCE_BOOK_SHOP,item.itemID,0,buyNum,1)
	else
	end

	if saveDB then
		self:setUpdateDB(true)
		self:cast2DB()
	end

	g_tradeMgr:sendErrMsg2Client(self:getUID(), TRADE_MALL_SUCCEED, 0, {})		
	self:BuyRet()

	g_tlogMgr:TlogMallFlow(player, logmallType, item.itemID, buyNum)
	return true
end

function MystUserInfo.BuyCallBack(roleSID, payRet, money, itemId, itemCount, callBackContext)
	if 0==payRet then
		local context = unserialize(callBackContext)
		local mystID = context.mystMallID or 0
		local moneyType = context.moneyType or 0
		local itemIndex = context.itemIndex or 0
		local itemID = context.itemID or 0
		local buyNum = context.buyNums or 0

		local player = g_entityMgr:getPlayerBySID(roleSID)
		if not player then return TPAY_FAILED end

		local user = g_mystShopMgr:getUserInfo(roleSID)
		if not user then return TPAY_FAILED end
		local ret = user:BuyThen(mystID,moneyType,itemIndex,itemID,buyNum)
		if ret then
			return TPAY_SUCESS
		end
	end
	return TPAY_FAILED
end

function MystUserInfo:loadDB(datas)
	local player = g_entityMgr:getPlayer(self:getUID())
	if not player then return end
	if player:getLevel() < g_configMgr:getNewFuncLevel(14)-1 then
		return
	end

	local theSameMystData = false
	if datas then
		local data = unserialize(datas)
		if data.tick and tonumber(data.tick) == tonumber(self._timeTick) then
			if data.s and data.s.myst then
				local tickTmp = tonumber(data.refreshH or 0)
				local lastRefreshTime = g_mystShopMgr:getLastRefreshTime(1)
				if 1 == lastRefreshTime or tickTmp == tonumber(lastRefreshTime) then
					theSameMystData = true
					self._shop[MYSTERYSHOP_SMELTER] = data.s.myst
					self._refreshHour = tickTmp

					local isOpen = tonumber(data.open)
					if isOpen then
						self:setOpenSmelterMall(isOpen)
						if isOpen < 1 then
							self._isNewData = true
						end
					end

					--个人每次刷新间限购
					if not self._roleLimit.black then
						self._roleLimit.black = {}
					end
					self._roleLimit.black = data.limit.black
				end
			else
				print("MystUserInfo:loadDB no data.s.myst")
			end
		end
	else
		print("MystUserInfo:loadDB no datas")
	end

	if not theSameMystData then
		self:ShopInit(MYSTERYSHOP_SMELTER)
		self:setOpenSmelterMall(0)
		self._isNewData = true
	end
	self:setLoadDB(true)
end

function MystUserInfo:cast2DB()
	if self:getLoadDB() == false then return end
	if self:getUpdateDB() == false then	return end

	local dbStr = {}
	dbStr.s = {}
	dbStr.s.myst = self._shop[MYSTERYSHOP_SMELTER]
	dbStr.tick = self._timeTick
	dbStr.refreshH = self._refreshHour
	dbStr.limit = {}
	dbStr.limit.black = self._roleLimit.black
	dbStr.open = self._openSmelterMall

	--g_entityDao:updateRole(self:getSID(), serialize(dbStr), "mysteryshop")
	--self:setUpdateDB(false)
	local player = g_entityMgr:getPlayer(self:getUID())
	if not player then return end		
	local cache_buf = serialize(dbStr)
	g_engine:savePlayerCache(player:getSerialID(), FIELD_MYSTERYSHOP, cache_buf, #cache_buf)
end

function MystUserInfo:switchIn(isData,refresh,shop,version,date,buyInfo)
end

function MystUserInfo:mysteryShopReq(id)
	if id~=MYSTERYSHOP_SMELTER then return end
	local active = true
	if self._shop[id] then
		if not self._shop[id][4] then 
			active = false 
		end
	end

	if not active then
		local retData = {}
		retData.itemInfo = {}
		retData.itemNum = 0
		retData.mallID = id
		fireProtoMessage(self:getUID(),TRADE_SC_MYSTRET,"MysteryShopReqRetProtocol",retData)
		return
	end

	local retData = {}
	retData.mallID = id
	retData.itemNum = 0
	retData.itemInfo = {}
	retData.param1 = 0

	local ItemNum = 0
	for i=1,4 do
		if self._shop[id] then
			local temp = self._shop[id][i]
			if temp then
				ItemNum = ItemNum + #temp
			end
		end
	end
	retData.itemNum = ItemNum

	local SoulIndex = 1	
	for m=1,MYSTERYSHOP_3_INGOT_ITEM_NUM+MYSTERYSHOP_3_SOUL_ITEM_NUM do
		if self._shop[id] then
			local tmp = self._shop[id][4]
			if tmp and tmp[SoulIndex] then
				local itemInfoTmp = {}
				itemInfoTmp.moneyType = 4
				itemInfoTmp.arrayIndex = SoulIndex
				itemInfoTmp.itemID = tmp[SoulIndex].itemID
				itemInfoTmp.price = tmp[SoulIndex].price
				itemInfoTmp.itemLeft = tmp[SoulIndex].num
				itemInfoTmp.souceNum = tmp[SoulIndex].sellnum or 0
				itemInfoTmp.serverLimit = tmp[SoulIndex].limit or -1
				itemInfoTmp.roleLimit = -1
				itemInfoTmp.roleCurBuy = -1
				itemInfoTmp.isBind = tmp[SoulIndex].isBind or 1
				table.insert(retData.itemInfo, itemInfoTmp)
				SoulIndex = SoulIndex + 1
			end
		end
	end

	local nowHour = tonumber(os.date("%H"))
	if nowHour>=12 then
		retData.param1 = 0 				--下次自动刷新时间点
	else
		retData.param1 = 12
	end
	fireProtoMessage(self:getUID(),TRADE_SC_MYSTRET,"MysteryShopReqRetProtocol",retData)
end

function MystUserInfo:blackMystReq(id)
	if MYSTERYSHOP_BLACK ~= id then return end

	--local player = g_entityMgr:getPlayer(self:getUID())
	--if not player then return end	
	--local level = player:getLevel()
	--local roleSID = player:getSerialID()

	local active = true
	--if level < TRADE_BLACK_MALL_LEVEL_LIMIT then
		--active = false
	--end

	if not self._shop[id] then
		active = false
	end

	if not active then
print("MystUserInfo:blackMystReq 02")		
		local retData = {}
		retData.itemInfo = {}
		retData.itemNum = 0
		retData.mallID = id
		fireProtoMessage(self:getUID(),TRADE_SC_BLACK_RET,"MysteryBlackMallRetProtocol",retData)
		return
	end

	local retData = {}
	retData.mallID = id
	retData.itemNum = 0
	retData.itemInfo = {}
	retData.param1 = 0

	local ItemNum = 0
	for i=1,4 do
		if self._shop[id] then
			local temp = self._shop[id][i]
			if temp then
				ItemNum = ItemNum + #temp
			end
		end
	end
	retData.itemNum = ItemNum

	local IngotIndex = 1
	for m=1,MYSTERYSHOP_4_INGOT_ITEM_NUM do
		if self._shop[id] then
			local tmp = self._shop[id][1]
			if tmp and tmp[IngotIndex] then
				local itemInfoTmp = {}
				itemInfoTmp.moneyType = 1
				itemInfoTmp.arrayIndex = IngotIndex
				local itemIDTmp = tmp[IngotIndex].itemID
				itemInfoTmp.itemID = itemIDTmp
				itemInfoTmp.price = tmp[IngotIndex].price
				itemInfoTmp.itemLeft = tmp[IngotIndex].num
				itemInfoTmp.souceNum = tmp[IngotIndex].sellnum or 0
				itemInfoTmp.serverLimit = tmp[IngotIndex].limit or -1
				itemInfoTmp.roleLimit = tmp[IngotIndex].roleLimit or -1
				itemInfoTmp.roleCurBuy = self:getMystRoleLimitByItemID(id, itemIDTmp)
				itemInfoTmp.isBind = tmp[IngotIndex].isBind or 1
				table.insert(retData.itemInfo, itemInfoTmp)
				IngotIndex = IngotIndex + 1
			end
		end
	end

	local nowHour = tonumber(os.date("%H"))
	if nowHour>=12 then
		retData.param1 = 0 				--下次自动刷新时间点
	else
		retData.param1 = 12
	end
	fireProtoMessage(self:getUID(),TRADE_SC_BLACK_RET,"MysteryBlackMallRetProtocol",retData)
end

function MystUserInfo:bookMystReq(id)
	if MYSTERYSHOP_BOOK~=id then return end
	local active = true
	if not self._shop[id] then
		active = false
	end

	if not active then
print("MystUserInfo:bookMystReq 02",id)
		local retData = {}
		retData.itemInfo = {}
		retData.itemNum = 0
		retData.mallID = id
		fireProtoMessage(self:getUID(),TRADE_SC_BLACK_RET,"MysteryBlackMallRetProtocol",retData)
		return
	end

	local retData = {}
	retData.mallID = id
	retData.itemNum = 0
	retData.itemInfo = {}
	retData.param1 = 0

	local ItemNum = 0
	for i=1,4 do
		if self._shop[id] then
			local temp = self._shop[id][i]
			if temp then
				ItemNum = ItemNum + #temp
			end
		end
	end
	retData.itemNum = ItemNum

	local IngotIndex = 1
	for m=1,g_mystShopMgr._bookShopInfoNums do 
		if self._shop[id] then
			local tmp = self._shop[id][3]
			if tmp and tmp[IngotIndex] then
				local itemInfoTmp = {}
				itemInfoTmp.moneyType = 3 			--1元宝2礼金3金币4魂值
				itemInfoTmp.arrayIndex = IngotIndex
				itemInfoTmp.itemID = tmp[IngotIndex].itemID
				itemInfoTmp.price = tmp[IngotIndex].price
				itemInfoTmp.itemLeft = tmp[IngotIndex].num
				itemInfoTmp.souceNum = tmp[IngotIndex].sellnum or 0
				itemInfoTmp.serverLimit = tmp[IngotIndex].limit or -1
				itemInfoTmp.roleLimit = -1
				itemInfoTmp.roleCurBuy = -1
				itemInfoTmp.isBind = tmp[IngotIndex].isBind or 1
				table.insert(retData.itemInfo, itemInfoTmp)
				IngotIndex = IngotIndex + 1
			end
		end
	end
	fireProtoMessage(self:getUID(),TRADE_SC_BLACK_RET,"MysteryBlackMallRetProtocol",retData)
end

function MystUserInfo:getMystLimit(mallID,moneyType,arrayIndex,itemID)
	if mallID~=MYSTERYSHOP_BLACK and mallID~=MYSTERYSHOP_SMELTER then return end
	--local player = g_entityMgr:getPlayer(self:getUID())
	--if not player then return end	
	--local level = player:getLevel()

	--if 4==mallID then
		--if level < TRADE_BLACK_MALL_LEVEL_LIMIT then
			--g_tradeMgr:sendErrMsg2Client(self:getUID(), TRADE_ERR_OPERATE_LEVEL_LIMIT, 1, {TRADE_BLACK_MALL_LEVEL_LIMIT})
			--return
		--end
	--end

	if self._shop[mallID] and self._shop[mallID][moneyType] and self._shop[mallID][moneyType][arrayIndex] then
		local itemInfoTmp = self._shop[mallID][moneyType][arrayIndex]
		if itemID == itemInfoTmp.itemID then
			local ret = {}
			ret.mallID = mallID
			ret.itemInfo = {}
			ret.itemInfo.moneyType = moneyType
			ret.itemInfo.arrayIndex = arrayIndex
			ret.itemInfo.itemID = itemID
			ret.itemInfo.price = itemInfoTmp.price
			ret.itemInfo.itemLeft = itemInfoTmp.num
			ret.itemInfo.souceNum = itemInfoTmp.sellnum
			ret.itemInfo.serverLimit = itemInfoTmp.limit
			ret.itemInfo.roleLimit = itemInfoTmp.roleLimit or -1
			ret.itemInfo.roleCurBuy = self:getMystRoleLimitByItemID(mallID, itemID)
			ret.itemInfo.isBind = itemInfoTmp.isBind or 1
			fireProtoMessage(self:getUID(),TRADE_SC_MYST_LIMIT_RET,"MysteryLimitRetProtocol",ret)
		end
	end
end

function MystUserInfo:mystUseSpeItem(player, slot)
	if slot <=0 then return end
	if not player then return end
	local roleSID = player:getSerialID()

	local itemMgr = player:getItemMgr()
	if not itemMgr then return end
	local item = itemMgr:findItem(slot)
	if not item then return end

	local sourceItemID = item:getProtoID()
	if sourceItemID ~= ITEM_UNICOM_ID then
		return
	end

	if player:getLevel() < g_configMgr:getNewFuncLevel(1) then
		g_rideServlet:sendErrMsg2Client(self:getUID(), -2, 0)
		return
	end

	local speRideID = 0
	local mystSpeInfo = g_mystShopMgr:getMystSpeInfo()
	if mystSpeInfo and mystSpeInfo[ITEM_UNICOM_ID] then
		speRideID = mystSpeInfo[ITEM_UNICOM_ID]
	end

	if speRideID <= 0 then
		local speItemInfo = g_mystShopMgr:getMystItemInfo(MYSTERYSHOP_BLACK, 1, ITEM_UNICOM_ID)
		if speItemInfo.spe then
			speRideID = speItemInfo.spe
			mystSpeInfo[ITEM_UNICOM_ID] = speItemInfo.spe
			g_mystShopMgr:setMystSpeInfo(mystSpeInfo)
		end
	end

	if speRideID <= 0 then return end

	local ret3 = g_rideMgr:hasRide(roleSID, speRideID)
	if ret3 then 
		g_rideServlet:sendErrMsg2Client(self:getUID(), RIDE_ERR_HAS_SAME, 0)
		return
	end

	local ret = g_rideMgr:addNewRide(self:getUID(), speRideID)
	if ret then
		--local itemName = g_ActivityMgr:getItemName(ITEM_UNICOM_ID)
		--local nameParam = '['..itemName..']X1'
		--g_tradeMgr:sendErrMsg2Client2(self:getUID(), 5000, 3, 1, {nameParam})

		local retBuf = {}
		retBuf.itemID = ITEM_UNICOM_ID
		retBuf.itemNum = 1
		fireProtoMessage(self:getUID(),ITEM_SC_USEMATERIAL,"ItemUseRetProtocol",retBuf)
		
		--删除格子内物品
		local flag, errcode = itemMgr:removeBagItem(slot, 1, errcode)
		if not flag then return end
		g_logManager:writePropChange(roleSID,2,233,ITEM_UNICOM_ID,0,1,0)
	end
end

function MystUserInfo:clearMystRoleLimit()
	if self._roleLimit.black then
		self._roleLimit.black = {}
		self:setUpdateDB(true)
		self:cast2DB()
	end
end

function MystUserInfo:getMystRoleLimitByItemID(mallID, itemID)
	if MYSTERYSHOP_BLACK == mallID then
		if self._roleLimit.black then
			return self._roleLimit.black[itemID] or 0
		end
	end
	return -1
end