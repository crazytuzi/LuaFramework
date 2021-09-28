PlayerTitleHuanhuaView = PlayerTitleHuanhuaView or BaseClass(BaseView)

local CLOTHES_TOGGLE = 1
local WEAPONS_TOGGLE = 0

function PlayerTitleHuanhuaView:__init()
	self.ui_config = {"uis/views/player_prefab","TitleHuanHuaView"}
	self.cell_list = {}
	self.cur_upgrade_cfg_list = {}
	self.cur_cell_index = 1
	self.title_obj_list = {}
	self.is_loading = false
	self.play_audio = true
end

function PlayerTitleHuanhuaView:LoadCallBack()

	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshHuanhuaCell, self)

	self.up_grade_btn = self:FindObj("UpGradeButton")
	self.show_up_grade_text_gray = self:FindVariable("ShowUpgradeTextGray")
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("Item"))

	-- 监听事件
	self:ListenEvent("OnClickActivate", BindTool.Bind(self.OnClickActivate, self))
	self:ListenEvent("Close", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickUpGrade", BindTool.Bind(self.OnClickUpGrade, self))

	-- 变量
	self.gongji = self:FindVariable("GongJi")
	self.fangyu = self:FindVariable("FangYu")
	self.maxhp = self:FindVariable("ShengMing")

	self.bag_prop_num = self:FindVariable("ActivateProNum")
	self.need_prop_num = self:FindVariable("ExchangeNeedNum")
	self.fight_power = self:FindVariable("FightPower")
	self.name = self:FindVariable("ZuoQiName")
	self.cur_level = self:FindVariable("CurrentLevel")
	self.upgrade_btn_text = self:FindVariable("UpgradeBtnText")

	self.show_up_grade_btn = self:FindVariable("IsShowUpGrade")
	self.show_active_btn = self:FindVariable("IsShowActivate")
	self.show_cur_level = self:FindVariable("ShowCurrentLevel")

	self.title_root = self:FindObj("TitleRoot")
end

function PlayerTitleHuanhuaView:ReleaseCallBack()
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end

	for k, v in pairs(self.title_obj_list) do
		GameObject.Destroy(v)
	end
	self.title_obj_list = {}

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.cur_upgrade_cfg_list = {}
	self.cur_cell_index = nil
	self.res_id = nil

	self.title_obj_list = {}
	self.res_id = nil
	self.is_loading = nil

	-- 清理变量和对象
	self.list_view = nil
	self.up_grade_btn = nil
	self.show_up_grade_text_gray = nil
	self.gongji = nil
	self.fangyu = nil
	self.maxhp = nil
	self.bag_prop_num = nil
	self.need_prop_num = nil
	self.fight_power = nil
	self.name = nil
	self.cur_level = nil
	self.upgrade_btn_text = nil
	self.show_up_grade_btn = nil
	self.show_active_btn = nil
	self.show_cur_level = nil
	self.title_root = nil
end

function PlayerTitleHuanhuaView:OpenCallBack()
	self:SetNotifyDataChangeCallBack()
	self.cur_upgrade_cfg_list = {}
	self.cur_cell_index = 1
	self:Flush()
end

function PlayerTitleHuanhuaView:CloseCallBack()
	self.res_id = nil
	self.is_loading = false
	self:RemoveNotifyDataChangeCallBack()
end

function PlayerTitleHuanhuaView:OnClickActivate()
	local cfg = self.cur_upgrade_cfg_list[self.cur_cell_index] or {}
	local upgrade_cfg = TitleData.Instance:GetUpgradeCfg(cfg.title_id)
	local data_list = ItemData.Instance:GetBagItemDataList()
	if not cfg or not upgrade_cfg then return end
	local item_id = cfg.stuff_id
	for k, v in pairs(data_list) do
		if v.item_id == item_id and v.num >= upgrade_cfg.stuff_num then
			PackageCtrl.Instance:SendUseItem(v.index, 1, v.sub_type, 0)
			return
		end
	end

	local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
	if item_cfg == nil then
		TipsCtrl.Instance:ShowItemGetWayView(item_id)
		return
	end

	if item_cfg.bind_gold == 0 then
		TipsCtrl.Instance:ShowShopView(item_id, 2)
		return
	end

	local func = function(item_id, item_num, is_bind, is_use)
		MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
	end

	TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, 1)
	return
