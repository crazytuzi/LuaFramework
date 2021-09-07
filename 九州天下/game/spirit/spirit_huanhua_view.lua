SpiritHuanHuaView = SpiritHuanHuaView or BaseClass(BaseView)

function SpiritHuanHuaView:__init()
	self.ui_config = {"uis/views/spiritview", "SpiritHuanHuaView"}
	self.cell_list = {}
end

function SpiritHuanHuaView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickActivate", BindTool.Bind(self.OnClickActivate, self))
	self:ListenEvent("OnClickUseIma", BindTool.Bind(self.OnClickUseIma, self))
	self:ListenEvent("OnClickUpGrade", BindTool.Bind(self.OnClickUpGrade, self))
	self:ListenEvent("OnClickCancelIma", BindTool.Bind(self.OnClickCancelIma, self))

	self.gongji = self:FindVariable("GongJi")
	self.fangyu = self:FindVariable("FangYu")
	self.maxhp = self:FindVariable("ShengMing")
	self.mingzhong = self:FindVariable("MingZhong")
	self.shanbi = self:FindVariable("ShanBi")
	self.baoji = self:FindVariable("BaoJi")
	self.jianren = self:FindVariable("JianRen")

	self.spirit_name = self:FindVariable("ZuoQiName")
	self.fight_power = self:FindVariable("FightPower")
	self.cur_level = self:FindVariable("CurrentLevel")
	self.need_prop_num = self:FindVariable("ExchangeNeedNum")
	self.had_prop_num = self:FindVariable("ActivateProNum")

	self.show_active_button = self:FindVariable("IsShowActivate")
	self.show_use_iamge_button = self:FindVariable("IsShowUseImaButton")
	self.show_use_image_sprite = self:FindVariable("IsShowUseImage")
	self.show_cur_level = self:FindVariable("ShowCurrentLevel")
	self.show_upgrade_button = self:FindVariable("IsShowUpGrade")
	self.show_cancel = self:FindVariable("ShowCancelImage")

	self.display = self:FindObj("Display")
	self.list_view = self:FindObj("ListView")
	self.upgrade_button = self:FindObj("UpGradeButton")
	self.use_image_button = self:FindObj("UseImageButton")

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("Item"))

	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.HuanHuaRefreshCell, self)

	self.cur_index = 1
	self:Flush()
end

function SpiritHuanHuaView:__delete()
end

function SpiritHuanHuaView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end
end

function SpiritHuanHuaView:CloseCallBack()

end

function SpiritHuanHuaView:OnClickCancelIma()
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_PHANTOM, 0, 0, 0, - 1, "")
end

function SpiritHuanHuaView:OnClickActivate()
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_UPPHANTOM, 0, 0, 0, self.cur_index - 1, "")
end

function SpiritHuanHuaView:OnClickUseIma()
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_PHANTOM, 0, 0, 0, self.cur_index - 1, "")
end

function SpiritHuanHuaView:OnClickUpGrade()
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_UPPHANTOM, 0, 0, 0, self.cur_index - 1, "")
end

function SpiritHuanHuaView:GetNumberOfCells()
	return SpiritData.Instance:GetMaxSpiritHuanhuaImage()
end

function SpiritHuanHuaView:HuanHuaRefreshCell(cell, data_index)
	local huanhua_cell = self.cell_list[cell]
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local huanhua_level = spirit_info.phantom_level_list[data_index]
	if data_index >= GameEnum.JINGLING_PTHANTOM_MAX_TYPE then
		huanhua_level = spirit_info.phantom_level_list_new[data_index - GameEnum.JINGLING_PTHANTOM_MAX_TYPE]
	end
	if huanhua_cell == nil then
		huanhua_cell = SpiritHuanHuaList.New(cell.gameObject)
		self.cell_list[cell] = huanhua_cell
	end
	huanhua_cell:SetToggleGroup(self.list_view.toggle_group)
	local image_cfg = SpiritData.Instance:GetSpiritHuanhuaCfgById(data_index, huanhua_level)
	local huanhua_cfg = SpiritData.Instance:GetSpiritHuanImageConfig()[data_index + 1]
	local is_show = SpiritData.Instance:ShowHuanhuaRedPoint()[data_index] and true or false
	huanhua_cell:SetData(huanhua_cfg, is_show)
	huanhua_cell:ListenClick(BindTool.Bind(self.OnClickItemCell, self, data_index + 1, image_cfg, huanhua_cell))
	huanhua_cell:SetHighLight(self.cur_index == data_index + 1)
end

