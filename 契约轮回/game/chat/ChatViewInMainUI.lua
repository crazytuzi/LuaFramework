--
-- @Author: chk
-- @Date:   2018-09-06 11:54:19
--
ChatViewInMainUI = ChatViewInMainUI or class("ChatViewInMainUI",BaseItem)
local ChatViewInMainUI = ChatViewInMainUI
local tableRemove = table.remove
local tableInsert = table.insert

function ChatViewInMainUI:ctor(parent_node,layer)
	self.abName = "chat"
	self.assetName = "ChatViewInMainUI"
	self.layer = layer

	self.globalEvents = {}
	self.settors = {}
	self.model = ChatModel:GetInstance()
	ChatViewInMainUI.super.Load(self)
end

function ChatViewInMainUI:dctor()
	for i, v in pairs(self.settors) do
		v:destroy()
	end
	self.settors = {}

	for i, v in pairs(self.globalEvents) do
		GlobalEvent:RemoveListener(v)
	end
	self.globalEvents = {}
end

function ChatViewInMainUI:LoadCallBack()
	self.nodes = {
		"ScrollView/Viewport/Content",
		"ScrollView",
		"chat_open",
		"chat_fold",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()

	--self.model.inlineMgrMainUI = self.inlineManager
	--self.model.inlineMgrMainUIScp = self.inlineManager:GetComponent('InlineManager')
	--self.model.inlineMgrMainUIScp:LoadEmoji("asset/chatemoji_asset","e",0,16)
	self.sRect = self.ScrollView:GetComponent('ScrollRect')
	self.rectTra = self.ScrollView:GetComponent('RectTransform')
	self.contentRectTra = self.Content:GetComponent('RectTransform')
end

function ChatViewInMainUI:AddEvent()
	local function call_back(target,x,y)
		GlobalEvent:Brocast(ChatEvent.OpenChatPanel,1)
	end
	-- AddClickEvent(self.Content.gameObject,call_back,false,false)

	local function call_back(target,x,y)
		GlobalEvent:Brocast(ChatEvent.ExpandMainChatView)
		SetSizeDeltaY(self.ScrollView.transform, 290)
		SetSizeDeltaY(self.transform, 312)
		SetVisible(self.chat_open, false)
		SetVisible(self.chat_fold, true)
	end
	AddClickEvent(self.chat_open.gameObject,call_back)

	local function call_back(target,x,y)
		GlobalEvent:Brocast(ChatEvent.FoldMainChatView)
		SetSizeDeltaY(self.ScrollView.transform, 110)
		SetSizeDeltaY(self.transform, 132)
		SetVisible(self.chat_open, true)
		SetVisible(self.chat_fold, false)
	end
	AddClickEvent(self.chat_fold.gameObject,call_back)

	self.globalEvents[#self.globalEvents+1]=GlobalEvent:AddListener(ChatEvent.AddMsgItem,handler(self,self.ReceiveMessage))
	self.globalEvents[#self.globalEvents+1] =  GlobalEvent:AddListener(ChatEvent.CreateItemEndInMain,handler(self,self.DealCreateItemEnd))
end

function ChatViewInMainUI:SetData(data)

end

--[[function ChatViewInMainUI:CheckDeleteChat()
	if self.Content.childCount >= ChatModel.MaxChatCount then
		local settor = table.remove(self.model.chatSettorsInMainUI,1)
		settor:destroy()
	end
end--]]

function ChatViewInMainUI:DealCreateItemEnd(chatMsg)
	--local heigh = self.model:GetMainUIChannelItemsHeight()
	
	--if self.Content.childCount >= ChatModel.MaxChatCount then
		local height = 0
		for i, v in pairs(self.model.chatSettorsInMainUI) do
			if v.is_loaded then
				v.itemRectTra.localPosition = Vector3(0,-height-5,0)
				v.y = height
				height = height + v.height
			end
		end
	--end
	self.contentRectTra.sizeDelta = Vector2(self.contentRectTra.sizeDelta.x, height)
	local y = height - self.rectTra.sizeDelta.y

	if self.rectTra.sizeDelta.y < height then
		local spanY = y - self.contentRectTra.localPosition.y
		self:MoveMsgToEnd(spanY,y)
	end
end

function ChatViewInMainUI:MoveMsgToEnd(spanY,y)
	SetLocalPosition(self.contentRectTra,0,y,0)
end

function ChatViewInMainUI:ReceiveMessage(chatMsg)
	if #self.model.chatSettorsInMainUI >= ChatModel.MaxChatCount then
		local settor = tableRemove(self.model.chatSettorsInMainUI, 1)
		settor:destroy()
		local settor2 = ChatItemInMainSettor(self.Content)
		tableInsert(self.model.chatSettorsInMainUI,settor2)
		settor2:SetInfo(chatMsg,self.sRect)
	else
		local settor = ChatItemInMainSettor(self.Content,"UI")
		settor:SetInfo(chatMsg,self.sRect)
		tableInsert(self.model.chatSettorsInMainUI,settor)
	end
end
