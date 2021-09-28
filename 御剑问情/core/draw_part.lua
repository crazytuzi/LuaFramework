DrawPart = DrawPart or BaseClass()

ResPreload = require "core.res_preload"

local NirvanaRenderer = typeof(NirvanaRenderer)
local UnitySkinnedMeshRenderer = typeof(UnityEngine.SkinnedMeshRenderer)
local UnityMeshRenderer = typeof(UnityEngine.MeshRenderer)
local UnityParticleSystem = typeof(UnityEngine.ParticleSystem)
local GeometryRendererQueue = 2000
local AlphaTestQueue = 2450

local ShadowCastingMode = nil
if nil ~= UnityEngine.Rendering then -- 兼容旧包
	ShadowCastingMode = UnityEngine.Rendering.ShadowCastingMode
end

local instantiateQueue = InstantiateQueue.New()
InstantiateQueue.Global = instantiateQueue

local function ChangeRenderOpaqueQueue(renderers, render_queue, skip_particle_system)
	if renderers ~= nil then
        for i = 0, renderers.Length - 1 do
            local renderer = renderers[i]
            if not skip_particle_system or renderer:GetComponent(UnityParticleSystem) == nil then
	            local nirvana_renderer = renderer.gameObject:GetComponent(NirvanaRenderer)

	            local materials
	            if nirvana_renderer then
	                materials = nirvana_renderer.Materials
	            else
	                materials = renderer.materials
	            end

	            if nil == materials then return end

	            for j = 0, materials.Length - 1 do
	            	if materials[j] and materials[j] ~= ResPreload.role_occlusion then
	            		if materials[j].renderQueue < AlphaTestQueue then
	                		materials[j].renderQueue = render_queue
	            		end
	                end
	            end
	        end
        end
    end
end

local function ChangeIsCastShadow(renderers, is_cast_shadow)
	if nil == renderers or nil == ShadowCastingMode then -- 兼容旧包
		return
	end

	for i = 0, renderers.Length - 1 do
		renderers[i].shadowCastingMode = is_cast_shadow and ShadowCastingMode.On or ShadowCastingMode.Off
	end
end

function DrawPart:__init()
	self.obj = nil
	self.asset_bundle = nil
	self.asset_name = nil
	self.loading = false
	self.load_priority = 0
	self.load_complete = nil
	self.remove_callback = nil
	self.material_index = 0

	self.visible = true
	self.parent = nil
	self.layer = 0
	self.click_listener = nil
	self.attack_target = nil
	self.attach_requests = {}
	self.blink = false
	self.play_attach_effect = false

	self.animator_triggers = {}
	self.animator_bools = {}
	self.animator_ints = {}
	self.animator_floats = {}
	self.animator_listener = {}
	self.animator_layers = {}
	self.animator_plays = {}

	self.animator_handle = {}

	self.is_main_role = false
	self.enable_effect = true
	self.enable_halt = true
	self.enable_camera_shake = true
	self.enable_scene_fade = true
	self.enable_footsteps = true
	self.enable_mount_up = false
	self.budget_vis = true
	self.is_visible = true
	self.budget_handle = nil
	self.part = 0
	self.offset_y = 0

	self.is_monster = false

	self.add_occlusion_material_list = {}

	self.is_use_objpool = false
	self.is_use_transparent = false 			-- 是否使用隐身材质球
end

function DrawPart:__delete()
	for _, v in pairs(self.animator_handle) do
		v:Dispose()
	end
	self.animator_handle = {}

	self:RemoveModel()

	if self.budget_handle and RenderBudget.Instance then
		RenderBudget.Instance:RemovePayload(self.budget_handle)
		self.budget_handle = nil
	end
end

function DrawPart:DestoryObj(obj)
	if not IsNil(obj) then
		if self.obj and not IsNil(self.obj.gameObject) and obj == self.obj.gameObject then
			if self.is_use_transparent then
				self:RemoveTransparentMaterial()
				self.is_use_transparent = true
			end
		end

		if self.is_use_objpool then
			self:RemoveOcclusion()
			GameObjectPool.Instance:Free(obj)
		else
			GameObject.Destroy(obj)
		end
	end
end

function DrawPart:SetIsUseObjPool(is_use_objpool)
	self.is_use_objpool = is_use_objpool