end

function PlayerTitleHuanhuaView:OnClickClose()
	self:Close()
end

function PlayerTitleHuanhuaView:OnClickUpGrade()
	local cfg = self.cur_upgrade_cfg_list[self.cur_cell_index] or {}
	local next_upgrade_cfg = TitleData.Instance:GetUpgradeCfg(cfg.title_id, true)
	if not next_upgrade_cfg then return end
	local item_id = next_upgrade_cfg.stuff_id
	if ItemData.Instance:GetItemNumInBagById(item_id) >= next_upgrade_cfg.stuff_num then
		TitleCtrl.Instance:SendUpgradeTitleReq(next_upgrade_cfg.title_id)
	else
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(item_id)
			return
		end

		if item_cfg.bind_gold == 0 then
			TipsCtrl.Instance:ShowShopView(item_id, 2)
			return
		end

		local func = function(item_id, item_num, is_bind, is_use)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
		end

		TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, 1)
	end
end

function PlayerTitleHuanhuaView:GetNumberOfCells()
	return #TitleData.Instance:GetUpgradeList()
end

function PlayerTitleHuanhuaView:RefreshHuanhuaCell(cell, data_index)
	local huanhua_cell = self.cell_list[cell]
	if not huanhua_cell then
		huanhua_cell = TitleHuanhuaItem.New(cell)
		self.cell_list[cell] = huanhua_cell
		huanhua_cell:SetToggleGroup(self.list_view.toggle_group)
	end
	huanhua_cell:SetData(self.cur_upgrade_cfg_list[data_index + 1])
	huanhua_cell:ListenClick(BindTool.Bind(self.OnClickHuanhuaCell, self, self.cur_upgrade_cfg_list[data_index + 1], data_index, huanhua_cell))
	huanhua_cell:SetHighLight(self.cur_cell_index == (data_index + 1))
end

function PlayerTitleHuanhuaView:OnClickHuanhuaCell(cfg, index, huanhua_cell)
	self.cur_cell_index = index + 1
	huanhua_cell:SetHighLight(true)
	self:SetHuanhuaInfo(index, cfg)
end

-- 设置幻化面板显示
function PlayerTitleHuanhuaView:SetHuanhuaInfo(index, cfg)
	self.cur_cell_index = self.cur_cell_index or index
	local cfg = cfg or self.cur_upgrade_cfg_list[self.cur_cell_index]
	if not cfg then return end
	local upgrade_cfg = TitleData.Instance:GetUpgradeCfg(cfg.title_id)
	local next_upgrade_cfg = TitleData.Instance:GetUpgradeCfg(cfg.title_id, true)
	if not upgrade_cfg then return end

	local item_cfg = ItemData.Instance:GetItemConfig(upgrade_cfg.stuff_id)
	if item_cfg then
		local title_cfg = TitleData.Instance:GetTitleCfg(cfg.title_id)
		-- local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..(title_cfg.name or "").."</color>"
		self.name:SetValue(title_cfg.name or "")
	end
	self.show_cur_level:SetValue(TitleData.Instance:GetTitleActiveState(cfg.title_id))
	self.cur_level:SetValue(upgrade_cfg.level)
	local bag_num = ItemData.Instance:GetItemNumInBagById(upgrade_cfg.stuff_id)
	if next_upgrade_cfg then
		self.need_prop_num:SetValue(next_upgrade_cfg.stuff_num)
		local bag_num_str = bag_num < next_upgrade_cfg.stuff_num and string.format(Language.Mount.ShowRedNum, bag_num) or bag_num
		self.bag_prop_num:SetValue(bag_num_str)
	else
		self.bag_prop_num:SetValue(bag_num)
		self.need_prop_num:SetValue(string.format(Language.Mount.ShowRedNum, 0))
	end
	local attr_list = CommonDataManager.GetAttributteNoUnderline(upgrade_cfg)
	self.gongji:SetValue(attr_list.gongji)
	self.fangyu:SetValue(attr_list.fangyu)
	self.maxhp:SetValue(attr_list.maxhp)

	self.fight_power:SetValue(CommonDataManager.GetCapabilityCalculation(attr_list))

	local data = {item_id = upgrade_cfg.stuff_id}
	self.item:SetData(data)
	self:SetButtonsState()
	self:SetModel()
