UIScene = {
	is_loading = false,
	scene_asset = nil,
	pre_scene_asset = nil,
	pre_root_name = nil,
	change_scene_id = nil,
	def_root_name = "ActorPoint",
	root_name = "ActorPoint",
	role_model = nil,
	res_info = nil,
	is_play_action = false,
	rotate_cache = nil,
	def_name_list = {
		{"ActorPoint", false}
	},
	name_list = {}, 			--{[1] = {"父节点名字", 是否非人物模型, ...}}
	model_list = {}, 			--{["父节点名字"] = {model = RoleModel, res_info = {}}
	scene_target = nil,
	def_actor_child = "ActorPointChild"
}

--清除
function UIScene:DeleteMe()
	self:DeleteModels()
	self.bundle_list = {}
	self.asset_list = {}
end
function UIScene:DeleteModels()
	self.role_model = nil
	for k,v in pairs(self.model_list) do
		v.model:DeleteMe()
	end
	self.model_list = {}
	if self.apperance_change then
		GlobalEventSystem:UnBind(self.apperance_change)
		self.apperance_change = nil
	end
end

function UIScene:ChangeScene(view, scene_asset, name_list, call_back)
	if view and not view:IsRendering() then
		return
	end
	for k,v in pairs(self.name_list) do
		self:RemoveDelayTime(k)
	end
	self.name_list = name_list or TableCopy(self.def_name_list)

	if self.load_call_back then
		self.load_call_back()
	end

	self.load_call_back = call_back
	self.pre_scene_asset = nil
	self.pre_view = nil
	if self.is_loading then
		if ((scene_asset == nil or self.scene_asset == nil) and scene_asset ~= self.scene_asset)
			or (scene_asset and self.scene_asset and (scene_asset[1] ~= self.scene_asset[1] or scene_asset[2] ~= self.scene_asset[2])) then
			if scene_asset then
				self.pre_scene_asset = scene_asset
				self.pre_view = view
			else
				self.pre_scene_asset = "nil"
			end
			self.pre_name_list = name_list
		end
		return
	end
	if scene_asset and self.scene_asset and self.scene_asset[1] == scene_asset[1] and self.scene_asset[2] == scene_asset[2] then
		self:DeleteModels()
		self:CreateModel()
		if self.load_call_back then
			self.load_call_back()
			self.load_call_back = nil
		end
		if nil ~= self.load_success_call_back then
			self.load_success_call_back()
			self.load_success_call_back = nil
		end
	else
		if self.scene_asset ~= nil then
			UnityEngine.SceneManagement.SceneManager.UnloadSceneAsync(self.scene_asset[2].."_Main")
			UnityEngine.SceneManagement.SceneManager.UnloadSceneAsync(self.scene_asset[2].."_Detail")
			self:DeleteMe()
		end
		self.scene_asset = scene_asset

		if self.scene_asset ~= nil then
			self.scene_name = scene_asset[2]
			self.is_loading = true
			local request_id = LoadingPriorityManager.Instance:RequestPriority(
				LoadingPriority.High)
			AssetManager.LoadLevelSync(
				scene_asset[1].."_main",
				scene_asset[2].."_Main",
				UnityEngine.SceneManagement.LoadSceneMode.Additive,
				function()
					GlobalEventSystem:Fire(
						SceneEventType.UI_SCENE_LOADING_STATE_QUIT,
						scene_asset)
					AssetManager.LoadLevel(
						scene_asset[1].."_detail",
						scene_asset[2].."_Detail",
						UnityEngine.SceneManagement.LoadSceneMode.Additive,
						function()
							LoadingPriorityManager.Instance:CancelRequest(request_id)
							self:OnLoadSceneComplete(scene_asset)
							if nil ~= self.load_success_call_back then
								self.load_success_call_back()
								self.load_success_call_back = nil
							end
						end)
				end)
		end
	end
end

function UIScene:SetUISceneLoadCallBack(call_back)
	self.load_success_call_back = call_back
end

function UIScene:SetModelLoadCallBack(call_back, index)
	index = index or 1
	local name_info = self.name_list[index]
	if name_info == nil then return end
	name_info.model_load_call_back = call_back
end

function UIScene:OnLoadSceneComplete(scene_asset)
	self.is_loading = false
	if self.pre_scene_asset then
		if "nil" == self.pre_scene_asset then
			self:ChangeScene()
		else
			self:ChangeScene(self.pre_view, self.pre_scene_asset, self.pre_name_list, self.load_call_back)
		end
		return
	end
	local scene = UnityEngine.SceneManagement.SceneManager.GetSceneByName(self.scene_name.."_Detail")
	local objects = UnityEngine.SceneManagement.Scene.GetRootGameObjects(scene)
	for k,v in pairs(self.name_list) do
		v.root_obj = objects[0]
		for k1,v1 in pairs(objects:ToTable()) do
			if v1.name == v[1] then
				v.root_obj = v1
			end
		end
		local point_path = "ActorPoint/ActorPointChild"
		if v[3] then
			point_path = "ActorPoint"..v[3].."/ActorPointChild"
		end
		local child_point = v.root_obj.transform:FindHard(point_path)
		if child_point then
			v.root_obj = child_point
		end
	end
	self:CreateModel()
	if self.load_call_back then
		self.load_call_back()
		self.load_call_back  = nil
	end
end

function UIScene:SetSceneCameraTransform()
	local scene = UnityEngine.SceneManagement.SceneManager.GetSceneByName(self.scene_name.."_Main")
	local objects = UnityEngine.SceneManagement.Scene.GetRootGameObjects(scene)

end

function UIScene:CanShowPingtai(name)
	for k,v in pairs(self.name_list) do
		if v[1] == name then
			return true
		end
	end
	return false
end

function UIScene:GetPingTaiPosition(name)
	for k,v in pairs(self.name_list) do
		if v[1] == name and v.position then
			return v.position
		end
	end
	return nil
end

function UIScene:SetPingTaiActive()
	local scene = UnityEngine.SceneManagement.SceneManager.GetSceneByName(self.scene_name.."_Detail")
	local objects = UnityEngine.SceneManagement.Scene.GetRootGameObjects(scene)
	for k,v in pairs(objects:ToTable()) do
		for i = 1, 6 do
			if v.name == ("Pingtai0" .. i) then
				if self:GetPingTaiPosition(v.name) then
					v.transform.localPosition = self:GetPingTaiPosition(v.name)
				end
				v:SetActive(self:CanShowPingtai(v.name))
			end
		end
	end
end

function UIScene:SetPingTaiPosition(index, pos)
	local scene = UnityEngine.SceneManagement.SceneManager.GetSceneByName(self.scene_name.."_Detail")
	local objects = UnityEngine.SceneManagement.Scene.GetRootGameObjects(scene)
	for k,v in pairs(objects:ToTable()) do
		if v.name == ("Pingtai0" .. index) then
			v.transform.localPosition = pos
		end
	end
end

function UIScene:CreateModel()
	self:SetPingTaiActive()
	for i,v in ipairs(self.name_list) do
		v[1] = v[1] or self.def_root_name
		v[2] = v[2] ~= nil and v[2]
		local model_info = self.model_list[v[3] or v[1]]
		if model_info and (model_info.res_info ~= nil or v.res_info ~= nil or v[2] == false) then
			model_info.model:DeleteMe()
			model_info.model = nil
		elseif model_info == nil then
			model_info = {}
			self.model_list[v[3] or v[1]] = model_info
		end
		model_info.pint_tai = v[1]
		if not v[2] then
			if nil == model_info.model then
				model_info.model = RoleModel.New()
				self:CreateRoleModel(i)
			end
		else
			if nil == model_info.model then
				model_info.model = RoleModel.New()
			end
			self:SetModelAsset(i)
		end
		self.role_model = model_info.model
	end
end

--删除模型
function UIScene:DeleteModel(index)
	index = index or 1
	local name_info = self.name_list[index]
	if name_info == nil or nil == self.model_list[name_info[3] or name_info[1]] then
	 	return
	end

	local model_info = self.model_list[name_info[3] or name_info[1]]
	for k, v in pairs(SceneObjPart) do
		local part = model_info.model.draw_obj:GetPart(v)
		if part then
			part:RemoveModel()
		end
	end
end

function UIScene:SetModelAsset(index)
	index = index or 1
	local name_info = self.name_list[index]
	if name_info == nil then return end
	local model_info = self.model_list[name_info[3] or name_info[1]]
	if nil == model_info then return end

	if name_info.res_info then
		model_info.model:SetLoadComplete(BindTool.Bind(self._OnModelLoaded, self, index))

		if name_info.res_info.is_goddess then
			model_info.model:SetGoddessModelResInfo(name_info.res_info)
		else
			local res_info_t = name_info.res_info_t or {}
			model_info.model:SetModelResInfo(name_info.res_info, res_info_t.ignore_find, res_info_t.ignore_wing, res_info_t.ignore_halo, res_info_t.ignore_weapon)
		end
		name_info.res_info = nil
		
	elseif next(name_info.bundle_list or {}) and next(name_info.asset_list or {}) then
		for k, v in pairs(SceneObjPart) do
			local part = model_info.model.draw_obj:GetPart(v)
			if part then
				part:RemoveModel()
			end
		end

		model_info.model:SetLoadComplete(BindTool.Bind(self._OnModelLoaded, self, index))
		model_info.model:SetMainAsset(name_info.bundle_list[SceneObjPart.Main], name_info.asset_list[SceneObjPart.Main])

		if name_info.bundle_list[SceneObjPart.Weapon] then
			model_info.model:SetGoddessAsset(name_info.bundle_list[SceneObjPart.Weapon], name_info.asset_list[SceneObjPart.Weapon])
		end
		if name_info.bundle_list[SceneObjPart.Wing] then
			model_info.model:SetWingAsset(name_info.bundle_list[SceneObjPart.Wing], name_info.asset_list[SceneObjPart.Wing])
		end

		if name_info.bundle_list[SceneObjPart.Halo] then
			local part = model_info.model.draw_obj:GetPart(SceneObjPart.Halo)
			part:ChangeModel(name_info.bundle_list[SceneObjPart.Halo], name_info.asset_list[SceneObjPart.Halo])
		end
		
		self.bundle_list = {}
		self.asset_list = {}
	end
end

function UIScene:CreateRoleModel(index)
	index = index or 1
	local name_info = self.name_list[index]
	if name_info == nil then return end
	local model_info = self.model_list[name_info[1]]
	if nil == model_info then return end
	model_info.res_info = name_info.res_info
	local main_role = Scene.Instance:GetMainRole()

	model_info.model:SetIsUseObjPool(true)
	model_info.model:SetLoadComplete(BindTool.Bind(self._OnModelLoaded, self, index))

	if name_info.res_info then
		if name_info.res_info.is_goddess then
			model_info.model:SetGoddessModelResInfo(name_info.res_info)
		else
			local res_info_t = name_info.res_info_t or {}
			model_info.model:SetModelResInfo(name_info.res_info, res_info_t.ignore_find, res_info_t.ignore_wing, res_info_t.ignore_halo, res_info_t.ignore_weapon)
		end
		name_info.res_info = nil
	else
		model_info.model:SetModelResInfo(GameVoManager.Instance:GetMainRoleVo())
		--在光环, 羽翼界面的时候不监听形象改变
		local advance_show_index = AdvanceCtrl.Instance.advance_view:GetShowIndex()
		if self.apperance_change == nil and advance_show_index ~= TabIndex.wing_jinjie and advance_show_index ~= TabIndex.halo_jinjie then
			self.apperance_change = GlobalEventSystem:Bind(
			ObjectEventType.MAIN_ROLE_APPERANCE_CHANGE,
			BindTool.Bind(self.MainRoleApperanceChange, self))
		end
	end
	-- model_info.model:SetLoadComplete(BindTool.Bind(self._OnModelLoaded, self, index))
	model_info.model.draw_obj.root.transform.rotation = Quaternion.identity
	self:SetRoleFightState(part, index)
end

function UIScene:MainRoleApperanceChange()
	local need_event = false
	local model_info = nil
	for k,v in pairs(self.name_list) do
		model_info = self.model_list[v[3] or v[1]]
		if model_info and v[2] == false and model_info.res_info == nil and v.res_info == nil then
			model_info.model:SetModelResInfo(GameVoManager.Instance:GetMainRoleVo())
			need_event = true
		end
	end
	if not need_event and self.apperance_change then
		GlobalEventSystem:UnBind(self.apperance_change)
		self.apperance_change = nil
	end
end

function UIScene:GetNameInfoRootObj(name_info)
	local scene = UnityEngine.SceneManagement.SceneManager.GetSceneByName(self.scene_name.."_Detail")
	local objects = UnityEngine.SceneManagement.Scene.GetRootGameObjects(scene)
	name_info.root_obj = objects[0]
	for k,v in pairs(objects:ToTable()) do
		if v.name == name_info[1] then
			name_info.root_obj = v
		end
	end
	local point_path = "ActorPoint/ActorPointChild"
	if name_info[3] then
		point_path = "ActorPoint"..name_info[3].."/ActorPointChild"
	end
	local child_point = name_info.root_obj.transform:FindHard(point_path)
	if child_point then
		name_info.root_obj = child_point
	end
end

function UIScene:_OnModelLoaded(index, part, obj)
	index = index or 1
	local name_info = self.name_list[index]
	if nil == name_info then return end
	local model_info = self.model_list[name_info[3] or name_info[1]]
	if nil == model_info then return end
	if name_info.rotate_cache then
		model_info.model.draw_obj.root.transform.rotation = Quaternion.identity
		model_info.model:Rotate(name_info.rotate_cache.x, name_info.rotate_cache.y, name_info.rotate_cache.z)
		self.rotate_cache = nil
	end

	if name_info.rotation_cache then
		model_info.model.draw_obj.root.transform.localRotation = Quaternion.Euler(name_info.rotation_cache.x, name_info.rotation_cache.y, name_info.rotation_cache.z)
	end

	if name_info.model_load_call_back then
		name_info.model_load_call_back(model_info.model, model_info.model.draw_obj.root)
		name_info.model_load_call_back = nil
	end
	if part == SceneObjPart.BaoJu then
		obj.gameObject:SetLayerRecursively(13)
	end
	if part ~= SceneObjPart.Main then return end
	part = model_info.model.draw_obj:GetPart(SceneObjPart.Main)
	if name_info.root_obj == nil then
		local scene = UnityEngine.SceneManagement.SceneManager.GetSceneByName(self.scene_name.."_Detail")
		local objects = UnityEngine.SceneManagement.Scene.GetRootGameObjects(scene)
		name_info.root_obj = objects[0]
		for k,v in pairs(objects:ToTable()) do
			if v.name == name_info[1] then
				name_info.root_obj = v
			end
		end
		local point_path = "ActorPoint/ActorPointChild"
		if name_info[3] then
			point_path = "ActorPoint"..name_info[3].."/ActorPointChild"
		end
		local child_point = name_info.root_obj.transform:FindHard(point_path)
		if child_point then
			name_info.root_obj = child_point
		end
	end

	part:SetGameLayer(UnityEngine.LayerMask.NameToLayer("UIScene"))
	-- part:SetTrigger("rest")
	obj.gameObject:SetLayerRecursively(name_info.root_obj.gameObject.layer)
	model_info.model.draw_obj:GetRoot().transform:SetParent(name_info.root_obj.transform, false)
	model_info.model.draw_obj:GetRoot().gameObject:SetLayerRecursively(name_info.root_obj.gameObject.layer)
	if self.name_list[index].fight_enable then
		part:SetBool("fight", true)
	end
	self:SetRoleAnimation(part, index)
end

function UIScene:ResetLocalPostion()
	for k,v in pairs(self.model_list) do
		local obj = v.model.draw_obj.root
		obj.transform.localPosition = Vector3(0, 0, 0)
		obj.transform.localRotation = Quaternion.Euler(0, 0, 0)
		obj.transform.localScale = Vector3(1, 1, 1)
	end
end

function UIScene:SetRoleAnimation(part_obj, index)
	local name_info = self.name_list[index]
	if nil == name_info then return end
	local model_info = self.model_list[name_info[1]]
	if nil == model_info then return end
	part_obj = part_obj or model_info.model.draw_obj:GetPart(SceneObjPart.Main)
	if not part_obj or not self.name_list[index].fight_enable then return end
	local animator = part_obj:GetObj() and part_obj:GetObj().animator
	if name_info.tiggers then
		for k, v in pairs(name_info.tiggers) do
			part_obj:SetTrigger(v)
		end
	end
	name_info.tiggers = {}
	name_info.attack_hit_handle = name_info.attack_hit_handle or {}
	name_info.attack_begin_handle = name_info.attack_begin_handle or {}
	if animator and name_info.action_names then
		for k, v in pairs(name_info.action_names) do
			if name_info.attack_hit_handle[v] then
				name_info.attack_hit_handle[v]:Dispose()
				name_info.attack_hit_handle[v] = nil
			end
			if name_info.attack_begin_handle[v] then
				name_info.attack_begin_handle[v]:Dispose()
				name_info.attack_begin_handle[v] = nil
			end
			name_info.attack_begin_handle[v] = animator:ListenEvent(
				v.."/begin", BindTool.Bind(self.OnAnimatorBegin, self, part_obj, v, name_info.attack_begin_handle))
			name_info.attack_hit_handle[v] = animator:ListenEvent(
				v.."/hit", BindTool.Bind(self.OnAnimatorHit, self, part_obj, v, name_info.attack_hit_handle))
		end
	end
end

function UIScene:OnAnimatorBegin(part_obj, skill_action, attack_begin_handle)
	local actor_ctrl = part_obj:GetObj() and part_obj:GetObj().actor_ctrl
	if actor_ctrl then
		local name_info = self.name_list[1]
		if not name_info.scene_target then
			name_info.scene_target = U3DObject(GameObject.New())
		end
		-- local target_go = U3DObject(GameObject.New())
		local target_transform = name_info.scene_target.transform
		part_obj:GetObj().actor_ctrl.Target = target_transform
		target_transform:SetParent(part_obj:GetObj().transform, false)
		target_transform.localPosition = part_obj:GetObj().transform.localPosition + Vector3(-0.23, 0, 4.57)
		-- actor_ctrl:PlayProjectile(skill_action, target_transform, target_transform, function ()
		-- 	--GameObject.Destroy(target_go.gameObject)
		-- end)
	end

	if attack_begin_handle[skill_action] then
		attack_begin_handle[skill_action]:Dispose()
		attack_begin_handle[skill_action] = nil
	end
	-- self.action_names[skill_action] = nil
end

function UIScene:OnAnimatorHit(part_obj, skill_action, attack_hit_handle)
	local actor_ctrl = part_obj:GetObj() and part_obj:GetObj().actor_ctrl
	if actor_ctrl then
		local name_info = self.name_list[1]
		if not name_info.scene_target then
			name_info.scene_target = U3DObject(GameObject.New())
		end
		-- local target_go = U3DObject(GameObject.New())
		local target_transform = name_info.scene_target.transform
		target_transform:SetParent(part_obj:GetObj().transform, false)
		target_transform.localPosition = part_obj:GetObj().transform.localPosition + Vector3(-0.23, 0, 4.57)
		actor_ctrl:PlayProjectile(skill_action, target_transform, target_transform, function ()
		end)
	end

	if attack_hit_handle[skill_action] then
		attack_hit_handle[skill_action]:Dispose()
		attack_hit_handle[skill_action] = nil
	end
	-- self.action_names[skill_action] = nil
end

function UIScene:SetRoleFightState(part_obj, index)
	index = index or 1
	if self.name_list[index] == nil then return end
	if not part_obj then return end
	part_obj:SetBool("fight", self.name_list[index].fight_enable or false)
end

function UIScene:SetFightBool(fight_enable, index)
	index = index or 1
	if self.name_list[index] == nil then return end
	self.name_list[index].fight_enable = fight_enable or false
	local model_info = self.model_list[self.name_list[index][1]]
	if model_info then
		local part = model_info.model.draw_obj:GetPart(SceneObjPart.Main)
		if part then
			part:SetBool("fight", fight_enable)
		end
	end
end

function UIScene:SetAnimation(action_name, index)
	index = index or 1
	local name_info = self.name_list[index]
	if nil == name_info then return end
	name_info.action_names = name_info.action_names or {}
	name_info.action_names[action_name] = action_name
	if not self.is_loading then
		self:SetRoleAnimation(nil, index)
	end
end

function UIScene:SetTriggerValue(tigger, index)
	index = index or 1
	local name_info = self.name_list[index]
	if nil == name_info then return end
	name_info.tiggers = name_info.tiggers or {}
	name_info.tiggers[tigger] = tigger
end

function UIScene:SetRoleModelResInfo(info, index, ignore_find, ignore_wing, ignore_halo, ignore_weapon)
	index = index or 1
	if self.name_list[index] == nil then return end
	local model_info = self.model_list[self.name_list[index][3] or self.name_list[index][1]]
	if model_info then
		model_info.model:SetLoadComplete(BindTool.Bind(self._OnModelLoaded, self, index))
		model_info.model:SetModelResInfo(info, ignore_find, ignore_wing, ignore_halo, ignore_weapon)
	else
		self.name_list[index].res_info = info
		self.name_list[index].res_info_t = {ignore_find = ignore_find, ignore_wing = ignore_wing, ignore_halo = ignore_halo, ignore_weapon = ignore_weapon}
	end
end

function UIScene:SetGoddessModelResInfo(info, index)
	index = index or 1
	if self.name_list[index] == nil then return end
	local model_info = self.model_list[self.name_list[index][3] or self.name_list[index][1]]
	if model_info then
		model_info.model:SetLoadComplete(BindTool.Bind(self._OnModelLoaded, self, index))
		model_info.model:SetGoddessModelResInfo(info)
	else
		self.name_list[index].res_info = info
	end
end

function UIScene:ResetRotate(index)
	index = index or 1
	local name_info = self.name_list[index]
	if nil == name_info then return end
	local model_info = self.model_list[name_info[1]]
	if model_info then
		model_info.model.draw_obj.root.transform.localRotation = Quaternion.identity
	end
	name_info.rotate_cache = nil
end

function UIScene:Rotate(x, y, z, index)
	index = index or 1
	local name_info = self.name_list[index]
	if nil == name_info then return end
	local model_info = self.model_list[name_info[3] or name_info[1]]
	if model_info then
		model_info.model:Rotate(x, y, z)
	else
		name_info.rotate_cache = {x = x, y = y, z = z}
	end
end

-- 设置模型的旋转
function UIScene:SetLocalRotation(x, y, z, index)
	index = index or 1
	local name_info = self.name_list[index]
	if nil == name_info then return end
	local model_info = self.model_list[name_info[3] or name_info[1]]
	if model_info then
		model_info.model.draw_obj.root.localRotation = Quaternion.Euler(x, y, z)
	else
		name_info.rotation_cache = {x = x, y = y, z = z}
	end
end

function UIScene:IsNotCreateRoleModel(is_not_create_role, index)
	index = index or 1
	local name_info = self.name_list[index]
	if name_info == nil then return end
	name_info[2] = is_not_create_role or false
end

function UIScene:ModelBundle(bundle_list, asset_list, index)
	index = index or 1
	if self.name_list[index] == nil  then return end
	self.name_list[index].bundle_list = bundle_list or {}
	self.name_list[index].asset_list = asset_list or {}
	if not self.is_loading then
		UIScene:SetModelAsset(index)
	end
end

function UIScene:SetActionEnable(switch, index)
	index = index or 1
	local name_info = self.name_list[index]
	if nil == name_info then return end
	if switch then
		if not name_info.is_play_action then
			self:RemoveDelayTime(index)
			name_info.delay_time = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.PlayAction, self, index), 2)
		end
	else
		self:RemoveDelayTime(index)
		name_info.is_play_action = false
		local name_info = self.name_list[index]
		if nil == name_info then return end
		local model_info = self.model_list[name_info[1]]
		if model_info then
			local part = model_info.model.draw_obj:GetPart(SceneObjPart.Main)
			part:SetBool("fight", false)
		end
	end