end

function DrawPart:SetBudgetVis(visible)
	self.budget_vis = visible
	self:SetVisible()
end

function DrawPart:SetVisible(visible)
	if self.part == SceneObjPart.Shadow then
		--怪物不隐藏阴影
		if self.is_monster then
			self.budget_vis = true
			self.is_visible = true
			return
		end
	end

	if visible ~= nil then
		self.is_visible = visible
	end
	visible = self.is_visible and self.budget_vis
	if visible then
		if self.obj == nil and
			self.asset_bundle ~= nil and
			self.asset_name ~= nil then
			local asset_bundle = self.asset_bundle
			local asset_name = self.asset_name
			self.asset_bundle = nil
			self.asset_name = nil
			self:ChangeModel(asset_bundle, asset_name)
		end
	else
		if self.obj ~= nil then
			if self.remove_callback ~= nil then
				self.remove_callback(self.obj)
			end
			self:Reset()

			self:DestoryObj(self.obj.gameObject)
			self.obj = nil
		end
	end
end

function DrawPart:SetParent(parent)
	self.parent = parent
	if self.obj ~= nil then
		self:_FlushParent(self.obj)
	end
end

function DrawPart:SetMaterialIndex(index)
	if self.material_index ~= index then
		self.material_index = index
		if self.obj ~= nil then
			self:_FlushMaterialIndex(self.obj)
		end
	end
end

function DrawPart:SetGameLayer(layer)
	self.layer = layer

	if self.obj ~= nil then
		self:_FlushGameLayer(self.obj)
	end
end

function DrawPart:ListenClick(listener)
	self.click_listener = listener
	if self.obj ~= nil then
		self:_FlushClickListener(self.obj)
	end
end

function DrawPart:SetAttackTarget(target)
	self.attack_target = target
	if self.obj ~= nil then
		self:_FlushAttackTarget(self.obj)
	end
end

function DrawPart:SetTrigger(key)
	if self.obj ~= nil and not IsNil(self.obj.animator) then
		if self.obj.animator and self.obj.animator.isActiveAndEnabled then
			self.obj.animator:SetTrigger(key)
		end
	elseif self.visible then
		self.animator_triggers[key] = true
	end
end

function DrawPart:SetBool(key, value)
	self.animator_bools[key] = value
	if self.obj ~= nil then
		if self.obj.animator and self.obj.animator.isActiveAndEnabled then
			self.obj.animator:SetBool(key, value)
		end
	end
end

function DrawPart:SetInteger(key, value)
	self.animator_ints[key] = value
	if self.obj ~= nil then
		if self.obj.animator and self.obj.animator.isActiveAndEnabled then
			self.obj.animator:SetInteger(key, value)
		end
	end
end

function DrawPart:GetInteger(key)
	if self.obj ~= nil then
		if self.obj.animator and self.obj.animator.isActiveAndEnabled then
			return self.obj.animator:GetInteger(key)
		end
	end
end

function DrawPart:SetFloat(key, value)
	self.animator_floats[key] = value
	if self.obj ~= nil then
		if self.obj.animator and self.obj.animator.isActiveAndEnabled then
			self.obj.animator:SetFloat(key, value)
		end
	end
end

function DrawPart:SetLayer(layer, value)
	if self.obj ~= nil then
		self.obj.animator:SetLayerWeight(layer, value)
	else
		self.animator_layers[layer] = value
	end
end

function DrawPart:Play(key, layer, value)
	self.animator_plays[key] = {layer = layer, value = value}
	if self.obj ~= nil then
		self.obj.animator:Play(key, layer, value)
	end
end

function DrawPart:GetAnimationInfo(layer)
	layer = layer or ANIMATOR_PARAM.BASE_LAYER
	local animation_info = nil
	if self.obj ~= nil then
		if self.obj.animator and self.obj.animator.isActiveAndEnabled then
			animation_info = self.obj.animator:GetCurrentAnimatorStateInfo(layer)
		end
	end
	return animation_info
end

function DrawPart:SetMainRole(is_main_role)
	self.is_main_role = is_main_role
	if self.obj ~= nil then
		local actor_ctrl = self.obj.actor_ctrl
		if actor_ctrl ~= nil then
			actor_ctrl.IsMainRole = is_main_role
		end
	end
