YYSTMessageItem = YYSTMessageItem or class("YYSTMessageItem",BaseItem)
local YYSTMessageItem = YYSTMessageItem

function YYSTMessageItem:ctor(parent_node,layer)
	self.abName = "search_treasure"
	self.assetName = "YYSTMessageItem"
	self.layer = layer

	self.model = SearchTreasureModel:GetInstance()
	YYSTMessageItem.super.Load(self)
end

function YYSTMessageItem:dctor()
	self.Text_t = nil
end

function YYSTMessageItem:LoadCallBack()
	self.nodes = {
		"Text",
	}
	self:GetChildren(self.nodes)
	self.Text_t = GetText(self.Text)
	self:AddEvent()
	self:UpdateView()
end

function YYSTMessageItem:AddEvent()
end

function YYSTMessageItem:SetData(data)
	self.data = data
	if self.is_loaded then
		self:UpdateView()
	end
end

function YYSTMessageItem:UpdateView()
	local item = Config.db_item[self.data.item_id]
	local item_name = ColorUtil.GetHtmlStr(item.color, item.name)
	local YYName = Config.db_yunying[self.model.act_id].name
	self.Text_t.text = string.format("<color=#6ce19b>%s</color> processes[%s] and obtain %s×%s", self.data.name, YYName, item_name, self.data.num)
end

function YYSTMessageItem:GetHeight()
	return 36.5
end