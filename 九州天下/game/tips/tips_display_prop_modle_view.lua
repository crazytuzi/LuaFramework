local CommonFunc = require("game/tips/tips_common_func")

TipsDisplayPropModleView = TipsDisplayPropModleView or BaseClass(BaseView)

local Model_Config = {
	--法阵
	[DISPLAY_TYPE.SPIRIT_FAZHEN] = {
		rotation = Vector3(0, 10, 0),
		scale = Vector3(0.6, 0.6, 0.6),
	},
}

local FIX_SHOW_TIME = 8
function TipsDisplayPropModleView:__init()
	self.ui_config = {"uis/views/tips/proptips", "DisplayModleTip"}
	self.view_layer = UiLayer.Pop
	self:SetMaskBg(true)
	self.button_handle = {}
	self.get_way_list = {}
	self.button_label = {}
	self.can_reset_ani = true
	self.play_audio = true

	self.suit_list_data = {}
	self.suit_item_list = {}

	-- 有些模型需要手动循环播放动画 把模型类型加在下表中即可 [模型类型] = {播放动作参数, 完成动作回调参数(可以为空)}
	self.need_loop_model = {
		[DISPLAY_TYPE.ZHIBAO] = {"bj_rest", "rest_stop"}			--宝具
	}
end

function TipsDisplayPropModleView:__delete()
end

function TipsDisplayPropModleView:LoadCallBack()
	self.button_label = Language.Tip.ButtonLabel
	self.fix_show_time = 8
	self.ani_obj = self:FindObj("Ani")
	self.show_ani = self:FindVariable("ShowAni")

	self:ListenEvent("Close", BindTool.Bind(self.CloseView, self))
	self:ListenEvent("OnClickWay1", BindTool.Bind(self.OnClickWay, self, 1))
	self:ListenEvent("OnClickWay2", BindTool.Bind(self.OnClickWay, self, 2))
	self:ListenEvent("OnClickWay3", BindTool.Bind(self.OnClickWay, self, 3))

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("Item"))
	self.display = self:FindObj("Display")
	self.model = RoleModel.New("tips_display_view", 1000)
	self.model:SetDisplay(self.display.ui3d_display)
	self.ani_image = self:FindVariable("AniImage")

	self.button_root = self:FindObj("RightBtn")
	self.buttons = {}
	for i =1 ,1 do
		local button = self.button_root:FindObj("Btn"..i)
		local btn_text = button:FindObj("Text")
		self.buttons[i] = {btn = button, text = btn_text}
	end

	self.prop_name = self:FindVariable("EquipName")
	self.prop_type = self:FindVariable("EquipType")
	self.level_limit = self:FindVariable("Level")
	self.description = self:FindVariable("Description")
	self.fight_power = self:FindVariable("FightPower")
	self.suit_property = self:FindVariable("SuitProperty")
	self.suit_name = self:FindVariable("SuitName")
	self.attack = self:FindVariable("Attack")
	self.health = self:FindVariable("Health")
	self.defense = self:FindVariable("Defense")
	self.is_suit = self:FindVariable("IsSuit")

	self.show_ways = self:FindVariable("ShowTexts")
	self.show_icons = self:FindVariable("ShowIcons")
	self.text_way_list = {
		{is_show = self:FindVariable("ShowText1"), name = self:FindVariable("Text1")},
		{is_show = self:FindVariable("ShowText2"), name = self:FindVariable("Text2")},
		{is_show = self:FindVariable("ShowText3"), name = self:FindVariable("Text3")}
	}
	self.icon_list = {
		{is_show = self:FindVariable("ShowIcon1"), icon = self:FindVariable("Icon1")},
		{is_show = self:FindVariable("ShowIcon2"), icon = self:FindVariable("Icon2")},
		{is_show = self:FindVariable("ShowIcon3"), icon = self:FindVariable("Icon3")},
	}

	self.fight_power_txt = self:FindObj("FightPower")

	self.suit_list = self:FindObj("SuitList")
	local list_view_delegate = self.suit_list.list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self.foot_display = self:FindObj("FootDisplay")
	local ui_foot = self:FindObj("UI_Foot")
	local foot_camera = self:FindObj("FootCamera")
	self.foot_parent = {}
	for i = 1, 3 do
		self.foot_parent[i] = self:FindObj("Foot_" .. i)
	end
	local camera = foot_camera:GetComponent(typeof(UnityEngine.Camera))
	if not IsNil(camera) then
		-- self.left_display.ui3d_display:Display(ui_foot.gameObject, camera)
		self.foot_display.ui3d_display:DisplayPerspectiveWithOffset(ui_foot.gameObject, Vector3(0, 0, 0), Vector3(0, 11.5, 1.2), Vector3(90, 0, 0))
	end

	self.is_foot = self:FindVariable("IsFoot")
end

function TipsDisplayPropModleView:GetNumberOfCells()
	return #self.suit_list_data
end

