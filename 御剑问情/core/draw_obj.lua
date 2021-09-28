require("core/draw_part")

DrawObj = DrawObj or BaseClass()

function DrawObj:__init(parent_obj, parent_transform)
	self.parent_obj = parent_obj

	-- 控制的根节点.
	self.root = U3DObject(GameObject.New())
	self.root.gameObject:AddComponent(typeof(MoveableObject))
	if parent_transform ~= nil then
		self.root.transform:SetParent(parent_transform)
	end

	self.part_list = {}
	self.shield_part_list = {}
	self.auto_fly = false
	self.load_complete = nil
	self.obj_type = 0
	self.scene_obj = nil
	self.budget_vis = true
	self.is_visible = true
	self.is_use_objpool = true
	self.look_at_point = nil
end

function DrawObj:__delete()
	for k,v in pairs(self.part_list) do
		v:DeleteMe()
	end
	self.part_list = {}
	self.shield_part_list = {}

	local game_obj = self.root.gameObject
	GameObject.Destroy(game_obj)

	GlobalTimerQuest:CancelQuest(self.delay_set_attached)

	self.root = nil
	self.parent_obj = nil
	self.scene_obj = nil
	self.look_at_point = nil
end

function DrawObj:GetObjVisible()
	return self.is_visible
end

function DrawObj:IsDeleted()
	return self.root == nil
end

function DrawObj:GetRoot()
	return self.root
end

function DrawObj:SetIsUseObjPool(is_use_objpool)
	self.is_use_objpool = is_use_objpool
end

function DrawObj:SetName(name)
	self.root.gameObject.name = name
end

function DrawObj:SetSceneObj(scene_obj)
	self.scene_obj = scene_obj
end

function DrawObj:GetSceneObj()
	return self.scene_obj
end

function DrawObj:SetOffset(offset)
	self.root.move_obj:SetOffset(offset)
end

function DrawObj:SetPosition(x, y)
	self.root.move_obj:SetPosition(x, 0, y)
	-- 如果有TrailRenderer组件，瞬移过来会出现很长的拖尾，很难看(暂时只处理光环)
	local halo_part = self:_TryGetPartObj(SceneObjPart.Halo)
	if halo_part then
		local trail_renderer_list = halo_part.gameObject:GetComponentsInChildren(typeof(UnityEngine.TrailRenderer))
		for i = 0, trail_renderer_list.Length - 1 do
			local trail_renderer = trail_renderer_list[i]
			if trail_renderer then
				trail_renderer:Clear()
			end
		end
	end
end

function DrawObj:Rotate(x_angle, y_angle, z_angle)
	self.root.transform:Rotate(x_angle, y_angle, z_angle)
end

function DrawObj:GetRootPosition()
	return self.root.transform.position
end

function DrawObj:LookAt(x, y, z)
	local point = Vector3(x, y, z)
	self.root.transform:LookAt(point)
end

function DrawObj:SetDirectionByXY(x, y)
	self.root.move_obj:RotateTo(x, 0, y, 20)
end

function DrawObj:MoveTo(x, y, speed)
	self.root.move_obj:MoveTo(x, 0, y, speed)
end

function DrawObj:SetMoveCallback(callback)
	if nil ~= callback then
		self.root.move_obj:SetMoveCallback(callback)
	end
end

function DrawObj:StopRotate()
	self.root.move_obj:StopRotate()
end

function DrawObj:StopMove()
	self.root.move_obj:StopMove()
end

function DrawObj:SetBudgetVis(visible)
	self.budget_vis = visible
	for k, part in pairs(SceneObjPart) do
		if self.part_list[part] then
			self.part_list[part]:SetVisible(self:GetPartVisible(part))
		end
	end
end

function DrawObj:SetVisible(visible)
	self.is_visible = visible
	for k, part in pairs(SceneObjPart) do
		if self.part_list[part] then
			self.part_list[part]:SetVisible(self:GetPartVisible(part))
		end
	end
end

function DrawObj:GetPart(part)
	if self.part_list[part] == nil then
		self.part_list[part] = self:_CreatePart(part)
	end

	return self.part_list[part]
end

