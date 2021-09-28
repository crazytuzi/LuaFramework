--Trade.lua
--/*-----------------------------------------------------------------
 --* Module:  Trade.lua
 --* Author:  HE Ningxu
 --* Modified: 2014年5月14日
 --* Purpose: Implementation of the class Trade
 -------------------------------------------------------------------*/

require ("base.class")
Trade = class()

local prop = Property(Trade)
prop:accessor("TradeID")
prop:accessor("UserAID")
prop:accessor("UserBID")
prop:accessor("LockA", false)
prop:accessor("LockB", false)
prop:accessor("Version", 0)
prop:accessor("TradeA", false)
prop:accessor("TradeB", false)

function Trade:__init(tradeid, userAID, userBID)
	self._userAitem = {}
	self._userBitem = {}
	self._userItem = {}
	prop(self, "TradeID", tradeid)
	prop(self, "UserAID", userAID)
	prop(self, "UserBID", userBID)	

	self._userABillno = nil
	self._userBBillno = nil
end

--交易开始
function Trade:tradeOn()
	local AID = self:getUserAID()
	local BID = self:getUserBID()
	local UserA = g_tradeMgr:getUserInfo(AID)		
	local UserB = g_tradeMgr:getUserInfo(BID)
	--检查玩家B的背包空间
	--if g_entityMgr:getPlayer(BID):getItemMgr():getEmptySize() < 4 then
	   	--g_tradeMgr:sendErrMsg2Client(BID, TRADE_ERR_BAG_NOTENOUGH, 0, {})
	    --return
	--end
	--设置交易状态
	if UserA and UserB then
		UserA:setTradeState(TRADE_ON)
		UserB:setTradeState(TRADE_ON)
		UserA:setTradeID(self:getTradeID())
		UserB:setTradeID(self:getTradeID())
		local playerA = g_entityMgr:getPlayer(self:getUserAID())
        local playerB = g_entityMgr:getPlayer(self:getUserBID())
        if not playerA or not playerB then return end

		g_tradeMgr:SEND_TRADE_SC_RET(AID,self:getTradeID(),true,self:getUserBID(),playerB:getLevel(),playerB:getName())
		g_tradeMgr:SEND_TRADE_SC_RET(BID,self:getTradeID(),true,self:getUserAID(),playerA:getLevel(),playerA:getName())
	else
		g_tradeMgr:tradeDelete(self:getTradeID())
	end		
end

--交易关闭
function Trade:close()
	local AID = self:getUserAID()
	local BID = self:getUserBID()
	local playerA = g_entityMgr:getPlayer(AID)
	local playerB = g_entityMgr:getPlayer(BID)
	
	--回滚
	if playerA and self._userABillno then
		g_tPayMgr:TPayScriptCancelTransferMoney(playerA, self._userABillno)
	end

	if playerB and self._userBBillno then
		g_tPayMgr:TPayScriptCancelTransferMoney(playerB, self._userBBillno)
	end 
end

--交易结束
function Trade:tradeOff()
	local AID = self:getUserAID()
	local BID = self:getUserBID()
	local UserA = g_tradeMgr:getUserInfo(AID)
	local UserB = g_tradeMgr:getUserInfo(BID)
	
	if UserA then
		UserA:setTradeState(TRADE_FREE)
	end

	if UserB then
		UserB:setTradeState(TRADE_FREE)
	end

	UserB:setRecvApplyTick(0)
	local playerB = g_entityMgr:getPlayer(BID)
	if not playerB then return end
	local BSID = playerB:getSerialID()
	UserA:setApplyTrade(BSID,nil)
end

