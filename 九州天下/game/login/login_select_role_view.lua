function LoginView:InitSelectRoleView()
	self.select_role = self:FindObj("SelectRole")
	self:ListenEvent("OnClickOpenAdventure", BindTool.Bind(self.OnClickOpenAdventure, self))

	-- 选择角色旋转区域
	self.select_role_rotate_area = self:FindObj("SelectRoleEventTrigger")
	local event_trigger = self.select_role_rotate_area:GetComponent(typeof(EventTriggerListener))
	event_trigger:AddDragListener(BindTool.Bind(self.OnSelectRoleDrag, self))

	----------------------------------------------------
	-- 选择角色列表生成滚动条
	self.select_role_cell_list = {}
	self.select_role_listview_data = {}
	self.select_role_list = self:FindObj("RoleList")
	local selectrole_list_delegate = self.select_role_list.list_simple_delegate
	--生成数量
	selectrole_list_delegate.NumberOfCellsDel = function()
		return #self.select_role_listview_data or 0
	end
	--刷新函数
	selectrole_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshSelectRoleListView, self)
	-- 移动scrollerview的时候调用
	-- self.select_role_list.scroller.scrollerScrollingChanged = function ()
	-- end
	----------------------------------------------------
	self.select_role_prof = 0
	self.select_role_id = 0

	self.is_enter_select_role = false -- 是否进入选择角色面板

end

function LoginView:DeleteSelectRoleView()
	self.select_role = nil
	self.select_role_rotate_area = nil
	self.select_role_list = nil
end

function LoginView:RefreshSelectRoleListView(cell, data_index, cell_index)
	data_index = data_index + 1

	local role_cell = self.select_role_cell_list[cell]
	if role_cell == nil then
		role_cell = SelectRoleItem.New(cell.gameObject)
		role_cell:SetClickCallBack(BindTool.Bind1(self.OnClickContractHandler, self))
		if data_index == 1 then
			role_cell.root_node.toggle.isOn = true
		end
		self.select_role_cell_list[cell] = role_cell
	end

	local role_list_ack_info = LoginData.Instance:GetRoleListAck()
	if role_list_ack_info.count < 3 then
		if #self.select_role_listview_data > data_index then
			role_cell.root_node.toggle.group = self.select_role_list.toggle_group
		else
			role_cell.root_node.toggle.group = nil
		end
		if #self.select_role_listview_data <= data_index then
			role_cell.root_node.toggle.enabled = false
		else
			role_cell.root_node.toggle.enabled = true
		end
	else
		role_cell.root_node.toggle.group = self.select_role_list.toggle_group
		role_cell.root_node.toggle.enabled = true
	end

	role_cell:SetIndex(data_index)
	role_cell:SetData(self.select_role_listview_data[data_index])

	if not self.is_enter_select_role and data_index == 1 then
		self.is_enter_select_role = true
		self.select_role_id = 0
		self:OnClickContractHandler(role_cell)
		role_cell.root_node.toggle.isOn = true
		cell.gameObject:SetActive(true)
	else
		role_cell.root_node.toggle.isOn = false
	end
end

-- 列表选择回调函数处理
function LoginView:OnClickContractHandler(cell)
	if not cell or not cell.data then return end

	local data = cell.data
	if data.role_id > 0 then
		self.select_zhujue_rotate_cache = {x = 0, y = 0, z = 0}

		self:SelectRoleProf(data)

		self.select_role_id = data.role_id

		local user_vo = GameVoManager.Instance:GetUserVo()
		user_vo:SetNowRole(data.role_id)
		local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
		mainrole_vo.name = data.role_name

		-- UIScene:SetRoleModelResInfo(mainrole_vo)
	else
		self.select_prof = 0
		self:OnChangeToCreate()
	end

end

