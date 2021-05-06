local CTeamSettingPage = class("CTeamSettingPage", CPageBase)

function CTeamSettingPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CTeamSettingPage.OnInitPage(self)
	self.m_Grid = self:NewUI(2, CGrid)
	self.m_TitleLabel = self:NewUI(3, CLabel)
	self.m_AllyCmdGrid = self:NewUI(4, CGrid)
	self.m_EnemyCmdGrid = self:NewUI(5, CGrid)
	self:InitContent()
end

function CTeamSettingPage.InitContent(self)
	self.m_Grid:InitChild(function (obj, index)
		local oBox = CBox.New(obj)
		return oBox
	end)
	self.m_AllyCmdGrid:InitChild(function (obj, index)
		local oBox = CBox.New(obj)
		oBox.m_CmdLabel = oBox:NewUI(1, CLabel)
		return oBox
	end)
		self.m_EnemyCmdGrid:InitChild(function (obj, index)
		local oBox = CBox.New(obj)
		oBox.m_CmdLabel = oBox:NewUI(1, CLabel)
		return oBox
	end)
	
	local setTable = 
	{
		{key = "队伍弹幕", value = g_TeamCtrl.m_TeamSet.AutoChatScreen },
		{key = "自动同意好友组队邀请", value = g_TeamCtrl.m_TeamSet.AutoAgreedFriendApply},
		{key = "队伍玩家离队，自动开启组队匹配", value = g_TeamCtrl.m_TeamSet.AutoReInvite},
	}
	for k, v in pairs(setTable) do
		local oBox = self.m_Grid:GetChild(k)
		oBox.m_KeyLabel = oBox:NewUI(1, CLabel)
		oBox.m_OnBtn = oBox:NewUI(2, CButton)
		oBox.m_OffBtn = oBox:NewUI(3, CButton)
		oBox.m_OnBtn:SetGroup(oBox:GetInstanceID())
		oBox.m_OffBtn:SetGroup(oBox:GetInstanceID())
		oBox.m_KeyLabel:SetText(v.key)
		oBox.m_OnBtn:SetActive(v.value)
		oBox.m_OffBtn:SetActive(not v.value)
		oBox.m_OnBtn:AddUIEvent("click", callback(self, "OnToggle", "Key"..tostring(k), "On", oBox))
		oBox.m_OffBtn:AddUIEvent("click", callback(self, "OnToggle", "Key"..tostring(k), "Off", oBox))
	end
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAttrEvent"))

	self:RefreshCmdGrid()
end

function CTeamSettingPage.OnCtrlAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		if oCtrl.m_EventData["dAttr"] and oCtrl.m_EventData["dAttr"]["bcmd"] then
			self:RefreshCmdGrid()
		end
	end
end

function CTeamSettingPage.OnToggle(self, sKey, isOn, oBox)
	if sKey == "Key1" then
		if isOn	== "Off" then
			g_TeamCtrl.m_TeamSet.AutoChatScreen = true
		else
			g_TeamCtrl.m_TeamSet.AutoChatScreen = false
		end
	elseif sKey == "Key2" then
		if isOn	== "Off" then
			g_TeamCtrl.m_TeamSet.AutoAgreedFriendApply = true
		else
			g_TeamCtrl.m_TeamSet.AutoAgreedFriendApply = false
		end
	elseif sKey == "Key3" then
		if isOn	== "Off" then
			g_TeamCtrl.m_TeamSet.AutoReInvite = true
		else
			g_TeamCtrl.m_TeamSet.AutoReInvite = false
		end
	end
	g_TeamCtrl:C2GSChangeTeamSetting()
	if oBox and oBox.m_OnBtn and oBox.m_OffBtn then
		oBox.m_OnBtn:SetActive(isOn	== "Off")
		oBox.m_OffBtn:SetActive(isOn ~= "Off")
	end
end

function CTeamSettingPage.RefreshCmdGrid(self)
	local lCmd = g_AttrCtrl:GetBattleCmd(true)
	for i,oBox in ipairs(self.m_AllyCmdGrid:GetChildList()) do
		local d = lCmd[i]
		if d then
			oBox.m_Cmd = d.cmd
			oBox.m_Idx = d.idx
			oBox.m_CmdLabel = oBox:NewUI(1, CLabel)
			local txt = "+"
			if oBox.m_Cmd and oBox.m_Cmd ~= "" then
				txt = oBox.m_Cmd
			end
			oBox.m_CmdLabel:SetText(txt)
			oBox:SetActive(true)
			oBox:AddUIEvent("click", callback(self, "OnCmdBox", true))
			self.m_AllyCmdGrid:AddChild(oBox)
		end
	end
	self.m_AllyCmdGrid:Reposition()

	local lCmd = g_AttrCtrl:GetBattleCmd(false)
	for i,oBox in ipairs(self.m_EnemyCmdGrid:GetChildList()) do
		local d = lCmd[i]
		if d then
			oBox.m_Cmd = d.cmd
			oBox.m_Idx = d.idx
			oBox.m_CmdLabel = oBox:NewUI(1, CLabel)
			local txt = "+"
			if oBox.m_Cmd and oBox.m_Cmd ~= "" then
				txt = oBox.m_Cmd
			end
			oBox.m_CmdLabel:SetText(txt)
			oBox:SetActive(true)
			oBox:AddUIEvent("click", callback(self, "OnCmdBox", false))
			self.m_EnemyCmdGrid:AddChild(oBox)
		end
	end
	self.m_EnemyCmdGrid:Reposition()
end

function CTeamSettingPage.OnCmdBox(self, bAlly, oBox)
	CTeamCommandChangeView:ShowView(function (oView)
		oView:SetData(bAlly, oBox.m_Idx)
	end)
end

function CTeamSettingPage.Destroy(self )
	g_TeamCtrl:C2GSChangeTeamSetting()
end

return CTeamSettingPage