function DrawObj:RemoveModel(part)
	local part_obj = self.part_list[part]
	if part_obj then
		part_obj:RemoveModel()
	end
end

function DrawObj:GetAttachPoint(point)
	local part = self:GetPart(SceneObjPart.Main)
	local point_node = part:GetAttachPoint(point)
	if point_node ~= nil then
		return point_node
	else
		return self.root.transform
	end
end

function DrawObj:GetTransfrom()
	return self.root.transform
end

function DrawObj:GetObjType()
	return self.obj_type
end

function DrawObj:SetObjType(obj_type)
	self.obj_type = obj_type
end

function DrawObj:SetLoadComplete(complete)
	self.load_complete = complete
end

function DrawObj:SetRemoveCallback(callback)
	self.remove_callback = callback
end

function DrawObj:_CreatePart(part)
	local part_obj = DrawPart.New(part)
	part_obj:SetParent(self.root)
	part_obj:SetIsUseObjPool(self.is_use_objpool)
	part_obj:SetMainRole(self.parent_obj.IsMainRole and self.parent_obj:IsMainRole())
	part_obj:SetIsMonster(self.parent_obj.IsMonster and self.parent_obj:IsMonster())
	if self.parent_obj.IsFollowObj and self.parent_obj:IsFollowObj() then
		part_obj:SetMainRole(self.parent_obj:OwnerIsMainRole())
	end
	if part == SceneObjPart.Main then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			obj_class:SetVisible(self:GetPartVisible(part))
			local attachment = obj.actor_attachment
			local attach_skin = obj.attach_skin
			if attachment == nil then
				if self.load_complete ~= nil then
					self.load_complete(part, obj)
				end
				return
			end

			local attach, point = nil, nil
			GlobalTimerQuest:CancelQuest(self.delay_set_attached)
			self.delay_set_attached = GlobalTimerQuest:AddDelayTimer(function ()
				for k, v in pairs(PartAttachPoint) do
					local attach_skin_obj = self:_TryGetPartAttachSkinObj(k)
					if nil ~= attach_skin_obj and nil ~= attach_skin then
						attach_skin_obj.gameObject:SetActive(true)
						attach_skin:AttachMesh(attach_skin_obj.gameObject)
					else
						attach = self:_TryGetPartAttachObj(k)
						if attach ~= nil then
							attach.gameObject:SetActive(true)
							point = attachment:GetAttachPoint(v)
							if nil ~= point and not IsNil(point.gameObject) then
								attach:SetAttached(point)
								attach:SetTransform(attachment.Prof)
							end
						end
					end
				end
			end, 0)

			local wing_obj = self:_TryGetPartAttachObj(SceneObjPart.Wing)
			if wing_obj ~= nil then
				wing_obj.gameObject:SetActive(true)
				point = attachment:GetAttachPoint(AttachPoint.Wing)
				if nil ~= point and not IsNil(point.gameObject) then
					wing_obj:SetAttached(point)
					wing_obj:SetTransform(attachment.Prof)
				end

				if self.auto_fly then
					local main_part = self:GetPart(SceneObjPart.Main)
					main_part:SetLayer(1, 1)
				end
			end

			local cloak_obj = self:_TryGetPartAttachObj(SceneObjPart.Cloak)
			if cloak_obj ~= nil then
				cloak_obj.gameObject:SetActive(true)
				point = attachment:GetAttachPoint(AttachPoint.Wing)
				if nil ~= point and not IsNil(point.gameObject) then
					cloak_obj:SetAttached(point)
					cloak_obj:SetTransform(attachment.Prof)
				end

				if self.auto_fly then
					local main_part = self:GetPart(SceneObjPart.Main)
					main_part:SetLayer(1, 1)
				end
			end

			local mount_obj = self:_TryGetPartObj(SceneObjPart.Mount)
			if mount_obj ~= nil then
				mount_obj.gameObject:SetActive(true)
				attachment:AddMount(mount_obj.gameObject)
				if self.parent_obj.IsRole and self.parent_obj:IsRole() then
					local main_part = self:GetPart(SceneObjPart.Main)
					if self.parent_obj.IsMountLayer2 and self.parent_obj:IsMountLayer2() then
						main_part:SetLayer(ANIMATOR_PARAM.MOUNT_LAYER2, 1)
					else
						main_part:SetLayer(ANIMATOR_PARAM.MOUNT_LAYER2, 0)
					end
				elseif self.parent_obj.IsLingChong and self.parent_obj:IsLingChong() then
					local main_part = self:GetPart(SceneObjPart.Main)
					main_part:SetLayer(LINGCHONG_ANIMATOR_PARAM.MOUNT_LAYER, 1)

					mount_obj.transform.localPosition = Vector3(0, 0, 0)
					mount_obj.transform.localEulerAngles = Vector3(0, 0, 0)

					local vo = self.parent_obj:GetVo()
					local image_info = LingQiData.Instance:GetLingQiImageCfgInfoByImageId(vo.lingqi_used_imageid or 0)
					if image_info then
						local scale = image_info.scale
						if scale then
							mount_obj.transform.localScale = Vector3(scale, scale, scale)
						end
					end
				end
				if mount_obj.attach_obj ~= nil then
					mount_obj.attach_obj:SetTransform(attachment.Prof)
				end
			else
				local fight_mount_obj = self:_TryGetPartObj(SceneObjPart.FightMount)
				if fight_mount_obj ~= nil then
					fight_mount_obj.gameObject:SetActive(true)
					attachment:AddFightMount(fight_mount_obj.gameObject)
					if fight_mount_obj.attach_obj ~= nil then
						fight_mount_obj.attach_obj:SetTransform(attachment.Prof)
					end
				end
			end

			if self.load_complete ~= nil then
				self.load_complete(part, obj)
			end
			self:AddPayload(obj_class, obj_part)
		end, part)
		part_obj:SetRemoveCallback(function(obj)
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				attachment:RemoveMount()
				if self.parent_obj.IsRole and self.parent_obj:IsRole() then
					local main_part = self:GetPart(SceneObjPart.Main)
					main_part:SetLayer(ANIMATOR_PARAM.MOUNT_LAYER2, 0)
				elseif self.parent_obj.IsLingChong and self.parent_obj:IsLingChong() then
					local main_part = self:GetPart(SceneObjPart.Main)
					main_part:SetLayer(LINGCHONG_ANIMATOR_PARAM.MOUNT_LAYER, 0)
				end
			end
			local weapon = self.part_list[SceneObjPart.Weapon]
			if nil ~= weapon then
				if self.weapon_effect then
					GameObject.Destroy(self.weapon_effect)
					self.weapon_effect = nil
				end
				weapon:Reset()
				local obj = weapon:GetObj()
				if obj then
					obj.gameObject:SetActive(false)
				end
			end
			local weapon2 = self.part_list[SceneObjPart.Weapon2]
			if nil ~= weapon2 then
				if self.weapon2_effect then
					GameObject.Destroy(self.weapon2_effect)
					self.weapon2_effect = nil
				end
				weapon2:Reset()
				local obj = weapon2:GetObj()
				if obj then
					obj.gameObject:SetActive(false)
				end
			end
			local wing = self.part_list[SceneObjPart.Wing]
			if nil ~= wing then
				wing:Reset()
			end
			local cloak = self.part_list[SceneObjPart.Cloak]
			if nil ~= cloak then
				cloak:Reset()
			end
			local halo = self.part_list[SceneObjPart.Halo]
			if nil ~= halo then
				halo:Reset()
			end
			local fazhen = self.part_list[SceneObjPart.FaZhen]
			if nil ~= fazhen then
				fazhen:Reset()
			end
			local beauty = self.part_list[SceneObjPart.HoldBeauty]
			if nil ~= beauty then
				beauty:Reset()
			end
			local head = self.part_list[SceneObjPart.Head]
			if nil ~= head then
				head:Reset()
			end

			if self.remove_callback ~= nil then
				self.remove_callback(part, obj)
			end
		end)
	elseif PartAttachPoint[part] ~= nil then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			obj_class:SetVisible(self:GetPartVisible(part))
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			local attach_skin = self:_TryGetPartAttachSkin(SceneObjPart.Main)
			if nil ~= attach_skin and nil ~= obj.attach_skin_obj then
				obj.gameObject:SetActive(true)
				attach_skin:AttachMesh(obj.gameObject)
			else
				if attachment ~= nil then
					obj.gameObject:SetActive(true)
					local point = attachment:GetAttachPoint(PartAttachPoint[part])
					if not IsNil(point) and obj.attach_obj then
						obj.attach_obj:SetAttached(point)
						obj.attach_obj:SetTransform(attachment.Prof)
					end
				else
					obj.gameObject:SetActive(false)
				end
			end

			if self.load_complete ~= nil then
				self.load_complete(part, obj)
			end
			self:AddPayload(obj_class, obj_part)
		end, part)
		part_obj:SetRemoveCallback(function(obj)
			if self.remove_callback ~= nil then
				self.remove_callback(part, obj)
			end
		end)
	elseif part == SceneObjPart.Wing then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			obj_class:SetVisible(self:GetPartVisible(part))
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				obj.gameObject:SetActive(true)
				local point = attachment:GetAttachPoint(AttachPoint.Wing)
				if not IsNil(point) then
					obj.attach_obj:SetAttached(point)
					obj.attach_obj:SetTransform(attachment.Prof)
				end
			else
				obj.gameObject:SetActive(false)
			end

			if self.auto_fly then
				local main_part = self:GetPart(SceneObjPart.Main)
				main_part:SetLayer(1, 1)
			end

			if self.load_complete ~= nil then
				self.load_complete(part, obj)
			end
			self:AddPayload(obj_class, obj_part)
		end, part)
		part_obj:SetRemoveCallback(function(obj)
			if self.remove_callback ~= nil then
				self.remove_callback(part, obj)
			end
		end)
	elseif part == SceneObjPart.Cloak then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			obj_class:SetVisible(self:GetPartVisible(part))
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				local point = attachment:GetAttachPoint(AttachPoint.Wing)
				if not IsNil(point) then
					obj.attach_obj:SetAttached(point)
					obj.attach_obj:SetTransform(attachment.Prof)
				end
			end

			if self.auto_fly then
				local main_part = self:GetPart(SceneObjPart.Main)
				main_part:SetLayer(1, 1)
			end

			if self.load_complete ~= nil then
				self.load_complete(part, obj)
			end
			self:AddPayload(obj_class, obj_part)
		end, part)
		part_obj:SetRemoveCallback(function()
			if self.remove_callback ~= nil then
				self.remove_callback(part, obj)
			end
		end)
	elseif part == SceneObjPart.Mount or part == SceneObjPart.FightMount then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			obj_class:SetVisible(self:GetPartVisible(part))
			self:AddPayload(obj_class, obj_part)
			part_obj:SetInteger(ANIMATOR_PARAM.STATUS, 0)
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				obj.gameObject:SetActive(true)
				local point = attachment:GetAttachPoint(AttachPoint.Mount)
				if part == SceneObjPart.Mount then
					attachment:AddMount(obj.gameObject)
					if self.parent_obj.IsRole and self.parent_obj:IsRole() then
						local main_part = self:GetPart(SceneObjPart.Main)
						if self.parent_obj.IsMountLayer2 and self.parent_obj:IsMountLayer2() then
							main_part:SetLayer(ANIMATOR_PARAM.MOUNT_LAYER2, 1)
						else
							main_part:SetLayer(ANIMATOR_PARAM.MOUNT_LAYER2, 0)
						end
					elseif self.parent_obj.IsLingChong and self.parent_obj:IsLingChong() then
						local main_part = self:GetPart(SceneObjPart.Main)
						main_part:SetLayer(LINGCHONG_ANIMATOR_PARAM.MOUNT_LAYER, 1)

						obj.transform.localPosition = Vector3(0, 0, 0)
						obj.transform.localEulerAngles = Vector3(0, 0, 0)

						local vo = self.parent_obj:GetVo()
						local image_info = LingQiData.Instance:GetLingQiImageCfgInfoByImageId(vo.lingqi_used_imageid or 0)
						if image_info then
							local scale = image_info.scale
							if scale then
								obj.transform.localScale = Vector3(scale, scale, scale)
							end
						end
					end
				else
					attachment:AddFightMount(obj.gameObject)
				end
				if obj.attach_obj ~= nil then
					obj.attach_obj:SetTransform(attachment.Prof)
				end
				local baoju_part = self:GetPart(SceneObjPart.BaoJu)
				if baoju_part and baoju_part:GetObj() then
					local mount_point = obj.transform:Find("mount_point")
					if mount_point then
						local position = baoju_part:GetObj().transform.localPosition
						local temp_y = mount_point.transform.localPosition.y - 1.2
						-- 战斗坐骑因为挂点是在人物脚底，所以把至宝高度提高到人物的腰部
						if part == SceneObjPart.FightMount then
							temp_y = mount_point.transform.localPosition.y + 1.2
						end
						baoju_part:GetObj().transform.localPosition = Vector3(position.x, temp_y, mount_point.transform.localPosition.z)
					end
				end
			else
				obj.gameObject:SetActive(false)
			end

			if self.load_complete ~= nil then
				self.load_complete(part, obj)
			end
		end, part)
		part_obj:SetRemoveCallback(function(obj)
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				attachment:RemoveMount()
				if self.parent_obj.IsRole and self.parent_obj:IsRole() then
					local main_part = self:GetPart(SceneObjPart.Main)
					main_part:SetLayer(ANIMATOR_PARAM.MOUNT_LAYER2, 0)
				elseif self.parent_obj.IsLingChong and self.parent_obj:IsLingChong() then
					local main_part = self:GetPart(SceneObjPart.Main)
					main_part:SetLayer(LINGCHONG_ANIMATOR_PARAM.MOUNT_LAYER, 0)
				end
				local part = self:GetPart(SceneObjPart.BaoJu)
				if part and part:GetObj() then
					part:GetObj().transform.localPosition = Vector3(0, -0.34, 0)
				end
			end
			if self.remove_callback ~= nil then
				self.remove_callback(part, obj)
			end
		end)
	elseif part == SceneObjPart.Halo then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			obj_class:SetVisible(self:GetPartVisible(part))
			self:AddPayload(obj_class, obj_part)
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				obj.gameObject:SetActive(true)
				local point = attachment:GetAttachPoint(AttachPoint.Hurt)
				if not IsNil(point) then
					obj.attach_obj:SetAttached(point)
					obj.attach_obj:SetTransform(attachment.Prof)
				end
			else
				obj.gameObject:SetActive(false)
			end

			if self.load_complete ~= nil then
				self.load_complete(part, obj)
			end
		end, part)
		part_obj:SetRemoveCallback(function(obj)
			if self.remove_callback ~= nil then
				self.remove_callback(part, obj)
			end
		end)
	elseif part == SceneObjPart.BaoJu then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			obj_class:SetVisible(self:GetPartVisible(part))
			self:AddPayload(obj_class, obj_part)
			local mount_part = self:GetPart(SceneObjPart.Mount)
			local fight_mount_part = self:GetPart(SceneObjPart.FightMount)
			if mount_part and mount_part:GetObj() then
				local position = obj.transform.localPosition
				local mount_point = mount_part:GetObj().transform:Find("mount_point")
				if mount_point then
					obj.transform.localPosition = Vector3(position.x, mount_point.transform.localPosition.y - 1.2, mount_point.transform.localPosition.z)
				end
			elseif fight_mount_part and fight_mount_part:GetObj() then
				local position = obj.transform.localPosition
				local mount_point = fight_mount_part:GetObj().transform:Find("mount_point")
				if mount_point then
					-- 战斗坐骑因为挂点是在人物脚底，所以把至宝高度提高到人物的腰部
					local temp_y = mount_point.transform.localPosition.y + 1.2
					obj.transform.localPosition = Vector3(position.x, temp_y, mount_point.transform.localPosition.z)
				end
			elseif not mount_part and not fight_mount_part then
				obj.transform.localPosition = Vector3(0, -0.34, 0)
			end
			if self.load_complete ~= nil then
				self.load_complete(part, obj)
				part_obj:SetInteger(ANIMATOR_PARAM.STATUS, 1)
			end
		end, part)
		part_obj:SetRemoveCallback(function(obj)
			if self.remove_callback ~= nil then
				self.remove_callback(part, obj)
			end
		end)
	elseif part == SceneObjPart.Particle then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			obj_class:SetVisible(self:GetPartVisible(part))
			self:AddPayload(obj_class, obj_part)
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				obj.gameObject:SetActive(true)
				local point = attachment:GetAttachPoint(AttachPoint.Hurt)
				if not IsNil(point) then
					obj.attach_obj:SetAttached(point)
					obj.attach_obj:SetTransform(attachment.Prof)
				end
			else
				obj.gameObject:SetActive(false)
			end

			if self.load_complete ~= nil then
				self.load_complete(part, obj)
			end
		end, part)
		part_obj:SetRemoveCallback(function(obj)
			if self.remove_callback ~= nil then
				self.remove_callback(part, obj)
			end
		end)
	elseif part == SceneObjPart.FaZhen then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			obj_class:SetVisible(self:GetPartVisible(part))
			self:AddPayload(obj_class, obj_part)
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				obj.gameObject:SetActive(true)
				local point = attachment:GetAttachPoint(AttachPoint.HurtRoot)
				if not IsNil(point) then
					obj.attach_obj:SetAttached(point)
					obj.attach_obj:SetTransform(attachment.Prof)
				end
			else
				obj.gameObject:SetActive(false)
			end

			if self.load_complete ~= nil then
				self.load_complete(part, obj)
			end
		end, part)
		part_obj:SetRemoveCallback(function(obj)
			if self.remove_callback ~= nil then
				self.remove_callback(part, obj)
			end
		end)

	elseif part == SceneObjPart.HoldBeauty then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			obj_class:SetVisible(self:GetPartVisible(part))
			self:AddPayload(obj_class, obj_part)
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				obj.gameObject:SetActive(true)
				local point = attachment:GetAttachPoint(AttachPoint.Hug)
				if not IsNil(point) and obj.attach_obj then
					obj.attach_obj:SetAttached(point)
					obj.attach_obj:SetTransform(attachment.Prof)
				end
			else
				obj.gameObject:SetActive(false)
			end

			if self.load_complete ~= nil then
				self.load_complete(part, obj)
			end
			self:AddPayload(obj_class, obj_part)
		end, part)
		part_obj:SetRemoveCallback(function(obj)
			if self.remove_callback ~= nil then
				self.remove_callback(part, obj)
			end
		end)
	elseif part == SceneObjPart.Shadow then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			local quality_level = QualityConfig.QualityLevel

			if quality_level <= 0 and obj_class:IsMainRole() then
				obj_class:SetVisible(false)
			else
				local parent = obj.transform.parent
				if parent then
					local parent_scale = parent.localScale
					obj.transform.localScale = Vector3(2/parent_scale.x, 2/parent_scale.y, 2/parent_scale.z)
				end

				obj_class:SetVisible(true)
				self:AddPayload(obj_class, obj_part)
			end

		end, part)
		part_obj:SetRemoveCallback(function(obj)
			if self.remove_callback ~= nil then
				self.remove_callback(part, obj)
			end
		end)
	elseif part == SceneObjPart.Head then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				obj.gameObject:SetActive(true)
				local point = attachment:GetAttachPoint(AttachPoint.Head)
				if not IsNil(point) and obj.attach_obj then
					obj.attach_obj:SetAttached(point)
					obj.attach_obj:SetTransform(attachment.Prof)
				end
			else
				obj.gameObject:SetActive(false)
			end

			if self.load_complete ~= nil then
				self.load_complete(part, obj)
			end
			self:AddPayload(obj_class, obj_part)
		end, part)
		part_obj:SetRemoveCallback(function(obj)
			if self.remove_callback ~= nil then
				self.remove_callback(part, obj)
			end
		end)
	else
		print_error("_CreatePart failed: ", part)
	end

	return part_obj
