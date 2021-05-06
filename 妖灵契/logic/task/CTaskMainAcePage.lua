local CTaskMainAcePage = class("CTaskMainAcePage", CPageBase)

function CTaskMainAcePage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CTaskMainAcePage.OnInitPage(self)
	self.m_TaskData = nil
	self.m_RewardList = nil
	self.m_TaskId = nil

	self.m_PageContainer = self:NewUI(1, CWidget)
	self.m_TitleLabel = self:NewUI(2, CLabel)
	self.m_TitleSubLabel = self:NewUI(3, CLabel)
	self.m_DesTitleLabel = self:NewUI(4, CLabel)
	self.m_DesMainLabel = self:NewUI(5, CLabel)
	self.m_TargetItemBox = self:NewUI(6, CItemTipsBox)
	self.m_DesSubNormalLabel = self:NewUI(7, CLabel)
	self.m_DesSubSpecialLabel = self:NewUI(8, CLabel)
	self.m_AwardTitleLabel = self:NewUI(9, CLabel)
	self.m_AwardGrid = self:NewUI(10, CGrid)
	self.m_AwardBox = self:NewUI(11, CItemTipsBox)
	self.m_AcceptBtn = self:NewUI(12, CButton)	

	self:InitContent()
end

function CTaskMainAcePage.InitContent(self)
	self.m_AwardBox:SetActive(false)
	self.m_PageContainer:SetActive(false)
	self.m_AcceptBtn:AddUIEvent("click", callback(self, "OnClickAccept"))

	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTaskCtrlEvent"))
end

function CTaskMainAcePage.OnTaskCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Task.Event.RefreshAllTaskBox then
		if self.m_TaskData ~= nil then			
			local tTask = g_TaskCtrl:GetTaskById(self.m_TaskId)
			self:SetTaskInfo(tTask)
		end
		
	elseif oCtrl.m_EventID == define.Task.Event.RefreshSpecificTaskBox then		

	end
end

function CTaskMainAcePage.OnClickAccept(self)
	if self.m_TaskData == nil then
		return
	end
	self.m_ParentView:CloseView()
	g_TaskCtrl:ClickTaskLogic(self.m_TaskData)
end

function CTaskMainAcePage.SetTaskInfo(self, oTask)
	if oTask == nil then
		self.m_TaskData = nil
		self.m_TaskId = nil
		self.m_PageContainer:SetActive(false)
		return
	end
	self.m_PageContainer:SetActive(true)

	self.m_TaskData = oTask
	self.m_TaskId = oTask:GetValue("taskid")
	self:SetTitleWidget()
	self:SetMainDesWidget()
	self:SetRewardWidget()
end

function CTaskMainAcePage.OnClickRewardBox(self, sid, parId, oBox)
	g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(sid,
	{widget = oBox, openView = self}, parId)
end

function CTaskMainAcePage.SetTitleWidget(self)
	self.m_TitleLabel:SetText(g_TaskCtrl:GetTaskDetailTitle(self.m_TaskData))
	local target = string.format("[5E2E10]%s", self.m_TaskData:GetValue("targetdesc"))
	self.m_DesMainLabel:SetText(target)
end

function CTaskMainAcePage.SetMainDesWidget(self)
	local target = string.format("[5E2E10]%s", self.m_TaskData:GetValue("detaildesc"))

	local needitem = self.m_TaskData:GetValue("needitem")
	if needitem	and needitem[1] ~= nil then
		self.m_TargetItemBox:SetActive(true)		
		local oItem = CItem.NewBySid(needitem[1].itemid)
		local count = g_ItemCtrl:GetTargetItemCountBySid(needitem[1].itemid) 
		self.m_TargetItemBox:SetItemData(needitem[1].itemid)
	else
		self.m_TargetItemBox:SetActive(false)
	end

	self.m_DesMainLabel:SetText(target)	
end

function CTaskMainAcePage.SetRewardWidget(self)
	local rewardList = g_TaskCtrl:GetTaskRewardList(self.m_TaskData)
	self.m_RewardList = rewardList
	local showReward = rewardList and #rewardList > 0
	self.m_AwardGrid:SetActive(showReward)
	local rewardGridList = self.m_AwardGrid:GetChildList() or {}
	local groupID = self.m_AwardGrid:GetInstanceID()
	for i,v in ipairs(rewardList) do
		local oRewardBox = nil
		if i > #rewardGridList then
			oRewardBox = self.m_AwardBox:Clone()
			oRewardBox:SetGroup(groupID)
			self.m_AwardGrid:AddChild(oRewardBox)			
		else
			oRewardBox = rewardGridList[i]
		end		
		local partId = tonumber(data.globaldata.GLOBAL.partner_reward_itemid.value)
		local config = {isLocal = true,}
		if v.sid == partId then
			oRewardBox:SetItemData(v.sid, v.amount, v.partnerId, config)
		else
			oRewardBox:SetItemData(v.sid, v.amount, nil, config)			
		end			
		oRewardBox:SetActive(true)
	end
	for i = #rewardList + 1, #rewardGridList do
		rewardGridList[i]:SetActive(false)
	end
end

return CTaskMainAcePage