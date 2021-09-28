--UserInfo.lua
--/*-----------------------------------------------------------------
 --* Module:  UserInfo.lua
 --* Author:  HE Ningxu
 --* Modified: 2014年5月14日
 --* Purpose: Implementation of the class UserInfo
 -------------------------------------------------------------------*/

require ("base.class")
require ("system.trade.TradeMallDB")
UserInfo = class()

local prop = Property(UserInfo)
prop:accessor("UserID")
prop:accessor("TradeID")
prop:accessor("TradeState", TRADE_FREE)
prop:accessor("BlockTrade", false)
prop:accessor("UpdateDB", false)

function UserInfo:__init(UID)
	self._tradeLitst = {}

	self.RoleLimitData = {}     --个人限购数据 20151030 { [购买ID]=次数， }
	self.RoleIngotTrade = 0 	--今日元宝交易数目
	self._timeTick = time.toedition("day")

	self._applyTrade = {}
	self._recvApplyTick = 0
	prop(self, "UserID", UID)
end

--add lc 20150806 
function pairsByKeys(t)  
    local a = {}  
    for n in pairs(t) do  
        a[#a+1] = n  
    end  
    table.sort(a)  
    local i = 0  
    return function()  
        i = i + 1  
        return a[i], t[a[i]]  
    end  
end 

function UserInfo:getMallItem(Type,dbid,hGate)
	--判断系统开启
	local todayTimetick = time.toedition("day")
	if self._timeTick~=todayTimetick then
		self._timeTick = todayTimetick
	end
	local player = g_entityMgr:getPlayer(self:getUserID())
	if not player then return end	

	local retData = {}
	retData.shopType = Type 		 						--商城类型
	retData.itemInfo = {}

	local shopItemCount = 0
	if ShopCount[Type] and (0 ~= ShopCount[Type]) then
		--retData.shopItemCount = ShopCount[Type] 			--商品数量
		--for i, v in pairs(ShopTable[Type]) do 	--20150806  lc
		for i, v in pairsByKeys(ShopTable[Type]) do
			local allLimit, roleLimit = g_TradePublic:getAllLimitNums(i)	--通过 购买ID  获取全服限购总量
			local allLimitLeft = -1
			if allLimit>0 then
				local ServerID = 0
				local alreadyBuy = g_TradePublic:getAlreadyBuy(i, ServerID)
				allLimitLeft = allLimit - alreadyBuy
			end
			local roleLimitCur = self.RoleLimitData[i] or 0
			
			local shopItemInfoTmp = {}
			shopItemInfoTmp.effectTime = 0
			local itemEffect = true 
			if v.starOnSellTick > 0 then
				local curTick = os.time()
				if v.starOnSellTick <= curTick and v.endOnSellTick>=curTick then
					shopItemInfoTmp.effectTime = v.endOnSellTick - curTick
				else
					itemEffect = false
				end
			end

			if itemEffect then
				shopItemInfoTmp.itemBuyID = i 									--购买ID		MallDB 里的 q_id
				shopItemInfoTmp.itemID = v.sell 								--物品原形ID
				shopItemInfoTmp.sellState = v.sale_rate 						--销售状态
				shopItemInfoTmp.sellPrice = PriceTable[Type][v.sell].price 		--售价
				shopItemInfoTmp.sourcePrice = PriceTable[Type][v.sell].show 	--原价
				shopItemInfoTmp.allLimite = allLimit
				shopItemInfoTmp.allLimiteLeft = allLimitLeft 					--全服限购剩余数量
				shopItemInfoTmp.roleLimite = roleLimit 							--每人每天限购数
				shopItemInfoTmp.roleBuy = roleLimitCur 							--个人已购买数目
				shopItemInfoTmp.label = v.label or 0							--标签
				table.insert(retData.itemInfo,shopItemInfoTmp)
				shopItemCount = shopItemCount + 1
			end
		end
	end			
	retData.shopItemCount = shopItemCount 			--商品数量
	fireProtoMessageBySid(dbid, TRADE_SC_MALLRET, "TradeMallReqRetProtocol", retData)
end

function UserInfo:addTrade(TID)
	self._tradeLitst[TID] = true
end

function UserInfo:delTrade(TID)
	self._tradeLitst[TID] = nil
end

function UserInfo:Offline() 
	--清空交易
	if TRADE_ON == self:getTradeState() then
		trade = g_tradeMgr:getTradeInfo(self:getTradeID())

		if trade then			
			local TargetID = trade:getUserAID()
			if TargetID==self:getUserID() then
				TargetID = trade:getUserBID()
			end
			
			trade:SEND_TRADE_SC_TRADERET(TargetID, false)		--20151012  用户下线关闭对方交易面板
			trade:close()
			trade:tradeOff()
		end
	end
	for i,v in pairs(self._tradeLitst) do
		if v then
			g_tradeMgr:tradeDelete(i)
		end
	end
end

function UserInfo:switchOut(peer, dbid, mapID)
end

function UserInfo:switchIn(luabuf)
end

function UserInfo:MoneyShopTrade(ItemID, num)
	local item = g_tradeMgr:getItem(ItemID)
	if item == nil then
		g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_MALL_DOWN, 0, {})
		return false
	end

	local player = g_entityMgr:getPlayer(self:getUserID())
	if not player then
		return false
	end
	local ServerID = 0 		--player:getServerID() or 

	local itemMgr = player:getItemMgr()
	if not itemMgr then
		return false
	end

	local money = player:getMoney() 
	local price = item.money * num

	if price < 0 then
		g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_MALL_FAIL, 0, {})
		return false
	end

	--if money >= price then
	if isMoneyEnough(player,price) then
		--全服限购判断	
		--local ret1 = g_tradeMgr:checkLimit(ItemID, num, shoptype, ServerID)
		--if not ret1 then return false end

		--单人每天限购
		local ret2 = self:CheckRoleLimit(ItemID, num)
		if not ret2 then return false end

		local succeed = itemMgr:addBagItem(MallItemTable[ItemID].sell, num, true, errorCode)
		if false == succeed then
			g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_ERR_BAG_NOSLOT, 0, {})
			return false
		end
		
		--g_tradeMgr:updateLimit(ItemID, num, ServerID)
		self:UpdateRoleLimit(ItemID, num)
		--player:setMoney(money - price)
		local logSource = 36
		if MALL_TYPE_BOOK_SHOP==item.shop_type then
			logSource = LOG_SOURCE_BOOK_SHOP
		end
		costMoney(player, price, logSource)
		g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_MALL_SUCCEED, 0, {})

		--20150907
		local BindTmp = MallItemTable[ItemID].buy_bind and 1 or 0
		local RoleSID = player:getSerialID()
		g_logManager:writePropChange(RoleSID,1,36,MallItemTable[ItemID].sell,0,num,BindTmp)

		--Tlog[ItemFlow]
		g_tlogMgr:TlogMallFlow(player, 9, MallItemTable[ItemID].sell, num)
	else
		g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_ERR_MONEY, 0, {})
		return false
	end

	return true
