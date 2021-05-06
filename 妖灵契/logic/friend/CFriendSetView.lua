local CFriendSetView = class("CFriendSetView", CViewBase)

function CFriendSetView.ctor(self, cb)
	CViewBase.ctor(self, "UI/friend/FriendSetView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CFriendSetView.OnCreateView(self)
	--self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_MsgAmountInput = self:NewUI(2, CInput)
	self.m_MsgBox = self:NewUI(3, CBox)
	self.m_ApplyAmountInput = self:NewUI(4, CInput)
	self.m_ApplyBox = self:NewUI(5, CBox)
	self.m_ResponseBox = self:NewUI(6, CBox)
	self.m_ResponseInput = self:NewUI(7, CInput)
	self.m_NotifyBox = self:NewUI(8, CBox)
	self.m_TipBtn = self:NewUI(9, CButton)
	self:InitContent()
end

function CFriendSetView.InitContent(self)
	local setting = g_FriendCtrl:GetFriendSetting()
	
	--self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_TipBtn:AddHelpTipClick("haoyou")
	self:InitSwithchBox(self.m_NotifyBox, setting.notify == 1)
	self:InitSwithchBox(self.m_MsgBox, setting.strange_chat == 1)
	self:InitSwithchBox(self.m_ApplyBox, setting.apply_switch == 1)
	self:InitSwithchBox(self.m_ResponseBox, setting.respond_switch == 1)
	self.m_MsgAmountInput:SetText(tostring(setting.strange_grade))
	self.m_ApplyAmountInput:SetText(tostring(setting.apply_grade))
	self.m_ResponseInput:SetText(tostring(setting.auto_response))
	
	self.m_MsgAmountInput:AddUIEvent("change", callback(self, "OnInputChange"))
	self.m_ApplyAmountInput:AddUIEvent("change", callback(self, "OnInputChange"))
end

function CFriendSetView.InitSwithchBox(self, box, bopen)
	box.m_OpenBtn = box:NewUI(1, CBox)
	box.m_CloseBtn = box:NewUI(2, CBox)
	box.m_OpenBtn:SetGroup(box:GetInstanceID())
	box.m_CloseBtn:SetGroup(box:GetInstanceID())
	local function func()
		if box.m_OpenBtn:GetSelected() then
			box.m_OpenBtn:SetDepth(49)
			box.m_CloseBtn:SetDepth(50)
		else
			box.m_OpenBtn:SetDepth(50)
			box.m_CloseBtn:SetDepth(49)
		end
	end
	if bopen then
		box.m_CloseBtn:SetSelected(true)
	else
		box.m_OpenBtn:SetSelected(true)
	end
	box.m_OpenBtn:AddUIEvent("click", func)
	box.m_CloseBtn:AddUIEvent("click", func)
end

function CFriendSetView.GetSwitchState(self, box)
	if box.m_OpenBtn:GetSelected() then
		return 0
	else
		return 1
	end
end

function CFriendSetView.OnInputChange(self, inputObj)
	if tonumber(inputObj:GetText()) then
		if tonumber(inputObj:GetText()) > g_AttrCtrl.grade then
			inputObj:SetText(tostring(g_AttrCtrl.grade))
		elseif tonumber(inputObj:GetText()) < 0 then
			inputObj:SetText(tostring(0))
		end
	end
end

function CFriendSetView.CloseView(self)
	self:SaveSet()
	g_ViewCtrl:CloseView(self)
end

function CFriendSetView.SaveSet(self)
	local notify = self:GetSwitchState(self.m_NotifyBox)
	local strange_chat = self:GetSwitchState(self.m_MsgBox)
	local apply_switch = self:GetSwitchState(self.m_ApplyBox)
	local respond_switch = self:GetSwitchState(self.m_ResponseBox)

	local strange_grade = tonumber(self.m_MsgAmountInput:GetText())
	local apply_grade = tonumber(self.m_ApplyAmountInput:GetText())
	local auto_response = self.m_ResponseInput:GetText()
	auto_response = g_MaskWordCtrl:ReplaceMaskWord(auto_response)
	local t = {
		notify = notify,
		strange_chat = strange_chat,
		strange_grade = strange_grade,
		apply_switch = apply_switch,
		apply_grade = apply_grade,
		auto_response = auto_response,
		respond_switch = respond_switch,
	}
	netfriend.C2GSFriendSetting(t)
end 

return CFriendSetView