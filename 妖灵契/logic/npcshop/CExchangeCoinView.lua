local CExchangeCoinView = class("CExchangeCoinView", CViewBase)

function CExchangeCoinView.ctor(self, cb)
	CViewBase.ctor(self, "UI/NpcShop/ExchangeCoinView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CExchangeCoinView.OnCreateView(self)
	-- self.m_ColorBtn = self:NewUI(1, CBox)
	self.m_GoldBtn = self:NewUI(2, CBox)
	-- self.m_CurrencySprite = self:NewUI(1, CSprite)
	-- self.m_ExchangeRateLabel = self:NewUI(2, CLabel)
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
	self.m_OwnSprite = self:NewUI(16, CSprite)
	self.m_CurrencyLabel = self:NewUI(17, CLabel)
	self.m_OpenShopBtn = self:NewUI(18, CButton)
	self.m_ExtraLabel = self:NewUI(19, CLabel)
	self.m_MaxLabel = self:NewUI(20, CLabel)
	self.m_GiftMark = self:NewUI(21, CBox)
	self:InitContent()
end

function CExchangeCoinView.InitModeBtn(self, oBtn, iMode)
	oBtn.m_Btn = oBtn:NewUI(1, CButton)
	oBtn.m_Selected = oBtn:NewUI(2, CBox)
	oBtn.m_RateLabel = oBtn:NewUI(3, CLabel)
	oBtn.m_Selected:SetActive(false)
	-- oBtn.m_Btn:AddUIEvent("click", callback(self, "SetExchangeRate", iMode))
	self.m_OpenShopBtn:AddUIEvent("click", callback(self, "OnOpenShop"))
end

function CExchangeCoinView.InitContent(self)
	-- self:InitModeBtn(self.m_ColorBtn, define.Store.ExchangeType.ColorCoin2Coin)
	self:InitModeBtn(self.m_GoldBtn, define.Store.ExchangeType.GoldCoin2Coin)
	self.m_MaxNum = 10000
	self.m_MinNum = 0
	self.m_DefaultBuyNum = 10
	self.m_ExchangeNum = 10
	self.m_ExchangeRate = 0
	self.m_OwnerView = nil
	self.m_CurrencyValue = 0

	self.m_AddBtn:SetData({Label = self.m_ExchangeNumLabel, LimitNum = self.m_MaxNum, ChangeTable = {{0, 10},{5, 50}}, Callback = callback(self, "OnChangeGold")})
	self.m_DecBtn:SetData({Label = self.m_ExchangeNumLabel, LimitNum = self.m_MinNum, ChangeTable = {{0, -10},{5, -50}}, Callback = callback(self, "OnChangeGold")})
	self.m_AddBtn:SetClickChange(10)
	self.m_DecBtn:SetClickChange(-10)

	self.m_ExchangeNumBtn:AddUIEvent("click", callback(self, "OnShowKeyboard"))
	self.m_ExcangeBtn:AddUIEvent("click", callback(self, "OnExcange"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_MaxBtn:AddUIEvent("click", callback(self, "OnMax"))

	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotifyRefresh"))
	g_NpcShopCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))
	self:RefreshUI()
	self:InitFindWay()
	self:SetExchangeRate(define.Store.ExchangeType.GoldCoin2Coin)
end

function CExchangeCoinView.RefreshGiftCount(self)
	self.m_GiftCount = g_NpcShopCtrl:GetGiftCount(self.m_Mode)
	self.m_ExtraLabel:SetActive(self.m_GiftCount > 0)
	if self.m_GiftCount > 0 then
		self.m_GiftMark:SetActive(true)
		self.m_MaxLabel:SetText(self.m_GiftCount)
	else
		self.m_GiftMark:SetActive(false)
		self.m_MaxLabel:SetText("最大")
	end
	self:OnChangeGold(self.m_ExchangeNum)
end

function CExchangeCoinView.InitFindWay(self)
	local gainWay = data.npcstoredata.GetWay.coin.get_way
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

function CExchangeCoinView.CreateFindWayBox(self)
	local oBox = self.m_FindWayCloneBox:Clone()
	oBox.m_Label = oBox:NewUI(1, CLabel)
	oBox:AddUIEvent("click", callback(self, "OnClickGo", oBox))

	function oBox.SetData(self, oData)
		oBox.m_Data = oData
		oBox.m_Label:SetText(oData.name)
	end
	return oBox
end

function CExchangeCoinView.OnClickGo(self, oBox)
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

function CExchangeCoinView.SetOwnerView(self, owner)
	self.m_OwnerView = owner
end

function CExchangeCoinView.OnMax(self)
	local iMin = self.m_GiftCount
	if iMin == 0 then
		iMin = self.m_CurrencyValue
	end

	if self.m_CurrencyValue < iMin then
		iMin = self.m_CurrencyValue
	end
	if self.m_MaxNum < iMin then
		iMin = self.m_MaxNum
	end
	self:OnChangeGold(iMin)
end

function CExchangeCoinView.SetExchangeRate(self, iMode)
	self.m_Mode = iMode
	self.m_ExchangeNum = self.m_DefaultBuyNum
	self.m_ExchangeRate = g_NpcShopCtrl:GetRatio(iMode)
	-- self.m_ColorBtn.m_RateLabel:SetText(string.format("1彩晶=%s金币", g_NpcShopCtrl:GetRatio(define.Store.ExchangeType.ColorCoin2Coin)))
	self.m_GoldBtn.m_RateLabel:SetText(string.format("10水晶=%s金币", g_NpcShopCtrl:GetRatio(define.Store.ExchangeType.GoldCoin2Coin) * 10))
	if self.m_CurrentBtn ~= nil then
		self.m_CurrentBtn.m_Selected:SetActive(false)
	end
	if self.m_Mode == define.Store.ExchangeType.ColorCoin2Coin then
		-- self.m_CurrentBtn = self.m_ColorBtn
		-- self.m_OwnSprite:SetSpriteName("1001")
		-- self.m_CurrencyLabel:SetText("我的彩晶")
		-- self.m_OpenShopBtn:SetActive(true)
	else
		self.m_CurrentBtn = self.m_GoldBtn
		self.m_OwnSprite:SetSpriteName("1003")
		self.m_CurrencyLabel:SetText("我的水晶")
		self.m_OpenShopBtn:SetActive(false)
	end
	self.m_ExtraLabel:SetText(string.format("本日前%s水晶可额外获赠%s", g_NpcShopCtrl:GetTodayGiftCount(iMode), "50%金币"))
	self.m_CurrentBtn.m_Selected:SetActive(true)
	
	self:OnChangeGold(self.m_ExchangeNum)
	self:RefreshUI()
end

function CExchangeCoinView.CloseView(self)
	CViewBase.CloseView(self)
end

function CExchangeCoinView.OnChangeGold(self, value)
	if self.m_MaxNum and value > self.m_MaxNum then
		self.m_ExchangeNum = self.m_MaxNum
		g_NotifyCtrl:FloatMsg("输入数字超出范围")
	elseif value < self.m_MinNum then
		self.m_ExchangeNum = self.m_MinNum
	else
		self.m_ExchangeNum = value
	end
	self.m_ExchangeNumLabel:SetText(self.m_ExchangeNum)
	local iGift = 0
	if self.m_ExchangeNum > self.m_GiftCount then
		iGift = self.m_GiftCount
	else
		iGift = self.m_ExchangeNum
	end

	self.m_GainCoinLabel:SetText(self.m_ExchangeRate * (self.m_ExchangeNum - iGift + iGift * 1.5))
end

function CExchangeCoinView.OnShowKeyboard(self)
	local function syncCallback(self, count)
		self:OnChangeGold(count)
	end
	g_WindowTipCtrl:SetWindowNumberKeyBorad(
		{num = self.m_ExchangeNum, min = self.m_MinNum, max = self.m_MaxNum, syncfunc = syncCallback, obj = self},
		{widget = self.m_ExchangeNumBtn, side = enum.UIAnchor.Side.Top, offset = Vector2.New(0, 0), extendClose = true}
	)
end

function CExchangeCoinView.OnExcange(self)
	if self.m_Mode == define.Store.ExchangeType.GoldCoin2Coin and self.m_ExchangeNum > self.m_CurrencyValue then
		-- local windowConfirmInfo = {
		-- 	msg = "您的水晶不足哦，是否使用彩晶进行兑换？\n(彩晶兑换更划算哦~)",
		-- 	okStr = "前往兑换",
		-- 	cancelStr = "以后再说",
		-- 	okCallback = function()
		-- 		self:SetExchangeRate(define.Store.ExchangeType.ColorCoin2Coin)
		-- 	end
		-- }
		-- g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
		g_NotifyCtrl:FloatMsg("您的水晶不足")
		g_SdkCtrl:ShowPayView()
		self:OnClose()
	elseif self.m_Mode == define.Store.ExchangeType.ColorCoin2Coin and self.m_ExchangeNum > self.m_CurrencyValue then
		g_NotifyCtrl:FloatMsg("您的彩晶不足")
		g_SdkCtrl:ShowPayView()
		self:OnClose()
	elseif self.m_ExchangeNum <= 0 then
		g_NotifyCtrl:FloatMsg("兑换数量最少为1")
	else
		netstore.C2GSGold2Coin(self.m_ExchangeNum, self.m_ExchangeRate, self.m_Mode)
	end
end

function CExchangeCoinView.OnNotifyRefresh(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:RefreshUI()
	end
end

function CExchangeCoinView.OnNotify(self, oCtrl)
	if oCtrl.m_EventID == define.Store.Event.CloseGold2Coin then
		self:CloseView()
	end
end

function CExchangeCoinView.RefreshUI(self)
	if self.m_Mode == define.Store.ExchangeType.ColorCoin2Coin then
		self.m_CurrencyValue = g_AttrCtrl.color_coin
	else
		self.m_CurrencyValue = g_AttrCtrl.goldcoin
	end
	self.m_PlayerGoldLabel:SetText(self.m_CurrencyValue)
	self:RefreshGiftCount()
end

function CExchangeCoinView.OnOpenShop(self)
	g_SdkCtrl:ShowPayView()
end

return CExchangeCoinView