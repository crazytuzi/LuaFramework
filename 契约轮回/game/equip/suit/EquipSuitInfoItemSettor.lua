--
-- @Author: chk
-- @Date:   2018-11-05 20:10:53
--
EquipSuitInfoItemSettor = EquipSuitInfoItemSettor or class("EquipSuitInfoItemSettor",BaseItem)
local EquipSuitInfoItemSettor = EquipSuitInfoItemSettor

function EquipSuitInfoItemSettor:ctor(parent_node,layer)
	self.abName = "equip"
	self.assetName = "EquipSuitInfoItem"
	self.layer = layer

	self.height = 0
	self.suitAttrSettors = {}
	self.model = EquipSuitModel:GetInstance()
	EquipSuitInfoItemSettor.super.Load(self)
end

function EquipSuitInfoItemSettor:dctor()
	for i, v in pairs(self.suitAttrSettors) do
		v:destroy()
	end
end

function EquipSuitInfoItemSettor:LoadCallBack()
	self.nodes = {
		"attrContain",
		"line",
		"title",
		"valueTemp",
		"value",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()

	self.lineRectTra  = self.line:GetComponent('RectTransform')
	self.titleTxt = self.title:GetComponent('Text')
	self.valueTempTxt = self.valueTemp:GetComponent('Text')
	self.itemRectTra = self.transform:GetComponent('RectTransform')
	self.valueTempTxt = self.valueTemp:GetComponent('Text')
    self.valueTxt = self.value:GetComponent('Text')

	if self.need_loaded_end then
		self:UpdateInfo(self.suitInfo)
	end
end

function EquipSuitInfoItemSettor:AddEvent()
end

function EquipSuitInfoItemSettor:SetData(data)

end

function EquipSuitInfoItemSettor:UpdateInfo(suitInfo)
	if self.is_loaded then
		self.titleTxt.text = suitInfo.title
		 if table.isempty(self.suitAttrSettors) then
			 for i = 1, 3 do
				 local attrSettor = EquipSuitAttrItemSettor(self.attrContain,"UI")
				 table.insert(self.suitAttrSettors,attrSettor)
			 end
		 end

		local count = 1
		self.height = 0
		for i, v in pairs(suitInfo.attrInfos) do
			self.valueTempTxt.text = v.value
			self.suitAttrSettors[count]:UpdateInfo(v.active,{suitCount = v.count,attrValue = v.value})
			count = count + 1

			--self.height = self.height + self.valueTempTxt.preferredHeight
		end
		 self.itemRectTra.sizeDelta = Vector2(self.itemRectTra.sizeDelta.x,suitInfo.itemHeight)
		 self.itemRectTra.anchoredPosition = Vector2(self.itemRectTra.anchoredPosition.x,-suitInfo.posY)
		 self.lineRectTra.anchoredPosition = Vector2(self.lineRectTra.anchoredPosition.x,- suitInfo.itemHeight + 10)
	else
		self.need_loaded_end = true
		self.suitInfo = suitInfo
	end
end
 --function EquipSuitInfoItemSettor:UpdateInfo(equipDetail)
	-- if self.is_loaded then
	--	 local showSuitLv = self.model:GetShowSuitLvByEquip(equipDetail)
	--	 local itemCfg = Config.db_item[equipDetail.id]
	--	 local equipCfg = Config.db_equip[equipDetail.id]
	--	 local suitCount = self.model:GetActiveSuitCount(equipCfg.slot,equipCfg.order,showSuitLv)
	--	 local suitCfg = self.model:GetSuitConfig(equipCfg.slot,equipCfg.order,showSuitLv)
	--	 local attrsTb = String2Table(suitCfg.attribs)
 --
	--	 if table.isempty(attrsTb) then
	--		 return
	--	 end
 --
 --
 --
	--	 local suitCfg = self.model:GetSuitConfig(equipCfg.slot,equipCfg.order,showSuitLv)
 --
	--	 if not table.isempty(suitCfg) then
	--		 local totalCount = self.model:GetSuitCount(equipCfg.slot,equipCfg.order,showSuitLv)
	--		 local hasCount = self.model:GetActiveSuitCount(equipCfg.slot,equipCfg.order,showSuitLv)
 --
	--		 local titleInfo = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(ColorUtil.ColorType.Orange),
	--				 "【" .. self.model.suitTypeName[showSuitLv] .. "】" .. self.model.suitTypeName[showSuitLv] .. "·" .. suitCfg.title)
	--		 local countInfo = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(ColorUtil.ColorType.Yellow),
	--				 "(" .. hasCount .. "/" .. totalCount)
	--		 self.titleTxt.text = titleInfo .. countInfo
	--	 end
 --
 --
 --
 --
	--	 --if table.isempty(self.suitAttrSettors) then
	--		-- for i = 1, 3 do
	--		--	 local attrSettor = EquipSuitAttrItemSettor(self.attrContain,"UI")
	--		--	 table.insert(self.suitAttrSettors,attrSettor)
	--		-- end
	--	 --end
 --
	--	 --local notAttr = {}
	--	 --table.insert(notAttr,1)
	--	 --table.insert(notAttr,2)
	--	 --table.insert(notAttr,3)
 --
	--	 for i, v in ipairs(attrsTb) do
	--		 table.removebyvalue(notAttr,i)
 --
	--		 local active = false
	--		 if suitCount >= v[1] then
	--			 active = true
	--		 end
 --
	--		 local attrInfo = ""
	--		 local countInfo = ""
	--		 local attrCount = table.nums(v[2])
	--		 local crntCount = 1
	--		 for ii, vv in pairs(v[2]) do
	--			 if active then
	--				 countInfo = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(ColorUtil.ColorType.Orange),"[" .. v[1] .. "]")
	--				 attrInfo = attrInfo .. string.format("<color=#%s>%s</color>",ColorUtil.GetColor(ColorUtil.ColorType.Yellow),
	--						 enumName.ATTR[vv[1]])
 --
	--				 attrInfo = attrInfo .. string.format("<color=#%s>%s</color>",ColorUtil.GetColor(ColorUtil.ColorType.GreenDeep),
	--						 "  +" .. vv[2])
	--			 else
	--				 countInfo = string.format("<color=#8E8E8E>%s</color>","[" .. v[1] .. "]")
	--				 attrInfo = attrInfo .. string.format("<color=#8E8E8E>%s</color>", enumName.ATTR[vv[1]] ..
	--				 "  +" .. vv[2])
	--			 end
 --
	--			 if crntCount < attrCount then
	--				 attrInfo = attrInfo .. "\n"
	--			 end
 --
 --
	--			 crntCount = crntCount + 1
	--	 	 end
 --
	--		 self.suitAttrSettors[i]:UpdateInfo(active,{suitCount = countInfo,attrValue = attrInfo})
	--		 self.valueTempTxt.text = attrInfo
	--		 self.height = self.height + self.valueTempTxt.preferredHeight + 10
	--	 end
 --
	--	 self.itemRectTra.sizeDelta = Vector2(self.itemRectTra.sizeDelta.x,self.height + 45)
	--	 self.lineRectTra.anchoredPosition = Vector2(self.lineRectTra.anchoredPosition.x,- self.height - 35)
	-- else
	--	 self.need_loaded_end = true
	--	 self.equipItem = equipDetail
	-- end
 --end