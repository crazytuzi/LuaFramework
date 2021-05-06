local CChargeBackPage = class("CChargeBackPage", CPageBase)

function CChargeBackPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CChargeBackPage.OnInitPage(self)
	self.m_TimeLabel = self:NewUI(1, CLabel)
	self.m_ItemGrids = {}
	self.m_ItemGrids[1] = self:NewUI(2, CGrid)
	self.m_ItemGrids[2] = self:NewUI(3, CGrid)
	self.m_LeftLabels = {}
	self.m_LeftLabels[1] = self:NewUI(4, CLabel)
	self.m_LeftLabels[2] = self:NewUI(5, CLabel)
	self.m_GoBtn = self:NewUI(6, CButton)
	self.m_CloneItem = self:NewUI(7, CItemTipsBox)
	self.m_MainDesLabel = self:NewUI(8, CLabel)
	self.m_SubDesLabels = {}
	self.m_SubDesLabels[1] = self:NewUI(9, CLabel)
	self.m_SubDesLabels[2] = self:NewUI(10, CLabel)
	self.m_GoBtn:AddUIEvent("click", callback(self, "OnGo"))
	self.m_CloneItem:SetActive(false)

	self:SetContent()
end

function CChargeBackPage.SetContent(self)
	local d1 = data.welfaredata.CHARGE_REWARD_OPEN
	local d2 = data.welfaredata.CHARGE_REWARD
	if not d1 or not d2 then
		return
	end
	local curSchedule = g_WelfareCtrl.m_ChargeBackSchedule
	self.m_TimeLabel:SetText(string.format("%s-%s", g_TimeCtrl:GetDayByTimeS(g_WelfareCtrl.m_ChargeBackTimeS), g_TimeCtrl:GetDayByTimeS(g_WelfareCtrl.m_ChargeBackTimeE)))
	local info = g_WelfareCtrl:GetChargeBackInfo()
	self.m_MainDesLabel:SetText(d1[curSchedule].schedule_des)
	local scheduleList = {}
	for k,v in pairs(d2) do
		if v.schedule_id == curSchedule then
			scheduleList[v.sub_schedule_id] = v
		end
	end
	for i = 1, #scheduleList do
		self.m_SubDesLabels[i]:SetText(scheduleList[i].sub_schedule_des)
		local list = scheduleList[i].reward_id
		for _,v in ipairs(list) do
			local t = data.rewarddata.CHARGE[v]
			if t and t.reward[1] then
				local leftTime = 0
				if info[scheduleList[i].charge_rmb] and info[scheduleList[i].charge_rmb].left_amount then
					leftTime = info[scheduleList[i].charge_rmb].left_amount
				end
				local reward = t.reward[1]
				local oBox = self.m_CloneItem:Clone()					
				oBox:SetActive(true)
				oBox:SetItemData(tonumber(reward.sid), reward.amount, nil, {isLocal = true})
				self.m_LeftLabels[i]:SetText(string.format("[9A928F]（剩余[159a80]%d[9A928F]次）", leftTime))				
				self.m_LeftLabels[i]:SetActive(leftTime < 1000)
				self.m_ItemGrids[i]:AddChild(oBox)
			end
		end
	end
end

function CChargeBackPage.OnGo(self)
	if self.m_ParentView then
		self.m_ParentView:CloseView()
	end
	g_SdkCtrl:ShowPayView()
end

return CChargeBackPage