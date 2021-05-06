local CPartnerChipInputView = class("CPartnerChipInputView", CViewBase)

function CPartnerChipInputView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Partner/PartnerChipInputView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black" 
end

function CPartnerChipInputView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_Texture = self:NewUI(2, CTexture)
	self.m_AddBtn = self:NewUI(5, CButton)
	self.m_DelBtn = self:NewUI(6, CButton)
	self.m_AmountBtn = self:NewUI(7, CButton)
	self.m_MaxAmountBtn = self:NewUI(8, CButton)
	self.m_ConfirmBtn = self:NewUI(9, CButton)
	self.m_CostLabel = self:NewUI(10, CLabel)
	--self.m_IconBorder = self:NewUI(11, CSprite)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_DelBtn:AddUIEvent("repeatpress", callback(self, "OnRePeatPress", "Del"))
	self.m_AddBtn:AddUIEvent("repeatpress", callback(self, "OnRePeatPress", "Add"))
	self.m_MaxAmountBtn:AddUIEvent("click", callback(self, "OnMaxAmount"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnConfirm"))
	self.m_AmountBtn:AddUIEvent("click", callback(self, "OnInput"))
	self.m_Cost = 0
	self.m_MaxAmount = 1
	self.m_CurAmount = 1
end

function CPartnerChipInputView.SetType(self, chiptype, maxamount)
	self.m_ChipType = chiptype
	self.m_MaxAmount = maxamount
	local chipinfo = g_PartnerCtrl:GetSingleChipInfo(chiptype)
	local costlist = {5000, 15000, 65000, 150000}
	self.m_Cost = costlist[chipinfo:GetValue("rare")] or 0
	local shape = chipinfo:GetValue("shape")
	local k = 0.4
	if table.index({1753, 1754, 1755}, shape) then 
		k = 0.2
	end
	self.m_Texture:SetActive(false)
	self.m_Texture:LoadFullPhoto(shape, function()
		self.m_Texture:SnapFullPhoto(shape, k)
		self.m_Texture:SetActive(true)
		end)

	self:UpdateCost()
end

function CPartnerChipInputView.OnRePeatPress(self ,tType ,...)
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

function CPartnerChipInputView.OnDel(self)
	self.m_CurAmount = math.max(1, self.m_CurAmount-1)
	self:UpdateCost()
	self.m_AmountBtn:SetText(self.m_CurAmount)
end

function CPartnerChipInputView.OnAdd(self)
	self.m_CurAmount = math.min(self.m_MaxAmount, self.m_CurAmount+1)
	self:UpdateCost()
	self.m_AmountBtn:SetText(self.m_CurAmount)
end

function CPartnerChipInputView.OnMaxAmount(self)
	self.m_CurAmount = self.m_MaxAmount
	self:UpdateCost()
	self.m_AmountBtn:SetText(self.m_CurAmount)
end

function CPartnerChipInputView.OnConfirm(self)
	netpartner.C2GSComposePartner(self.m_ChipType, self.m_CurAmount)
end

function CPartnerChipInputView.UpdateCost(self)
	local coststr = string.format("#w1%s", string.numberConvert(self.m_CurAmount*self.m_Cost))
	self.m_CostLabel:SetText(coststr)
end

function CPartnerChipInputView.OnInput(self)
	local function syncCallback(self, count)
		self.m_CurAmount = count
		self:UpdateCost()
		self.m_AmountBtn:SetText(self.m_CurAmount)
	end
	g_WindowTipCtrl:SetWindowNumberKeyBorad(
	{num = self.m_CurAmount, min = 1, max = self.m_MaxAmount, syncfunc = syncCallback , obj = self},
	{widget=  self.m_AmountBtn, side = enum.UIAnchor.Side.Up ,offset = Vector2.New(0, 0)})
end

return CPartnerChipInputView