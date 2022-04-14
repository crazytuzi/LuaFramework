MarqueePanel = MarqueePanel or class("MarqueePanel",BasePanel)
local MarqueePanel = MarqueePanel

function MarqueePanel:ctor()
	self.abName = "chat"
	self.assetName = "MarqueePanel"
	self.layer = "Top"

	self.use_background = false
	self.change_scene_close = false

	self.model = ChatModel:GetInstance()
end

function MarqueePanel:dctor()
end

function MarqueePanel:Open(marquee)
	self.data = marquee
	MarqueePanel.super.Open(self)
end

function MarqueePanel:LoadCallBack()
	self.nodes = {
		"bg/Text",
	}
	self:GetChildren(self.nodes)

	self.Text = GetText(self.Text)
	self:AddEvent()
end

function MarqueePanel:AddEvent()

end

function MarqueePanel:OpenCallBack()
	self:UpdateView()
end

function MarqueePanel:UpdateView( )
	self.Text.text = self.data.content
	local x, y = GetLocalPosition(self.Text.transform)
	local action = cc.MoveTo(12, -698, y, 0)
	local function call_back(  )
		self:Close()
	end
	local call_action = cc.CallFunc(call_back)
	local action2 = cc.Sequence(action, call_action)
	cc.ActionManager:GetInstance():addAction(action2, self.Text.transform)
end

function MarqueePanel:CloseCallBack(  )
	GlobalEvent:Brocast(ChatEvent.OpenMarqueePanel)
end