-- 刷新选择角色面板
function LoginView:FlushSelectRoleView()
	local role_list_ack_info = LoginData.Instance:GetRoleListAck()
	local temp_role_list = TableCopy(role_list_ack_info.role_list)
	table.sort(temp_role_list, SortTools.KeyUpperSorter("last_login_time"))
	if role_list_ack_info.count < 3 then
		local plus_sign = {
			role_id = -9999,
			role_name = Language.Login.CreateRole,
			avatar = 0,
			sex = 0,
			prof = 0,
			country = 0,
			level = 0,
			create_time = 0,
			last_login_time = 0,
			wuqi_id = 0,
			shizhuang_wuqi = 0,
			shizhuang_body = 0,
			wing_used_imageid = 0,
			halo_used_imageid = 0,
			fazhen_used_imageid = 0,
			headwear_used_imageid = 0,
			mask_used_imageid = 0,
			waist_used_imageid = 0,
			kirin_arm_used_imageid = 0,
			bead_used_imageid = 0,
			fabao_used_imageid = 0,
		}
		table.insert(temp_role_list, plus_sign)
	end
	self.select_role_listview_data = temp_role_list
	if self.select_role_list.scroller.isActiveAndEnabled then
		-- GlobalTimerQuest:AddDelayTimer(function()
			self.select_role_list.scroller:ReloadData(0)
		-- end, 0)
	end
	local select_role_state = UtilU3d.GetCacheData("select_role_state")
	if select_role_state == 1 then
		UtilU3d.CacheData("select_role_state", 0)
		InitCtrl:HideLoading()
	end
end

-- 切换选择角色面板
function LoginView:OnChangeToSelectRole()
	if self:IsOpen() then
		self.is_open_create = false
		self.is_enter_select_role = false

		-- TipsCtrl.Instance:CloseLoadingTips()

		-- self.select_server:SetActive(false)
		-- self.create_role:SetActive(false)
		-- self.login_root:SetActive(false)
		self.select_role:SetActive(true)

		self:Flush("flush_select_role_view")
	end
end

-- 开启冒险
function LoginView:OnClickOpenAdventure()
	-- 提前打开加载页（为了进游戏时的体验）
	Scene.Instance:OpenSceneLoading()
	if self.select_role_id > 0 then
		LoginData.Instance:SetCurrSelectRoleId(self.select_role_id)
		LoginCtrl.SendRoleReq()
	else
		self:OnChangeToCreate()
	end
end


