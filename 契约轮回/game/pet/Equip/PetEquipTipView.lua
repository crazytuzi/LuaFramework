--宠物装备的tip
PetEquipTipView = PetEquipTipView or class("PetEquipTipView", BaseGoodsTip)

function PetEquipTipView:ctor(parent_node,layer)
	self.abName = "system"
	self.assetName = "EquipDetailView"
	self.layer = layer

	self.pet_equip_model = PetEquipModel.GetInstance()

	self.pet_equip_cfg = nil

	self.career_settor = nil
	self.base_attr_item = nil
	self.best_attr_item = nil
	self.stren_attr_item = nil

	self:BeforeLoad()
end

function PetEquipTipView:BeforeLoad()
	PetEquipTipView.super.Load(self)
end

function PetEquipTipView:dctor()
	
	if self.career_settor then
		self.career_settor:destroy()
		self.career_settor = nil
	end

	if self.base_attr_item then
		self.base_attr_item:destroy()
		self.base_attr_item = nil
	end

	if self.best_attr_item then
		self.best_attr_item:destroy()
		self.best_attr_item = nil
	end

	if self.stren_attr_item then
		self.stren_attr_item:destroy()
		self.stren_attr_item = nil
	end
end


function PetEquipTipView:LoadCallBack()

	self.nodes = {
		"had_put_on",
		"equipScore/scoreContain/scoreValue",
		"equipScore/scoreContain/upArrow",
		"equipScore/scoreContain/downArrow",
		"equipScore",
		"compose",
		"careerContain",
		"wearLV",
	}
	self:GetChildren(self.nodes)

	SetVisible(self.compose,false)

	self:AddEvent()

	--评分text
	self.txt_score_value = GetText(self.scoreValue)
	self.txt_equip_pos = GetText(self.equipPos)

	SetVisible(self.wearLV,false)

	PetEquipTipView.super.LoadCallBack(self)
end

function PetEquipTipView:AddEvent()

	PetEquipTipView.super.AddEvent(self)

	self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.DelItems, handler(self, self.DelItem))
	self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.CloseTipView, handler(self, self.CloseTipView))
end

function PetEquipTipView:InitData()
	PetEquipTipView.super.InitData(self)
	
	self.minScrollViewHeight = 160

	self.addValueTemp = 180

	self.click_bg_close = true
end

--显示Tip
function PetEquipTipView:ShowTip(param)
	
	PetEquipTipView.super.ShowTip(self, param)

	if self.goods_item then
		self.pet_equip_cfg = self.pet_equip_model.pet_equip_cfg[self.item_id][self.goods_item.equip.stren_phase]
	else
		self.pet_equip_cfg = self.cfg
	end

	self:UpdatePutOn()
	self:UpdateScore()

	self:UpdateBaseAttr()
	self:UpdateBestAttr()
	self:UpdateStrengthenAttr()

	self:SetDes(self.item_cfg.desc .. "\n")

	self:UpdateSlot()

	--修正大小和位置
	self:DealCreateAttEnd()
	self:SetViewPosition()
	
	--logError(Table2String(self.goods_item))
end

function PetEquipTipView:SetIcon(itemId, p_item, bind)
    local param = {}
    param["model"] = BagModel.GetInstance()
    param["item_id"] = itemId
    param["size"] = { x = 72, y = 72 }
    param["p_item"] = p_item
	param["bind"] = bind

	--宠物装备的配置表特殊处理
	if not p_item then
		param["cfg"] = self.cfg
	else
		param["cfg"] = self.pet_equip_model.pet_equip_cfg[itemId][p_item.equip.stren_phase]
	end
	

    if self.iconStor == nil then
        self.iconStor = GoodsIconSettorTwo(self.icon)
    end

    self.iconStor:SetIcon(param)


end

--刷新”已装备“标志
function PetEquipTipView:UpdatePutOn()
	local slot  = Config.db_item[self.item_id].stype
	local puton_item = self.pet_equip_model:GetPutOnBySlot(slot)
	if puton_item ~= nil and puton_item.uid == self.uid then
		SetVisible(self.had_put_on.gameObject, true)
	else
		SetVisible(self.had_put_on.gameObject, false)
	end