end

function DrawPart:IsMainRole()
	return self.is_main_role
end

function DrawPart:SetIsMonster(is_monster)
	self.is_monster = is_monster
end

function DrawPart:GetIsMonster()
	return self.is_monster
end

function DrawPart:EnableEffect(enabled)
	self.enable_effect = enabled
	if self.obj ~= nil then
		local actor_ctrl = self.obj.actor_ctrl
		if actor_ctrl ~= nil then
			actor_ctrl:EnableEffect(enabled)
		end
	end
end

function DrawPart:EnableHalt(enabled)
	self.enable_halt = enabled
	if self.obj ~= nil then
		local actor_ctrl = self.obj.actor_ctrl
		if actor_ctrl ~= nil then
			actor_ctrl:EnableHalt(enabled)
		end
	end
end

function DrawPart:EnableMountUpTrigger(enabled)
	self.enable_mount_up = enabled
	if self.obj ~= nil then
		local attachment = self.obj.actor_attachment
		if attachment ~= nil then
			attachment:SetMountUpTriggerEnable(enabled)
		end
	end
end

function DrawPart:GetEnabelMountUp()
	return self.enable_mount_up
end

function DrawPart:EnableCameraShake(enabled)
	self.enable_camera_shake = enabled
	if self.obj ~= nil then
		local actor_ctrl = self.obj.actor_ctrl
		if actor_ctrl ~= nil then
			actor_ctrl:EnableCameraShake(enabled)
		end
	end
end

function DrawPart:EnableCameraFOV(enabled)
	self.enable_camera = enabled
	if self.obj ~= nil then
		local actor_ctrl = self.obj.actor_ctrl
		if actor_ctrl ~= nil then
			actor_ctrl:EnableCameraFOV(enabled)
		end
	end
end

function DrawPart:EnableSceneFade(enabled)
	self.enable_scene_fade = enabled
	if self.obj ~= nil then
		local actor_ctrl = self.obj.actor_ctrl
		if actor_ctrl ~= nil then
			actor_ctrl:EnableSceneFade(enabled)
		end
	end
end

function DrawPart:EnableFootsteps(enabled)
	self.enable_footsteps = enabled
	if self.obj ~= nil then
		local actor_ctrl = self.obj.actor_ctrl
		if actor_ctrl ~= nil then
			actor_ctrl:EnableFootsteps(enabled)
		end
	end
end

function DrawPart:ListenEvent(event_name, callback)
	self:UnListenEvent(event_name)

	self.animator_listener[event_name] = callback
	if self.obj ~= nil then
		self.animator_handle[event_name] = self.obj.animator:ListenEvent(event_name, callback)
	end
end

function DrawPart:UnListenEvent(event_name)
	self.animator_listener[event_name] = nil

	if nil ~= self.animator_handle[event_name] then
		self.animator_handle[event_name]:Dispose()
		self.animator_handle[event_name] = nil
	end
end

function DrawPart:Blink()
	if self.obj ~= nil and self.obj.actor_ctrl ~= nil then
		self.obj.actor_ctrl:Blink()
	else
		self.blink = true
	end
end

function DrawPart:PlayAttachEffect()
	if self.obj ~= nil then
		if nil ~= self.obj.actor_attach_effect then
			self.obj.actor_attach_effect:PlayEffect()
		end
	else
		self.play_attach_effect = true
	end
end

function DrawPart:GetAttachPoint(point)
	if self.obj == nil or IsNil(self.obj.gameObject) then
		return nil
	end

	local attachment = self.obj.actor_attachment
	if attachment == nil then
		return nil
	end

	return attachment:GetAttachPoint(point)
end

function DrawPart:RequestAttachment(complete)
	if self.obj ~= nil then
		local attachment = self.obj.actor_attachment
		if attachment ~= nil then
			complete(attachment)
		else
			complete(nil)
		end
	else
		table.insert(self.attach_requests, complete)
	end
end

function DrawPart:SetLoadComplete(complete, part)
	self.load_complete = complete
	self.part = part
end

function DrawPart:SetRemoveCallback(callback)
	self.remove_callback = callback
end


function DrawPart:GetObj()
	return self.obj
