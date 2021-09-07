ShengXiaoEquipView = ShengXiaoEquipView or BaseClass(BaseRender)

local Defult_Icon_List = {
	27001, 27002, 27003, 27004, 27005
}

local HIDE_NUM = 6

function ShengXiaoEquipView:__init()
	self.lbl_cost_desc = self:FindVariable("lbl_cost_desc")
	self.can_level_up = self:FindVariable("can_level_up")
	self.cell_list = {}
	self.list_view = self:FindObj("ShengXiaoList")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.equip_list = {}
	self.red_point_list = {}
	for i = 1, 5 do
		self.equip_list[i] = ShengXiaoEquipCell.New()
		self.equip_list[i]:SetInstanceParent(self:FindObj("EquipCell" .. i))
		self.equip_list[i]:IgnoreArrow(true)
		self.equip_list[i]:ListenClick(BindTool.Bind(self.ClickEquipItem, self, i))

		self.red_point_list[i] = self:FindVariable("ShowRedPoint"..i)
	end

	self.cur_equip_cell = ShengXiaoEquipCell.New()
	self.cur_equip_cell:SetInstanceParent(self:FindObj("CurEquip"))
	self.cur_equip_cell:IgnoreArrow(true)
	self.cur_equip_cell:SetIsShowTips(false)
	self.cur_equip_cell:ShowHighLight(false)

	self.next_equip_cell = ShengXiaoEquipCell.New()
	self.next_equip_cell:SetInstanceParent(self:FindObj("NextEquip"))
	self.next_equip_cell:IgnoreArrow(true)
	self.next_equip_cell:SetIsShowTips(false)
	self.next_equip_cell:ShowHighLight(false)

	self.is_max_level = self:FindVariable("max_level")
	self.big_pic_path = self:FindVariable("big_pic_path")
	self.fight_power = self:FindVariable("FightPower")
	self.up_level_btn_txt = self:FindVariable("UpLevelBtnTxt")

	self:ListenEvent("ClickLevelUp", BindTool.Bind(self.ClickLevelUp, self))
	self:ListenEvent("OnClickListLeft", BindTool.Bind(self.OnClickListLeft, self))
	self:ListenEvent("OnClickListRight", BindTool.Bind(self.OnClickListRight, self))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))

	self.attr_cell_list = {}
	self.attr_list = self:FindObj("AttrList")
	local list_delegate = self.attr_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfAttrCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshAttrCell, self)

	self.equip_index = self.equip_index or 1
	self.list_index = self.list_index or 1
	self.is_load_effect = false
	self.effect_obj = nil

	self.success_effect = self:FindObj("SuccessEffect")
	self.up_level_btn = self:FindObj("UpLevelBtn")

	self.center_display = self:FindObj("center_display")
end

