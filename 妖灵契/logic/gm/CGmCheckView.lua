CGmCheckView = class("CGmCheckView", CViewBase)

function CGmCheckView.ctor(self, cb)
	CViewBase.ctor(self, "UI/gm/GMCheckView.prefab", cb)
end

function CGmCheckView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_RoleNameInput = self:NewUI(2, CInput)
	self.m_CheckBtn = self:NewUI(3, CButton)
	self.m_ResultLabel = self:NewUI(4, CLabel)

	self.m_ResultStr = "输出结果："
	self.m_ResultCount = 0
	self:InitContent()
end

function CGmCheckView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CheckBtn:AddUIEvent("click", callback(self, "OnCheckMaskWork"))
end

function CGmCheckView.Reset(self)
	self.m_ResultStr = "输出结果："
	self.m_ResultCount = 0
end

function CGmCheckView.AddAndShowResult(self, sText)
	self.m_ResultCount = self.m_ResultCount + 1
	local replaceResult = g_MaskWordCtrl:ReplaceMaskWord(sText)
	self.m_ResultStr = string.format("%s \n%d:%s-->%s", self.m_ResultStr, self.m_ResultCount, sText, replaceResult)
	self.m_ResultLabel:SetText(self.m_ResultStr)
end

function CGmCheckView.OnCheckMaskWork(self)
	self:Reset()
	local sRoleName = self.m_RoleNameInput:GetText()
	local result = string.split(sRoleName,"\n")
	for k,v in pairs(result) do
		if g_MaskWordCtrl:IsContainMaskWord(v) then
			self:AddAndShowResult(v)
		end
	end
end

return CGmCheckView