end

function DrawPart:ChangeModel(asset_bundle, asset_name, callback)
	if not self.visible then
		self.asset_bundle = asset_bundle
		self.asset_name = asset_name
		return
	end

	if self.asset_bundle == asset_bundle and
		self.asset_name == asset_name then
		return
	end

	self.asset_bundle = asset_bundle
	self.asset_name = asset_name
	if self.loading then
		return
	end

	self.load_callback = callback
	if self.asset_bundle ~= nil and self.asset_name ~= nil then
		self.loading = true
		self:LoadModel(self.asset_bundle, self.asset_name, false)
	elseif self.obj ~= nil then
		if self.remove_callback ~= nil then
			self.remove_callback(self.obj)
		end
		self:Reset()
		self:DestoryObj(self.obj.gameObject)
		self.obj = nil
	end
end

function DrawPart:RemoveModel()
	self.asset_bundle = nil
	self.asset_name = nil
	if self.obj ~= nil and not IsNil(self.obj.gameObject) then
		if self.remove_callback ~= nil then
			self.remove_callback(self.obj)
		end
		self:Reset()

		local attachment = self.obj.actor_attachment
		if attachment ~= nil then
			for i,v in ipairs(self.attach_requests) do
				v(nil)
			end
		end

		local actor_ctrl = self.obj.actor_ctrl
		if nil ~= actor_ctrl then
			actor_ctrl:StopEffects()
		end

		local actor_attach_effect = self.obj.actor_attach_effect
		if nil ~= actor_attach_effect then
			actor_attach_effect:StopEffect()
		end

		self:DestoryObj(self.obj.gameObject)
		self.obj = nil
	end
end

function DrawPart:Reset(obj)
	local object = nil
	if obj == nil then
		object = self.obj
	else
		if type(obj) == "userdata" then
			object = U3DObject(obj)
		else
			object = obj
		end
	end
	if object ~= nil then
		if object.attach_obj ~= nil then
			object.attach_obj:CleanAttached()
		end
		if object.attach_skin_obj ~= nil then
			object.attach_skin_obj:ResetBone()
		end
	end
end

function DrawPart:LoadModel(asset_bundle, asset_name, is_reload)
	if self.is_use_objpool then
		GameObjectPool.Instance:SpawnAssetWithQueue(
				asset_bundle,
				asset_name,
				instantiateQueue,
				self.load_priority,
				BindTool.Bind(self._OnLoadComplete, self, asset_bundle, asset_name, is_reload))
	else
		QueueLoader.Instance:LoadPrefab(
				asset_bundle,
				asset_name,
				BindTool.Bind(self._OnLoadComplete, self, asset_bundle, asset_name, is_reload))
	end
end

