KaifuActivityPanelTwelve = KaifuActivityPanelTwelve or BaseClass(BaseRender)

-- local MODEL_TRANS_CFG = {
-- 	[1] = {
-- 		position = Vector3(0.34, 1.7, 0),
-- 		rotation = Vector3(0, 0, 0),
-- 		scale = Vector3(4, 4, 4),
-- 	},
-- 	[2] = {
-- 		position = Vector3(0.35, 0.43, 1.33),
-- 		rotation = Vector3(0, 0, 0),
-- 		scale = Vector3(5.5, 5.5, 5.5),
-- 	},
-- 	[3] = {
-- 		position = Vector3(0.33, 0.45, 1.33),
-- 		rotation = Vector3(0, 0, 0),
-- 		scale = Vector3(4.5, 4.5, 4.5),
-- 	},
-- 	[4] = {
-- 		[1] = {
-- 			position = Vector3(6, -15, -19),
-- 			rotation = Vector3(0, 0, 50),
-- 			scale = Vector3(5, 5, 5),
-- 		},
-- 		[2] = {
-- 			position = Vector3(2, -9.5, -5),
-- 			rotation = Vector3(0, 0, 10),
-- 			scale = Vector3(5, 5, 5),
-- 		},
-- 		[3] = {
-- 			position = Vector3(2, -8, -5),
-- 			rotation = Vector3(0, 0, 10),
-- 			scale = Vector3(5, 5, 5),
-- 		},
-- 	},
-- }

function KaifuActivityPanelTwelve:__init(instance)
	self.list = self:FindObj("ListView")
	self.list_delegate = self.list.list_simple_delegate
	-- list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	-- list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.price = self:FindVariable("Price")
	self.show_btn = self:FindVariable("ShowBtn")
	self.text_1 = self:FindVariable("Text1")
	self.text_2 = self:FindVariable("Text2")
	self.show_equip_effect = self:FindVariable("ShowEquipEffect")

	self:ListenEvent("OnClickBuy", BindTool.Bind(self.OnClickBuy, self))

	self.item_list = {}
	for i = 1, 4 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("RewardItem"..i))
	end

	self.display = self:FindObj("Display")

	self.model = RoleModel.New("libaoxiangou_panel_1")
	self.model:SetDisplay(self.display.ui3d_display)

	self.effect_root = self:FindObj("EffectRoot")

	self.cell_list = {}

	self.cur_item_index = 1
end

function KaifuActivityPanelTwelve:__delete()
	self.temp_activity_type = nil
	self.activity_type = nil
	self.show_equip_effect = nil

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	-- if self.equip_bg_effect_obj ~= nil then
	-- 	GameObject.Destroy(self.equip_bg_effect_obj)
	-- 	self.equip_bg_effect_obj = nil
	-- end
end

function KaifuActivityPanelTwelve:GetNumberOfCells()
	return #KaifuActivityData.Instance:GetGiftShopCfg()
end

function KaifuActivityPanelTwelve:RefreshCell(cell, data_index)
	local cell_item = self.cell_list[cell]
	if cell_item == nil then
		cell_item = PanelTwelveListCell.New(cell.gameObject)
		self.cell_list[cell] = cell_item
	end
	local cfg = KaifuActivityData.Instance:GetGiftShopCfg()[data_index + 1]
	cell_item:SetData(cfg)
	cell_item:SetToggleGroup(self.list.toggle_group)
	cell_item:SetHightLight(self.cur_item_index == (data_index + 1))
	cell_item:ListenClick(BindTool.Bind(self.OnClickItemCell, self, cfg, data_index + 1))
end

function KaifuActivityPanelTwelve:OnClickBuy()
	local cfg = KaifuActivityData.Instance:GetGiftShopCfg()[self.cur_item_index]
	if not cfg  then
		return
	end
	local func = function()
		KaifuActivityCtrl.Instance:SendRAOpenGameGiftShopBuy(cfg.seq)
	end
	local str = string.format(Language.Activity.BuyGiftTip, cfg.price)
	TipsCtrl.Instance:ShowCommonAutoView("", str, func)
end

function KaifuActivityPanelTwelve:OnClickItemCell(cfg, index)
	if not cfg then return end

	if self.cur_item_index == index then
		return
	end

	self.cur_item_index = index
	self:SetItemListData(cfg)
	if cfg.model_assetbundle then
		if cfg.seq == 3 then
			local prof = PlayerData.Instance:GetRoleBaseProf()
			local t = Split(cfg.model_assetbundle, ";")
			if t[prof] then
				local t2 = Split(t[prof], ",")
				local bundle, asset = t2[1], t2[2]
				self:SetModel(bundle, asset, self.cur_item_index)
			end
		else
			local t = Split(cfg.model_assetbundle, ",")
			local bundle, asset = t[1], t[2]
			self:SetModel(bundle, asset, self.cur_item_index)
		end
	end
end

