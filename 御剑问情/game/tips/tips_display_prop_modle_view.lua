local CommonFunc = require("game/tips/tips_common_func")
local FOOT_TYPE_INDEX = 17

local DISPLAYNAME = {
	[7113001] = "display_model_tips_fight_mount_1",
	[7114001] = "display_model_tips_fight_mount_2",
	[7111001] = "display_model_tips_fight_mount_3",
	[7115001] = "display_model_tips_fight_mount_4",
	[7116001] = "display_model_tips_fight_mount_5",
	[7117001] = "display_model_tips_fight_mount_6",
	[7118001] = "display_model_tips_fight_mount_7",
	[13005] = "display_model_tips_zhibao2",
	[13016] = "display_model_tips_zhibao3",
	[13017] = "display_model_tips_zhibao4",
	[10024001] = "spirit_huanhua_panel1",
	[11003] = "display_model_tips_huoban1",
}
TipsDisplayPropModleView = TipsDisplayPropModleView or BaseClass(BaseView)

local FIX_SHOW_TIME = 8
function TipsDisplayPropModleView:__init()
	self.ui_config = {"uis/views/tips/proptips_prefab", "DisplayModleTip"}
	self.view_layer = UiLayer.Pop
	self.button_handle = {}
	self.get_way_list = {}
	self.button_label = Language.Tip.ButtonLabel
	self.fix_show_time = 8
	self.can_reset_ani = true
	self.play_audio = true

	-- 有些模型需要手动循环播放动画 把模型类型加在下表中即可 [模型类型] = {播放动作参数, 完成动作回调参数(可以为空)}
	self.need_loop_model = {
		[DISPLAY_TYPE.ZHIBAO] = {"bj_rest", "rest_stop"}			--宝具
	}
end

function TipsDisplayPropModleView:__delete()

end

function TipsDisplayPropModleView:LoadCallBack()
	self.ani_obj = self:FindObj("Ani")
	self.show_ani = self:FindVariable("ShowAni")

	self:ListenEvent("Close", BindTool.Bind(self.CloseView, self))
	self:ListenEvent("OnClickWay1", BindTool.Bind(self.OnClickWay, self, 1))
	self:ListenEvent("OnClickWay2", BindTool.Bind(self.OnClickWay, self, 2))
	self:ListenEvent("OnClickWay3", BindTool.Bind(self.OnClickWay, self, 3))

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("Item"))
	self.display = self:FindObj("Display")
	self.model = RoleModel.New("display_model_tips_wing")
	self.model:SetDisplay(self.display.ui3d_display)
	self.ani_image = self:FindVariable("ani_image")

	self.button_root = self:FindObj("RightBtn")
	self.buttons = {}
	for i =1 ,5 do
		local button = self.button_root:FindObj("Btn"..i)
		local btn_text = button:FindObj("Text")
		self.buttons[i] = {btn = button, text = btn_text}
	end

	self.prop_name = self:FindVariable("EquipName")
	self.prop_type = self:FindVariable("EquipType")
	self.level_limit = self:FindVariable("Level")
	self.description = self:FindVariable("Description")
	self.fight_power = self:FindVariable("FightPower")
	self.aperture_image = self:FindVariable("ApertureImage")
	self.title_image = self:FindVariable("Title")
	self.show_effect = self:FindVariable("ShowEffect")

	self.show_ways = self:FindVariable("ShowTexts")
	self.show_icons = self:FindVariable("ShowIcons")
	self.text_way_list = {
		{is_show = self:FindVariable("ShowText1"), name = self:FindVariable("Text1")},
		{is_show = self:FindVariable("ShowText2"), name = self:FindVariable("Text2")},
		{is_show = self:FindVariable("ShowText3"), name = self:FindVariable("Text3")}
	}
	self.icon_list = {
		{is_show = self:FindVariable("ShowIcon1"), icon = self:FindVariable("Icon1"), text = self:FindVariable("IconText1")},
		{is_show = self:FindVariable("ShowIcon2"), icon = self:FindVariable("Icon2"), text = self:FindVariable("IconText2")},
		{is_show = self:FindVariable("ShowIcon3"), icon = self:FindVariable("Icon3"), text = self:FindVariable("IconText3")},
	}
	self.tab_images = self:FindVariable("tab_images")

	self.fight_power_txt = self:FindObj("FightPower")
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
	self.tab_images = nil
	self.aperture_image = nil
	self.title_image = nil
	self.show_effect = nil
	self.ani_image = nil

	for k, v in pairs(self.button_handle) do
		v:Dispose()
	end
	self.button_handle = {}
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

	self.can_reset_ani = true