end

function UIScene:PlayAction(index)
	index = index or 1
	local name_info = self.name_list[index]
	if nil == name_info then return end
	local model_info = self.model_list[name_info[1]]
	if model_info and not self.is_play_action then
		local part = model_info.model.draw_obj:GetPart(SceneObjPart.Main)
		part:SetBool("fight", true)
		name_info.delay_time = GlobalTimerQuest:AddDelayTimer(function()
			name_info.is_play_action = true
			part:EnableEffect(false)
			part:SetTrigger("combo1_1") part:SetTrigger("combo1_2") part:SetTrigger("combo1_3")
			name_info.delay_time = GlobalTimerQuest:AddDelayTimer(function()
				part:EnableEffect(true)
				part:SetBool("fight", false)
				name_info.is_play_action = false
				name_info.delay_time2 = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.PlayAction,self), 5)
				 end ,3)
		  end, 0.5)
	end
end

function UIScene:RemoveDelayTime(index)
	index = index or 1
	local name_info = self.name_list[index]
	if nil == name_info then return end
	if name_info.delay_time then
		GlobalTimerQuest:CancelQuest(name_info.delay_time)
		name_info.delay_time = nil
	end
	if name_info.delay_time2 then
		GlobalTimerQuest:CancelQuest(name_info.delay_time2)
		name_info.delay_time2 = nil
	end
end

function UIScene:MovePingTai(index, target_pos, is_tween, move_call_back)
	local name_info = self.name_list[index]
	if nil == name_info.root_obj then
		self:GetNameInfoRootObj(name_info)
	end

	if is_tween then
		self["obj_move_quest_"..index] = GlobalTimerQuest:AddDelayTimer(function()
			local path = {}
			table.insert(path, target_pos)
			local tweener = name_info.root_obj.transform:DOPath(
				path,
				0.5,
				DG.Tweening.PathType.Linear,
				DG.Tweening.PathMode.TopDown2D,
				1,
				nil)
			tweener:SetEase(DG.Tweening.Ease.InQuad)
			tweener:SetLoops(0)
			tweener:OnComplete(move_call_back)
		end, 0)
	else
		name_info.root_obj.transform:SetLocalPosition(target_pos.x, target_pos.y, target_pos.z)
		move_call_back()
	end
end