end

function PlayerTitleHuanhuaView:SetModel()
	local cfg = self.cur_upgrade_cfg_list[self.cur_cell_index] or {}

	if cfg and self.res_id ~= cfg.title_id then
		if self.title_obj_list[cfg.title_id] then
			if self.title_obj_list[self.res_id] then
				self.title_obj_list[self.res_id]:SetActive(false)
			end
			self.title_obj_list[cfg.title_id]:SetActive(true)
		elseif not self.is_loading then
			self.is_loading = true
			local bundle, asset = ResPath.GetTitleModel(cfg.title_id)
			PrefabPool.Instance:Load(AssetID(bundle, asset), function(prefab)
				if prefab then
					local go = GameObject.Instantiate(prefab)
					go.transform:SetParent(self.title_root.transform, false)
					go.transform.localScale = Vector3(1.5, 1.5, 1.5)
					self.title_obj_list[cfg.title_id] = go.gameObject
					for k,v in pairs(self.title_obj_list) do
						if k ~= cfg.title_id then
							v:SetActive(false)
						end
					end
					self.is_loading = false
					PrefabPool.Instance:Free(prefab)
				end
			end)
		end
		self.res_id = cfg.title_id
	end
end

function PlayerTitleHuanhuaView:SetButtonsState()
	local cur_cfg = self.cur_upgrade_cfg_list[self.cur_cell_index] or {}
	local is_active = TitleData.Instance:GetTitleActiveState(cur_cfg.title_id)
	self.show_active_btn:SetValue(not is_active)
	self.show_up_grade_btn:SetValue(is_active)
	local next_upgrade_cfg = TitleData.Instance:GetUpgradeCfg(cur_cfg.title_id, true)
	self.up_grade_btn.button.interactable = (nil ~= next_upgrade_cfg)
	self.show_up_grade_text_gray:SetValue(nil ~= next_upgrade_cfg)
	self.upgrade_btn_text:SetValue((nil ~= next_upgrade_cfg) and Language.Common.UpGrade or Language.Common.YiManJi)
end

function PlayerTitleHuanhuaView:OnFlush(param)
	self.cur_upgrade_cfg_list = TitleData.Instance:GetUpgradeList()

	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshActiveCellViews()
	end

	self:SetHuanhuaInfo(self.cur_cell_index, self.cur_upgrade_cfg_list[self.cur_cell_index])
	for k,v in pairs(self.cell_list) do
		v:Flush()
	end
end

--移除物品回调
function PlayerTitleHuanhuaView:RemoveNotifyDataChangeCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

-- 设置物品回调
function PlayerTitleHuanhuaView:SetNotifyDataChangeCallBack()
	-- 监听系统事件
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function PlayerTitleHuanhuaView:ItemDataChangeCallback()
	self:Flush()
end

------------------------------------------------------------------------
TitleHuanhuaItem = TitleHuanhuaItem or BaseClass(BaseCell)

function TitleHuanhuaItem:__init(instance)
	self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.quality = self:FindVariable("Quality")
	self.show_red_point = self:FindVariable("ShowRedPoint")
end

function TitleHuanhuaItem:__delete()
end

function TitleHuanhuaItem:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function TitleHuanhuaItem:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end

function TitleHuanhuaItem:OnFlush()
	if not self.data then return end
	local cfg = TitleData.Instance:GetTitleCfg(self.data.title_id)
	if not cfg then return end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.stuff_id)
	local next_upgrade_cfg = TitleData.Instance:GetUpgradeCfg(self.data.title_id, true)
	if item_cfg then
		local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..(cfg.name or "").."</color>"
		self.name:SetValue(name_str)
		local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
		self.icon:SetAsset(bundle, asset)

		self.quality:SetAsset(ResPath.GetQualityIcon(item_cfg.color))
	end
	self.show_red_point:SetValue((nil ~= next_upgrade_cfg) and ItemData.Instance:GetItemNumInBagById(self.data.stuff_id) >= next_upgrade_cfg.stuff_num)
end

function TitleHuanhuaItem:ListenClick(handler)
	self:ClearEvent("Click")
	self:ListenEvent("Click", handler)
end