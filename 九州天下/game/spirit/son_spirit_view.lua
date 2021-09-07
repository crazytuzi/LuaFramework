SonSpiritView = SonSpiritView or BaseClass(BaseRender)

-- 常亮定义
local BAG_MAX_GRID_NUM = 100
local BAG_ROW = 4
local BAG_COLUMN = 5
local EFFECT_CD = 1

function SonSpiritView:__init(instance)
	self.need_num = self:FindVariable("UpgradeNeedPro")
	self.have_num = self:FindVariable("UpgradeHavePro")
	self.state_text = self:FindVariable("SpiritState")
	self.spirit_name = self:FindVariable("SpiritName")
	self.spirit_level = self:FindVariable("SpiritLevel")
	self.show_spirit_name = self:FindVariable("ShowSpiritName")
	self.show_uplevel_btn = self:FindVariable("ShowUplevelButton")
	self.show_uplevel_use = self:FindVariable("ShowUplevelUse")

	self:ListenEvent("OnClickBackPack",BindTool.Bind(self.OnClickBackPack, self))
	self:ListenEvent("OnClickHuanHua",BindTool.Bind(self.OnClickHuanHua, self))
	self:ListenEvent("OnClickFaZhen",BindTool.Bind(self.OnClickFaZhen, self))
	self:ListenEvent("OnClickZhaoHui",BindTool.Bind(self.OnClickZhaoHui, self))
	self:ListenEvent("OnClickUpgrade",BindTool.Bind(self.OnClickUpgrade, self))

	self:ListenEvent("OnClickTakeOff1", BindTool.Bind(self.OnClickTakeOff, self, 1))
	self:ListenEvent("OnClickTakeOff2", BindTool.Bind(self.OnClickTakeOff, self, 2))
	self:ListenEvent("OnClickTakeOff3", BindTool.Bind(self.OnClickTakeOff, self, 3))
	self:ListenEvent("OnClickTakeOff4", BindTool.Bind(self.OnClickTakeOff, self, 4))

	self:ListenEvent("OnClickOneKeyRecover",BindTool.Bind(self.OnClickOneKeyRecover, self))
	self:ListenEvent("OnClickOneKeyEquip",BindTool.Bind(self.OnClickOneKeyEquip, self))
	self:ListenEvent("OnClickCleanBag",BindTool.Bind(self.OnClickCleanBag, self))
	self:ListenEvent("OnClickHelp",BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickReName", BindTool.Bind(self.OnClickReName, self))

	self.bag_list_view = self:FindObj("PackListView")
	self.fanzhen_list_view = self:FindObj("FaZhenListView")
	self.effect_root = self:FindObj("EffectRoot")
	-- self.display = self:FindObj("Display")
	-- if self.model_display == nil then
	-- 	self.model_display = RoleModel.New()
	-- 	self.model_display:SetDisplay(self.display.ui3d_display)
	-- end
	self.attr_view = SpiritAttrView.New(self:FindObj("AttrView"))
	self.show_attr_view = self:FindObj("AttrView")
	self.show_backpack_view = self:FindObj("BackpackView")
	self.show_fazhen_view = self:FindObj("FaZhenView")
	self.bagpack_toggle = self:FindObj("BackpackButton")
	self.show_huanhua_red_point = self:FindVariable("ShowSpiritHuanhuaRedPoint")
	self.show_fight_out = self:FindVariable("ShowFightOut")
	self.show_effect = self:FindVariable("ShowEffect")

	self.items = {}
	self.takeoff_image_list = {}
	self.show_fight_out_list = {}
	for i = 1, 4 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self:FindObj("Item"..i))
		item_cell:SetToggleGroup(self:FindObj("ItemToggleGroup").toggle_group)
		self.items[i] = {item = self:FindObj("Item"..i), cell = item_cell}
		self.takeoff_image_list[i] = self:FindVariable("ShowClose"..i)
		self.show_fight_out_list[i] = self:FindVariable("ShowFightOut"..i)
	end

	local list_delegate = self.bag_list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)

	local fazhen_list_delegate = self.fanzhen_list_view.list_simple_delegate
	fazhen_list_delegate.NumberOfCellsDel = BindTool.Bind(self.FaZhenGetNumberOfCells, self)
	fazhen_list_delegate.CellRefreshDel = BindTool.Bind(self.FaZhenRefreshCell, self)

	self.cur_click_index = 1
	self.fazhen_cells = {}
	self.spirit_cells = {}
	self.is_first = true
	self.fix_show_time = 8
	self.is_click_item = false
	self.res_id = 0
	self.temp_spirit_list = {}
	self.is_click_bag = false
	self.is_click_zhenfa = false
	self.effect_cd = 0
