local COrgApproveView = class("COrgApproveView", CViewBase)

function COrgApproveView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Org/OrgApproveView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function COrgApproveView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_InfoGrid = self:NewUI(2, CGrid)
	self.m_InfoBox = self:NewUI(3, CBox)
	self.m_RejectAllBtn = self:NewUI(4, CButton)
	self.m_InviteBtn = self:NewUI(5, CButton)
	self.m_SettingBtn = self:NewUI(6, CButton)
	self.m_PowerLimitLabel = self:NewUI(7, CLabel)
	self.m_NeedAllowLabel = self:NewUI(8, CLabel)
	self.m_SettingPart = self:NewUI(9, CBox)
	self.m_MemberLabel = self:NewUI(10, CLabel)
	self.m_SortGradeBtn = self:NewUI(11, CBox)
	self.m_SortPowerBtn = self:NewUI(12, CBox)
	self.m_SortTimeBtn = self:NewUI(13, CBox)
	self.m_XiaoRenTexture = self:NewUI(14, CSpineTexture)
	self.m_SpreadLabel = self:NewUI(15, CCountDownLabel)
	self:InitContent()
end

function COrgApproveView.InitContent(self)
	self.m_SpreadLabel:SetTickFunc(callback(self, "OnSpreadCount"))
	self.m_SpreadLabel:SetTimeUPCallBack(callback(self, "OnSpreadTimeUp"))
	self.m_SpreadLabel:BeginCountDown(g_OrgCtrl:GetSpreadTime())
	self.m_XiaoRenTexture:SetActive(false)
	self.m_XiaoRenTexture:ShapeOrg("XiaoRen", function ()
		self.m_XiaoRenTexture:SetActive(true)
		self.m_XiaoRenTexture:SetAnimation(0, "idle_1", false)
	end)
	self.m_CurSortList = g_OrgCtrl.m_ApproveSortList.apply_time
	self.m_InfoBoxArr = {}
	self.m_IDToInfoBox = {}
	self.m_SettingBox = self:CreateSettingPart()

	self.m_SortList = {
		{btn = self.m_SortGradeBtn, list = g_OrgCtrl.m_ApproveSortList.grade, bReverse = true},
		{btn = self.m_SortPowerBtn, list = g_OrgCtrl.m_ApproveSortList.power, bReverse = true},
		{btn = self.m_SortTimeBtn, list = g_OrgCtrl.m_ApproveSortList.apply_time, bReverse = true},
	}
	for i = 1, #self.m_SortList do
		self.m_SortList[i].btn:AddUIEvent("click", callback(self, "OnClickSort", self.m_SortList[i].list))
	end

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_RejectAllBtn:AddUIEvent("click", callback(self, "OnClickRejectAll"))
	self.m_InviteBtn:AddUIEvent("click", callback(self, "OnClickInvite"))
	self.m_SettingBtn:AddUIEvent("click", callback(self, "OnClickSetting"))
	g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))
	self:SetData()
	self:SetLimitData()
	self:SetMemberLabelData()
	self.m_InfoBox:SetActive(false)
end

function COrgApproveView.OnSpreadCount(self, iValue)
	self.m_SpreadLabel:SetText(string.format("剩余时间：%s", g_TimeCtrl:GetLeftTime(iValue)))
end

function COrgApproveView.OnSpreadTimeUp(self)
	self.m_SpreadLabel:SetText("未开启招募")
end

function COrgApproveView.SetMemberLabelData(self)
	self.m_MemberLabel:SetText(string.format("公会当前成员：%d/%d", g_OrgCtrl:GetMyOrgInfo().memcnt, g_OrgCtrl:GetMaxMember(g_OrgCtrl:GetMyOrgInfo().level)))
end