function DrawPart:_OnLoadComplete(asset_bundle, asset_name, is_reload, obj)
	if IsNil(obj) then
		self.loading = false
		print_warning("Load model failed: ", asset_bundle, asset_name)
		if is_reload then
			return
		end
	end

	if self.obj ~= nil then
		if self.remove_callback ~= nil then
			self.remove_callback(self.obj)
		end
		self:Reset()
		self:DestoryObj(self.obj.gameObject)
		self.obj = nil
	end

	if obj == nil or IsNil(obj) or self.asset_bundle ~= asset_bundle or
		self.asset_name ~= asset_name then
		if obj and not IsNil(obj) then
			self:Reset(obj)
			self:DestoryObj(obj)
		end

		if self.asset_bundle ~= nil and self.asset_name ~= nil then
			self:LoadModel(self.asset_bundle, self.asset_name, true)
		else
			self.loading = false
		end

		return
	end

	self.loading = false
	self.obj = U3DObject(obj)

	self:AddOcclusion()

	-- Flush the data.
	self:_FlushParent(self.obj)
	self:_FlushMaterialIndex(self.obj)
	self:_FlushClickListener(self.obj)
	self:_FlushAttackTarget(self.obj)
	self:_FlushGameLayer(self.obj)

	-- Blink
	if self.blink and nil ~= self.obj.actor_ctrl then
		self.obj.actor_ctrl:Blink()
		self.blink = false
	end

	-- play attach effect
	if self.play_attach_effect and self.obj.actor_attach_effect then
		self.obj.actor_attach_effect:PlayEffect()
		self.play_attach_effect = false
	end

	-- Flush all animator parameters.
	local animator = self.obj.animator
	if animator ~= nil and animator.isActiveAndEnabled then
		for k,v in pairs(self.animator_triggers) do
			animator:SetTrigger(k)
		end
		self.animator_triggers = {}

		for k,v in pairs(self.animator_bools) do
			animator:SetBool(k, v)
		end

		for k,v in pairs(self.animator_ints) do
			animator:SetInteger(k, v)
		end

		for k,v in pairs(self.animator_floats) do
			animator:SetFloat(k, v)
		end

		for k,v in pairs(self.animator_layers) do
			animator:SetLayerWeight(k, v)
		end

		for k,v in pairs(self.animator_plays) do
			animator:Play(k, v.layer, v.value)
		end
		self.animator_layers = {}

		-- listen animator event.
		for k,v in pairs(self.animator_listener) do
			if nil ~= self.animator_handle[k] then
				self.animator_handle[k]:Dispose()
				self.animator_handle[k] = nil
			end

			self.animator_handle[k] = self.obj.animator:ListenEvent(k, v)
		end
	end

	-- flush the actor controller
	local actor_ctrl = self.obj.actor_ctrl
	if actor_ctrl ~= nil then
		actor_ctrl.IsMainRole = self.is_main_role
		actor_ctrl:EnableEffect(self.enable_effect)
		actor_ctrl:EnableHalt(self.enable_halt)
		actor_ctrl:EnableCameraShake(self.enable_camera_shake)
		actor_ctrl:EnableCameraFOV(self.enable_camera)
		actor_ctrl:EnableSceneFade(self.enable_scene_fade)
		actor_ctrl:EnableFootsteps(self.enable_footsteps)
		actor_ctrl:StopEffects()
	end

	local skinned_mesh_renderers = self.obj:GetComponentsInChildren(UnitySkinnedMeshRenderer)
	local mesh_renderers = self.obj:GetComponentsInChildren(UnityMeshRenderer)
	if not self.is_main_role then
		-- 修改渲染队列
		ChangeRenderOpaqueQueue(skinned_mesh_renderers, GeometryRendererQueue + 2, false)
		ChangeRenderOpaqueQueue(mesh_renderers, GeometryRendererQueue + 2, true)

		ChangeIsCastShadow(skinned_mesh_renderers, false)
		ChangeIsCastShadow(mesh_renderers, false)
	else
		ChangeIsCastShadow(skinned_mesh_renderers, true)
		ChangeIsCastShadow(mesh_renderers, true)
	end

	if self.is_use_transparent then
		self:AddTransparentMaterial()
	end

	local visible = self.is_visible and self.budget_vis
	self:SetVisible(visible)
	if not visible then
		return
	end

	-- Notify load complete
	if self.load_complete then
		self.load_complete(self.obj, self.part, self)
	end

	if self.load_callback then
		self.load_callback(self.obj)
		self.load_callback = nil
	end

	-- Flush attach point request.（必须得放在load_complete后面）
	local attachment = self.obj and self.obj.actor_attachment
	if attachment ~= nil then
		attachment:SetMountUpTriggerEnable(self.enable_mount_up)
		for i,v in ipairs(self.attach_requests) do
			v(attachment)
		end
	else
		for i,v in ipairs(self.attach_requests) do
			v(nil)
		end
	end
	self.attach_requests = {}

	if self.offset_y > 0 then
		self.obj.transform.localPosition = Vector3(self.obj.transform.localPosition.x,
			self.offset_y, self.obj.transform.localPosition.z)
	end
end

function DrawPart:_FlushParent(obj)
	if self.parent ~= nil then
		obj.transform:SetParent(self.parent.transform, false)
		-- 如果有TrailRenderer组件，瞬移过来会出现很长的拖尾，很难看
		local trail_renderer_list = obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.TrailRenderer))
		for i = 0, trail_renderer_list.Length - 1 do
			local trail_renderer = trail_renderer_list[i]
			if trail_renderer then
				trail_renderer:Clear()
			end
		end
	else
		obj.transform:SetParent(nil)
	end
end

