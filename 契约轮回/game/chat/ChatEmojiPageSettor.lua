--
-- @Author: chk
-- @Date:   2019-02-12 21:22:41
--
ChatEmojiPageSettor = ChatEmojiPageSettor or class("ChatEmojiPageSettor",BaseItem)
local ChatEmojiPageSettor = ChatEmojiPageSettor

function ChatEmojiPageSettor:ctor(parent_node,layer)
	self.abName = "chat"
	self.assetName = "ChatEmojiPage"
	self.layer = layer

	self.events = {}
	self.model = ChatModel:GetInstance()
	ChatEmojiPageSettor.super.Load(self)
end

function ChatEmojiPageSettor:dctor()
	for k,v in pairs(self.events) do
		self.model:RemoveListener(v)
	end

	self.events = {}
end

function ChatEmojiPageSettor:LoadCallBack()
	self.nodes = {
		"p_s",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
end

function ChatEmojiPageSettor:AddEvent()
	self.events[#self.events+1] = self.model:AddListener(ChatEvent.ShowEmojiPage,handler(self,self.DealShowEmojiPage))
end

function ChatEmojiPageSettor:SetData(data)
	self.page = data
end

function ChatEmojiPageSettor:DealShowEmojiPage(page)
	if self.page == page then
		SetVisible(self.p_s.gameObject,true)
	else
		SetVisible(self.p_s.gameObject,false)	
	end
end