-- 
-- @Author: LaoY
-- @Date:   2018-08-21 15:14:34
-- 
LoginSelectItem = LoginSelectItem or class("LoginSelectItem",BaseCloneItem)
local LoginSelectItem = LoginSelectItem

function LoginSelectItem:ctor(obj,parent_node,layer)
	LoginSelectItem.super.Load(self)
end

function LoginSelectItem:dctor()
end

function LoginSelectItem:LoadCallBack()
	self.nodes = {
		"text"
	}
	self:GetChildren(self.nodes)
	self.img = self.gameObject:GetComponent('Image')
	self.text_component = self.text:GetComponent('Text')
--[[ 	if self.text_str then
		self:SetText(self.text_str)
	end ]]
	self:AddEvent()
end

function LoginSelectItem:AddEvent()
	local function call_back(target,x,y)
		if self.call_back then
			self.call_back(self.index)
		end
	end
	AddClickEvent(self.img.gameObject,call_back)
end

function LoginSelectItem:SetText(str)
	self.text_str = str
	if self.is_loaded then
		self.text_component.text = str
	end
end

function LoginSelectItem:SetIndex(call_back,index)
	self.call_back = call_back
	self.index = index
end

function LoginSelectItem:SetData(data)

end