function COrgApproveView.CreateSettingPart(self)
	local oSettingBox = self.m_SettingPart
	oSettingBox.m_CloseBtn = oSettingBox:NewUI(1, CButton)
	oSettingBox.m_Input = oSettingBox:NewUI(2, CInput)
	oSettingBox.m_FreeJoinBtn = oSettingBox:NewUI(3, CBox)
	oSettingBox.m_NeedAllowBtn = oSettingBox:NewUI(4, CBox)
	oSettingBox.m_SaveBtn = oSettingBox:NewUI(5, CButton)
	
	oSettingBox.m_FreeJoinBtn:SetGroup(oSettingBox:GetInstanceID())
	oSettingBox.m_NeedAllowBtn:SetGroup(oSettingBox:GetInstanceID())
	oSettingBox.m_CloseBtn:AddUIEvent("click", callback(self, "OnHideSetting"))
	oSettingBox.m_SaveBtn:AddUIEvent("click", callback(self, "OnClickSave"))
	oSettingBox.m_Input:AddUIEvent("change", callback(self, "OnInputChange"))
	function oSettingBox.SetData(self)
		oSettingBox:SetActive(true)
		oSettingBox.m_Input:SetText(tostring(g_OrgCtrl.m_Org.powerlimit))
		if g_OrgCtrl.m_Org.needallow == COrgCtrl.Need_Allow then
			oSettingBox.m_NeedAllowBtn:SetSelected(true)
		else
			oSettingBox.m_FreeJoinBtn:SetSelected(true)
		end
	end

	return oSettingBox
end

function COrgApproveView.SetData(self)
	-- self.m_Data = g_OrgCtrl.m_ApplyList
	self.m_Data = g_OrgCtrl:GetApproveSortList(self.m_CurSortList, self.m_CurSortList.bReverse)
	local count = 0
	local now = g_TimeCtrl:GetTimeS()
	for k,v in pairs(self.m_Data) do
		if v ~= nil then
			count = count + 1
			if self.m_InfoBoxArr[count] == nil then
				self.m_InfoBoxArr[count] = self:CreateInfoBox()
			end
			self.m_IDToInfoBox[v.pid] = self.m_InfoBoxArr[count]
			self.m_InfoBoxArr[count]:SetData(v, now)
		end
	end
	count = count + 1
	for i = count, #self.m_Data do
		self.m_InfoBoxArr[i]:SetActive(false)
	end
end

function COrgApproveView.SetLimitData(self)
	if g_OrgCtrl.m_Org.needallow == COrgCtrl.Need_Allow then
		self.m_NeedAllowLabel:SetText("审核加入")
	else
		self.m_NeedAllowLabel:SetText("自由加入")
	end
	self.m_PowerLimitLabel:SetText("战力要求：" .. g_OrgCtrl.m_Org.powerlimit)
end

function COrgApproveView.CreateInfoBox(self)
	local oInfoBox = self.m_InfoBox:Clone()
	oInfoBox.m_NameLabel = oInfoBox:NewUI(1, CLabel)
	oInfoBox.m_GradeLabel = oInfoBox:NewUI(2, CLabel)
	oInfoBox.m_SchoolSprite = oInfoBox:NewUI(3, CSprite)
	oInfoBox.m_PowerLabel = oInfoBox:NewUI(4, CLabel)
	oInfoBox.m_ApplyTimeLabel = oInfoBox:NewUI(5, CLabel)
	oInfoBox.m_AgreeBtn = oInfoBox:NewUI(6, CButton)
	oInfoBox.m_RejectBtn = oInfoBox:NewUI(7, CButton)
	oInfoBox.m_OnSelectMark = oInfoBox:NewUI(8, CSprite)

	self.m_InfoGrid:AddChild(oInfoBox)
	oInfoBox:AddUIEvent("click", callback(self, "OnSelect", oInfoBox))
	oInfoBox.m_AgreeBtn:AddUIEvent("click", callback(self, "OnClickAgree", oInfoBox))
	oInfoBox.m_RejectBtn:AddUIEvent("click", callback(self, "OnClickReject", oInfoBox))
	
	function oInfoBox.SetData(self, oData, now)
		oInfoBox:SetActive(true)
		oInfoBox.m_Data = oData
		oInfoBox.m_NameLabel:SetText(oData.name)
		oInfoBox.m_GradeLabel:SetText(tostring(oData.grade))
		oInfoBox.m_SchoolSprite:SpriteSchool(oData.school)
		oInfoBox.m_PowerLabel:SetText(tostring(oData.power))
		oInfoBox.m_ApplyTimeLabel:SetText(g_OrgCtrl:GetApplyTime(oData.apply_time, now))
	end

	return oInfoBox