end

function SonSpiritView:__delete()
	self.cur_bag_index = nil

	if self.fazhen_cells ~= nil then
		for k, v in pairs(self.fazhen_cells) do
			v:DeleteMe()
		end
	end
	if self.spirit_cells ~= nil then
		for k, v in pairs(self.spirit_cells) do
			v:DeleteMe()
		end
	end

	for k, v in pairs(self.items) do
		v.cell:DeleteMe()
	end
	self.items = {}

	if self.attr_view then
		self.attr_view:DeleteMe()
		self.attr_view = nil
	end

	self.fazhen_cells = {}
	self.spirit_cells = {}
	self.is_first = nil
	self.cur_click_index = nil
	self.is_click_bag = nil
	self.temp_spirit_list = {}
	self.is_click_zhenfa = nil
	self.effect_cd = nil
	self.fix_show_time = nil
	self.res_id = nil
end

function SonSpiritView:OpenCallBack()
	self.is_first = true
	-- if self.item_data_event == nil then
	-- 	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	-- 	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	-- end
	self.is_click_bag = false
	self.is_click_zhenfa = false
	self.temp_spirit_list = {}
end

function SonSpiritView:CloseCallBack()
	GlobalTimerQuest:CancelQuest(self.time_quest)
	self.time_quest = nil
	-- if self.item_data_event ~= nil then
	-- 	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	-- 	self.item_data_event = nil
	-- end
	self.res_id = 0
	self.is_first = true
end

-- 物品不足，购买成功后刷新物品数量
function SonSpiritView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self:FlushBagView()
end

function SonSpiritView:BagGetNumberOfCells()
	return BAG_MAX_GRID_NUM / BAG_ROW
end

function SonSpiritView:BagRefreshCell(cell, data_index)
	local group = self.spirit_cells[cell]
	if group == nil  then
		group = SpiritBagGroup.New(cell.gameObject)
		self.spirit_cells[cell] = group
	end
	group:SetToggleGroup(self.bag_list_view.toggle_group)
	local page = math.floor(data_index / BAG_COLUMN)
	local column = data_index - page * BAG_COLUMN
	local grid_count = BAG_COLUMN * BAG_ROW
	for i = 1, BAG_ROW do
		local index = (i - 1) * BAG_COLUMN + column + (page * grid_count)
		local data = nil
		data = SpiritData.Instance:GetBagBestSpirit()[index + 1]
		data = data or {}
		data.locked = false
		if data.index == nil then
			data.index = index
		end
		group:SetData(i, data)
		group:ShowHighLight(i, not data.locked)
		group:SetHighLight(i, (self.cur_bag_index == index and nil ~= data.item_id))
		group:ListenClick(i, BindTool.Bind(self.HandleBagOnClick, self, data, group, i, index))
		group:SetInteractable(i, nil ~= data.item_id)
	end
end

function SonSpiritView:FlushBagView()
	self.bagpack_toggle.toggle.isOn = true
	if self.bag_list_view.scroller.isActiveAndEnabled then
		SpiritData.Instance:GetBagBestSpirit()
		self.cur_bag_index = -1
		self.bag_list_view.scroller:RefreshActiveCellViews()
	end
end