function TipsDisplayPropModleView:RefreshView(cell, data_index)
	data_index = data_index + 1
	local suit_cell = self.suit_item_list[cell]
    -- local bunble, asset = ResPath.GetImages("bg_cell_equip")
	if suit_cell == nil then
		suit_cell = ItemCell.New()
		suit_cell:SetInstanceParent(cell.gameObject)
		-- suit_cell:SetItemCellBg(bunble, asset)
		suit_cell.root_node.toggle.group = self.suit_list.toggle_group
		self.suit_item_list[cell] = suit_cell
	end
	suit_cell:SetIndex(data_index)
	suit_cell:SetData({item_id = self.suit_list_data[data_index]})
	suit_cell:SetHighLight(self.suit_list_data[data_index] == self.data.item_id)
end

function TipsDisplayPropModleView:GetSuitListData(item_id)
	local master_collect_cfg = FashionData.Instance:GetMasterCollectListCfg()
	if not item_id or not master_collect_cfg or not next(master_collect_cfg) then return end
	for _,v in pairs(master_collect_cfg) do
		if item_id == v.weapon_id or item_id == v.dress_id or item_id == v.mount_id or item_id == v.wing_id then
			return v
		end
	end
end


--如果为空，就是可展示道具,否则为套装
function TipsDisplayPropModleView:SetSuitListData()
	self.suit_list_data = {}
	local suit_info = self:GetSuitListData(self.data.item_id)
	if not suit_info or not next(suit_info) then
	 	self.is_suit:SetValue(false)
	 	return 
	end
	self.is_suit:SetValue(true)
	self.suit_list_data[1] = suit_info.weapon_id
	self.suit_list_data[2] = suit_info.dress_id
	self.suit_list_data[3] = suit_info.mount_id
	self.suit_list_data[4] = suit_info.wing_id

	self.suit_property:SetValue(suit_info.suit_account or "")
	self.suit_name:SetValue(suit_info.suit_name or "")

	for i = #self.suit_list_data, 1, -1 do
		if self.suit_list_data[i] <= 0 then
			table.remove(self.suit_list_data, i)
		end
	end
end

function TipsDisplayPropModleView:OnFlushSuitList()
	if self.suit_list.scroller.isActiveAndEnabled then
		self.suit_list.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function TipsDisplayPropModleView:OpenCallBack()
	self:CloseCallBack()
	self:SetSuitListData()
	self.fight_power:SetValue(0)
	self.attack:SetValue(0)
	self.health:SetValue(0)
	self.defense:SetValue(0)
	self:Flush()
end

