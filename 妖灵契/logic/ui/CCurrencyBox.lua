local CCurrencyBox = class("CCurrencyBox", CBox)

function CCurrencyBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_CurrencySpr = self:NewUI(1, CSprite)
	self.m_CountLabel = self:NewUI(2, CLabel)
	self.m_AddButton = self:NewUI(3, CButton)

	self.m_CurrencyType = 0
	self.m_IsCost = false
	self.m_Amount = 0
	self.m_WarningValue = -1

	self.m_AddButton:AddUIEvent("click", callback(self, "OpenCurrencyView"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAttrEvent"))
end

function CCurrencyBox.OnCtrlAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:RefreshCurrency()
	end
end

--设置警告值，低于警告值显示红色
--@param iValue 警告值
function CCurrencyBox.SetWarningValue(self, iValue)
	self.m_WarningValue = iValue
	self:RefreshCurrency()
end

--设置货币类型
--@param iType 
--@param bIsCost 默认非消耗
function CCurrencyBox.SetCurrencyType(self, iType, bIsCost)
	self.m_CurrencyType = iType
	self.m_IsCost = bIsCost or false
	self:InitCurrencySpr()
	self:RefreshCurrency()
	self.m_AddButton:SetActive(not self.m_IsCost)
end

--初始货币Icon
function CCurrencyBox.InitCurrencySpr(self)
	local list = {"10002s","10003s","10001s",}
	self:SetSpriteName(list[self.m_CurrencyType])
end

--设置货币数量
--@param iCount 
function CCurrencyBox.SetCurrencyCount(self, iCount)
	if iCount < self.m_WarningValue then
		self.m_CountLabel:SetText("#R"..iCount.."#n")
	else
		self.m_CountLabel:SetText(iCount)
	end
	self.m_Amount = iCount
end

--非消耗状态下自动刷新货币
function CCurrencyBox.RefreshCurrency(self)
	if self.m_IsCost then
		self:SetCurrencyCount(self.m_Amount)
		return
	end
	local iCount = 0
	if self.m_CurrencyType == define.Currency.Type.Gold then
		iCount = g_AttrCtrl.gold
	elseif self.m_CurrencyType == define.Currency.Type.Silver then
		iCount = g_AttrCtrl.silver
	else
		iCount = g_AttrCtrl.goldcoin
	end
	self:SetCurrencyCount(iCount)
end

function CCurrencyBox.OpenCurrencyView(self)
	if self.m_CurrencyType == define.Currency.Type.Gold then
		CCurrencyView:ShowView(function(oView)
			oView:SetCurrencyView(define.Currency.Type.Gold)
		end)
	elseif self.m_CurrencyType == define.Currency.Type.Silver then
		CCurrencyView:ShowView(function(oView)
			oView:SetCurrencyView(define.Currency.Type.Silver)
		end)
	else
		return
	end
end
return CCurrencyBox