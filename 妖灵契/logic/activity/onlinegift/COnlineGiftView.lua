local COnlineGiftView = class("COnlineGiftView", CViewBase)

function COnlineGiftView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/OnlineGift/OnlineGiftView.prefab", cb)
	self.m_ExtendClose = "Black"
	-- self.m_GroupName = "main"
	self.m_OpenEffect = "Scale"
end

function COnlineGiftView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_GetSpr = self:NewUI(2, CSprite)
	self.m_ItemTipsBox = self:NewUI(3, CItemTipsBox)
	self.m_LeftScrollView = self:NewUI(4, CScrollView)
	self.m_LeftGrid = self:NewUI(5, CGrid)
	self.m_CountDownLabel = self:NewUI(6, CCountDownLabel)
	self.m_RewardBox = self:NewUI(7, CBox)
	self:InitContent()
end

function COnlineGiftView.InitContent(self)
	self.m_Timer = nil
	self.m_OnlineTime = 0
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	g_OnlineGiftCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOnlineCtrl"))
	self.m_RewardBox:SetActive(false)
	self.m_GetSpr:SetActive(false)
	self:SetData()
end

function COnlineGiftView.SetData(self)
	self.m_OnlineTime = g_TimeCtrl:GetTimeS() - g_OnlineGiftCtrl:GetStartTime()
	self.m_Init = false
	self.m_BtnArr = {}
	self.m_LeftGrid:Clear()
	for i,v in ipairs(data.onlinegiftdata.SortID) do
		local oBox = self:CreateBtn()
		oBox:SetActive(true)
		
		self:UpdateReward(oBox, data.onlinegiftdata.DATA[v])
		if oBox.m_Status ~= define.OnlineGift.Status.Got and not self.m_Init then
			self:OnClickBtn(oBox)
			self.m_Init = true
		end
		self.m_LeftGrid:AddChild(oBox)
		self.m_BtnArr[i] = oBox
	end
	if not self.m_Init then
		self:OnClickBtn(self.m_BtnArr[1])
	end
	self.m_OnlineTime = g_TimeCtrl:GetTimeS() - g_OnlineGiftCtrl:GetStartTime()
	self.m_Timer = Utils.AddTimer(callback(self, "UpdataTime"), 1, 0)
end

function COnlineGiftView.Refresh(self)
	for i,v in ipairs(data.onlinegiftdata.SortID) do
		if self.m_BtnArr[i] then
			self:UpdateReward(self.m_BtnArr[i], data.onlinegiftdata.DATA[v])
		end
	end
end

function COnlineGiftView.OnOnlineCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.OnlineGift.Event.UpdateStatus then
		self:Refresh()
	
	elseif oCtrl.m_EventID == define.OnlineGift.Event.UpdateTime then
		self.m_OnlineTime = g_TimeCtrl:GetTimeS() - g_OnlineGiftCtrl:GetStartTime()
		self:Refresh()
	end
end

function COnlineGiftView.UpdataTime(self)
	if Utils.IsNil(self) then
		return
	end
	self.m_OnlineTime = g_TimeCtrl:GetTimeS() - g_OnlineGiftCtrl:GetStartTime()
	self:Refresh()
	return true
end

function COnlineGiftView.CreateBtn(self)
	local oBox = self.m_RewardBox:Clone()
	oBox.m_TimeSpr = oBox:NewUI(1, CSprite)
	oBox.m_GetBtn = oBox:NewUI(2, CButton)
	oBox.m_GotSpr = oBox:NewUI(3, CSprite)
	oBox.m_CanGetSpr = oBox:NewUI(4, CSprite)
	oBox.m_Grid = oBox:NewUI(5, CGrid)
	oBox.m_LeftTimeLabel = oBox:NewUI(6, CLabel)
	oBox.m_GetBtn = oBox:NewUI(7, CButton)
	oBox.m_RandomScrollView = oBox:NewUI(8, CScrollView)
	oBox.m_RandomGrid = oBox:NewUI(9, CGrid)

	oBox.m_GotSpr:SetActive(false)
	oBox.m_CanGetSpr:SetActive(false)
	oBox:SetActive(true)
	oBox:SetGroup(self.m_LeftGrid:GetInstanceID())
	return oBox
end