end

function DrawObj:_TryGetPartObj(part)
	local part_obj = self.part_list[part]
	if part_obj == nil then
		return nil
	end

	local obj = part_obj:GetObj()
	if obj == nil or IsNil(obj.gameObject) then
		return nil
	end

	return obj
end

function DrawObj:_TryGetPartAttachObj(part)
	local part_obj = self.part_list[part]
	if part_obj == nil then
		return nil
	end

	local obj = part_obj:GetObj()
	if obj == nil or IsNil(obj.gameObject) then
		return nil
	end

	return obj.attach_obj
end

function DrawObj:_TryGetPartAttachment(part)
	local part_obj = self.part_list[part]
	if part_obj == nil then
		return nil
	end

	local obj = part_obj:GetObj()
	if obj == nil or IsNil(obj.gameObject) then
		return nil
	end

	return obj.actor_attachment
end

function DrawObj:_TryGetPartAttachSkinObj(part)
	local part_obj = self.part_list[part]
	if part_obj == nil then
		return nil
	end

	local obj = part_obj:GetObj()
	if obj == nil or IsNil(obj.gameObject) then
		return nil
	end

	return obj.attach_skin_obj
end

function DrawObj:_TryGetPartAttachSkin(part)
	local part_obj = self.part_list[part]
	if part_obj == nil then
		return nil
	end

	local obj = part_obj:GetObj()
	if obj == nil or IsNil(obj.gameObject) then
		return nil
	end

	return obj.attach_skin