function ShengXiaoEquipView:__delete()
	if nil ~= self.cur_equip_cell then
		self.cur_equip_cell:DeleteMe()
		self.cur_equip_cell = nil
	end
	if nil ~= self.next_equip_cell then
		self.next_equip_cell:DeleteMe()
		self.next_equip_cell = nil
	end
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
	for _,v in pairs(self.equip_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.equip_list = {}

	self.is_load_effect = nil
	if self.effect_obj then
		GameObject.Destroy(self.effect_obj)
		self.effect_obj = nil
	end
	self.success_effect = nil

	if nil ~= self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

	if self.tweener1 then
		self.tweener1:Pause()
		self.tweener1 = nil
	end
end


function ShengXiaoEquipView:GetNumberOfAttrCells()
	return 3
end

function ShengXiaoEquipView:RefreshAttrCell(cell, data_index)
	data_index = data_index + 1
	local attr_cell = self.attr_cell_list[cell]
	if attr_cell == nil then
		attr_cell = AttrItem.New(cell.gameObject)
		self.attr_cell_list[cell] = attr_cell
	end

	local cur_equip_level = ShengXiaoData.Instance:GetOneEquipLevel(self.list_index, self.equip_index)
	local cur_cfg = ShengXiaoData.Instance:GetEquipCfgByIndexAndLevel(self.equip_index - 1, cur_equip_level)
	local one_level_attr = CommonDataManager.GetAttributteNoUnderline(cur_cfg)
	local show_attr = CommonDataManager.GetAttrNameAndValueByClass(one_level_attr)
	local data = {}
	if cur_equip_level == 0 then
		cur_cfg = ShengXiaoData.Instance:GetEquipCfgByIndexAndLevel(self.equip_index - 1, 1)
		one_level_attr = CommonDataManager.GetAttributteNoUnderline(cur_cfg)
		show_attr = CommonDataManager.GetAttrNameAndValueByClass(one_level_attr)
		data = show_attr[data_index]
		data.value = 0
	else
		data = show_attr[data_index]
	end
	data.show_add = cur_equip_level < GameEnum.CHINESE_ZODIAC_MAX_EQUIP_LEVEL
	if cur_equip_level < GameEnum.CHINESE_ZODIAC_MAX_EQUIP_LEVEL then
		local next_equip_cfg = ShengXiaoData.Instance:GetEquipCfgByIndexAndLevel(self.equip_index - 1, cur_equip_level + 1)
		local attr_cfg = CommonDataManager.GetAttributteNoUnderline(next_equip_cfg)
		local next_show_attr = CommonDataManager.GetAttrNameAndValueByClass(attr_cfg)
		data.add_attr = next_show_attr[data_index].value - data.value
	else
		data.add_attr = 0
	end
	attr_cell:SetData(data)
end

function ShengXiaoEquipView:GetNumberOfCells()
	return 12
end

function ShengXiaoEquipView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local star_cell = self.cell_list[cell]
	if star_cell == nil then
		star_cell = ShengXiaoItem.New(cell.gameObject)
		star_cell.root_node.toggle.group = self.list_view.toggle_group
		star_cell.shengxiao_equip_view = self
		self.cell_list[cell] = star_cell
	end

	star_cell:SetItemIndex(data_index)
	star_cell:SetData({})
end

function ShengXiaoEquipView:ClickEquipItem(index)
	-- if index == self.equip_index then
		-- return
	-- end
	self.equip_index = index
	self:FlushRightInfo()
	self:FlushEquipInfo()
end

function ShengXiaoEquipView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(176)
end

function ShengXiaoEquipView:OnClickListRight()
	if self.list_view.scroll_rect.horizontalNormalizedPosition + 1 / HIDE_NUM >= 1 then
		self.list_view.scroll_rect.horizontalNormalizedPosition = 1
		return
	end
	self.list_view.scroll_rect.horizontalNormalizedPosition = self.list_view.scroll_rect.horizontalNormalizedPosition + 1 / HIDE_NUM
end

function ShengXiaoEquipView:OnClickListLeft()
	if self.list_view.scroll_rect.horizontalNormalizedPosition - 1 / HIDE_NUM <= 0 then
		self.list_view.scroll_rect.horizontalNormalizedPosition = 0
		return
	end
	self.list_view.scroll_rect.horizontalNormalizedPosition = self.list_view.scroll_rect.horizontalNormalizedPosition - 1 / HIDE_NUM
end

function ShengXiaoEquipView:ClickLevelUp()
	local cur_equip_level = ShengXiaoData.Instance:GetOneEquipLevel(self.list_index, self.equip_index)
	if cur_equip_level < GameEnum.CHINESE_ZODIAC_MAX_EQUIP_LEVEL then
		local equip_next_cfg = ShengXiaoData.Instance:GetEquipCfgByIndexAndLevel(self.equip_index - 1, cur_equip_level + 1)
		local bag_num = ItemData.Instance:GetItemNumInBagById(equip_next_cfg.consume_stuff_id)
		if bag_num < equip_next_cfg.consume_stuff_num then
			-- SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.NoEquipStuff)
			TipsCtrl.Instance:ShowItemGetWayView(equip_next_cfg.consume_stuff_id)
			return
		end
	end

	ShengXiaoCtrl.Instance:SendPromoteEquipRequest(self.list_index - 1, self.equip_index - 1)
end

