-- 异步加载器
AsyncLoader = AsyncLoader or BaseClass()

local SceneObjLayer = GameObject.Find("GameRoot/SceneObjLayer").transform

function AsyncLoader:__init(parent_transform, off_y)
	self.parent_transform = parent_transform or SceneObjLayer
	self.game_obj = nil
	self.is_active = true
	self.off_y = off_y

	self.local_pos_v3 = nil
	self.local_scale_v3 = nil
	self.local_rotation_euler = nil

	self.is_loading = false
	self.bundle_name = ""
	self.prefab_name = ""
	self.load_callback = nil
	self.is_use_objpool = false
end

function AsyncLoader:__delete()
	self.parent_transform = nil
	self:Destroy()

	self.bundle_name = ""
	self.prefab_name = ""
	self.load_callback = nil
end

function AsyncLoader:SetIsUseObjPool(is_use_objpool)
	self.is_use_objpool = is_use_objpool
end

function AsyncLoader:SetParent(parent_transform)
	self.parent_transform = parent_transform
end

function AsyncLoader:SetScale(scale)
	self.scale = scale
	if self.game_obj ~= nil then
		self.game_obj.transform.localScale = Vector3(scale[1], scale[2], scale[3])
	end
end

function AsyncLoader:SetLocalPosition(local_pos_v3)
	self.local_pos_v3 = local_pos_v3

	if self.game_obj ~= nil then
		self.game_obj.transform.localPosition = self.local_pos_v3
	end
end

function AsyncLoader:SetPosition(pos_v3)
	self.pos_v3 = pos_v3

	if self.game_obj ~= nil then
		self.game_obj.transform.position = self.pos_v3
	end
end

function AsyncLoader:SetLocalScale(local_scale_v3)
	self.local_scale_v3 = local_scale_v3

	if self.game_obj ~= nil then
		self.game_obj.transform.localScale = local_scale_v3
	end
end

function AsyncLoader:SetLocalRotation(local_rotation_euler)
	self.local_rotation_euler = local_rotation_euler

	if self.game_obj ~= nil then
		self.game_obj.transform.localRotation = local_rotation_euler
	end
end

function AsyncLoader:Load(bundle_name, prefab_name, load_callback)
	if nil == load_callback and self.bundle_name == bundle_name and self.prefab_name == prefab_name then
		return
	end
	self.load_callback = load_callback
	self.bundle_name = bundle_name
	self.prefab_name = prefab_name

	if not self.is_loading then
		self:LoadHelper()
	end
end

function AsyncLoader:SetActive(active)
	if self.is_active ~= active then
		self.is_active = active
		if nil ~= self.game_obj then
			self.game_obj:SetActive(active)
		end
	end
end

function AsyncLoader:Destroy()
	if nil ~= self.game_obj then
		self:DestoryObj(self.game_obj)
		self.game_obj = nil
	end
end

function AsyncLoader:DestoryObj(obj)
	if not IsNil(obj) then
		if self.is_use_objpool then
			GameObjectPool.Instance:Free(obj)
		else
			GameObject.Destroy(obj)
		end
	end
end

function AsyncLoader:LoadHelper()
	if self.bundle_name == "" or self.prefab_name == "" then
		return
	end

	self:Destroy()

	self.is_loading = true

	if self.is_use_objpool then
		GameObjectPool.Instance:SpawnAssetWithQueue(
			self.bundle_name,
			self.prefab_name,
			InstantiateQueue.Global,
			0,
			BindTool.Bind(self.LoadComplete, self, self.bundle_name, self.prefab_name))
	else
		QueueLoader.Instance:LoadPrefab(
				self.bundle_name,
				self.prefab_name,
				BindTool.Bind(self.LoadComplete, self, self.bundle_name, self.prefab_name))
	end
end

function AsyncLoader:LoadComplete(bundle_name, prefab_name, obj)
	if IsNil(obj) then
		return
	end

	if nil == self.parent_transform then
		self:DestoryObj(obj)
		return
	end

	if self.bundle_name ~= bundle_name or self.prefab_name ~= prefab_name then
		self:DestoryObj(obj)
		self:LoadHelper()
		return
	end

	self.is_loading = false

	self.game_obj = obj
	obj.transform:SetParent(self.parent_transform, false)

	if self.local_pos_v3 then
		obj.transform.localPosition = self.local_pos_v3
	end

	if self.off_y then
		local pos = obj.transform.localPosition
		obj.transform:SetLocalPosition(pos.x, self.off_y, pos.y)
	end

	if nil ~= self.local_scale_v3 then
		obj.transform.localScale = self.local_scale_v3
	end

	if self.scale then
		obj.transform.localScale = Vector3(self.scale[1], self.scale[2], self.scale[3])
	end

	if nil ~= self.local_rotation_euler then
		self.game_obj.transform.localRotation = self.local_rotation_euler
	end

	self.game_obj:SetActive(self.is_active)

	if nil ~= self.load_callback then
		self.load_callback(obj)
	end
	local lock_rotation = obj:GetComponent(typeof(LockRotation))
	if lock_rotation and self.parent_transform ~= nil then
		local off_y = DownAngleOfCamera or 0
		lock_rotation:SetOffY(off_y - 180)
		lock_rotation:SetParentTransform(self.parent_transform)
	end
end
