--Author:		bishaoqing
--DateTime:		2016-05-13 15:00:15
--Region:		黑市管理类
local BlackMarketCtr = class("BlackMarketCtr")
local Arg = require("src/layers/blackMarket/BlackMarketCfg")
local MarketPanel = require("src/layers/blackMarket/BlackMarketPanel")
--构造函数
function BlackMarketCtr:ctor( ... )
	-- body
	self.m_stAllItems = {}
	self.m_iItemUid = 0
	self.m_nShopType = Arg.BlackMarket
	self:AddEvent()
end

function BlackMarketCtr:openBookMarket( ... )
	-- body
	checkIfSecondaryPassNeed(function()
		self:setShopType(Arg.BookMarket)
		-- local oPanel = MarketPanel.new()
		local oPanel = MarketPanel.getInstance()
		oPanel:setShopType(Arg.BookMarket)
		oPanel:setLimitLabelVisible(false)
		oPanel:setTitle(Arg.BookMarket)
		oPanel:setPerson(Arg.BookMarket)
		return oPanel
		end)
end

function BlackMarketCtr:openBlackMarket( ... )
	-- body
	checkIfSecondaryPassNeed(function( ... )
		-- body
		self:setShopType(Arg.BlackMarket)
		-- local oPanel = MarketPanel.new()
		local oPanel = MarketPanel.getInstance()
		oPanel:setShopType(Arg.BlackMarket)
		oPanel:setLimitLabelVisible(true)
		oPanel:setTitle(Arg.BlackMarket)
		oPanel:setPerson(Arg.BlackMarket)
		return oPanel
	end)
	
end

function BlackMarketCtr:setShopType( nShopType )
	-- body
	self.m_nShopType = nShopType
end

--添加监听
function BlackMarketCtr:AddEvent( ... )
	-- body
	g_msgHandlerInst:registerMsgHandler(TRADE_SC_BLACK_RET, handler(self, self.OnMarketRev))
	g_msgHandlerInst:registerMsgHandler(TRADE_SC_MYSTBUY_RET, handler(self, self.OnBuyReturn))
	g_msgHandlerInst:registerMsgHandler(TRADE_SC_MYST_LIMIT_RET, handler(self, self.OnLimitReturn))
end


function BlackMarketCtr:reRegisteCallBack()
    g_msgHandlerInst:registerMsgHandler(TRADE_SC_MYSTBUY_RET, handler(self, self.OnBuyReturn))
end

--删除监听
function BlackMarketCtr:RemoveEvent( ... )
	-- body
	g_msgHandlerInst:registerMsgHandler(TRADE_SC_BLACK_RET, nil)
	g_msgHandlerInst:registerMsgHandler(TRADE_SC_MYSTBUY_RET, nil)
	g_msgHandlerInst:registerMsgHandler(TRADE_SC_MYST_LIMIT_RET, nil)
end

--获取黑市信息协议发起
function BlackMarketCtr:GetMsgFromServer( ... )
	-- body
	local t = {}
	t.shopType = self.m_nShopType
	g_msgHandlerInst:sendNetDataByTableExEx(TRADE_CS_MYSTREQ, "MysteryShopReqProtocol", t)
end

--获取黑市信息返回
function BlackMarketCtr:OnMarketRev( sBuffer )
	-- body
	local stProto = g_msgHandlerInst:convertBufferToTable("MysteryBlackMallRetProtocol", sBuffer) 
	if stProto then
		self:Reset(stProto)
	end

	--抛出刷新黑市的事件
	Event.Dispatch(EventName.UpdateBlackMarket)
end

--获取购买协议返回
function BlackMarketCtr:OnBuyReturn( sBuffer )
	-- body
    print("black market ctr line 91 ........................................")
	local stProto = g_msgHandlerInst:convertBufferToTable("MysteryShopBuyRetProtocol", sBuffer) 
	if stProto then
		local bBuyret = stProto.buyRet
		-- local nNeedMoreIngot = stProto.needMoreIngot
		-- local nBuyCountLeft = stProto.buyCountLeft
	end

	--抛出刷新黑市的事件
	-- Event.Dispatch(EventName.UpdateBlackMarket)			--本意是抛出一个刷新命令，服务器暂时没做，就改为抛出一个重新拉取命令
	self:GetMsgFromServer()
end

--获取单条黑市商品全服限购信息
function BlackMarketCtr:GetLimitFromServer( oItem )
	-- body
	local t = {}
	t.shopType = self.m_nMallID
	t.arrayIndex = oItem:GetArrayIndex()
	t.itemID = oItem:GetItemID()
	t.moneyType = oItem:GetMoneyType()
	g_msgHandlerInst:sendNetDataByTableExEx(TRADE_CS_MYST_LIMIT_REQ, "MysteryLimitReqProtocol", t)

	--转菊花等网络连接
	addNetLoading(TRADE_CS_MYST_LIMIT_REQ, TRADE_SC_MYST_LIMIT_RET) 
end

--获取单条黑市商品限购返回
function BlackMarketCtr:OnLimitReturn( sBuffer )
	-- body
	local stProto = g_msgHandlerInst:convertBufferToTable("MysteryLimitRetProtocol", sBuffer)
	if stProto then
		local nMallID = stProto.mallID
		local stItemInfo = stProto.itemInfo
		if stItemInfo and self.m_nMallID == nMallID then
			local nItemID = stItemInfo.itemID
			local nIndex = stItemInfo.arrayIndex
			local oItem = self:GetCachByIDAndIndex(nItemID, nIndex)
			if oItem then
				oItem:Reset(stItemInfo)
				-- release_print("找到商品:")
				Event.Dispatch(EventName.OnLimitReturn, oItem)
			else
				-- release_print("未找到商品:")
				error("未找到商品:"..nItemID.."|"..nIndex)
			end
		end
	end
