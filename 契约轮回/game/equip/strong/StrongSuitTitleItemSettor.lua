--
-- @Author: chk
-- @Date:   2018-09-24 22:25:14
--
StrongSuitTitleItemSettor = StrongSuitTitleItemSettor or class("StrongSuitTitleItemSettor",BaseItem)
local StrongSuitTitleItemSettor = StrongSuitTitleItemSettor

function StrongSuitTitleItemSettor:ctor(parent_node,layer)
	self.abName = "equip"
	self.assetName = "SuitTitleItem"
	self.layer = layer

	-- self.model = 2222222222222end:GetInstance()
	StrongSuitTitleItemSettor.super.Load(self)
end

function StrongSuitTitleItemSettor:dctor()
	if self.schedule_id ~= nil then
		GlobalSchedule:Stop(self.schedule_id)
		self.schedule_id = nil
	end
end

function StrongSuitTitleItemSettor:LoadCallBack()
	self.nodes = {
		"value",
	}
	self:GetChildren(self.nodes)
	self:GetRectTransform()
	self:AddEvent()

	if self.need_loaded_end then
		self:UpdateInfo(self.equipAttr)
	end
end

function StrongSuitTitleItemSettor:AddEvent()
end

function StrongSuitTitleItemSettor:GetRectTransform()
	self.valueRectTra = self.value:GetComponent('RectTransform')
	self.selfRectTra = self.transform:GetComponent('RectTransform')
end

function StrongSuitTitleItemSettor:SetData(data)

end

function StrongSuitTitleItemSettor:SetSize()
	self.selfRectTra.sizeDelta = Vector2(self.selfRectTra.sizeDelta.x,self.valueRectTra.sizeDelta.y + 16)
end

function StrongSuitTitleItemSettor:UpdateInfo(equipAttr)
	self.equipAttr = equipAttr
	if self.is_loaded then
		self.value:GetComponent('Text').text = self.equipAttr.title

		self.need_loaded_end = false

		self.selfRectTra.anchoredPosition = Vector2(self.selfRectTra.anchoredPosition.x,-self.equipAttr.pos)
		self.schedule_id = GlobalSchedule:StartOnce(handler(self,self.SetSize),0.03)
	else
		self.need_loaded_end = true
	end
end