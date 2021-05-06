local COrgShopView = class("COrgShopView", CViewBase)

function COrgShopView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Org/OrgShopView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"

	self.m_CurrentItem = nil
	self.m_CurrentPageBtn = nil
	self.m_CurrentTagBtn = nil
	self.m_ItemCellPool = {}

	self.m_TagBtnPool = {}
	self.m_ShopIdToTagBtn = {}
	self.m_GoodsPosToItemCell = {}
	self.m_CountDown = 0
	self.m_TextColor = Color.New(0.5, 0.38, 0.53, 1)
end

function COrgShopView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_TagGrid = self:NewUI(2, CTabGrid)
	self.m_TagBtn = self:NewUI(3, CBox)
	self.m_ItemGrid = self:NewUI(4, CGrid)
	self.m_ItemCell = self:NewUI(5, CBox)
	self.m_InfoPart = self:NewUI(6, COrgShopInfoPart)
	self.m_ItemScrollView = self:NewUI(7, CScrollView)
	self.m_RefreshBtn = self:NewUI(8, CBox)
	self.m_CountDownLabel = self:NewUI(9, CLabel)
	self.m_OwnLabel = self:NewUI(10, CLabel)
	self.m_OwnCurrencySprite = self:NewUI(11, CSprite)
	self.m_OpenShopBtn = self:NewUI(12, CButton)
	self.m_HuliTexture = self:NewUI(13, CSpineTexture)
	self.m_XiaoRenTexture = self:NewUI(14, CSpineTexture)

	self:InitContent()
end

function COrgShopView.InitContent(self)
	self.m_HuliTexture:ShapeOrg("HuLi", function ()
		self.m_HuliTexture:SetAnimation(0, "idle_1", true)
	end)
	self.m_XiaoRenTexture:SetActive(false)
	self.m_XiaoRenTexture:ShapeOrg("XiaoRen",objcall(self, function(obj)
		obj.m_XiaoRenTexture:SetActive(true)
		obj.m_XiaoRenTexture:SetAnimation(0, "idle_1", false)
	end))
	self:InitBtn()
	self.m_RefreshBox = self:CreateRefreshBtn()
	self.m_ItemCell:SetActive(false)
	self.m_TagBtn:SetActive(false)

	g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotifyRefresh"))
	g_NpcShopCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_OpenShopBtn:AddUIEvent("click", callback(self, "OnClickOpenShop"))
end

function COrgShopView.OnClickOpenShop(self)
	g_NpcShopCtrl:OpenShop(define.Store.Page.OrgMemberShop)
end

function COrgShopView.InitBtn(self)
	self.m_TagBtnIDArr = {define.Store.Page.OrgFuLiShop}
	for i = 1, #self.m_TagBtnIDArr do
		if self.m_TagBtnPool[i] == nil then
			self.m_TagBtnPool[i] = self:CreateTagBtn(g_NpcShopCtrl:GetTagData(self.m_TagBtnIDArr[i]))
		else
			self.m_TagBtnPool[i].m_TagData = g_NpcShopCtrl:GetTagData(self.m_TagBtnIDArr[i])
		end
		self.m_ShopIdToTagBtn[self.m_TagBtnIDArr[i]] = self.m_TagBtnPool[i]
		self.m_TagBtnPool[i].m_Label:SetText(self.m_TagBtnPool[i].m_TagData.name)
		self.m_TagBtnPool[i].m_SelectLabel:SetText(self.m_TagBtnPool[i].m_TagData.name)
		self.m_TagBtnPool[i]:SetActive(true)
	end
end

function COrgShopView.CreateRefreshBtn(self)
	local oBtn = self.m_RefreshBtn
	oBtn.m_Table = oBtn:NewUI(1, CTable)
	oBtn.m_CurrencySprite = oBtn:NewUI(2, CSprite)
	oBtn.m_Label = oBtn:NewUI(3, CLabel)
	oBtn:AddUIEvent("click", callback(self, "RefreshShop"))

	function oBtn.SetData(self, refreshInfo)
		oBtn:SetActive(refreshInfo.refresh_time ~= 0)
		if refreshInfo.refresh_cost == 0 then
			oBtn.m_CurrencySprite:SetActive(false)
			oBtn.m_Label:SetText("刷新")
		else
			oBtn.m_CurrencySprite:SetSpriteName(g_NpcShopCtrl:GetCurrency(refreshInfo.refresh_coin_type).icon)
			oBtn.m_CurrencySprite:SetActive(true)
			oBtn.m_Label:SetText(refreshInfo.refresh_cost)
		end
		oBtn.m_Table:Reposition()
	end
	return oBtn
