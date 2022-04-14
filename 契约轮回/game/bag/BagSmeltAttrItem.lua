BagSmeltAttrItem = BagSmeltAttrItem or class("BagSmeltAttrItem",BaseItem)
local BagSmeltAttrItem = BagSmeltAttrItem

function BagSmeltAttrItem:ctor(parent_node,layer)
	self.abName = "bag"
	self.assetName = "BagSmeltAttrItem"
	self.layer = layer

	--self.model = 2222222222222end:GetInstance()
	BagSmeltAttrItem.super.Load(self)
end

function BagSmeltAttrItem:dctor()
end

function BagSmeltAttrItem:LoadCallBack()
	self.nodes = {
		"name","value","up", "up/upvalue", "bg"
	}
	self:GetChildren(self.nodes)

	self.name = GetText(self.name)
	self.value = GetText(self.value)
	self.upvalue = GetText(self.upvalue)
	self:AddEvent()

	self:UpdateView()
end

function BagSmeltAttrItem:AddEvent()
end


--data:{key, value}
function BagSmeltAttrItem:SetData(data, index)
	self.data = data
	self.index = index
	if self.is_loaded then
		self:UpdateView()
	end
end

function BagSmeltAttrItem:UpdateView( ... )
	self.name.text = GetAttrNameByIndex(self.data[1])
	self.value.text = self.data[2]
	if self.data2 == nil then
		SetVisible(self.up, false)
	else
		SetVisible(self.up, true)
		self.upvalue.text = self.data2[2] - self.data[2]
	end
	if self.index % 2 == 0 then
		SetVisible(self.bg, true)
	else
		SetVisible(self.bg, false)
	end
end

function BagSmeltAttrItem:SetUpData(data)
	self.data2 = data
	if self.is_loaded then
		self:UpdateView()
	end
end

function BagSmeltAttrItem:ClearUpData()
	self.data2 = nil
	if self.is_loaded then
		self:UpdateView()
	end
end