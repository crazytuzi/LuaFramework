local COrgMemberPage = class("COrgMemberPage", CPageBase)

function COrgMemberPage.ctor(self, cb)
	CPageBase.ctor(self, cb)
end

function COrgMemberPage.OnInitPage(self)
	self.m_WrapContent = self:NewUI(1, CWrapContent)
	self.m_InfoBox = self:NewUI(2, CBox)
	self.m_InfoHandlePart = self:NewUI(3, CBox)
	self.m_MemberLabel = self:NewUI(4, CLabel)
	self.m_HideOfflineBtn = self:NewUI(5, CBox)
	self.m_HideOffineMarkSprite = self:NewUI(6, CSprite)
	self.m_SortGradeBtn = self:NewUI(7, CBox)
	self.m_SortPowerBtn = self:NewUI(8, CBox)
	self.m_SortOfferBtn = self:NewUI(9, CBox)
	self.m_SortActiveBtn = self:NewUI(10, CBox)
	self.m_SortOfflineBtn = self:NewUI(11, CBox)
	self.m_PlayerSlot = self:NewUI(12, CBox)
	self.m_HelpBtn = self:NewUI(13, CButton)
	self.m_ScrollView = self:NewUI(14, CScrollView)

	self:InitContent()
end

function COrgMemberPage.InitContent(self)
	self.m_WrapContent:SetCloneChild(self.m_InfoBox, callback(self, "InitInfoBox"))
	
	self.m_WrapContent:SetRefreshFunc(function(oChild, oData)
		if oData and self.m_Data[oData] then
			oChild:SetData(self.m_Data[oData], g_TimeCtrl:GetTimeS(), oData)
			oChild.m_InfoBtn:SetActive(true)
		else
			oChild.m_InfoBtn:SetActive(false)
		end
	end)

	self.m_MemberLabel:SetText()
	self.m_HandleData = {
		{name = "查 看", callbackFunc = callback(self, "Look"), key = "Look"},
		{name = "添加好友", callbackFunc = callback(self, "AddFriend"), key = "AddFriend"},
		{name = "私 聊", callbackFunc = callback(self, "Talk"), key = "Talk"},
		{name = "踢出公会", callbackFunc = callback(self, "KickOut"), key = "KickOut"},
		{name = "任 命", callbackFunc = callback(self, "Appoint"), key = "Appoint"},
		{name = "禁 言", callbackFunc = callback(self, "BanChat"), key = "BanChat"},
	}
	self.m_SortList = {
		{btn = self.m_SortGradeBtn, list = g_OrgCtrl.m_MemberSortList.grade, bReverse = true},
		{btn = self.m_SortPowerBtn, list = g_OrgCtrl.m_MemberSortList.power, bReverse = true},
		{btn = self.m_SortOfferBtn, list = g_OrgCtrl.m_MemberSortList.org_offer, bReverse = true},
		{btn = self.m_SortActiveBtn, list = g_OrgCtrl.m_MemberSortList.active_point, bReverse = true},
		{btn = self.m_SortOfflineBtn, list = g_OrgCtrl.m_MemberSortList.offline, bReverse = true},
	}
	for i = 1, #self.m_SortList do
		self.m_SortList[i].btn:AddUIEvent("click", callback(self, "OnClickSort", self.m_SortList[i].list))
	end
	self.m_InfoBoxArr = {}
	self.m_IDToInfoBox = {}
	self.m_InfoHandleBox = self:CreateInfoHandleBox()
	self.m_PlayerBox = self:InitInfoBox(self.m_InfoBox:Clone())
	self.m_PlayerBox.m_InfoBtn.enabled = false
	self.m_PlayerBox:SetParent(self.m_PlayerSlot.m_Transform)
	self.m_PlayerBox:SetLocalPos(Vector3.zero)
	self:HideHandleBox()
	self:SetMemberLabelData()
	self.m_HelpBtn:AddUIEvent("click", callback(self, "OnClickHelp"))
	self.m_HideOfflineBtn:AddUIEvent("click", callback(self, "OnClickHide"))
	g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))
