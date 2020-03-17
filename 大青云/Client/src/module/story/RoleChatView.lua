--[[头顶冒泡
liyuan
2014年9月28日10:33:06
]]

_G.UIRoleChat = BaseUI:new("UIRoleChat") 
UIRoleChat.npcRole = nil
UIRoleChat.chatText = ""
UIRoleChat.offsetX = 0
UIRoleChat.offsetY = 0
UIRoleChat.timerId = nil
UIRoleChat.lastTime = 5000

function UIRoleChat:Create()
	self:AddSWF("roleChatPanel.swf", true, "storyBottom")
end

function UIRoleChat:OnLoaded(objSwf,name)

end

function UIRoleChat:Update()
	if not self.bShowState then return end
	
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self.npcRole or not self.npcRole:GetAvatar() then 
		--FPrint('UIRoleChatHide3')
		self:Hide()
		return
	end
	if self.npcRole.IsHide then
		if self.npcRole:IsHide() then
			--FPrint('UIRoleChatHide4')
			self:Hide()
			return
		end
	end
	
	local talkPos = nil
	if self.npcRole and self.npcRole:GetAvatar() then
		talkPos = self.npcRole:GetNamePos()
	end
	if not talkPos then 
		--FPrint('UIRoleChatHide6')
		self:Hide() 
		return
	end
	-- --FPrint(talkPos.x..'#'..talkPos.y + 30)
	objSwf._x =talkPos.x + self.offsetX
	objSwf._y =talkPos.y + 30 + self.offsetY
	
end

function UIRoleChat:OnShow(name)
	local objSwf = self.objSwf
	if not objSwf then return end
	self:Reset()
end

function UIRoleChat:Reset()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	if self.timerId then TimerManager:UnRegisterTimer(self.timerId) end
	self.timerId = TimerManager:RegisterTimer(function()			
			if self.timerId then TimerManager:UnRegisterTimer(self.timerId) end
			self:Hide()
			--FPrint('UIRoleChatHide5')
		end,
	self.lastTime, 1)	
	objSwf.textField.htmlText = self.chatText
	-- objSwf._x =500
	-- objSwf._y =300
end

function UIRoleChat:OnHide()
	self.npcRole = nil
	self.chatText="" 
	if self.timerId then TimerManager:UnRegisterTimer(self.timerId) end
end

function UIRoleChat:GetCfgPos()
	return -500, -500
end

----------------------------------
function UIRoleChat:Set(chatText, role)
	----FPrint('UIRoleChat:Set')
	self.npcRole = role
	self.chatText=chatText.talk 
	self.offsetX = chatText.offsetX or 0
	self.offsetY = chatText.offsetY or 0
	if self.timerId then TimerManager:UnRegisterTimer(self.timerId) end
	
	if role.IsHide then
		if role:IsHide() then
			--FPrint('UIRoleChatHide1')
			self:Hide()
			return
		end
	end
	
	if chatText=="" then
		--FPrint('UIRoleChatHide2')
		self:Hide()
		return
	end
	if self.bShowState then
		self:Reset()
	else
		self:Show()
	end
end

--从来不被回收
function UIRoleChat:NeverDeleteWhenHide()
	return true;
end
