--
-- @Author: chk
-- @Date:   2018-09-19 16:50:27
--

StrongAttItemSettor = StrongAttItemSettor or class("StrongAttItemSettor",BaseItem)
local StrongAttItemSettor = StrongAttItemSettor

function StrongAttItemSettor:ctor(parent_node,layer)
	self.abName = "equip"
	self.assetName = "StrongAttItem"
	self.layer = layer

	-- self.model = 2222222222222end:GetInstance()
	self.crntStrongAtt = nil
	self.nextStrongAtt = nil
	self.need_load_end = nil
	StrongAttItemSettor.super.Load(self)
end

function StrongAttItemSettor:dctor()
	if self.schedule_id ~= nil then
		GlobalSchedule:Stop(self.schedule_id)
		self.schedule_id = nil
	end

end

function StrongAttItemSettor:LoadCallBack()
	self.nodes = {
		"crnt",
		"next",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()

	if self.need_load_end then
		self:UpdateInfo(self.crntStrongAtt,self.nextStrongAtt)
	end
end

function StrongAttItemSettor:AddEvent()
end

function StrongAttItemSettor:SetData(data)

end

function StrongAttItemSettor:UpdateInfo(crntStrongAtt,nextStrongAtt)
	self.crntStrongAtt = crntStrongAtt
	self.nextStrongAtt = nextStrongAtt

	if self.is_loaded then

		self.crnt:GetComponent('Text').text = enumName.ATTR[self.crntStrongAtt.att] .. ": +" .. self.crntStrongAtt.value
		self.next:GetComponent('Text').text = "+" .. self.nextStrongAtt.value

		self.need_load_end = false

	else
		self.need_load_end = true
	end
end