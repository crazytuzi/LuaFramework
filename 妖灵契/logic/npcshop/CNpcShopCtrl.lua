
local CNpcShopCtrl = class("CNpcShopCtrl", CCtrlBase)

function CNpcShopCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self:ResetCtrl()
end

function CNpcShopCtrl.ResetCtrl(self)
	self.m_ShopId = nil
	self.m_GoodsInfo = {}
	self.m_IDToGoodsInfo = {}
	self.m_ShopView = nil
	self.m_RefreshInfo = {}
	self.m_CanOpenShopIDList = nil
	self.m_RatioDic = {}
	self.m_PayInfo = {}
	self.m_GiftGount = {}
	self.m_TodayGift = {}
	self.m_QuickBuyGoodsID = nil
end

function CNpcShopCtrl.SetQuickBuyGood(self, goodsID)
	self.m_QuickBuyGoodsID = goodsID
end

function CNpcShopCtrl.GetCurrency(self, coinType)
	return data.npcstoredata.Currency[coinType]
end

--获取商店分页排序
function CNpcShopCtrl.GetPageSort(self)
	local oPageList = {}
	for _,v in ipairs(data.npcstoredata.PageSort) do
		local bInit = false
		for __, id in ipairs(data.npcstoredata.StorePage[v].subId) do
			if g_AttrCtrl.grade >= data.npcstoredata.StoreTag[id].open_grade then
				bInit = true
			end
		end
		if bInit then
			table.insert(oPageList, v)
		end
	end
	return oPageList
end

--获取商店标签数据
function CNpcShopCtrl.GetTagData(self, tagId)
	return data.npcstoredata.StoreTag[tagId]
end

--通过商店ID反查分页id
function CNpcShopCtrl.GetPageIdByShopId(self, shopId)
	return data.npcstoredata.StoreTag[shopId].storepage
end

--获取分页数据
function CNpcShopCtrl.GetPageData(self, pageId)
	return data.npcstoredata.StorePage[pageId]
end

--获取商品数据
function CNpcShopCtrl.GetGoodsData(self, goodsId)
	return data.npcstoredata.DATA[goodsId]
end

--获取商品ids
function CNpcShopCtrl.GetGoodsPosList(self, shopId)
	local posList = {}
	local oData
	for k,v in pairs(self.m_GoodsInfo) do
		oData = data.npcstoredata.DATA[v.item_id]
		if oData and oData.recharge <= g_WelfareCtrl.m_HistoryChargeDegree then
			table.insert(posList, v.pos)
		end
	end
	if data.npcstoredata.StoreTag[shopId].select_item == 0 then
		--无随机规则时按照导表sortID排序
		local function sortFunc(v1, v2)
			return data.npcstoredata.DATA[self.m_GoodsInfo[v1].item_id].sortId < data.npcstoredata.DATA[self.m_GoodsInfo[v2].item_id].sortId
		end
		table.sort(posList, sortFunc)
	else
		--有随机规则，按pos排序
		local function sortFunc(v1, v2)
			return v1 < v2
		end
		table.sort(posList, sortFunc)
	end
	return posList
end

function CNpcShopCtrl.HasRefreshRult(self, shopId)
	return self.m_RefreshInfo[shopId].refresh_rule ~= 0
end

function CNpcShopCtrl.GetRefreshInfo(self, shopId)
	return self.m_RefreshInfo[shopId]
end


--获取该页下所有标签id
function CNpcShopCtrl.GetTagIds(self, pageId)
	local oTagList = {}
	for _, id in ipairs(data.npcstoredata.StorePage[pageId].subId) do
		if g_AttrCtrl.grade >= data.npcstoredata.StoreTag[id].open_grade then
			table.insert(oTagList, id)
		end
	end
	return oTagList
end

--获取该页下所有页data
function CNpcShopCtrl.GetPages(self)
	return data.npcstoredata.StorePage
end

--获取服务器的商品数据
function CNpcShopCtrl.GetGoodsInfo(self, pos)
	return self.m_GoodsInfo[pos]
end

--限皮肤商店使用,若有刷新规则，或引起相同皮肤同时出现的情况，会有BUG
function CNpcShopCtrl.GetGoodsInfoBySkinID(self, skinID)
	return self.m_IDToGoodsInfo[skinID]
end

