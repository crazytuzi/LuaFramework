local CExchangeGoldCoinView = class("CExchangeGoldCoinView", CViewBase)

function CExchangeGoldCoinView.ctor(self, cb)
	CViewBase.ctor(self, "UI/NpcShop/ExchangeGoldCoinView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CExchangeGoldCoinView.OnCreateView(self)
	self.m_OpenShopBtn = self:NewUI(1, CButton)
	self.m_ExchangeRateLabel = self:NewUI(2, CLabel)
	self.m_PlayerGoldLabel = self:NewUI(3, CLabel)
	self.m_AddBtn = self:NewUI(4, CAddorDecButton)
	self.m_DecBtn = self:NewUI(5, CAddorDecButton)
	self.m_ExchangeNumLabel = self:NewUI(6, CLabel)
	self.m_ExchangeNumBtn = self:NewUI(7, CButton)
	self.m_GainCoinLabel = self:NewUI(8, CLabel)
	self.m_ExcangeBtn = self:NewUI(9, CButton)
	self.m_CancelBtn = self:NewUI(10, CButton)
	self.m_FindWayGroup = self:NewUI(11, CBox)
	self.m_FindWayGrid = self:NewUI(12, CGrid)
	self.m_FindWayCloneBox = self:NewUI(13, CBox)
	self.m_FindWayGroupBgSrp = self:NewUI(14, CSprite)
	self.m_MaxBtn = self:NewUI(15, CButton)
	self:InitContent()
end

function CExchangeGoldCoinView.InitContent(self)
	self.m_MaxNum = 10000
	self.m_MinNum = 0
	self.m_DefaultBuyNum = 1
	self.m_ExchangeNum = 1
	self.m_ExchangeRate = 0
	self.m_OwnerView = nil

	self.m_AddBtn:SetData({Label = self.m_ExchangeNumLabel, LimitNum = self.m_MaxNum, ChangeTable = {{0, 10},{5, 50}}, Callback = callback(self, "OnChangeGold")})
	self.m_DecBtn:SetData({Label = self.m_ExchangeNumLabel, LimitNum = self.m_MinNum, ChangeTable = {{0, -10},{5, -50}}, Callback = callback(self, "OnChangeGold")})
	self.m_ExchangeNumBtn:AddUIEvent("click", callback(self, "OnShowKeyboard"))
	self.m_ExcangeBtn:AddUIEvent("click", callback(self, "OnExcange"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_MaxBtn:AddUIEvent("click", callback(self, "OnMax"))
	self.m_OpenShopBtn:AddUIEvent("click", callback(self, "OnOpenShop"))

	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotifyRefresh"))
	g_NpcShopCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))
	self:RefreshUI()
	self:InitFindWay()
	self:SetExchangeRate()
end

function CExchangeGoldCoinView.InitFindWay(self)
	local gainWay = data.npcstoredata.GetWay.goldcoin.get_way
	for i,v in ipairs(gainWay) do
		local oBox = self:CreateFindWayBox()
		self.m_FindWayGrid:AddChild(oBox)
		oBox:SetData(data.itemdata.MODULE_SRC[v])
	end
	local w, h = self.m_FindWayGrid:GetCellSize()
	self.m_FindWayGroupBgSrp:SetHeight(91 + #gainWay * h)
	self.m_FindWayCloneBox:SetActive(false)
	self.m_FindWayGrid:Reposition()
end

function CExchangeGoldCoinView.CreateFindWayBox(self)
	local oBox = self.m_FindWayCloneBox:Clone()
	oBox.m_Label = oBox:NewUI(1, CLabel)
	oBox:AddUIEvent("click", callback(self, "OnClickGo", oBox))

	function oBox.SetData(self, oData)
		oBox.m_Data = oData
		oBox.m_Label:SetText(oData.name)
	end
	return oBox
end

function CExchangeGoldCoinView.OnClickGo(self, oBox)
	if not g_ActivityCtrl:ActivityBlockContrl("item_resource") and not g_ActivityCtrl:ActivityBlockContrl("partner_resource") then
		return
	end
	if oBox.m_Data.blockkey ~= "" then
		if not g_ActivityCtrl:ActivityBlockContrl(oBox.m_Data.blockkey) then
			return
		end
	end
	if g_ItemCtrl:ItemFindWayToSwitch(oBox.m_Data.id) == true then
		local oView = self.m_OwnerView
		if oView ~= nil then
			--如果是在背包页面切换画面，关闭背包页面
			if oView.classname == "CItemBagMainView" then
				oView:CloseView()
			end
		end
		self:CloseView()
	end
end

function CExchangeGoldCoinView.OnOpenShop(self)
	g_SdkCtrl:ShowPayView()
end

function CExchangeGoldCoinView.SetOwnerView(self, owner)
	self.m_OwnerView = owner
end

function CExchangeGoldCoinView.OnMax(self)
	if g_AttrCtrl.color_coin > self.m_MaxNum then
		self:OnChangeGold(self.m_MaxNum)
	else
		self:OnChangeGold(g_AttrCtrl.color_coin)
	end
end

function CExchangeGoldCoinView.SetExchangeRate(self)
	self.m_ExchangeRate = g_NpcShopCtrl:GetRatio(define.Store.ExchangeType.ColorCoin2GoldCoin)
	self.m_ExchangeRateLabel:SetText(string.format("1彩晶=%s水晶", self.m_ExchangeRate))
	self:OnChangeGold(self.m_ExchangeNum)
	self:RefreshUI()
end

function CExchangeGoldCoinView.CloseView(self)
	CViewBase.CloseView(self)
end

function CExchangeGoldCoinView.OnChangeGold(self, value)
	if self.m_MaxNum and value > self.m_MaxNum then
		self.m_ExchangeNum = self.m_MaxNum
		g_NotifyCtrl:FloatMsg("输入数字超出范围")
	elseif value < self.m_MinNum then
		self.m_ExchangeNum = self.m_MinNum
	else
		self.m_ExchangeNum = value
	end
	self.m_ExchangeNumLabel:SetText(self.m_ExchangeNum)
	self.m_GainCoinLabel:SetText(self.m_ExchangeRate * self.m_ExchangeNum)
end

function CExchangeGoldCoinView.OnShowKeyboard(self)
	local function syncCallback(self, count)
		self:OnChangeGold(count)
	end
	g_WindowTipCtrl:SetWindowNumberKeyBorad(
		{num = self.m_ExchangeNum, min = self.m_MinNum, max = self.m_MaxNum, syncfunc = syncCallback, obj = self},
		{widget = self.m_ExchangeNumBtn, side = enum.UIAnchor.Side.Top, offset = Vector2.New(0, 0), extendClose = true}
	)
end

function CExchangeGoldCoinView.OnExcange(self)
	if self.m_ExchangeNum > g_AttrCtrl.color_coin then
		g_NotifyCtrl:FloatMsg("您的彩晶不足")
		g_SdkCtrl:ShowPayView()
		self:OnClose()
	elseif self.m_ExchangeNum <= 0 then
		g_NotifyCtrl:FloatMsg("兑换数量最少为1")
	else
		netstore.C2GSGold2Coin(self.m_ExchangeNum, self.m_ExchangeRate, define.Store.ExchangeType.ColorCoin2GoldCoin)
	end
end

function CExchangeGoldCoinView.OnNotifyRefresh(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:RefreshUI()
	end
end

function CExchangeGoldCoinView.OnNotify(self, oCtrl)
	if oCtrl.m_EventID == define.Store.Event.CloseGold2Coin then
		self:CloseView()
	end
end

function CExchangeGoldCoinView.RefreshUI(self)
	self.m_PlayerGoldLabel:SetText(g_AttrCtrl.color_coin)
end

return CExchangeGoldCoinView