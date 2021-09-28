SpiritHuanHuaView = SpiritHuanHuaView or BaseClass(BaseView)

-- 需要特殊处理的模型
local DISPLAYNAME = 10024001

function SpiritHuanHuaView:__init()
	self.ui_config = {"uis/views/spiritview_prefab", "SpiritHuanHuaView"}
	self.cell_list = {}
	self.res_id = nil
	self.fix_show_time = 10
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
	-- self.use_image_button = self:FindObj("UseImageButton")

	self.mount_model = RoleModel.New("spirit_equip_frame")
	self.mount_model:SetDisplay(self.display.ui3d_display)

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("Item"))

	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.HuanHuaRefreshCell, self)

	self.index = 1
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

	if self.mount_model ~= nil then
		self.mount_model:DeleteMe()
		self.mount_model = nil
	end

	self.gongji = nil
	self.fangyu = nil
	self.maxhp = nil
	self.mingzhong = nil
	self.shanbi = nil
	self.baoji = nil
	self.jianren = nil

	self.spirit_name = nil
	self.fight_power = nil
	self.cur_level = nil
	self.need_prop_num = nil
	self.had_prop_num = nil

	self.show_active_button = nil
	self.show_use_iamge_button = nil
	self.show_use_image_sprite = nil
	self.show_cur_level = nil
	self.show_upgrade_button = nil
	self.show_cancel = nil

	self.display = nil
	self.list_view = nil
	self.upgrade_button = nil
	-- self.use_image_button = nil

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function SpiritHuanHuaView:OpenCallBack()
	self:Flush()
	self.index = 1
	self:SetModleRestAni()
end

function SpiritHuanHuaView:CloseCallBack()

end

function SpiritHuanHuaView:OnClickCancelIma()
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_PHANTOM, 0, 0, 0, - 1, "")
end

function SpiritHuanHuaView:OnClickActivate()
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_UPPHANTOM, 0, 0, 0, SpiritData.Instance:GetListIndex(self.index) - 1, "")
end

function SpiritHuanHuaView:OnClickUseIma()
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_PHANTOM, 0, 0, 0, SpiritData.Instance:GetListIndex(self.index) - 1, "")
end

function SpiritHuanHuaView:OnClickUpGrade()
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_UPPHANTOM, 0, 0, 0, SpiritData.Instance:GetListIndex(self.index) - 1, "")
end

function SpiritHuanHuaView:GetNumberOfCells()
	local list = SpiritData.Instance:GetHuanHuaListByLevel()
	return #list
end

function SpiritHuanHuaView:HuanHuaRefreshCell(cell, data_index)
	local huanhua_cell = self.cell_list[cell]
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local huanhua_index = SpiritData.Instance:GetHuanHuaListByLevel()[data_index + 1] or {}
	local huanhua_image_id = huanhua_index.active_image_id or 0

	local huanhua_level = spirit_info.phantom_level_list[huanhua_image_id + 1]
	if huanhua_cell == nil then
		huanhua_cell = SpiritHuanHuaList.New(cell.gameObject)
		self.cell_list[cell] = huanhua_cell
	end
	huanhua_cell:SetToggleGroup(self.list_view.toggle_group)
	local image_cfg = SpiritData.Instance:GetSpiritHuanhuaCfgById(huanhua_image_id, huanhua_level)
	local huanhua_cfg = SpiritData.Instance:GetHuanHuaListByLevel()[data_index + 1]
	local is_show = SpiritData.Instance:ShowHuanhuaRedPoint()[huanhua_image_id] and true or false
	huanhua_cell:SetData(huanhua_cfg, is_show, data_index)
	huanhua_cell:ListenClick(BindTool.Bind(self.OnClickItemCell, self, data_index + 1, image_cfg, huanhua_cell))
	huanhua_cell:SetHighLight(self.index == data_index + 1)
end

function SpiritHuanHuaView:OnClickItemCell(index, data, huanhua_cell)
	self:SetSelectAttr(index)
	self.index = index
	self:SetButtonState(index)
	huanhua_cell:SetHighLight(self.index == index)
end

function SpiritHuanHuaView:SetModleRestAni()
	self.timer = self.fix_show_time
	if not self.time_quest then
		self.time_quest = GlobalTimerQuest:AddRunQuest(function()
			self.timer = self.timer - UnityEngine.Time.deltaTime
			if self.timer <= 0 then
				if self.mount_model then
					local part = self.mount_model.draw_obj:GetPart(SceneObjPart.Main)
					if part then
						part:SetTrigger(ANIMATOR_PARAM.REST)
					end
				end
				self.timer = self.fix_show_time
			end
		end, 0)
	end
end