end

function UserInfo:IngotShopTrade(ItemID, num, isShortCut)
	--ItemID 代表列表中的第多少项  购买ID  而不是物品ID
	local item = g_tradeMgr:getItem(ItemID)
	if item == nil then
		g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_MALL_DOWN, 0, {})
		return false
	end

	local player = g_entityMgr:getPlayer(self:getUserID())
	if not player then
		print("UserInfo:IngotShopTrade no player",ItemID,num)
		return false
	end
	local RoleSID = player:getSerialID()
	local ServerID = 0 		--player:getServerID() or 

	--商品是否下架
	if item.starOnSellTick>0 then
		local endOnSellTick = item.endOnSellTick or 0
		local curTick = tonumber(os.time())
		if curTick<item.starOnSellTick or curTick>endOnSellTick then
			g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_MALL_DOWN, 0, {})
			return false
		end
	end

	local itemMgr = player:getItemMgr()
	if not itemMgr then
		print("UserInfo:IngotShopTrade no itemMgr",ItemID,num)		
		return false
	end

	local money = player:getIngot() 
	local price = item.ingot * num

	if price <= 0 then
		g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_MALL_FAIL, 0, {})
		return false
	end

	--if money<price then
	if not isIngotEnough(player, price) then		
		g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_ERR_INGOT, 0, {})
		return false
	end

	--单人每天限购
	local ret2 = self:CheckRoleLimit(ItemID, num)
	if not ret2 then 
		g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_ERR_OVER_LIMIT, 0, {})
		return false
	end

	local ServerLimit = g_TradePublic:getAllLimitNums(ItemID)
	if ServerLimit>0 then
		local alreadyBuy = g_TradePublic:getAlreadyBuy(ItemID, 0)
		if alreadyBuy+num>ServerLimit then
			g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_ERR_OVER_LIMIT, 0, {})
			return false
		else
			--g_TradePublic:addAlreadyBuy(num, ItemID, 0)
		end
	end

	local logSource = 23
	if isShortCut then
		if MallItemTable[ItemID] and MallItemTable[ItemID].sell then
			local itemIDTmp = MallItemTable[ItemID].sell
			if 6200033==itemIDTmp or 6200034==itemIDTmp or 6200035==itemIDTmp then
				logSource = LOG_SOURCE_SHORTCUT_1 	--快捷购买 运镖符
			elseif 9007==itemIDTmp or 9008==itemIDTmp then
				logSource = LOG_SOURCE_SHORTCUT_2 	--快捷购买 悬赏
			elseif 2002==itemIDTmp then
				logSource = LOG_SOURCE_SHORTCUT_3 	--快捷购买 金条
			else
			end
		end
	end

	if SpeMallItem[ItemID] then
		--坐骑购买做特殊处理
		--if not g_taskMgr:canUseFun(player,1) then 		--判断是否开了坐骑功能
		if player:getLevel() < g_configMgr:getNewFuncLevel(1) then
			g_rideServlet:sendErrMsg2Client(self:getUserID(), -2, 0)
			return false
		end

		local rideID = SpeMallItem[ItemID].special or 0
		if rideID<=0 then
			return false
		end

		local ret3 = g_rideMgr:hasRide(RoleSID, rideID)
		if ret3 then 
			g_rideServlet:sendErrMsg2Client(self:getUserID(), RIDE_ERR_HAS_SAME, 0)
			return false
		end
		
		if num> 1 then num = 1 end
		--costIngot(player, item.ingot*num, 23)
	else
		local freeslot = itemMgr:getEmptySize(BAG_INDEX_BAG)
		if freeslot<1 then
			g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_ERR_BAG_NOSLOT, 0, {})
			return false
		end
		--costIngot(player, item.ingot*num, logSource)
	end

	local context = {itemBuyID=ItemID,itemNum=num}
	local ret = g_tPayMgr:TPayScriptUseMoney(player,item.ingot*num,logSource,"Ingot Mall",0,0,"UserInfo.IngotShopTradeCallBack", serialize(context)) 
	if ret ~= 0 then
		g_tradeMgr:sendErrMsg2Client2(self:getUserID(), EVENT_COPY_SETS, -57, 0, {})
		return false
	end
	return true
