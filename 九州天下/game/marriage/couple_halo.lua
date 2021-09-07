CoupleHalo = CoupleHalo or BaseClass()

local SceneObjLayer = GameObject.Find("GameRoot/SceneObjLayer").transform

function CoupleHalo:__init(halo_type, obj1, obj2)
	local asset, bundle = ResPath.GetHaloModel(halo_type + 4)
	GameObjectPool.Instance:SpawnAsset(
			asset,
			bundle,
			BindTool.Bind(self.OnModelLoaded, self))
	self.obj_1 = obj1
	self.obj_2 = obj2
end

function CoupleHalo:__delete()
	GlobalTimerQuest:CancelQuest(self.time_quest)
	local game_obj = self.root_node.gameObject
	if game_obj ~= nil then
		GameObjectPool.Instance:Free(game_obj)
	end

	if self.obj_1 then
		self.obj_1:DeleteDrawObj()
		self.obj_1 = nil
	end

	if self.obj_2 then
		self.obj_2:DeleteDrawObj()
		self.obj_2 = nil
	end
end

function CoupleHalo:OnModelLoaded(obj)
	-- obj = GameObject.Instantiate(obj)
	obj.transform.localScale = Vector3(2,2,2)
	obj.transform:SetParent(SceneObjLayer)
	self.root_node = U3DObject(obj)

	self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.Update, self), 0)
end

function CoupleHalo:Update()
	if self.root_node.transform == nil then
		return
	end
	if self.obj_1:IsDeleted() or self.obj_2:IsDeleted() then
		return
	end
	local pos_1 = self.obj_1:GetRoot().transform.position
	local pos_2 = self.obj_2:GetRoot().transform.position
	-- if Vector3.Distance(pos_1, pos_2) > 2 then
	-- 	--超出距离
	-- 	self.root_node.gameObject:SetActive(false)
	-- 	return
	-- end
	-- self.root_node.gameObject:SetActive(true)

	local x = (pos_1.x + pos_2.x)/2
	local z = (pos_1.z + pos_2.z)/2

	self.root_node.transform.position = Vector3(x, pos_1.y + 3, z)
end