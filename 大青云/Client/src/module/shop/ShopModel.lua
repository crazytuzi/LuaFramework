--[[
商店 model
郝户
2014年11月3日18:01:38
]]

_G.ShopModel = Module:new();

--自动购买元宝商店
ShopModel.autoBuyMoneyList = {};
--自动购买绑元商店
ShopModel.autoBuyBindMoneyList = {};
ShopModel.shopList = {}

function ShopModel:Init()
	self.shopList[ShopConsts.T_Consumable]       = ShopUtils:GetItemList( ShopConsts.ST_Consumable );
	self.autoBuyMoneyList     = ShopUtils:GetListByType( ShopConsts.T_Money );
	self.autoBuyBindMoneyList = ShopUtils:GetListByType( ShopConsts.T_BindMoney );
	self.shopList[ShopConsts.T_Honor]            = ShopUtils:GetItemList( ShopConsts.ST_Honor );
	self.IngotMall            = ShopUtils:GetItemList( ShopConsts.ST_Money );
	self.CashGiftMall         = ShopUtils:GetItemList( ShopConsts.ST_BindMoney );
	self.VplanItemList        = ShopUtils:GetItemList( ShopConsts.ST_Vplan );
	self.shopList[ShopConsts.T_Gongxun]          = ShopUtils:GetItemList( ShopConsts.ST_Gongxun );
	self.tehuiMall            = ShopUtils:GetItemList( ShopConsts.ST_Tehui );
	self.exchangeShop         = ShopUtils:GetItemList( ShopConsts.ST_Exchange );
	self.xmasExchangeShop     = ShopUtils:GetItemList( ShopConsts.ST_XmasExchange );
	self.interSerSceneShop 	  = ShopUtils:GetItemList( ShopConsts.ST_InterSScene );
	self.shopList[ShopConsts.T_Guild]			  = ShopUtils:GetItemList( ShopConsts.ST_Guild)
	self.shopList[ShopConsts.T_Babel]            = ShopUtils:GetItemList( ShopConsts.ST_Babel );
end

----------------消耗品商店列表 从t_shop中筛选出来的消耗品商店商品列表---------------
ShopModel.consumableList = {};



---------------------------限购商品列表-------------------------------

--当日已购买的限购商品列表 商品id = 已购买数量{shopId = num}
ShopModel.hasBuyList = {};

--更新已购限购商品列表
function ShopModel:UpdateHasBuyList( list )
	for _, item in pairs(list) do
		if self.hasBuyList[item.id] ~= item.num then
			self.hasBuyList[item.id] = item.num;
		end
	end
	self:sendNotification( NotifyConsts.HasBuyListRefresh );
end

--根据商品Id获取这个商品今日已购买数量
function ShopModel:GetDayLimitItemHasBuyNum( id )
	return self.hasBuyList[ id ] or 0;
end




--------------------------回购商品列表-----------------------------

--出售时缓存（出售成功后会加入buyBackList)
ShopModel.sellCache = {};
function ShopModel:AddSellCache(bag, pos)
	local bag = BagModel:GetBag(bag);
	local item = bag and bag:GetItemByPos(pos);
	if not item then return end
	local cid = item:GetId();
	--强化等级
	local strenLvl = EquipModel:GetStrenLvl( cid );
	--追加等级
	local extraLvl = EquipModel:GetExtraLvl( cid );
	--卓越属性
	local superVO  = EquipModel:GetSuperVO( cid );
	--新卓越属性
	local newSuperList = nil;
	if EquipModel:GetNewSuperVO( cid ) then
		newSuperList = EquipModel:GetNewSuperVO( cid ).newSuperList;
	end
	-- 添加到缓存
	local vo = {};
	vo.item     = item;
	vo.strenLvl = strenLvl;
	vo.extraLvl = extraLvl;
	vo.superVO  = superVO;
	vo.newSuperList = newSuperList;
	self.sellCache[cid] = vo;
end

function ShopModel:RemoveSellCache( cid )
	local sellCache = self.sellCache[cid];
	self.sellCache[cid] = nil;
	return sellCache;
end

--回购商品列表
ShopModel.shopList[ShopConsts.T_Back] = {};

--增加回购物品
function ShopModel:AddBuyBackItem( cid )
	local sellCache = self:RemoveSellCache(cid);
	local item = sellCache.item;
	local vo = ShopBuyBackVO:new();
	vo.cid      = item:GetId();
	vo.tid      = item:GetTid();
	vo.count    = item:GetCount();
	vo.flags    = item.flags;
	vo.strenLvl = sellCache.strenLvl;
	vo.extraLvl = sellCache.extraLvl;
	vo.superVO  = sellCache.superVO;
	vo.newSuperList = sellCache.newSuperList;
	table.push( self.shopList[ShopConsts.T_Back], vo );
	-- 只保存一页回购物品，多余的删除
	while #self.shopList[ShopConsts.T_Back] > ShopConsts.NumIn1Page do
		table.remove( self.shopList[ShopConsts.T_Back], 1 );
	end
	self:sendNotification( NotifyConsts.BuyBackListRefresh );
end

--获取回购物品列表
function ShopModel:GetBuyBackItem(cid)
	for _, vo in pairs( self.shopList[ShopConsts.T_Back] ) do
		if vo.cid == cid then
			return vo;
		end
	end
	return nil;
end

--移除回购物品
function ShopModel:RemoveBuyBackItem(cid)
	for index, buyBackItem in pairs(self.shopList[ShopConsts.T_Back]) do
		if buyBackItem.cid == cid then
			table.remove(self.shopList[ShopConsts.T_Back], index);
			self:sendNotification( NotifyConsts.BuyBackListRefresh );
			return true;
		end
	end
	return false;
end

---------------------------------- 荣誉商店 --------------------------------------
-- ShopModel.honorlist = {};
-- -- Get HonorList 
-- function ShopModel:GetHonorList(id)
-- 	for i,vo in ipairs(self.honorlist) do 
-- 		if vo.cid == cid then 
-- 			return vo
-- 		end;
-- 	end;
-- end;


---------------------------------- 推荐商城 --------------------------------------
ShopModel.IngotMall = {};
function ShopModel:GetIngotMall()
	return self.IngotMall;
end


---------------------------------- 绑元商城 --------------------------------------
ShopModel.CashGiftMall = {};
function ShopModel:GetCashGiftMall()
	return self.CashGiftMall;
end

--------------------------------- V计划商城-----------------------------------------
ShopModel.VplanItemList = {};
function ShopModel:GetVplanItemlist()
	return self.VplanItemList;
end;

--------------------------------- 特惠商城 -----------------------------------------
ShopModel.tehuiMall = {};
function ShopModel:GetTehuiMall()
	return self.tehuiMall;
end;

--------------------------------- 兑换商店 -----------------------------------------
ShopModel.exchangeShop = {};
function ShopModel:GetExchangeShop()
	return self.exchangeShop;
end;

--------------------------------- 圣诞兑换商店 -----------------------------------------
ShopModel.xmasExchangeShop = {}
function ShopModel:GetXmasExchangeShop()
	return self.xmasExchangeShop;
end
--------------------------------- 跨服战场商店 -----------------------------------------
ShopModel.interSerSceneShop = {};
function ShopModel:GetInterSerSceneShop()
	return self.interSerSceneShop;
end;