--点击格子事件
function SonSpiritView:HandleBagOnClick(data, group, group_index, data_index)
	local page = math.ceil((data.index + 1) / BAG_COLUMN)
	if data.locked then
		return
	end
	self.cur_bag_index = data_index
	group:SetHighLight(group_index, self.cur_bag_index == index)
	-- 弹出面板
	local item_cfg1, big_type1 = ItemData.Instance:GetItemConfig(data.item_id)
	local close_callback = function()
		group:SetHighLight(group_index, false)
		self.cur_bag_index = -1
	end
	if nil ~= item_cfg1 then
		TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_SPIRIT_BAG, nil, close_callback)
	end
end

-- 点击精灵改名
function SonSpiritView:OnClickReName()
	local cost_num = SpiritData.Instance:GetSpiritOtherCfg().rename_cost
	local des = string.format(Language.Common.IsXiaoHao, cost_num)
	local des_2 = Language.Common.ReSpiritName
	local callback = function(name)
		SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_RENAME,
						0, 0, 0, 0, name)
	end
	TipsCtrl.Instance:ShowRename(callback, false, nil, des, des_2)
end

function SonSpiritView:OnClickHelp()
	local tip_id = 40
	TipsCtrl.Instance:ShowHelpTipView(tip_id)
end

-- 一键回收
function SonSpiritView:OnClickOneKeyRecover()
	local func = function (is_recycle)
		local color = is_recycle and GameEnum.ITEM_COLOR_ORANGE or GameEnum.ITEM_COLOR_PURPLE
		SpiritCtrl.Instance:OneKeyRecoverSpirit(color)
	end
	TipsCtrl.Instance:ShowCommonTip(func, nil, Language.JingLing.OneKeyRecyle, nil, nil, false, false, nil, true, Language.JingLing.AutoRecyclePurple)
end

-- 一键装备
function SonSpiritView:OnClickOneKeyEquip()
	SpiritCtrl.Instance:AutoEquipOrChange()
end

-- 整理
function SonSpiritView:OnClickCleanBag()
	SpiritData.Instance:GetBagBestSpirit()
	self:FlushBagView()
	-- PackageCtrl.Instance:SendKnapsackStoragePutInOrder(GameEnum.STORAGER_TYPE_BAG, 0)
end

function SonSpiritView:OnClickTakeOff(index)
	local spirit_list = SpiritData.Instance:GetSpiritInfo().jingling_list
	spirit_list = spirit_list or {}
	if spirit_list[index - 1] == nil then
		return
	end
	local item_cfg = ItemData.Instance:GetItemConfig(spirit_list[index - 1].item_id)
	if not item_cfg then return end

	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_TAKEOFF,
					index - 1, 0, 0, 0, item_cfg.name)
	-- self.cur_click_index = index
end



-- 法阵列表
function SonSpiritView:FaZhenGetNumberOfCells()
	return #SpiritData.Instance:GetSpiritGroupCfg()
end

function SonSpiritView:FaZhenRefreshCell(cell, data_index)
	local group_list = SpiritData.Instance:GetSpiritGroupCfg()

	local temp_data = group_list[data_index + 1]
	local data = SpiritData.Instance:GetSpiritGroup()[temp_data.id]
	local fazhen_cell = self.fazhen_cells[cell]
	if fazhen_cell == nil then
		fazhen_cell = SpiritFaZhenList.New(cell.gameObject)
		self.fazhen_cells[cell] = fazhen_cell
	end
	fazhen_cell:SetData(data)
end

function SonSpiritView:FlushFaZhenView()
	if self.fanzhen_list_view.scroller.isActiveAndEnabled then
		self.fanzhen_list_view.scroller:ReloadData(0)
	end
end

-- function SonSpiritView:JumpToPage(page)
-- end

function SonSpiritView:SetBackPackState(enable)
	self.show_backpack_view:SetActive(enable and not self.is_click_item)
	self.show_attr_view:SetActive(not enable or self.is_click_item)
	self.show_fazhen_view:SetActive(not enable)
end

