--
-- @Author: chk
-- @Date:   2018-09-19 23:38:09
--
StrongestAttItemSettor = StrongestAttItemSettor or class("StrongestAttItemSettor",BaseItem)
local StrongestAttItemSettor = StrongestAttItemSettor

function StrongestAttItemSettor:ctor(parent_node,layer)
	self.abName = "equip"
	self.assetName = "StrongestAttItem"
	self.layer = layer

	self.equipAttr = nil
	self.need_loaded_end = false
	-- self.model = 2222222222222end:GetInstance()
	StrongestAttItemSettor.super.Load(self)
end

function StrongestAttItemSettor:dctor()
end

function StrongestAttItemSettor:LoadCallBack()
	self.nodes = {
		"attr",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()

	if self.need_loaded_end then
		self:UpdateInfo(self.equipAttr)
	end
end

function StrongestAttItemSettor:AddEvent()
end

function StrongestAttItemSettor:SetData(data)

end

function StrongestAttItemSettor:UpdateInfo(equipAttr)
	self.equipAttr = equipAttr
	if self.is_loaded then
		self.attr:GetComponent('Text').text = enumName.ATTR[self.equipAttr.att] ..": +" .. self.equipAttr.value

		self.need_loaded_end = false
	else
		self.need_loaded_end = true	
	end	
end
