local CTaskMainCurPage = class("CTaskMainCurPage", CPageBase)

function CTaskMainCurPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CTaskMainCurPage.OnInitPage(self)
	self.m_TaskData = nil
	self.m_RewardList = nil
	self.m_TaskId = nil 
	self.m_RemainTime = 0
	self.m_RemainTimer = nil
	self.m_TargetText = nil

	self.m_PageContainer = self:NewUI(1, CWidget)
	self.m_TitleLabel = self:NewUI(2, CLabel)
	self.m_TitleSubLabel = self:NewUI(3, CLabel)
	self.m_DesTitleLabel = self:NewUI(4, CLabel)
	self.m_DesMainLabel = self:NewUI(5, CLabel)
	self.m_TargetItemBox = self:NewUI(6, CItemTipsBox)
	self.m_DesSubNormalLabel = self:NewUI(7, CLabel)
	self.m_DesSubSpecialLabel = self:NewUI(8, CLabel)
	self.m_AwardGrid = self:NewUI(10, CGrid)
	self.m_AwardBox = self:NewUI(11, CItemTipsBox)
	self.m_GiveUpBtn = self:NewUI(12, CButton)
	self.m_GoBtn = self:NewUI(13, CButton)
	self.m_DesScrollView = self:NewUI(14, CScrollView)
	self.m_ScrollViewContent = self:NewUI(15, CWidget)

	self:InitContent()
end

function CTaskMainCurPage.InitContent(self)
	self.m_AwardBox:SetActive(false)
	self.m_PageContainer:SetActive(false)
	self.m_GiveUpBtn:AddUIEvent("click", callback(self, "OnClickGiveUp"))
	self.m_GoBtn:AddUIEvent("click", callback(self, "OnClickGo"))

	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTaskCtrlEvent"))
end

function CTaskMainCurPage.OnTaskCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Task.Event.RefreshAllTaskBox then
		if self.m_TaskData ~= nil then			
			local tTask = g_TaskCtrl:GetTaskById(self.m_TaskId)
			self:SetTaskInfo(tTask)
		end
	elseif oCtrl.m_EventID == define.Task.Event.RefreshSpecificTaskBox then		

	end
end

function CTaskMainCurPage.OnClickGiveUp(self)
	if self.m_TaskData == nil then
		return
	end
	local id = self.m_TaskData:GetValue("taskid")
	g_TaskCtrl:C2GSAbandonTask(id)
end

function CTaskMainCurPage.OnClickGo(self)	
	if g_TaskCtrl:CheckClickTaskInterval(self.m_TaskId) then
		if g_ActivityCtrl:ActivityBlockContrl("task") then
			if self.m_TaskData:GetValue("type") == define.Task.TaskCategory.SHIMEN.ID then
				g_TaskCtrl:StartAutoDoingShiMen(true)
			else
				g_TaskCtrl:StartAutoDoingShiMen(false)
			end
			g_TaskCtrl:ClickTaskLogic(self.m_TaskData, nil, {clickTask = true})
			self.m_ParentView:CloseView()		
		end
	end
end

function CTaskMainCurPage.SetTaskInfo(self, oTask)
	if oTask == nil then
		self.m_TaskData = nil
		self.m_TaskId = nil
		self.m_RemainTime = 0
		if self.m_RemainTimer ~= nil then
			Utils.DelTimer(self.m_RemainTimer)
			self.m_RemainTimer = nil
		end
		self.m_TargetText = nil
		self.m_PageContainer:SetActive(false)
		return
	end
	self.m_PageContainer:SetActive(true)

	self.m_TaskData = oTask
	self.m_TaskId = oTask:GetValue("taskid")
	self.m_GoBtn:SetActive(not oTask:IsMissMengTask())	
	self:SetTitleWidget()
	self:SetMainDesWidget()
	self:SetRewardWidget()
	self.m_DesScrollView:ResetPosition()
	self:AdjustScrollViewContentSize()
end