function SonSpiritView:OnClickItem(index, data, cell)
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(data.item_id)
	local spirit_level_cfg = SpiritData.Instance:GetSpiritLevelCfgByLevel(data.index)
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local spirit_list = spirit_info.jingling_list
	local vo = GameVoManager.Instance:GetMainRoleVo()

	self.show_attr_view:SetActive(true)
	self.show_backpack_view:SetActive(false)
	self.show_fazhen_view:SetActive(false)
	self.show_spirit_name:SetValue(item_cfg ~= nil)
	if nil ~= item_cfg and spirit_level_cfg ~= nil then
		self.cur_data = data
		local name_str = ""
		if spirit_info.use_jingling_id > 0 and spirit_info.jingling_name ~= "" then
			name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..spirit_info.jingling_name.."</color>"
		else
			name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
		end
		self.spirit_name:SetValue(name_str)
		self.spirit_level:SetValue(spirit_list[index - 1].param.strengthen_level)

		local cost = spirit_level_cfg.cost_lingjing
		if cost > 99999 and cost <= 99999999 then
			cost = cost / 10000
			cost = math.floor(cost)
			cost = cost .. Language.Common.Wan
		elseif cost > 99999999 then
			cost = cost / 100000000
			cost = math.floor(cost)
			cost = cost .. Language.Common.Yi
		end
		self.need_num:SetValue(cost)

		local count = vo.lingjing
		if count > 99999 and count <= 99999999 then
			count = count / 10000
			count = math.floor(count)
			count = count .. Language.Common.Wan
		elseif count > 99999999 then
			count = count / 100000000
			count = math.floor(count)
			count = count .. Language.Common.Yi
		end
		if vo.lingjing < spirit_level_cfg.cost_lingjing then
			self.have_num:SetValue(string.format(Language.Mount.ShowRedNum, count))
		else
			self.have_num:SetValue(count)
		end
		self.attr_view:SetSpiritAttr(data)

		local spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(self.cur_data.item_id)
		if spirit_cfg.res_id ~= self.res_id then
			local bundle, asset = ResPath.GetSpiritModel(spirit_cfg.res_id)
			local call_back = function (model, root)
				local cfg = model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.SPIRIT], spirit_cfg.res_id)
				if root then
					if cfg then
						root.transform.localPosition = cfg.position
						root.transform.localRotation = Quaternion.Euler(cfg.rotation.x, cfg.rotation.y, cfg.rotation.z)
						root.transform.localScale = cfg.scale
					else
						root.transform.localPosition = Vector3(0, 0, 0)
						root.transform.localRotation = Quaternion.Euler(0, 0, 0)
						root.transform.localScale = Vector3(1, 1, 1)
					end
				end
				self:SetModleRestAni(model)
			end
			UIScene:SetModelLoadCallBack(call_back)
			UIScene:ModelBundle({[SceneObjPart.Main] = bundle}, {[SceneObjPart.Main] = asset})
			self.res_id = spirit_cfg.res_id
		end

		self.cur_click_index = index
	end
	if spirit_info.use_jingling_id == data.item_id then
		self.state_text:SetValue(Language.Common.CallBack)
	else
		self.state_text:SetValue(Language.Common.OutFight)
	end
	self.show_fight_out:SetValue(spirit_info.use_jingling_id ~= data.item_id)
	cell:SetHighLight(true)
	self.show_uplevel_btn:SetValue(spirit_list[self.cur_click_index - 1] ~= nil)
	self.show_uplevel_use:SetValue(spirit_list[self.cur_click_index - 1] ~= nil)
	self.is_click_item = true
	self.is_click_bag = false
	self.is_click_zhenfa = false
end

function SonSpiritView:SetModleRestAni(model)
	self.timer = self.fix_show_time
	if not self.time_quest then
		self.time_quest = GlobalTimerQuest:AddRunQuest(function()
			self.timer = self.timer - UnityEngine.Time.deltaTime
			if self.timer <= 0 then
				if model then
					model:SetTrigger("rest")
				end
				self.timer = self.fix_show_time
			end
		end, 0)
	end
end

