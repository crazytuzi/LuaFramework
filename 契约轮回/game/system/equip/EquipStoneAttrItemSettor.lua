--
-- @Author: chk
-- @Date:   2018-10-19 17:26:34
--
EquipStoneAttrItemSettor = EquipStoneAttrItemSettor or class("EquipStoneAttrItemSettor",BaseWidget)
local EquipStoneAttrItemSettor = EquipStoneAttrItemSettor

function EquipStoneAttrItemSettor:ctor(parent_node,layer)
	self.abName = "system"
	self.assetName = "EquipStoneAttrItem"
	self.layer = layer

	self.height = 0
	self.model = EquipMountStoneModel:GetInstance()
	EquipStoneAttrItemSettor.super.Load(self)
end

function EquipStoneAttrItemSettor:dctor()
end

function EquipStoneAttrItemSettor:LoadCallBack()
	self.nodes = {
		"stone",
		"title",
		"value",
	}
	self:GetChildren(self.nodes)
	self:GetRectTransform()
	self:AddEvent()

	if self.stoneId then
		self:UpdateAttrInfo(self.stoneId)
	end
end

function EquipStoneAttrItemSettor:AddEvent()
end

function EquipStoneAttrItemSettor:SetData(data)

end

function EquipStoneAttrItemSettor:GetRectTransform()
	self.selfRectTra = self.transform:GetComponent('RectTransform')
	self.titleTxt = self.title:GetComponent('Text')
	self.titleRectTra = self.title:GetComponent('RectTransform')
	self.valueTxt = self.value:GetComponent('Text')
	self.valueRectTra = self.value:GetComponent('RectTransform')
end

function EquipStoneAttrItemSettor:UpdateAttrInfo(stoneId)
	if  self.is_loaded then
		local itemCfg = Config.db_item[stoneId]
		local attrInfo = self.model:GetStoneAttrInfoInTip(stoneId,EquipMountStoneModel.GetInstance().cur_state)

		GoodIconUtil.GetInstance():CreateIcon(self,self.stone:GetComponent('Image'),itemCfg.icon,true)
		self.titleTxt.text = itemCfg.name
		self.valueTxt.text = attrInfo

		self.height = self.height + self.titleTxt.preferredHeight + self.valueTxt.preferredHeight

		self.selfRectTra.sizeDelta = Vector2(self.selfRectTra.sizeDelta.x,self.height)
	else
		self.stoneId = stoneId
	end
end


