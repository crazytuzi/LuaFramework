--
-- @Author: chk
-- @Date:   2019-02-12 21:11:42
--
ChatEmojiPageItemSettor = ChatEmojiPageItemSettor or class("ChatEmojiPageItemSettor",BaseItem)
local ChatEmojiPageItemSettor = ChatEmojiPageItemSettor

function ChatEmojiPageItemSettor:ctor(parent_node,layer)
	self.abName = "chat"
	self.assetName = "ChatEmojiPageItem"
	self.layer = layer

	self.emojiItems = {}
	self.model = ChatModel:GetInstance()
	ChatEmojiPageItemSettor.super.Load(self)
end

function ChatEmojiPageItemSettor:dctor()
	for i=1, #self.emojiItems do
		self.emojiItems[i]:destroy()
	end
	self.emojiItems = nil
	self.model = nil
end

function ChatEmojiPageItemSettor:LoadCallBack()
	self.nodes = {
		"ChatEmojiItem",
	}
	self:GetChildren(self.nodes)
	self.ChatEmojiItem_go = self.ChatEmojiItem.gameObject
	SetVisible(self.ChatEmojiItem_go, false)
	self:AddEvent()

	self:LoadEmoji()
end

function ChatEmojiPageItemSettor:AddEvent()
end

function ChatEmojiPageItemSettor:LoadEmoji()
	local fromIdx = (self.data.page - 1) * self.model.emojisOnePage + 10
	local endIdx = self.data.page * self.model.emojisOnePage + 10 -1
	--[[if endIdx > self.data.emojiNums then
		endIdx = self.data.emojiNums
	end--]]

	for i=fromIdx,endIdx do
		local emojiName = "e_" .. i --self.model.inlineManagerScpButtom:GetEmojiName(self.data.graphicIdx,i - 1)
		local chatEmoji = ChatEmojiItemSettor(self.ChatEmojiItem_go, self.transform)
		local item = Config.db_emoji[emojiName]
		if item then
			local icon = item.icon
			chatEmoji:SetData(string.format("<quad name=emoji:%s size=71 width=1 />", icon), emojiName)
		end
		self.emojiItems[#self.emojiItems+1] = chatEmoji
	end

	local rectTra = GetRectTransform(self.transform)
	rectTra.anchoredPosition = Vector2(7, 2 - (self.data.page - 1) * rectTra.sizeDelta.y)
end

function ChatEmojiPageItemSettor:SetData(data)
	self.data = data
end