end

function UserInfo:IngotShopTradeThen(ItemID, num)
	local item = g_tradeMgr:getItem(ItemID)
	if not item then return false end
	local price = item.ingot * num

	local player = g_entityMgr:getPlayer(self:getUserID())
	if not player then return false end
	local RoleSID = player:getSerialID()

	local itemMgr = player:getItemMgr()
	if not itemMgr then
		print("UserInfo:IngotShopTrade no itemMgr",ItemID,num)		
		return false
	end

	if SpeMallItem[ItemID] then
		local rideID = SpeMallItem[ItemID].special or 0
		if rideID<=0 then
			return false
		end
		local ret = g_rideMgr:addNewRide(player:getID(), rideID)
		if not ret then return false end
	else
		local succeed = itemMgr:addBagItem(MallItemTable[ItemID].sell, num, false, errorCode)
		if false == succeed then
			--print("UserInfo:IngotShopTradeThen addBagItem is error")
			g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_ERR_BAG_NOSLOT, 0, {})
			return false
		end
	end

	g_TradePublic:addAlreadyBuy(num, ItemID, 0)
	self:UpdateRoleLimit(ItemID, num)
	g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_MALL_SUCCEED, 0, {})
	--消费记录
	g_PayRecord:Record(self:getUserID(), -price, CURRENCY_INGOT, 1)
	g_achieveSer:costIngot(RoleSID, price)
	--活跃度标记
	g_normalMgr:activeness(self:getUserID(), ACTIVENESS_TYPE.INGOT)
	--任务标记
	g_taskMgr:NotifyListener(player, "onUseIngot")
	--Tlog[ItemFlow]
	g_tlogMgr:TlogMallFlow(player, 1, MallItemTable[ItemID].sell, num)
	g_logManager:writePropChange(RoleSID,1,23,MallItemTable[ItemID].sell,0,num,0)
	return true
end

function UserInfo.IngotShopTradeCallBack(roleSID, payRet, money, itemId, itemCount, callBackContext)
	if 0==payRet then
		local context = unserialize(callBackContext)
		local buyID = context.itemBuyID or 0
		local buyNum = context.itemNum or 0

		local player = g_entityMgr:getPlayerBySID(roleSID)
		if not player then return TPAY_FAILED end
		local UID = player:getID()
		local User = g_tradeMgr:getUserInfo(UID)
		if not User then return TPAY_FAILED end
	
		local ret = User:IngotShopTradeThen(buyID, buyNum)
		if ret then
			return TPAY_SUCESS
		end
	end
	return TPAY_FAILED
