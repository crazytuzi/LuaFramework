Tower = Tower or BaseClass(Monster)

local FireProress = 0.5				--着火百分比

function Tower:__init(vo)
	Monster.__init(self, vo)
	self.attack_cache = 0
end

function Tower:__delete()
	Monster.__delete(self)
	if self.tower_fire_obj then
		GameObjectPool.Instance:Free(self.tower_fire_obj)
		self.tower_fire_obj = nil
	end
	self.tower_quan_obj = nil
end

function Tower:Update(now_time, elapse_time)
	Character.Update(self, now_time, elapse_time)

	if Scene.Instance:GetSceneType() == SceneType.ClashTerritory then
		if not self.tower_quan_obj then
			return
		end

		local main_role = Scene.Instance:GetMainRole()
		local pos_x, pos_y = main_role:GetLogicPos()
		local main_role_side = ClashTerritoryData.Instance:GetMainRoleTerritoryWarSide()
		local tower_side = ClashTerritoryData.Instance:GetTerritoryMonsterSide(self.vo.monster_id)

		if tower_side ~= main_role_side then
			local delta_pos = u3d.vec2(pos_x - self.vo.pos_x, pos_y - self.vo.pos_y)
			local temp_distance = u3d.v2Length(delta_pos)
			if temp_distance <= 30 then
				self.tower_quan_obj:SetActive(true)
			else
				self.tower_quan_obj:SetActive(false)
			end
		else
			self.tower_quan_obj:SetActive(false)
		end
	end
end

function Tower:GetTowerEffectObj()
	local draw_tower = self.draw_obj:GetPart(SceneObjPart.Main)
	local tower_obj = draw_tower:GetObj()
	if not tower_obj then
		return
	end
	local count = tower_obj.transform.childCount
	for i = 0, count - 1 do
		local obj = tower_obj.transform:GetChild(i).gameObject
		if string.find(obj.name, "Quan") then
			self.tower_quan_obj = obj
			self.tower_quan_obj:SetActive(false)
		end
	end
end

function Tower:OnModelLoaded(part, obj)
	SceneObj.OnModelLoaded(self, part, obj)
	if Scene.Instance:GetSceneType() == SceneType.ClashTerritory then
		self:GetTowerEffectObj()
		local proess = self.vo.hp / self.vo.max_hp
		if proess < FireProress then
			self:ChangeFireEffect(true)
		else
			self:ChangeFireEffect(false)
		end
	end
end

function Tower:EnterStateDead()
	Character.EnterStateDead(self)
	if self.tower_quan_obj then
		self.tower_quan_obj:SetActive(false)
	end
end

function Tower:InitInfo()
	Monster.InitInfo(self)
end

function Tower:ChangeFireEffect(enable)
	if not self.tower_fire_obj then
		local bundle, asset = ResPath.GetEffectBoss("2038001_ransao")
		GameObjectPool.Instance:SpawnAsset(bundle, asset, function(obj)
			if not obj then return end
			if not self.draw_obj then
				GameObjectPool.Instance:Free(obj)
				return
			end
			local parent_transform = self.draw_obj:GetAttachPoint(AttachPoint.BuffBottom)
			if not parent_transform then
				GameObjectPool.Instance:Free(obj)
				return
			end

			obj.transform:SetParent(parent_transform, false)
			self.tower_fire_obj = obj
			self.tower_fire_obj:SetActive(enable)
		end)
	else
		self.tower_fire_obj:SetActive(enable)
	end
end

function Tower:SyncShowHp()
	Character.SyncShowHp(self)
	if Scene.Instance:GetSceneType() == SceneType.ClashTerritory then
		local proess = self.vo.hp / self.vo.max_hp
		if proess < FireProress then
			self:ChangeFireEffect(true)
		else
			self:ChangeFireEffect(false)
		end
	end
end

function Tower:DoAttack(...)
	if self:IsAtk() then
		self.attack_cache = self.attack_cache + 1
	end
	Character.DoAttack(self, ...)
end

function Tower:OnAnimatorEnd()
	if self.attack_cache > 0 then
		self.attack_cache = self.attack_cache - 1
		return
	end
	Character.OnAnimatorEnd(self)
end