function CTaskMainCurPage.SetTitleWidget(self)
	self.m_TitleLabel:SetText(g_TaskCtrl:GetTaskDetailTitle(self.m_TaskData))

	local target = g_TaskCtrl:GetTargetDesc(self.m_TaskData, false)
	self.m_DesMainLabel:SetText(target)
	self.m_TitleSubLabel:SetActive(false)
	if self.m_TaskData:GetValue("type") == define.Task.TaskCategory.SHIMEN.ID then
		local shimenInfo = self.m_TaskData:GetValue("shimeninfo")
		if shimenInfo then
			self.m_TitleSubLabel:SetActive(true)
			self.m_TitleSubLabel:SetText(string.format("%s(%d/%d)", data.colordata.COLORINDARK["#R"], shimenInfo.cur_times, shimenInfo.max_times)) 
		end
	end
	
end

function CTaskMainCurPage.SetMainDesWidget(self)
	local target = g_TaskCtrl:GetTargetDesc(self.m_TaskData, false)

	--显示任务道具进度
	local needitem = self.m_TaskData:GetValue("needitem")
	if needitem	and needitem[1] ~= nil then
		self.m_TargetItemBox:SetActive(true)		
		local oItem = CItem.NewBySid(needitem[1].itemid)
		local count = g_ItemCtrl:GetTargetItemCountBySid(needitem[1].itemid) 
		if count >= needitem[1].amount then
			target = string.format("%s[159a80] (%d/%d)[654A33] ", target, count, needitem[1].amount)
		else
			target = string.format("%s[c54420] (%d/%d)[654A33] ", target, count, needitem[1].amount)
		end
		self.m_TargetItemBox:SetItemData(needitem[1].itemid)
	else
		self.m_TargetItemBox:SetActive(false)
	end
	self.m_TargetText = target

	--任务倒计时处理
	self.m_RemainTime = self.m_TaskData:GetRemainTime()
	if self.m_RemainTime > 0 then		
		local function update(dt)
			self.m_RemainTime = self.m_RemainTime - 1
			self:SetTargetText()
			if self.m_RemainTime <= 0 then
				return false
			else
				return true
			end
		end

		if self.m_RemainTimer ~= nil then
			Utils.DelTimer(self.m_RemainTimer)
			self.m_RemainTimer = nil
		end
		self.m_RemainTimer = Utils.AddTimer(update, 1, 0)	
	else
		self.m_RemainTime = 0
		if self.m_RemainTimer ~= nil then
			Utils.DelTimer(self.m_RemainTimer)
			self.m_RemainTimer = nil
		end
	end

	self:SetTargetText()
end

function CTaskMainCurPage.SetTargetText(self)
	local targetText = self.m_TargetText
	if self.m_RemainTime and self.m_RemainTime > 0 then
		targetText = string.format("%s[c54420](%dS)", targetText, self.m_RemainTime)
	end
	self.m_DesMainLabel:SetText(targetText)	
end

function CTaskMainCurPage.SetRewardWidget(self)
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
		--如果是日程任务，不显示奖励的数量（因为奖励是奖励池）
		if self.m_TaskData:GetValue("type") == define.Task.TaskCategory.DAILY.ID then
			oRewardBox.m_CountLabel:SetActive(false)
		end
		oRewardBox:SetActive(true)
	end
	for i = #rewardList + 1, #rewardGridList do
		rewardGridList[i]:SetActive(false)
	end
end

function CTaskMainCurPage.Destroy(self)
	if self.m_RemainTimer ~= nil then
		Utils.DelTimer(self.m_RemainTimer)
		self.m_RemainTimer = nil
	end
	CPageBase.Destroy(self)
end

function CTaskMainCurPage.AdjustScrollViewContentSize(self)
	local function cb()
		if not Utils.IsNil(self) then			
			if self.m_TargetItemBox:GetActive() == true then
				local pos = self.m_TargetItemBox:GetLocalPos()
				if pos.y < -150 then
					local offset = -150 - pos.y
					self.m_ScrollViewContent:SetHeight(210 + offset)
				else
					self.m_ScrollViewContent:SetHeight(210)
				end
			else
				self.m_ScrollViewContent:SetHeight(210)
			end			
		end
	end
	Utils.AddTimer(cb, 0, 0.1)
end

return CTaskMainCurPage