--更改交易物品
function Trade:tradeItem(player, bagSlot, num, tradeSlot)
	if not player then return end
	local UID = player:getID()

	local itemTmp = {}
	if self:getUserAID() == UID then
		if self:getLockA() == true then
			return
		end
		itemTmp = self._userAitem
	elseif self:getUserBID() == UID then
		if self:getLockB() == true then
			return
		end
		itemTmp = self._userBitem
	else
	end

	--local User = g_tradeMgr:getUserInfo(UID)
	local vip = 0
	if 0 == tradeSlot then
		--放入元宝
	    if TRADE_INGOT == bagSlot then 		
			local Ingot = player:getIngot()
			if num < 0 or num > TRADE_INGOT_ONCE then		--num > MAX_TRADE_INGOT or    or User._times >= VIP_TRADE_INGOT[vip]
				--元宝超出限制
				itemTmp[TRADE_INGOT] = {-1, Ingot, -1, 0}
				self:SEND_TRADE_SC_ITEMRET(player, TRADE_INGOT)
				g_tradeMgr:sendErrMsg2Client(UID, TRADE_ERR_INGOT_ERR, 0, {})
				return
			end

			if not isIngotEnough(player, num) then
				--print("元宝不足")
				itemTmp[TRADE_INGOT] = {-1, Ingot, -1, 0}
				self:SEND_TRADE_SC_ITEMRET(player, TRADE_INGOT)
				g_tradeMgr:sendErrMsg2Client(UID, TRADE_ERR_INGOT, 0, {})
				return
			end

			--预先计算税及手续费
			local Tax = num*TRADE_TAX_RATE + TRADE_ITEM_ONCE
			if not isIngotEnough(player, num + Tax) then
				itemTmp[TRADE_INGOT] = {-1, Ingot, -1, 0}
				self:SEND_TRADE_SC_ITEMRET(player, TRADE_INGOT)
				g_tradeMgr:sendErrMsg2Client(UID, TRADE_ERR_COMMISSION, 0, {})
				return
			end

			itemTmp[TRADE_INGOT] = {-1, Ingot, -1, num}		
            self:SEND_TRADE_SC_ITEMRET(player, TRADE_INGOT)
            return
        end

    	--放入物品
		local itemMgr = player:getItemMgr()
		if not itemMgr then return end

		local item = itemMgr:findItem(bagSlot)
		local proto = item:getProtoID()
		local count = item:getCount()
		if item and item:isBinded() then
			g_tradeMgr:sendErrMsg2Client(UID, TRADE_ERR_ITEM_SELL, 0, {})
			return
		end

		--贵重物品不能交易
		local limitNum = 0
		local itemInfoTmp = TradeLimit[proto]    --g_ActivityMgr:getItemInfo(proto)
		if itemInfoTmp then
			if itemInfoTmp.limitTrade and itemInfoTmp.limitTrade > 0 then
				g_tradeMgr:sendErrMsg2Client(UID, TRADE_ERR_VALUABLE_ITEM, 0, {})
				return
			end
			limitNum = itemInfoTmp.limitNum or 0
		else
		--没配置的物品都不能交易
			g_tradeMgr:sendErrMsg2Client(UID, TRADE_ERR_UNABLE_TRADE, 0, {})
			return
		end

		--强化过的装备不能交易
		local itemStrengthLvl = itemMgr:getItemEquipStrengthLevel(bagSlot)
		if itemStrengthLvl > 0 then
			g_tradeMgr:sendErrMsg2Client(UID, TRADE_ERR_STRENG_EQUIP, 0, {})
			return
		end

		--数目不能超过限制
		for i = 1, 4 do
			if not itemTmp[i] then
				if count < num then
					--print("物品不足")
					g_tradeMgr:sendErrMsg2Client(UID, TRADE_ERR_ITEM_SELL, 0, {})
					return
				end

				if limitNum > 0 and num > limitNum then
					g_tradeMgr:sendErrMsg2Client(UID, TRADE_ERR_ITEM_NUM_MAX, 0, {})
					return
				end

				itemTmp[i] = {bagSlot, proto, i, num}
				self:SEND_TRADE_SC_ITEMRET(player, i)
				return
			end

			if itemTmp[i][1] and bagSlot == itemTmp[i][1] then
				if count < itemTmp[i][4] + num then
					--print("物品不足")
					g_tradeMgr:sendErrMsg2Client(UID, TRADE_ERR_ITEM_SELL, 0, {})
					return
				end

				if limitNum > 0 and itemTmp[i][4] + num > limitNum then
					g_tradeMgr:sendErrMsg2Client(UID, TRADE_ERR_ITEM_NUM_MAX, 0, {})
					return
				end

				itemTmp[i][4] = itemTmp[i][4] + num
				self:SEND_TRADE_SC_ITEMRET(player, i)
				return
			end
		end
		g_tradeMgr:sendErrMsg2Client(UID, TRADE_ERR_NO_TRADE_SLOT, 0, {})   --位置不足
		return
	end

	--取出元宝
	if TRADE_INGOT == tradeSlot then
		--元宝 		--print("无法取出")
		return
	end

	--取出物品
	if itemTmp[tradeSlot] then
		if num > itemTmp[tradeSlot][4] then
			--print("交易物品不足")
			g_tradeMgr:sendErrMsg2Client(UID, TRADE_ERR_NO_TRADE_ITEM, 0, {})
			return
		else
			itemTmp[tradeSlot][4] = itemTmp[tradeSlot][4] - num
			self:SEND_TRADE_SC_ITEMRET(player, tradeSlot)
			if 0 == itemTmp[tradeSlot][4] then
				itemTmp[tradeSlot] = nil
			end
		end
	else
		--print("交易物品不足")
		g_tradeMgr:sendErrMsg2Client(UID, TRADE_ERR_NO_TRADE_ITEM, 0, {})
		return
	end
