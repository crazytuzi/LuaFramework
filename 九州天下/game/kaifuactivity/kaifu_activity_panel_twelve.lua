KaifuActivityPanelTwelve = KaifuActivityPanelTwelve or BaseClass(BaseRender)

local MODEL_TRANS_CFG = {
	[1] = {
		rotation = Vector3(0, 180, 0),
		scale = Vector3(0.8, 0.8, 0.8),
	},
	[2] = {
		rotation = Vector3(0, 0, 0),
		scale = Vector3(2, 2, 2),
	},
	[3] = {
		rotation = Vector3(0, 0, 0),
		scale = Vector3(1, 1, 1),
	},
	[4] = {
		[1] = {
			rotation = Vector3(0, 0, 0),
			scale = Vector3(1.8, 1.8, 1.8),
		},
		[2] = {
			rotation = Vector3(0, 0, 0),
			scale = Vector3(1.8, 1.8, 1.8),
		},
		[3] = {
			rotation = Vector3(0, 0, 0),
			scale = Vector3(1.8, 1.8, 1.8),
		},
		[4] = {
			rotation = Vector3(0, 0, 0),
			scale = Vector3(1.8, 1.8, 1.8),
		},
	},
}

local camera_select = {
	[1] = "kaifu_gift_buy_item",
	[2] = "kaifu_gift_buy_model",
	[3] = "kaifu_gift_buy_model",
	[4] = "kaifu_gift_buy_model",
}
local REWARD_ITEM_NUM = 5
function KaifuActivityPanelTwelve:__init(instance)
	self.item_list = {}
	self.cell_list = {}
	self.item_obj_list = {}
end

function KaifuActivityPanelTwelve:LoadCallBack()
	self.list = self:FindObj("ListView")
	local list_delegate = self.list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.price = self:FindVariable("Price")
	self.show_btn = self:FindVariable("ShowBtn")
	self.text_1 = self:FindVariable("Text1")
	self.text_2 = self:FindVariable("Text2")
	self.show_text1 = self:FindVariable("showText1")
	self.show_text2 = self:FindVariable("showText2")
	self.text_image = self:FindVariable("TextImage")

	self:ListenEvent("OnClickBuy", BindTool.Bind(self.OnClickBuy, self))

	for i = 1, REWARD_ITEM_NUM do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("RewardItem"..i))
		self.item_obj_list[i] = self:FindObj("RewardItem"..i)
	end

	self.display = self:FindObj("Display")

	self.model = RoleModel.New("kaifu_gift_buy_item")
	self.model:SetDisplay(self.display.ui3d_display)

	self.effect_root = self:FindObj("EffectRoot")
	self.cur_item_index = 1
	self.rotate_speed = 100 
	self:Flush()
	
end

function KaifuActivityPanelTwelve:__delete()
	self.temp_activity_type = nil
	self.activity_type = nil
	self.item_obj_list = {}

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

	if self.equip_bg_effect_obj ~= nil then
		GameObject.Destroy(self.equip_bg_effect_obj)
		self.equip_bg_effect_obj = nil
	end
	Runner.Instance:RemoveRunObj(self)
	self.obj_model = nil

	UnityEngine.PlayerPrefs.DeleteKey("activity_panel_twelve")
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
	
	if UnityEngine.PlayerPrefs.GetInt("activity_panel_twelve") == 1 then
		func()
	else
		local str = string.format(Language.Activity.BuyGiftTip, cfg.price)
		TipsCtrl.Instance:ShowCommonTip(func, nil, str, nil, nil, true, false, "activity_panel_twelve")
	end
end

function KaifuActivityPanelTwelve:OnClickItemCell(cfg, index)
	if not cfg then return end

	if self.cur_item_index == index then
		return
	end

	self.cur_item_index = index
	self:SetItemListData(cfg)
	if cfg.model_assetbundle then
		local prof = PlayerData.Instance:GetRoleBaseProf()
		local t = Split(cfg.model_assetbundle, ",")
		local bundle, asset = t[1], t[2]
		if string.find(bundle, "#") then
			bundle = string.gsub(bundle, "#", prof)
		end
		if string.find(asset, "#") then
			asset = string.gsub(asset, "#", prof)
		end
		local weapon_res = 0
		if cfg.weapon ~= "" then
			weapon_res = string.gsub(cfg.weapon, "#", prof)
		end
		self:SetModel(bundle, asset, self.cur_item_index, weapon_res)
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
		self.item_obj_list[k]:SetActive(nil ~= item_list[k])
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

	--self.price:SetValue(cfg.price)
	self.text_image:SetAsset(ResPath.GetKaiFuChargeImage("text_image_"..self.cur_item_index))
	local flag = KaifuActivityData.Instance:GetGiftShopFlag()
	self.show_btn:SetValue(flag[32 - cfg.seq] ~= 1)
	--self.text_1:SetValue(cfg.show_language_1)
	--self.text_2:SetValue(cfg.show_language_2)
	self.show_text1:SetAsset(ResPath.GetKaiFuChargeImage("show_language_"..self.cur_item_index.."_01"))
	self.show_text2:SetAsset(ResPath.GetKaiFuChargeImage("show_language_"..self.cur_item_index.."_02"))
