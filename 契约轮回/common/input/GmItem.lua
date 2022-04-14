--
-- @Author: LaoY
-- @Date:   2019-01-24 15:04:06
--
GmItem = GmItem or class("GmItem",BaseCloneItem)

function GmItem:ctor(obj,parent_node,layer)
	GmItem.super.Load(self)
end

function GmItem:dctor()
end

function GmItem:LoadCallBack()
	self.nodes = {
		"text",
	}
	self:GetChildren(self.nodes)

	self.img = self.gameObject:GetComponent('Image')
	self.text_component = self.text:GetComponent('Text')
	self:AddEvent()
end

function GmItem:AddEvent()
	local function call_back(target,x,y)
		if self.call_back then
			self.call_back(self.data.id)
		end
	end
	AddClickEvent(self.gameObject,call_back)
end

function GmItem:SetCallBack(call_back)
	self.call_back = call_back
end

function GmItem:SetData(data)
	self.data = data
	self.text_component.text = data.name
	self:SetImageRes()
end

function GmItem:SetImageRes()
	local abName = 'common_image'
	local assetName = 'btn_blue_3'
	if self.data.gm_type == 1 then
		assetName = 'com_btn_3'
	elseif self.data.gm_type == 2 then
		assetName = 'com_btn_4'
	elseif self.data.gm_type == 3 then
		assetName = 'com_btn_5'
	elseif self.data.gm_type == 4 then
		assetName = 'com_btn_6'
	end	
	if self.assetName == assetName then
		return
	end
	self.assetName = assetName
	lua_resMgr:SetImageTexture(self,self.img, abName, assetName,true)
end