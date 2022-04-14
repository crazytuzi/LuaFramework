--
-- @Author: chk
-- @Date:   2019-01-15 21:00:48
--
EquipTipView = EquipTipView or class("EquipTipView", BaseGoodsTip)
local this = EquipTipView

function EquipTipView:ctor(parent_node, layer)
	self.abName = "system"
	self.assetName = "EquipDetailView"
	self.layer = layer
	
	self.careerSettor = nil
	self.has_compose = false
	
	self.compose_need_icons = {}
	self:BeforeLoad()
end

function EquipTipView:BeforeLoad()
	EquipTipView.super.Load(self)
end

function EquipTipView:dctor()
	
	if self.careerSettor ~= nil then
		self.careerSettor:destroy()
		self.careerSettor = nil
    end
    
	if self.bestAttrStr then
		self.bestAttrStr:destroy()
		self.bestAttrStr = nil
    end
    
	if self.stoneItemSettor then
		self.stoneItemSettor:destroy()
		self.stoneItemSettor = nil
    end
    
	if self.baseAttrStr then
		self.baseAttrStr:destroy()
		self.baseAttrStr = nil
    end
    
    if self.validDayStr then
        self.validDayStr:destroy()
        self.validDayStr = nil
    end
    
	if self.marriageAttrStr then
		self.marriageAttrStr:destroy()
		self.marriageAttrStr = nil
	end	
	if self.suitItemSettor then
		self.suitItemSettor:destroy()
		self.suitItemSettor = nil
	end
	if self.castAttrItem then
		self.castAttrItem:destroy()
		self.castAttrItem = nil
	end
	if self.refineAttrItem then
		self.refineAttrItem:destroy()
		self.refineAttrItem = nil
	end
	if self.compose_need_icons then
		for i=1, #self.compose_need_icons do
			self.compose_need_icons[i]:destroy()
		end
		self.compose_need_icons = nil
	end
end

function EquipTipView:InitData()
	EquipTipView.super.InitData(self)
	
	--self.maxScrollViewHeight = 371
	self.minScrollViewHeight = 160
	--self.maxViewHeight = 555
	self.addValueTemp = 180
end

function EquipTipView:LoadCallBack()
	self.nodes = {
		"had_put_on",
		"wearLV/wareValue",
		"compositeScore/comScoreValue",
		"equipScore/scoreContain/scoreValue",
		"equipScore/scoreContain/upArrow",
		"equipScore/scoreContain/downArrow",
		"careerInfo",
		"careerInfo/careerCon",
		"careerInfo/careerCon/equipPos",
		"careerInfo/careerCon/career",
		"careerContain",
		"compose",
		"compose/compose_title",
		"compose/compose_desc",
		"compose/compose_style1",
		"compose/compose_style2",
		"compose/compose_style1/need_icon1",
		"compose/compose_style1/need_icon2",
		"compose/compose_style1/need_icon3",
		"compose/compose_style2/need_icon4",
		"compose/compose_style2/need_icon5",
	}
	self:GetChildren(self.nodes)
	self.scoreValueTxt = self.scoreValue:GetComponent("Text")
	self.careerContainRect = self.careerContain:GetComponent('RectTransform')
	self.compose_title = GetText(self.compose_title)
	self.compose_desc = GetText(self.compose_desc)
	EquipTipView.super.LoadCallBack(self)
	--self:AddEvent()
end