end

--交易锁定
function Trade:tradeLock(player)
	if not player then return end
	local UID = player:getID()

	local ret = self:tradeMoneyEnough(player)
	if ret then
		if UID == self:getUserAID() then
			self:setLockA(true)
		end

		if UID == self:getUserBID() then
			self:setLockB(true)
		end

		if true == self:getLockA() and true == self:getLockB() then
			--A  B中至少要有一方放入了元宝或者物品
			local Input = false   			--是否有一方放入了  元宝  或者  物品
			if self._userBitem[TRADE_INGOT] and self._userBitem[TRADE_INGOT][4] and self._userBitem[TRADE_INGOT][4] > 0 then
				Input = true
			end

			if not Input then
				for i = 1, 4 do 
					if self._userBitem[i] and self._userBitem[i][4] and self._userBitem[i][4] > 0 then
						Input = true
					end
					if Input then break end
				end
			end

			--如果B 既没放元宝  又没放 物品
			if not Input then
				if self._userAitem[TRADE_INGOT] and self._userAitem[TRADE_INGOT][4] and self._userAitem[TRADE_INGOT][4] > 0 then
					Input = true
				end
			end

			if not Input then
				for i = 1, 4 do 
					if self._userAitem[i] and self._userAitem[i][4] and self._userAitem[i][4] > 0 then
						Input = true
					end
					if Input then break end
				end
			end

			if not Input then
				if UID == self:getUserAID() then
					self:setLockA(false)
				end

				if UID == self:getUserBID() then
					self:setLockB(false)
				end
				g_tradeMgr:sendErrMsg2Client(UID, TRADE_ERR_EMPTY_TRADE, 0, {})
				return
			end
		end
		self:SEND_TRADE_SC_LOCKRET(UID)
	end
end

--交易
function Trade:doTrade(UID, ver)
	if self:getVersion() == ver then
		if UID == self:getUserAID() then
			self:setTradeA(true)
			self:SEND_TRADE_SC_TRADERET(UID, true)
		end
		if UID == self:getUserBID() then
			self:setTradeB(true)
			self:SEND_TRADE_SC_TRADERET(UID, true)
		end
		if true == self:getTradeA() and true == self:getTradeB() then
			return self:itemExchange()
		end
		return true
	else
		self:SEND_TRADE_SC_TRADERET(UID, false)
		g_tradeMgr:sendErrMsg2Client(self:getUserAID(), TRADE_ERR_FAILED, 0, {})
		g_tradeMgr:sendErrMsg2Client(self:getUserBID(), TRADE_ERR_FAILED, 0, {})	
		return false
	end
	
end