end

function KaifuActivityPanelTwelve:SetCurTyoe(cur_type)
	self.cur_type = cur_type
end

function KaifuActivityPanelTwelve:OnFlush()
	local activity_type = self.cur_type
	self.activity_type = activity_type or self.activity_type

	-- self.list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	-- self.list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

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
		-- if cfg.seq == 3 then
		-- 	local prof = PlayerData.Instance:GetRoleBaseProf()
		-- 	local t = Split(cfg.model_assetbundle, ";")
		-- 	if t[prof] then
		-- 		local t2 = Split(t[prof], ",")
		-- 		local bundle, asset = t2[1], t2[2]
		-- 		self:SetModel(bundle, asset, self.cur_item_index)
		-- 	end
		-- else
		-- 	local t = Split(cfg.model_assetbundle, ",")
		-- 	local bundle, asset = t[1], t[2]
		-- 	self:SetModel(bundle, asset, self.cur_item_index)
		-- end
		local prof = PlayerData.Instance:GetRoleBaseProf()
		local t = Split(cfg.model_assetbundle, ",")
		local bundle, asset = t[1], t[2]
		if string.find(bundle, "#") then
			bundle = string.gsub(bundle, "#", prof)
		end
		if string.find(asset, "#") then
			asset = string.gsub(asset, "#", prof)
		end
		local weapon_res = 0
		if cfg.weapon ~= "" then
			weapon_res = string.gsub(cfg.weapon, "#", prof)
		end
		self:SetModel(bundle, asset, self.cur_item_index, tonumber(weapon_res))
	end
end

function KaifuActivityPanelTwelve:Update()
	if self.obj_model == nil then return end
			self.obj_model.localRotation = self.obj_model.localRotation * Quaternion.Euler(0,self.rotate_speed * UnityEngine.Time.deltaTime, 0)
end

function KaifuActivityPanelTwelve:SetModel(bundle, asset, index, weapon_res)
	Runner.Instance:RemoveRunObj(self)
	if not bundle or not asset then return end
	local prof = PlayerData.Instance:GetRoleBaseProf()
	if self.model and self.cur_res_id ~= asset then
		self.cur_res_id = asset
		if index == 4 then
			self.model:SetTransform(MODEL_TRANS_CFG[index][prof])
		else
			-- self.model:SetTransform(MODEL_TRANS_CFG[index])
			if MODEL_TRANS_CFG[index] then
				self.model:SetModelScale(MODEL_TRANS_CFG[index].scale)
				self.model:SetRotation(MODEL_TRANS_CFG[index].rotation)
			end
			-- if index == 1 then
				if not self.equip_bg_effect_obj and not self.is_loading then
					self.is_loading = true
					PrefabPool.Instance:Load(AssetID("effects2/prefab/ui/ui_tongyongbaoju_1_prefab", "UI_tongyongbaoju_1"), function(prefab)
						if prefab then
							if self.equip_bg_effect_obj  ~= nil then
								GameObject.Destroy(self.equip_bg_effect_obj)
								self.equip_bg_effect_obj = nil
							end
							local obj = GameObject.Instantiate(prefab)
							PrefabPool.Instance:Free(prefab)

							local transform = obj.transform
							transform:SetParent(self.effect_root.transform, false)
							transform.localScale = Vector3(3, 3, 3)
							self.equip_bg_effect_obj = obj.gameObject
							self.is_loading = false
						end
					end)
				end
			-- end
			-- self.effect_root:SetActive(index == 1)
		end
		if camera_select[index] then
			self.model:SetDisplayPositionAndRotation(camera_select[index])
		end
		self.model:SetMainAsset(bundle, asset)
		self.model:SetWeaponResid(weapon_res)
	end
	if index == 1 then
		Runner.Instance:AddRunObj(self, 16)
		self.obj_model = self.model.draw_obj.root.transform
	end
end


PanelTwelveListCell = PanelTwelveListCell or BaseClass(BaseRender)

function PanelTwelveListCell:__init(instance)
	self.gift_name = self:FindVariable("GiftName")
	self.show_image_list = {}
	for i = 1, 4 do
		self.show_image_list[i] = self:FindVariable("ShowImage"..i)
	end
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