function EquipTipView:AddEvent()
	self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.DelItems, handler(self, self.DelItem))
	self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.CloseTipView, handler(self, self.CloseTipView))
	self.events[#self.events + 1] = GlobalEvent:AddListener(EquipEvent.PutOffEquip, handler(self, self.CloseTipView))
end

function EquipTipView:SetData(data)
	
end

--param包含参数
--cfg  该物品(装备)的配置
--p_item 服务器给的，服务器没给，只传cfg就好
--model 管理该tip数据的实例
--is_compare --是否有对比
--operate_param --操作参数
function EquipTipView:ShowTip(param)
	self.is_compare = param["is_compare"]
	EquipTipView.super.ShowTip(self, param)
	
	
	self.wareValue:GetComponent('Text').text = GetLevelShow(self.item_cfg.level)
	self:SetSlot(self.cfg.slot)
	
	--self:SetCareer(self.cfg.career, self.cfg.id, self.cfg.wake)
	if self.goods_item ~= nil then
		local rare3Attr = EquipModel.GetInstance():TranslateAttr(self.goods_item.equip.rare3)
		local rare2Attr = EquipModel.GetInstance():TranslateAttr(self.goods_item.equip.rare2)
		local rare1Attr = EquipModel.GetInstance():TranslateAttr(self.goods_item.equip.rare1)
		---结婚属性
		local rare4Attr = EquipModel.GetInstance():TranslateAttr(self.goods_item.equip.marriage.rare)
		
		self:SetBaseAttr(self.goods_item)
		self:SetBestAttr(rare3Attr, rare2Attr, rare1Attr)
		self:SetCast()
		self:SetRefine()
		self:SetMarriageAttr(rare4Attr)
		self:SetValidDate(self.goods_item.etime)
		self:CompareEquipScore()
	else
		self:SetBaseAttrByItemId(self.cfg.base)
		self:SetBestAttrInCfg(self.cfg.rare3, self.cfg.rare2, self.cfg.rare1, self.cfg.attr)
		self:SetValidDateWithCfg(Config.db_item[self.cfg.id].expire)
		self:CompareEquipScoreByEquipId()
	end
	
	self:SetDes(self.item_cfg.desc .. "\n")
	if self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
		local equip_cfg = Config.db_equip[self.cfg.id]
		if self.model:GetEquipCanStoneBySlot(equip_cfg.slot) then
			self:SetStone()
		end
		self:SetSuit()
		self:SetCareer()
		self:SetCompose()
	else
		SetVisible(self.compose, false)
	end
	
	SetVisible(self.careerInfo.gameObject, false)
	
	self:DealCreateAttEnd()
	
	if not self.is_compare then
		GlobalEvent:Brocast(GoodsEvent.CloseTipView)
		
		self:AddClickCloseBtn()
		self:SetViewPosition()
		
		self:AddEvent()
	else
		SetVisible(self.mask.gameObject, false)
	end
	
	local puton_item = self.model:GetPutOn(self.item_id)
	if puton_item ~= nil and puton_item.uid == self.uid then
		SetVisible(self.had_put_on.gameObject, true)
	else
		SetVisible(self.had_put_on.gameObject, false)
	end
	
	
	if puton_item ~= nil and puton_item.uid ~= self.uid then
		local pos = self.transform.position
		local bg_x = ScreenWidth / 2 + pos.x * 100 - self.bgRectTra.sizeDelta.x
		local bg_y = pos.y * 100 + ScreenHeight / 2
		
		local xw = bg_x + self.bgRectTra.sizeDelta.x * 2
		local yw = bg_y - self.bgRectTra.sizeDelta.y
		
		--if self.operate_param ~= nil then
		xw = xw
		--end
		param["bg_x"] = bg_x
		param["bg_y"] = bg_y
		param["xw"] = xw
		param["yw"] = yw
		
		GlobalEvent:Brocast(EquipEvent.BrocastSetViewPosition, param)
	end
end

function EquipTipView:ShowScoreUpArrow(upShow, downShow)
	local showDownArrow = not upShow
	if downShow ~= nil then
		showDownArrow = downShow
	end
	SetVisible(self.upArrow.gameObject, upShow)
	SetVisible(self.downArrow.gameObject, showDownArrow)
	SetLocalPositionX(self.upArrow, self.scoreValueTxt.preferredWidth)
	SetLocalPositionX(self.downArrow, self.scoreValueTxt.preferredWidth)
end

function EquipTipView:CompareEquipScore()
	if self.is_compare then
		local putOnEquip = self.model:GetPutOn(self.goods_item.id)
		if putOnEquip ~= nil and putOnEquip.uid ~= self.goods_item.uid then
			local w = self.scoreValueTxt.preferredWidth
			local difScore = self.goods_item.score - putOnEquip.score
			if difScore > 0 then
				--self.scoreValueTxt.text = string.format("<color=#%s>%s</color>",
				--        ColorUtil.GetColor(ColorUtil.ColorType.Green), self.goods_item.score)
				self.scoreValueTxt.text = self.goods_item.score
				self:ShowScoreUpArrow(true)
			elseif difScore < 0 then
				--self.scoreValueTxt.text = string.format("<color=#%s>%s</color>",
				--        ColorUtil.GetColor(ColorUtil.ColorType.Red), self.goods_item.score)
				self.scoreValueTxt.text = self.goods_item.score
				self:ShowScoreUpArrow(false)
			else
				self.scoreValueTxt.text = self.goods_item.score
				self:ShowScoreUpArrow(false, false)
			end
		else
			self.scoreValueTxt.text = self.goods_item.score
			self:ShowScoreUpArrow(false, false)
		end
	else
		local putOnEquip = self.model:GetPutOn(self.goods_item.id)
		if putOnEquip ~= nil and putOnEquip.uid == self.goods_item.uid then
			self.scoreValueTxt.text = self.goods_item.score
			self:ShowScoreUpArrow(false, false)
		else
			--self.scoreValueTxt.text = string.format("<color=#%s>%s</color>",
			--        ColorUtil.GetColor(ColorUtil.ColorType.Green), self.goods_item.score)
			self.scoreValueTxt.text = self.goods_item.score
			self:ShowScoreUpArrow(true , false)
		end
		
	end
end

function EquipTipView:CompareEquipScoreByEquipId()


	local score = 0;
    if self.item_cfg and self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_BEAST then
        score = EquipModel.Instance:GetBeastEquipScore(self.item_id);
	elseif self.item_cfg and self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_TOTEMS_EQUIP then
		score = EquipModel.Instance:GetTosmsEquipScore(self.item_id);
	else
        score = self.model:GetEquipScoreInCfg(self.item_id)
    end
	if self.is_compare then
		local putOnEquip = self.model:GetPutOn(self.item_id)
		if putOnEquip.uid ~= self.item_id then
			
			local difScore = score - putOnEquip.score
			if difScore > 0 then
				self.scoreValueTxt.text = string.format("<color=#%s>%s</color>",
					ColorUtil.GetColor(ColorUtil.ColorType.Green), score)
				self:ShowScoreUpArrow(true)
			elseif difScore < 0 then
				self.scoreValueTxt.text = string.format("<color=#%s>%s</color>",
					ColorUtil.GetColor(ColorUtil.ColorType.Red), score)
				self:ShowScoreUpArrow(false)
			else
				self.scoreValueTxt.text = score .. ""
				self:ShowScoreUpArrow(false, false)
			end
			
		end
	else
		self.scoreValueTxt.text = score .. ""
	end
end


--更新部位
function EquipTipView:SetSlot(slot)
	if not slot then return end
	local key = enum.ITEM_TYPE.ITEM_TYPE_EQUIP .. "@" .. slot
	if Config.db_item_type[key] ~= nil then
		local stype = Config.db_item_type[key].stype
		self.equipPos:GetComponent('Text').text = enumName.ITEM_STYPE[stype]
	end
end

--设置铸造属性
function EquipTipView:SetCast()
	if self.goods_item.equip.cast > 0 then
		local Attr = EquipStrongModel.GetInstance():CalcCastAttr(self.goods_item, self.goods_item.equip.cast)

		if not self.castAttrItem then
			self.castAttrItem = EquipAttrItemSettor(self.Content)
		end
		local attrInfo = ""
		for k, v in pairs(Attr) do
			local valueInfo = self.model:GetAttrTypeInfo(k, v)
			attrInfo = attrInfo .. string.format("<color=#675344>%s</color>", enumName.ATTR[k]) ..
			": " .. string.format("<color=#af3f3f>%s</color>", valueInfo)
			attrInfo = attrInfo .. "\n"
		end
		
		self.valueTempTxt.text = attrInfo
		local height = self.valueTempTxt.preferredHeight + 25 + 10
		self.castAttrItem:UpdatInfo({ title = ConfigLanguage.AttrTypeName.CastAttr, info = attrInfo, posY = self.height, itemHeight = height })
		
		self.height = self.height + height
	end
end

--设置洗练属性
function EquipTipView:SetRefine()
	if not table.isempty(self.goods_item.equip.refine) then
		local refine = self.goods_item.equip.refine
		if not self.refineAttrItem then
			self.refineAttrItem = EquipAttrItemSettor(self.Content)
		end
		local attrInfo = ""
		for i=1, #refine do
			local k = refine[i].attr
			local v = refine[i].value
			local color = refine[i].color
			if color == enum.COLOR.COLOR_WHITE then
				color = 99
			end
			local valueInfo = self.model:GetAttrTypeInfo(k, v)
			attrInfo = attrInfo .. ColorUtil.GetHtmlStr(color, enumName.ATTR[k] .. "  " .. valueInfo)
			attrInfo = attrInfo .. "\n"
		end

		self.valueTempTxt.text = attrInfo
		local height = self.valueTempTxt.preferredHeight + 25 + 10
		self.refineAttrItem:UpdatInfo({ title = ConfigLanguage.AttrTypeName.RefineAttr, info = attrInfo, posY = self.height, itemHeight = height })
		
		self.height = self.height + height
	end
end

--(玩家身上的)套装
function EquipTipView:SetSuit()
	if not self.goods_item then
		return
	end
	local suite = self.goods_item.equip.suite
	if table.isempty(suite) then
		self:DealCreateAttEnd()
		return
	end
	
	local suite_id, num = next(suite)
	local suitCfg = EquipSuitModel:GetInstance():GetEquipSuite(suite_id)
	local attrsTb = String2Table(suitCfg.attribs)
	
	if table.isempty(attrsTb) then
		self:DealCreateAttEnd()
		return
	end
	
	local totalCount = #String2Table(suitCfg.slots)
	local hasCount = num
	local showSuitLv = suitCfg.level

	local suitename = EquipSuitModel:GetInstance():GetSuitLvName(showSuitLv)
	local titleInfo = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.White),
			"【" .. suitename .. "】" .. suitename .. "" .. suitCfg.title)
	local countInfo = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.YellowWish),
			"(" .. hasCount .. "/" .. totalCount .. ")")
	titleInfo = titleInfo .. countInfo
	
	local attrInfoTbl = {}
	local height = 0
	for i, v in pairs(attrsTb) do
		local active = false
		if hasCount >= v[1] then
			active = true
		end
		
		local attrInfo = ""
		local countInfo = ""
		local attrCount = table.nums(v[2])
		local crntCount = 1
		for ii, vv in pairs(v[2]) do
			if active then
				countInfo = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.Orange),
					string.format("【" .. ConfigLanguage.Equip.Piece .. "】", v[1]))
				attrInfo = attrInfo .. string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.Yellow),
					enumName.ATTR[vv[1]])
				
				attrInfo = attrInfo .. string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.GreenDeep),
					"  " .. self.model:GetAttrTypeInfo(vv[1], vv[2]))
			else
				countInfo = string.format("<color=#8E8E8E>%s</color>", string.format("【" .. ConfigLanguage.Equip.Piece .. "】", v[1]))
				attrInfo = attrInfo .. string.format("<color=#8E8E8E>%s</color>", enumName.ATTR[vv[1]] ..
					"  " .. self.model:GetAttrTypeInfo(vv[1], vv[2]))
			end
			
			if crntCount < attrCount then
				attrInfo = attrInfo .. "\n"
			end
			
			crntCount = crntCount + 1
		end
		
		self.valueTempTxt.text = attrInfo
		height = height + self.valueTempTxt.preferredHeight + 10
		table.insert(attrInfoTbl, { active = active, count = countInfo, value = attrInfo })
	end
	
	height = height + 14 + 25
	--self.height = height
	if self.suitItemSettor == nil then
		self.suitItemSettor = EquipSuitInfoItemSettor(self.Content)
	end
	
	if self.goods_item ~= nil then
		self.suitItemSettor:UpdateInfo({ title = titleInfo, attrInfos = attrInfoTbl, posY = self.height, itemHeight = height })
	end
	
	self.height = self.height + height
	self:DealCreateAttEnd()