end

function UserInfo:BindIngotShopTrade(ItemID, num)
	local item = g_tradeMgr:getItem(ItemID)
	if item == nil then
		g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_MALL_DOWN, 0, {})
		return false
	end

	local player = g_entityMgr:getPlayer(self:getUserID())
	if not player then
		return false
	end
	local RoleSID = player:getSerialID()
	local ServerID = 0 		--player:getServerID() or 

	local itemMgr = player:getItemMgr()
	if not itemMgr then
		return false
	end

	local money = player:getBindIngot() 
	local price = item.bind_ingot * num

	if price < 0 then
		g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_MALL_FAIL, 0, {})
		return false
	end

	if money < price then
		g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_ERR_BIND_INGOT, 0, {})
		return false
	end

	--单人每天限购
	local ret2 = self:CheckRoleLimit(ItemID, num)
	if not ret2 then 
		g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_ERR_OVER_LIMIT, 0, {})
		return false
	end

	--全服限购判断	
	--local ret1 = g_tradeMgr:checkLimit(ItemID, num, shoptype, ServerID)
	--if not ret1 then return false end
	--g_tradeMgr:updateLimit(ItemID, num, ServerID)

	if SpeMallItem[ItemID] then
		--坐骑购买做特殊处理
		--if not g_taskMgr:canUseFun(player,1) then 		--判断是否开了坐骑功能
		if player:getLevel() < g_configMgr:getNewFuncLevel(1) then
			g_rideServlet:sendErrMsg2Client(self:getUserID(), -2, 0)
			return false
		end

		local rideID = SpeMallItem[ItemID].special or 0
		if rideID<=0 then
			return false
		end

		local ret3 = g_rideMgr:hasRide(RoleSID, rideID)
		if ret3 then 
			g_rideServlet:sendErrMsg2Client(self:getUserID(), RIDE_ERR_HAS_SAME, 0)
			return false
		end
		
		if num> 1 then num = 1 end
		local ret = g_rideMgr:addNewRide(player:getID(), rideID)
		if not ret then 
			return false 
		else
			self:UpdateRoleLimit(ItemID, num)
			player:setBindIngot(money - price)
		end
	else
		local freeslot = itemMgr:getEmptySize(BAG_INDEX_BAG)
		if freeslot<1 then
			g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_ERR_BAG_NOSLOT, 0, {})
			return false
		end
		--costIngot(player, item.ingot*num, logSource)

		self:UpdateRoleLimit(ItemID, num)
		player:setBindIngot(money - price)

		local succeed = itemMgr:addBagItem(MallItemTable[ItemID].sell, num, true, errorCode)
		if false == succeed then
			g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_ERR_BAG_NOSLOT, 0, {})
			return false
		end
	end

	g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_MALL_SUCCEED, 0, {})
	--消费记录
	g_PayRecord:Record(self:getUserID(), -price, CURRENCY_BINDINGOT, 1)
	--活跃度标记
	g_normalMgr:activeness(self:getUserID(), ACTIVENESS_TYPE.BIND_INGOT)
	--任务标记
	g_taskMgr:NotifyListener(player, "onUseBindIngot")

	--20150907
	--local countTmp = itemMgr:getItemCount(MallItemTable[ItemID].sell)
	local BindTmp = MallItemTable[ItemID].buy_bind and 1 or 0
	g_logManager:writeMoneyChange(RoleSID,"",4,24,player:getBindIngot(),price,2)
	g_logManager:writePropChange(RoleSID,1,24,MallItemTable[ItemID].sell,0,num,BindTmp)

	--Tlog[ItemFlow]
	g_tlogMgr:TlogMallFlow(player, 2, MallItemTable[ItemID].sell, num)
	---
	return true
end

