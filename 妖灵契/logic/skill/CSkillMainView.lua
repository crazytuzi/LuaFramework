local CSkillMainView = class("CSkillMainView", CViewBase)

CSkillMainView.EnumPage =
{
	SchoolPage = 1,
	CultivatePage = 2,
}

function CSkillMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Skill/SkillMainView.prefab", cb)
	--界面设置
	--self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
	self.m_TabIndex = CSkillMainView.EnumPage.SchoolPage
end

function CSkillMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_TabGrid = self:NewUI(2, CGrid)
	self.m_SchoolPage = self:NewPage(3, CSkillSchoolPage)
	self.m_CultivationPage = self:NewPage(4, CSkillCultivatePage)

	self:InitContent()
end

function CSkillMainView.InitContent(self)

	self.m_TabGrid:InitChild(function (obj, index)
		local oBox = CBox.New(obj)
		oBox:SetGroup(self.m_TabGrid:GetInstanceID())
		oBox:AddUIEvent("click", callback(self, "OnClick", "SwitchTab", index))

		--判断修炼系统是否开启
		if index == CSkillMainView.EnumPage.CultivatePage then
			if data.globalcontroldata.GLOBAL_CONTROL.cultivate_skill.is_open == "y" then
				oBox:SetActive(true)
			else
				oBox:SetActive(false)
			end	
		end

		return oBox
	end)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClickClose"))

	self:ShowSchoolPage()
end


function CSkillMainView.ShowSchoolPage(self)
	self.m_TabGrid:GetChild(CSkillMainView.EnumPage.SchoolPage):SetSelected(true)
	self:ShowSubPage(self.m_SchoolPage)
end

function CSkillMainView.ShowCultivatePage(self)
	self.m_TabGrid:GetChild(CSkillMainView.EnumPage.CultivatePage):SetSelected(true)
	self:ShowSubPage(self.m_CultivationPage)
end

function CSkillMainView.OnClick(self, sKey, index)
	if sKey == "SwitchTab" then
		if index == CSkillMainView.EnumPage.CultivatePage then			
			if data.globalcontroldata.GLOBAL_CONTROL.cultivate_skill.is_open == "y" then
				self.m_TabIndex = CSkillMainView.EnumPage.CultivatePage
				self:ShowCultivatePage()
			else
				g_NotifyCtrl:FloatMsg("该功能正在维护，已临时关闭，请您留意官网相关信息。")
			end			
		else 			
			if self.m_CultivationPage.m_IsAutoLearning then
				self.m_CultivationPage:OnStopAutoLearn()
			end	
			self.m_TabIndex = CSkillMainView.EnumPage.m_IsAutoLearning
			self:ShowSchoolPage()
		end
	end
end
	
function CSkillMainView.OnClickClose( self )
	--如果当前正在自动修炼，点击会提示，是否要关掉自动修炼	
	if self.m_TabIndex == CSkillMainView.EnumPage.CultivatePage and self.m_CultivationPage.m_IsAutoLearning  == true then
		local args = 
		{
			msg = string.format("正在自动修炼中，退出会停止自动修炼"),
			okCallback = function ()
				self.m_CultivationPage.m_IsOpenCloseWindow =  false
				self.m_CultivationPage:OnStopAutoLearn()
				CViewBase.OnClose(self)
			end,
			cancelCallback = function ()
				self.m_CultivationPage.m_IsOpenCloseWindow =  false
			end,
		}
		g_WindowTipCtrl:SetWindowConfirm(args)
		self.m_CultivationPage.m_IsOpenCloseWindow =  true
	else
		CViewBase.OnClose(self)
		self.m_CultivationPage.m_IsOpenCloseWindow =  false
	end
end

return CSkillMainView