end

--设置(玩家的)职业
function EquipTipView:SetCareer()
	SetVisible(self.careerInfo.gameObject, false)
	if Config.db_equip[self.cfg.id] ~= nil then
		
		if self.height == 0 then			
			SetAnchoredPosition(self.careerContainRect, self.careerContainRect.anchoredPosition.x, - 140)
			self.height = self.height + 20
		else
			self.height = self.height + 20
			local y = self:DealContentHeight()
			self.careerContainRect.anchoredPosition = Vector2(self.careerContainRect.anchoredPosition.x,
				self.scrollViewRectTra.anchoredPosition.y - y) -- self.scrollViewRectTra.sizeDelta.y)
		end
		
		self.careerSettor = EquipTipCareerInfoSettor(self.careerContain)      
		self.careerSettor:SetCareer(self.cfg)
		
		
		self:DealCreateAttEnd()
	end
end

function EquipTipView:SetStone()
	local equipCfg = self.cfg
	if self.stoneItemSettor == nil then
		self.stoneItemSettor = EquipStoneInfoItemSettor(self.Content)
		local stones = {}
		local posY = self.height
		local itemHeight = 0
		
		if self.goods_item ~= nil then
			
			stones = EquipMountStoneModel.GetInstance():GetStones(self.goods_item.equip.stones,EquipMountStoneModel.GetInstance().cur_state)



			local stonesNum = table.nums(stones)
			
			itemHeight = stonesNum * 52 + (6 - stonesNum) * 22 + 22 + 20
			self.height = self.height + itemHeight
		else
			equipCfg = Config.db_equip[self.item_id]
			
			itemHeight = 6 * 22 + 22 + 20
			self.height = self.height + itemHeight
		end
		
		self.stoneItemSettor:UpdateStoneInfo(stones, equipCfg.slot, posY, itemHeight)
	end