--物品交换过程
function Trade:itemExchange()
	local AID = self:getUserAID()
	local BID = self:getUserBID()
	local playerA = g_entityMgr:getPlayer(AID)
	local playerB = g_entityMgr:getPlayer(BID)
	if not playerA or not playerB then
		return false
	end
	
	local itemMgrA = playerA:getItemMgr()
	local itemMgrB = playerB:getItemMgr()
	local UserA = g_tradeMgr:getUserInfo(AID)
	local UserB = g_tradeMgr:getUserInfo(BID)
	
	local AIngotChange = {put=0,items=0}
	local BIngotChange = {put=0,items=0} 
	--元宝交换
	if self._userBitem[TRADE_INGOT] then
		local num = self._userBitem[TRADE_INGOT][4]
		if num < 0 then		--or num > MAX_TRADE_INGOT
			--发送交易结果
			self:SEND_TRADE_SC_TRADERET(playerB:getID(), false)

			g_tradeMgr:sendErrMsg2Client(playerA:getID(), TRADE_ERR_INGOT_ERR, 0, {})
			g_tradeMgr:sendErrMsg2Client(playerB:getID(), TRADE_ERR_INGOT_ERR, 0, {})
			return false
		end
		BIngotChange.put = num
	end

	if self._userAitem[TRADE_INGOT] then
		local num = self._userAitem[TRADE_INGOT][4]
		if num < 0 then	-- or num > MAX_TRADE_INGOT
			--发送交易结果
			self:SEND_TRADE_SC_TRADERET(playerA:getID(), false)

			g_tradeMgr:sendErrMsg2Client(playerA:getID(), TRADE_ERR_INGOT_ERR, 0, {})
			g_tradeMgr:sendErrMsg2Client(playerB:getID(), TRADE_ERR_INGOT_ERR, 0, {})
			print("ingot error shutdown")
			return false
		end
		AIngotChange.put = num
	end

	--检查今日元宝交易数目是否超出限制
	local curAIngotTrade = UserA:getRoleIngotTrade()
	if curAIngotTrade + BIngotChange.put + AIngotChange.put > TRADE_INGOT_MAX then
		--发送交易结果
		self:SEND_TRADE_SC_TRADERET(playerA:getID(), false)

		g_tradeMgr:sendErrMsg2Client(playerA:getID(), TRADE_ERR_INGOT_MAX, 0, {})
		g_tradeMgr:sendErrMsg2Client(playerB:getID(), TRADE_ERR_OTHER_INGOT_MAX, 0, {})
		return false
	end

	local curBIngotTrade = UserB:getRoleIngotTrade()
	if curBIngotTrade + BIngotChange.put + AIngotChange.put > TRADE_INGOT_MAX then
		--发送交易结果
		self:SEND_TRADE_SC_TRADERET(playerB:getID(), false)

		g_tradeMgr:sendErrMsg2Client(playerA:getID(), TRADE_ERR_OTHER_INGOT_MAX, 0, {})
		g_tradeMgr:sendErrMsg2Client(playerB:getID(), TRADE_ERR_INGOT_MAX, 0, {})
		return false
	end

	local AItem = {0,0,0,0}						--物品ID
	local AItemNum = {0,0,0,0}					--每样物品的数目
	--local AItemShuNum = {0,0,0,0}				--每个物品的随机属性条数  现在改为道具品质 颜色
	local BItem = {0,0,0,0}
	local BItemNum = {0,0,0,0}
	--local BItemShuNum = {0,0,0,0}
	-- B->A
	for i = 1, 4 do
		if self._userBitem[i] then
			local bagSlot = self._userBitem[i][1]
			local proto = self._userBitem[i][2]
			local num = self._userBitem[i][4]
			local item = itemMgrB:findItem(bagSlot)
			if item then
				BIngotChange.items = BIngotChange.items+1
				BItem[i] = proto
				BItemNum[i] = num
				--local ItemPrototype = item:getProto()
				--if ItemPrototype then
					--BItemShuNum[i] = ItemPrototype.defaultColor
				--end
			end
		end
	end

	-- A->B
	for i = 1, 4 do
		if self._userAitem[i] then
			local bagSlot = self._userAitem[i][1]
			local proto = self._userAitem[i][2]
			local num = self._userAitem[i][4]
			local item = itemMgrA:findItem(bagSlot)
			if item then
				AIngotChange.items = AIngotChange.items+1
				AItem[i] = proto
				AItemNum[i] = num
			end
		end
	end

	--20150907
	local Atax = AIngotChange.put*TRADE_TAX_RATE + TRADE_ITEM_ONCE 				--AIngotChange.items*TRADE_ITEM_TAX
	--if Atax > TRADE_TAX_MAX then
		--Atax = TRADE_TAX_MAX
	--end
	local Btax = BIngotChange.put*TRADE_TAX_RATE + TRADE_ITEM_ONCE 				--BIngotChange.items*TRADE_ITEM_TAX
	--if Btax > TRADE_TAX_MAX then
		--Btax = TRADE_TAX_MAX
	--end

	local tradeContext = {tradeID = self:getTradeID(), version = self:getVersion(), AItem = AItem, AItemNum = AItemNum, BItem = BItem, BItemNum = BItemNum}
	local ret1 = g_tPayMgr:TPayScriptTransferMoney(playerA, playerB, AIngotChange.put, Atax, 3, "", 0, 0, "TradeServlet.APay2BCallBack", serialize(tradeContext))
	local ret2 = g_tPayMgr:TPayScriptTransferMoney(playerB, playerA, BIngotChange.put, Btax, 3, "", 0, 0, "TradeServlet.BPay2ACallBack", serialize(tradeContext))
	if ret1 ~= 0 or ret2 ~= 0 then
		return false
	end

	--更新今日元宝交易数目
	if AIngotChange.put + BIngotChange.put > 0 then
		UserA:updateRoleIngotTrade(curAIngotTrade + AIngotChange.put + BIngotChange.put)
		UserB:updateRoleIngotTrade(curBIngotTrade + AIngotChange.put + BIngotChange.put)
	end
	
	g_achieveSer:costIngot(playerA:getSerialID(), AIngotChange.put + Atax)
	g_achieveSer:costIngot(playerB:getSerialID(), BIngotChange.put + Btax)
	
	local AIngotTradeChange = BIngotChange.put - AIngotChange.put - Atax
	local BIngotTradeChange = AIngotChange.put - BIngotChange.put - Btax
	if AIngotTradeChange > 0 then
		g_PayRecord:Record(playerA:getID(), AIngotTradeChange, CURRENCY_INGOT, 2)
	end
	if BIngotTradeChange > 0 then
		g_PayRecord:Record(playerB:getID(), BIngotTradeChange, CURRENCY_INGOT, 2)
	end
	return true