function CNpcShopCtrl.GetCurrencyValue(self, coinType)
	--金币
	if coinType == 2 then
		return g_AttrCtrl.coin
	--水晶
	elseif coinType == 1 then
		return g_AttrCtrl.goldcoin
	--比武场荣耀
	elseif coinType == 4 then
		return g_AttrCtrl.arenamedal
	--爬塔勋章
	elseif coinType == 3 then
		return g_AttrCtrl.medal
	--活跃度
	elseif coinType == 5 then
		return g_AttrCtrl.active
	--个人帮贡
	elseif coinType == 6 then
		return g_AttrCtrl.org_offer
	--帮派资金
	elseif coinType == 7 then
		return g_OrgCtrl:GetCash()
	--皮肤券
	elseif coinType == 9 then
		return g_AttrCtrl.skin
	elseif coinType == 12 then
		return g_AttrCtrl.color_coin
	elseif coinType == 13 then
		-- printc("<color=#ff0000>人民币是无限的，获取了也没用</color>")
		return 9999999999
	else
		--默认返回金币
		printc("<color=#ff0000>使用了未定义的货币类型</color>")
		return 0
	end
end
----------------------Shop Begin----------------------

function CNpcShopCtrl.GetCountDownText(self, time)
	local h = math.floor(time / 3600)
	local min = math.floor(time % 3600 / 60)
	local sec = time % 60
	if h == 0 then
		return string.format("%d:%02d", min, sec)
	else
		return string.format("%d:%02d:%02d", h, min, sec)
	end
end

function CNpcShopCtrl.OnReceiveOpenShop(self, shopId, goodslist, refresh_time, refresh_cost, refresh_coin_type, refresh_count, refresh_rule)
	g_NotifyCtrl:HideConnect()
	self.m_RefreshInfo[shopId] = {
		refresh_time = refresh_time or 0,
		refresh_cost = refresh_cost or 0,
		refresh_coin_type = refresh_coin_type or 0,
		refresh_count = refresh_count or 0,
		refresh_rule = refresh_rule or 0,
	}

	self.m_GoodsInfo = {}
	self.m_IDToGoodsInfo = {}
	for k,v in pairs(goodslist) do
		local goodsDate = self:GetGoodsData(v.item_id)
		if goodsDate then
			self.m_GoodsInfo[v.pos] = v
			self.m_IDToGoodsInfo[goodsDate.item_id] = self.m_GoodsInfo[v.pos]
		else
			printc(string.format("<color=#ff0000>未导表物品：ID:%s</color>", v.item_id))
		end
	end
	if shopId == nil then
		self.m_ShopId = data.npcstoredata.StorePage[data.npcstoredata.PageSort[1]].subId[1]
	else
		self.m_ShopId = shopId
	end

	if shopId == define.Store.Page.OrgFuLiShop then
		--打开公会商店
		if COrgShopView:GetView() == nil then
			COrgShopView:ShowView(function (oView)
				oView:SetShopData(self.m_ShopId)
			end)
		else
			self:OnEvent(define.Store.Event.SetShopData, self.m_ShopId)
		end
	else
		--打开通用商店
		if CNpcShopView:GetView() == nil then
			CNpcShopView:ShowView(function (oView)
				oView:SetShopData(self.m_ShopId, self.m_QuickBuyGoodsID)
				self.m_QuickBuyGoodsID = nil
			end)
		else
			self:OnEvent(define.Store.Event.SetShopData, self.m_ShopId)
		end
	end
end

function CNpcShopCtrl.IsStoreCanOpen(self, shopId)
	if self.m_CanOpenShopIDList == nil then
		self.m_CanOpenShopIDList = {}
		self.m_CanOpenShopIDList[define.Store.Page.OrgFuLiShop] = true
		for _,v in ipairs(data.npcstoredata.StorePage) do
			for __,id in ipairs(v.subId) do
				self.m_CanOpenShopIDList[id] = true
			end
		end
	end
	return self.m_CanOpenShopIDList[shopId]
end

function CNpcShopCtrl.GetRestRefreshTime(self, shopId)
	-- if self.m_RefreshInfo[shopId].refresh_time == 0 then
	-- 	return 0
	-- else
	-- 	local restTime = self.m_RefreshInfo[shopId].refresh_time - g_TimeCtrl:GetTimeS()
	-- 	if restTime >= 0 then
	-- 		return restTime
	-- 	else
	-- 		return 0
	-- 	end
	-- end
	return self.m_RefreshInfo[shopId].refresh_time