end

--有效期
function EquipTipView:SetValidDate(time)
	if time <= 0 or time == nil then
		return
	end
	
	self.valueTempTxt.text = self.model:GetEquipDifTime(time, TimeManager.Instance:GetServerTime()) .. "\n"
	local height = self.valueTempTxt.preferredHeight + 25 + 10
	
	if self.validDayStr == nil then
		self.validDayStr = EquipAttrItemSettor(self.Content)
	end
	self.validDayStr:UpdatInfo({ title = ConfigLanguage.Mix.ValidDay, info = self.valueTempTxt.text, posY = self.height,
			itemHeight = height })
	
	self.height = self.height + height
end

--有效期
function EquipTipView:SetValidDateWithCfg(time)
	if time <= 0 then
		return
	end
	
	self.valueTempTxt.text = self.model:SplicingDifTime(0, time) .. "\n"
	local height = self.valueTempTxt.preferredHeight + 25 + 10
	
	if self.validDayStr == nil then
		self.validDayStr = EquipAttrItemSettor(self.Content)
	end
	self.validDayStr:UpdatInfo({ title = ConfigLanguage.Mix.ValidDay, info = self.valueTempTxt.text, posY = self.height,
			itemHeight = height })
	
	self.height = self.height + height
end

function EquipTipView:SetMarriageAttr(rare)
	if table.isempty(rare) then
		return
	end
	
	local attrInfo = ""
	
	for k, v in pairs(rare) do
		local valueInfo = self.model:GetAttrTypeInfo(k, v)
		attrInfo = string.format("<color=#%s>", ColorUtil.GetColor(ColorUtil.ColorType.Pink)) ..
		attrInfo .. enumName.ATTR[k] .. "  " .. valueInfo .. "</color>" .. "\n"
	end
	
	self.marriageAttrStr = EquipAttrItemSettor(self.Content)
	
	self.valueTempTxt.text = attrInfo
	local height = 0
	if self.valueTempTxt.preferredHeight <= 96 then
		height = 96
	else
		height = self.valueTempTxt.preferredHeight
	end
	height = height + 25 + 10
	self.marriageAttrStr:SetMinHeight(96)

	self.marriageAttrStr:UpdatInfo({ title = ConfigLanguage.AttrTypeName.MarriageAttr, info = attrInfo, posY = self.height,
			itemHeight = height })
	
	self.height = self.height + height
	
