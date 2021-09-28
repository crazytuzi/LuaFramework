	
ChatNewView =BaseClass()

function ChatNewView:__init()
	resMgr:AddUIAB("ChatNew")

	self:Reset()
end
function ChatNewView:Reset()
	if self:IsExitView() then
		self.chatNewPanel:Destroy()
	end
	self:GetView()
end

function ChatNewView:OpenChatNewPanel()
	self:GetView():Open()
end 

function ChatNewView:Close()
	if self:IsExitView() then
		self.chatNewPanel:Close()
	end
end 

function ChatNewView:IsExitView()
	return self.chatNewPanel and self.chatNewPanel.isInited
end
function ChatNewView:GetView()
	if not self:IsExitView() then
		self.chatNewPanel = ChatNewPanel.New()
	end
	return self.chatNewPanel
end

function ChatNewView:AddMsg(channelId, content)
	if self:IsExitView() then
		self.chatNewPanel:AddMsg(channelId, content)
	end
end 

function ChatNewView:__delete()
	if self:IsExitView() then
		self.chatNewPanel:Destroy()
	end
	self.chatNewPanel = nil
end