end

--转账是否成功
function Trade:SetTransferBillno(UID, billno)
	if UID == self:getUserAID() then
		self._userABillno = billno
		return self._userBBillno
	end

	if UID == self:getUserBID() then
		self._userBBillno = billno
		return self._userABillno
	end
end

--物品真正交换
function Trade:itemRealExchange(tradeContext)
	local AID = self:getUserAID()
	local BID = self:getUserBID()
	local playerA = g_entityMgr:getPlayer(AID)
	local playerB = g_entityMgr:getPlayer(BID)
	if not playerA or not playerB then
		return false
	end

	local itemMgrA = playerA:getItemMgr()
	local itemMgrB = playerB:getItemMgr()
	local UserA = g_tradeMgr:getUserInfo(AID)		
	local UserB = g_tradeMgr:getUserInfo(BID)
	
	local AIngotChange = {put=0,items=0}
	local BIngotChange = {put=0,items=0} 
	local AItem = {0,0,0,0}						--物品ID
	local AItemNum = {0,0,0,0}					--每样物品的数目
	--local AItemShuNum = {0,0,0,0}				--每个物品的随机属性条数  现在改为道具品质 颜色
	local BItem = {0,0,0,0}
	local BItemNum = {0,0,0,0}
	--local BItemShuNum = {0,0,0,0}

	--tlog面对面交易流水
	local tradePreDesc = ''
	local billno = self._userABillno

	-- B->A
	for i = 1, 4 do
		if self._userBitem[i] then
			local bagSlot = self._userBitem[i][1]
			local proto = self._userBitem[i][2]
			local num = self._userBitem[i][4]
			local item = itemMgrB:findItem(bagSlot)
			local Bcount = item:getCount()
			local freeSlot = itemMgrA:findFreeSlot()
			if item and item:isBinded() == false and freeSlot > 0 then
			    local ret = itemMgrB:removeItem(Item_BagIndex_Bag, bagSlot, num, errorCode)
				if ret then
					if Bcount == num then                    
						itemMgrA:addItemByObject(Item_BagIndex_Bag, freeSlot, item, errorCode)
					else
						itemMgrA:addItemBySlot(Item_BagIndex_Bag, freeSlot, proto, num, false, errorCode)
					end
					BIngotChange.items = BIngotChange.items+1
					
					g_logManager:writePropChange(playerB:getSerialID(),2,3,proto,0,num,0)
					g_logManager:writePropChange(playerA:getSerialID(),1,3,proto,0,num,0)
					
					if string.len(tradePreDesc) == 0 then
						tradePreDesc = g_tlogMgr:TlogFaceTradeFlow(playerA, playerB, billno, 2, proto, num)
					else
						g_tlogMgr:TlogFaceTradeFlow(tradePreDesc, 2, proto, num)
					end

					BItem[i] = proto
					BItemNum[i] = num
					--local ItemPrototype = item:getProto()
					--if ItemPrototype then
						--BItemShuNum[i] = ItemPrototype.defaultColor
					--end
				end
			 end
		end
	end

	-- A->B
	for i = 1, 4 do
		if self._userAitem[i] then
			local bagSlot = self._userAitem[i][1]
			local proto = self._userAitem[i][2]
			local num = self._userAitem[i][4]
			local item = itemMgrA:findItem(bagSlot)
			local Acount = item:getCount()
			local freeSlot = itemMgrB:findFreeSlot()
			if item and item:isBinded() == false and freeSlot > 0 then
			    local ret = itemMgrA:removeItem(Item_BagIndex_Bag, bagSlot, num, errorCode)
				if ret then
					if Acount == num then                    
						itemMgrB:addItemByObject(Item_BagIndex_Bag, freeSlot, item, errorCode)
					else
						itemMgrB:addItemBySlot(Item_BagIndex_Bag, freeSlot, proto, num, false, errorCode)
					end
					AIngotChange.items = AIngotChange.items+1
					
					g_logManager:writePropChange(playerA:getSerialID(),2,3,proto,0,num,0)
					g_logManager:writePropChange(playerB:getSerialID(),1,3,proto,0,num,0)
					
					if string.len(tradePreDesc) == 0 then
						tradePreDesc = g_tlogMgr:TlogFaceTradeFlow(playerA, playerB, billno, 1, proto, num)
					else
						g_tlogMgr:TlogFaceTradeFlow(tradePreDesc, 1, proto, num)
					end

					AItem[i] = proto
					AItemNum[i] = num
					--local ItemPrototype = item:getProto()
					--if ItemPrototype then
						--AItemShuNum[i] = ItemPrototype.defaultColor
					--end
				end
			 end
		end
	end

	g_tradeMgr:sendErrMsg2Client(self:getUserAID(), TRADE_ERR_SUCCEED, 0, {})
	g_tradeMgr:sendErrMsg2Client(self:getUserBID(), TRADE_ERR_SUCCEED, 0, {})
	
	if string.len(tradePreDesc) == 0 then
		tradePreDesc = g_tlogMgr:TlogFaceTradeFlow(playerA, playerB, billno, 3, 0, 0)
	else
		g_tlogMgr:TlogFaceTradeFlow(tradePreDesc, 3, 0, 0)
	end
	return true