function UserInfo:FactionShopTrade(ItemID, num)
	local item = g_tradeMgr:getItem(ItemID)
	if item == nil then
		g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_MALL_DOWN, 0, {})
		return false
	end

	local player = g_entityMgr:getPlayer(self:getUserID())
	if not player then
		return false
	end

	local roleSID = player:getSerialID()
	local ServerID = 0 		--player:getServerID() or 
	local itemMgr = player:getItemMgr()
	if not itemMgr then
		return false
	end

	local price = item.faction_money * num
	if price < 0 then
		g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_MALL_FAIL, 0, {})
		return false
	end

	local factionID = player:getFactionID()
	local faction = g_factionMgr:getFaction(factionID)
	if not faction then return false end

	local facMem = faction:getMember(roleSID)
	if not facMem then return false end
	local money = facMem:getContribution() or 0

	if money < price then
		g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_ERR_NO_FACTION, 0, {})
		return false
	end

	--单人每天限购
	local ret2 = self:CheckRoleLimit(ItemID, num)
	if not ret2 then 
		g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_ERR_OVER_LIMIT, 0, {})
		return false 
	end

	local succeed = itemMgr:addBagItem(MallItemTable[ItemID].sell, num, true, errorCode)
	if false == succeed then
		g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_ERR_BAG_NOSLOT, 0, {})
		return false
	end

	g_tlogMgr:TlogMallFlow(player, 8, MallItemTable[ItemID].sell, num)
	--g_tradeMgr:updateLimit(ItemID, num, ServerID)
	self:UpdateRoleLimit(ItemID, num)
	facMem:setContribution(money - price)
	faction:addUpdateMem(roleSID)

	local BindTmp = MallItemTable[ItemID].buy_bind and 1 or 0
	g_logManager:writeMoneyChange(roleSID,"",7,30,facMem:getContribution(),price,2)
	g_logManager:writePropChange(roleSID,1,30,MallItemTable[ItemID].sell,0,num,BindTmp)

	local factionShoplvl = faction:getStoreLvl()
	local ret = {}
	ret.storeLv = factionShoplvl
	ret.contribution = money-price
	fireProtoMessage(self:getUserID(), FACTION_SC_GETMYFACTIONDATARET, "GetMyFactionDataRet", ret)
	return true
end

function UserInfo:FactionShopBuy(ItemID,num,price,money)
	
end

--商城购买
function UserInfo:Buy(ItemID, num, isShortCut)
	--ItemID是商城表里的购买ID
	local item = g_tradeMgr:getItem(ItemID)
	if item == nil then
		g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_MALL_DOWN, 0, {})
		return
	end
	
	if num <= 0 then
		g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_MALL_FAIL, 0, {})
		return
	end
	
	local Ret = false
	local shopTypActive = false
	local tLogMoneyType = 0
	local tLogItemPrice = 0
	--VIP商城
	--if VIP_SHOP == item.shop_type then
		--Ret = self:VipShopTrade(ItemID, num)
	--end
	
	--金币购物
	if MONEY_TYPE_GOLD == item.money_type then
		shopTypActive = true
		tLogMoneyType = 3
		tLogItemPrice = item.money
		Ret = self:MoneyShopTrade(ItemID, num)
	end
	
	--元宝购物
	if MONEY_TYPE_INGOT == item.money_type then
		shopTypActive = true
		tLogMoneyType = 1
		tLogItemPrice = item.ingot
		Ret = self:IngotShopTrade(ItemID, num, isShortCut)
	end
	
	--绑定金币购物
	--if MONEY_TYPE_GOLD_BIND == item.money_type then
		--Ret = self:BindMoneyShopTrade(ItemID, num)
	--end
	
	--绑定元宝购物
	if MONEY_TYPE_INGOT_BIND == item.money_type then
		shopTypActive = true
		Ret = self:BindIngotShopTrade(ItemID, num)
	end
	
	--帮派商店
	if MONEY_TYPE_FACTION == item.money_type then
		shopTypActive = true
		Ret = self:FactionShopTrade(ItemID, num)
	end
	
	--跨服竞技场商店
	--if MONEY_TYPE_MERITORIOUS == item.money_type then
		--Ret = self:MeritoriousShopTrade(ItemID, num)
	--end
	
	--单服竞技场商店
	--if MONEY_TYPE_HONOR == item.money_type then
		--Ret = self:HonorShopTrade(ItemID, num)
	--end
	
	--积分商店
	--if MONEY_TYPE_JF == item.money_type then
		--Ret = self:JFShopTrade(ItemID, num)
	--end

	if shopTypActive then --and MONEY_TYPE_INGOT ~= item.money_type 
		if isShortCut and Ret then
			local player = g_entityMgr:getPlayer(self:getUserID())
			if player then
				g_tlogMgr:TlogKJGMFlow(player, tLogMoneyType, MallItemTable[ItemID].sell, num, tLogItemPrice)
			end
		end
		self:BuyRet(Ret, item.shop_type, ItemID)
	end
end

function UserInfo:BuyRet(ret, shopType, ItemID)
	local AllLimitLeft = -1
	local allLimit, roleLimit = g_TradePublic:getAllLimitNums(ItemID)	--添加全服限购总量
	if allLimit>0 then
		local alreadyBuy = g_TradePublic:getAlreadyBuy(ItemID, 0)
		AllLimitLeft = allLimit - alreadyBuy
	end

	local RoleLimitCur = self.RoleLimitData[ItemID] or 0
	local retData = {}
	retData.shopType = shopType or 0
	retData.mallRet = ret
	retData.allLimit = AllLimitLeft
	retData.roleLimit = RoleLimitCur
	fireProtoMessage(self:getUserID(),TRADE_SC_TRADEMALLOK,"TradeaMallRetProtocol",retData)