end

function TipsDisplayPropModleView:CloseView()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self:Close()
end

function TipsDisplayPropModleView:OnClickWay(index)
	if index == nil or self.get_way_list[index] == nil then return end

	if self.get_way_list[index] == ViewName.DisCount and self.data.item_id == 26405 then
		local DisCountGoddessPrase = 2
		local is_activity_open = nil ~= DisCountData.Instance:GetDiscountInfoByType(DisCountGoddessPrase)
		if is_activity_open then
			ViewManager.Instance:CloseAll()
			self:Close()
			local current_xiannv_id = 5
			local cfg = GoddessData.Instance:GetXianNvCfg(current_xiannv_id)
			if nil == cfg then return end
			local t = Split(cfg.open_panel, "#")
			local view_name = t[1]
			if nil ~= DisCountData.Instance:GetDiscountInfoByType(DisCountGoddessPrase) then
				local v, k = DisCountData.Instance:GetDiscountInfoByType(DisCountGoddessPrase)
				ViewManager.Instance:Open(view_name, nil, "index", {k})
			end
			return
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.GoddessActiveEndTip)
			return
		end
	else
		ViewManager.Instance:CloseAll()
		self:Close()
		ViewManager.Instance:OpenByCfg(self.get_way_list[index], self.data)
	end


end

function TipsDisplayPropModleView:ShowTipContent()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then return end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local name_str = "<color="..ITEM_TIP_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
	self.prop_name:SetValue(name_str)
	local bundle, asset = ResPath.GetTipsImageByIndex(item_cfg.color)
	self.tab_images:SetAsset(bundle, asset)

	local level_befor = math.floor(item_cfg.limit_level % 100) ~= 0 and math.floor(item_cfg.limit_level % 100) or 100
	local level_behind = math.floor(item_cfg.limit_level % 100) ~= 0 and math.floor(item_cfg.limit_level / 100) or math.floor(item_cfg.limit_level / 100) - 1
	local level_zhuan = level_befor.."级【"..level_behind.."转】"
	local level_str = vo.level >= item_cfg.limit_level and string.format(level_zhuan)
					or string.format(Language.Mount.ShowRedStr, level_zhuan)
	self.level_limit:SetValue(level_str)
	self.description:SetValue("   "..item_cfg.description or "")	
	
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.show_effect:SetValue(false)
	if item_cfg.use_type == GameEnum.ITEM_OPEN_TITLE then
		self.show_effect:SetValue(true)
		local bundle, asset = ResPath.GetTitleIcon(item_cfg.param1)
		self.title_image:SetAsset(bundle, asset)
	end

	local item_type = item_cfg.is_display_role == DISPLAY_TYPE.FOOTPRINT and FOOT_TYPE_INDEX or item_cfg.is_display_role		-- 足迹类型的文字显示
	self.prop_type:SetValue(Language.Common.PROP_TYPE[item_type])

	--伙伴法阵道具特殊处理
	if item_cfg.is_display_role == 9 then --9表示法阵，如果是法阵则隐藏地上的光圈图片
		self.aperture_image:SetValue(false)
	else
		self.aperture_image:SetValue(true)
	end

	self.item:SetData(self.data)
	self.item:SetInteractable(false)

	self:SetRoleModel(item_cfg.is_display_role)
	self:SetFightPower(item_cfg.is_display_role)
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

function TipsDisplayPropModleView:GetDisplayName(id, display_name)
	local index = tonumber(id)
	local display_name  = display_name
	for k,v in pairs(DISPLAYNAME) do
		if k == index then
			display_name = v
			return display_name
		end
	end
	return display_name
end

--灵玉的特殊处理
function TipsDisplayPropModleView:SetSpecialModle(modle_id)
	local display_name = "display_model_tips_zhibao"
	if nil ~= DISPLAYNAME[modle_id] then
		display_name = DISPLAYNAME[modle_id]
	end
	return display_name
end

