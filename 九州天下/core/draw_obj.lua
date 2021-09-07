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
	self.auto_fly = false
	self.load_complete = nil
	self.obj_type = 0
	self.scene_obj = nil
	self.budget_vis = true
	self.is_visible = true
	self.is_use_objpool = true
	self.is_fight_mount = false
end

function DrawObj:__delete()
	for k,v in pairs(self.part_list) do
		v:DeleteMe()
	end
	self.part_list = {}

	local game_obj = self.root.gameObject
	GameObject.Destroy(game_obj)

	GlobalTimerQuest:CancelQuest(self.delay_set_attached)

	self.root = nil
	self.parent_obj = nil
	self.scene_obj = nil
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

function DrawObj:SetOffset(y)
	self.root.move_obj:SetOffset(y)
end

function DrawObj:SetPosition(x, y)
	self.root.move_obj:SetPosition(x, 0, y)
end

function DrawObj:SetScale(x_scale, y_scale, z_scale)
	self.root.move_obj.transform.localScale = Vector3(x_scale, y_scale, z_scale)
end

function DrawObj:Rotate(x_angle, y_angle, z_angle)
	self.root.transform:Rotate(x_angle, y_angle, z_angle)
end

function DrawObj:GetRootPosition()
	return self.root.transform.position
end

function DrawObj:SetDirectionByXY(x, y)
	self.root.move_obj:RotateTo(x, 0, y, 20)
end

function DrawObj:MoveTo(x, y, speed)
	self.root.move_obj:MoveTo(x, 0, y, speed)
end

function DrawObj:StopMove()
	self.root.move_obj:StopMove()
end

function DrawObj:StopRotate()
	self.root.move_obj:StopRotate()
end

function DrawObj:SetBudgetVis(visible)
	self.budget_vis = visible
	for k, part in pairs(SceneObjPart) do
		if self.part_list[part] then
			self.part_list[part]:SetVisible(self.is_visible and self.budget_vis)
		end
	end
end

