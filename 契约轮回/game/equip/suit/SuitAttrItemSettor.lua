--
-- @Author: chk
-- @Date:   2018-10-31 17:57:35
--
SuitAttrItemSettor = SuitAttrItemSettor or class("SuitAttrItemSettor",BaseItem)
local SuitAttrItemSettor = SuitAttrItemSettor

function SuitAttrItemSettor:ctor(parent_node,layer)
	self.abName = "equip"
	self.assetName = "SuitAttrItem"
	self.layer = layer

	self.model = EquipSuitModel:GetInstance()
	SuitAttrItemSettor.super.Load(self)
end

function SuitAttrItemSettor:dctor()
end

function SuitAttrItemSettor:LoadCallBack()
	self.nodes = {
		"activeCountBG",
		"activeCountBG/activeCount",
		"notActiveCountBG",
		"notActiveCountBG/notActiveCount",
		"suitValue",
		"line",
		"valueTemp",
		"active_icon",
		"active_not_icon",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()

	self.activeCountTxt = self.activeCount:GetComponent('Text')
	self.notActiveCountTxt = self.notActiveCount:GetComponent('Text')
	self.suitValueTxt = self.suitValue:GetComponent('Text')
	self.itemRectTra = self.transform:GetComponent('RectTransform')
	self.lineRectTra = self.line:GetComponent('RectTransform')
	self.valueTempTxt = self.valueTemp:GetComponent('Text')

	if self.need_loaded_end then
		self:UpdateInfo(self.isActive,self.info)
	elseif self.need_dis_show then
		self:DisShowInfo()
	end
end

function SuitAttrItemSettor:AddEvent()
end

function SuitAttrItemSettor:SetData(data)

end

function SuitAttrItemSettor:UpdateInfo(isActive,info)
	if self.is_loaded then
		local attrInfo = ""
		if isActive then
			SetVisible(self.activeCountBG.gameObject,true)
			SetVisible(self.notActiveCountBG.gameObject,false)

			self.activeCountTxt.text = string.format(ConfigLanguage.Equip.Piece,info.suitCount)

			self.suitValueTxt.text = info.attrValue
			SetVisible(self.active_icon.gameObject,true)
			SetVisible(self.active_not_icon.gameObject,false)
		else
			SetVisible(self.activeCountBG.gameObject,false)
			SetVisible(self.notActiveCountBG.gameObject,true)

			self.notActiveCountTxt.text = string.format(ConfigLanguage.Equip.Piece,info.suitCount)
			self.suitValueTxt.text = info.attrValue

			SetVisible(self.active_icon.gameObject,false)
			SetVisible(self.active_not_icon.gameObject,true)
		end

		if info.index == 3 then
			SetVisible(self.line.gameObject,false)
		end
		--self.valueTempTxt.text = info.attrValue
		--self.itemRectTra.sizeDelta = Vector2(self.itemRectTra.sizeDelta.x,self.valueTempTxt.preferredHeight + 20)
		--self.lineRectTra.anchoredPosition = Vector2(self.lineRectTra.anchoredPosition.x,-self.suitValueTxt.preferredHeight - 15)
	else
		self.need_loaded_end = true
		self.isActive = isActive
		self.info = info
	end
end

function SuitAttrItemSettor:DisShowInfo()
	if self.is_loaded then
		self.activeCountTxt.text = ""
		self.suitValueTxt.text = ""
		SetVisible(self.activeCountBG.gameObject,false)
		SetVisible(self.notActiveCountBG.gameObject,false)
	else
		self.need_dis_show = true
	end
end
