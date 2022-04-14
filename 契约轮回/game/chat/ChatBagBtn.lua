ChatBagBtn = ChatBagBtn or class("ChatBagBtn", BaseItem)
local ChatBagBtn = ChatBagBtn

function ChatBagBtn:ctor(parent_node,layer)
	self.abName = "chat"
	self.assetName = "ChatBagBtn"

	self.model = ChatModel.GetInstance()

	ChatBagBtn.super.Load(self)
end

function ChatBagBtn:dctor()
end

function ChatBagBtn:LoadCallBack()
	self.nodes = {
		"select",
		"Text",
	}
	self:GetChildren(self.nodes)
	GetText(self.Text).text = self.data.name

	self:AddEvent()

	local rectTra = GetRectTransform(self.transform)
	rectTra.anchoredPosition = Vector2((self.data.idx - 1) * 116,rectTra.anchoredPosition.y)
end

function ChatBagBtn:AddEvent()
	local function call_back( ... )
		self.data.btnCB()

		if self.model.last_chatBagBtn_select ~= nil then
			SetVisible(self.model.last_chatBagBtn_select.gameObject,false)
		end

		SetVisible(self.select.gameObject,true)
		self.model.last_chatBagBtn_select = self.select
	end

	AddClickEvent(self.transform.gameObject,call_back)


	if self.data.name == self.model.default_bag_name then
		self.data.btnCB()

		SetVisible(self.select.gameObject,true)
		self.model.last_chatBagBtn_select = self.select
	end	
end

function ChatBagBtn:SetData(data)
	self.data = data
end