function DrawObj:SetVisible(visible)
	self.is_visible = visible
	visible = self.is_visible and self.budget_vis
	self:GetPart(SceneObjPart.Main):SetVisible(visible)
	self:GetPart(SceneObjPart.Weapon):SetVisible(visible)
	self:GetPart(SceneObjPart.Weapon2):SetVisible(visible)
	self:GetPart(SceneObjPart.Mount):SetVisible(visible)
	self:GetPart(SceneObjPart.FightMount):SetVisible(visible)
	self:GetPart(SceneObjPart.Wing):SetVisible(visible)
	self:GetPart(SceneObjPart.Halo):SetVisible(visible)
	self:GetPart(SceneObjPart.BaoJu):SetVisible(visible)
	self:GetPart(SceneObjPart.Particle):SetVisible(visible)
	self:GetPart(SceneObjPart.Mantle):SetVisible(visible)
	self:GetPart(SceneObjPart.HoldBeauty):SetVisible(visible)
	self:GetPart(SceneObjPart.FaZhen):SetVisible(visible)
	self:GetPart(SceneObjPart.Head):SetVisible(visible)
	self:GetPart(SceneObjPart.Bag):SetVisible(visible)
	self:GetPart(SceneObjPart.TouShi):SetVisible(visible)
	self:GetPart(SceneObjPart.Waist):SetVisible(visible)
	self:GetPart(SceneObjPart.Mask):SetVisible(visible)
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

	if part == SceneObjPart.Main then
		part_obj:SetMainRole(self.parent_obj.IsMainRole and self.parent_obj:IsMainRole())
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			local attachment = obj.actor_attachment
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

			local mantle_obj = self:_TryGetPartAttachObj(SceneObjPart.Mantle)
			if mantle_obj ~= nil then
					mantle_obj.gameObject:SetActive(true)
				point = attachment:GetAttachPoint(AttachPoint.Wing)
				if nil ~= point and not IsNil(point.gameObject) then
					mantle_obj:SetAttached(point)
					mantle_obj:SetTransform(attachment.Prof)
				end

				if self.auto_fly then
					local main_part = self:GetPart(SceneObjPart.Main)
					main_part:SetLayer(1, 1)
				end
			end

			local mount_obj = self:_TryGetPartObj(SceneObjPart.Mount)
			local need_reset_dance = false
			if mount_obj ~= nil then
				mount_obj.gameObject:SetActive(true)
				attachment:AddMount(mount_obj.gameObject)
				need_reset_dance = true
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

			if need_reset_dance then
				local main_part = self:GetPart(SceneObjPart.Main)
				main_part:SetLayer(9, 0)
				main_part:SetLayer(10, 0)
				main_part:SetLayer(11, 0)
				main_part:SetLayer(13, 0)
				main_part:SetLayer(14, 0)
			end


			local fazhen_obj = self:_TryGetPartObj(SceneObjPart.FaZhen)
			if fazhen_obj ~= nil then
				fazhen_obj.gameObject:SetActive(true)
				attachment:AddFaZhen(fazhen_obj.gameObject)
				if fazhen_obj.attach_obj ~= nil then
					fazhen_obj.attach_obj:SetTransform(attachment.Prof)
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
				attachment:RemoveFazhen()
			end

			local weapon = self.part_list[SceneObjPart.Weapon]
			if nil ~= weapon then
				if self.weapon_effect then
					GameObject.Destroy(self.weapon_effect)
					self.weapon_effect = nil
				end
				weapon:Reset()
			end
			local weapon2 = self.part_list[SceneObjPart.Weapon2]
			if nil ~= weapon2 then
				if self.weapon2_effect then
					GameObject.Destroy(self.weapon2_effect)
					self.weapon2_effect = nil
				end
				weapon2:Reset()
			end
			local wing = self.part_list[SceneObjPart.Wing]
			if nil ~= wing then
				wing:Reset()
			end
			local mantle = self.part_list[SceneObjPart.Mantle]
			if nil ~= mantle then
				mantle:Reset()
			end
			local halo = self.part_list[SceneObjPart.Halo]
			if nil ~= halo then
				halo:Reset()
			end
			local beauty = self.part_list[SceneObjPart.HoldBeauty]
			if nil ~= beauty then
				beauty:Reset()
			end
			local head = self.part_list[SceneObjPart.Head]
			if nil ~= head then
				head:Reset()
			end
			local bag = self.part_list[SceneObjPart.Bag]
			if nil ~= bag then
				bag:Reset()
			end

			if self.remove_callback ~= nil then
				self.remove_callback(part, obj)
			end
		end)
	elseif PartAttachPoint[part] ~= nil then -- Weapon, Weapon2
		part_obj:SetMainRole(self.parent_obj.IsMainRole and self.parent_obj:IsMainRole())
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
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
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				obj.gameObject:SetActive(true)
				local point = attachment:GetAttachPoint(AttachPoint.Wing)
				if not IsNil(point) and obj.attach_obj then
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
	elseif part == SceneObjPart.Mantle then
		part_obj:SetMainRole(self.parent_obj.IsMainRole and self.parent_obj:IsMainRole())
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
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
		part_obj:SetMainRole(self.parent_obj.IsMainRole and self.parent_obj:IsMainRole())
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			self:AddPayload(obj_class, obj_part)
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				obj.gameObject:SetActive(true)
				local point = attachment:GetAttachPoint(AttachPoint.Mount)
				if part == SceneObjPart.Mount and not self:GetIsFightMount() then
					attachment:AddMount(obj.gameObject)
				else
					attachment:AddFightMount(obj.gameObject)
				end

				local main_part = self:GetPart(SceneObjPart.Main)
				main_part:SetLayer(9, 0)
				main_part:SetLayer(10, 0)
				main_part:SetLayer(11, 0)
				main_part:SetLayer(13, 0)
				main_part:SetLayer(14, 0)
				
				if obj.attach_obj ~= nil then
					obj.attach_obj:SetTransform(attachment.Prof)
				end
				local baoju_part = self:GetPart(SceneObjPart.BaoJu)
				if baoju_part and baoju_part:GetObj() then
					local mount_point = obj.transform:Find("mount_point")
					if mount_point then
						local position = baoju_part:GetObj().transform.localPosition
						local temp_y = mount_point.transform.localPosition.y - 1.2
						if part == SceneObjPart.FightMount then
							temp_y = mount_point.transform.localPosition.y
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
			self:AddPayload(obj_class, obj_part)
		end, part)
		part_obj:SetRemoveCallback(function(obj)
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				attachment:RemoveMount()
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
			self:AddPayload(obj_class, obj_part)
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				obj.gameObject:SetActive(true)
				local point = attachment:GetAttachPoint(AttachPoint.Hurt)
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
	elseif part == SceneObjPart.BaoJu then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
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
					obj.transform.localPosition = Vector3(position.x, mount_point.transform.localPosition.y, mount_point.transform.localPosition.z)
				end
			elseif not mount_part and not fight_mount_part then
				obj.transform.localPosition = Vector3(0, -0.34, 0)
			end
			if self.load_complete ~= nil then
				self.load_complete(part, obj)
				part_obj:SetInteger("status", ActionStatus.Run)
			end
			self:AddPayload(obj_class, obj_part)
		end, part)
		part_obj:SetRemoveCallback(function(obj)
			if self.remove_callback ~= nil then
				self.remove_callback(part, obj)
			end
		end)
	elseif part == SceneObjPart.Particle then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			self:AddPayload(obj_class, obj_part)
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				obj.gameObject:SetActive(true)
				local point = attachment:GetAttachPoint(AttachPoint.Hurt)
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
	elseif part == SceneObjPart.FaZhen then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			self:AddPayload(obj_class, obj_part)
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				obj.gameObject:SetActive(true)
				attachment:AddFaZhen(obj.gameObject)
				if obj.attach_obj ~= nil then
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
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				attachment:RemoveFazhen()
			end
			if self.remove_callback ~= nil then
				self.remove_callback(part, obj)
			end
		end)

	elseif part == SceneObjPart.HoldBeauty then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			self:AddPayload(obj_class, obj_part)
			local attachment = self:_TryGetPartAttachment(SceneObjPart.Main)
			if attachment ~= nil then
				obj.gameObject:SetActive(true)
				local point = attachment:GetAttachPoint(AttachPoint.Hurt)
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
	elseif part == SceneObjPart.Head then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			self:AddPayload(obj_class, obj_part)
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
	elseif part == SceneObjPart.Bag then
		part_obj:SetLoadComplete(function(obj, obj_part, obj_class)
			self:AddPayload(obj_class, obj_part)
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

function DrawObj:PlayDead(dietype, callback, time)
	time = time or 2.0
	local main_part = self:GetPart(SceneObjPart.Main)
	local main_obj = main_part:GetObj()
	if main_obj == nil then
		if callback then
			callback()
		end
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

function DrawObj:SetIsFightMount(value)
	self.is_fight_mount = value
end

function DrawObj:GetIsFightMount(value)
	return self.is_fight_mount
end