end

function DrawObj:PlayDead(dietype, callback, time)
	time = time or 2.0
	local main_part = self:GetPart(SceneObjPart.Main)
	local main_obj = main_part:GetObj()
	if main_obj == nil then
		callback()
		return
	end

	local fadeout = main_obj.actor_fadout
	if fadeout ~= nil then
		fadeout:Fadeout(time, callback)
		return
	end

	local tween = main_obj.transform:DOLocalMoveY(-1.0, 1.0)
	tween:SetEase(DG.Tweening.Ease.Linear)
	tween:OnComplete(callback)
end

function DrawObj:AddPayload(part_obj, part)
	if nil == RenderBudget.Instance then return end
	if self.obj_type == SceneObjType.Monster and self.is_boss then return end
	part_obj.budget_handle = RenderBudget.Instance:AddPayload(self.obj_type, part, BindTool.Bind(self.BudgetEnable, self, part), BindTool.Bind(self.BudgetDisable, self, part))
end

function DrawObj:BudgetEnable(part)
	if part > 0 then
		if self.part_list[part] then
			self.part_list[part]:SetBudgetVis(true)
		end
	else
		self:SetBudgetVis(true)
	end
end

function DrawObj:BudgetDisable(part)
	if part > 0 then
		if self.part_list[part] then
			self.part_list[part]:SetBudgetVis(false)
		end
	else
		self:SetBudgetVis(false)
	end
