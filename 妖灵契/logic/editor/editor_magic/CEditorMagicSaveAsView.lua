local CEditorMagicSaveAsView = class("CEditorMagicSaveAsView", CViewBase)

function CEditorMagicSaveAsView.ctor(self, f)
	CViewBase.ctor(self, "UI/_Editor/EditorMagic/EditorMagicSaveAsView.prefab", f)
end

function CEditorMagicSaveAsView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ConfirmBtn = self:NewUI(2, CButton)
	self.m_IDInput = self:NewUI(3, CInput)
	self.m_IdxInput = self:NewUI(4, CInput)
	self.m_TypeBox = self:NewUI(5, CEditorNormalArgBox)
	self.m_TipsLabel = self:NewUI(6, CLabel)
	self.m_ConfirmFunc = nil
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnConfirm"))

	local oArgInfo = config.arg.template["magic_file"]
	self.m_TypeBox:SetArgInfo(oArgInfo)
	self.m_TypeBox:SetValueChangeFunc(callback(self, "OnTypeChange"))
	self.m_TypeBox:ResetDefault()
end

function CEditorMagicSaveAsView.OnTypeChange(self)
	local v = self.m_TypeBox:GetValue()
	if v == "magic" then
		self.m_IDInput:EnableTouch(true)
		self.m_IDInput:SetGrey(false)
		self.m_TipsLabel:SetText("请输入技能id，序号(1开始递增)")
	elseif v == "goback" then
		self.m_IDInput:SetText("99")
		self.m_IDInput:EnableTouch(false)
		self.m_IDInput:SetGrey(true)
		self.m_TipsLabel:SetText("在第二个框输入模型编号")
	elseif v == "createrole" then
		self.m_IDInput:SetText("98")
		self.m_IDInput:EnableTouch(false)
		self.m_IDInput:SetGrey(true)
		self.m_TipsLabel:SetText("在第二个框输入技能id")
		self.m_TipsLabel:SetText("在第二个框输入模型编号")
	elseif v == "dialogueani" then
		self.m_IDInput:SetText("96")
		self.m_IDInput:EnableTouch(false)
		self.m_IDInput:SetGrey(true)
		self.m_TipsLabel:SetText("在第二个框输入技能id")		
	end
end

function CEditorMagicSaveAsView.SetConfirmFunc(self, f)
	self.m_ConfirmFunc = f
end

function CEditorMagicSaveAsView.OnConfirm(self)
	if self.m_ConfirmFunc then
		local id = self.m_IDInput:GetText()
		local idx = self.m_IdxInput:GetText()
		local filename = string.format("magic_%s_%s.lua", id, idx)
		self.m_ConfirmFunc(filename)
	end
	self:CloseView()
end

return CEditorMagicSaveAsView