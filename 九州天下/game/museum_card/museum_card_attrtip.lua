MuseumCardAttrTip = MuseumCardAttrTip or BaseClass(BaseView)

function MuseumCardAttrTip:__init()
	self.ui_config = {"uis/views/museumcardview", "MuseumCardAttrTip"}
	self:SetMaskBg()
	self.play_audio = true
	self.is_async_load = false
	self.active_close = false

	self.cur_select_file = 1
	self.cur_select_chapter = 1
end

function MuseumCardAttrTip:__delete()
end

function MuseumCardAttrTip:ReleaseCallBack()
	self.fight_power = nil
	self.gong_ji = nil
	self.fang_yu = nil
	self.max_hp = nil
	self.baoji = nil
	self.spec_gongji_name = nil
	self.spec_gongji_value = nil
	self.spec_fangyu_value = {}
	self.attr_list = nil

	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
end

function MuseumCardAttrTip:LoadCallBack()
	self.cell_list = {}
	
	self.fight_power = self:FindVariable("FightPower")
	self.gong_ji = self:FindVariable("GongJi")
	self.fang_yu = self:FindVariable("FangYu")
	self.max_hp = self:FindVariable("MaxHp")
	self.baoji = self:FindVariable("BaoJi")
	self.spec_gongji_name = self:FindVariable("SpecGongJiName")
	self.spec_gongji_value = self:FindVariable("SpecGongJiValue")

	self.spec_fangyu_value = {}
	for i = 1, 4 do
		self.spec_fangyu_value[i] = self:FindVariable("SpecFangYuValue" .. i)
	end

	self.attr_list = self:FindObj("AttrList")
	local list_delegate = self.attr_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self:ListenEvent("CloseWindow", BindTool.Bind(self.Close, self))
end

function MuseumCardAttrTip:SetData(cur_select_file, cur_select_chapter)
	self.cur_select_file = cur_select_file
	self.cur_select_chapter = cur_select_chapter
end

function MuseumCardAttrTip:OpenCallBack()
	if self.attr_list.scroller then
		self.attr_list.scroller:ReloadData(0)
	end
end

function MuseumCardAttrTip:GetNumberOfCells()
	local suit_seq = MuseumCardData.Instance:GetCardSuitByFileAndchap(self.cur_select_file, self.cur_select_chapter)
	return #MuseumCardData.Instance:GetCardSuitCfgById(suit_seq)
end

function MuseumCardAttrTip:RefreshCell(cell, data_index)
	data_index = data_index + 1

	local attr_cell = self.cell_list[cell]
	if attr_cell == nil then
		attr_cell = MuseumCardAttrCell.New(cell.gameObject)
		self.cell_list[cell] = attr_cell
	end
	local suit_seq = MuseumCardData.Instance:GetCardSuitByFileAndchap(self.cur_select_file, self.cur_select_chapter)
	local data = MuseumCardData.Instance:GetCardSuitCfgById(suit_seq)
	attr_cell:SetIndex(data_index)
	attr_cell:SetData(data[data_index])
end

function MuseumCardAttrTip:OnFlush(param_t)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	self.spec_gongji_name:SetValue(Language.MuseumCard.GongJiName[main_role_vo.prof])

	local data = MuseumCardData.Instance:GetCardTotalAttr(self.cur_select_file, self.cur_select_chapter)
	self.gong_ji:SetValue(data.gongji or 0)
	self.fang_yu:SetValue(data.fangyu or 0)
	self.max_hp:SetValue(data.maxhp or 0)
	self.baoji:SetValue(data.baoji or 0)
	self.spec_gongji_value:SetValue(data.spec_gongji or 0)
	for i = 1, 4 do
		self.spec_fangyu_value[i]:SetValue(data.spec_fangyu[i] or 0)
	end
	local fight_power = CommonDataManager.GetCapabilityCalculation(data)
	self.fight_power:SetValue(fight_power + (data.fight_power or 0))
end


------------------------MuseumCardAttrCell------------------------------
MuseumCardAttrCell = MuseumCardAttrCell or BaseClass(BaseCell)

function MuseumCardAttrCell:__init()
	self.suit_name = self:FindVariable("SuitName")
	self.gongji = self:FindVariable("GongJi")
	self.fangyu = self:FindVariable("FangYu")
	self.maxhp = self:FindVariable("MaxHp")
	self.baoji = self:FindVariable("BaoJi")
	self.fight_power = self:FindVariable("FightPower")
end

function MuseumCardAttrCell:__delete()
end

function MuseumCardAttrCell:OnFlush()
	if nil == self.data or nil == next(self.data) then return end

	local fight_power = CommonDataManager.GetCapabilityCalculation(self.data)

	local is_active = false
	local suit_info = MuseumCardData.Instance:GetSuitInfo()
	for k, v in pairs(suit_info) do
		if v.suit_id == self.data.suit_seq and v.card_count >= self.data.need_cards then
			is_active = true
		end
	end

	if is_active then
		self.suit_name:SetValue(string.format(Language.MuseumCard.ColorAttr, self.data.suit_name, Language.MuseumCard.HasActive))
		self.gongji:SetValue(string.format(Language.MuseumCard.ColorAttr, Language.MuseumCard.AttrName[1], self.data.gongji))
		self.fangyu:SetValue(string.format(Language.MuseumCard.ColorAttr, Language.MuseumCard.AttrName[2], self.data.fangyu))
		self.maxhp:SetValue(string.format(Language.MuseumCard.ColorAttr, Language.MuseumCard.AttrName[3], self.data.maxhp))
		self.baoji:SetValue(string.format(Language.MuseumCard.ColorAttr, Language.MuseumCard.AttrName[4], self.data.baoji))
		self.fight_power:SetValue(string.format(Language.MuseumCard.ColorPower, Language.MuseumCard.AttrName[5], fight_power))
	else
		self.suit_name:SetValue(self.data.suit_name .. string.format(Language.MuseumCard.NotActive, self.data.need_cards))
		self.gongji:SetValue(Language.MuseumCard.AttrName[1] .. self.data.gongji)
		self.fangyu:SetValue(Language.MuseumCard.AttrName[2] .. self.data.fangyu)
		self.maxhp:SetValue(Language.MuseumCard.AttrName[3] .. self.data.maxhp)
		self.baoji:SetValue(Language.MuseumCard.AttrName[4] .. self.data.baoji)
		self.fight_power:SetValue(Language.MuseumCard.AttrName[5] .. fight_power)
	end
end