end

--通过物品ID购买
function UserInfo:BuyByItemID(ShopType,ItemID, num)
	if ShopType>=0 and ItemID>=0 and num>=0 then
		if MallItemTable2[ShopType] and MallItemTable2[ShopType][ItemID] then
			local buyID = MallItemTable2[ShopType][ItemID].id or 0
			if buyID>0 then
				self:Buy(buyID,num,true)
			end
		end
	end
end

--背包卖物品
function UserInfo:SellItem(bagSlot, num)
	if bagSlot<0 then return end
	local player = g_entityMgr:getPlayer(self:getUserID())
	if not player then return end
	local RoleSID = player:getSerialID()

	local itemMgr = player:getItemMgr()
	if not itemMgr then return end

	local item = itemMgr:findItem(bagSlot)
	if not item then
		g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_ERR_ITEM_SELL, 0, {})
		return
	end
	
	local count = item:getCount()
	local money = player:getMoney()			--player:getBindMoney()
	
	if count < num or num < 0 then
		g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_ERR_ITEM_SELL, 0, {})
		return
	end
		
	if false == item:getSellable() then
		g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_ERR_NOT_SELL, 0, {})
		return
	end
	
	local slot = itemMgr:findFreeSlot(Item_BagIndex_Back)
	if 0 == slot then
		--math.randomseed(tostring(os.time()):reverse():sub(1, 6))
		slot = math.random(Item_BagIndex_Back_Size)
		itemMgr:deleteItem(Item_BagIndex_Back, slot, errorCode)
	end
	
	--记录出售时间  方便客户端排序
	if item then
		item:setStallPrice(1000)
		item:setStallTime(os.time())
	end

	if count == num then		
		itemMgr:swapItem(Item_BagIndex_Bag, bagSlot, Item_BagIndex_Back, slot, errorCode)
	else
		itemMgr:removeItem(Item_BagIndex_Bag, bagSlot, num, errorCode)
		itemMgr:addItemBySlot(Item_BagIndex_Back, slot, item:getProtoID(), num, false, errorCode)			
	end

	--player:setBindMoney(money + item:getSellPrice() * num)
	player:setMoney(money + item:getSellPrice() * num)
	g_logManager:writeMoneyChange(RoleSID,"",1,96,player:getMoney(),item:getSellPrice() * num,1)
	local protoID = item:getProtoID()
	local Binded = 	item:isBinded() and 1 or 0
	g_logManager:writePropChange(RoleSID,2,96,protoID,0,num,Binded)
	g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_SELL, 0, {})
end

--回购物品
function UserInfo:BackItem(backSlot, num)
	local player = g_entityMgr:getPlayer(self:getUserID())
	if not player then return end
	local RoleSID = player:getSerialID()

	local itemMgr = player:getItemMgr()
	if not itemMgr then return end
	local item = itemMgr:findItem(backSlot, Item_BagIndex_Back)
	if item == nil then
		print("UserInfo:BackItem 01",backSlot,num)
		g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_ERR_ITEM_SELL, 0, {})
		return
	end

	local count = item:getCount()
	local money = player:getMoney()						--player:getBindMoney()
	local price = item:getSellPrice() * num *2			--20151021  回购价格改为10倍
	
	if count < num or num < 0 then
		print("UserInfo:BackItem 02",backSlot,num)
		g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_ERR_ITEM_SELL, 0, {})
		return
	end
	
	--if money < price then
	if not isMoneyEnough(player,price) then
		g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_ERR_MONEY, 0, {})
		return
	end
	
	local slot = itemMgr:findFreeSlot(Item_BagIndex_Bag)
	if 0 == slot then
		g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_ERR_BAG_NOSLOT, 0, {})
		return
	end
	
	if count == num then		
		itemMgr:swapItem(Item_BagIndex_Back, backSlot, Item_BagIndex_Bag, slot, errorCode)
	else
		itemMgr:removeItem(Item_BagIndex_Back, backSlot, num, errorCode)
		itemMgr:addItemBySlot(Item_BagIndex_Bag, slot, item:getProtoID(), num, false, errorCode)			
	end		
	--player:setMoney(money - price)
	costMoney(player, price, 97)
	local protoID = item:getProtoID()
	local Binded = item:isBinded() and 1 or 0
	g_logManager:writePropChange(RoleSID,1,97,protoID,0,num,Binded)
