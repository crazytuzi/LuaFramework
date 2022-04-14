--
-- @Author: chk
-- @Date:   2018-09-29 15:53:13
--
BaseEquipAttrItemSettor = BaseEquipAttrItemSettor or class("BaseEquipAttrItemSettor",BaseWidget)
local BaseEquipAttrItemSettor = BaseEquipAttrItemSettor

function BaseEquipAttrItemSettor:ctor(parent_node,layer)
	-- self.abName = "equip"
	-- self.assetName = "EquipAttrInfoItem"
	-- self.layer = layer

	self.minHeight = 0
	self.schedule_id = nil
	self.itemRectTra = nil
	self.titleRectTra = nil
	self.lineRectTra = nil
	self.TextRectTra = nil
	self.equipAttr = nil
	self.need_loaded_end = false
	self.globalEvents = {}
	--EquipAttrItemSettor.super.Load(self)
end

function BaseEquipAttrItemSettor:dctor()
	if self.schedule_id ~= nil then
		GlobalSchedule:Stop(self.schedule_id)
		self.schedule_id = nil
	end


	for k,v in pairs(self.globalEvents) do
		globalEvents:RemoveListener(v)
	end
	self.globalEvents = {}
end

function BaseEquipAttrItemSettor:LoadCallBack()
	self.nodes = {
		"title",
		"value",
		"line",
	}
	self:GetChildren(self.nodes)
	self:GetRectTransform()
	self:AddEvent()


	if self.need_loaded_end then
		self:UpdatInfo(self.equipAttr)
	end
	
end

function BaseEquipAttrItemSettor:AddEvent()
end

function BaseEquipAttrItemSettor:GetRectTransform( )
	self.titleRectTra = self.title:GetComponent('RectTransform')
	self.TextRectTra = self.value:GetComponent('RectTransform')
	self.itemRectTra = self.transform:GetComponent('RectTransform')
	self.lineRectTra = self.line:GetComponent('RectTransform')
end
function BaseEquipAttrItemSettor:SetData(data)
	self.equipAttr = data
end

function BaseEquipAttrItemSettor:SetMinHeight(height)
	self.minHeight = height
end

function BaseEquipAttrItemSettor:SetItemSize( )
	if self.minHeight > 0 then
		self.itemRectTra.sizeDelta = Vector2(self.itemRectTra.sizeDelta.x,self.minHeight)
	else
		self.itemRectTra.sizeDelta = Vector2(self.itemRectTra.sizeDelta.x,self.titleRectTra.sizeDelta.y + self.TextRectTra.sizeDelta.y + 8)
	end

	self.lineRectTra.anchoredPosition = Vector2(self.lineRectTra.anchoredPosition.x,-self.itemRectTra.sizeDelta.y + 5)
	GlobalEvent:Brocast(GoodsEvent.CreateAttEnd)
end
function BaseEquipAttrItemSettor:UpdatInfo(equipAttr)
	self.equipAttr = equipAttr
	if self.is_loaded then
		self.title:GetComponent('Text').text = self.equipAttr.title
		self.value:GetComponent('Text').text = self.equipAttr.info

		self.itemRectTra.anchoredPosition = Vector2(self.itemRectTra.anchoredPosition.x,-equipAttr.posY)
		self.itemRectTra.sizeDelta = Vector2(self.itemRectTra.sizeDelta.x,equipAttr.itemHeight)
		self.lineRectTra.anchoredPosition = Vector2(self.lineRectTra.anchoredPosition.x,-equipAttr.itemHeight )
		--self.schedule_id = GlobalSchedule:Start(handler(self,self.SetItemSize),0.045,1)

		self.need_loaded_end = false
	else
		self.need_loaded_end = true	
	end

end