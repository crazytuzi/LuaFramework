local CPEFbBuyView = class("CPEFbBuyView", CViewBase)

CPEFbBuyView.CloseViewTime = 5

function CPEFbBuyView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/PartnerEquipFuben/PEBuyView.prefab", cb)
	self.m_ExtendClose = "ClickOut"
end

function CPEFbBuyView.OnCreateView(self)
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

function CPEFbBuyView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_AmountLabel:AddUIEvent("click", callback(self, "OnInput"))
	self.m_DelBtn:AddUIEvent("repeatpress", callback(self, "OnRePeatPress", "Del"))
	self.m_AddBtn:AddUIEvent("repeatpress", callback(self, "OnRePeatPress", "Add"))

	self.m_BuyBtn:AddUIEvent("click", callback(self, "OnBuy"))
end

function CPEFbBuyView.RefreshData(self, iBuy, iFbID)
	self.m_BuyAmount = iBuy
	self.m_MaxAmount = 5 - iBuy
	self.m_ID = iFbID
	if self.m_CurAmount and self.m_CurAmount <= self.m_MaxAmount then
	else
		self.m_CurAmount = 1
	end
	self.m_AmountLabel:SetText(self.m_CurAmount)
	self:UpdateCost()
	self.m_TipsLabel:SetText(string.format("每天购买价格随购买次数增加，还能购买%d次\n异空流放各层之间共享购买次数", self.m_MaxAmount))
end

-- COST={
-- 	[1]={cost=100,num=1,},
-- 	[5]={cost=400,num=5,},
-- 	[10]={cost=500,num=10,},
-- }
function CPEFbBuyView.UpdateCost(self)
	local iBuy = self.m_BuyAmount
	--local iTotal = 20
	local iStart = iBuy + 1
	local iEnd = iBuy + self.m_CurAmount

	local keyList = table.keys(data.pefubendata.COST)
	local costDict = data.pefubendata.COST
	local sum = 0
	for i = #keyList, 1, -1 do
		local k = i
		if iEnd >= k then
			if iStart >= k then
				sum = sum + (iEnd - iStart + 1) * costDict[k]["cost"]
				break
			else
				sum = sum + (iEnd - k + 1) * costDict[k]["cost"]
			end
			iEnd = k - 1
		end
	end
	self.m_CostLabel:SetText(tostring(sum))
	self.m_Cost = sum
	if g_AttrCtrl.goldcoin < sum then
		self.m_GreySpr:SetActive(true)
	else
		self.m_GreySpr:SetActive(false)
	end
end


function CPEFbBuyView.OnInput(self)
	local function syncCallback(self, count)
		self.m_CurAmount = count
		self.m_AmountLabel:SetText(self.m_CurAmount)
		self:UpdateCost()
	end
	g_WindowTipCtrl:SetWindowNumberKeyBorad(
	{num = self.m_CurAmount, min = 1, max = self.m_MaxAmount, min = 1, syncfunc = syncCallback , obj = self},
	{widget=  self.m_AmountLabel, side = enum.UIAnchor.Side.Up ,offset = Vector2.New(0, 0)})
end


function CPEFbBuyView.OnRePeatPress(self ,tType ,...)
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

function CPEFbBuyView.OnDel(self)
	self.m_CurAmount = math.max(1, self.m_CurAmount-1)
	self.m_AmountLabel:SetText(self.m_CurAmount)
	self:UpdateCost()
end

function CPEFbBuyView.OnAdd(self)
	self.m_CurAmount = math.min(self.m_MaxAmount, self.m_CurAmount+1)
	self.m_AmountLabel:SetText(self.m_CurAmount)
	self:UpdateCost()
end

function CPEFbBuyView.OnBuy(self)
	if g_AttrCtrl.goldcoin < self.m_Cost then
		g_WindowTipCtrl:ShowNoGoldTips(2)
	else
		nethuodong.C2GSBuyPEFuBen(self.m_CurAmount, self.m_ID)
	end
end

return CPEFbBuyView