end

function DrawObj:SetCheckWater(state)
	self.root.move_obj.CheckWater = state
end

function DrawObj:SetWaterHeight(height)
	self.root.move_obj.WaterHeight = height
end

function DrawObj:SetEnterWaterCallBack(callback)
	self.root.move_obj:SetEnterWaterCallBack(callback)
end

function DrawObj:AddOcclusion()
	for k, part in pairs(SceneObjPart) do
		if self.part_list[part] then
			self.part_list[part]:AddOcclusion()
		end
	end
end

function DrawObj:RemoveOcclusion()
	for k, part in pairs(SceneObjPart) do
		if self.part_list[part] then
			self.part_list[part]:RemoveOcclusion()
		end
	end
end

function DrawObj:GetLookAtPoint(y)
	y = y or 0
	if nil == self.look_at_point then
		self.look_at_point = GameObject.New()
		self.look_at_point.transform:SetParent(self.root.transform)
		self.look_at_point.transform.localEulerAngles = Vector3(0, 0, 0)
		self.look_at_point.transform.localPosition = Vector3(0, y, 0)
	else
		self.look_at_point.transform:DOLocalMoveY(y, 1.5)
	end
	return self.look_at_point.transform
end

function DrawObj:GetIsInWater()
	local in_water = false
	if self.root.move_obj then
		in_water = self.root.move_obj.IsInWater
	end
	return in_water
end

function DrawObj:ShieldPart(part, is_shield)
	self.shield_part_list[part] = is_shield
	local part_obj = self.part_list[part]
	if part_obj then
		part_obj:SetVisible(self:GetPartVisible(part))
	end
end

function DrawObj:GetPartVisible(part)
	return (self.is_visible and self.budget_vis and not self.shield_part_list[part]) or false
end