end

function UserInfo:getCurRoleLimit(ItemID)
	local curRoleLimit = 0
	if self.RoleLimitData[ItemID] then
		curRoleLimit = self.RoleLimitData[ItemID]
	end
	return curRoleLimit
end

--20151029
function UserInfo:CheckRoleLimit(ItemID, num)
	local RoleLimit = 0
	if MallLimit[ItemID] then
		RoleLimit = MallLimit[ItemID].roleLimit or 0		
	end

	if RoleLimit>0 then 			--该物品个人限购
		if not self.RoleLimitData[ItemID] then
			self.RoleLimitData[ItemID] = 0
		end

		if self.RoleLimitData[ItemID]+num>RoleLimit then
			g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_ERR_OVER_LIMIT, 0, {})
			return false
		end		
	end
	return true
end

--20151030
function UserInfo:UpdateRoleLimit(ItemID, num)
	local RoleLimit = 0
	if MallLimit[ItemID] then
		RoleLimit = MallLimit[ItemID].roleLimit or 0		
	end

	if RoleLimit<=0 then return end
	self.RoleLimitData[ItemID] = self.RoleLimitData[ItemID] + num    --存数据库
	self:setUpdateDB(true)
	self:cast2DB()
end

function UserInfo:loadMallData(datas)
	local data = unserialize(datas)
    
	--self._date = data.d or self._date
	self.RoleLimitData = data.l or self.RoleLimitData				--修改
   -- self._times = data.t or self._times

    local tickTemp = data.tick
    if tickTemp~=self._timeTick then
    	self:clearRoleLimit()
    end
end

function UserInfo:loadDBMyData(cache_buf)
	if #cache_buf > 0 then
		local datas = protobuf.decode("TradeProtocol", cache_buf)
		local tickTemp = datas.timetick
		if tickTemp == self._timeTick then
			local limitTmp = {}
		   	for i,v in pairs(datas.limits) do	   		
		   		if v.id>0 then
		   			limitTmp[v.id] = v.num
		   		end
		   	end
		   	self.RoleLimitData = limitTmp

			if datas.ingotTrade then
				self.RoleIngotTrade = datas.ingotTrade
			end
		else
			self:clearRoleLimit()
		end
	end
end

