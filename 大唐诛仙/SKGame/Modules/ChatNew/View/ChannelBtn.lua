ChannelBtn = BaseClass(LuaUI)

ChannelBtn.CurSelect = nil
function ChannelBtn:__init(...)
	self.URL = "ui://m2d8gld1cdsbh";
	self:__property(...)
	self:Config()
end

function ChannelBtn:SetProperty(...)
	
end

function ChannelBtn:Config()
	
end

function ChannelBtn:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("ChatNew","ChannelBtn");

	self.state = self.ui:GetController("state")
	self.n0 = self.ui:GetChild("n0")
	self.title = self.ui:GetChild("title")
	self.n7 = self.ui:GetChild("n7")

	self.channelId = -1

	self.ui.onClick:Add(function(e)
		if ChannelBtn.CurSelect then
			ChannelBtn.CurSelect:UnSelect()
		end
		self:Select()
	end)
end

function ChannelBtn:Set(title, channel, x, y, container)
	self.title.text = title
	self.channelId = channel
	self:AddTo(container, x, y)
end

function ChannelBtn:Select()
	self.state.selectedIndex = 1
	ChannelBtn.CurSelect = self
	ChatNewModel:GetInstance():DispatchEvent(ChatNewConst.SelectChannel, self.channelId)
end

function ChannelBtn:UnSelect()
	self.state.selectedIndex = 0
end

function ChannelBtn.Create(ui, ...)
	return ChannelBtn.New(ui, "#", {...})
end

function ChannelBtn:__delete()
end