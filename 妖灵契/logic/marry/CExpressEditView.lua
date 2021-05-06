local CExpressEditView = class("CExpressEditView", CViewBase)

function CExpressEditView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Marry/ExpressEditView.prefab", cb)
	self.m_ExtendClose = "Black"
	-- self.m_GroupName = "main"
	-- self.m_DepthType = "Login"  --层次
end

function CExpressEditView.OnCreateView(self)
	self.m_OkBtn = self:NewUI(1, CButton)
	self.m_SaveBtn = self:NewUI(2, CButton)
	self.m_Input = self:NewUI(3, CInput)
	self.m_CountLabel = self:NewUI(4, CLabel)
	self.m_RefreshBtn = self:NewUI(5, CButton)
	self.m_ScrollView = self:NewUI(6, CScrollView)
	self:InitContent()
end

function CExpressEditView.InitContent(self)
	self.m_RandomIdx = 1
	self.m_MaxCount = data.marrydata.Rule[1].max_len
	self.m_MinCount = data.marrydata.Rule[1].min_len
	self.m_MaxIdx = #data.marrydata.DefaultText
	self.m_OkBtn:AddUIEvent("click", callback(self, "OnOkBtn"))
	self.m_SaveBtn:AddUIEvent("click", callback(self, "OnSaveBtn"))
	self.m_RefreshBtn:AddUIEvent("click", callback(self, "OnRefresh"))
	self.m_Input:AddUIEvent("change", callback(self, "OnInputChange"))
	self.m_Input:SetDefaultText(string.format("点击即可编辑表白宣言。(最少%s字符，最多%s字符内)", self.m_MinCount, self.m_MaxCount))
	self.m_Input:SetText(g_MarryCtrl:GetDefaultText())
	self:OnInputChange()
end

function CExpressEditView.OnInputChange(self)
	self.m_CurrentCount = #CMaskWordTree:GetCharList(self.m_Input:GetText())
	self.m_CountLabel:SetText(string.format("%s/%s", self.m_CurrentCount, self.m_MaxCount))
end

function CExpressEditView.OnOkBtn(self)
	if self.m_CurrentCount > self.m_MaxCount then
		g_NotifyCtrl:FloatMsg(string.format("字数超出%s", self.m_MaxCount))
	elseif self.m_CurrentCount < self.m_MinCount then
		g_NotifyCtrl:FloatMsg(string.format("字数小于%s", self.m_MinCount))
	else
		local sMaskWord = g_MaskWordCtrl:GetMaskWord(self.m_Input:GetText())
		if sMaskWord then
			g_NotifyCtrl:FloatMsg(string.format("输入内容中含有屏蔽字:%s", sMaskWord))
		else
			nethuodong.C2GSSendExpress(self.m_Input:GetText())
			self:OnClose()
		end
	end
end

function CExpressEditView.OnSaveBtn(self)
	if self.m_CurrentCount > self.m_MaxCount then
		g_NotifyCtrl:FloatMsg(string.format("字数超出%s", self.m_MaxCount))
	elseif self.m_CurrentCount < self.m_MinCount then
		g_NotifyCtrl:FloatMsg(string.format("字数小于%s", self.m_MinCount))
	else
		local sMaskWord = g_MaskWordCtrl:GetMaskWord(self.m_Input:GetText())
		if sMaskWord then
			g_NotifyCtrl:FloatMsg(string.format("输入内容中含有屏蔽字:%s", sMaskWord))
		else
			g_MarryCtrl:SaveEdit(self.m_Input:GetText())
			CExpressAniView:ShowView(function (oView)
				oView:ShowPreView(self.m_Input:GetText())
			end)
		end
	end
end

function CExpressEditView.OnRefresh(self)
	if g_WindowTipCtrl:IsShowTips("edit_couple_tip") then
		CExpressEditTipsView:ShowView(function (oView)
			oView:SetCb(callback(self, "RefreshEdit"))
		end)
	else
		self:RefreshEdit()
	end
	self.m_ScrollView:ResetPosition()
end

function CExpressEditView.RefreshEdit(self)
	self.m_RandomIdx = self.m_RandomIdx + 1
	if self.m_RandomIdx > self.m_MaxIdx then
		self.m_RandomIdx = 1
	end
	self.m_Input:SetText(data.marrydata.DefaultText[self.m_RandomIdx].text)
end

return CExpressEditView