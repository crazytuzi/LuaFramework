GoddessHuanHuaView = GoddessHuanHuaView or BaseClass(BaseView)

function GoddessHuanHuaView:__init()
	self.ui_config = {"uis/views/goddess_prefab","GoddessHuanHuaView"}
	self.play_audio = true
end

function GoddessHuanHuaView:LoadCallBack()
	self.first_select = true
	self.current_xiannv_id = -1
	self.icon_cell_list = {}
	self.cur_huanhua_list = {}
	GoddessHuanHuaView.Instance = self
	self.gongji_value = self:FindVariable("gongji_value")
	self.fangyu_value = self:FindVariable("fangyu_value")
	self.shengming_value = self:FindVariable("shengming_value")
	self.shanghai_value = self:FindVariable("shanghai_value")
	self.remian_text = self:FindVariable("remian_text")
	self.power_value = self:FindVariable("power_value")
	self.is_show_active = self:FindVariable("is_show_active")
	self.is_show_upgrade = self:FindVariable("is_show_upgrade")
	self.show_name_text = self:FindVariable("show_name_text")
	self.level_text = self:FindVariable("level_text")
	self.show_level = self:FindVariable("show_level")
	self.upgrade_btn_txt = self:FindVariable("upgrade_btn_txt")
	self.list_view = self:FindObj("list_view")
	self:ListenEvent("active_click",BindTool.Bind(self.OnClickActive, self))
	self:ListenEvent("upgrade_click",BindTool.Bind(self.OnClickUpgrade, self))
	self:ListenEvent("close_click",BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("use_click", BindTool.Bind(self.UseOnClick, self))
	self:ListenEvent("cancel_click", BindTool.Bind(self.CancelOnClick, self))
	self.show_use_btn = self:FindVariable("show_use_btn")
	self.show_cancel_btn = self:FindVariable("show_cancel_btn")
	self.goddess_display = self:FindObj("goddess_display")
	self.upgrade_button = self:FindObj("upgrade_button")
	self.upgrade_txt = self:FindObj("upgradeTxt")
	local handler = function()
		local close_call_back = function()
			self.item_cell:ShowHighLight(false)
			self.item_cell:SetToggle(false)
		end
		self.item_cell:ShowHighLight(true)
		TipsCtrl.Instance:OpenItem(self.item_cell:GetData(), nil, nil, close_call_back)
	end
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item_cell"))
	self.item_cell:ListenClick(handler)
	self.goddess_model_view = RoleModel.New("goddess_huanhua_panel")
	self.goddess_model_view:SetDisplay(self.goddess_display.ui3d_display)
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetGoddessNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshGoddessCell, self)
end

function GoddessHuanHuaView:ReleaseCallBack()
	self.cur_huanhua_list = {}
	self.icon_cell_list = {}
	if nil ~= self.goddess_model_view then
		self.goddess_model_view:DeleteMe()
		self.goddess_model_view = nil
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	GoddessHuanHuaView.Instance = nil

	-- 清理变量和对象
	self.upgrade_txt = nil
	self.gongji_value = nil
	self.fangyu_value = nil
	self.shengming_value = nil
	self.shanghai_value = nil
	self.remian_text = nil
	self.power_value = nil
	self.is_show_active = nil
	self.is_show_upgrade = nil
	self.show_name_text = nil
	self.level_text = nil
	self.show_level = nil
	self.list_view = nil
	self.show_use_btn = nil
	self.show_cancel_btn = nil
	self.goddess_display = nil
	self.upgrade_button = nil
	self.upgrade_btn_txt = nil
	self.cur_huanhua_list = {}
end

function GoddessHuanHuaView:OpenCallBack()
	-- self.current_xiannv_id
	self:SetCurHuanHuaList()
	self.list_view.scroller:ReloadData(0)
	self:IsActiveToUpgrde()
end

