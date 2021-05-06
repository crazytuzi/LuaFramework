local CTaskChatHud = class("CTaskChatHud", CAsyncHud)

function CTaskChatHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/TaskChatHud.prefab", cb, true)
end

function CTaskChatHud.OnCreateHud(self)
	self.m_MsgLabel = self:NewUI(1, CLabel)
	self.m_BgSpr = self:NewUI(2, CSprite)
	self.m_MsgList = {}
	self.m_Idx = 1
	self.m_UpdateTimer = nil
end

function CTaskChatHud.SetMsg(self, msg)
	if self.m_UpdateTimer then
		Utils.DelTimer(self.m_UpdateTimer)
		self.m_UpdateTimer = nil
	end
	if msg and next(msg) then
		self.m_MsgLabel:SetActive(true)	
		self.m_MsgList = msg
		self.m_Idx = 1
		self.m_MsgLabel:SetText(self.m_MsgList[1])
		self:ResizeBg(self.m_MsgList[1])
		if #msg > 1 then			
			self.m_UpdateTimer = Utils.AddTimer(callback(self, "Update"), 2, 2)
		else
			self.m_UpdateTimer = Utils.AddTimer(callback(self, "DelayHide"), 0, 2)
		end
	else
		self.m_MsgLabel:SetActive(false)
		self.m_BgSpr:SetActive(false)
	end
end

function CTaskChatHud.DelayHide(self)
	self.m_MsgLabel:SetActive(false)
	self.m_BgSpr:SetActive(false)
end

function CTaskChatHud.Update(self)
	if Utils.IsNil(self) then
		return
	end
	self.m_Idx = self.m_Idx + 1
	if self.m_Idx > #self.m_MsgList then
		self:DelayHide()
		return false
	end
	self.m_MsgLabel:SetText(self.m_MsgList[self.m_Idx])
	self:ResizeBg(self.m_MsgList[self.m_Idx])
	return true
end

function CTaskChatHud.Destroy(self)
	if self.m_UpdateTimer then
		Utils.DelTimer(self.m_UpdateTimer)
		self.m_UpdateTimer = nil
	end
	CObject.Destroy(self)
end

function CTaskChatHud.ResizeBg(self, text)
	local w, h = self.m_MsgLabel:GetSize()
	local offseth = 0
	if text then
		local _, sText = self.m_MsgLabel:Wrap(text)
		local textList = string.split(sText, "\n")
		sText = textList[#textList]
		if sText then
			local size1 = self.m_MsgLabel:CalculatePrintedSize("好")
			local size2 = self.m_MsgLabel:CalculatePrintedSize(sText)
			offseth = size2.y - size1.y
		end
		
	end
	local iw, ih = w + 36, h + 22
	if offseth > 0 then
		self.m_BgSpr:SetLocalPos(Vector3.New(0, offseth/2, 0))
		self.m_BgSpr:SetSize(iw, ih + offseth/2)
	else
		self.m_BgSpr:SetLocalPos(Vector3.New(0, 0, 0))
		self.m_BgSpr:SetSize(iw, ih)
	end
	self.m_BgSpr:ReActive()
end

return CTaskChatHud
