-- require("game/login/login_select_role_view")

function LoginView:InitSelectRoleView()
	self.select_role = self:FindObj("SelectRole")

	-- 旋转区域
	self.obj_select_role_event = self:FindObj("SelectRoleEventTrigger")
	local event_trigger = self.obj_select_role_event:GetComponent(typeof(EventTriggerListener))
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

	self:ListenEvent("OnClickOpenAdventure", BindTool.Bind(self.OnClickOpenAdventure, self))

	----------------------------------------------------
	-- 选择角色列表
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
	-- self:RefreshSelectRoleList()
	----------------------------------------------------
	self.select_role_prof = 0
	self.select_role_id = 0

	self.is_enter_select_role = false -- 是否进入选择角色面板

end

function LoginView:DeleteSelectRoleView()
	-- 额,貌似不能清数据,清了会突然不见数据了,给释放了.
	-- if self.select_role_cell_list then
	-- 	for k,v in pairs(self.select_role_cell_list) do
	-- 		v:DeleteMe()
	-- 	end
	-- 	self.select_role_cell_list = {}
	-- end
	-- self.select_role_id = 0
	-- GlobalTimerQuest:CancelQuest(self.fight_delay_time)
	-- GlobalTimerQuest:CancelQuest(self.fight_delay_time2)
end