function KaifuActivityPanelTwelve:SetItemListData(cfg)
	local item_list = {}
	local gift_id = 0
	local special_list = Split(cfg.item_special or 0, ",")
	for k, v in pairs(cfg.reward_item_list) do
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
		if big_type == GameEnum.ITEM_BIGTYPE_GIF then
			gift_id = v.item_id

			local gift_item_list = ItemData.Instance:GetGiftItemListByProf(v.item_id)
			for _, v2 in pairs(gift_item_list) do
				table.insert(item_list, v2)
			end
		else
			table.insert(item_list, v)
		end
	end

	for k, v in pairs(self.item_list) do
		v:SetActive(nil ~= item_list[k])
		if item_list[k] then
			v:SetGiftItemId(gift_id)
			v:SetData(item_list[k])
			for _, item_id in ipairs(special_list) do
				if tonumber(item_id) == item_list[k].item_id then
					v:ShowSpecialEffect(true)
					local bunble, asset = ResPath.GetItemActivityEffect()
					v:SetSpecialEffect(bunble, asset)
				end
			end
		end
	end

	self.price:SetValue(cfg.price)

	local flag = KaifuActivityData.Instance:GetGiftShopFlag()
	self.show_btn:SetValue(flag[32 - cfg.seq] ~= 1)
	self.text_1:SetValue(cfg.show_language_1)
	self.text_2:SetValue(cfg.show_language_2)
end

function KaifuActivityPanelTwelve:Flush(activity_type)
	self.activity_type = activity_type or self.activity_type

	self.list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	if activity_type == self.temp_activity_type then
		self.list.scroller:RefreshActiveCellViews()
	else
		if self.list.scroller.isActiveAndEnabled then
			self.list.scroller:ReloadData(0)
		end
	end

	local cfg = KaifuActivityData.Instance:GetGiftShopCfg()[self.cur_item_index]
	self:SetItemListData(cfg)

	self.temp_activity_type = activity_type

	if cfg.model_assetbundle then
		if cfg.seq == 3 then
			local prof = PlayerData.Instance:GetRoleBaseProf()
			local t = Split(cfg.model_assetbundle, ";")
			if t[prof] then
				local t2 = Split(t[prof], ",")
				local bundle, asset = t2[1], t2[2]
				self:SetModel(bundle, asset, self.cur_item_index)
			end
		else
			local t = Split(cfg.model_assetbundle, ",")
			local bundle, asset = t[1], t[2]
			self:SetModel(bundle, asset, self.cur_item_index)
		end
	end
end

function KaifuActivityPanelTwelve:SetModel(bundle, asset, index)
	if not bundle or not asset then return end
	
	local prof = PlayerData.Instance:GetRoleBaseProf()
	if self.model and self.cur_res_id ~= asset then
		self.cur_res_id = asset
		-- if index == 4 then
		-- 	--self.model:SetTransform(MODEL_TRANS_CFG[index][prof])
		-- 	-- self.model:SetPanelName("libaoxiangou_panel_weapon")
		-- else
		-- 	-- self.model:SetTransform(MODEL_TRANS_CFG[index])
		-- 	-- if index == 1 then
		-- 		--if not self.equip_bg_effect_obj and not self.is_loading then
		-- 			--self.is_loading = true
		-- 			-- PrefabPool.Instance:Load(AssetID("effects/prefabs", "UI_tongyongbaoju_1"), function(prefab)
		-- 			-- 	if prefab then
		-- 			-- 		if self.equip_bg_effect_obj  ~= nil then
		-- 			-- 			GameObject.Destroy(self.equip_bg_effect_obj)
		-- 			-- 			self.equip_bg_effect_obj = nil
		-- 			-- 		end
		-- 			-- 		local obj = GameObject.Instantiate(prefab)
		-- 			-- 		PrefabPool.Instance:Free(prefab)

		-- 			-- 		local transform = obj.transform
		-- 			-- 		transform:SetParent(self.effect_root.transform, false)
		-- 			-- 		transform.localScale = Vector3(3, 3, 3)
		-- 			-- 		self.equip_bg_effect_obj = obj.gameObject
		-- 			-- 		self.is_loading = false
		-- 			-- 	end
		-- 			-- end)
		-- 		--end
		-- 	-- end
		-- 	-- self.effect_root:SetActive(index == 1)
		-- end
		--显示装备特效
		if index == 1 then
			self.show_equip_effect:SetValue(true)
		else
			self.show_equip_effect:SetValue(false)
		end
		local display_name = "libaoxiangou_panel_" .. index
		if asset == "100401" then
			display_name = "libaoxiangou_panel_5"
		end
		self.model:SetPanelName(display_name)
		self.model:SetMainAsset(bundle, asset)
	end
end


PanelTwelveListCell = PanelTwelveListCell or BaseClass(BaseRender)

function PanelTwelveListCell:__init(instance)
	self.gift_name = self:FindVariable("GiftName")
	self.show_image_list = {}
	for i = 1, 3 do
		self.show_image_list[i] = self:FindVariable("ShowImage"..i)
	end
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
    local prof = main_role_vo.prof
    self.show_image_list[4] = self:FindVariable("WeaponImage"..prof)
end

function PanelTwelveListCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function PanelTwelveListCell:SetHightLight(value)
	self.root_node.toggle.isOn = value
end

function PanelTwelveListCell:__delete()
	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end
end

function PanelTwelveListCell:SetData(data)
	if not data then return end
	for k, v in ipairs(self.show_image_list) do
		v:SetValue(k == (data.seq + 1))
	end
end

function PanelTwelveListCell:ListenClick(handler)
	self:ClearEvent("Click")
	self:ListenEvent("Click", handler)
end