function GoddessHuanHuaView:UpdateAttrView()
	local level = GoddessData.Instance:GetXianNvHuanHuaLevel(self.current_xiannv_id)
	local huanhua_cfg = GoddessData.Instance:GetXianNvHuanHuaCfg(self.current_xiannv_id)
	local huanhua_level_attr = {}
	local need_item_num = 0
	if level == 0 then
		self.show_level:SetValue(false)
		level = 1
		huanhua_level_attr = GoddessData.Instance:GetXianNvHuanHuaLevelCfg(self.current_xiannv_id,level)
		need_item_num = GoddessHuanHuaActiveMatNum
	else
		-- self.level_text:SetValue(level)
		self.show_level:SetValue(true)
		huanhua_level_attr = GoddessData.Instance:GetXianNvHuanHuaLevelCfg(self.current_xiannv_id,level)
		need_item_num = huanhua_level_attr.uplevel_stuff_num

		local info = ItemData.Instance:GetItemConfig(huanhua_level_attr.uplevel_stuff_id)
		local level_str = "<color="..SOUL_NAME_COLOR[info.color]..">".. "Lv." .. level .. "</color>"
		self.level_text:SetValue(level_str.." ")
	end

	self.gongji_value:SetValue(huanhua_level_attr.gongji)
	self.fangyu_value:SetValue(huanhua_level_attr.fangyu)
	self.shengming_value:SetValue(huanhua_level_attr.maxhp)
	self.shanghai_value:SetValue(huanhua_level_attr.xiannv_gongji)
	local info = ItemData.Instance:GetItemConfig(huanhua_level_attr.uplevel_stuff_id)
	local have_item_num = ItemData.Instance:GetItemNumInBagById(huanhua_level_attr.uplevel_stuff_id)
	local text_1 = ""
	local text_2 = ToColorStr(need_item_num .. "", TEXT_COLOR.BLACK_1)
	if have_item_num >= need_item_num then
		text_1 = ToColorStr(have_item_num .. "", TEXT_COLOR.BLUE_SPECIAL)
	else
		text_1 = ToColorStr(have_item_num .. "" , TEXT_COLOR.RED)
	end
	self.remian_text:SetValue(text_1.." / "..text_2)
	self.power_value:SetValue(GoddessData.Instance:GetHuanhuaPower(self.current_xiannv_id,level))

	if info == nil then return end
	local name_str = "<color="..SOUL_NAME_COLOR[info.color]..">".. huanhua_cfg.name .."</color>"
	-- local name_str = huanhua_cfg.name
	self.show_name_text:SetValue(name_str)

	local data = {}
	data.item_id = huanhua_level_attr.uplevel_stuff_id
	self.item_cell:SetData(data)
end

--list_view
function GoddessHuanHuaView:GetGoddessNumberOfCells()
	return #self.cur_huanhua_list or 0
end

function GoddessHuanHuaView:SetCurHuanHuaList()
	
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local vo_level = GameVoManager.Instance:GetMainRoleVo().level
	local cell_num = 0
	for i=1, GoddessData.Instance:GetXianHuanhuaNum() do
		local open_day = GoddessData.Instance:GetXianNvHuanHuaCfg(i - 1).open_day	
		local lvl = GoddessData.Instance:GetXianNvHuanHuaCfg(i - 1).lvl
		if vo_level >= lvl and server_day >= open_day then
				cell_num = cell_num + 1
				table.insert( self.cur_huanhua_list, GoddessData.Instance:GetXianNvHuanHuaCfg(i - 1))
		end
	end	
end

function GoddessHuanHuaView:RefreshGoddessCell(cell, cell_index)
	local icon_cell = self.icon_cell_list[cell]
	if icon_cell == nil then
		icon_cell = GoddessHuanHuaCell.New(cell.gameObject, self)
		self.icon_cell_list[cell] = icon_cell
		icon_cell:SetToggleGroup(self.list_view.toggle_group)
	end
	local index = self.cur_huanhua_list[cell_index + 1].id
	icon_cell:InitCell(index)
	icon_cell:SetToggleIsOn(false)
end

function GoddessHuanHuaView:OnFlush()
	self:OnFlushCell()
	self:UpdateAttrView()
	self:IsActiveToUpgrde()
end

function GoddessHuanHuaView:IsActiveToUpgrde()
	local huanhua_flag_list = bit:d2b(GoddessData.Instance:GetXianNvHuanHuaFlag())
	local huanhua_id = GoddessData.Instance:GetHuanHuaId()
	if huanhua_flag_list[32 - self.current_xiannv_id] == 1 then
		self.is_show_active:SetValue(false)
		self.is_show_upgrade:SetValue(true)
		if huanhua_id == self.current_xiannv_id then
			self.show_use_btn:SetValue(false)
			self.show_cancel_btn:SetValue(true)
		else
			self.show_use_btn:SetValue(true)
			self.show_cancel_btn:SetValue(false)
		end
	else
		self.is_show_active:SetValue(true)
		self.is_show_upgrade:SetValue(false)
		self.show_use_btn:SetValue(false)
		self.show_cancel_btn:SetValue(false)
	end
	self:SetButtonGray(GoddessData.Instance:GetXianNvHuanHuaLevel(self.current_xiannv_id))