function DrawPart:_FlushMaterialIndex(obj)
	local switcher = obj:GetComponent(typeof(MaterialSwitcher))
	if switcher ~= nil then
		self:RemoveOcclusion()
		switcher:Switch(self.material_index)
		self:AddOcclusion()
	end
end

function DrawPart:_FlushGameLayer(obj)
	local children = self.obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.Transform))
	if self.layer ~= nil then
		for i = 0, children.Length - 1 do
			local child = children[i].gameObject
			if child then
				if child.layer ~= UnityEngine.LayerMask.NameToLayer("Clickable") then
					child.layer = self.layer
				end
			end
		end
	else
		for i = 0, children.Length - 1 do
			local child = children[i].gameObject
			if child then
				if child.layer ~= UnityEngine.LayerMask.NameToLayer("Clickable") then
					child.layer = UnityEngine.LayerMask.NameToLayer("Default")
				end
			end
		end
	end
end

function DrawPart:_FlushClickListener(obj)
	local clickable = obj.clickable_obj
	if clickable == nil then
		return
	end

	if self.click_listener ~= nil then
		clickable:SetClickListener(self.click_listener)
		clickable:SetClickable(true)
	else
		clickable:SetClickListener(nil)
		clickable:SetClickable(false)
	end
end

function DrawPart:_FlushAttackTarget(obj)
	if obj.actor_ctrl ~= nil and self.attack_target ~= nil and not IsNil(self.attack_target) then
		obj.actor_ctrl.Target = self.attack_target
	end
end

function DrawPart:SetOffsetY(offset)
	self.offset_y = offset or 0
	if self.obj ~= nil then
		self.obj.transform.localPosition = Vector3(self.obj.transform.localPosition.x,
		 	self.offset_y, self.obj.transform.localPosition.z)
	end
end

function DrawPart:ReSetOffsetY()
	if self.obj ~= nil then
		self.obj.transform.localPosition = Vector3(self.obj.transform.localPosition.x,
			0, self.obj.transform.localPosition.z)
	end
	self.offset_y = 0
end

function DrawPart:AddOcclusion()
	if self.is_main_role and self.obj then
		local occlusion_obj = self.obj:GetComponent(typeof(OcclusionObject))
		if occlusion_obj then
			local itmes = occlusion_obj.Items
			local length = itmes.Length
			for i = 0, length - 1 do
				local item = itmes[i]
				local skinned_mesh = item.renderer:GetComponent(UnitySkinnedMeshRenderer)
				if skinned_mesh then
					self:AddMaterial(skinned_mesh, item.occlusionMaterial)
				end
			end
		else
			self:AddOcclusionMaterial(self.obj:GetComponentsInChildren(UnitySkinnedMeshRenderer), false)
        	self:AddOcclusionMaterial(self.obj:GetComponentsInChildren(UnityMeshRenderer), true)
		end
    end
end

function DrawPart:RemoveOcclusion()
	if self.is_main_role and self.obj then
        local occlusion_obj = self.obj:GetComponent(typeof(OcclusionObject))
		if occlusion_obj then
			local itmes = occlusion_obj.Items
			local length = itmes.Length
			for i = 0, length - 1 do
				local item = itmes[i]
				local skinned_mesh = item.renderer:GetComponent(UnitySkinnedMeshRenderer)
				if skinned_mesh then
					self:RemoveMaterial(skinned_mesh, item.occlusionMaterial)
				end
			end
		else
			self:RemoveOcclusionMaterial(self.obj:GetComponentsInChildren(UnitySkinnedMeshRenderer), false)
        	self:RemoveOcclusionMaterial(self.obj:GetComponentsInChildren(UnityMeshRenderer), true)
		end
	end
end

function DrawPart:AddMaterial(renderer, occlusion_material, skip_particle_system)
	if not self.add_occlusion_material_list[renderer] and nil ~= renderer and nil ~= renderer.gameObject and not IsNil(renderer.gameObject) then
        if not skip_particle_system or renderer:GetComponent(UnityParticleSystem) == nil then
            local nirvana_renderer = renderer.gameObject:GetComponent(NirvanaRenderer)
            local materials

            if nirvana_renderer then
                materials = nirvana_renderer.Materials
            else
                materials = renderer.materials
            end

            if nil == materials then return end

            local new_materials = {}
            local len = materials.Length

            if len > 0 then
                for j = 0, len - 1 do
                	local material = materials[j]
                	if material then
                		table.insert(new_materials, material)
                    	if material.renderQueue < AlphaTestQueue then
                    		material.renderQueue = GeometryRendererQueue + 2    --2000+2
                   		end
                    end
                end
                table.insert(new_materials, occlusion_material)
                if nirvana_renderer then
                    nirvana_renderer.Materials = new_materials
                else
                    renderer.materials = new_materials
                end
                self.add_occlusion_material_list[renderer] = true
            end
        end
    end
