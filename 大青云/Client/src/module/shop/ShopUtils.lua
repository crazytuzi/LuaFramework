--[[
商店相关util
郝户
2014年11月3日20:28:48
]]

_G.ShopUtils = {};

-- 获取商店商品清单 
-- @param showType 商店类型
function ShopUtils:GetItemList(showType)
	local list = {};
	for id, cfg in pairs(t_shop) do
		if cfg.isShow then
			local t = split(cfg.showType,",");
			
			for i,st in ipairs(t) do
				if tonumber(st) == showType then
					local vo = ShopUtils:CreateShopVO(id)
					table.push(list,vo);
					break;
				end
			end
		end
	end
	table.sort( list, function(A, B) return A:GetShowIndex() < B:GetShowIndex(); end );
	return list;
end

--根据类型获取商品列表
function ShopUtils:GetListByType(type)
	local list = {};
	for id,cfg in pairs(t_shop) do
		if cfg.type == type then
			local vo = ShopUtils:CreateShopVO(id)
			table.push(list,vo);
		end
	end
	return list;
end

-- 根据物品id获取物品名称
function ShopUtils:GetItemNameById(itemId)
	local cfg = t_item[itemId] or t_equip[itemId];
	return cfg and cfg.name;
end

-- 根据货币类型获取货币名称
function ShopUtils:GetMoneyNameByType(moneyType)
	local name;
	if moneyType == enAttrType.eaBindGold then
		name = StrConfig['shop001'];
	elseif moneyType == enAttrType.eaUnBindGold then
		name = StrConfig['shop002'];
	elseif moneyType == enAttrType.eaUnBindMoney then
		name = StrConfig['shop003'];
	elseif moneyType == enAttrType.eaBindMoney then
		name = StrConfig['shop004'];
	end
	return name;
end

-- 根据itemId获取物品的品质颜色
function ShopUtils:GetItemQualityColor(itemId)
	local cfg = t_item[itemId] or t_equip[itemId];
	local quality = cfg and cfg.quality;
	return quality and TipsConsts:GetItemQualityColorVal(quality);
end

-- 获取某商品的最大购买数量，用于确认面板显示
-- @param id:商品id
-- @param ignore: 忽略的购买限制因素table.例：当table = {1, 2}时，只计算因素3，当table = {1}时，只计算因素2、3；
-- @return numMaxBuy 最大购买数目
-- @return reasonBottleneck 造成最大购买数的瓶颈原因
function ShopUtils:GetMaxBuyNum(id, ignore)
	if not ignore then ignore = {}; end
	local compareList = {};
	-- 限制因素 1：购买数量/最大堆叠 > 背包空余格子 时候，自动将数量变为 空余格子 * 最大堆叠数目，并提示玩家原因
	local maxNum1;
	-- 限制因素 2：如果物品限购，超过每日限购，自动将数量变成最大限购数量
	local maxNum2;
	-- 限制因素 3：如果总价格大于玩家当前所拥有的货币上限时，自动将数量变成玩家总货币/单价，floor取整
	local maxNum3;
	-- 检查是否忽略某一项因素
	local checkIgnore = function(factor)
		for i, v in pairs(ignore) do
			if v == factor then
				return true;
			end
		end
		return false;
	end

	local shopCfg = t_shop[id];
	if not shopCfg then
		Error( string.format( "cannot find shop cfg.shop id::%s", id ) )
		-- return
	end
	local moneyType = shopCfg.moneyType; --货币类型
	local price     = shopCfg.price; --价格
	local itemId    = shopCfg.itemId;
	local itemCfg   = t_item[itemId] or t_equip[itemId];
	if not itemCfg then
		Error( string.format( "cannot find shop item itemCfg.shop id::%s", id ) )
		-- return
	end

	local maxPile   = itemCfg.repeats or 1; --最大堆叠
	local bagVO = BagModel:GetBag( BagConsts.BagType_Bag );
	local bagSizeRest = bagVO:GetSize() - bagVO:GetUseSize(); --背包剩余格子数量
	local itemBagSize = bagVO:GetItemUsedSize( itemId );
	local numItem = BagModel:GetItemNumInBag( itemId );
	local numCanPile = itemBagSize * maxPile - numItem;
	local maxItemNum = maxPile * bagSizeRest + numCanPile;
	maxNum1 = math.floor( maxItemNum / shopCfg.itemNum )
	if not checkIgnore(1) then
		table.insert( compareList, maxNum1 );
	end
	if shopCfg.dayLimit ~= 0 then --dayLimit为0表示不限购
		maxNum2 = shopCfg.dayLimit - ShopModel:GetDayLimitItemHasBuyNum( id );
		if not checkIgnore(2) then
			table.insert( compareList, maxNum2 );
		end
	end
	local shopVO = ShopUtils:CreateShopVO(id)
	local moneyNum = shopVO:GetPlayerMoney()
	maxNum3 = math.floor( moneyNum / price );
	if not checkIgnore(3) then
		table.insert( compareList, maxNum3 );
	end
	local numMaxBuy = math.min( unpack(compareList) );
	local reasonBottleneck; --造成最大购买量的瓶颈原因
	if numMaxBuy == maxNum1 then
		reasonBottleneck = ShopConsts.ReasonBag;
	elseif numMaxBuy == maxNum2 then
		reasonBottleneck = ShopConsts.ReasonDayLimit;
	elseif numMaxBuy == maxNum3 then
		reasonBottleneck = ShopConsts.ReasonAfford;
	end
	return numMaxBuy, reasonBottleneck, moneyType;
