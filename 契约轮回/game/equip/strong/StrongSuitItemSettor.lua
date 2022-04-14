--
-- @Author: chk
-- @Date:   2018-09-19 23:38:09
--
StrongSuitItemSettor = StrongSuitItemSettor or class("StrongSuitItemSettor",BaseItem)
local StrongSuitItemSettor = StrongSuitItemSettor

function StrongSuitItemSettor:ctor(parent_node,layer)
	self.abName = "equip"
	self.assetName = "SuitAttItem"
	self.layer = layer

	self.equipAttr = nil
	self.need_loaded_end = false
	-- self.model = 2222222222222end:GetInstance()
	StrongSuitItemSettor.super.Load(self)
end

function StrongSuitItemSettor:dctor()
	if self.schedule_id ~= nil then
		GlobalSchedule:Stop(self.schedule_id)
		self.schedule_id = nil
	end
end

function StrongSuitItemSettor:LoadCallBack()
	self.nodes = {
		"attr",
	}
	self:GetChildren(self.nodes)
	self:GetRectTransform()
	self:AddEvent()

	if self.need_loaded_end then
		self:UpdateInfo(self.equipAttr)
	end
end

function StrongSuitItemSettor:AddEvent()
end

function  StrongSuitItemSettor:GetRectTransform()
	self.attrRectTra = self.attr:GetComponent('RectTransform')
	self.selfRectTra = self.transform:GetComponent('RectTransform')
end

function StrongSuitItemSettor:SetData(data)

end

function StrongSuitItemSettor:SetSize()
	self.selfRectTra.sizeDelta = Vector2(self.selfRectTra.sizeDelta.x,self.attrRectTra.sizeDelta.y)
end

function StrongSuitItemSettor:UpdateInfo(equipAttr)
	self.equipAttr = equipAttr
	if self.is_loaded then
		if enumName.ATTR[self.equipAttr.att] ~= nil then
			self.attr:GetComponent('Text').text = enumName.ATTR[self.equipAttr.att] ..": " .. "+" ..
					string.format("<color=#%s>%s</color>",ColorUtil.GetColor(ColorUtil.ColorType.Green), self.equipAttr.value)
		else
			self.attr:GetComponent('Text').text = self.equipAttr.value
		end

		self.schedule_id = GlobalSchedule:StartOnce(handler(self,self.SetSize),0.03)
		self.need_loaded_end = false

		self.selfRectTra.anchoredPosition = Vector2(self.selfRectTra.anchoredPosition.x,-self.equipAttr.pos)
	else
		self.need_loaded_end = true	
	end	
end