end

function COrgShopView.SetShopData(self, shopid)
	self:SelectShopTag(shopid)
end

--更新商店货物
function COrgShopView.RefreshShop(self)
	local shopId = self.m_CurrentTagBtn.m_TagData.id
	local refreshInfo = g_NpcShopCtrl:GetRefreshInfo(shopId)
	if refreshInfo.refresh_count <= 0 then
		g_NotifyCtrl:FloatMsg("本日手动刷新次数已消耗完")
	elseif refreshInfo.refresh_cost > g_NpcShopCtrl:GetCurrencyValue(refreshInfo.refresh_coin_type) then
		g_NotifyCtrl:FloatMsg("货币不足，无法刷新")
	else
		if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSRefreshShop"]) then
			netstore.C2GSRefreshShop(shopId)
		end
	end
end

function COrgShopView.SetRefreshInfo(self, shopId)
	self.m_RefreshBox:SetData(g_NpcShopCtrl:GetRefreshInfo(shopId))
	self:BeginCountDown(g_NpcShopCtrl:GetRestRefreshTime(shopId))
end

function COrgShopView.BeginCountDown(self, count)
	if count ~= 0 then
		if self.m_TimerID ~= nil then
			Utils.DelTimer(self.m_TimerID)
		end
		self.m_TimerID = Utils.AddTimer(callback(self, "CountDown"), 1, 2)
	end
	self.m_CountDown = count
	self.m_CountDownLabel:SetText((count == 0 and "" or g_NpcShopCtrl:GetCountDownText(count)))
end

function COrgShopView.CountDown(self)
	self.m_CountDown = self.m_CountDown - 1
	if self.m_CountDown < 0 then
		Utils.DelTimer(self.m_TimerID)
		self.m_TimerID = nil
		self.m_CountDownLabel:SetText("")
		--如果是要自动刷新的话，要主动请求数据
		if g_NpcShopCtrl:HasRefreshRult(self.m_CurrentTagBtn.m_TagData.id) then
			g_NpcShopCtrl:OpenShop(self.m_CurrentTagBtn.m_TagData.id)
		end
		return false
	end
	self.m_CountDownLabel:SetText(g_NpcShopCtrl:GetCountDownText(self.m_CountDown))
	
	return true
end

--创建标签按钮
function COrgShopView.CreateTagBtn(self, tagData)
	local tagBtn = self.m_TagBtn:Clone("tagBtn")
	tagBtn:SetActive(true)
	tagBtn.m_Btn = tagBtn:NewUI(1, CButton)
	tagBtn.m_Label = tagBtn:NewUI(2, CLabel)
	tagBtn.m_SelectSprite = tagBtn:NewUI(3, CSprite)
	tagBtn.m_SelectLabel = tagBtn:NewUI(4, CLabel)
	tagBtn.m_TagData = tagData
	tagBtn.m_SelectSprite:SetActive(false)

	self.m_TagGrid:AddChild(tagBtn)
	tagBtn.m_Btn:AddUIEvent("click",callback(self,"OnClickTag", tagBtn))
	return tagBtn
end

function COrgShopView.OnClickTag(self, tagBtn)
	-- self:SelectShopTag(tagBtn.m_TagData.id)
	g_NpcShopCtrl:OpenShop(tagBtn.m_TagData.id)
end

--选择商店标签
function COrgShopView.SelectShopTag(self, shopId)
	if self.m_CurrentItem ~= nil then
		-- self.m_CurrentItem.m_OnSelectSprite:SetActive(false)
	end
	self.m_CurrentItem = nil
	if shopId ~= nil then
		if self.m_CurrentTagBtn ~=nil then
			self.m_CurrentTagBtn.m_Btn:SetActive(true)
			self.m_CurrentTagBtn.m_SelectSprite:SetActive(false)
		end
		self.m_CurrentTagBtn = self.m_ShopIdToTagBtn[shopId]
		self.m_CurrentTagBtn.m_Btn:SetActive(false)
		self.m_CurrentTagBtn.m_SelectSprite:SetActive(true)
	end
	self:SetRefreshInfo(shopId)
	self:SetOnSellData(shopId)