function TipsDisplayPropModleView:ReleaseCallBack()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end

	for _,v in pairs(self.suit_item_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.suit_item_list = {}

	-- 清理变量和对象
	self.ani_obj = nil
	self.show_ani = nil
	self.display = nil
	self.button_root = nil
	self.buttons = nil
	self.prop_name = nil
	self.prop_type = nil
	self.level_limit = nil
	self.description = nil
	self.fight_power = nil
	self.show_ways = nil
	self.show_icons = nil
	self.text_way_list = nil
	self.icon_list = nil
	self.fight_power_txt = nil
	self.button_handle = {}
	self.button_label = {}
	self.fix_show_time = nil
	self.can_reset_ani = nil
	self.get_way_list = {}
	self.suit_list_data = {}
	self.suit_property = nil
	self.suit_name = nil
	self.suit_list = nil
	self.attack = nil
	self.health = nil
	self.defense = nil
	self.is_suit = nil
	self.foot_display = nil
	for i = 1, 3 do
		self.foot_parent[i] = nil
	end
	self.is_foot = nil
	self.ani_image = nil
end

function TipsDisplayPropModleView:CloseCallBack()
	if self.close_call_back then
		self.close_call_back()
		self.close_call_back = nil
	end
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	if self.time_quest_2 then
		GlobalTimerQuest:CancelQuest(self.time_quest_2)
		self.time_quest_2 = nil
	end

	for k, v in pairs(self.button_handle) do
		v:Dispose()
	end
	self.button_handle = {}
	self.model:ClearModel()

	self.can_reset_ani = true
end

function TipsDisplayPropModleView:CloseView()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	--self.model:ClearModel()
	self:Close()
end

function TipsDisplayPropModleView:OnClickWay(index)
	if index == nil or self.get_way_list[index] == nil then return end
	ViewManager.Instance:CloseAll()
	self:Close()
	ViewManager.Instance:OpenByCfg(self.get_way_list[index], self.data)
end

function TipsDisplayPropModleView:ShowTipContent()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then return end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
	self.prop_name:SetValue(name_str)

	-- local level_befor = math.floor(item_cfg.limit_level % 100) ~= 0 and math.floor(item_cfg.limit_level % 100) or 100
	-- local level_behind = math.floor(item_cfg.limit_level % 100) ~= 0 and math.floor(item_cfg.limit_level / 100) or math.floor(item_cfg.limit_level / 100) - 1
	-- local level_zhuan = level_befor.."级【"..level_behind.."转】"
	-- local level_str = vo.level >= item_cfg.limit_level and string.format(level_zhuan)
	-- 				or string.format(Language.Mount.ShowRedStr, level_zhuan)

	self.level_limit:SetValue(string.format(Language.Common.Zhuan_Level, item_cfg.limit_level))
	self.description:SetValue("   "..item_cfg.description or "")
	self.prop_type:SetValue(Language.Common.PROP_TYPE[item_cfg.is_display_role])

	self.item:SetData(self.data)
	self.item:SetInteractable(false)

	self:SetRoleModel(item_cfg.is_display_role)
	self:SetFightPower(item_cfg.is_display_role)

	self.fight_power_txt:SetActive(big_type ~= GameEnum.ITEM_BIGTYPE_OTHER)		--被动消耗类隐藏,主动消耗类显示
end

-- 根据不同情况，显示和隐藏按钮
local function showHandlerBtn(self)
	if self.from_view == nil then
		return
	end

	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
	local handler_types = CommonFunc.GetOperationState(self.from_view, self.data, item_cfg, big_type)
	for k ,v in pairs(self.buttons) do
		local handler_type = handler_types[k]
		local tx = self.button_label[handler_type]
		if tx ~= nil then
			v.btn:SetActive(true)
			v.text.text.text = tx
			if self.button_handle[k] ~= nil then
				self.button_handle[k]:Dispose()
			end
			self.button_handle[k] = self:ListenEvent("Button"..k,
				BindTool.Bind(self.OnClickHandle, self, handler_type))
		else
			v.btn:SetActive(false)
		end
	end
end

function TipsDisplayPropModleView:SetModleRestAni()
	self.timer = self.fix_show_time
	if not self.time_quest then
		self.time_quest = GlobalTimerQuest:AddRunQuest(function()
			self.timer = self.timer - UnityEngine.Time.deltaTime
			if self.timer <= 0 then
				if self.model then
					local part = self.model.draw_obj:GetPart(SceneObjPart.Main)
					if part then
						part:SetTrigger("rest")
					end
				end
				self.timer = self.fix_show_time
			end
		end, 0)
	end
end

function TipsDisplayPropModleView:OnClickHandle(handler_type)
	if self.data == nil then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
	if not CommonFunc.DoClickHandler(self.data,item_cfg,handler_type,self.from_view,self.handle_param_t) then
		return
	end
	self:Close()
end

function TipsDisplayPropModleView:SetRoleModel(display_role)
	self.model:SetDisplayPositionAndRotation("tips_display_view", 1000)
	self.is_foot:SetValue(display_role == DISPLAY_TYPE.SHENGONG)
	local bundle, asset = nil, nil
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local main_role = Scene.Instance:GetMainRole()
	local res_id = 0
	self.display_role = display_role
	self.show_ani:SetValue(false)
	self.ani_image:SetAsset(nil, nil)
	if self.model then
		self.model:SetRotation(Vector3(0, 0, 0))
		self.model:SetModelScale(Vector3(0.8, 0.8, 0.8)) --披风模型太大需要改小
		local halo_part = self.model.draw_obj:GetPart(SceneObjPart.Halo)
		local weapon_part = self.model.draw_obj:GetPart(SceneObjPart.Weapon)
		local wing_part = self.model.draw_obj:GetPart(SceneObjPart.Wing)
		if halo_part then
			halo_part:RemoveModel()
		end
		if wing_part then
			wing_part:RemoveModel()
		end
		if weapon_part then
			weapon_part:RemoveModel()
		end
	end
	if display_role == DISPLAY_TYPE.MOUNT then
		--坐骑
		for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				bundle, asset = ResPath.GetMountModel(v.res_id)
				res_id = v.res_id
				self.model:SetMainAsset(bundle, asset, function ()
					self.model:SetRotation(Vector3(0, -60, 0))
					self.model:SetModelScale(Vector3(0.5, 0.5, 0.5))
					--按照策划需求改的 普天同庆·骑
					if v.res_id == 7304001 then
						self.model:SetModelScale(Vector3(0.25, 0.25, 0.25))
					end
				end)
				return
			end
		end
	elseif display_role == DISPLAY_TYPE.WING then
		--羽翼
		for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id
				local bundle, asset = ResPath.GetWingModel(res_id)	
					self.model:SetMainAsset(bundle, asset, function ()
				end)
				self.model:SetLayer(1, 1.0)		
				return
			end
		end
	elseif display_role == DISPLAY_TYPE.FASHION then
		--时装
		for k, v in pairs(FashionData.Instance:GetFashionCfgs()) do
			if v.active_stuff_id == self.data.item_id then
				local weapon_res_id = 0
				local weapon2_res_id = 0
				if v.part_type == 1 then
					res_id = v["resouce"..game_vo.prof..game_vo.sex]
					weapon_res_id = main_role:GetWeaponResId()
					weapon2_res_id = main_role:GetWeapon2ResId()
				else
					res_id = main_role:GetRoleResId()
					weapon_res_id = v["resouce"..game_vo.prof..game_vo.sex]
					local temp = Split(weapon_res_id, ",")
					weapon_res_id = temp[1]
					weapon2_res_id = temp[2]
				end
				self.model:SetRoleResid(res_id, function ()

				end)
				self.model:SetWeaponResid(weapon_res_id)
				if weapon2_res_id then
					self.model:SetWeapon2Resid(weapon2_res_id)
				end
				-- bundle, asset = ResPath.GetRoleModel(res_id)
				return
			end
		end
	elseif display_role == DISPLAY_TYPE.SPIRIT_HALO then
		--幻化美人光环 芳华
		local spirit_halo = BeautyHaloData.Instance:GetSpecialImagesCfgByItemId()
		for k,v in pairs(spirit_halo) do
			if v.item_id == self.data.item_id then
				self.model:SetDisplay(self.display.ui3d_display)
				--获得美人资源
				local bundle, asset = ResPath.GetGoddessNotLModel(11101)
				self.model:SetMainAsset(bundle, asset)
				self.model:SetHaloResid(v.res_id, true)
				return
			end
		end
	elseif display_role == DISPLAY_TYPE.HALO then
		--光环
		for k, v in pairs(HaloData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id
				break
			end
		end
		self.model:SetRoleResid(main_role:GetRoleResId())
		self.model:SetHaloResid(res_id)
		return
	elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
		--战斗坐骑==法印
		local image_cfg = FaZhenData.Instance:GetSpecialImagesCfg()
		if not image_cfg then return end
		for k, v in pairs(image_cfg) do
			if v.item_id == self.data.item_id then
				self.model:SetDisplayPositionAndRotation("tips_display_fazhen_view",1000)
				self.model:SetMainAsset(ResPath.GetFaZhenModel(v.res_id))
				return
			end
		end
	elseif display_role == DISPLAY_TYPE.SHENGONG then
		--足迹
		for k, v in pairs(ShengongData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id
				local info = {}
				info.res_id = v.res_id
				self:SetZujiModel(info, DISPLAY_TYPE.SHENGONG)
				return
			end
		end
	elseif display_role == DISPLAY_TYPE.SHENYI then
		--披风
		local Special_shenyi_cfg = ShenyiData.Instance:GetSpecialImagesCfg()
		if not Special_shenyi_cfg then return end
		for k, v in pairs(Special_shenyi_cfg) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id
				local info = {}
				local main_role = Scene.Instance:GetMainRole()
				info.role_res_id = main_role:GetRoleResId()
				info.wing_res_id = v.res_id
				self:SetModel(info, DISPLAY_TYPE.SHENYI)
				return
			end
		end
	elseif display_role == DISPLAY_TYPE.XIAN_NV then
		--美人
		local beauty_cfg = ConfigManager.Instance:GetAutoConfig("beautyconfig_auto")
		if beauty_cfg then
			local beauty_model_id = 0
			local beauty_huanhua_cfg = beauty_cfg.beauty_huanhua
			if beauty_huanhua_cfg then
				for k, v in pairs(beauty_huanhua_cfg) do
					if v.need_item == self.data.item_id then
						beauty_model_id = v.model
						break
					end
				end
			end

			local beauty_jihuo_cfg = beauty_cfg.beauty_active
			if beauty_jihuo_cfg then
				for k, v in pairs(beauty_jihuo_cfg) do
					if v.active_item_id == self.data.item_id then
						beauty_model_id = v.model
						break
					end
				end
			end


			if beauty_model_id > 0 then
				local info = {}
				info.role_res_id = beauty_model_id
				--bundle, asset = ResPath.GetGoddessModel(beauty_model_id)
				self:SetModel(info, DISPLAY_TYPE.XIAN_NV)
				return
			end
			res_id = beauty_model_id
		end

	elseif display_role == DISPLAY_TYPE.GENERAL then
		--名将
		local greate_cfg = FamousGeneralData.Instance:GetGeneralConfig()
		local greate_huanhua_cfg = greate_cfg.level
		local greate_model_id = 0
		if greate_cfg then
			for k, v in pairs(greate_huanhua_cfg) do
				if v.item_id == self.data.item_id then
					greate_model_id = v.image_id
				end
			end

			if greate_model_id > 0 then
				local info = {}
				info.greate_res_id = greate_model_id
				self:SetModel(info, DISPLAY_TYPE.GENERAL)
				return
			end
			res_id = greate_model_id
		end

	elseif display_role == DISPLAY_TYPE.BUBBLE then
		--气泡聊天框
		self.show_ani:SetValue(true)
		local index = CoolChatData.Instance:GetBubbleIndexByItemId(self.data.item_id)
		if index > 0 then
			local PrefabName = "BubbleChat" .. index

			PrefabPool.Instance:Load(AssetID("uis/chatres/bubbleres/" .. "bubble" .. index .. "_prefab", PrefabName), function(prefab)
				if prefab then
					local obj = GameObject.Instantiate(prefab)
					PrefabPool.Instance:Free(prefab)

					local transform = obj.transform
					for i = 0, self.ani_obj.transform.childCount - 1 do
						local child = self.ani_obj.transform:GetChild(i)
						if child then
							GameObject.Destroy(child.gameObject)
						end
					end
					transform:SetParent(self.ani_obj.transform, false)
				end
			end)
		end
	-- elseif display_role == DISPLAY_TYPE.ZHIBAO then
	-- 	--至宝==軍印
	-- 	for k, v in pairs(ZhiBaoData.Instance:GetActivityHuanHuaCfg()) do
	-- 		if v.active_item == self.data.item_id then
	-- 			bundle, asset = ResPath.GetHighBaoJuModel(v.image_id)
	-- 			res_id = v.image_id
	-- 			break
	-- 		end
	-- 	end
	elseif display_role == DISPLAY_TYPE.SPIRIT_FAZHEN then
		--法宝 圣物
		local spirit_fazhen = HalidomData.Instance:GetSpecialImagesCfg()
		if spirit_fazhen then
			for k, v in pairs(spirit_fazhen) do
				if v.item_id == self.data.item_id then
					local info = {}
					info.res_id = v.res_id
					bundle, asset = ResPath.GetBaoJuModel(v.res_id)
					self.model:SetMainAsset(bundle, asset)
					self.model:SetTransform(Model_Config[display_role])
					res_id = v.res_id
					return
				end
			end
		end
	elseif display_role == DISPLAY_TYPE.MULTI_MOUNT then
		local _, multi_cfg = MultiMountData.Instance:GetImageListCfg()
		for k, v in pairs(multi_cfg) do
			if v.active_need_item_id == self.data.item_id then
				bundle, asset = ResPath.GetMountModel(v.res_id)
				res_id = v.res_id
				self.model:SetDisplayPositionAndRotation("tips_display_multi_mount")
				self.model:SetMainAsset(bundle, asset, function ()
					-- self.model:SetRotation(Vector3(0, 0, 0))
					-- self.model:SetModelScale(Vector3(0.3, 0.3, 0.3))
				end)
				return
			end
		end	
	elseif 	display_role == DISPLAY_TYPE.HEADWEAR then
		--头饰
		local Special_headwear_cfg = HeadwearData.Instance:GetSpecialImagesCfg()
		if not Special_headwear_cfg then return end
		for k, v in pairs(Special_headwear_cfg) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id
				local main_role = Scene.Instance:GetMainRole()
				self.model:SetRoleResid(main_role:GetRoleResId())
				self.model:SetTouShiResid(v.res_id)
				return
			end
		end

	elseif 	display_role == DISPLAY_TYPE.MASK then
		--面饰
		local Special_mask_cfg = MaskData.Instance:GetSpecialImagesCfg()
		if not Special_mask_cfg then return end
		for k, v in pairs(Special_mask_cfg) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id
				local main_role = Scene.Instance:GetMainRole()
				self.model:SetRoleResid(main_role:GetRoleResId())
				self.model:SetMaskResid(v.res_id)
				return
			end
		end

	elseif 	display_role == DISPLAY_TYPE.WAIST then
		--腰饰
		local Special_waist_cfg = WaistData.Instance:GetSpecialImagesCfg()
		if not Special_waist_cfg then return end
		for k, v in pairs(Special_waist_cfg) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id
				local main_role = Scene.Instance:GetMainRole()
				self.model:SetRoleResid(main_role:GetRoleResId())
				self.model:SetWaistnResid(v.res_id)
				return
			end
		end

	elseif 	display_role == DISPLAY_TYPE.BEAD then
		--灵珠
		local Special_bead_cfg = BeadData.Instance:GetSpecialImagesCfg()
		if not Special_bead_cfg then return end
		for k, v in pairs(Special_bead_cfg) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id
				local bundle, asset = ResPath.GetLingZhuModel(v.res_id, true)	
				self.model:SetMainAsset(bundle, asset) 
				self.model:SetModelScale(Vector3(0.5, 0.5, 0.5))
				return
			end
		end

	elseif 	display_role == DISPLAY_TYPE.FABAO then
		--法宝
		local Special_fabao_cfg = FaBaoData.Instance:GetSpecialImagesCfg()
		if not Special_fabao_cfg then return end
		for k, v in pairs(Special_fabao_cfg) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id
				local bundle, asset = ResPath.GetXianBaoModel(v.res_id)	
				self.model:SetMainAsset(bundle, asset) 
				self.model:SetLayer(1, 1.0)
				-- self.model:SetTrigger("rest")
				return
			end
		end

	elseif 	display_role == DISPLAY_TYPE.KIRINARM then
		--麒麟臂
		local Special_kirin_arm_cfg = KirinArmData.Instance:GetSpecialImagesCfg()
		if not Special_kirin_arm_cfg then return end
		for k, v in pairs(Special_kirin_arm_cfg) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id
				local role_vo = GameVoManager.Instance:GetMainRoleVo()
				local show_res_id = KirinArmData.Instance:GetSpecialResId(v.image_id, role_vo.sex, true)
				local bundle, asset = ResPath.GetQilinBiModel(show_res_id, role_vo.sex)	
				self.model:SetMainAsset(bundle, asset) 
				self.model:SetDisplayPositionAndRotation("tips_display_kirin_arm")
				return
			end
		end
	elseif display_role == DISPLAY_TYPE.HEAD_FRAME then
		self.show_ani:SetValue(true)

		local index = HeadFrameData.Instance:GetPrefabByItemId(self.data.item_id)
		if index >= 0 then
			self.ani_image:SetAsset(ResPath.GetHeadFrameIcon(index))
		end
	elseif display_role == DISPLAY_TYPE.LITTTLE_PET then
		local little_pet_cfg = LittlePetData.Instance:GetLittlePetCfg()
		if not little_pet_cfg then return end
		for k, v in pairs(little_pet_cfg) do
			if v.active_item_id == self.data.item_id then
				res_id = v.using_img_id
				local asset, bundle = ResPath.GetLittlePetModel(res_id)
				self.model:SetMainAsset(asset, bundle)
			end
		end
	end


	if self.model and res_id > 0 and display_role ~= DISPLAY_TYPE.WING then
		-- self.model:SetModelScale(Vector3(0.5, 0.5, 0.5))
	end
	self.can_reset_ani = display_role ~= DISPLAY_TYPE.FIGHT_MOUNT
	if bundle and asset and self.model then
		self.model:SetMainAsset(bundle, asset)
		local is_loop, ani_name_tbl = self:CheckIsNeedLoop()
		if is_loop then
			self.model:SetLoopAnimal(ani_name_tbl[1], ani_name_tbl[2])
		elseif display_role ~= DISPLAY_TYPE.FIGHT_MOUNT then
			self.model:SetTrigger("rest")
		end
	end
end

function TipsDisplayPropModleView:SetZujiModel(info, display_type)
	for i = 1, 3 do
			local bundle, asset = ResPath.GetZuJiModel(info.res_id)
		PrefabPool.Instance:Load(AssetID(bundle, asset), function (prefab)
			if nil == prefab then
				return
			end
			if self.foot_parent[i] then
				local parent_transform = self.foot_parent[i].transform
				for j = 0, parent_transform.childCount - 1 do
					GameObject.Destroy(parent_transform:GetChild(j).gameObject)
				end
				local obj = GameObject.Instantiate(prefab)
				local obj_transform = obj.transform
				obj_transform:SetParent(parent_transform, false)
				PrefabPool.Instance:Free(prefab)
			end
		end)
	end
end

--设置道具战斗力
function TipsDisplayPropModleView:SetFightPower(display_role)
	local fight_power = 0
	local cfg = {}

	--坐骑
	if display_role == DISPLAY_TYPE.MOUNT then
		for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				cfg = MountData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				self:SetProperty(cfg)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	--翅膀
	elseif display_role == DISPLAY_TYPE.WING then
		for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				cfg = WingData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				self:SetProperty(cfg)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	--时装
	elseif display_role == DISPLAY_TYPE.FASHION then
		for k, v in pairs(FashionData.Instance:GetFashionCfgs()) do
			if v.active_stuff_id == self.data.item_id then
				cfg = FashionData.Instance:GetFashionUpgradeCfg(v.index, v.part_type, false, 1)
				self:SetProperty(cfg)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	--光环
	elseif display_role == DISPLAY_TYPE.HALO then
			for k, v in pairs(HaloData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == self.data.item_id then
					cfg = HaloData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
					self:SetProperty(cfg)
					fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
					break
				end
			end
	elseif display_role == DISPLAY_TYPE.SPIRIT then
		-- for k, v in pairs(SpiritData.Instance:GetSpiritResourceCfg()) do
		-- 	if v.id == self.data.item_id then
		-- 	end
		-- end
	elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
		for k, v in pairs(FaZhenData.Instance:GetSpecialImageUpgradeCfg()) do
			if v.stuff_id == self.data.item_id and v.grade == 1 then
				cfg = v
				self:SetProperty(cfg)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.SHENGONG then
		for k, v in pairs(ShengongData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				cfg = ShengongData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				self:SetProperty(cfg)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.SHENYI then
		for k, v in pairs(ShenyiData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				cfg = ShenyiData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				self:SetProperty(cfg)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.XIAN_NV then
		--读取美人战斗力
		local beauty_cfg = BeautyData.Instance:GetBeautyCfg()
		local beauty_huanhua_cfg = beauty_cfg.beauty_huanhua
		for k, v in pairs(beauty_huanhua_cfg) do
			if v.need_item == self.data.item_id then
				--cfg = GoddessData.Instance:GetXianNvHuanHuaLevelCfg(v.seq, 1)
				cfg = BeautyData.Instance:GetCurHuanhuaAttrCfg(v.seq, 1)
				self:SetProperty(cfg)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
			end
		end
		if fight_power == 0 then
			local beauty_jihuo_cfg = beauty_cfg.beauty_active
			for k, v in pairs(beauty_jihuo_cfg) do
				if v.active_item_id == self.data.item_id then
					cfg = v
					self:SetProperty(cfg)
					fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				end
			end
		end

	elseif display_role == DISPLAY_TYPE.BUBBLE then
		cfg = CoolChatData.Instance:GetBubbleCfgByItemId(self.data.item_id)
		self:SetProperty(cfg)
		fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))

	elseif display_role == DISPLAY_TYPE.HEAD_FRAME then
		cfg = HeadFrameData.Instance:GetHeadFrameCfgByItemId(self.data.item_id)
		self:SetProperty(cfg)
		fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))

	elseif display_role == DISPLAY_TYPE.GENERAL then
		--名将
		local greate_cfg = FamousGeneralData.Instance:GetGeneralConfig()
		local greate_huanhua_cfg = greate_cfg.level
		for k, v in pairs(greate_huanhua_cfg) do
			if v.item_id == self.data.item_id then
				cfg = v
				self:SetProperty(cfg)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
			end
		end

	elseif display_role == DISPLAY_TYPE.ZHIBAO then
		--军印
		for k, v in pairs(ZhiBaoData.Instance:GetZhiBaoHuanHua()) do
			if v.stuff_id == self.data.item_id then
				cfg = ZhiBaoData.Instance:GetHuanHuaLevelCfg(v.huanhua_type, false, 1)
				self:SetProperty(cfg)
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.SPIRIT_HALO then
		--美人光环
		local all_info = BeautyHaloData.Instance:GetSpecialImageUpgradeCfgBySiGrade(self.data.item_id, 1)

		if all_info ~= nil then
			self:SetProperty(all_info)
			fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(all_info))
		end
	elseif display_role == DISPLAY_TYPE.SPIRIT_FAZHEN then
		--法宝 圣物
		local spirit_fazhen = HalidomData.Instance:GetSpecialImageUpgradeCfg()
		if spirit_fazhen then
			for k, v in pairs(spirit_fazhen) do
				if v.stuff_id == self.data.item_id and v.grade == 1 then
					cfg = v
					self:SetProperty(cfg)
					fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
					break
				end
			end
		end
	elseif display_role == DISPLAY_TYPE.MULTI_MOUNT then
		local _, multi_cfg = MultiMountData.Instance:GetImageListCfg()
		local multi_mount_id = nil
		for k,v in pairs(multi_cfg) do
			if v.active_need_item_id == self.data.item_id then
				multi_mount_id = v.mount_id
				break
			end
		end

		if multi_mount_id ~= nil then
			local cfg = MultiMountData.Instance:GetLeveInfoById(multi_mount_id, 0)
			self:SetProperty(cfg)
			fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
		end

	elseif display_role == DISPLAY_TYPE.HEADWEAR then
		for k, v in pairs(HeadwearData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				cfg = HeadwearData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				self:SetProperty(cfg)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end

	elseif display_role == DISPLAY_TYPE.MASK then
		for k, v in pairs(MaskData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				cfg = MaskData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				self:SetProperty(cfg)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end

	elseif display_role == DISPLAY_TYPE.WAIST then
		for k, v in pairs(WaistData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				cfg = WaistData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				self:SetProperty(cfg)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end

	elseif display_role == DISPLAY_TYPE.BEAD then
		for k, v in pairs(BeadData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				cfg = BeadData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				self:SetProperty(cfg)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end

	elseif display_role == DISPLAY_TYPE.FABAO then
		for k, v in pairs(FaBaoData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				cfg = FaBaoData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				self:SetProperty(cfg)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end

	elseif display_role == DISPLAY_TYPE.KIRINARM then
		for k, v in pairs(KirinArmData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				cfg = KirinArmData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				self:SetProperty(cfg)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.LITTTLE_PET then
		local cfg = LittlePetData.Instance:GetLittlePetBaseAttr(self.data.item_id)
		self:SetProperty(cfg)
		fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
	end 

	self.fight_power:SetValue(fight_power)
end

function TipsDisplayPropModleView:OnFlush(param_t)
	if self.model ~= nil then
		self.display.ui3d_display:ResetRotation()
	end
	showHandlerBtn(self)
	self:ShowTipContent()
	if self.can_reset_ani then
		self:SetModleRestAni()
	end

	self:SetWay()
	self:OnFlushSuitList()
end

function TipsDisplayPropModleView:SetData(data, from_view, param_t, close_call_back)
	if not data then
		return
	end
	if type(data) == "string" then
		self.data = CommonStruct.ItemDataWrapper()
		self.data.item_id = data
	else
		self.data = data
	end
	self.close_call_back = close_call_back

	self:Open()
	self.from_view = from_view or TipsFormDef.FROM_NORMAL
	--self.from_view = from_view or TipsFormDef.FROM_BAG
	self.handle_param_t = param_t or {}

	self:Flush()
end

function TipsDisplayPropModleView:SetModel(info, display_type)
	self.model:ResetRotation()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	local cfg = nil
	--设置模型和模型的大小
	if display_type == DISPLAY_TYPE.XIAN_NV then
		--美人
		self.model:SetGoddessModelResInfo(info)
	elseif display_type == DISPLAY_TYPE.SHENYI then
		--神翼==披风
		self.model:SetRoleResid(info.role_res_id)
		self.model:SetMantleResid(info.wing_res_id)

	elseif display_type == DISPLAY_TYPE.GENERAL then
		--名将
		local bundle, asset = ResPath.GetMingJiangRes(info.greate_res_id)
		self.model:SetMainAsset(bundle, asset)
		self.model:SetModelScale(Vector3(0.5, 0.5, 0.5))
	end
end

function TipsDisplayPropModleView:CalToShowAnim(is_change_tab, is_shenyi)
	local timer = GameEnum.GODDESS_ANIM_LONG_TIME
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer = timer - UnityEngine.Time.deltaTime
		if timer <= 0 or is_change_tab == true then
			local func = function()
				self:PlayAnim(is_change_tab)
				is_change_tab = false
				timer = GameEnum.GODDESS_ANIM_LONG_TIME
				GlobalTimerQuest:CancelQuest(self.time_quest)
			end
			if is_shenyi then
				if timer <= 6 then
					func()
				end
			else
				func()
			end
		end
	end, 0)
end

function TipsDisplayPropModleView:PlayAnim(is_change_tab)
	local is_change_tab = is_change_tab
	if self.time_quest_2 then
		GlobalTimerQuest:CancelQuest(self.time_quest_2)
		self.time_quest_2 = nil
	end
	local timer = GameEnum.GODDESS_ANIM_SHORT_TIME
	local count = 1
	self.time_quest_2 = GlobalTimerQuest:AddRunQuest(function()
		timer = timer - UnityEngine.Time.deltaTime
		if timer <= 0 or is_change_tab == true then
			if self.model then
				self.model:SetTrigger(GoddessData.Instance:GetShowTriggerName(count))
				count = count + 1
			end
			timer = GameEnum.GODDESS_ANIM_SHORT_TIME
			is_change_tab = false
			if count == 5 then
				GlobalTimerQuest:CancelQuest(self.time_quest_2)
				self.time_quest_2 = nil
				self:CalToShowAnim()
			end
		end
	end, 0)
end

function TipsDisplayPropModleView:SetWay()
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	local getway_cfg = ConfigManager.Instance:GetAutoConfig("getway_auto").get_way
	local get_way = item_cfg.get_way or ""
	local way = Split(get_way, ",")
	for k, v in ipairs(self.icon_list) do
		v.is_show:SetValue(false)
		self.text_way_list[k].is_show:SetValue(false)
	end
	if next(way) then
		for k, v in pairs(way) do
			local getway_cfg_k = getway_cfg[tonumber(way[k])]
			if (nil == getway_cfg_k and tonumber(v) == 0) or (getway_cfg_k and getway_cfg_k.icon) then
				self.show_icons:SetValue(true)
				self.show_ways:SetValue(false)
				if tonumber(v) == 0 then
					self.icon_list[k].is_show:SetValue(true)
					local bundle, asset = ResPath.GetMainUIButton("Icon_System_Shop")
					self.icon_list[k].icon:SetAsset(bundle, asset)
					self.get_way_list[k] = "ShopView"
				else
					self.icon_list[k].is_show:SetValue(true)
					local bundle, asset = ResPath.GetMainUIButton(getway_cfg_k.icon)
					self.icon_list[k].icon:SetAsset(bundle, asset)
					self.get_way_list[k] = getway_cfg_k.open_panel
				end
			else
				self.show_ways:SetValue(true)
				self.show_icons:SetValue(false)
				if tonumber(v) == 0 then
					self.text_way_list[k].is_show:SetValue(true)
					self.text_way_list[k].name:SetValue(Language.Common.Shop)
					self.get_way_list[k] = "ShopView"
				elseif getway_cfg_k then
					self.text_way_list[k].is_show:SetValue(true)
					if getway_cfg_k.button_name ~= "" and getway_cfg_k.button_name ~= nil then
						self.text_way_list[k].name:SetValue(getway_cfg_k.button_name)
					else
						self.text_way_list[k].name:SetValue(getway_cfg_k.discription)
					end
					self.get_way_list[k] = getway_cfg_k.open_panel
				end
			end
		end
	elseif nil == next(way) and (nil ~= item_cfg.get_msg and "" ~= item_cfg.get_msg) then
		self.show_ways:SetValue(true)
		local get_msg = item_cfg.get_msg or ""
		local msg = Split(get_msg, ",")
		self.show_icons:SetValue(false)
		for k, v in pairs(msg) do
			self.text_way_list[k].is_show:SetValue(true)
			self.text_way_list[k].name:SetValue(v)
		end
	end
end

function TipsDisplayPropModleView:CheckIsNeedLoop()
	for k,v in pairs(self.need_loop_model) do
		if self.display_role == k then
			return true, v
		end
	end
	return nil, nil
end

function TipsDisplayPropModleView:SetProperty(cfg)
	if cfg then
		self.attack:SetValue(cfg.gong_ji or cfg.attack or cfg.gongji or 0)
		self.health:SetValue(cfg.max_hp or cfg.maxhp or cfg.hp or cfg.qixue or 0)
		self.defense:SetValue(cfg.fang_yu or cfg.fangyu or 0)
	end
end