end

function COrgMemberPage.OnClickHelp(self)
	CHelpView:ShowView(function (oView)
		oView:ShowHelp("orgmemberbuff")
	end)
end

function COrgMemberPage.OnShowPage(self)
	self.m_CurSortList = g_OrgCtrl.m_MemberSortList.default
end

function COrgMemberPage.OnClickHide(self)
	self.m_HideOffineMarkSprite:SetActive(not self.m_HideOffineMarkSprite:GetActive())
	self:SetData(true)
end

function COrgMemberPage.SetMemberLabelData(self)
	self.m_MemberLabel:SetText(string.format("公会成员:%d/%d", g_OrgCtrl:GetMyOrgInfo().memcnt, g_OrgCtrl:GetMaxMember(g_OrgCtrl:GetMyOrgInfo().level)))
end

function COrgMemberPage.BanChat(self)
	netorg.C2GSBanChat(self.m_InfoHandleBox.m_Data.pid, self.m_InfoHandleBox.m_Data.inbanchat and COrgCtrl.OpenChat or COrgCtrl.BanChat)
end

function COrgMemberPage.Look(self)
	g_NotifyCtrl:FloatMsg("该功能暂未开放")
	-- netfriend.C2GSTakeDocunment(self.m_InfoHandleBox.m_Data.pid)
end

function COrgMemberPage.AddFriend(self)
	if g_FriendCtrl:IsMyFriend(self.m_InfoHandleBox.m_Data.pid) then
		netfriend.C2GSDeleteFriend(self.m_InfoHandleBox.m_Data.pid)
	else
		g_FriendCtrl:ApplyFriend(self.m_InfoHandleBox.m_Data.pid)
	end
end

function COrgMemberPage.Flower(self)
	printc("Flower")
	g_NotifyCtrl:FloatMsg("该功能暂未开放")
end

function COrgMemberPage.Talk(self)
	CFriendMainView:ShowView(function (oView)
		oView:ShowTalk(self.m_InfoHandleBox.m_Data.pid)
	end) 
end

function COrgMemberPage.Pk(self)
	g_NotifyCtrl:FloatMsg("该功能暂未开放")	
	--if g_ActivityCtrl:ActivityBlockContrl("pk") then
		-- netplayer.C2GSPlayerPK(self.m_InfoHandleBox.m_Data.pid)	
	--end
end

