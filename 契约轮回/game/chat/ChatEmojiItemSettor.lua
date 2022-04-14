
ChatEmojiItemSettor = ChatEmojiItemSettor or class("ChatEmojiItemSettor",BaseCloneItem)
local ChatEmojiItemSettor = ChatEmojiItemSettor

function ChatEmojiItemSettor:ctor(obj,parent_node,layer)
	ChatEmojiItemSettor.super.Load(self)
end

function ChatEmojiItemSettor:dctor()
	if self.lua_link_text then
		self.lua_link_text:destroy()
	end
	for i=1, #self.global_events do
		GlobalEvent:RemoveListener(self.global_events[i])
	end
	self.model = nil
end


function ChatEmojiItemSettor:LoadCallBack()
	self.nodes = {
		"select",
	}
	self:GetChildren(self.nodes)
	SetVisible(self.select.gameObject,false)
	self:AddEvent()

	self.inlineText = GetLinkText(self.transform) --self.transform:GetComponent('InlineText')
	--self.inlineText.inlineManager = self.model.inlineManagerScpButtom
end

function ChatEmojiItemSettor:AddEvent()
	self.global_events = self.global_events or  {}
	self.model = ChatModel:GetInstance()

	local function call_back()
		--GlobalEvent:Brocast(ChatEvent.ClickEmoji, self.emojiIdx, self.index)
		GlobalEvent:Brocast(ChatEvent.ClickEmoji, self.emojiName)
	end
	AddClickEvent(self.gameObject,call_back)

	local function call_back(emojiName)
		SetVisible(self.select, self.emojiName == emojiName)
	end
	self.global_events[#self.global_events+1] = GlobalEvent:AddListener(ChatEvent.ClickEmoji, call_back)
end

--data 加了标签后的表情
--emojiIdx 静态，动态表情的索引
--emojiName 更让名字
--index 表情在数组中的索引

function ChatEmojiItemSettor:SetData(data,emojiName)
	self.data = data
	--self.emojiIdx = emojiIdx
	self.emojiName = emojiName
	--self.index = index
	self.lua_link_text = LuaLinkImageText(self, self.inlineText)
    self.lua_link_text:clear()
	self.inlineText.text = self.data
end