function SpiritHuanHuaView:SetSelectAttr(index)
	local list = SpiritData.Instance:GetHuanHuaListByLevel()
	local index = SpiritData.Instance:GetOpenHuanhuaList()[list[index].active_image_id]
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local huanhua_level = spirit_info.phantom_level_list[index]

	index = index or self.index

	huanhua_level = huanhua_level > 0 and huanhua_level or 1

	local data = SpiritData.Instance:GetSpiritHuanhuaCfgById(index - 1, huanhua_level)
	local item_cfg = ItemData.Instance:GetItemConfig(data.stuff_id)
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
	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">".. huanhua_cfg.image_name .."</color>"
	self.spirit_name:SetValue(name_str)

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
	-- 形象展示
	if self.res_id ~= huanhua_cfg.res_id then

		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
		local bundle, asset = ResPath.GetSpiritModel(huanhua_cfg.res_id)
		local load_list = {{bundle, asset}}
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
				if self.mount_model == nil then return end
				self.mount_model:SetMainAsset(ResPath.GetSpiritModel(huanhua_cfg.res_id))
			end)
		local part = self.mount_model.draw_obj:GetPart(SceneObjPart.Main)
		if part then
			part:SetTrigger(ANIMATOR_PARAM.REST)
		end
		if huanhua_cfg.res_id == DISPLAYNAME then
			self.mount_model:SetPanelName("spirit_huanhua_panel")
		else
			self.mount_model:SetPanelName("spirit_equip_frame")
		end
		self.res_id = huanhua_cfg.res_id
	end
	
end

function SpiritHuanHuaView:OnClickItem(data)
	if nil == data then return end
	TipsCtrl.Instance:OpenItem(data)
	self.item:ShowHighLight(false)
end

function SpiritHuanHuaView:SetButtonState(index)
	index = index or self.index
	index = SpiritData.Instance:GetListIndex(index)
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local bit_list = bit:ll2b(spirit_info.special_img_active_flag_high, spirit_info.special_img_active_flag_low)
	local huanhua_level = spirit_info.phantom_level_list[index]
	-- self.show_use_image_sprite:SetValue(spirit_info.phantom_imageid == (index - 1))
	self.show_use_iamge_button:SetValue((bit_list[64 - index + 1] == 1) and spirit_info.phantom_imageid ~= (index - 1))
	self.show_cur_level:SetValue(bit_list[64 - index + 1] == 1)
	self.show_upgrade_button:SetValue(bit_list[64 - index + 1] == 1)
	self.upgrade_button.button.interactable = SpiritData.Instance:GetMaxSpiritHuanhuaLevelById(index - 1) > huanhua_level
	self.show_active_button:SetValue(bit_list[64 - index + 1] == 0)
	self.show_cancel:SetValue(spirit_info.phantom_imageid == (index - 1))
end

function SpiritHuanHuaView:OnClickClose()
	self:Close()
	self.res_id = nil
end

function SpiritHuanHuaView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "all" and v and v.item_id then
			local cfg = SpiritData.Instance:GetSpiritHuanConfigByItemId(v.item_id)
			self.index = cfg and (cfg.type + 1) or self.index
		end
	end
	self:SetSelectAttr(self.index)
	self:SetButtonState(self.index)

	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshActiveCellViews()
	end
end



-- 精灵幻化形象列表
SpiritHuanHuaList = SpiritHuanHuaList or BaseClass(BaseRender)

function SpiritHuanHuaList:__init(instance)
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))

	self.name = self:FindVariable("Name")
	self.show_fight_icon = self:FindVariable("ShowFight")
	self.show_help_icon = self:FindVariable("ShowHelp")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.is_own = self:FindVariable("IsOwn")
	self.is_used = self:FindVariable("IsUse")
end

function SpiritHuanHuaList:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
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

function SpiritHuanHuaList:SetData(data, is_show,index)
	if nil == data then
		return
	end
	self.item_cell:SetData(data)
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if item_cfg == nil then return end

	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">".. data.image_name .."</color>"
	self.name:SetValue(name_str)
	self.show_red_point:SetValue(is_show)
	local image_id = SpiritData.Instance:GetListIndex(index + 1) - 1
	self:ShowLabel(image_id)
end

function SpiritHuanHuaList:ShowLabel(image_id)
	if image_id == nil then
		return
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local user_pet_special_img = vo.user_pet_special_img
	local info_list = SpiritData.Instance:GetSpiritInfo()
	local bit_list = bit:ll2b(info_list.special_img_active_flag_high, info_list.special_img_active_flag_low)
	self.is_own:SetValue(0 ~= bit_list[64 - image_id])
	self.is_used:SetValue(0 ~= bit_list[64 - image_id])
	if user_pet_special_img >= 0 and user_pet_special_img == image_id and 0 ~= bit_list[64 - image_id] then
		self.is_used:SetValue(true)
		self.is_own:SetValue(false)
	else
		self.is_own:SetValue(0 ~= bit_list[64 - image_id])
		self.is_used:SetValue(false)
	end
end