function SonSpiritView:OnClickBackPack()
	self.is_click_item = false

	self.show_attr_view:SetActive(false)

	self.show_backpack_view:SetActive(true)
	self.show_fazhen_view:SetActive(false)
	if not self.is_click_bag then
		self:FlushBagView()
	end
	self.is_click_bag = true
	self.is_click_zhenfa = false
end

function SonSpiritView:OnClickHuanHua()
	self.is_click_item = false
	ViewManager.Instance:Open(ViewName.SpiritHuanHuaView)
end

function SonSpiritView:OnClickFaZhen()
	self.is_click_item = false
	if #SpiritData.Instance:GetSpiritGroupCfg() <= 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.JingLing.NoEquipJingLing)
		return
	end
	self.show_attr_view:SetActive(false)
	self.show_backpack_view:SetActive(false)
	self.show_fazhen_view:SetActive(true)
	if self.fanzhen_list_view.scroller.isActiveAndEnabled and not self.is_click_zhenfa then
		self.fanzhen_list_view.scroller:ReloadData(0)
	end
	self.is_click_bag = false
	self.is_click_zhenfa = true
end

-- 出战、召回
function SonSpiritView:OnClickZhaoHui()
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	if self.cur_click_index == nil or self.cur_data == nil or spirit_info == nil then
		return
	end
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.cur_data.item_id)
	if spirit_info.use_jingling_id == self.cur_data.item_id then
		SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_CALLBACK,
						self.cur_click_index - 1, 0, 0, 0, item_cfg.name)
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	else
		SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_FIGHTOUT,
						self.cur_click_index - 1, 0, 0, 0, item_cfg.name)
	end
end

function SonSpiritView:OnClickUpgrade()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.cur_data.item_id)
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_UPLEVEL,
					self.cur_click_index - 1, 0, 0, 0, item_cfg.name)
end

