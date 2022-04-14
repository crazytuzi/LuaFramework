WakeAttribItem = WakeAttribItem or class("WakeAttribItem",BaseItem)
local WakeAttribItem = WakeAttribItem

function WakeAttribItem:ctor(parent_node,layer)
	self.abName = "wake"
	self.assetName = "WakeAttribItem"
	self.layer = layer

	--self.model = 2222222222222end:GetInstance()
	WakeAttribItem.super.Load(self)
end

function WakeAttribItem:dctor()
end

function WakeAttribItem:LoadCallBack()
	self.nodes = {
		"attribname", "oldattribvalue", "newattribvalue"
	}
	self:GetChildren(self.nodes)
	self:AddEvent()

	self.attribname = GetText(self.attribname)
	self.oldattribvalue = GetText(self.oldattribvalue)
	self.newattribvalue = GetText(self.newattribvalue)
	self:UpdateView()
end

function WakeAttribItem:AddEvent()
end

function WakeAttribItem:SetData(pre_attrib, attrib)
	self.pre_attrib = pre_attrib
	self.attrib = attrib
	if self.is_loaded then
		self:UpdateView()
	end
end

function WakeAttribItem:UpdateView()
	self.attribname.text = enumName.ATTR[self.attrib[1]]
	self.oldattribvalue.text = self.pre_attrib[2] or 0
	self.newattribvalue.text = self.attrib[2]
end