end

function EquipTipView:SetBestAttr(rare3, rare2, rare1)
	local attrInfo = ""
	if not table.isempty(rare3) then
		
		self.bestAttrStr = EquipAttrItemSettor(self.Content)
		
		for k, v in pairs(rare3) do
			local valueInfo = self.model:GetAttrTypeInfo(k, v)
			attrInfo = string.format("<color=#%s>", ColorUtil.GetColor(ColorUtil.ColorType.Orange)) ..
			attrInfo .. enumName.ATTR[k] .. "  " .. valueInfo .. "</color>" .. "\n"
		end
	end
	
	if not table.isempty(rare2) then
		if self.bestAttrStr == nil then
			self.bestAttrStr = EquipAttrItemSettor(self.Content)
		else
			--attrInfo = attrInfo .. "\n"
		end
		
		for k, v in pairs(rare2) do
			local valueInfo = self.model:GetAttrTypeInfo(k, v)
			attrInfo = string.format("<color=#%s>", ColorUtil.GetColor(ColorUtil.ColorType.Purple)) ..
			attrInfo .. enumName.ATTR[k] .. "  " .. valueInfo .. "</color>" .. "\n"
		end
	end
	
	if not table.isempty(rare1) then
		if self.bestAttrStr == nil then
			self.bestAttrStr = EquipAttrItemSettor(self.Content)
		else
			--attrInfo = attrInfo .. "\n"
		end
		
		for k, v in pairs(rare1) do
			local valueInfo = self.model:GetAttrTypeInfo(k, v)
			attrInfo = string.format("<color=#%s>", ColorUtil.GetColor(ColorUtil.ColorType.Blue)) ..
			attrInfo .. enumName.ATTR[k] .. "  " .. valueInfo .. "</color>" .. "\n"
		end
	end
	
	if self.bestAttrStr ~= nil then
		self.valueTempTxt.text = attrInfo
		local height = 0
		if self.valueTempTxt.preferredHeight <= 96 then
			height = 96
		else
			height = self.valueTempTxt.preferredHeight
		end
		height = height + 25 + 10
		self.bestAttrStr:SetMinHeight(96)
		self.bestAttrStr:UpdatInfo({ title = ConfigLanguage.AttrTypeName.BestAttr, info = attrInfo, posY = self.height,
				itemHeight = height })
		
		self.height = self.height + height
	end
