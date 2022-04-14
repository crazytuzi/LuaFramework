CastHouseItem = CastHouseItem or class("CastHouseItem",BaseCloneItem)
local CastHouseItem = CastHouseItem

function CastHouseItem:ctor(obj,parent_node,layer)
	CastHouseItem.super.Load(self)
end

function CastHouseItem:dctor()
end

function CastHouseItem:LoadCallBack()
	self.nodes = {
		"icon",
	}
	self:GetChildren(self.nodes)
	self.icon = GetImage(self.icon)
	self:AddEvent()
end

function CastHouseItem:AddEvent()
end

--data:item_id
function CastHouseItem:SetData(data, pos)
	self.pos = pos
	self.data = data
	if self.is_loaded then
		self:UpdateView()
	end
end

function CastHouseItem:UpdateView()
	local itemcfg = Config.db_item[self.data]
	local icon = itemcfg.icon
	GoodIconUtil.GetInstance():CreateIcon(self,self.icon,icon,true)
	SetLocalPositionXY(self.transform, self.pos[1], self.pos[2])
end