end

function COrgApproveView.OnSelect(self, oInfoBox)
	if self.m_CurrentSelect ~= nil then
		self.m_CurrentSelect.m_OnSelectMark:SetActive(false)
	end
	self.m_CurrentSelect = oInfoBox
	self.m_CurrentSelect.m_OnSelectMark:SetActive(true)
end

function COrgApproveView.OnClickAgree(self, oInfoBox)
	-- printc("OnClickAgree" .. oInfoBox.m_Data.pid)
	netorg.C2GSOrgDealApply(oInfoBox.m_Data.pid, COrgCtrl.AgreeApply)
end

function COrgApproveView.OnClickReject(self, oInfoBox)
	-- printc("OnClickReject" .. oInfoBox.m_Data.pid)
	netorg.C2GSOrgDealApply(oInfoBox.m_Data.pid, COrgCtrl.RejectApply)
end

function COrgApproveView.OnClickRejectAll(self)
	-- printc("OnClickRejectAll")
	netorg.C2GSRejectAllApply()
end

function COrgApproveView.OnClickInvite(self)
	if g_OrgCtrl:GetPosition(g_AttrCtrl.org_pos).broadcast == COrgCtrl.Has_Power then
		COrgSpreadView:ShowView()
	else
		g_NotifyCtrl:FloatMsg("仅会长和副会长可发布招募信息")
	end
end

function COrgApproveView.OnClickSetting(self)
	self.m_SettingBox:SetData()
end

function COrgApproveView.OnHideSetting(self)
	self.m_SettingBox:SetActive(false)
end

function COrgApproveView.OnClickSave(self)
	local powerlimit = tonumber(self.m_SettingBox.m_Input:GetText()) or 0
	if powerlimit > 0 then
		powerlimit = math.floor(powerlimit)
	end

	if self.m_SettingBox.m_FreeJoinBtn:GetSelected() then
		g_OrgCtrl:ChangeLimit(powerlimit, COrgCtrl.Dont_Need_Allow)
	else
		g_OrgCtrl:ChangeLimit(powerlimit, COrgCtrl.Need_Allow)
	end
end

function COrgApproveView.OnInputChange(self)
	local str = string.sub(self.m_SettingBox.m_Input:GetText(), 1, 1)
	if str == "0" or str == "-" then
		self.m_SettingBox.m_Input:SetText(string.sub(self.m_SettingBox.m_Input:GetText(), 2, -1))
	end
end

function COrgApproveView.OnNotify(self, oCtrl)
	if oCtrl.m_EventID == define.Org.Event.DelMember then
		if oCtrl.m_EventData ~= g_AttrCtrl.pid then
			self:SetMemberLabelData()
		end
	elseif oCtrl.m_EventID == define.Org.Event.OnRejectAll then
		self:SetData()
	elseif oCtrl.m_EventID == define.Org.Event.OnChangeLimit then
		self:SetLimitData()
		self.m_SettingBox:SetActive(false)
	elseif oCtrl.m_EventID == define.Org.Event.OnDealApply then
		self:SetMemberLabelData()
		self.m_IDToInfoBox[oCtrl.m_EventData]:SetActive(false)
		self.m_InfoGrid:Reposition()
	elseif oCtrl.m_EventID == define.Org.Event.UpdateOrgInfo then
		self:SetMemberLabelData()
		self.m_SpreadLabel:BeginCountDown(g_OrgCtrl:GetSpreadTime())
	end
end

function COrgApproveView.OnClickSort(self, sortList)
	self.m_CurSortList = sortList
	self:SetData()
	self.m_CurSortList.bReverse = not self.m_CurSortList.bReverse
end

return COrgApproveView