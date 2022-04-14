TipAttribItem = TipAttribItem or class("TipAttribItem",BaseCloneItem)
local TipAttribItem = TipAttribItem

function TipAttribItem:ctor(obj,parent_node,layer)
	TipAttribItem.super.Load(self)
end

function TipAttribItem:dctor()
end

function TipAttribItem:LoadCallBack()
	self.nodes = {
		"attribname","attrib",
	}
	self:GetChildren(self.nodes)
	self.attribname = GetText(self.attribname)
	self.attrib = GetText(self.attrib)
	self:AddEvent()

	self:UpdateView()
end

function TipAttribItem:AddEvent()
end

--data:{key,value}
function TipAttribItem:SetData(data)
	self.data = data
	if self.is_loaded then
		self:UpdateView()
	end
end

function TipAttribItem:UpdateView()
	if self.data then
		Jlprint('--Jl TipAttribItem.lua,line 36--')
		Jldump(self.data,"self.data")
		self.attribname.text = enumName.ATTR[self.data[1]] .. "："
		self.attrib.text = self.data[2]
	end
end