function SpiritHuanHuaView:OnClickItemCell(index, data, huanhua_cell)
	self:SetSelectAttr(index)
	self.cur_index = index
	self:SetButtonState(index)
	huanhua_cell:SetHighLight(self.cur_index == index)
end

function SpiritHuanHuaView:SetSelectAttr(index)
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local huanhua_level = spirit_info.phantom_level_list[index - 1]
	if index > 10 then
		huanhua_level = spirit_info.phantom_level_list_new[index - 11]
	end
	index = index or self.cur_index

	huanhua_level = huanhua_level > 0 and huanhua_level or 1

	local data = SpiritData.Instance:GetSpiritHuanhuaCfgById(index - 1, huanhua_level)
	local attr_list = CommonDataManager.GetAttributteNoUnderline(data, true)
	self.gongji:SetValue(attr_list.gongji)
	self.fangyu:SetValue(attr_list.fangyu)
	self.maxhp:SetValue(attr_list.maxhp)
	self.mingzhong:SetValue(attr_list.mingzhong)
	self.shanbi:SetValue(attr_list.shanbi)
	self.baoji:SetValue(attr_list.baoji)
	self.jianren:SetValue(attr_list.jianren)

	self.fight_power:SetValue(CommonDataManager.GetCapability(attr_list))
	local huanhua_cfg = SpiritData.Instance:GetSpiritHuanImageConfig()[index]
	self.spirit_name:SetValue(huanhua_cfg.image_name)

	self.need_prop_num:SetValue(data.stuff_num)
	local count = ItemData.Instance:GetItemNumInBagById(data.stuff_id)
	if count < data.stuff_num then
		count = string.format(Language.Mount.ShowRedNum, count)
	else
		count = string.format(Language.Mount.ShowGreenNum, count)
	end
	self.had_prop_num:SetValue(count)
	self.cur_level:SetValue(data.level)

	local item_data = {item_id = data.stuff_id, is_bind = 0}
	self.item:SetData(item_data)
	self.item:ListenClick(BindTool.Bind(self.OnClickItem, self, item_data))
end

function SpiritHuanHuaView:OnClickItem(data)
	if nil == data then return end
	TipsCtrl.Instance:OpenItem(data)
end

function SpiritHuanHuaView:SetButtonState(index)
	index = index or self.cur_index
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local bit_list = bit:d2b(spirit_info.special_img_active_flag)
	local huanhua_level = spirit_info.phantom_level_list[index - 1]
	if index > 10 then
		huanhua_level = spirit_info.phantom_level_list_new[index - 11]
	end
	-- self.show_use_image_sprite:SetValue(spirit_info.phantom_imageid == (index - 1))
	self.show_use_iamge_button:SetValue((bit_list[32 - index + 1] == 1) and spirit_info.phantom_imageid ~= (index - 1))
	self.show_cur_level:SetValue(bit_list[32 - index + 1] == 1)
	self.show_upgrade_button:SetValue(bit_list[32 - index + 1] == 1)
	self.upgrade_button.button.interactable = SpiritData.Instance:GetMaxSpiritHuanhuaLevelById(index - 1) > huanhua_level
	self.show_active_button:SetValue(bit_list[32 - index + 1] == 0)
	self.show_cancel:SetValue(spirit_info.phantom_imageid == (index - 1))
end

function SpiritHuanHuaView:OnClickClose()
	self:Close()
end

function SpiritHuanHuaView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "all" and v and v.item_id then
			local cfg = SpiritData.Instance:GetSpiritHuanConfigByItemId(v.item_id)
			self.cur_index = cfg and (cfg.type + 1) or self.cur_index
		end
	end
	self:SetSelectAttr(self.cur_index)
	self:SetButtonState(self.cur_index)

	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshActiveCellViews()
	end
end



-- 精灵幻化形象列表
SpiritHuanHuaList = SpiritHuanHuaList or BaseClass(BaseRender)

function SpiritHuanHuaList:__init(instance)
	self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.show_fight_icon = self:FindVariable("ShowFight")
	self.show_help_icon = self:FindVariable("ShowHelp")
	self.show_red_point = self:FindVariable("ShowRedPoint")
end

function SpiritHuanHuaList:ListenClick(handler)
	self:ClearEvent("Click")
	self:ListenEvent("Click", handler)
end

function SpiritHuanHuaList:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function SpiritHuanHuaList:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end

function SpiritHuanHuaList:SetData(data, is_show)
	self.name:SetValue(data.image_name)
	self.show_red_point:SetValue(is_show)
end