-- 角色被拖转动事件
function LoginView:OnRoleDrag(data)
	if nil ~= self.draw_obj and nil ~= self.draw_obj.root and not IsNil(self.draw_obj.root.gameObject) then
		self.draw_obj.root.transform:Rotate(u3d.vec3(0, -data.delta.x * 0.25, 0))
	end
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
	local data = cell.data
	if not cell or not data or data.role_id < 0 then
		self.select_prof = 0
		self:OnChangeToCreate()
		return
	else
		self:SelectRoleProf(data)

		self.select_role_id = data.role_id

		local user_vo = GameVoManager.Instance:GetUserVo()
		user_vo:SetNowRole(data.role_id)
		local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
		mainrole_vo.name = data.role_name
		-- UIScene:SetRoleModelResInfo(mainrole_vo)
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
		}
		for i = 1, 3 - role_list_ack_info.count do
			table.insert(temp_role_list, plus_sign)
		end
	end

	self.select_role_listview_data = temp_role_list
	if self.select_role_list.scroller.isActiveAndEnabled then
		self.select_role_list.scroller:ReloadData(0)
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
		-- UIScene:ChangeScene(self.ui_scene, {[1] = {"Pingtai01"}})

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
		-- 销毁预加载的AB包
		LoginCtrl.Instance:DestoryDependBundles()
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

	if self.select_role_id == role_id then
		return
	end
	-- 卸载登录界面
	local SceneManager = UnityEngine.SceneManagement.SceneManager
	local scene = SceneManager.GetSceneByName("W2_TS_DengLu")
	if scene:IsValid() then
		local roots = scene:GetRootGameObjects()
		for i = 0,roots.Length-1 do
			local obj = roots[i]
			obj:SetActive(false)
		end
		SceneManager.UnloadSceneAsync(scene)
	end

	TipsCtrl.Instance:ShowLoadingTips()

	self.select_role_id = role_id

	if self.draw_obj ~= nil then
		self.draw_obj:DeleteMe()
		self.draw_obj = nil
	end
	-- GlobalTimerQuest:CancelQuest(self.fight_delay_time)
	-- GlobalTimerQuest:CancelQuest(self.fight_delay_time2)

	local bundle, asset
	if prof == 1 then
		bundle = "scenes/map/w2_ts_nanzhan_main"
		asset = "W2_TS_NanZhan_Main"
		self.is_male = true
	elseif prof == 2 then
		bundle = "scenes/map/w2_ts_liandao_main"
		asset = "W2_TS_LianDao_Main"
		self.is_male = false
	elseif prof == 3 then
		bundle = "scenes/map/w2_ts_nanshan_main"
		asset = "W2_TS_NanShan_Main"
		self.is_male = true
	else
		bundle = "scenes/map/w2_ts_nvqin_main"
		asset = "W2_TS_NvQin_Main"
		self.is_male = false
	end

	if self.cg_handler ~= nil then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

	if self.touch_handle and self.is_click_event then
		self.is_click_event = false
		EasyTouch.RemoveCamera(self.cg_camera)
		EasyTouch.On_TouchDown = EasyTouch.On_TouchDown - self.touch_handle
	end

	if IS_AUDIT_VERSION then
		bundle = "scenes/map/w2_ts_nanzhan_main"
		asset = "W2_TS_NanZhan_Main"
	end

	self:ChangeScene(bundle, asset, function()
		self.select_server:SetActive(false)
		self.create_role:SetActive(false)
		self.login_root:SetActive(false)

		-- self.select_role:SetActive(true)
		local key = bundle..asset
		for k,v in pairs(self.scene_cache) do
			if k ~= key then
				local objs = v.roots
				for i = 0,objs.Length-1 do
					local obj = objs[i]
					obj:SetActive(false)
				end
			else
				local objs = v.roots
				for i = 0,objs.Length-1 do
					local obj = objs[i]
					obj:SetActive(true)
				end
			end
		end
		local center = UnityEngine.GameObject.Find("Center")
		if not center then
			return
		end
		local camera = UnityEngine.GameObject.Find("Camera")
		self.cg_camera = camera:GetComponent(typeof(UnityEngine.Camera))
		if self.cg_camera then
			EasyTouch.AddCamera(self.cg_camera)
		end
		self.draw_obj = DrawObj.New(self, center.transform)
		self.draw_obj.root.transform.localPosition = Vector3.zero
		self.draw_obj.root.transform.localRotation = Quaternion.identity

		--镰刀角色，休闲动画特殊处理
		if prof == 2 then
			self.draw_obj:GetPart(SceneObjPart.Main):SetBool("idle_n2",true)
		end

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
		wing_res_id = self:UpdateWingResId(data.wing_used_imageid)
		halo_res_id = self:UpdateHaloResId(data.halo_used_imageid)

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

		self.draw_obj:SetLoadComplete(function(part,obj)
			if part == SceneObjPart.Main then
				local colider = obj.gameObject:GetComponentInChildren(typeof(UnityEngine.SkinnedMeshRenderer))
				local gameObject = colider.gameObject
				colider = gameObject:GetComponent(typeof(UnityEngine.CapsuleCollider))
				if colider == nil then
					gameObject:AddComponent(typeof(UnityEngine.CapsuleCollider))
				end
				TipsCtrl.Instance:CloseLoadingTips()
			end
			local related_part = self.draw_obj:GetPart(part)
			if nil ~= related_part then
				related_part:SetMaterialIndex(1)
			end
		end)
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

		--腰饰
		if data.yaoshi_used_imageid and data.yaoshi_used_imageid > 0 then
			local part = self.draw_obj:GetPart(SceneObjPart.Waist)
			local waist_res_id = WaistData.Instance:GetResIdByImageId(data.yaoshi_used_imageid)
			part:ChangeModel(ResPath.GetWaistModel(waist_res_id))
		end

		--头饰
		if data.toushi_used_imageid and data.toushi_used_imageid > 0 then
			local part = self.draw_obj:GetPart(SceneObjPart.TouShi)
			local toushi_res_id = TouShiData.Instance:GetResIdByImageId(data.toushi_used_imageid)
			part:ChangeModel(ResPath.GetTouShiModel(toushi_res_id))
		end

		--麒麟臂
		if data.qilinbi_used_imageid and data.qilinbi_used_imageid > 0 then
			local part = self.draw_obj:GetPart(SceneObjPart.QilinBi)
			local qilinbi_res_id = QilinBiData.Instance:GetResIdByImageId(data.qilinbi_used_imageid, sex)
			part:ChangeModel(ResPath.GetQilinBiModel(qilinbi_res_id, sex))
		end

		--面饰
		if data.mask_used_imageid and data.mask_used_imageid > 0 then
			local part = self.draw_obj:GetPart(SceneObjPart.Mask)
			local mask_res_id = MaskData.Instance:GetResIdByImageId(data.mask_used_imageid, sex)
			part:ChangeModel(ResPath.GetMaskModel(mask_res_id, sex))
		end
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


---------------------------------
-- 选择多人角色Item
---------------------------------
SelectRoleItem = SelectRoleItem or BaseClass(BaseCell)

function SelectRoleItem:__init()
	self.label_name = self:FindVariable("Name")
	self.label_level = self:FindVariable("Level")
	self.label_bg = self:FindVariable("Bg")
	self.label_head_img = self:FindVariable("HeadImg")
	self.is_create_role = self:FindVariable("IsCreateRole")

	-- 这里调用的是basecell里面的回调函数
	self:ListenEvent("OnClickItem", BindTool.Bind(self.OnClick, self))
end

function SelectRoleItem:OnFlush()
	local bundle, asset = ""
	local level_str = ""
	local label_name = ""
	if nil == self.data or self.data.role_id <= 0 then
		self.is_create_role:SetValue(true)
		level_str = ""
		label_name = ""
	else
		self.is_create_role:SetValue(false)
		level_str = PlayerData.GetLevelString(self.data.level)
		label_name = self.data.role_name
		bundle, asset = ResPath.GetRoleHeadBig(self.data.prof, self.data.sex)
	end
	self.label_head_img:SetAsset(bundle, asset)
	self.label_name:SetValue(label_name)
	self.label_level:SetValue(level_str)
end