end

--检查可否购买指定数量的商品
--@return 1: 可否购买 2：最大购买量 3：购买力瓶颈原因
function ShopUtils:CheckCanBuy(shopId, num)
	local maxBuyNum, bottleneck, moneyType = ShopUtils:GetMaxBuyNum(shopId);
	if maxBuyNum == nil then
		Error( string.format( "ShopUtils:CheckCanBuy::maxBuyNum is nil,shopId:%s", shopId ) )
	end
	if num == nil then
		Error( "ShopUtils:CheckCanBuy::num is nil" )
	end
	return num <= maxBuyNum, maxBuyNum, bottleneck, moneyType;
end

-- 获取金钱约数文本描述，用于确认面板显示
function ShopUtils:GetCostRough(cost)
	local numShow = _G.getNumShow(cost);
	local costRough = "";
	if tonumber(numShow) ~= cost then
		costRough = string.format( StrConfig['shop206'], numShow );
	else
		costRough = string.format( StrConfig['shop207'], numShow );
	end
	return costRough;
end

--获取物品品质
function ShopUtils:GetQualityUrl(itemId, isSmall)
	local cfg = t_equip[itemId] or t_item[itemId];
	local qURL = cfg and ResUtil:GetSlotQuality( cfg.quality, isSmall and nil or 54 ) or "";
	return qURL;
end

--获取可购买某商品所剩金钱
function ShopUtils:GetMoneyByType(moneyType)
	local playerInfo = MainPlayerModel.humanDetailInfo
	if moneyType == enAttrType.eaBindGold then
		return playerInfo.eaBindGold + playerInfo.eaUnBindGold;
	elseif moneyType == enAttrType.eaUnBindGold then
		return playerInfo.eaUnBindGold;
	elseif moneyType == enAttrType.eaUnBindMoney then
		return playerInfo.eaUnBindMoney;
	elseif moneyType == enAttrType.eaBindMoney then
		return playerInfo.eaBindMoney;
	elseif moneyType == enAttrType.eaHonor then 
		return playerInfo.eaHonor;
	elseif moneyType == enAttrType.eaLingZhi then
		return playerInfo.eaLingZhi;
	elseif moneyType == enAttrType.eaExtremityVal then
		return playerInfo.eaExtremityVal;
	elseif moneyType == enAttrType.eaCrossExploit then
		return playerInfo.eaCrossExploit;
	elseif moneyType == enAttrType.eaZhenQi then
		return playerInfo.eaZhenQi;
	elseif moneyType == enAttrType.eaInterSSVal then
		return playerInfo.eaInterSSVal;
	elseif moneyType == 80 then
		return UnionModel.MyUnionInfo.contribution
	elseif moneyType ==enAttrType.eaTrialScore then
		return playerInfo.eaTrialScore;
	end

end

--根据商品id配表信息
function ShopUtils:GetShopCfg( shopId )
	return t_shop[shopId];
end

--根据商品id获取物品配表信息
function ShopUtils:GetItemCfg( shopId )
	local itemId = t_shop[shopId] and t_shop[shopId].itemId;
	return itemId and t_item[itemId] or t_equip[itemId];
end

-- 显示类型list
function ShopUtils:OnGetShowTypeList(type)
	if type == ShopConsts.ST_BindMoney then  -- 绑元商店
		return ShopModel:GetCashGiftMall()
	elseif type == ShopConsts.ST_Money then 
		return ShopModel:GetIngotMall()
	elseif type == ShopConsts.ST_Tehui then 
		return ShopModel:GetTehuiMall()
	end;
end;

function ShopUtils:CreateShopVO( shopId )
	local cfg = t_shop[shopId]
	if not cfg then return end
	local class
	if cfg.type == ShopConsts.T_Exchange then
		class = ShopExchangeVO
	elseif cfg.type == ShopConsts.T_XmasExchange then
		class = ShopXmasExchangeVO
	else
		class = ShopVO
	end
	local vo = class:new()
	vo.id = shopId
	return vo
end