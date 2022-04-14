--
-- @Author: chk
-- @Date:   2018-09-25 11:40:16
--
EquipTwoAttrItemSettor = EquipTwoAttrItemSettor or class("EquipTwoAttrItemSettor",BaseWidget)
local EquipTwoAttrItemSettor = EquipTwoAttrItemSettor


function EquipTwoAttrItemSettor:ctor(parent_node,layer)
	self.abName = "system"
	self.assetName = "Equip2AttrInfoItem"
	self.layer = layer

	self.schedule_id = nil
	self.itemRectTra = nil
	self.titleRectTra = nil
	self.lineRectTra = nil
	self.Text1RectTra = nil
	self.Text2RectTra = nil
	self.equipAttr = nil
	self.need_loaded_end = false
	self.globalEvents = {}
	EquipAttrItemSettor.super.Load(self)
end

function EquipTwoAttrItemSettor:dctor()
	if self.schedule_id ~= nil then
		GlobalSchedule:Stop(self.schedule_id)
		self.schedule_id = nil
	end


	for k,v in pairs(self.globalEvents) do
		globalEvents:RemoveListener(v)
	end
	self.globalEvents = {}
end

function EquipTwoAttrItemSettor:LoadCallBack()
	self.nodes = {
		"title",
		"value1",
		"value2",
		"line",
		"valueTemp",
	}
	self:GetChildren(self.nodes)
	self:GetRectTransform()
	self:AddEvent()


	if self.need_loaded_end then
		self:UpdatInfo(self.equipAttr)
	end
	
end

function EquipTwoAttrItemSettor:AddEvent()
end

function EquipTwoAttrItemSettor:GetRectTransform( )
	self.titleRectTra = self.title:GetComponent('RectTransform')
	self.Text1RectTra = self.value1:GetComponent('RectTransform')
	self.Text2RectTra = self.value2:GetComponent('RectTransform')
	self.itemRectTra = self.transform:GetComponent('RectTransform')
	self.lineRectTra = self.line:GetComponent('RectTransform')
end
function EquipTwoAttrItemSettor:SetData(data)
	self.equipAttr = data
end

function EquipTwoAttrItemSettor:SetMinHeight(height)
	self.minHeight = height
end

function EquipTwoAttrItemSettor:SetItemSize( )
	if self.minHeight ~= nil and self.minHeight > 0 then
		self.itemRectTra.sizeDelta = Vector2(self.itemRectTra.sizeDelta.x,self.minHeight)
	else
		self.itemRectTra.sizeDelta = Vector2(self.itemRectTra.sizeDelta.x,self.titleRectTra.sizeDelta.y + self.Text1RectTra.sizeDelta.y)
	end

	self.lineRectTra.anchoredPosition = Vector2(self.lineRectTra.anchoredPosition.x,-self.itemRectTra.sizeDelta.y + 5)
	GlobalEvent:Brocast(GoodsEvent.CreateAttEnd)
end
function EquipTwoAttrItemSettor:UpdatInfo(equipAttr)
	self.equipAttr = equipAttr
	if self.is_loaded then
		self.title:GetComponent('Text').text = self.equipAttr.title
		self.value1:GetComponent('Text').text = self.equipAttr.info1
		self.value2:GetComponent('Text').text = self.equipAttr.info2

		self.itemRectTra.anchoredPosition = Vector2(self.itemRectTra.anchoredPosition.x,-equipAttr.posY)
		self.itemRectTra.sizeDelta = Vector2(self.itemRectTra.sizeDelta.x,equipAttr.itemHeight)
		self.lineRectTra.anchoredPosition = Vector2(self.lineRectTra.anchoredPosition.x,-equipAttr.itemHeight + 10)
		--self.schedule_id = GlobalSchedule:Start(handler(self,self.SetItemSize),0.045,1)

		self.need_loaded_end = false
	else
		self.need_loaded_end = true	
	end

end