end

function CNpcShopCtrl.RefreshItem(self, shopId, goodsInfo)
	-- if self.m_ShopId ~= shopId then
	-- 	return
	-- end
	if shopId == 211 then
		--游历商店不走以下流程
		return
	end
	self.m_GoodsInfo[goodsInfo.pos] = goodsInfo
	local v = self.m_GoodsInfo[goodsInfo.pos]
	self.m_IDToGoodsInfo[self:GetGoodsData(goodsInfo.item_id).item_id] = self.m_GoodsInfo[goodsInfo.pos]
	self:OnEvent(define.Store.Event.RefreshItem, {goodsInfo = goodsInfo, shopId = shopId})
end

function CNpcShopCtrl.GetGoodsPrice(self, iPos)
	local oGoodsInfo = self.m_GoodsInfo[iPos]
	if oGoodsInfo.rebate ~= 0 and oGoodsInfo.rebate ~= nil then
		return math.ceil(self:GetGoodsData(oGoodsInfo.item_id).coin_count * oGoodsInfo.rebate /100)
	else
		return self:GetGoodsData(oGoodsInfo.item_id).coin_count
	end
end

function CNpcShopCtrl.IsDaZhe(self, iPos)
	local oGoodsInfo = self.m_GoodsInfo[iPos]
	return oGoodsInfo.rebate ~= 0 and oGoodsInfo.rebate ~= nil
end

function CNpcShopCtrl.OpenShop(self, shopId)
	local openId = shopId or data.npcstoredata.StorePage[data.npcstoredata.PageSort[1]].subId[1]
	if not self:IsStoreCanOpen(openId) then
		g_NotifyCtrl:FloatMsg("该商店暂未开放")
		return false
	end
	if g_AttrCtrl.grade < data.npcstoredata.StoreTag[openId].open_grade then
		g_NotifyCtrl:FloatMsg(data.npcstoredata.StoreTag[openId].open_grade .. "级开启该功能")
		return false
	end
	if shopId == define.Store.Page.OrgMemberShop and g_AttrCtrl.org_id == 0 then
		g_NotifyCtrl:FloatMsg("需加入公会才可打开该商店")
		return false
	end
	g_NotifyCtrl:ShowConnect("请稍候", 0.5)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSOpenShop"]) then
		netstore.C2GSOpenShop(openId)
	end
	
	return true
end

function CNpcShopCtrl.GetGoodType(self, goodsID)
	local goodsData = self:GetGoodsData(goodsID)
	if goodsData.item_arg ~= nil then
		local len = string.len(goodsData.item_arg)
		if len > 7 and string.sub(goodsData.item_arg, 1, 7) == "partner" then
			return define.Store.GoodsType.Partner
		else
			printc(string.format("<color=#ff0000>未定义的类型：ID:%s, arg:%s</color>", goodsID, goodsData.item_arg))
			return define.Store.GoodsType.Item
		end
	else
		local oItem = CItem.NewBySid(goodsData.item_id)
		if oItem:IsPartnerEquip() then 
			return define.Store.GoodsType.PartnerEquip
		elseif oItem:IsPartnerSkin() then
			return define.Store.GoodsType.PartnerSkin
		elseif oItem:IsPartnerChip() then
			return define.Store.GoodsType.PartnerChip
		else
			return define.Store.GoodsType.Item
		end
	end
end