--刷新右边面板
function ShengXiaoEquipView:FlushRightInfo()
	self.can_level_up:SetValue(true)
	self.big_pic_path:SetAsset(ResPath.GetShengXiaoBigIcon2(self.list_index))
	local cur_equip_level = ShengXiaoData.Instance:GetOneEquipLevel(self.list_index, self.equip_index)
	local data = {}
	data.level = cur_equip_level
	data.item_id = Defult_Icon_List[self.equip_index]
	local equip_cfg = ShengXiaoData.Instance:GetEquipCfgByIndexAndLevel(self.equip_index - 1, cur_equip_level)
	data.color = equip_cfg.color
	self.cur_equip_cell:SetData(data)

	if cur_equip_level >= GameEnum.CHINESE_ZODIAC_MAX_EQUIP_LEVEL then
		self.is_max_level:SetValue(true)
		self.lbl_cost_desc:SetValue(Language.ShengXiao.MaxLevel)
		self.up_level_btn.grayscale.GrayScale = 255
		self.can_level_up:SetValue(false)
		self.up_level_btn_txt:SetValue(Language.ShengXiao.btnMaxLevel)
	else
		self.is_max_level:SetValue(false)
		local next_data = {}
		next_data.level = cur_equip_level + 1
		next_data.item_id = Defult_Icon_List[self.equip_index]
		local equip_next_cfg = ShengXiaoData.Instance:GetEquipCfgByIndexAndLevel(self.equip_index - 1, cur_equip_level + 1)
		next_data.color = equip_next_cfg.color
		self.next_equip_cell:SetData(next_data)

		local bag_num = ItemData.Instance:GetItemNumInBagById(equip_next_cfg.consume_stuff_id)
		local item_name = ItemData.Instance:GetItemName(equip_next_cfg.consume_stuff_id)
		local item_cfg = ItemData.Instance:GetItemConfig(equip_next_cfg.consume_stuff_id)
		local item_color = SOUL_NAME_COLOR[item_cfg.color] or TEXT_COLOR.WHITE
		local cost_desc = string.format(Language.ShengXiao.StuffDecs, item_color, item_name, bag_num, equip_next_cfg.consume_stuff_num)
		local cost_desc1 = string.format(Language.ShengXiao.StuffDecs2, item_color, item_name, bag_num, equip_next_cfg.consume_stuff_num)
		self.lbl_cost_desc:SetValue(bag_num >= equip_next_cfg.consume_stuff_num and cost_desc or cost_desc1)
		self.up_level_btn.grayscale.GrayScale = 0

		local star_level = ShengXiaoData.Instance:GetZodiacLevelByIndex(self.list_index)
		if star_level < equip_next_cfg.zodiac_level then
			self.lbl_cost_desc:SetValue(string.format(Language.ShengXiao.OpenEquip, star_level, equip_next_cfg.zodiac_level))
			self.up_level_btn.grayscale.GrayScale = 255
			self.can_level_up:SetValue(false)
		end
		self.up_level_btn_txt:SetValue(Language.ShengXiao.UpGrade)
	end
	self.fight_power:SetValue(CommonDataManager.GetCapability(equip_cfg))
	self.attr_list.scroller:ReloadData(0)
end


function ShengXiaoEquipView:FlushEquipInfo()
	local equip_level_list = ShengXiaoData.Instance:GetEquipLevelListByindex(self.list_index)
	for i = 1, 5 do
		local data = {}
		data.level = equip_level_list[i]
		data.item_id = Defult_Icon_List[i]
		local equip_cfg = ShengXiaoData.Instance:GetEquipCfgByIndexAndLevel(i - 1, data.level)
		data.color = equip_cfg.color
		self.equip_list[i]:SetData(data)
		self.equip_list[i]:SetHighLight(i == self.equip_index)

		self.red_point_list[i]:SetValue(ShengXiaoData.Instance:GetEquipRemindByEquipTypeAndIndex(self.list_index, i))
	end
end

function ShengXiaoEquipView:GetSelectIndex()
	return self.list_index or 1
end

function ShengXiaoEquipView:SetSelectIndex(index)
	if index then
		self.list_index = index
	end
	self:FlushFlyAni()
end

function ShengXiaoEquipView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

--刷新所有装备格子信息
function ShengXiaoEquipView:FlushListCell()
	for k,v in pairs(self.cell_list) do
		v:OnFlush()
	end
end

function ShengXiaoEquipView:FlushAll()
	self:FlushListCell()
	self:FlushEquipInfo()
	self:FlushRightInfo()
end