end

function Trade:getSize(UID)
	if UID == self:getUserAID() then
		local count = 0
		for i, v in ipairs(self._userAitem) do
			if v then
				count = count + 1
			end
		end
		return count
	else
		local count = 0
		for i, v in ipairs(self._userBitem) do
			if v then
				count = count + 1
			end
		end
		return count
	end
end

function Trade:upVersion()
	local ver = self:getVersion()
	self:setVersion(ver + 1)
end

function Trade:SEND_TRADE_SC_LOCKRET(UID)
	local retData = {}
	retData.tradeID = self:getTradeID()
	retData.roleID = UID
	fireProtoMessage(self:getUserAID(),TRADE_SC_LOCKRET,"TradeLockRetProtocol",retData)
	fireProtoMessage(self:getUserBID(),TRADE_SC_LOCKRET,"TradeLockRetProtocol",retData)
end

--self._userAitem[i] = {bagSlot, proto, i, num}
function Trade:SEND_TRADE_SC_ITEMRET(player, tradeSlot)
	--local player = g_entityMgr:getPlayer(UID)
	if not player then return end
	local UID = player:getID()

	local itemMgr = player:getItemMgr()
	if not itemMgr then return end

	local retData = {}
	retData.roleID = UID
	retData.tradeItemSlot = tradeSlot
	
	self:upVersion()
	local itembuff = LuaMsgBuffer:new()
	if UID == self:getUserAID() then
		retData.itemNum = self._userAitem[tradeSlot][4]
		retData.version = self:getVersion()	    
		if tradeSlot ~= TRADE_INGOT then
			--local itembuff = LuaMsgBuffer:new()
			itemMgr:writeItem4lua(itembuff, self._userAitem[tradeSlot][1])
			retData.itemInfo = itembuff:popPbc()
			--itembuff:delete()
		end
	else
	    retData.itemNum = self._userBitem[tradeSlot][4]
		retData.version = self:getVersion()
		if tradeSlot ~= TRADE_INGOT then
			itemMgr:writeItem4lua(itembuff, self._userBitem[tradeSlot][1])
			retData.itemInfo = itembuff:popPbc()
			--itembuff:delete()
		end
	end

	fireProtoMessage(self:getUserAID(),TRADE_SC_ITEMRET,"TradeItemRetProtocol",retData)
	fireProtoMessage(self:getUserBID(),TRADE_SC_ITEMRET,"TradeItemRetProtocol",retData)
	itembuff:delete()