function LoginView:SelectRoleProf(data)
	local prof = data.prof
	local sex = data.sex

	local role_id = data.role_id

	local role_res_id = 0
	local weapon_res_id = 0
	local weapon2_res_id = 0

	local wing_res_id = 0
	local halo_res_id = 0
	local fazhen_res_id = ""
	local headwear_res_id = 0
	local mask_res_id = 0
	local waist_res_id = 0
	local kirin_arm_res_id = 0

	if self.select_role_id == role_id then
		return
	end

	-- -- 卸载登录界面(龙出来喷火那个)
	-- local SceneManager = UnityEngine.SceneManagement.SceneManager
	-- local scene = SceneManager.GetSceneByName("Dljm01_Main")
	-- if scene:IsValid() then
	-- 	local roots = scene:GetRootGameObjects()
	-- 	for i = 0,roots.Length-1 do
	-- 		local obj = roots[i]
	-- 		obj:SetActive(false)
	-- 	end
	-- 	SceneManager.UnloadSceneAsync(scene)
	-- end

	TipsCtrl.Instance:ShowLoadingTips()

	self.select_role_id = role_id

	if self.draw_obj ~= nil then
		self.draw_obj:DeleteMe()
		self.draw_obj = nil
	end

	local bundle = "scenes/map/gz_chuangjue_main"
	local asset = "Gz_ChuangJue_Main"
	-- if prof == 1 then
	-- 	bundle = "scenes/map/gz_chuangjue_main"
	-- 	asset = "Gz_ChuangJue_Main"
	-- 	-- self.is_male = true
	-- elseif prof == 2 then
	-- 	bundle = "scenes/map/gz_chuangjue_main"
	-- 	asset = "Gz_ChuangJue_Main"
	-- 	-- self.is_male = false
	-- elseif prof == 3 then
	-- 	bundle = "scenes/map/gz_chuangjue_main"
	-- 	asset = "Gz_ChuangJue_Main"
	-- 	-- self.is_male = false
	-- else
	-- 	bundle = "scenes/map/gz_chuangjue_main"
	-- 	asset = "Gz_ChuangJue_Main"
	-- 	-- self.is_male = true
	-- end

	-- 清空CG实例
	if self.cg_instance_list then
		for k,v in pairs(self.cg_instance_list) do
			GameObject.Destroy(v)
		end
	end
	self.cg_instance_list = {}

	if self.cg_handler ~= nil then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

	self:ChangeScene(bundle, asset, function()
		self.select_server:SetActive(false)
		self.create_role:SetActive(false)
		self.login_root:SetActive(false)

		-- self.select_role:SetActive(true)
		local key = bundle .. asset
		for k,v in pairs(self.scene_cache) do
			if k ~= key then
				local objs = v.roots
				for i = 0,objs.Length-1 do
					local obj = objs[i]
					obj:SetActive(false)
				end
			end
		end
		local center = UnityEngine.GameObject.Find("RolePos")
		if not center then
			return
		end
		self.draw_obj = DrawObj.New(self, center.transform)
		self.draw_obj.root.transform.localPosition = Vector3.zero
		self.draw_obj.root.transform.localRotation = Quaternion.identity

		-- 先查找时装的武器和衣服
		if data.shizhuang_wuqi ~= 0 then
			local wuqi_cfg = LoginData.Instance:GetFashionConfig(SHIZHUANG_TYPE.WUQI, data.shizhuang_wuqi)
			if wuqi_cfg then
				local cfg = wuqi_cfg["resouce" .. prof .. sex]
				if type(cfg) == "string" then
					local temp_table = Split(cfg, ",")
					if temp_table then
						weapon_res_id = tonumber(temp_table[1]) or 0
						weapon2_res_id = tonumber(temp_table[2]) or 0
					end
				elseif type(cfg) == "number" then
					weapon_res_id = cfg
				end
			end
		end
		if data.shizhuang_body ~= 0 then
			local clothing_cfg = LoginData.Instance:GetFashionConfig(SHIZHUANG_TYPE.BODY, data.shizhuang_body)
			if clothing_cfg then
				local index = string.format("resouce%s%s", prof, sex)
				local res_id = clothing_cfg[index]
				role_res_id = res_id
			end
		end
		if data.body_use_type == APPEARANCE_BODY_USE_TYPE.APPEARANCE_BODY_USE_TYPE_SHENQI then 		-- 神器衣服形象
			if ShenqiData.Instance then
				local res_id = ShenqiData.Instance:GetDataBaojiaResCfgByIamgeID(data)
				role_res_id = res_id
			end
		end

		if data.wuqi_use_type == APPEARANCE_USE_TYPE.APPEARANCE_WUQI_USE_TYPE_SHENQI then 			-- 神器武器形象
			if ShenqiData.Instance then
				weapon_res_id = ShenqiData.Instance:GetDataResCfgByIamgeID(data)
			end
		end

		wing_res_id = self:UpdateWingResId(data.wing_used_imageid)
		halo_res_id = self:UpdateHaloResId(data.halo_used_imageid)
		fazhen_res_id = self:UpdateFazhenResId(data.fazhen_used_imageid)
		--装扮形象
		headwear_res_id = self:UpdateHeadwearResId(data.appearance.ugs_head_wear_img_id)
		mask_res_id = self:UpdateMaskResId(data.appearance.ugs_mask_img_id)
		waist_res_id = self:UpdateWaistResId(data.appearance.ugs_waist_img_id)
		-- kirin_arm_res_id = self:UpdateKirinArmResId(data.appearance.ugs_kirin_arm_img_id, sex)

		-- 最后查找职业表
		local job_cfgs = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job
		local role_job = job_cfgs[prof]
		if role_job ~= nil then
			if role_res_id == 0 then
				role_res_id = role_job["model" .. sex]
			end
			if weapon_res_id == 0 then
				weapon_res_id = role_job["right_weapon" .. sex]
			end
			if weapon2_res_id == 0 then
				weapon2_res_id = role_job["left_weapon" .. sex]
			end
		else
			if role_res_id == 0 then
				role_res_id = 1001001
			end
			if weapon_res_id == 0 then
				weapon_res_id = 900100101
			end
		end

		-- 主角
		local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
		main_part:ChangeModel(ResPath.GetRoleModel(role_res_id))

		-- 武器1
		local wepapon_part = self.draw_obj:GetPart(SceneObjPart.Weapon)
		wepapon_part:ChangeModel(ResPath.GetWeaponModel(weapon_res_id))

		-- 武器2
		if weapon2_res_id > 0 then
			local wepapon_part2 = self.draw_obj:GetPart(SceneObjPart.Weapon2)
			wepapon_part2:ChangeModel(ResPath.GetWeaponModel(weapon2_res_id))
		end

		-- 羽翼
		if wing_res_id > 0 then
			local wing_part = self.draw_obj:GetPart(SceneObjPart.Wing)
			wing_part:ChangeModel(ResPath.GetWingModel(wing_res_id))
		end

		-- 光环
		if halo_res_id > 0 then
			local halo_part = self.draw_obj:GetPart(SceneObjPart.Halo)
			halo_part:ChangeModel(ResPath.GetHaloModel(halo_res_id))
		end

		-- 法阵
		if fazhen_res_id ~= "" then
			local fazhen_part = self.draw_obj:GetPart(SceneObjPart.FaZhen)
			fazhen_part:ChangeModel(ResPath.GetFaZhenModel(fazhen_res_id))
		end

		-- 头饰
		if headwear_res_id > 0 then
			local headwear_part = self.draw_obj:GetPart(SceneObjPart.TouShi)
			headwear_part:ChangeModel(ResPath.GetTouShiModel(headwear_res_id))
		end

		-- 面饰
		if mask_res_id > 0 then
			local mask_part = self.draw_obj:GetPart(SceneObjPart.Mask)
			mask_part:ChangeModel(ResPath.GetMaskModel(mask_res_id))
		end

		-- 腰饰
		if waist_res_id > 0 then
			local waist_part = self.draw_obj:GetPart(SceneObjPart.Waist)
			waist_part:ChangeModel(ResPath.GetWaistModel(waist_res_id))
		end

		-- -- 麒麟臂
		-- if kirin_arm_res_id > 0 then
		-- 	local kirin_arm_part = self.draw_obj:GetPart(SceneObjPart.QilinBi)
		-- 	kirin_arm_part:ChangeModel(ResPath.GetQilinBiModel(kirin_arm_res_id, sex))
		-- end

		TipsCtrl.Instance:CloseLoadingTips()
	end)