end

function DrawPart:AddOcclusionMaterial(renderers, skip_particle_system)
    if renderers ~= nil then
		for i = 0, renderers.Length - 1 do
            local renderer = renderers[i]
            self:AddMaterial(renderer, ResPreload.role_occlusion, skip_particle_system)
        end
    end
end

function DrawPart:RemoveMaterial(renderer, occlusion_material, skip_particle_system)
	if self.add_occlusion_material_list[renderer] and nil ~= renderer and nil ~= renderer.gameObject and not IsNil(renderer.gameObject) then
        if not skip_particle_system or renderer:GetComponent(UnityParticleSystem) == nil then
        	local nirvana_renderer = renderer.gameObject:GetComponent(NirvanaRenderer)
            local materials

            if nirvana_renderer then
                materials = nirvana_renderer.Materials
            else
                materials = renderer.materials
            end

            if nil == materials then return end

            local new_materials = {}
            local len = materials.Length

            if len > 1 then
                for j = 0, len - 2 do
                	local material = materials[j]
                	if material then
                		table.insert(new_materials, material)
                    end
                end

                if nirvana_renderer then
                    nirvana_renderer.Materials = new_materials
                else
                    renderer.materials = new_materials
                end
                self.add_occlusion_material_list[renderer] = nil
            end
    	end
    end
end

function DrawPart:RemoveOcclusionMaterial(renderers, skip_particle_system)
    if renderers ~= nil then
        for i = 0, renderers.Length - 1 do
            local renderer = renderers[i]
            self:RemoveMaterial(renderer, ResPreload.role_occlusion, skip_particle_system)
        end
    end
end

function DrawPart:AddTransparentMaterial()
	self.is_use_transparent = true
	if nil == self.obj then
		return
	end

	self:AddOcclusionTransparentMaterial(self.obj:GetComponentsInChildren(UnitySkinnedMeshRenderer), false)
    self:AddOcclusionTransparentMaterial(self.obj:GetComponentsInChildren(UnityMeshRenderer), true)
end

function DrawPart:RemoveTransparentMaterial()
	self.is_use_transparent = false
	if nil == self.obj then
		return
	end

    self:RemoveOcclusionTransparentMaterial(self.obj:GetComponentsInChildren(UnitySkinnedMeshRenderer), false)
    self:RemoveOcclusionTransparentMaterial(self.obj:GetComponentsInChildren(UnityMeshRenderer), true)
end

function DrawPart:AddOcclusionTransparentMaterial(renderers, skip_particle_system)
	if renderers ~= nil then
		for i = 0, renderers.Length - 1 do
            local renderer = renderers[i]
            local nirvana_renderer = renderer.gameObject:GetComponent(NirvanaRenderer)
            local materials

            if nirvana_renderer then
                materials = nirvana_renderer.Materials
            else
                materials = renderer.materials
            end
            if nil == materials then return end

            if materials[0] then
            	self.transparent_material = materials[0]
            end

            materials[0] = ResPreload.role_transparent_occlusion
            renderer.materials = materials
        end
    end
end

function DrawPart:RemoveOcclusionTransparentMaterial(renderers, skip_particle_system)
    if renderers ~= nil then
        for i = 0, renderers.Length - 1 do
            local renderer = renderers[i]
            local nirvana_renderer = renderer.gameObject:GetComponent(NirvanaRenderer)
            local materials

            if nirvana_renderer then
                materials = nirvana_renderer.Materials
            else
                materials = renderer.materials
            end
            if nil == materials then return end

            if materials[0] and self.transparent_material then
            	materials[0] = self.transparent_material
            end

            renderer.materials = materials
        end
    end
end