function SonSpiritView:Flush()
	-- if not self.root_node.gameObject.activeSelf then
	-- 	return
	-- end

	self.cur_data = nil
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local spirit_list = spirit_info.jingling_list or {}
	local is_flush_bag = false

	for k, v in pairs(self.items) do
		if v.cell:GetData().item_id then
			if not spirit_list[k - 1] then
				if self.cur_click_index == k then
					if UIScene.role_model then
						local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
						if part then
							part:DeleteMe()
							self.res_id = 0
						end
					end
				end
				v.cell:SetData({})
				v.cell:ClearItemEvent()
				v.cell:SetInteractable(false)
				v.cell:SetHighLight(false)
				self.cur_click_index = nil
			else
				if v.cell:GetData().param.strengthen_level < spirit_list[k - 1].param.strengthen_level then
					if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
						AudioService.Instance:PlayAdvancedAudio()
						EffectManager.Instance:PlayAtTransformCenter(
								"effects2/prefab/ui/ui_shengjichenggong_prefab",
								"UI_shengjichenggong",
								self.effect_root.transform,
								2.0)
						self.effect_cd = Status.NowTime + EFFECT_CD
					end
				end
				v.cell:IsDestroyEffect(false)
				v.cell:SetData(spirit_list[k - 1])
				v.cell:SetHighLight(self.cur_click_index == k)
			end
		elseif spirit_list[k - 1] and nil == v.cell:GetData().item_id then
			if vo.used_sprite_id == spirit_list[k - 1].item_id and self.is_first then
				self.cur_click_index = k
			elseif (not self.cur_click_index and spirit_list[k - 1]) or (not self.temp_spirit_list[k - 1] and spirit_list[k - 1] and not self.is_first) then
				self.cur_click_index = k
			end
			v.cell:SetData(spirit_list[k - 1])
			v.cell:ListenClick(BindTool.Bind(self.OnClickItem, self, k, spirit_list[k - 1], v.cell))
			v.cell:SetInteractable(true)
			v.cell:SetHighLight(self.cur_click_index == k)
		else
			v.cell:SetData({})
			v.cell:SetInteractable(false)
		end
		self.takeoff_image_list[k]:SetValue(spirit_list[k - 1] ~= nil)
	end

	if self.cur_click_index and spirit_list[self.cur_click_index - 1] then
		local spirit_level_cfg = SpiritData.Instance:GetSpiritLevelCfgByLevel(spirit_list[self.cur_click_index - 1].index)
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(spirit_list[self.cur_click_index - 1].item_id)
		local name_str = ""
		if spirit_info.use_jingling_id > 0 and spirit_info.jingling_name ~= "" then
			name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..spirit_info.jingling_name.."</color>"
		else
			name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
		end
		self.spirit_name:SetValue(name_str)
		self.spirit_level:SetValue(spirit_list[self.cur_click_index - 1].param.strengthen_level)

		local cost = spirit_level_cfg.cost_lingjing
		if cost > 99999 and cost <= 99999999 then
			cost = cost / 10000
			cost = math.floor(cost)
			cost = cost .. Language.Common.Wan
		elseif cost > 99999999 then
			cost = cost / 100000000
			cost = math.floor(cost)
			cost = cost .. Language.Common.Yi
		end
		self.need_num:SetValue(cost)

		local count = vo.lingjing
		if count > 99999 and count <= 99999999 then
			count = count / 10000
			count = math.floor(count)
			count = count .. Language.Common.Wan
		elseif count > 99999999 then
			count = count / 100000000
			count = math.floor(count)
			count = count .. Language.Common.Yi
		end
		if vo.lingjing < spirit_level_cfg.cost_lingjing then
			self.have_num:SetValue(string.format(Language.Mount.ShowRedNum, count))
		else
			self.have_num:SetValue(count)
		end
		self.cur_data = spirit_list[self.cur_click_index - 1]
	end

	for k, v in pairs(self.show_fight_out_list) do
		v:SetValue(spirit_list[k - 1] and spirit_list[k - 1].item_id == spirit_info.use_jingling_id or false)
	end

	self.show_spirit_name:SetValue(self.cur_click_index and spirit_list[self.cur_click_index - 1] ~= nil or false)
	self.show_uplevel_btn:SetValue(self.cur_click_index and spirit_list[self.cur_click_index - 1] ~= nil or false)
	self.show_uplevel_use:SetValue(self.cur_click_index and spirit_list[self.cur_click_index - 1] ~= nil or false)
	self.attr_view:SetSpiritAttr(self.cur_click_index and spirit_list[self.cur_click_index - 1] or {})
	-- self.model_display:SetVisible(self.cur_click_index and spirit_list[self.cur_click_index - 1] ~= nil or false)

	if self.cur_data ~= nil then
		if spirit_info.use_jingling_id == self.cur_data.item_id then
			self.state_text:SetValue(Language.Common.CallBack)
		else
			self.state_text:SetValue(Language.Common.OutFight)
		end
		self.show_fight_out:SetValue(spirit_info.use_jingling_id ~= self.cur_data.item_id)

		local spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(self.cur_data.item_id)
		if spirit_cfg and spirit_cfg.res_id and spirit_cfg.res_id > 0 then
			if self.res_id ~= spirit_cfg.res_id then
				local bundle, asset = ResPath.GetSpiritModel(spirit_cfg.res_id)
				local call_back = function (model, root)
					local cfg = model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.SPIRIT], spirit_cfg.res_id)
					if root then
						if cfg then
							root.transform.localPosition = cfg.position
							root.transform.localRotation = Quaternion.Euler(cfg.rotation.x, cfg.rotation.y, cfg.rotation.z)
							root.transform.localScale = cfg.scale
						else
							root.transform.localPosition = Vector3(0, 0, 0)
							root.transform.localRotation = Quaternion.Euler(0, 0, 0)
							root.transform.localScale = Vector3(1, 1, 1)
						end
					end
					self:SetModleRestAni(model)
				end
				UIScene:SetModelLoadCallBack(call_back)
				UIScene:ModelBundle({[SceneObjPart.Main] = bundle}, {[SceneObjPart.Main] = asset})
				self.res_id = spirit_cfg.res_id
			end
		end
	end

	-- 自动出战
	if not next(self.temp_spirit_list) and not self.is_first then
		for k, v in pairs(spirit_list) do
			local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_FIGHTOUT,
							k, 0, 0, 0, item_cfg.name)
			break
		end
	end

	for k, v in pairs(self.temp_spirit_list) do
		if not spirit_list[k] then
			is_flush_bag = true
			break
		elseif spirit_list[k].item_id ~= v.item_id then
			is_flush_bag = true
			break
		end
	end
	self.temp_spirit_list = spirit_list

	local huanhua_list = SpiritData.Instance:ShowHuanhuaRedPoint()
	self.show_huanhua_red_point:SetValue(nil ~= next(huanhua_list))

	if self.is_first or is_flush_bag then
		self:FlushBagView()
		self:FlushFaZhenView()
	end

	self.is_first = false