--获取商品信息
function CNpcShopCtrl.GetCommonGoodsData(self, goodsID)
	local sType = self:GetGoodType(goodsID)
	local baseData = self:GetGoodsData(goodsID)
	local goodsData = {
		gType = sType,
		id = goodsID,
		item_id = baseData.item_id,
		coin_count = baseData.coin_count,
		cycle_type = baseData.cycle_type,
		mark = baseData.mark,
		vip = baseData.vip,
		payid = baseData.payid,
	}
	if Utils.IsIOS() then
		goodsData.payid = baseData.iospayid
	end
	local exData = nil
	local baseDescription = ""
	local exDescription = ""
	--伙伴
	if sType == define.Store.GoodsType.Partner then
		exData = data.partnerdata.DATA[tonumber(string.sub(baseData.item_arg, 9, -1))]
		baseDescription = exData.description
		goodsData.rare = exData.rare
	else
		--物品
		exData = DataTools.GetItemData(baseData.item_id)
		goodsData.quality = exData.quality
		local oItem = CItem.NewBySid(baseData.item_id)
		if sType == define.Store.GoodsType.PartnerEquip then
			local equipType = data.partnerequipdata.ParSoulType[oItem:GetValue("equip_type")]
			baseDescription = equipType["description"]
			-- exDescription = string.format("2件套效果:%s\n4件套效果:%s", equipType["two_set_desc"], equipType["four_set_desc"])
		elseif sType == define.Store.GoodsType.PartnerSkin then
			baseDescription = exData.description
			goodsData.partnerName = data.partnerdata.DATA[exData.partner_type].name
		else
			baseDescription = exData.description
		end
	end
	goodsData.exData = exData
	goodsData.name = baseData.name or exData.name
	goodsData.icon = baseData.icon or exData.icon
	goodsData.currency = self:GetCurrency(baseData.coin_typ)
	if baseData.description ~= nil then
		baseDescription = baseData.description
	end
	goodsData.description = string.format("%s\n%s", baseDescription, exDescription)
	return goodsData
end

--判断是否满足等级限制
function CNpcShopCtrl.IsGradeOK(self, goodsID)
	local goodsData = self:GetGoodsData(goodsID)
	if goodsData == nil 
		or (
			goodsData.grade_limit ~= nil 
			and (
					(goodsData.grade_limit.max ~= nil and goodsData.grade_limit.max < g_AttrCtrl.grade)
					or(goodsData.grade_limit.min ~= nil and goodsData.grade_limit.min > g_AttrCtrl.grade)
				)
			) then
		return false
	end
	return true
end

function CNpcShopCtrl.GetMarkName(self, idx)
	local markDic = {"text_hui", "text_jian", "text_re", "text_xian", "text_zeng", "text_zhe", "text_meiri", "text_meizhou"}
	return markDic[idx] or ""
end

----------------------Shop End------------------------

function CNpcShopCtrl.ShowGold2CoinView(self)
	netstore.C2GSOpenGold2Coin(define.Store.ExchangeType.GoldCoin2Coin)
	-- netstore.C2GSOpenGold2Coin(define.Store.ExchangeType.ColorCoin2Coin)
end

-- function CNpcShopCtrl.ShowColor2GoldView(self)
-- 	netstore.C2GSOpenGold2Coin(define.Store.ExchangeType.ColorCoin2GoldCoin)
-- end

function CNpcShopCtrl.ShowGold2EnergyView(self)
	netstore.C2GSOpenGold2Coin(define.Store.ExchangeType.GoldCoin2Energy)
end

function CNpcShopCtrl.OnReceiveExchange(self, iType, iRatio, iToday, iGiftCount)
	self.m_RatioDic[iType] = iRatio / 100
	self.m_GiftGount[iType] = iGiftCount or 0
	self.m_TodayGift[iType] = iToday or 0
	if iType == define.Store.ExchangeType.GoldCoin2Energy then
		CExchangeEnergyView:ShowView()
	-- elseif iType == define.Store.ExchangeType.ColorCoin2GoldCoin then
	-- 	CExchangeGoldCoinView:ShowView()
	else
		local oView = CExchangeCoinView:GetView()
		if oView then
			oView:RefreshGiftCount()
		else
			CExchangeCoinView:ShowView()
		end
	end
end

function CNpcShopCtrl.GetGiftCount(self, iType)
	return self.m_GiftGount[iType] or 0
end

function CNpcShopCtrl.GetRatio(self, iType)
	return self.m_RatioDic[iType]
end

function CNpcShopCtrl.GetTodayGiftCount(self, iType)
	return self.m_TodayGift[iType]
end

--------------------充值begin--------------------------------------
function CNpcShopCtrl.UpdatePayList(self, infoList)
	self.m_PayInfo = {}
	for k,v in pairs(infoList) do
		self.m_PayInfo[v.key] = v
	end
	self:OnEvent(define.Store.Event.RefreshPayInfo)
end

function CNpcShopCtrl.UpdatePayInfo(self, info)
	self.m_PayInfo[info.key] = info
	self:OnEvent(define.Store.Event.RefreshPayInfo, info)
end

function CNpcShopCtrl.GetPayInfo(self, sKey)
	return self.m_PayInfo[sKey]
end
-------------------------充值end---------------------------------



return CNpcShopCtrl