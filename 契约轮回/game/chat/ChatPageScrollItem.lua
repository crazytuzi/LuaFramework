ChatPageScrollItem = ChatPageScrollItem or class("ChatPageScrollItem",BaseItem)
local ChatPageScrollItem = ChatPageScrollItem

function ChatPageScrollItem:ctor(parent_node,layer)
	self.abName = "chat"
	self.assetName = "ChatPageScrollItem"
	self.layer = layer

	self.model = ChatModel:GetInstance()
	ChatPageScrollItem.super.Load(self)
end

function ChatPageScrollItem:dctor()
	if self.event_id then
		self.model:RemoveListener(self.event_id)
	end
	self.model = nil
end

function ChatPageScrollItem:LoadCallBack()
	self.nodes = {
		"bg", "selected"
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
	self:UpdateView()
end

function ChatPageScrollItem:AddEvent()
	local function call_back(x)
		if x ~= self.value then
			self.value = x
			self:UpdateView()
		end
	end
	self.event_id = self.model:AddListener(ChatEvent.EmojiScrollChange, call_back)
end

function ChatPageScrollItem:SetData(index, total_count, data)
	self.index = index
	self.total_count = total_count
	self.value = data
end

function ChatPageScrollItem:UpdateView()
	if self.value >= (self.index-1)/self.total_count and self.value <= self.index/self.total_count then
		SetVisible(self.bg, false)
		SetVisible(self.selected, true)
	else
		SetVisible(self.bg, true)
		SetVisible(self.selected, false)
	end
end