end


-- 精灵属性
SpiritAttrView = SpiritAttrView or BaseClass(BaseRender)

function SpiritAttrView:__init(instance)
	self.base_attr_list = {}
	self.talent_attr_list = {}
	for i = 1, 7 do
		self.base_attr_list[i] = {name = self:FindVariable("BaseAttrName"..i), value = self:FindVariable("BaseAttrValue"..i),
				is_show = self:FindVariable("ShowBaseAttr"..i), next_value = self:FindVariable("BaseAttrNextValue"..i),
					show_image = self:FindVariable("ShowUpImag"..i), show_next_value = self:FindVariable("ShowNextAttr"..i)
		}
	end
	for i = 1, 4 do
		self.talent_attr_list[i] = {name = self:FindVariable("TalentAttrName"..i), value = self:FindVariable("TalentAttrValue"..i),
				is_show = self:FindVariable("ShowTalentAttr"..i), icon = self:FindVariable("TalentAttrIcon"..i),
		}
	end

	self.fight_power = self:FindVariable("FightPower")

	self.spirit_name = self:FindVariable("SpiritName")
end

function SpiritAttrView:__delete()

end

function SpiritAttrView:SetSpiritAttr(data)
	if data == nil then return end
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local spirit_level_cfg = SpiritData.Instance:GetSpiritLevelCfgByLevel(data.index)
	local attr = CommonDataManager.GetAttributteNoUnderline(spirit_level_cfg)
	local had_base_attr = {}

	if item_cfg and spirit_level_cfg then
		local spirit_next_level_cfg = SpiritData.Instance:GetSpiritLevelCfgByLevel(data.index, spirit_info.jingling_list[data.index].param.strengthen_level + 1)
		local next_attr = CommonDataManager.GetAttributteNoUnderline(spirit_next_level_cfg, true)
		for k, v in pairs(attr) do
			if v > 0 then
				if next_attr[k] and next_attr[k] > 0 then
					table.insert(had_base_attr,{key = k, value = v, next_value = next_attr[k]})
				else
					table.insert(had_base_attr,{key = k, value = v, next_value = 0})
				end
			end
		end
		if next(had_base_attr) then
			for k, v in pairs(self.base_attr_list) do
				v.is_show:SetValue(had_base_attr[k] ~= nil)
				if had_base_attr[k] ~= nil then
					v.name:SetValue(Language.Common.AttrNameNoUnderline[had_base_attr[k].key])
					v.value:SetValue(had_base_attr[k].value)
					if spirit_info.jingling_list[data.index].param.strengthen_level + 1 <= SpiritData.Instance:GetMaxSpiritUplevel(data.item_id) then
						v.show_image:SetValue(true)
						v.show_next_value:SetValue(true)
						v.next_value:SetValue(had_base_attr[k].next_value)
					else
						v.show_image:SetValue(false)
						v.show_next_value:SetValue(false)
					end
				end
			end
		end
		for k, v in pairs(self.talent_attr_list) do
			v.is_show:SetValue(false)
		end
		if data.param then
			local bundle_t, asset_t = nil, nil
			if next(data.param.xianpin_type_list) then
				for k, v in pairs(data.param.xianpin_type_list) do
					local cfg = SpiritData.Instance:GetSpiritTalentAttrCfgById(data.item_id)
					if self.talent_attr_list[k] then
						if cfg["type"..v] then
							self.talent_attr_list[k].name:SetValue(JINGLING_TALENT_ATTR_NAME[JINGLING_TALENT_TYPE[v]])
							self.talent_attr_list[k].value:SetValue(cfg["type"..v] / 100)
							self.talent_attr_list[k].is_show:SetValue(true)
							bundle_t, asset_t = ResPath.GetImages(SPIRIT_TALENT_ICON_LIST[v])
							self.talent_attr_list[k].icon:SetAsset(bundle_t, asset_t)
						else
							print_error("Spirit Talent Cfg No Attr Type :", "type"..v)
						end
					end
				end
			end
		end
		local fight_power = CommonDataManager.GetCapability(CommonDataManager.GetAttributteNoUnderline(attr))
		self.fight_power:SetValue(fight_power)
		local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
		self.spirit_name:SetValue(name_str)
	end