end

---生成配置中的属性文字描述
function EquipTipView:GenerateConfigAttrText(attrStr, color, recommend)
	local attr = String2Table(attrStr) or {}
	local count = #attr
	
	if count <= 0 then
		return nil
	end
	
	local attrDesc = {}
	
	---配一条属性的时候，子项为数字，所以做额外的判断
	if type(attr[1]) ~= "table" then
		attr = { attr }
		count = #attr
	end
	
	for i = 1, count do
		local v = attr[i]
		if table.containValue(recommend, v[1]) then
			local valueInfo = EquipModel.Instance:GetAttrTypeInfo(v[1], v[2])
			local desc = string.format("<color=#%s>[%s] %s:   %s</color>",
				ColorUtil.GetColor(color), ConfigLanguage.Mix.Recommend, enumName.ATTR[v[1]], valueInfo)
			table.insert(attrDesc, desc)
		end
	end
	
	return attrDesc
end

function EquipTipView:SetBestAttrInCfg(attr3, attr2, attr1, recommend)
	recommend = String2Table(recommend)

	if #recommend == 0 then
		return
	end
	
	local attr3Desc = self:GenerateConfigAttrText(attr3, ColorUtil.ColorType.Orange, recommend)
	local attr2Desc = self:GenerateConfigAttrText(attr2, ColorUtil.ColorType.Purple, recommend)
	local attr1Desc = self:GenerateConfigAttrText(attr1, ColorUtil.ColorType.Blue, recommend)
	
	---都没有的时候就不显示了
	if (attr3Desc == nil) and (attr2Desc == nil) then
		return
	end
	
	local attrInfo = ""
	if not table.isempty(attr3Desc) then
		attrInfo = attrInfo .. table.concat(attr3Desc, "\n") .. "\n"
	end
	if not table.isempty(attr2Desc) then
		attrInfo = attrInfo .. table.concat(attr2Desc, "\n") .. "\n"
	end
	if not table.isempty(attr1Desc) then
		attrInfo = attrInfo .. table.concat(attr1Desc, "\n") .. "\n"
	end
	
	self.bestAttrStr = EquipAttrItemSettor(self.Content)
	
	--[[local rare_num = self.model:GetRareNum(ColorUtil.ColorType.Purple)
	local title = ""
	if rare_num > 0 then
		title = ConfigLanguage.AttrTypeName.BestAttr .. "(" .. string.format(ConfigLanguage.Equip.RandGetAttr,
			rare_num) .. ")"
	else
		title = ""
	end--]]
	
	self.valueTempTxt.text = attrInfo
	local height = 0
	if self.valueTempTxt.preferredHeight <= 96 then
		height = 96
	else
		height = self.valueTempTxt.preferredHeight
	end
	height = height + 25 + 10
	self.bestAttrStr:SetMinHeight(96)
	local title = ConfigLanguage.AttrTypeName.BestAttr .. "(Recommended attribute combination)"
	self.bestAttrStr:UpdatInfo({ title = title, info = attrInfo, posY = self.height, itemHeight = height })
	
	self.height = self.height + height