end
 
function Trade:SEND_TRADE_SC_TRADERET(UID, b_trade)
	local retData = {}
	retData.tradeID = self:getTradeID()
	retData.roleID = UID
	retData.isTrade = b_trade	
	fireProtoMessage(self:getUserAID(),TRADE_SC_TRADERET,"TradeDoRetProtocol",retData)
	fireProtoMessage(self:getUserBID(),TRADE_SC_TRADERET,"TradeDoRetProtocol",retData)	
end

--20151029 交易元宝是否充足
function Trade:tradeMoneyEnough(player)
	if not player then return end
	local UID = player:getID()

	local tradeItem = {}
	local findTradeInfo = false
	if UID == self:getUserAID() then
		tradeItem = self._userAitem
		findTradeInfo = true
	end	

	if UID == self:getUserBID() then
		tradeItem = self._userBitem
		findTradeInfo = true
	end

	if not findTradeInfo then
		return false
	end

	local putIngot = 0
	if tradeItem[TRADE_INGOT] then 
		putIngot = tradeItem[TRADE_INGOT][4] or 0 
	end

--[[
	local putItems = 0
	for i = 1, 4 do
		if tradeItem[i] and tradeItem[i][4] then 
			if tradeItem[i][4]>0 then
				putItems = putItems + 1
			end
		end
	end
]]
	--local maxTax = putIngot*TRADE_TAX_RATE + TRADE_ITEM_ONCE    --putItems*TRADE_ITEM_TAX
	--if maxTax>200 then maxTax = 200 end

	if not isIngotEnough(player, putIngot) then
		g_tradeMgr:sendErrMsg2Client(UID, TRADE_ERR_INGOT, 0, {})
		return false
	end

	--预先计算税及手续费
	local Tax = putIngot*TRADE_TAX_RATE + TRADE_ITEM_ONCE
	--if not isIngotEnough(player, putIngot + Tax) then
		--g_tradeMgr:sendErrMsg2Client(UID, TRADE_ERR_COMMISSION, 0, {})
		--return false
	--end
	--这里不提示元宝不足   提示具体收的手续费
	local curIngot = player:getIngot()
	if curIngot < putIngot + Tax then
		matNotEnough(player, 2, Tax)
		return false
	end
	return true
end