require("game.roleinfo.RoleInfoModel")

ChatCommonLGItemSettor = ChatCommonLGItemSettor or class("ChatCommonLGItemSettor", BaseItem)
local ChatCommonLGItemSettor = ChatCommonLGItemSettor

function ChatCommonLGItemSettor:ctor(parent_node,layer)
	self.abName = "chat"
	self.assetName = "ChatCommonLGItem"

	self.height = 0
	self.model = ChatModel.GetInstance()
	ChatCommonLGItemSettor.super.Load(self)
end

function ChatCommonLGItemSettor:dctor()
	self.model = nil
end

function ChatCommonLGItemSettor:LoadCallBack()
	self.nodes = {
		"bg",
		"Text",
	}

	self:GetChildren(self.nodes)
	self:AddEvent()

	self.inlineText = GetText(self.Text) --self.Text:GetComponent('InlineText')
	--self.inlineText.inlineManager = self.model.inlineMgrComLGScp
	self.inlineText.text = self.data.info
	--GetText(self.Text).text = self.data.info
	local rectTra = GetRectTransform(self.transform)
	rectTra.anchoredPosition = Vector2(rectTra.anchoredPosition.x,-(self.data.index - 1) * 41)
--[[
	if self.data.index % 2 == 1 then
		SetVisible(self.bg.gameObject,true)
	else
		SetVisible(self.bg.gameObject,false)
	end
]]
	--self.model.CMLGInlineManager.transform:SetAsLastSibling()
end

function ChatCommonLGItemSettor:AddEvent()
	local function call_back(  )
		GlobalEvent:Brocast(ChatEvent.ClickCommonLG,self.data.info)
	end
	AddClickEvent(self.transform.gameObject,call_back)
end

function ChatCommonLGItemSettor:SetData(data)
	self.data = data
end
