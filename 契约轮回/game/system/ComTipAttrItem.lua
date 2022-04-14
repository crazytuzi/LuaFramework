ComTipAttrItem = ComTipAttrItem or class("ComTipAttrItem",BaseWidget)
local ComTipAttrItem = ComTipAttrItem

function ComTipAttrItem:ctor(parent_node,layer)
	self.abName = "system"
	self.assetName = "ComTipAttrItem"
	self.layer = layer

	ComTipAttrItem.super.Load(self)
end

function ComTipAttrItem:dctor()
end

function ComTipAttrItem:LoadCallBack()
	self.nodes = {
		"bg","attr_title","attr_value","next_attr_value",
	}
	self:GetChildren(self.nodes)
	self.attr_title = GetText(self.attr_title)
	self.attr_value = GetText(self.attr_value)
	self.next_attr_value = GetText(self.next_attr_value)
	self:AddEvent()
	self:UpdateView()
end

function ComTipAttrItem:AddEvent()
end

--data:attr_id, attr_value, index
--next_attr_value:下一级属性，没有就不传
function ComTipAttrItem:SetData(attr_id, attr_value, index, next_attr_value)
	self.attr_id = attr_id
	self.attr = attr_value
	self.index = index
	self.next_attr = next_attr_value
	if self.is_loaded then
		self:UpdateView()
	end
end

function ComTipAttrItem:UpdateView()
	if self.index then
		self.attr_title.text = string.format("%s:", enumName.ATTR[self.attr_id])
		self.attr_value.text = EquipModel:GetInstance():GetAttrTypeInfo2(self.attr_id, self.attr)
		local mod = self.index % 2
		if mod == 1 then
			SetVisible(self.bg, true)
		else
			SetVisible(self.bg, false)
		end
		if self.next_attr then
			SetVisible(self.next_attr_value, true)
			self.next_attr_value.text = self.next_attr
		else
			SetVisible(self.next_attr_value, false)
		end
	end
end

function ComTipAttrItem:GetHeight()
	return 27.7
end