function UserInfo:cast2DB()
    if self:getUpdateDB() == false then
        return
    end

    local player = g_entityMgr:getPlayer(self:getUserID())
	if not player then return end
	local roleSID = player:getSerialID()

	local cache_buff = self:writeObject()
	g_engine:savePlayerCache(roleSID, FIELD_TRADE, cache_buff, #cache_buff)

	--local dbStr = {d = self._date, l = self.RoleLimitData, t = self._times, tick = self._timeTick} 			--修改	
	--local dbStr = {l = self.RoleLimitData, tick = self._timeTick} 			--修改	
	self:setUpdateDB(false)
	
	--local UID = self:getUserID()
	--local player = g_entityMgr:getPlayer(UID)
	--g_entityDao:updateRole(player:getSerialID(), serialize(dbStr), "trade")
end

--保存到数据库
function UserInfo:writeObject()	
	local limitDataTmp = {}
	for i,v in pairs(self.RoleLimitData) do
		local DataTmp = {num=0,id=0}
		if i>0 then
			DataTmp.num = v
			DataTmp.id = i			
			table.insert(limitDataTmp,DataTmp)
		end		
	end

	local tradeDateTmp = {		
		limits = limitDataTmp,
		timetick = self._timeTick,
		ingotTrade = self.RoleIngotTrade,
	}
	return protobuf.encode("TradeProtocol", tradeDateTmp)
end

function UserInfo:updateTimetick()
	self._timeTick = time.toedition("day")
end

function UserInfo:clearRoleLimit()
	self.RoleLimitData = {}
	self.RoleIngotTrade = 0
	self:setUpdateDB(true)
	self:cast2DB()
end

function UserInfo:getRoleIngotTrade()
	return self.RoleIngotTrade
end

function UserInfo:updateRoleIngotTrade(value)
	if value > 0 then
		self.RoleIngotTrade = value
		self:setUpdateDB(true)
		self:cast2DB()
	end
end

function UserInfo:speTrade(UID, ItemParam, paramTemp)
	local useItem = 0      		--要使用的道具
	if 1==ItemParam then
		useItem = 1001
	end
	if useItem<=0 then return end

	local itemPrice = 0
	local mallType = 1 			--1 元宝商城，2 绑元商城
	for i,v in pairs(MallItemTable) do
		if 1 == mallType then
			if useItem==v.sell and 0==v.shop_type then
				itemPrice = v.ingot
				break
			end
		elseif 2 == mallType then
			if useItem==v.sell and 1==v.shop_type then
				itemPrice = v.bind_ingot
				break
			end
		else
		end
	end
	if itemPrice<=0 then return end

	local player = g_entityMgr:getPlayer(UID)
	if not player then return end

	local price = itemPrice * 1
	local itemID = useItem

	if 1 == mallType then
		if not isIngotEnough(player, price) then
			g_tradeMgr:sendErrMsg2Client(UID, TRADE_ERR_INGOT, 0, {})
			return
		end
	elseif 2 == mallType then
		if player:getBindIngot() < price then
			g_tradeMgr:sendErrMsg2Client(self:getUserID(), TRADE_ERR_BIND_INGOT, 0, {})
			return
		end
	else
	end

	local logSource = 23
	local paramGet = unserialize(paramTemp) or {}
	if 1001==itemID then
		logSource = LOG_SOURCE_SHORTCUT_4 		--快捷购买 小飞鞋
		if paramGet.mapID and paramGet.posX and paramGet.posY then			
			if g_entityMgr:canSendto(UID, paramGet.mapID, paramGet.posX, paramGet.posY) then
				--costIngot(player, price, logSource)
				if 1 == mallType then
					local context = {mapID=paramGet.mapID,xPos=paramGet.posX,yPos=paramGet.posY}
					local ret = g_tPayMgr:TPayScriptUseMoney(player,price,logSource,"special Ingot Mall",0,0,"UserInfo.speTradeCallBack", serialize(context)) 
					if ret ~= 0 then
						self:sendErrMsg2Client(self:getUserID(), EVENT_COPY_SETS, -57, 0, {})
					end
				elseif 2 == mallType then
					player:setBindIngot(player:getBindIngot() - price)
					local roleSID = player:getSerialID()
					g_logManager:writeMoneyChange(roleSID,"",4,logSource,player:getBindIngot(),price,2)
					g_sceneMgr:enterPublicScene(UID, paramGet.mapID, paramGet.posX, paramGet.posY)
					g_tlogMgr:TlogMallFlow(player, 2, useItem, 1)

					g_logManager:writePropChange(roleSID,1,24,1001,0,1,1)
					g_logManager:writePropChange(roleSID,2,logSource,1001,0,1,1)
				else
				end
			end
		end
	end
end

function UserInfo:speTradeThen(player, mapID, xPos, yPos)
	if not player then return false end
	local ret = g_sceneMgr:enterPublicScene(player:getID(), mapID, xPos, yPos)
	if ret then
		g_tlogMgr:TlogMallFlow(player, 1, 1001, 1)

		local roleSID = player:getSerialID()
		g_logManager:writePropChange(roleSID,1,23,1001,0,1,0)
		g_logManager:writePropChange(roleSID,2,LOG_SOURCE_SHORTCUT_4,1001,0,1,0)
	end
	return ret
end

function UserInfo.speTradeCallBack(roleSID, payRet, money, itemId, itemCount, callBackContext)
	if 0==payRet then
		local context = unserialize(callBackContext)
		local mapID = context.mapID or 0
		local xPos = context.xPos or 0
		local yPos = context.yPos or 0

		local player = g_entityMgr:getPlayerBySID(roleSID)
		if not player then return TPAY_FAILED end
		local UID = player:getID()
		local User = g_tradeMgr:getUserInfo(UID)
		if not User then return TPAY_FAILED end
	
		local ret = User:speTradeThen(player, mapID, xPos, yPos)
		if ret then
			return TPAY_SUCESS
		end
	end
	return TPAY_FAILED
end

function UserInfo:setApplyTrade(roleSID,tick)
	if self._applyTrade and roleSID ~= "" then 			--and roleSID>0 
		if not self._applyTrade[roleSID] then
			self._applyTrade[roleSID] = 0
		end
		
		self._applyTrade[roleSID] = tick
	end
end

function UserInfo:getApplyTradeTick(roleSID)
	if self._applyTrade and roleSID ~= "" then 		--and roleSID>0 
		if self._applyTrade[roleSID] then
			return self._applyTrade[roleSID]
		else
			return 0
		end
	end
end

function UserInfo:clearApplyTrade()
	if self._applyTrade then
		self._applyTrade = {}
	end
end

function UserInfo:setRecvApplyTick(tick)
	self._recvApplyTick = tick
end

function UserInfo:getRecvApplyTick()
	return self._recvApplyTick
end