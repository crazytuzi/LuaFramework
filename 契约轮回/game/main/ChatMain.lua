

require("game.chat.ChatPanel")
require("game.chat.ChatEvent")
require("game.main.ChatMainItem")

ChatMain = ChatMain or class("ChatMain", BasePanel)
local ChatMain = ChatMain


function ChatMain:ctor()
	self.abName = "main"
	self.assetName = "ChatMain"
	self.layer = "Bottom"

	self.use_background = true		
	self.change_scene_close = true
	self.height = 0
	self.item_list = {}

	self.model = MainModel:GetInstance()
end

function ChatMain:LoadCallBack()
	self.nodes = {
		"bg", "view", "view/content"
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
end


function ChatMain:dctor()
	self.item_list = nil
end


function ChatMain:Open( )
	BasePanel.Open(self)
end

function ChatMain:AddEvent()
	local function call_back(target,x,y)
		Jlprint('--Jl ChatMain.lua,line 44-- data=',lua_panelMgr:GetPanel(ChatPanel))
		lua_panelMgr:GetPanelOrCreate(ChatPanel):Open()
	end
	AddClickEvent(self.view.gameObject,call_back)

	function call_back(data)
		self:AddMessage(data)
	end

	self.event_id = GlobalEvent:AddListener(ChatEvent.ReceiveMessage, call_back)

end


function ChatMain:AddMessage(data)
	local item
	local count = #self.item_list
	if  count < 5 then
		item = ChatMainItem(self.content)
	else
		item = table.remove(self.item_list, 1)
		self.height = self.height - item:GetHeight()
	end
	local item_height = item:SetData(data)
	
	table.insert(self.item_list, item)

	self.height = self.height + item_height

	local c_item, p_item
	for i=1, #self.item_list do
		c_item = self.item_list[i]
		if i == 1 then
			c_item.transform.anchoredPosition = Vector2(0, 0)
		else
			p_item = self.item_list[i-1]
			c_item.transform.anchoredPosition = Vector2(0, p_item.transform.anchoredPosition.y-p_item:GetHeight())
		end
	end
	self:ReLayout()
end


function ChatMain:ReLayout()
	self.content.sizeDelta = Vector2(403.7, self.height)
	
	if self.content.sizeDelta.y<100 then
		self.content.anchoredPosition = Vector2(0, 33)
	else
		self.content.anchoredPosition = Vector2(0, 33+self.height-100)
	end
end

function ChatMain:CloseCallBack()
	if self.event_id then
		GlobalEvent:RemoveListener(self.event_id)
		self.event_id = nil
	end
end