function COrgMemberPage.KickOut(self)
	local windowConfirmInfo = {
		msg = string.format("是否将玩家#G%s#n踢出公会？", self.m_InfoHandleBox.m_Data.name),
		okStr = "确定",
		cancelStr = "取消",
		pivot = enum.UIWidget.Pivot.Center,
		okCallback = function()
			netorg.C2GSKickMember(self.m_InfoHandleBox.m_Data.pid)
		end
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function COrgMemberPage.Appoint(self)
	self.m_InfoHandleBox.m_AppointPart:SetActive(true)
	local w, h = self.m_InfoHandleBox.m_BgSprite:GetSize()
	local pos = self.m_InfoHandleBox.m_BgSprite:GetLocalPos()
	local basePos = self.m_InfoHandleBox.m_AppointPart:GetLocalPos()
	if pos.y < 0 then
		self.m_InfoHandleBox.m_AppointPart:SetLocalPos(Vector3.New(basePos.x, 184, basePos.z))
	else
		self.m_InfoHandleBox.m_AppointPart:SetLocalPos(Vector3.New(basePos.x, -73, basePos.z))
	end
end

function COrgMemberPage.SetPosition(self, posid)
	if posid == define.Org.Pos.HuiZhang then
		if g_QQPluginCtrl:HasBindQQGroup() and g_QQPluginCtrl:IsRelation(define.QQPlugin.Relation.QunZhu) then
			g_NotifyCtrl:FloatMsg("解绑Q群后才可转移会长")
			return
		end
		local windowConfirmInfo = {
			msg = string.format("是否将会长转移给#B%s#n？", self.m_InfoHandleBox.m_Data.name),
			okStr = "确定",
			cancelStr = "取消",
			pivot = enum.UIWidget.Pivot.Center,
			okCallback = function()
				netorg.C2GSOrgSetPosition(self.m_InfoHandleBox.m_Data.pid, posid)
			end
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	else
		netorg.C2GSOrgSetPosition(self.m_InfoHandleBox.m_Data.pid, posid)
	end
end


function COrgMemberPage.CreateInfoHandleBox(self)
	local oInfoHandleBox = self.m_InfoHandlePart
	oInfoHandleBox.m_InfoGrid = oInfoHandleBox:NewUI(1, CGrid)
	oInfoHandleBox.m_InfoBtn = oInfoHandleBox:NewUI(2, CButton)
	oInfoHandleBox.m_AppointPart = oInfoHandleBox:NewUI(3, CBox)
	oInfoHandleBox.m_AppointGrid = oInfoHandleBox:NewUI(4, CGrid)
	oInfoHandleBox.m_AppointBtn = oInfoHandleBox:NewUI(5, CButton)
	oInfoHandleBox.m_CloseBtn = oInfoHandleBox:NewUI(6, CBox)
	oInfoHandleBox.m_BgSprite = oInfoHandleBox:NewUI(7, CSprite)

	oInfoHandleBox.m_CloseBtn:AddUIEvent("click", callback(self, "HideHandleBox"))
	oInfoHandleBox.m_HandleBtnDic = {}
	oInfoHandleBox.m_AppointHandleArr = {}
	oInfoHandleBox.m_InfoCellW, oInfoHandleBox.m_InfoCellH = oInfoHandleBox.m_InfoGrid:GetCellSize()
	oInfoHandleBox.m_AppointCellW, oInfoHandleBox.m_AppointCellH = oInfoHandleBox.m_AppointGrid:GetCellSize()

	for i=1, #self.m_HandleData do
		oInfoHandleBox.m_HandleBtnDic[self.m_HandleData[i].key] = oInfoHandleBox.m_InfoBtn:Clone()
		oInfoHandleBox.m_InfoGrid:AddChild(oInfoHandleBox.m_HandleBtnDic[self.m_HandleData[i].key])
		oInfoHandleBox.m_HandleBtnDic[self.m_HandleData[i].key]:SetText(self.m_HandleData[i].name)
		if self.m_HandleData[i].callbackFunc ~= nil then
			oInfoHandleBox.m_HandleBtnDic[self.m_HandleData[i].key]:AddUIEvent("click", self.m_HandleData[i].callbackFunc)
		end
	end
	--tzq隐藏未完成功能
	oInfoHandleBox.m_HandleBtnDic["Look"]:SetActive(false)
	for k,v in ipairs(data.orgdata.MemberLimit) do
		if v.auto_appoint ~= COrgCtrl.Auto_Appoint then
			oInfoHandleBox.m_AppointHandleArr[k] = oInfoHandleBox.m_AppointBtn:Clone()
			oInfoHandleBox.m_AppointGrid:AddChild(oInfoHandleBox.m_AppointHandleArr[k])
			oInfoHandleBox.m_AppointHandleArr[k]:SetText(v.pos)
			oInfoHandleBox.m_AppointHandleArr[k]:AddUIEvent("click", callback(self, "SetPosition", v.posid))
		end
	end

	oInfoHandleBox.m_InfoBtn:SetActive(false)
	oInfoHandleBox.m_AppointBtn:SetActive(false)
	function oInfoHandleBox.SetData(self, oData, oInfoBox)
		oInfoHandleBox.m_Data = oData
		local limitData = g_OrgCtrl:GetPosition(g_AttrCtrl.org_pos)
		oInfoHandleBox:SetActive(true)
		oInfoHandleBox.m_AppointPart:SetActive(false)
		local posList = limitData.authorize_pos
		local init = false
		for k,v in pairs(posList) do
			if v == oInfoBox.m_Data.position then
				init = true
			end
		end
		if init then
			for k,v in pairs(oInfoHandleBox.m_AppointHandleArr) do
				v:SetActive(false)
			end
			local btnCount = 0
			for i = 1, #limitData.target_pos do
				btnCount = btnCount + 1
				if oInfoHandleBox.m_AppointHandleArr[limitData.target_pos[i]] ~= nil then
					oInfoHandleBox.m_AppointHandleArr[limitData.target_pos[i]]:SetActive(true)
				end
			end
			oInfoHandleBox.m_AppointPart:SetHeight(20 + oInfoHandleBox.m_AppointCellH * btnCount)
			--显示任命按钮
			oInfoHandleBox.m_HandleBtnDic["Appoint"]:SetActive(true)
		else
			--任命按钮不显示
			oInfoHandleBox.m_HandleBtnDic["Appoint"]:SetActive(false)
		end
		--踢出按钮
		oInfoHandleBox.m_HandleBtnDic["KickOut"]:SetActive(false)
		if #limitData.del_pos > 0 then
			for k,v in pairs(limitData.del_pos) do
				if v == oData.position then
					oInfoHandleBox.m_HandleBtnDic["KickOut"]:SetActive(true)
					break
				end
			end
		end
		--禁言
		oInfoHandleBox.m_HandleBtnDic["BanChat"]:SetActive(limitData.ban_chat == COrgCtrl.Has_Power)
		oInfoHandleBox.m_HandleBtnDic["BanChat"]:SetText(oInfoHandleBox.m_Data.inbanchat and "解 禁" or "禁 言")
		--好友按钮
		if g_FriendCtrl:IsMyFriend(oInfoHandleBox.m_Data.pid) then
			oInfoHandleBox.m_HandleBtnDic["AddFriend"]:SetText("删除好友")
		else
			oInfoHandleBox.m_HandleBtnDic["AddFriend"]:SetText("加为好友")
		end
		local infoBtnCount = 0
		for k,v in pairs(oInfoHandleBox.m_HandleBtnDic) do
			if v:GetActive() then
				infoBtnCount = infoBtnCount + 1
			end
		end
		oInfoHandleBox.m_BgSprite:SetHeight(20 + oInfoHandleBox.m_InfoCellH * math.ceil(infoBtnCount/2))
		if oInfoBox then
			UITools.NearTarget(oInfoBox, oInfoHandleBox.m_BgSprite, enum.UIAnchor.Side.Center, Vector2.New(0, -20), true)
		end
		oInfoHandleBox.m_InfoGrid:Reposition()
		oInfoHandleBox.m_AppointGrid:Reposition()
	end
	
	return oInfoHandleBox
end

function COrgMemberPage.SetData(self, bSort)
	self.m_Data = g_OrgCtrl:GetMemberSortList(self.m_CurSortList, self.m_CurSortList.bReverse)
	local hideOffline = self.m_HideOffineMarkSprite:GetActive()
	local now = g_TimeCtrl:GetTimeS()
	local count = 0
	local lIndex = {}
	for i,v in ipairs(self.m_Data) do
		if v ~= nil and ((hideOffline and v.offline == 0) or (not hideOffline)) then
			table.insert(lIndex, i)
			count = count + 1
			if v.pid == g_AttrCtrl.pid then
				self.m_PlayerBox:SetData(v, now, count)
				self.m_PlayerBox.m_InfoBtn:SetSpriteName("")
			end
		end
	end
	self.m_InfoList = lIndex
	-- printc("SetData:" .. (bSort and "true" or "false"))
	-- table.print(lIndex, "lIndex-------------------->")
	-- table.print(self.m_Data, "self.m_Data-------------------->")
	self.m_WrapContent:SetData(lIndex, bSort)
	if bSort then
		self.m_ScrollView:ResetPosition()
	else
		self.m_WrapContent:Refresh()
	end
	self.m_InfoBox:SetActive(false)
end

function COrgMemberPage.InitInfoBox(self, oInfoBox)
	oInfoBox.m_PositionLabel = oInfoBox:NewUI(1, CLabel)
	oInfoBox.m_NameLabel = oInfoBox:NewUI(2, CLabel)
	oInfoBox.m_GradeLabel = oInfoBox:NewUI(3, CLabel)
	oInfoBox.m_SchoolSprite = oInfoBox:NewUI(4, CSprite)
	oInfoBox.m_PowerLabel = oInfoBox:NewUI(5, CLabel)
	oInfoBox.m_OfflineTimeLabel = oInfoBox:NewUI(6, CLabel)
	oInfoBox.m_ContributeLabel = oInfoBox:NewUI(7, CLabel)
	oInfoBox.m_InfoBtn = oInfoBox:NewUI(8, CSprite)
	oInfoBox.m_ActiveLabel = oInfoBox:NewUI(9, CLabel)
	oInfoBox.m_PositionBg = oInfoBox:NewUI(10, CSprite)

	oInfoBox.m_InfoBtn:AddUIEvent("click", callback(self, "OnClickInfo", oInfoBox))
	function oInfoBox.SetData(self, oData, now, idx)
		oInfoBox.m_Data = oData
		oInfoBox.m_InfoBtn:SetSpriteName("pic_rank_di0" .. ((idx + 1) % 2 + 1))
		oInfoBox.m_NameLabel:SetText(oData.name)
		oInfoBox.m_PositionLabel:SetText(g_OrgCtrl:GetPosition(oData.position).pos)
		oInfoBox.m_GradeLabel:SetText(tostring(oData.grade))
		oInfoBox.m_SchoolSprite:SpriteSchool(oData.school)
		oInfoBox.m_PowerLabel:SetText(tostring(oData.power))
		oInfoBox.m_OfflineTimeLabel:SetText(g_OrgCtrl:GetOfflineTime(oData.offline, now))
		oInfoBox.m_ContributeLabel:SetText(tostring(oData.org_offer))
		oInfoBox.m_ActiveLabel:SetText(tostring(oData.active_point))
		oInfoBox.m_PositionBg:SetSpriteName(g_OrgCtrl:GetPosition(oData.position).bg)
		local textColor = g_OrgCtrl:GetPosition(oData.position).text_color
		oInfoBox.m_PositionLabel:SetEffectColor(Color.New(textColor.r, textColor.g, textColor.b, 1))
	end
	return oInfoBox
end

function COrgMemberPage.OnClickInfo(self, oInfoBox)
	if oInfoBox.m_Data.pid ~= g_AttrCtrl.pid then
		self.m_InfoHandleBox:SetData(oInfoBox.m_Data, oInfoBox)
	end
end

function COrgMemberPage.HideHandleBox(self)
	self.m_InfoHandleBox:SetActive(false)
end

function COrgMemberPage.OnNotify(self, oCtrl)
	if oCtrl.m_EventID == define.Org.Event.DelMember then
		if oCtrl.m_EventData ~= g_AttrCtrl.pid then
			for i,v in ipairs(self.m_InfoList) do
				if self.m_Data[v].pid == oCtrl.m_EventData then
					table.remove(self.m_InfoList, i)
					break
				end
			end
			self.m_WrapContent:SetData(self.m_InfoList, false)
			self.m_WrapContent:Refresh()
			self:SetMemberLabelData()
		end
	elseif oCtrl.m_EventID == define.Org.Event.OnChangePos then
		self.m_WrapContent:Refresh()
		self.m_InfoHandleBox:SetActive(false)
	elseif oCtrl.m_EventID == define.Org.Event.UpdateOrgInfo then
		self:SetMemberLabelData()
	elseif oCtrl.m_EventID == define.Org.Event.OnUpdateMemberInfo then
		self:SetData(false)
		if self.m_InfoHandleBox:GetActive() then
			local oData = g_OrgCtrl:GetOrgMember(self.m_InfoHandleBox.m_Data.pid)
			if oData then
				self.m_InfoHandleBox:SetData(oData)
			end
		end
	end
end

function COrgMemberPage.OnClickSort(self, sortList)
	self.m_CurSortList = sortList
	self:SetData(false)
	self.m_CurSortList.bReverse = not self.m_CurSortList.bReverse
end

return COrgMemberPage