function COnlineGiftView.UpdateReward(self, oBox, oData)
	oBox.m_Data = oData
	oBox.m_TimeSpr:SetSpriteName(string.format("pic_zaixian_shijian%d", oData.online_time/60))

	oBox.m_GotSpr:SetActive(false)
	oBox.m_CanGetSpr:SetActive(false)
	oBox.m_LeftTimeLabel:SetActive(false)
	if g_OnlineGiftCtrl:IsGiftGot(oData.id) then
		--已领取
		oBox.m_Status = define.OnlineGift.Status.Got
		oBox.m_GotSpr:SetActive(true)
	elseif self.m_OnlineTime >= oData.online_time then
		--可领取
		oBox.m_Status = define.OnlineGift.Status.CanGet
		oBox.m_CanGetSpr:SetActive(true)
	else
		oBox.m_Status = define.OnlineGift.Status.Doing
		oBox.m_LeftTimeLabel:SetActive(true)
		local str = g_TimeCtrl:GetLeftTime(oData.online_time - self.m_OnlineTime)
		oBox.m_LeftTimeLabel:SetText(str)
	end
	if not oBox.m_InitGrid then
		oBox.m_Grid:Clear()
		for i, v in pairs(oData.reward) do
			local itemBox = self.m_ItemTipsBox:Clone()
			itemBox:SetSid(v.sid, v.num, {isLocal = true, uiType = 1})
			itemBox:SetActive(true)
			local getspr = self.m_GetSpr:Clone()
			getspr:SetParent(itemBox.m_Transform)
			getspr:SetLocalPos(Vector3.New(14, -22, 0))
			getspr:SetDepth(301)
			itemBox.m_GetSpr = getspr
			itemBox:SetLocalScale(Vector3.New(0.9, 0.9, 0.9))
			oBox.m_Grid:AddChild(itemBox)
		end
		oBox.m_Grid:Reposition()
		oBox.m_RandomGrid:Clear()
		for i, v in ipairs(oData.randomlist) do
			local oItemBox = self.m_ItemTipsBox:Clone()
			oItemBox:SetActive(true)
			oItemBox:SetSid(v.sid, v.num, {isLocal = true, uiType = 1})
			local getspr = self.m_GetSpr:Clone()
			getspr:SetParent(oItemBox.m_Transform)
			getspr:SetLocalPos(Vector3.New(14, -22, 0))
			getspr:SetDepth(301)
			oItemBox.m_GetSpr = getspr
			oItemBox:SetLocalScale(Vector3.New(0.9, 0.9, 0.9))
			if oData.randomicon[i] == 1 then
				oItemBox.m_QualitySprite:AddEffect("bordermove", nil, nil, 4)
				local effctobj = oItemBox.m_QualitySprite.m_Effects["bordermove"]
			end
			oBox.m_RandomGrid:AddChild(oItemBox)
		end
		oBox.m_RandomGrid:Reposition()
	end
	if oBox.m_Status == define.OnlineGift.Status.Got then
		for _, itemBox in ipairs(oBox.m_Grid:GetChildList()) do
			itemBox.m_GetSpr:SetActive(true)
			itemBox.m_IconSprite:SetGrey(true)
		end
		local dRewardInfo = g_OnlineGiftCtrl:GetGetRewardList(oData.id)
		for itemidx, itemBox in ipairs(oBox.m_RandomGrid:GetChildList()) do
			itemBox.m_IconSprite:SetGrey(true)
			itemBox.m_QualitySprite:DelEffect("bordermove")
			if dRewardInfo and table.index(dRewardInfo, itemidx) then
				itemBox.m_GetSpr:SetActive(true)
			else
				itemBox.m_GetSpr:SetActive(false)
			end
		end
	end
	oBox.m_InitGrid = true
	oBox.m_GetBtn:AddUIEvent("click", callback(self, "OnGetBtn", oData.id))
	oBox:AddUIEvent("click", callback(self, "OnClickBtn"))
end

function COnlineGiftView.OnClickBtn(self, oBtnBox)
	local isdoing = oBtnBox.m_Status == define.OnlineGift.Status.Doing
	self:Refresh()
end

function COnlineGiftView.OnGetBtn(self, id)
	nethuodong.C2GSGetOnlineGift(id)
end

function COnlineGiftView.Destroy(self)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
	CViewBase.Destroy(self)
end


return COnlineGiftView