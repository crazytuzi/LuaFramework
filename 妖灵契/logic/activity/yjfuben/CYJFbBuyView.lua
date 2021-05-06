local CYJFbBuyView = class("CYJFbBuyView", CViewBase)

CYJFbBuyView.CloseViewTime = 5

function CYJFbBuyView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/YJFuben/YJBuyView.prefab", cb)
	self.m_ExtendClose = "ClickOut"
	self.m_SwitchSceneClose = true
end

function CYJFbBuyView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_TipsLabel = self:NewUI(2, CLabel)
	self.m_AddBtn = self:NewUI(3, CButton)
	self.m_DelBtn = self:NewUI(4, CButton)
	self.m_AmountLabel = self:NewUI(5, CLabel)
	self.m_BuyBtn = self:NewUI(6, CButton)
	self.m_CostLabel = self:NewUI(7, CLabel)
	self.m_GreySpr = self:NewUI(8, CSprite)
	self:InitContent()
end

function CYJFbBuyView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_AmountLabel:AddUIEvent("click", callback(self, "OnInput"))
	self.m_DelBtn:AddUIEvent("repeatpress", callback(self, "OnRePeatPress", "Del"))
	self.m_AddBtn:AddUIEvent("repeatpress", callback(self, "OnRePeatPress", "Add"))

	self.m_BuyBtn:AddUIEvent("click", callback(self, "OnBuy"))
end

function CYJFbBuyView.RefreshData(self, iRemain, iBuy)
	-- self.m_BuyAmount = iBuy
	self.m_RemainAmount = iRemain
	self.m_MaxAmount = iBuy
	if self.m_CurAmount and self.m_CurAmount <= self.m_MaxAmount then
	else
		self.m_CurAmount = 1
	end
	self.m_AmountLabel:SetText(self.m_CurAmount)
	self:UpdateCost()
	self.m_TipsLabel:SetText("每天限购1次（次数当天有效）")
end

function CYJFbBuyView.UpdateCost(self)
	local sum = self.m_CurAmount * 180
	self.m_CostLabel:SetRichText(string.format("#w2 %d", sum))
	self.m_Cost = sum
	self.m_GreySpr:SetActive(false)
end

function CYJFbBuyView.OnInput(self)
	local function syncCallback(self, count)
		self.m_CurAmount = count
		self.m_AmountLabel:SetText(self.m_CurAmount)
		self:UpdateCost()
	end
	g_WindowTipCtrl:SetWindowNumberKeyBorad(
	{num = self.m_CurAmount, min = 0, max = self.m_MaxAmount, syncfunc = syncCallback , obj = self},
	{widget=  self.m_AmountLabel, side = enum.UIAnchor.Side.Up ,offset = Vector2.New(0, 0)})
end


function CYJFbBuyView.OnRePeatPress(self ,tType ,...)
	local bPress = select(2, ...)
	if bPress ~= true then
			return
	end 
	
	if tType == "Add" then
		self:OnAdd()
	else
		self:OnDel()
	end
end

function CYJFbBuyView.OnDel(self)
	self.m_CurAmount = math.max(0, self.m_CurAmount-1)
	self.m_AmountLabel:SetText(self.m_CurAmount)
	self:UpdateCost()
end

function CYJFbBuyView.OnAdd(self)
	self.m_CurAmount = math.min(self.m_MaxAmount, self.m_CurAmount+1)
	self.m_AmountLabel:SetText(self.m_CurAmount)
	self:UpdateCost()
end

function CYJFbBuyView.OnBuy(self)
	if g_AttrCtrl.goldcoin < self.m_Cost then
		g_WindowTipCtrl:ShowNoGoldTips(2)
	else
		nethuodong.C2GSBuyYJFuben(self.m_CurAmount)
	end
end

return CYJFbBuyView