end

--重新解析
--[[
message MysteryBlackMallRetProtocol
{
	optional uint32 mallID = 1;
	optional uint32 itemNum = 2;
	repeated MysteryItemInfo itemInfo = 3;
	optional int32 param1 = 4;
}
]]
function BlackMarketCtr:Reset( stInfo )
	-- body
	self:Clear()
	if not stInfo then
		return
	end
	self.m_stInfo = stInfo
	self.m_nMallID = stInfo.mallID
	self.m_nItemNum = stInfo.itemNum
	self.m_vItemInfo = stInfo.itemInfo
	self.m_stParam1 = stInfo.param1
	-- self.m_nShowSlot = stInfo.showSlot
	-- self.m_nLeftBuyCount = stInfo.leftBuyCount
	-- self.m_nNextNeedMoreIngot = stInfo.nextNeedMoreIngot
	-- self.m_nNextRefreshCost = stInfo.nextRefreshCost
	-- self.m_nNextRefreshTime = stInfo.nextRefreshTime

	if self.m_vItemInfo then
		for _,stItemInfo in ipairs(self.m_vItemInfo) do
			local oItem = self:CreateItem(stItemInfo)
			if oItem then
				self:AddCach(oItem)
			end
		end
	end
end

function BlackMarketCtr:GetShopType( ... )
	-- body
	return self.m_nShopType
end

function BlackMarketCtr:GetInfo( ... )
	-- body
	return self.m_stInfo
end

function BlackMarketCtr:GetMallID( ... )
	-- body
	return self.m_nMallID
end

function BlackMarketCtr:GetItemNum( ... )
	-- body
	return self.m_nItemNum
end

function BlackMarketCtr:GetItemInfo( ... )
	-- body
	return self.m_vItemInfo
end

function BlackMarketCtr:GetParam1( ... )
	-- body
	return self.m_stParam1
end

-- function BlackMarketCtr:GetShowSlot( ... )
-- 	-- body
-- 	return self.m_nShowSlot
-- end

-- function BlackMarketCtr:GetLeftBuyCount( ... )
-- 	-- body
-- 	return self.m_nLeftBuyCount
-- end

-- function BlackMarketCtr:GetNextNeedMoreIngot( ... )
-- 	-- body
-- 	return self.m_nNextNeedMoreIngot
-- end

-- function BlackMarketCtr:GetNextRefreshCost( ... )
-- 	-- body
-- 	return self.m_nNextRefreshCost
-- end

-- function BlackMarketCtr:GetNextRefreshTime( ... )
-- 	-- body
-- 	return self.m_nNextRefreshTime
-- end

function BlackMarketCtr:CreateItem( stInfo )
	-- body
	if not stInfo then
		return
	end
	self.m_iItemUid = self.m_iItemUid + 1
	return GetBlackMarketItem().new(self.m_iItemUid, stInfo)
end

--添加缓存
function BlackMarketCtr:AddCach( oItem )
	-- body
	if not oItem then
		return
	end
	local iUid = oItem:GetUid()
	if iUid then
		self.m_stAllItems[iUid] = oItem
	end
end

--删除缓存
function BlackMarketCtr:RemoveCach( iUid )
	-- body
	if not iUid then
		return
	end
	local oItem = self.m_stAllItems[iUid]
	if oItem then
		oItem:Dispose()
		self.m_stAllItems[iUid] = nil
	end
end

--根据itemid 和 arrayindex获取缓存
function BlackMarketCtr:GetCachByIDAndIndex( nItemID, nIndex )
	-- body
	for iUid,oItem in pairs(self.m_stAllItems) do
		-- release_print("GetCachByIDAndIndex", nItemID, nIndex, oItem:GetItemID(), oItem:GetArrayIndex())
		if oItem:GetItemID() == nItemID and oItem:GetArrayIndex() == nIndex then
			return oItem
		end
	end
end

--获取缓存
function BlackMarketCtr:GetCach( iUid )
	-- body
	if not iUid then
		return
	end
	return self.m_stAllItems[iUid]
end

--清空缓存
function BlackMarketCtr:Clear( ... )
	-- body
	for k,v in pairs(self.m_stAllItems) do
		v:Dispose()
		self.m_stAllItems[k] = nil
	end
end

--获取全部缓存(自己的缓存是map，返回出去的是vector)
function BlackMarketCtr:GetAllCach( bSort, funSortFun )
	-- body
	local vRet = {}
	if self.m_stAllItems then
		for iUid,oItem in pairs(self.m_stAllItems) do
			table.insert(vRet, oItem)
		end
	end
	--如果需要排序就排
	if bSort then
		if funSortFun then
			table.sort(vRet, funSortFun)
		else
			table.sort(vRet, handler(self, self.DefaultSort))
		end
	end
	return vRet
end

local iNull = 9999
--默认排序，按照uid从小到大
function BlackMarketCtr:DefaultSort( a, b )
	-- body
	local iUidA = a:GetUid() or iNull
	local iUidB = b:GetUid() or iNull
	return iUidA < iUidB
end

--购买物品
function BlackMarketCtr:Buy( oItem, nBuyNum )
	-- body
	local t = {}
	t.shopType = self.m_nShopType
	t.moneyType = oItem:GetMoneyType()
	t.arrayIndex = oItem:GetArrayIndex()
	t.itemID = oItem:GetItemID()
	t.buyNum = nBuyNum
	g_msgHandlerInst:sendNetDataByTableExEx(TRADE_CS_MYSTBUY, "MysteryShopBuyProtocol", t)
end

function BlackMarketCtr:Dispose( ... )
	-- body
	self:RemoveEvent()
end

return BlackMarketCtr