end

--设置当前标签出售商品
function COrgShopView.SetOnSellData(self, shopId)
	local count = 0
	local goodsPosList = g_NpcShopCtrl:GetGoodsPosList(shopId)

	if shopId ~= nil and goodsPosList ~= nil then
		for k,v in ipairs(goodsPosList) do
			count = count +1
			if self.m_ItemCellPool[count] == nil then
				self.m_ItemCellPool[count] = self:CreateItemCell()
			end
			self.m_GoodsPosToItemCell[v] = self.m_ItemCellPool[count]
			-- self.m_ItemCellPool[count]:SetData(g_NpcShopCtrl:GetGoodsData(g_NpcShopCtrl:GetGoodsInfo(v).item_id))
			self.m_ItemCellPool[count]:SetData(g_NpcShopCtrl:GetCommonGoodsData(g_NpcShopCtrl:GetGoodsInfo(v).item_id))
			self.m_ItemCellPool[count]:Refresh(g_NpcShopCtrl:GetGoodsInfo(v))
		end
	end

	count = count + 1
	for i = count, #self.m_ItemCellPool do
		self.m_ItemCellPool[i]:SetActive(false)
	end
	self.m_OwnLabel:SetNumberString(g_NpcShopCtrl:GetCurrencyValue(g_NpcShopCtrl:GetTagData(shopId).coin_typ))
	self.m_OwnCurrencySprite:SetSpriteName(g_NpcShopCtrl:GetCurrency(g_NpcShopCtrl:GetTagData(shopId).coin_typ).icon)

	self.m_ItemScrollView:ResetPosition()
	self.m_ItemGrid:Reposition()
end

function COrgShopView.CreateItemCell(self)
	local oItemCell = self.m_ItemCell:Clone("oItemCell")
	oItemCell:SetActive(true)
	oItemCell.m_NameLabel = oItemCell:NewUI(1, CLabel)
	oItemCell.m_Icon = oItemCell:NewUI(2, CButton)
	oItemCell.m_CostLabel = oItemCell:NewUI(3, CLabel)
	oItemCell.m_CurrencySprite = oItemCell:NewUI(4, CSprite)
	oItemCell.m_DiscountGroup = oItemCell:NewUI(5, CSprite)
	oItemCell.m_DiscountLabel = oItemCell:NewUI(6, CLabel)
	-- oItemCell.m_OnSelectSprite = oItemCell:NewUI(7, CSprite)
	oItemCell.m_QualitySprite = oItemCell:NewUI(8, CSprite)
	oItemCell.m_AmountLabel = oItemCell:NewUI(9, CLabel)
	oItemCell.m_PartnerQualitySprite = oItemCell:NewUI(10, CSprite)
	oItemCell.m_CostTable = oItemCell:NewUI(11, CTable)
	oItemCell.m_LimitSprite = oItemCell:NewUI(12, CSprite)

	oItemCell.m_Currency = nil
	oItemCell.m_ParentView = self

	oItemCell:AddUIEvent("click",callback(self,"OnItemCellClick", oItemCell))
	self.m_ItemGrid:AddChild(oItemCell)

	function oItemCell.SetData(self, goodsData)
		oItemCell.m_GoodsData = goodsData
		if not g_NpcShopCtrl:IsGradeOK(goodsData.id) then
			oItemCell:SetActive(false)
			return
		end
		oItemCell:SetActive(true)
		oItemCell.m_CurrencySprite:SetSpriteName(goodsData.currency.icon)
		oItemCell.m_NameLabel:SetText(goodsData.name)
		if goodsData.gType == define.Store.GoodsType.Partner then
			-- oItemCell.m_Icon:SetSize(55, 55)
			oItemCell.m_Icon:SpriteAvatar(goodsData.icon)
			oItemCell.m_PartnerQualitySprite:SetActive(true)
			oItemCell.m_QualitySprite:SetSpriteName("bg_ditu_daoju")
			g_PartnerCtrl:ChangeRareBorder(oItemCell.m_PartnerQualitySprite, goodsData.rare)
		else
			oItemCell.m_NameLabel:SetText(goodsData.name)
			-- oItemCell.m_Icon:SetSize(56, 56)
			oItemCell.m_PartnerQualitySprite:SetActive(false)
			oItemCell.m_Icon:SpriteItemShape(goodsData.icon)
			oItemCell.m_QualitySprite:SetItemQuality(goodsData.quality)
		end
	end

	function oItemCell.Refresh(self, oInfo)
		oItemCell.m_GoodsInfo = oInfo
		if oItemCell.m_GoodsInfo.rebate ~= 0 and oItemCell.m_GoodsInfo.rebate ~= nil then
			oItemCell.m_DiscountGroup:SetActive(true)
			oItemCell.m_DiscountLabel:SetText((oItemCell.m_GoodsInfo.rebate/10) .. "折")
			oItemCell.m_Price = math.ceil(oItemCell.m_GoodsData.coin_count * oItemCell.m_GoodsInfo.rebate /100)
		else
			oItemCell.m_Price = oItemCell.m_GoodsData.coin_count
			oItemCell.m_DiscountGroup:SetActive(false)
		end
		oItemCell.m_CostLabel:SetText(oItemCell.m_Price)

		if oItemCell.m_GoodsInfo.limit == 0 then
			oItemCell.m_Amount = nil
			oItemCell.m_AmountLabel:SetText("")
			oItemCell.m_LimitSprite:SetActive(false)
		else
			oItemCell.m_LimitSprite:SetActive(true)
			oItemCell.m_Amount = oItemCell.m_GoodsInfo.amount
			oItemCell.m_AmountLabel:SetText(oItemCell.m_Amount)
			if oItemCell.m_GoodsData.cycle_type == "day" then
				oItemCell.m_AmountLabel:SetText(string.format("今天还可以购买%s个", oItemCell.m_Amount))
			elseif oItemCell.m_GoodsData.cycle_type == "week" then
				oItemCell.m_AmountLabel:SetText(string.format("本周还可以购买%s个", oItemCell.m_Amount))
			elseif oItemCell.m_GoodsData.cycle_type == "month" then
				oItemCell.m_AmountLabel:SetText(string.format("本月还可以购买%s个", oItemCell.m_Amount))
			else
				oItemCell.m_AmountLabel:SetText(string.format("还可以购买%s个",oItemCell.m_Amount))
			end
		end
	end

	return oItemCell