end

function GoddessHuanHuaView:OnClickActive()
	local active_num = #(GoddessData.Instance:GetXiannvActiveList())
	if active_num <= 0 then
		TipsCtrl.Instance:ShowSystemMsg("至少激活一个伙伴，才能进行幻化")
		return
	end
	local item_id = GoddessData.Instance:GetXianNvHuanHuaCfg(self.current_xiannv_id).active_item
	local num = ItemData.Instance:GetItemNumInBagByIndex(ItemData.Instance:GetItemIndex(item_id),item_id)
	if num > 0 then
		GoddessCtrl.Instance:SendXiannvActiveHuanhua(self.current_xiannv_id,ItemData.Instance:GetItemIndex(item_id))
	else
		-- TipsCtrl.Instance:ShowSystemMsg("材料不足")
		local func = function(item_id, item_num, is_bind, is_use)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, 1)
		return
	end
end

function GoddessHuanHuaView:OnClickUpgrade()
	local huanhua_level = GoddessData.Instance:GetXianNvHuanHuaLevel(self.current_xiannv_id)
	if huanhua_level >= GODDRESS_HUANHUA_MAX_LEVEL then
		TipsCtrl.Instance:ShowSystemMsg("等级已满")
		return
	end
	local item_id = GoddessData.Instance:GetXianNvHuanHuaLevelCfg(self.current_xiannv_id,huanhua_level).uplevel_stuff_id
	local num = ItemData.Instance:GetItemNumInBagByIndex(ItemData.Instance:GetItemIndex(item_id),item_id)
	if num > 0 then
		GoddessCtrl.Instance:SentXiannvHuanHuaUpLevelReq(self.current_xiannv_id,1)
	else
		local func = function(item_id, item_num, is_bind, is_use)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, num)
		return
	end
end

function GoddessHuanHuaView:OnClickClose()
	self.first_select = true
	self:Close()
end

function GoddessHuanHuaView:UseOnClick()
	GoddessCtrl.Instance:SentXiannvImageReq(self.current_xiannv_id)
end

function GoddessHuanHuaView:CancelOnClick()
	GoddessCtrl.Instance:SentXiannvImageReq(-1)
end

function GoddessHuanHuaView:GetFirstSelect()
	return self.first_select
end

function GoddessHuanHuaView:SetFirstSelect(first_select)
	self.first_select = first_select
end

function GoddessHuanHuaView:SetXiannvID(xiannv_id)
	self.current_xiannv_id = xiannv_id
end

function GoddessHuanHuaView:GetXiannvID()
	return self.current_xiannv_id
end

function GoddessHuanHuaView:OnFlushCell()
	for k,v in pairs(self.icon_cell_list) do
		v:OnFlush()
	end
end

function GoddessHuanHuaView:SetButtonGray(level)
	if level == GODDRESS_HUANHUA_MAX_LEVEL then
		self.upgrade_button.grayscale.GrayScale = 255
		self.upgrade_txt.grayscale.GrayScale = 255
		self.upgrade_button.button.interactable = false
		self.upgrade_btn_txt:SetValue(Language.Common.YiManJi)
	else
		self.upgrade_button.grayscale.GrayScale = 0
		self.upgrade_txt.grayscale.GrayScale = 0
		self.upgrade_button.button.interactable = true
		self.upgrade_btn_txt:SetValue(Language.Common.UpGrade)
	end
end

function GoddessHuanHuaView:SetModel(res_id)
	self.goddess_model_view:ResetRotation()
	self.goddess_model_view:SetMainAsset(ResPath.GetGoddessModel(res_id))
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end
	self:CalToShowAnim(true)
end

function GoddessHuanHuaView:CalToShowAnim(is_change_tab)
	self:PlayAnim(is_change_tab)
end

function GoddessHuanHuaView:PlayAnim(is_change_tab)
	local count = 1
	self.goddess_model_view:SetTrigger(GoddessData.Instance:GetShowTriggerName(count))
end

function GoddessHuanHuaView:CloseCallBack()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.time_quest_2 ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest_2)
		self.time_quest = nil
	end
	self.cur_huanhua_list = {}
end

----------------------------------------------------------------------------

GoddessHuanHuaCell = GoddessHuanHuaCell or BaseClass(BaseRender)

