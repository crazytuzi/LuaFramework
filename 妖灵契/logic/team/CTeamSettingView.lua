local CTeamSettingView = class("CTeamSettingView", CViewBase)

function CTeamSettingView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Team/TeamSettingView.prefab", cb)
	self.m_ExtendClose = "ClickOut"
end

function CTeamSettingView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_Grid = self:NewUI(2, CGrid)
	self.m_TitleLabel = self:NewUI(3, CLabel)
	self.m_TeamOrderBtn = self:NewUI(4, CButton)
	self:InitContent()
end

function CTeamSettingView.InitContent(self)
	self.m_Grid:InitChild(function (obj, index)
		local oBox = CBox.New(obj)
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
	self.m_TeamOrderBtn:AddUIEvent("click", callback(self, "OnTeamOrderBtn"))
end

function CTeamSettingView.OnTeamOrderBtn(self, oBtn)
	CTeamCommandView:ShowView()
end

function CTeamSettingView.OnToggle(self, sKey, isOn, oBox)
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
	if oBox and oBox.m_OnBtn and oBox.m_OffBtn then
		oBox.m_OnBtn:SetActive(isOn	== "Off")
		oBox.m_OffBtn:SetActive(isOn ~= "Off")
	end
end

function CTeamSettingView.Destroy(self )
	g_TeamCtrl:C2GSChangeTeamSetting()
	CViewBase.Destroy(self)
end

return CTeamSettingView