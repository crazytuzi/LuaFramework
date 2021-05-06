local CTaskPartTipsView = class("CTaskPartTipsView", CViewBase)

function CTaskPartTipsView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Task/TaskPartTipsView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
end

function CTaskPartTipsView.OnCreateView(self)
	self.m_TitleLabel = self:NewUI(1, CLabel)
	self.m_TipsLabel = self:NewUI(2, CLabel)
	self.m_CloseBtn = self:NewUI(3, CButton)
	self.m_OkBtn = self:NewUI(4, CButton)
	self.m_CancelBtn = self:NewUI(5, CButton)
	self.m_DoingLabel = self:NewUI(6, CLabel)
	self.m_AwardGrid = self:NewUI(7, CGrid)
	self.m_AwardBox = self:NewUI(8, CItemRewardBox)

	self:InitContent()
end

function CTaskPartTipsView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_OkBtn:AddUIEvent("click", callback(self, "OnAccept"))
	self.m_AwardBox:SetActive(false)
end

function CTaskPartTipsView.SetData(self, parId)
	if Utils.IsNil(self) then
		return
	end
	self.m_Data = g_TaskCtrl:GetPartnerTaskProgressData(parId)
	if not self.m_Data then
		self:OnClose()
	end
	local config = data.taskdata.TASK.PARTNER.CONFIG[self.m_Data.parid]
	if not config then
		self:OnClose()
	end
	self.m_TitleLabel:SetText(config.title)
	self.m_TipsLabel:SetText(config.des)

	if next(config.ui_reward) ~= nil then
		for k, v in ipairs(config.ui_reward) do
			local sid, value
			if string.find(v, "value") then
				sid,value = g_ItemCtrl:SplitSidAndValue(v)	
			else
				sid = tonumber(v)
			end
			value = value or 1
			local oItem = CItem.NewBySid(v.sid)
			local oBox = self.m_AwardBox:Clone()
			oBox:SetActive(true)
			local config = {side = enum.UIAnchor.Side.Top}
			oBox:SetItemBySid(sid, value, config)
			self.m_AwardGrid:AddChild(oBox)
		end
	end

	self.m_OkBtn:SetActive(false)
	self.m_CancelBtn:SetActive(false)
	self.m_DoingLabel:SetActive(false)

	if self.m_Data.status == 1 then
		self.m_OkBtn:SetActive(true)
		self.m_CancelBtn:SetActive(true)

	elseif self.m_Data.status == 2 then
		self.m_DoingLabel:SetActive(true)

	else
		self:OnClose()
	end
end

function CTaskPartTipsView.OnAccept(self)
	if self.m_Data then
		if g_TaskCtrl:IsHavePartnerTask() then
			g_NotifyCtrl:FloatMsg("当前已有领取任务，请先完成")
			return
		end
		g_TaskCtrl:C2GSAcceptSideTask(self.m_Data.parid)
		self:OnClose()
	end
end

return CTaskPartTipsView