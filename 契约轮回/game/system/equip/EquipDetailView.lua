--
-- @Author: chk
-- @Date:   2018-08-29 15:24:50
--
EquipDetailView = EquipDetailView or class("EquipDetailView",BaseEquipDetailView)
local this = EquipDetailView

function EquipDetailView:ctor(parent_node,layer)
	self.abName = "system"
	self.assetName = "EquipDetailView"

	self.layer = nil

	self:InitData()

	self.btnWidth = 120
	EquipDetailView.super.Load(self)
end

function EquipDetailView:dctor()
end


function EquipDetailView:LoadCallBack()
	EquipDetailView.super.LoadCallBack(self)
end

function EquipDetailView:AddEvent()

	EquipDetailView.super.AddEvent(self)

end