end

--刷新评分
function PetEquipTipView:UpdateScore(  )
	if not self.goods_item then
		-- SetVisible(self.equipScore,false)
		-- return
		local score = self.pet_equip_model:GetEquipScoreInCfg(self.cfg)
		self.txt_score_value.text = score
	else
		self.txt_score_value.text = self.goods_item.score
	end
	
end


--刷新基础属性
function PetEquipTipView:UpdateBaseAttr()

	local base_attr

	if self.goods_item then
		base_attr = EquipModel.GetInstance():TranslateAttr(self.goods_item.equip.base)
	else
		base_attr = String2Table(self.cfg.base)
	end

	if not base_attr then
		return
	end

	self.base_attr_item = EquipTwoAttrItemSettor(self.Content)

	--基础属性文本
	local base_attr_info = ""

	--进阶增益文本
	local order_up_info = ""

	for k, v in pairs(base_attr) do

		local attr_index = k
		local attr_value = v

		if not self.goods_item then
			attr_index = v[1]
			attr_value = v[2]
		end

		local valueInfo = EquipModel.GetInstance():GetAttrTypeInfo(attr_index, attr_value)
		base_attr_info = base_attr_info .. string.format("<color=#675344>%s</color>", enumName.ATTR[attr_index]) ..
		": " .. string.format("<color=#af3f3f>%s</color>", valueInfo)

		base_attr_info = base_attr_info .. "\n"

	end

	self.valueTempTxt.text = base_attr_info

	local height = self.valueTempTxt.preferredHeight + 25 + 10
	self.base_attr_item:UpdatInfo({ title = ConfigLanguage.AttrTypeName.BaseAttr, info1 = base_attr_info, info2 = order_up_info,
			posY = self.height, itemHeight = height })
	
	self.height = self.height + height
end

--刷新极品属性
function PetEquipTipView:UpdateBestAttr()

	local rare3 = nil
	local rare2 = nil
	local rare1 = nil
	local pre_str = ""
	local ex_title = ""
	if not self.goods_item then
		--self.cfg = self.pet_equip_model.pet_equip_cfg[self.goods_item.id][self.goods_item.equip.stren_lv]
		rare3,rare2,rare1 = self:GetRareAttrByConfig(self.cfg)
		pre_str = "[Hot]"
		ex_title = "(Hot attri.)"
	else
		rare3 = EquipModel.GetInstance():TranslateAttr(self.goods_item.equip.rare3)
		rare2 = EquipModel.GetInstance():TranslateAttr(self.goods_item.equip.rare2)
		rare1 = EquipModel.GetInstance():TranslateAttr(self.goods_item.equip.rare1)
	end

	

	
	--极品属性文本
	local best_attr_info = ""

	--进阶增益文本
	local order_up_info = ""

	if not table.isempty(rare3) then
		
		self.best_attr_item = EquipTwoAttrItemSettor(self.Content)
		
		for k, v in pairs(rare3) do
			local valueInfo = EquipModel.GetInstance():GetAttrTypeInfo(k, v)
			best_attr_info =  string.format("<color=#%s>", ColorUtil.GetColor(ColorUtil.ColorType.Orange)) ..
			pre_str .. enumName.ATTR[k] .. "  " .. valueInfo .. "</color>" .. "\n"
		end
	end
	
	if not table.isempty(rare2) then
		if self.best_attr_item == nil then
			self.best_attr_item = EquipTwoAttrItemSettor(self.Content)
		end
		
		for k, v in pairs(rare2) do
			local valueInfo = EquipModel.GetInstance():GetAttrTypeInfo(k, v)
			best_attr_info = best_attr_info ..  string.format("<color=#%s>", ColorUtil.GetColor(ColorUtil.ColorType.Purple)) ..
			pre_str .. enumName.ATTR[k] .. "  " .. valueInfo .. "</color>" .. "\n"
		end
	end
	
	if not table.isempty(rare1) then
		if self.best_attr_item == nil then
			self.best_attr_item = EquipTwoAttrItemSettor(self.Content)
		end
		
		for k, v in pairs(rare1) do
			local valueInfo = EquipModel.GetInstance():GetAttrTypeInfo(k, v)
			best_attr_info = best_attr_info ..  string.format("<color=#%s>", ColorUtil.GetColor(ColorUtil.ColorType.Blue)) ..
			pre_str ..enumName.ATTR[k] .. "  " .. valueInfo .. "</color>" .. "\n"
		end
	end

	if self.best_attr_item ~= nil then
		self.valueTempTxt.text = best_attr_info
		local height = 0
		if self.valueTempTxt.preferredHeight <= 96 then
			height = 96
		else
			height = self.valueTempTxt.preferredHeight
		end
		height = height + 25 + 10
		self.best_attr_item:SetMinHeight(96)
		self.best_attr_item:UpdatInfo({ title = ConfigLanguage.AttrTypeName.BestAttr .. ex_title, info1 = best_attr_info, info2 = order_up_info, posY = self.height,
				itemHeight = height })
		
		self.height = self.height + height
	end
