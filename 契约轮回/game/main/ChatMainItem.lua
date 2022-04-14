


ChatMainItem = ChatMainItem or class("ChatMainItem", BaseWidget)
local ChatMainItem = ChatMainItem

function ChatMainItem:ctor(parent_node,layer)
	self.abName = "main"
	self.assetName = "ChatMainItem"

	self.height = 0
	--self.model = 2222222222222end:GetInstance()
	BaseWidget.Load(self)
end

function ChatMainItem:dctor()
end

function ChatMainItem:LoadCallBack()
	self.nodes = {
		"Channel", "Text"
	}
	self:GetChildren(self.nodes)

	self:AddEvent()
end

function ChatMainItem:AddEvent()
end

function ChatMainItem:SetData(data)
	self.Channel:GetComponent('Text').text = data.channel_id
	local content_text = self.Text:GetComponent('Text')
	content_text.text = data.role_nick .. ":" .. data.content
	
	self.height = content_text.preferredHeight
	return self.height
end


function ChatMainItem:GetHeight()
	return self.height
end

