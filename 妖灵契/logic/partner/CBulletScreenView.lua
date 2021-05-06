local CBulletScreenView = class("CBulletScreenView", CViewBase)

function CBulletScreenView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Partner/BulletScreenView.prefab", cb)
	self.m_DepthType = "Notify"

	self.m_MsgList = {}
	self.m_LabelDict = {}
	self.m_Count = 1
end

function CBulletScreenView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_BG = self:NewUI(2, CSprite)
	self.m_Label = self:NewUI(3, CLabel)
	self.m_Label:SetActive(false)
	self.m_SelfLabel = self:NewUI(4, CLabel)
	self.m_SelfLabel:SetActive(false)
	self:InitContent()
end

function CBulletScreenView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	local w, h = UITools.GetRootSize()
	self.m_Width = w
	--位置调整 by ych
	local pos = Vector2.New(self.m_Label:GetLocalPos().x, h / 2 - 75)
	self.m_Label:SetLocalPos(pos)
	self.m_SelfLabel:SetLocalPos(pos)	

	self.m_BG:SetSize(w, 300)
	self:InitState()
	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTaskCtrlEvent"))
end

function CBulletScreenView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Partner.Event.AddBullet then
		self:AddMsg(oCtrl.m_EventData)
	end
end

function CBulletScreenView.OnTaskCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Task.Event.AddTaskBullet then
		self:AddMsg(oCtrl.m_EventData)
	end
end

function CBulletScreenView.AddMsg(self, oMsg)
	if oMsg["send_id"] == g_AttrCtrl.pid then
		table.insert(self.m_MsgList, 1, oMsg)
	else
		if g_MaskWordCtrl:IsContainHideStr(oMsg["content"]) then
			return
		end
		table.insert(self.m_MsgList, oMsg)
	end
	self:PlayNext()
end

function CBulletScreenView.PlayNext(self)
	if not next(self.m_MsgList) then
		return
	end
	local index = self:GetFreeLable()
	if index then
		local oMsg = self.m_MsgList[1]
		table.remove(self.m_MsgList, 1)
		self:PlayAnimation(index, oMsg)
	end
end

function CBulletScreenView.PlayAnimation(self, iTrack, oMsg)
	local label = self:CreateLable(oMsg, iTrack)
	local index = self.m_Count
	self.m_LabelDict[self.m_Count] = label
	self.m_Count = (index + 1) % 100
	
	self:SetTrickState(iTrack, "Add")
	local speed = data.partnerdata.BulletConfig[1]["speed"]
	local w = self.m_Width
	local v = tonumber(w * speed / 100)
	local lw, _ = label:GetSize()
	local t = (w + lw) / v
	local midt = (w / 2) / v
	local function finish()
		if Utils.IsNil(self) then
			return false
		end
		self:SetTrickState(iTrack, "Finish")
		if self.m_LabelDict[index] then
			self.m_LabelDict[index]:Destroy()
		end
		self.m_LabelDict[index] = nil
		self:PlayNext()
	end
	local pos =label:GetLocalPos()
	local oAction = CStableMove.New(label, t, pos, Vector3.New(-w / 2, pos.y, pos.z))
	oAction:SetEndCallback(finish)
	g_ActionCtrl:AddAction(oAction)
	local function midfinish()
		if Utils.IsNil(label) then
			return false
		end
		if label:GetLocalPos().x < 0 then
			self:SetTrickState(iTrack, "Ready")
			self:PlayNext()
			return false
		end
		return true
	end
	Utils.AddTimer(midfinish, 0.1, 0)
end

function CBulletScreenView.CreateLable(self, oMsg, iTrack)
	local sMsg = oMsg["content"]
	local pid = oMsg["send_id"]
	local label = self.m_Label:Clone()
	
	if pid == g_AttrCtrl.pid then
		label = self.m_SelfLabel:Clone()
		label:SetParent(self.m_SelfLabel:GetParent())
	else
		label:SetParent(self.m_Label:GetParent())
	end
	sMsg = string.replace(sMsg, "\n", " ")
	label:SetActive(true)
	label:SetRichText(sMsg)

	local lw, lh = label:GetSize()
	local p = label:GetLocalPos()
	p.x = self.m_Width/2 + lw
	p.y = p.y - iTrack*40
	label:SetLocalPos(p)
	return label
end

function CBulletScreenView.InitState(self)
	self.m_TrackState = {
		{0, 0},{0, 0},{0, 0},
	}
end

function CBulletScreenView.GetFreeLable(self)
	local list = {}
	for i, oState in ipairs(self.m_TrackState) do
		if oState[1] == 0 then
			table.insert(list, i)
		end
	end
	if #list > 0 then
		return table.randomvalue(list)
	end
	for i, oState in pairs(self.m_TrackState) do
		if oState[2] > 0 then
			table.insert(list, i)
		end
	end
	if #list > 0 then
		return table.randomvalue(list)
	else
		return nil
	end
end

function CBulletScreenView.SetTrickState(self, iTrack, iState)
	if iState == "Add" then
		self.m_TrackState[iTrack][1] = self.m_TrackState[iTrack][1] + 1
		self.m_TrackState[iTrack][2] = -1
	
	elseif iState == "Ready" then
		self.m_TrackState[iTrack][2] = g_TimeCtrl:GetTimeS()
	
	elseif iState == "Finish" then
		self.m_TrackState[iTrack][1] = self.m_TrackState[iTrack][1] - 1
		self.m_TrackState[iTrack][2] = 0
	end
end

return CBulletScreenView