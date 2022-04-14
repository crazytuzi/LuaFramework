--
-- @Author: LaoY
-- @Date:   2018-11-28 20:18:31
--
MapLineItem = MapLineItem or class("MapLineItem",BaseCloneItem)
local MapLineItem = MapLineItem

function MapLineItem:ctor(obj,parent_node,layer)
	MapLineItem.super.Load(self)
end

function MapLineItem:dctor()
end

function MapLineItem:LoadCallBack()
	self.nodes = {
		"btn","btn/text"
	}
	self:GetChildren(self.nodes)
	self.text_component = self.text:GetComponent('Text')
	self:AddEvent()
end

function MapLineItem:SetCallBack(call_back)
	self.call_back = call_back
end

function MapLineItem:AddEvent()
	local function call_back(target,x,y)
		if self.call_back then
			local id = self.data and self.data.id
			self.call_back(id)
		end
	end
	AddClickEvent(self.btn.gameObject,call_back)
end

function MapLineItem:SetData(index,data)
	self.index = index
	self.data = data
	self.text_component.text = "Line " .. data.id
end