function GoddessHuanHuaCell:__init()
	self.icon_state = self:FindObj("icon_state")
	self.name = self:FindVariable("name")
	self.show_red_point = self:FindVariable("show_red_point")
	self.xiannv_id = -1
	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnIconToggleClick,self))
	self.item_cell = ItemCellReward.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.is_own = self:FindVariable("IsOwn")

end
function GoddessHuanHuaCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end
function GoddessHuanHuaCell:InitCell(xiannv_id)
	self.xiannv_id = xiannv_id
	local huanhua_cfg = GoddessData.Instance:GetXianNvHuanHuaCfg(xiannv_id)
	if huanhua_cfg == nil then
		return
	end
	local res_id = huanhua_cfg.active_item
	-- -- local bundle, asset = ResPath.GetGoddessIcon(res_id)
	-- local bundle, asset = ResPath.GetItemIcon(res_id)
	-- self.icon:SetAsset(bundle, asset)

	--设置所需升级物品ItemCell
	local data = {}
	data.item_id = res_id
	self.item_cell:SetData(data)
	self:OnFlush()
end

function GoddessHuanHuaCell:OnIconToggleClick(is_click)
	if is_click then
		local goddess_huanhua_view = GoddessHuanHuaView.Instance
		if goddess_huanhua_view:GetXiannvID() == self.xiannv_id then
			return
		end
		goddess_huanhua_view:SetXiannvID(self.xiannv_id)
		goddess_huanhua_view:UpdateAttrView(self.xiannv_id)
		goddess_huanhua_view:SetModel(GoddessData.Instance:GetXianNvHuanHuaCfg(self.xiannv_id).resid)
		goddess_huanhua_view:IsActiveToUpgrde()
	end
end

function GoddessHuanHuaCell:OnFlush()
	self.show_red_point:SetValue(false)
	if GoddessHuanHuaView.Instance:GetFirstSelect() then
		self:SetToggleIsOn(true)
		GoddessHuanHuaView.Instance:SetFirstSelect(false)
	end

	self.icon_state:SetActive(false)
	local huanhua_flag_list = bit:d2b(GoddessData.Instance:GetXianNvHuanHuaFlag())
	local need_item = 0
	if huanhua_flag_list[32 - self.xiannv_id] == 1 then
		--self.icon_sprite.grayscale.GrayScale = 0
		need_item = GoddessData.Instance:GetXiannvHuanhuaUpgradeItemID(self.xiannv_id, GoddessData.Instance:GetXianNvHuanHuaLevel(self.xiannv_id))
	else
		--self.icon_sprite.grayscale.GrayScale = 255
		need_item = GoddessData.Instance:GetXiannvHuanhuaActiveItemID(self.xiannv_id)
	end

	local count = ItemData.Instance:GetItemNumInBagById(need_item)
	if count > 0 and GoddessData.Instance:GetXianNvHuanHuaLevel(self.xiannv_id) < GODDRESS_HUANHUA_MAX_LEVEL and #(GoddessData.Instance:GetXiannvActiveList()) >= 1 then
		self.show_red_point:SetValue(true)
	end
	local active_flag = GoddessData.Instance:GetXianNvHuanHuaFlag()
	local bit_list = bit:d2b(active_flag)
	if GoddessData.Instance:GetHuanHuaId() == self.xiannv_id then
		self.icon_state:SetActive(true)
		self.is_own:SetValue(false)
	else
		self.is_own:SetValue(0 ~= bit_list[32 - self.xiannv_id])
		self.icon_state:SetActive(false)
	end

	local huanhua_cfg = GoddessData.Instance:GetXianNvHuanHuaCfg(self.xiannv_id)
	if huanhua_cfg == nil then
		return
	end
	local item_cfg = ItemData.Instance:GetItemConfig(need_item)
	if item_cfg == nil then return end
	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">".. huanhua_cfg.name .."</color>"
	self.name:SetValue(name_str)

	GoddessHuanHuaView.Instance:SetButtonGray(GoddessData.Instance:GetXianNvHuanHuaLevel(self.xiannv_id))
end

function GoddessHuanHuaCell:SetStateActive(is_active)
	self.icon_state:SetActive(is_active)
end

function GoddessHuanHuaCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function GoddessHuanHuaCell:SetToggleIsOn(is_on)
	self.root_node.toggle.isOn = is_on
end

function GoddessHuanHuaCell:GetXiannvID()
	return self.xiannv_id
end
