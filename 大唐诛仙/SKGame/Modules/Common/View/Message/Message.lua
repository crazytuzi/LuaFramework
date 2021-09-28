Message =BaseClass()

function Message:GetInstance()
	if Message.inst == nil then
		Message.inst = Message.New()
		Message.inst:Init()
	end
	return Message.inst
end

function Message:Init()
	if self.msgUI then
		self.msgUI:Destroy()
	end
	self.msgUI = MsgUI.New()
	layerMgr:GetMSGLayer():AddChild(self.msgUI.ui)
end

--滚动消息
function Message:RollMsg(msg)
	self.msgUI:RollMsg(msg)
end

--Tips消息
function Message:TipsMsg(msg)
	if msg ~= nil and msg ~= "" then
		self.msgUI:TipsMsg(msg)
	end
end

--喇叭消息
function Message:TrumpetMsg(msg)
	if self.msgUI then
		self.msgUI:TrumpetMsg(msg)
	end
end
function Message:__delete()
	if self.msgUI then
		self.msgUI:Destroy()
	end
	self.msgUI = nil
	Message.inst = nil
end