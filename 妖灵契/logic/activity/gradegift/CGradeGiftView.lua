local CGradeGiftView = class("CGradeGiftView", CViewBase)

function CGradeGiftView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/GradeGift/GradeGiftView.prefab", cb)
	self.m_ExtendClose = "Black"
	-- self.m_GroupName = "main"
end

function CGradeGiftView.OnCreateView(self)
	self.m_OldCostLabel = self:NewUI(1, CLabel)
	self.m_NowCostLabel = self:NewUI(2, CLabel)
	self.m_TipsLabel = self:NewUI(3, CLabel)
	self.m_PayGrid = self:NewUI(4, CGrid)
	self.m_BuyBtn = self:NewUI(5, CSprite)
	self.m_FreeGrid = self:NewUI(6, CGrid)
	self.m_ItemTipsBox = self:NewUI(7, CItemTipsBox)
	self.m_GetBtn = self:NewUI(8, CSprite)
	self.m_CountDownLabel = self:NewUI(9, CCountDownLabel)
	self.m_GradeSprite = self:NewUI(10, CSprite)
	self.m_Container = self:NewUI(11, CWidget)
	self.m_SellOutMark = self:NewUI(12, CBox)
	self.m_GotMark = self:NewUI(13, CBox)
	self:InitContent()
end

function CGradeGiftView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_BuyBtn:AddUIEvent("click", callback(self, "OnBuy"))
	self.m_GetBtn:AddUIEvent("click", callback(self, "OnGetGift"))
	self.m_CountDownLabel:SetTickFunc(callback(self, "OnTick"))
	self.m_CountDownLabel:SetTimeUPCallBack(callback(self, "OnTimeUP"))

	g_GradeGiftCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnGradeGiftEvent"))
	self:SetData()
end

function CGradeGiftView.SetData(self)
	self.m_GradeSprite:SetSpriteName(string.format("text_%s", g_GradeGiftCtrl.m_Grade))
	self.m_OldCostLabel:SetText(string.format("原价%s", g_GradeGiftCtrl.m_OldPrice))
	self.m_NowCostLabel:SetText(g_GradeGiftCtrl.m_NowPrice)
	self.m_TipsLabel:SetText(string.format("立减\n%s%s", (100 - g_GradeGiftCtrl.m_Discount),"%"))
	self:RefreshItem(self.m_FreeGrid, g_GradeGiftCtrl.m_FreeGiftList.items)
	self:RefreshItem(self.m_PayGrid, g_GradeGiftCtrl.m_PayGiftList.items)
	self.m_SellOutMark:SetActive(g_GradeGiftCtrl.m_PayGiftList.done == 1)
	self.m_GotMark:SetActive(g_GradeGiftCtrl.m_FreeGiftList.done == 1)
	self.m_BuyBtn:SetActive(g_GradeGiftCtrl.m_PayGiftList.done ~= 1)
	self.m_GetBtn:SetActive(g_GradeGiftCtrl.m_FreeGiftList.done ~= 1)
	if g_GradeGiftCtrl:GetStatus() == define.GradeGift.Status.Buying then
		self.m_CountDownLabel:BeginCountDown(g_GradeGiftCtrl:GetRestTime())
	elseif g_GradeGiftCtrl:GetStatus() == define.GradeGift.Status.Foretell then
		self.m_CountDownLabel:DelTimer()
		self.m_CountDownLabel:SetText(string.format("%s等级开启", g_GradeGiftCtrl.m_Grade))
	end
end

function CGradeGiftView.RefreshItem(self, oGrid, oData)
	oGrid:Clear()
	if not oData then
		return
	end
	for i,v in ipairs(oData) do
		if v.sid then
			local oItemBox = self.m_ItemTipsBox:Clone()
			oItemBox:SetActive(true)
			local config = {isLocal = true, uiType = 2}
			if v.virtual ~= 1010 then
				oItemBox:SetItemData(v.sid, v.amount, nil ,config)
			else
				oItemBox:SetItemData(v.virtual, v.amount, v.sid ,config)
			end
			oItemBox.m_CountLabel:SetActive(true)
			oItemBox.m_CountLabel:SetNumberString(v.amount)
			oGrid:AddChild(oItemBox)
		end
	end
end

function CGradeGiftView.OnTick(self, iValue)
	self.m_CountDownLabel:SetText(string.format("礼包剩余时间：%s", g_TimeCtrl:GetLeftTime(iValue)))
end

function CGradeGiftView.OnTimeUP(self)
	self.m_CountDownLabel:SetText("即将刷新")
end

function CGradeGiftView.OnBuy(self)
	if g_GradeGiftCtrl:GetStatus() == define.GradeGift.Status.Foretell then
		g_NotifyCtrl:FloatMsg("礼包未开启")
		return
	end
	if g_LoginCtrl:IsSdkLogin() then
		if Utils.IsAndroid() then
			g_SdkCtrl:Pay(g_GradeGiftCtrl.m_Payid, 1, {request_value = tostring(g_GradeGiftCtrl.m_Grade), request_key = "grade_key"})
		elseif Utils.Utils.IsIOS() then
			g_SdkCtrl:Pay(g_GradeGiftCtrl.m_IosPayID, 1, {request_value = tostring(g_GradeGiftCtrl.m_Grade), request_key = "grade_key"})
		else
			g_NotifyCtrl:FloatMsg("当前环境不支持购买")
		end
	elseif Utils.IsDevUser() and Utils.IsEditor() then
		netother.C2GSGMCmd(string.format("huodong gradegift 101 %s", g_GradeGiftCtrl.m_Grade))
		g_NotifyCtrl:FloatMsg("直接调用GM指令，超级高危操作！！！只用于测试")
	else
		g_NotifyCtrl:FloatMsg("当前环境不支持购买")
	end
end

function CGradeGiftView.OnGetGift(self)
	if g_GradeGiftCtrl:GetStatus() == define.GradeGift.Status.Foretell then
		g_NotifyCtrl:FloatMsg("礼包未开启")
		return
	end
	nethuodong.C2GSReceiveFreeGift(g_GradeGiftCtrl.m_Grade)
end

function CGradeGiftView.OnGradeGiftEvent(self, oCtrl)
	if oCtrl.m_EventID == define.GradeGift.Event.UpdateInfo then
		self:SetData()
	end
end

return CGradeGiftView