end


--更新基础属性
function EquipTipView:SetBaseAttr(equipItem)
	local baseAttr = EquipModel.GetInstance():TranslateAttr(equipItem.equip.base)
	if not table.isempty(baseAttr) then
		local equipCfg = self.cfg;
		local streng_key, equipStrongCfg
		if Config.db_item[self.cfg.id].type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
			streng_key = equipCfg.slot .. "@" .. equipItem.equip.stren_phase .. "@" .. equipItem.equip.stren_lv
			local escfg =  Config.db_equip_strength[streng_key]
			equipStrongCfg = escfg and String2Table(Config.db_equip_strength[streng_key].attrib) or nil
		elseif Config.db_item[self.cfg.id].type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_BEAST then
			streng_key = equipCfg.slot .. "@" .. equipItem.extra
			equipStrongCfg = String2Table(Config.db_beast_reinforce[streng_key].base)
		elseif Config.db_item[self.cfg.id].type == enum.ITEM_TYPE.ITEM_TYPE_TOTEMS_EQUIP then
			local num = equipItem.extra
			if num <= 0 then
				num = 1
			end
			streng_key = equipCfg.slot .. "@" .. num
			equipStrongCfg = String2Table(Config.db_totems_reinforce[streng_key].base)
		end
		
		self.baseAttrStr = EquipTwoAttrItemSettor(self.Content)
		local attrInfo = ""
		local strongAttrInfo = ""
		for k, v in pairs(baseAttr) do
			local valueInfo = self.model:GetAttrTypeInfo(k, v)
			attrInfo = attrInfo .. string.format("<color=#675344>%s</color>", enumName.ATTR[k]) ..
			": " .. string.format("<color=#af3f3f>%s</color>", valueInfo)
			if equipStrongCfg ~= nil then
				local strongVlu = self:GetAttStrongValue(k, equipStrongCfg)
				local valueInfo = self.model:GetAttrTypeInfo(k, strongVlu)
				if strongVlu > 0 then
					strongAttrInfo = strongAttrInfo .. "<color=#2fad25>" .. ConfigLanguage.Equip.Strong .. valueInfo .. "</color>" .. "\n"
				end
			end
			
			attrInfo = attrInfo .. "\n"
		end
		
		--local equipConfig = Config.db_equip[equipItem.id]
		if equipCfg.slot == self.model.emoSlot then
			self.baseAttrStr:SetMinHeight(120)
			
			local itemCfg = Config.db_item[equipItem.id]
			attrInfo = attrInfo .. string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.YellowWish2),
				itemCfg.desc) .. "\n"
		end
		
		self.valueTempTxt.text = attrInfo
		local height = self.valueTempTxt.preferredHeight + 25 + 10
		self.baseAttrStr:UpdatInfo({ title = ConfigLanguage.AttrTypeName.BaseAttr, info1 = attrInfo, info2 = strongAttrInfo,
				posY = self.height, itemHeight = height })
		
		self.height = self.height + height
		--self.height = self.height + 25 + 10
	end