end


-- 背包格子
SpiritBagGroup = SpiritBagGroup or BaseClass(BaseRender)

function SpiritBagGroup:__init(instance)
	self.cells = {}
	for i = 1, BAG_ROW do
		self.cells[i] = ItemCell.New()
		self.cells[i]:SetInstanceParent(self:FindObj("Item"..i))
	end
end

function SpiritBagGroup:__delete()
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
end

function SpiritBagGroup:SetData(i, data)
	self.cells[i]:SetData(data)
end

function SpiritBagGroup:ListenClick(i, handler)
	self.cells[i]:ListenClick(handler)
end

function SpiritBagGroup:SetToggleGroup(toggle_group)
	for k, v in ipairs(self.cells) do
		v:SetToggleGroup(toggle_group)
	end
end

function SpiritBagGroup:SetHighLight(i, enable)
	self.cells[i]:SetHighLight(enable)
end

function SpiritBagGroup:ShowHighLight(i, enable)
	self.cells[i]:ShowHighLight(enable)
end

function SpiritBagGroup:SetInteractable(i, enable)
	self.cells[i]:SetInteractable(enable)
end


-- 法阵列表
SpiritFaZhenList = SpiritFaZhenList or BaseClass(BaseRender)

function SpiritFaZhenList:__init(instance)
	self.icons = {}
	self.attrs = {}
	for i = 1, 4 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self:FindObj("Item"..i))
		self.icons[i] = {item = item_cell, is_show = self:FindVariable("ShowIcon"..i)}
	end
	self.score_image = self:FindVariable("Score")
	self.show_score = self:FindVariable("ShowScore")
	self.attr_des = self:FindVariable("Attr_Des")
end

function SpiritFaZhenList:__delete()
	for k, v in pairs(self.icons) do
		v.item:DeleteMe()
	end
	self.icons = {}
end

function SpiritFaZhenList:SetData(data)
	if data == nil then return end
	self.show_score:SetValue(data.zuhe_pingfen ~= nil)
	local bundle, asset = ResPath.GetSpiritScoreIcon(data.zuhe_pingfen or 1)
	self.score_image:SetAsset(bundle, asset)

	local attr = CommonDataManager.GetAttributteNoUnderline(data, true)
	self.attr_des:SetValue(data.desc)

	for k, v in pairs(self.icons) do
		v.is_show:SetValue(data["itemid"..k] > 0)
		if data["itemid"..k] > 0 then
			local item_data = SpiritData.Instance:GetDressSpiritInfoById(data["itemid"..k])
			if nil == item_data then
				local temp_data = {item_id = data["itemid"..k], param = {strengthen_level = 0}}
				v.item:ShowQuality(false)
				v.item:SetData(temp_data)
				v.item:SetIconGrayScale(true)
			else
				v.item:ShowQuality(true)
				v.item:SetData(item_data)
				v.item:SetIconGrayScale(false)
			end
		end
	end
end