end



--刷新强化属性
function PetEquipTipView:UpdateStrengthenAttr()

	if not self.goods_item then
		return
	end

	local slot = self.pet_equip_cfg.slot
	local stren_lv = self.goods_item.equip.stren_lv
	local cfg = Config.db_pet_equip_strength[slot.."@"..stren_lv]

	if not cfg then
		return
	end

	local stren_attr = String2Table(cfg.attr)

	--强化属性文本
	local stren_attr_info = ""
	self.stren_attr_item = EquipAttrItemSettor(self.Content)

	for k, v in pairs(stren_attr) do
		local attr_index = v[1]
		local attr_value = v[2]

		local valueInfo = EquipModel.GetInstance():GetAttrTypeInfo(attr_index,attr_value)
		stren_attr_info = stren_attr_info .. string.format("<color=#675344>%s</color>", enumName.ATTR[attr_index]) ..
		": " .. string.format("<color=#af3f3f>%s</color>", valueInfo)

		stren_attr_info = stren_attr_info .. "\n"
	end

	
	self.valueTempTxt.text = stren_attr_info

	local height = self.valueTempTxt.preferredHeight + 25 + 10
	local stren_str = string.format( "Enhace Attri.(Lv.%s)",stren_lv )
	self.stren_attr_item:UpdatInfo({ title = stren_str, info = stren_attr_info,
			posY = self.height, itemHeight = height })
	
	self.height = self.height + height

end

--刷新部位
function PetEquipTipView:UpdateSlot()

	if self.height == 0 then			
		SetAnchoredPosition(self.careerContain, self.careerContain.anchoredPosition.x, - 140)
		self.height = self.height + 20
	else
		self.height = self.height + 20
		local y = self:DealContentHeight()
		self.careerContain.anchoredPosition = Vector2(self.careerContain.anchoredPosition.x,
			self.scrollViewRectTra.anchoredPosition.y - y) 
	end
	
	self.career_settor = EquipTipCareerInfoSettor(self.careerContain)    
	local slot  = Config.db_item[self.item_id].stype
	self.career_settor.pos:GetComponent('Text').text = enumName.ITEM_STYPE[slot]
	SetSizeDeltaX(self.career_settor.pos,79)
end

--根据配置表的推荐属性里获取虚拟的极品属性
function PetEquipTipView:GetRareAttrByConfig(cfg)
	local result_rare1 = {}
	local result_rare2 = {}
	local result_rare3 = {}

	local attr = String2Table(cfg.attr)
	local rare1 = String2Table(cfg.rare1)
	local rare2 = String2Table(cfg.rare2)
	local rare3 = String2Table(cfg.rare3)

	for k,v in pairs(rare1) do
		for kk,vv in pairs(attr) do
			if v[1] == vv[1] then
				result_rare1[v[1]] = v[2]
			end
		end
	end
	for k,v in pairs(rare2) do
		for kk,vv in pairs(attr) do
			if v[1] == vv[1] then
				result_rare2[v[1]] = v[2]
			end
		end
	end
	for k,v in pairs(rare3) do
		for kk,vv in pairs(attr) do
			if v[1] == vv[1] then
				result_rare3[v[1]] = v[2]
			end
		end
	end

	return result_rare3,result_rare2,result_rare1
end