end

function LoginView:UpdateWingResId(index)
	local wing_config = ConfigManager.Instance:GetAutoConfig("wing_auto")
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local image_cfg = nil
	local wing_res_id = 0
	if wing_config then
		if index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = wing_config.special_img[index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = wing_config.image_list[index]
		end
		if image_cfg then
			wing_res_id = image_cfg.res_id
		end
	end
	return wing_res_id
end

function LoginView:UpdateHaloResId(index)
	local halo_config = ConfigManager.Instance:GetAutoConfig("halo_auto")
	local image_cfg = nil
	local halo_res_id = 0
	if halo_config then
		if index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = halo_config.special_img[index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = halo_config.image_list[index]
		end
		if image_cfg then
			halo_res_id = image_cfg.res_id
		end
	end
	return halo_res_id
end

function LoginView:UpdateFazhenResId(index)
	local fazhen_config = ConfigManager.Instance:GetAutoConfig("fazhen_cfg_auto")
	local image_cfg = nil
	local fazhen_res_id = ""
	if fazhen_config then
		if index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = fazhen_config.special_img[index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = fazhen_config.image_list[index]
		end
		if image_cfg then
			fazhen_res_id = image_cfg.res_id
		end
	end
	return fazhen_res_id
end

function LoginView:UpdateHeadwearResId(index)
	local headwear_config = ConfigManager.Instance:GetAutoConfig("ugs_head_wear_auto")
	local image_cfg = nil
	local headwear_res_id = 0
	if headwear_config then
		if index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = headwear_config.special_img[index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = headwear_config.image_list[index]
		end
		if image_cfg then
			headwear_res_id = image_cfg.res_id
		end
	end
	return headwear_res_id
end

function LoginView:UpdateMaskResId(index)
	local mask_config = ConfigManager.Instance:GetAutoConfig("ugs_mask_auto")
	local image_cfg = nil
	local mask_res_id = 0
	if mask_config then
		if index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = mask_config.special_img[index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = mask_config.image_list[index]
		end
		if image_cfg then
			mask_res_id = image_cfg.res_id
		end
	end
	return mask_res_id
end

function LoginView:UpdateWaistResId(index)
	local waist_config = ConfigManager.Instance:GetAutoConfig("ugs_waist_auto")
	local image_cfg = nil
	local waist_res_id = 0
	if waist_config then
		if index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = waist_config.special_img[index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = waist_config.image_list[index]
		end
		if image_cfg then
			waist_res_id = image_cfg.res_id
		end
	end
	return waist_res_id
end

-- function LoginView:UpdateKirinArmResId(index,sex)
-- 	local kirin_arm_config = ConfigManager.Instance:GetAutoConfig("ugs_kirin_arm_auto")
-- 	local image_cfg = nil
-- 	local kirin_arm_res_id = 0
-- 	if kirin_arm_config then
-- 		if index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
-- 			image_cfg = kirin_arm_config.special_img[index - GameEnum.MOUNT_SPECIAL_IMA_ID]
-- 		else
-- 			image_cfg = kirin_arm_config.image_list[index]
-- 		end
-- 		if image_cfg then
-- 			local show_res_id = KirinArmData.Instance:GetResIdByImgId(image_cfg.image_id, sex, false)
-- 			kirin_arm_res_id = show_res_id
-- 		end
-- 	end
-- 	return kirin_arm_res_id
-- end

-- 选择角色被拖转动事件
function LoginView:OnSelectRoleDrag(data)
	if self.draw_obj and self.draw_obj.root then
		local cache = self.select_zhujue_rotate_cache
		self.select_zhujue_rotate_cache = {x = cache.x, y = -data.delta.x * 0.25 + cache.y, z = cache.z}
		self.draw_obj.root.transform.localRotation = Quaternion.Euler(
			self.select_zhujue_rotate_cache.x, self.select_zhujue_rotate_cache.y, self.select_zhujue_rotate_cache.z)
	end
end


---------------------------------
-- 选择多人角色Item
---------------------------------
SelectRoleItem = SelectRoleItem or BaseClass(BaseCell)

function SelectRoleItem:__init()
	self.label_name = self:FindVariable("Name")
	self.label_level = self:FindVariable("Level")
	self.label_bg = self:FindVariable("Bg")
	self.img_camp = self:FindVariable("Camp")
	self.img_head = self:FindVariable("HeadImg")
	self.is_create_role = self:FindVariable("IsCreateRole")

	-- 这里调用的是basecell里面的回调函数
	self:ListenEvent("OnClickItem", BindTool.Bind(self.OnClick, self))
end

function SelectRoleItem:OnFlush()
	if nil == self.data then return end
	self.is_create_role:SetValue(false)
	local level_str = PlayerData.GetLevelString(self.data.level)
	if self.data.role_id <= 0 then
		self.is_create_role:SetValue(true)
		level_str = ""
	else
		local bundle, asset = ResPath.GetLoginRes("select_camp_" .. self.data.camp)
		self.img_camp:SetAsset(bundle, asset)
		bundle, asset = ResPath.GetRoleHeadBig(self.data.prof, self.data.sex)
		self.img_head:SetAsset(bundle, asset)
	end
	self.label_name:SetValue(self.data.role_name)
	self.label_level:SetValue(level_str)
end