function TipsDisplayPropModleView:SetRoleModel(display_role)
	local bundle, asset = nil, nil
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local main_role = Scene.Instance:GetMainRole()
	local res_id = 0
	self.display_role = display_role
	self.show_ani:SetValue(false)
	self.ani_image:SetAsset(nil, nil)
	if self.model then
		self.model:ClearModel()

		local halo_part = self.model.draw_obj:GetPart(SceneObjPart.Halo)
		local weapon_part = self.model.draw_obj:GetPart(SceneObjPart.Weapon)
		local wing_part = self.model.draw_obj:GetPart(SceneObjPart.Wing)
		self.model.display:SetRotation(Vector3(0, 0, 0))
		if display_role ~= DISPLAY_TYPE.FOOTPRINT and display_role ~= DISPLAY_TYPE.MOUNT then
			self.model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
		end
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
		for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id
				break
			end
		end
		self.model:SetMainAsset(ResPath.GetMountModel(res_id))
		self.model:SetPanelName("display_model_tips_mount")
	elseif display_role == DISPLAY_TYPE.WING then
		for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id
				break
			end
		end
		self.model:SetPanelName("display_model_tips_wing1")
		self.model:SetRoleResid(main_role:GetRoleResId())
		self.model:SetWingResid(res_id)
		local cfg = self.model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.ROLE_WING], WingData.Instance:GetWingModelResCfg(), DISPLAY_PANEL.PROP_TIP)
		if cfg then
			self.model:SetTransform(cfg)
		end
	elseif display_role == DISPLAY_TYPE.FASHION then
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

				self.model:SetPanelName("display_model_tips_fashion")
				self.model:ResetRotation()
				self.model:SetRoleResid(res_id)
				self.model:SetWeaponResid(weapon_res_id)
				if weapon2_res_id then
					self.model:SetWeapon2Resid(weapon2_res_id)
				end
				-- bundle, asset = ResPath.GetRoleModel(res_id)
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.HALO then
			for k, v in pairs(HaloData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == self.data.item_id then
					res_id = v.res_id
					break
				end
			end
			self.model:SetPanelName("display_model_tips_huoban")
			self.model:SetRoleResid(main_role:GetRoleResId())
			self.model:SetHaloResid(res_id)
	elseif display_role == DISPLAY_TYPE.FOOTPRINT then
			for k, v in pairs(FootData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == self.data.item_id then
					res_id = v.res_id
					break
				end
			end
			self.model:SetPanelName("display_model_tips_footprint")
			self.model:SetRoleResid(main_role:GetRoleResId())
			self.model:SetFootResid(res_id)
			self.model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
	elseif display_role == DISPLAY_TYPE.SPIRIT then
		self.model:SetPanelName("display_model_tips_spirit")
		for k, v in pairs(SpiritData.Instance:GetSpiritResourceCfg()) do
			if v.id == self.data.item_id then
				bundle, asset = ResPath.GetSpiritModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
		for k, v in pairs(SpiritData.Instance:GetSpiritHuanImageConfig()) do
			if v.item_id == self.data.item_id then
				bundle, asset = ResPath.GetSpiritModel(v.res_id)
				res_id = v.res_id
				if DISPLAYNAME[res_id] ~= nil then
					self.model:SetPanelName("spirit_huanhua_panel1")
				else
					self.model:SetPanelName("display_model_tips_spirit")
				end
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
		for k, v in pairs(FightMountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				bundle, asset = ResPath.GetFightMountModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
		local display_name = self:GetDisplayName(asset, "display_model_tips_fight_mount")
		self.model:SetPanelName(display_name)
	elseif display_role == DISPLAY_TYPE.MULTI_MOUNT then
		cfg = MultiMountData.Instance:GetMountCfgByItemId(self.data.item_id) or {}
		local mount_grade_cfg = MultiMountData.Instance:GetMountInfoCfgByIndex(cfg.mount_id or 1)
		bundle, asset = ResPath.GetMountModel(mount_grade_cfg.res_id)
		res_id = mount_grade_cfg.res_id
		local display_name = self:GetDisplayName(asset, "display_model_tips_multi_mount")
		self.model:SetPanelName(display_name)
	elseif display_role == DISPLAY_TYPE.SHENGONG then
		for k, v in pairs(ShengongData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id
				local info = {}
				info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
				info.weapon_res_id = v.res_id
				self.model:SetPanelName("display_model_tips_huoban")
				self:SetModel(info, DISPLAY_TYPE.SHENGONG)
				return
			end
		end
	-- 头饰
	elseif display_role == DISPLAY_TYPE.TOU_SHI then
		for k, v in pairs(TouShiData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				local main_vo = GameVoManager.Instance:GetMainRoleVo()
				local info = {}
				info.prof = main_vo.prof
				info.sex = main_vo.sex
				info.appearance = {}
				info.appearance.fashion_body = main_vo.appearance.fashion_body
				info.appearance.toushi_used_imageid = v.image_id + GameEnum.MOUNT_SPECIAL_IMA_ID -- 特殊资源形象+ 1000

				self.model:ResetRotation()
				self.model:SetPanelName("display_model_tips_toushi")
				self.model:SetModelResInfo(info, true, true, true, true, true, true)
				return
			end
		end
	-- 腰饰
	elseif display_role == DISPLAY_TYPE.YAO_SHI then
		for k, v in pairs(WaistData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				local main_vo = GameVoManager.Instance:GetMainRoleVo()
				local info = {}
				info.prof = main_vo.prof
				info.sex = main_vo.sex
				info.appearance = {}
				info.appearance.fashion_body = main_vo.appearance.fashion_body
				info.appearance.yaoshi_used_imageid = v.image_id + GameEnum.MOUNT_SPECIAL_IMA_ID -- 特殊资源形象+ 1000

				self.model:ResetRotation()
				self.model:SetPanelName("display_model_tips_waist")
				self.model:SetModelResInfo(info, true, true, true, true, true, true)
				return
			end
		end
	-- 面饰
	elseif display_role == DISPLAY_TYPE.MIAN_SHI then
		for k, v in pairs(MaskData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				local main_vo = GameVoManager.Instance:GetMainRoleVo()
				local info = {}
				info.prof = main_vo.prof
				info.sex = main_vo.sex
				info.appearance = {}
				info.appearance.fashion_body = main_vo.appearance.fashion_body
				info.appearance.mask_used_imageid = v.image_id + GameEnum.MOUNT_SPECIAL_IMA_ID -- 特殊资源形象+ 1000

				self.model:ResetRotation()
				self.model:SetPanelName("display_model_tips_mask")
				self.model:SetModelResInfo(info, true, true, true, true, true, true)
			end
		end
	-- 麒麟臂
	elseif display_role == DISPLAY_TYPE.QIN_LIN_BI then
		for k, v in pairs(QilinBiData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				local main_vo = GameVoManager.Instance:GetMainRoleVo()
				local bundle, asset = ResPath.GetQilinBiModel(v["res_id" .. main_vo.sex .. "_h"], main_vo.sex)
				self.model:ResetRotation()
				self.model:SetPanelName("display_model_tips_qilinbi")
				self.model:SetMainAsset(bundle, asset)
				return
			end
		end

	elseif display_role == DISPLAY_TYPE.SHENYI then
		for k, v in pairs(ShenyiData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				res_id = v.res_id
				local info = {}
				info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
				info.wing_res_id = v.res_id
				self.model:SetPanelName("display_model_tips_huoban")
				self:SetModel(info, DISPLAY_TYPE.SHENYI)
				return
			end
		end
	elseif display_role == DISPLAY_TYPE.XIAN_NV then
		self.model:SetPanelName("display_model_tips_huoban")
		local goddess_cfg = ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto")
		if goddess_cfg then
			local xiannv_resid = 0
			local xiannv_cfg = goddess_cfg.xiannv
			if xiannv_cfg then
				for k, v in pairs(xiannv_cfg) do
					if v.active_item == self.data.item_id then
						xiannv_resid = v.resid
						break
					end
				end
			end
			if xiannv_resid == 0 then
				local huanhua_cfg = goddess_cfg.huanhua
				if huanhua_cfg then
					for k, v in pairs(huanhua_cfg) do
						if v.active_item == self.data.item_id then
							xiannv_resid = v.resid
							break
						end
					end
				end
			end
			if xiannv_resid > 0 then
				local info = {}
				info.role_res_id = xiannv_resid
				bundle, asset = ResPath.GetGoddessModel(xiannv_resid)
				if DISPLAYNAME[xiannv_resid] ~= nil then
					self.model:SetPanelName("display_model_tips_huoban1")
				else
					self.model:SetPanelName("display_model_tips_huoban")
				end
				self:SetModel(info, DISPLAY_TYPE.XIAN_NV)
				return
			end
			res_id = xiannv_resid
		end
	elseif display_role == DISPLAY_TYPE.BUBBLE then
		self.show_ani:SetValue(true)

		local index = CoolChatData.Instance:GetBubbleIndexByItemId(self.data.item_id)
		if index > 0 then
			local PrefabName = "BubbleChat" .. index

			PrefabPool.Instance:Load(AssetID("uis/chatres", PrefabName), function(prefab)
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
	elseif display_role == DISPLAY_TYPE.HEAD_FRAME then
		self.show_ani:SetValue(true)

		local index = HeadFrameData.Instance:GetPrefabByItemId(self.data.item_id)
		if index >= 0 then
			self.ani_image:SetAsset(ResPath.GetHeadFrameIcon(index))
		end
	elseif display_role == DISPLAY_TYPE.ZHIBAO then
		for k, v in pairs(ZhiBaoData.Instance:GetActivityHuanHuaCfg()) do
			if v.active_item == self.data.item_id then
				res_id = v.image_id
				bundle, asset = ResPath.GetHighBaoJuModel(v.image_id)
				self.model:SetPanelName(self:SetSpecialModle(res_id))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.GENERAL then
		--名将
		local greate_cfg = FamousGeneralData.Instance:GetGeneralList()

		local greate_model_id = 0
		if greate_cfg then
			for k, v in pairs(greate_cfg) do
				if v.item_id == self.data.item_id then
					greate_model_id = v.image_id
				end
			end

			--幻化形象
			if greate_model_id == 0 then
				local special_img_cfg = SpecialGeneralData.Instance:GetSpecialImagesCfg()
				for k,v in pairs(special_img_cfg) do
					if v.item_id == self.data.item_id then
						greate_model_id = v.res_id or 0
					end
				end
			end

			if greate_model_id > 0 then
				local info = {}
				info.greate_res_id = greate_model_id
				bundle, asset = ResPath.GetGeneralRes(info.greate_res_id)
				self.model:SetPanelName("famous_general_panel")
			end
			res_id = greate_model_id
		end
	elseif display_role == DISPLAY_TYPE.SUPER_BABY then
		--超级宝宝
		local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
		if item_cfg then
			local cfg_info = BaobaoData.Instance:GetSuperBabyCfgInfo(item_cfg.param1)
			if cfg_info then
				bundle, asset = ResPath.GetSpiritModel(cfg_info.res_id)
			end
			self.model:SetPanelName("super_baobao_panel")
		end
	end

	self.can_reset_ani = display_role ~= DISPLAY_TYPE.FIGHT_MOUNT
	if bundle and asset and self.model then
		self.model:SetMainAsset(bundle, asset)
		local is_loop, ani_name_tbl = self:CheckIsNeedLoop()
		if is_loop then
			self.model:SetLoopAnimal(ani_name_tbl[1], ani_name_tbl[2])
		elseif display_role == DISPLAY_TYPE.GENERAL then
				self.model:SetTrigger("attack3")
		elseif display_role ~= DISPLAY_TYPE.FIGHT_MOUNT then
			self.model:SetTrigger(ANIMATOR_PARAM.REST)
		end
	end
end

function TipsDisplayPropModleView:SetFightPower(display_role)
	local fight_power = 0
	local cfg = {}
	cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	fight_power = cfg.power
	if display_role == DISPLAY_TYPE.MOUNT then
		for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				cfg = MountData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.WING then
		for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				cfg = WingData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.FASHION then
		for k, v in pairs(FashionData.Instance:GetFashionCfgs()) do
			if v.active_stuff_id == self.data.item_id then
				cfg = FashionData.Instance:GetFashionUpgradeCfg(v.index, v.part_type, false, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.HALO then
			for k, v in pairs(HaloData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == self.data.item_id then
					cfg = HaloData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
					fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
					break
				end
			end
	elseif display_role == DISPLAY_TYPE.SPIRIT then
		for k, v in pairs(SpiritData.Instance:GetSpiritHuanImageConfig()) do
			if v.item_id == self.data.item_id then
				cfg = SpiritData.Instance:GetSpiritHuanhuaCfgById(v.active_image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
		for k, v in pairs(FightMountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				cfg = FightMountData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.SHENGONG then
		for k, v in pairs(ShengongData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				cfg = ShengongData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.SHENYI then
		for k, v in pairs(ShenyiData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				cfg = ShenyiData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.MULTI_MOUNT then
			cfg = MultiMountData.Instance:GetMountCfgByItemId(self.data.item_id) or {}
			fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
	elseif display_role == DISPLAY_TYPE.XIAN_NV then
		local goddess_cfg = ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto")
		for k, v in pairs(goddess_cfg.huanhua) do
			if v.active_item == self.data.item_id then
				cfg = GoddessData.Instance:GetXianNvHuanHuaLevelCfg(v.id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
			end
		end

	elseif display_role == DISPLAY_TYPE.BUBBLE then
		cfg = CoolChatData.Instance:GetBubbleCfgByItemId(self.data.item_id)
		fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
	elseif display_role == DISPLAY_TYPE.FOOTPRINT then
		for k, v in pairs(FootData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == self.data.item_id then
				cfg = FootData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.ZHIBAO then
		for k, v in pairs(ZhiBaoData.Instance:GetZhiBaoHuanHua()) do
			if v.stuff_id == self.data.item_id then
				cfg = ZhiBaoData.Instance:GetHuanHuaLevelCfg(v.huanhua_type, false, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	end

	self.fight_power:SetValue(fight_power)
	self.fight_power_txt:SetActive(fight_power > 0)
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
	self.handle_param_t = param_t or {}
	self:Flush()
end

function TipsDisplayPropModleView:SetModel(info, display_type)
	self.model:ResetRotation()
	self.model:SetGoddessModelResInfo(info)
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	local cfg = nil
	if display_type == DISPLAY_TYPE.XIAN_NV then
		self:CalToShowAnim(true)
	elseif display_type == DISPLAY_TYPE.SHENYI then
		self:CalToShowAnim(true, true)
	elseif display_type == DISPLAY_TYPE.SHENGONG then
		local resid = GoddessData.Instance:GetShowXiannvResId()
	end
end

function TipsDisplayPropModleView:CalToShowAnim(is_change_tab, is_shenyi)
	self:PlayAnim(is_change_tab)
end

function TipsDisplayPropModleView:PlayAnim(is_change_tab)
	local count = 1
	self.model:SetTrigger(GoddessData.Instance:GetShowTriggerName(count))
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
					local bundle, asset = ResPath.GetMainUI("Icon_System_Shop")
					self.icon_list[k].icon:SetAsset(bundle, asset)
					asset = asset .. "_text"
					self.icon_list[k].text:SetAsset(bundle, asset)
					self.get_way_list[k] = "ShopView"
				else
					self.icon_list[k].is_show:SetValue(true)
					local bundle, asset = ResPath.GetMainUI(getway_cfg_k.icon)
					if asset and asset ~= "" then
						self.icon_list[k].icon:SetAsset(bundle, asset)
						asset = asset .. "_text"
						self.icon_list[k].text:SetAsset(bundle, asset)
					end

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

function TipsDisplayPropModleView:SetImgFuLingTips()
	local img_fuling_type = ImageFuLingData.Instance:GetImgFuLingTypeByDisplayType(self.display_role) or -1
	local stuff_cfg = ImageFuLingData.Instance:GetImgFuLingAllUpStuffCfg(img_fuling_type)
	if nil == img_fuling_type or nil == stuff_cfg or nil == stuff_cfg[self.data.item_id] then
		self.img_fuling_tips:SetValue("")
		return
	end

	local is_open_img_fuling = OpenFunData.Instance:CheckIsHide("img_fuling")
	local cfg = OpenFunData.Instance:GetSingleCfg("img_fuling")
	local str = Language.Advance.ImgFuLingTips
	if not is_open_img_fuling then
		local level_des = PlayerData.GetLevelString(cfg.trigger_param)
		str = str .. "<color=#ff0000>" .. level_des .. Language.Common.Open .. "</color>"
	end
	self.img_fuling_tips:SetValue(str)
end