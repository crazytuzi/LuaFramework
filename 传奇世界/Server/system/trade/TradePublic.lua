--TradePublic.lua
--/*-----------------------------------------------------------------
 --* Module:  TradePublic.lua
 --* Author:  liucheng
 --* Modified: 2015年12月3日 15:49:14
 --* Purpose: Implementation of the class TradePublic
 -------------------------------------------------------------------*/
require ("system.trade.TradeMallDB")

 TradePublic = class(nil, Singleton)

function TradePublic:__init()
	self._AllLimitData = {}			--全服限购数据	20151030   记录某个物品当前已购买了多少个
end

function TradePublic:setAllLimitData(data)
	local dataTmp = unserialize(data) or {}
	self._AllLimitData = dataTmp
end

function TradePublic:updateAllLimitData(data)
	local dataTmp = unserialize(data) or {}
	self._AllLimitData = dataTmp
	updateCommonData(MALL_ALL_LIMIT,self._AllLimitData)
end	

function TradePublic:getAllLimitNums(ItemBuyID)
	local AllLimitNums = -1
	local RoleLimitNums = -1

	if MallLimit[ItemBuyID] then
		AllLimitNums = MallLimit[ItemBuyID].allLimit or -1
		RoleLimitNums = MallLimit[ItemBuyID].roleLimit or -1
	end

	return AllLimitNums, RoleLimitNums
end

--如果是限购的物品  返回已经购买了多少个   如果不限购  返回0
function TradePublic:getAlreadyBuy(ItemBuyID, ServerID)
	local alreadyBuy = 0
	local allLimit, roleLimit = self:getAllLimitNums(ItemBuyID)
	if allLimit>0 then
		if not self._AllLimitData[ServerID] then
			self._AllLimitData[ServerID] = {}			
		end
		alreadyBuy = self._AllLimitData[ServerID][ItemBuyID] or 0
	end
	return alreadyBuy
end

function TradePublic:addAlreadyBuy(num, ItemBuyID, ServerID)
	local allLimit, roleLimit = self:getAllLimitNums(ItemBuyID)
	if allLimit>0 then
		if not self._AllLimitData[ServerID] then
			self._AllLimitData[ServerID] = {}
		end

		if not self._AllLimitData[ServerID][ItemBuyID] then
			self._AllLimitData[ServerID][ItemBuyID] = 0
		end

		self._AllLimitData[ServerID][ItemBuyID] = self._AllLimitData[ServerID][ItemBuyID]+num
		updateCommonData(MALL_ALL_LIMIT,self._AllLimitData)
	end
end

function TradePublic:GetAllLimitLeft(roleSID, ItemID)
	local ServerID = 0
	local AllLimitLeft = -1
	local allLimit, roleLimit = self:getAllLimitNums(ItemID)
	if allLimit>0 then
		local allLimitCur = self._AllLimitData[ServerID][ItemID] or 0
		AllLimitLeft = allLimit - allLimitCur
	end

	local curRoleLimit = 0
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end
	local UID = player:getID()

	local User = g_tradeMgr:getUserInfo(UID)
	if User then
		curRoleLimit = User:getCurRoleLimit(ItemID)
	end

	local retData = {}
	retData.allLimit = allLimit
	retData.allLimitLeft = AllLimitLeft
	retData.roleLimit = roleLimit
	retData.roleLimitLeft = roleLimit - curRoleLimit
	fireProtoMessageBySid(roleSID, TRADE_SC_ALLLIMITRET, "AllLimitRetProtocol", retData)
end

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

function TradePublic.getInstance()
	return TradePublic()
end

g_TradePublic = TradePublic.getInstance()