end

function EquipTipView:GetAttStrongValue(k, attr)
	local vlu = 0
	for i, v in pairs(attr) do
		if k == v[1] then
			vlu = v[2]
			break
		end
	end

	return vlu
end

function EquipTipView:SetBaseAttrByItemId(baseAttr)
	local attrInfo = ""
	local baseAttrTbl = String2Table(baseAttr)
	self.baseAttrStr = EquipAttrItemSettor(self.Content)
	for k, v in pairs(baseAttrTbl) do
		local valueInfo = self.model:GetAttrTypeInfo(v[1], v[2])
		attrInfo = attrInfo .. string.format("<color=#675344>%s</color>", enumName.ATTR[v[1]]) .. ":  " ..
		string.format("<color=#af3f3f>%s</color>", valueInfo)
		
		attrInfo = attrInfo .. "\n"
	end
	
	--local equipConfig = Config.db_equip[self.item_id]
	if self.cfg.slot == self.model.emoSlot then
		--判断是否人物身上的小恶魔
		self.baseAttrStr:SetMinHeight(120)
		
		local itemCfg = Config.db_item[self.item_id]
		attrInfo = attrInfo .. string.format("<color=#675344>%s</color>", itemCfg.desc) .. "\n"
	end
	
	self.valueTempTxt.text = attrInfo
	local height = self.valueTempTxt.preferredHeight + 25 + 10
	self.baseAttrStr:UpdatInfo({ title = ConfigLanguage.AttrTypeName.BaseAttr, info = attrInfo, posY = self.height,
			itemHeight = height })
	
	self.height = self.height + height
end

function EquipTipView:DealCreateAttEnd()
	SetSizeDeltaY(self.contentRectTra, self.height)
	
	local srollViewY = self:DealContentHeight()
	if not self.has_compose then
		SetSizeDeltaY(self.scrollViewRectTra, srollViewY)
	end

    local y = srollViewY + self.addValueTemp
    if y > self.maxViewHeight then
        y = self.maxViewHeight
    end
    self.viewRectTra.sizeDelta = Vector2(self.viewRectTra.sizeDelta.x, y)
    self.bgRectTra.sizeDelta = self.viewRectTra.sizeDelta
end

function EquipTipView:SetCompose()
	local equip_cfg = Config.db_equip[self.cfg.id]
	local comb = equip_cfg.comb
	if comb == "" then
		SetSizeDeltaY(self.ScrollView.transform, 374)
		SetVisible(self.compose, false)
	else
		self.has_compose = true
		SetSizeDeltaY(self.ScrollView.transform, 224)
		SetVisible(self.compose, true)
		self.compose_desc.text = string.format("Can be used to combine advanced gear (Unlock at Lv.%s)", GetLevelShow(equip_cfg.com_lv))
		self.compose_title.text = string.format("T%s.%s require", equip_cfg.order, enumName.ITEM_STYPE[equip_cfg.slot])
		comb = String2Table(string.format("{%s}",comb))
		if #comb == 1 then
			SetVisible(self.compose_style1, false)
			SetVisible(self.compose_style2, true)
			self:NewComposeItem(self.need_icon4, self.cfg.id)
			self:NewComposeItem(self.need_icon5, comb[1][2])
		elseif #comb == 2 then
			SetVisible(self.compose_style1, true)
			SetVisible(self.compose_style2, false)
			self:NewComposeItem(self.need_icon1, self.cfg.id)
			self:NewComposeItem(self.need_icon2, comb[1][2])
			self:NewComposeItem(self.need_icon3, comb[2][2])
		end
	end
end

function EquipTipView:NewComposeItem(parent_node, itemid)
	local item = GoodsIconSettorTwo(parent_node)
	local param = {}
	param["item_id"] = itemid
	param["size"] = {x=60, y=60}
	param["bind"] = 2
	item:SetIcon(param)
	self.compose_need_icons[#self.compose_need_icons + 1] = item
end
