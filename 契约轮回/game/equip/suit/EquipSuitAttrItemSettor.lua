--
-- @Author: chk
-- @Date:   2018-11-05 20:12:24
--
EquipSuitAttrItemSettor = EquipSuitAttrItemSettor or class("EquipSuitAttrItemSettor",BaseItem)
local EquipSuitAttrItemSettor = EquipSuitAttrItemSettor

function EquipSuitAttrItemSettor:ctor(parent_node,layer)
	self.abName = "equip"
	self.assetName = "EquipSuitAttrItem"
	self.layer = layer

	--self.model = 2222222222222end:GetInstance()
	EquipSuitAttrItemSettor.super.Load(self)
end

function EquipSuitAttrItemSettor:dctor()
end

function EquipSuitAttrItemSettor:LoadCallBack()
	self.nodes = {
		"count",
		"value",
	}
	self:GetChildren(self.nodes)

	self.countTxt = self.count:GetComponent('Text')
	self.valueTxt = self.value:GetComponent('Text')
	self.itemRectTra = self.transform:GetComponent('RectTransform')
	self.valueRectTra = self.value:GetComponent('RectTransform')
	self:AddEvent()

	if self.need_loaded_end then
		self:UpdateInfo(self.isActive,self.info)
	end
end

function EquipSuitAttrItemSettor:AddEvent()
end

function EquipSuitAttrItemSettor:SetData(data)

end

function EquipSuitAttrItemSettor:UpdateInfo(isActive,info)
	if self.is_loaded then
		local attrInfo = ""
		if isActive then

			self.countTxt.text = info.suitCount

			self.valueTxt.text = string.format("<color=#fcefd4>%s</color>",info.attrValue)
		else

			self.countTxt.text = info.suitCount
			self.valueTxt.text = string.format("<color=#a6785c>%s</color>",info.attrValue)
		end

		self.valueRectTra.sizeDelta = Vector2(self.valueRectTra.sizeDelta.x,self.valueTxt.preferredHeight)
		self.itemRectTra.sizeDelta = Vector2(self.itemRectTra.sizeDelta.x,self.valueTxt.preferredHeight + 10)
		--self.lineRectTra.anchoredPosition = Vector2(self.lineRectTra.anchoredPosition.x,-self.suitValueTxt.preferredHeight - 25)
	else
		self.need_loaded_end = true
		self.isActive = isActive
		self.info = info
	end
end