function ShengXiaoEquipView:AfterSuccessUp()
	if not self.effect_obj then
		local bundle, asset = "effects2/prefab/ui/ui_duanzaochenggeng_prefab", "UI_duanzaochenggeng"
		self.is_load_effect =  true
		PrefabPool.Instance:Load(AssetID(bundle, asset), function(prefab)
		if prefab then
			local obj = GameObject.Instantiate(prefab)
			PrefabPool.Instance:Free(prefab)
			local transform = obj.transform
			transform:SetParent(self.success_effect.transform, false)
			self.effect_obj = obj.gameObject
			self.is_load_effect = false

			if nil == self.timer_quest then
				self.timer_quest = GlobalTimerQuest:AddDelayTimer(function()
						if self.effect_obj then
							GameObject.Destroy(self.effect_obj)
							self.effect_obj = nil
						end
						GlobalTimerQuest:CancelQuest(self.timer_quest)
						self.timer_quest = nil
				end, 1.5)
			end

			end
		end)
	 end
end

function ShengXiaoEquipView:FlushFlyAni(index)
	if self.tweener1 then
		self.tweener1:Pause()
	end

	self.center_display.rect:SetLocalPosition(0, 0, 0)
	self.center_display.rect:SetLocalScale(0, 0, 0)

	local target_pos = {x = 0, y = 0, z = 0}
	local target_scale = Vector3(1, 1, 1)
	self.tweener1 = self.center_display.rect:DOAnchorPos(target_pos, 0.7, false)
	self.tweener1 = self.center_display.rect:DOScale(target_scale, 0.7)
end


---------------------ShengXiaoItem--------------------------------
ShengXiaoItem = ShengXiaoItem or BaseClass(BaseCell)

function ShengXiaoItem:__init()
	self.shengxiao_equip_view = nil
	self.show_hl = self:FindVariable("show_hl")
	self.show_rp = self:FindVariable("show_rp")
	self.level = self:FindVariable("level")
	self.image_path = self:FindVariable("image_path")
	self.show_lock = self:FindVariable("show_lock")

	self:ListenEvent("ClickItem", BindTool.Bind(self.OnClickItem, self))
end

function ShengXiaoItem:__delete()
	self.shengxiao_equip_view = nil
end

function ShengXiaoItem:SetItemIndex(index)
	self.item_index = index
end

function ShengXiaoItem:OnFlush()
	self:FlushHL()
	local zodiac_progress = ShengXiaoData.Instance:GetZodiacProgress()
	self.show_lock:SetValue(not ShengXiaoData.Instance:GetCurCanUpByIndex(self.item_index) or self.item_index > zodiac_progress)
	local level = ShengXiaoData.Instance:GetZodiacLevelByIndex(self.item_index)
	self.level:SetValue(level)
	self.show_rp:SetValue(ShengXiaoData.Instance:GetEquipRemindByStarIndex(self.item_index))
	self.image_path:SetAsset(ResPath.GetShengXiaoIcon(self.item_index))
end

function ShengXiaoItem:OnClickItem(is_click)
	if is_click then
		local select_index = self.shengxiao_equip_view:GetSelectIndex()
		if select_index == self.item_index then
			return
		end
		local zodiac_progress = ShengXiaoData.Instance:GetZodiacProgress()
		if not ShengXiaoData.Instance:GetCurCanUpByIndex(self.item_index) or self.item_index > zodiac_progress then
			return
		end
		self.shengxiao_equip_view:SetSelectIndex(self.item_index)
		self.shengxiao_equip_view:FlushAllHL()
		self.shengxiao_equip_view:FlushEquipInfo()
		self.shengxiao_equip_view:FlushRightInfo()
	end
end

function ShengXiaoItem:FlushHL()
	local select_index = self.shengxiao_equip_view:GetSelectIndex()
	self.show_hl:SetValue(select_index == self.item_index)
end


---------------------ShengXiaoEquipCell--------------------------------
ShengXiaoEquipCell = ShengXiaoEquipCell or BaseClass(ItemCell)

function ShengXiaoEquipCell:SetData(data, is_from_bag)
	ItemCell.SetData(self, data, is_from_bag)
	self:ShowQuality(false)
	self:SetIconGrayScale(true)
	self.show_equip_grade:SetValue(false)
	if self.data and self.data.level > 0 then
		self:SetIconGrayScale(false)
		self.show_equip_grade:SetValue(true)
		self:ShowQuality(true)
		local bundle1, asset1 = ResPath.GetQualityIcon(self.data.color)
		self.quality:SetAsset(bundle1, asset1)
		self:SetGrade(self.data.level)
	end
end

function ShengXiaoEquipCell:SetGrade(grade)
	if nil ~= self.show_equip_grade and self.equip_grade then
		self.equip_grade:SetValue(grade % 10 > 0 and grade % 10 or 10)
	end
end
