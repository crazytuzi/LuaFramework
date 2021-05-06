------------------------------------------------------------
--组队主界面


------------------------------------------------------------
local CTeamMainView = class("CTeamMainView", CViewBase)
CTeamMainView.Tab = 
{
	TeamMain = 1,
	HandyBuild = 2,
	TeamSetting = 3,
}

function CTeamMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Team/TeamMainView.prefab", cb)
	--界面设置
	--self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
	self.m_Tab = nil
end

function CTeamMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_MainPage = self:NewPage(2, CTeamMainPage)
	self.m_HandyBuildPage = self:NewPage(3, CTeamHandyBuildPage)
	self.m_TeamSettingPage = self:NewPage(4, CTeamSettingPage)
	self.m_TabGrid = self:NewUI(5, CGrid)
	self:InitContent()
end

function CTeamMainView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self:InitGrid()
	local guide_ui = {"teammain_handybuild_btn"}
	g_GuideCtrl:LoadTipsGuideEffect(guide_ui)
	g_GuideCtrl:FinishTeamHandyBuildTipsStep(2)
end

function CTeamMainView.InitGrid(self)
	self.m_TabGrid:InitChild(function (obj, index)
		local oBox = CBox.New(obj)
		oBox:SetGroup(self.m_TabGrid:GetInstanceID())
		oBox:AddUIEvent("click", callback(self, "OnSwitchPage", index, nil))
		if index == 2 then
			g_GuideCtrl:AddGuideUI("teammain_handybuild_btn", oBox)
		end
		return oBox
	end)
end

function CTeamMainView.OnSwitchPage(self, index, taskId)
	self.m_Tab = index
	if index == 2 then
		g_GuideCtrl:ReqTipsGuideFinish("teammain_handybuild_btn")		
	end
	local oBox = self.m_TabGrid:GetChild(index)
	if oBox then
		oBox:SetSelected(true)
	end
	self:ShowTeamPage(self.m_Tab, taskId)
end

function CTeamMainView.ShowTeamPage(self, page, taskId)
	page  = page or CTeamMainView.Tab.TeamMain
	if page == CTeamMainView.Tab.HandyBuild then
		self:ShowSubPage(self.m_HandyBuildPage, taskId)
	elseif page == CTeamMainView.Tab.TeamMain then
		self:ShowSubPage(self.m_MainPage)
		g_TeamCtrl:CtrlC2GSTeamCountInfo()
	elseif page == CTeamMainView.Tab.TeamSetting then
		self:ShowSubPage(self.m_TeamSettingPage)
	end
	if self.m_Tab == nil then
		self.m_Tab = page
		local oBox = self.m_TabGrid:GetChild(page)
		oBox:SetSelected(true)
	end
end

return CTeamMainView