end

function COrgShopView.OnItemCellClick(self, oItemCell)
	self.m_CurrentItem = oItemCell
	self.m_InfoPart:SetInfo(oItemCell, self.m_CurrentTagBtn.m_TagData.id)
end

function COrgShopView.OnNotifyRefresh(self, oCtrl)
	if oCtrl.m_EventID == define.Org.Event.UpdateOrgInfo then
		self:RefreshUI()
	end
end

function COrgShopView.OnNotify(self, oCtrl)
	if oCtrl.m_EventID == define.Store.Event.CloseGold2Coin then
		self:CloseView()
	elseif oCtrl.m_EventID == define.Store.Event.RefreshItem then
		if oCtrl.m_EventData.shopId == define.Store.Page.OrgFuLiShop then
			self:RefreshItem(oCtrl.m_EventData.goodsInfo)
		end
	elseif oCtrl.m_EventID == define.Store.Event.SetShopData then
		if oCtrl.m_EventData == define.Store.Page.OrgFuLiShop then
			self:SetShopData(oCtrl.m_EventData)
		end
	end
end

function COrgShopView.RefreshUI(self)
	self.m_OwnLabel:SetNumberString(g_NpcShopCtrl:GetCurrencyValue(g_NpcShopCtrl:GetTagData(self.m_CurrentTagBtn.m_TagData.id).coin_typ))
	self.m_OwnCurrencySprite:SetSpriteName(g_NpcShopCtrl:GetCurrency(g_NpcShopCtrl:GetTagData(self.m_CurrentTagBtn.m_TagData.id).coin_typ).icon)
end

function COrgShopView.RefreshItem(self, goodsInfo)
	local oItemCell = self.m_GoodsPosToItemCell[goodsInfo.pos]
	oItemCell:Refresh(goodsInfo)
end

function COrgShopView.Destroy(self)
	if self.m_TimerID ~= nil then
		Utils.DelTimer(self.m_TimerID)
		self.m_TimerID = nil
	end
	local oView = COrgMainView:GetView()
	if oView ~= nil then
		oView:ShowInfo(true)
	end
	CViewBase.Destroy(self)
end

return COrgShopView