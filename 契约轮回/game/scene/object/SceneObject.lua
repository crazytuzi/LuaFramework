-- 
-- @Author: LaoY
-- @Date:   2018-07-23 12:02:41
-- 场景模型基类

SceneObject = SceneObject or class("SceneObject")
local this = SceneObject

local math_abs = math.abs
local math_sin = math.sin
local math_cos = math.cos
local math_random = math.random

function SceneObject:ctor(object_id,...)
	self.object_type = 0
	self.abName = ""
	self.assetName = ""
	
	-- 这个要提前，self.parent_node 有可能为空
	-- 状态机相关
	self.machine = Machine()
	self:SetMachineDefaultState()
	
	self.parent_node = PreloadManager:GetInstance():GetSceneObject()
	-- if not self.parent_node then
	--     return
	-- end
	
	self.is_first_time_load_body = true
	self.transform_layer_is_self = nil

	self.parent_transform = self.parent_node.transform
	self.model_parent = self.parent_transform:Find("model_con")
	self.effect_parent = self.parent_transform:Find("skill_effect")
	self._default_res = self.parent_transform:Find("default")
	if self._default_res then
		SetVisible(self._default_res,false)
	end
	self.default_res = nil
	
	if self.effect_parent then
		SetLocalRotation(self.effect_parent,0,0,0)
		SetLocalPosition(self.effect_parent,0,0,0)
	end
	local scene_obj_layer = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.SceneOtherObj)
	if scene_obj_layer then
		self.parent_transform:SetParent(scene_obj_layer)
	else
		logWarn("SceneObj is nil........................")
	end
	
	self.action_list = {}
	self.last_state_name = nil
	self.cur_state_name = nil
	self.default_state = nil
	
	self.load_level = Constant.LoadResLevel.High
	
	-- 地块坐标 阻挡
	self.block_pos = { x = -1, y = -1 }
	self.last_block_pos = { x = -1, y = -1 }
	self.block_info = nil
	self.last_block_info = nil
	self.is_in_safe = false
	
	self.body_size = { width = 90, height = 160, length = 90 }
	self.rotate = { x = 0, y = 0 }
	self.rotateX = 0
	self.rotateY = 0
	self.rotateZ = 0
	self.angele = 0
	
	self.scale = 1
	-- self.orientation_angle
	self.direction_angle = 0
	self.gameObject = nil
	self.transform = nil
	self.animator = nil
	
	self.direction = Vector2(0, 0)
	self.curr_rotate = Vector3(0, 0, 0)
	
	self.is_attacking = false                -- 是否在攻击中
	self.last_attack_time = 0
	
	self.is_death = false                    -- 是否死亡
	
	-- 骨骼相关
	-- 骨骼节点(body上的)列表
	self.boneNode_list = {}
	-- 骨骼资源列表
	self.boneRes_list = {}
	-- 骨骼对象(资源加载生成的)列表
	self.boneObject_list = {}
	
	self.move_speed = SceneConstant.ObjectSpeed
	
	self.position = { x = 0, y = 0, z = self:GetDepth(0) }
	self.server_pos = { x = 0, y = 0 }
	self.body_pos = { x = 0, y = 0 }
	self:SetBodyPosition(0, 0)
	
	if self.model_parent then
		self:SetRotateX(SceneConstant.SceneRotate.x)
		self:SetRotateZ(SceneConstant.SceneRotate.z)
	end
	
	self.material_shader_list = {}

	self.change_material_list = {}
		
	self.alpha = 1
	
	-- 保存节点下面的特效
	-- 用于切换形象等
	self.target_effect_list = {}
	
	self:CreateNameContainer()
	self:InitData(object_id,...)
	self:CreateShadowImage()
	self:AddEvent()
end

-- 需要影子派生类的重写
function SceneObject:CreateShadowImage()
	-- self.shadow_image = ShadowImage()
end

function SceneObject:CreateNameContainer()
    if self.__cname == "Monster" then
        self.name_container = MonsterText()    -- 怪物名字容器
    elseif self.__cname == "Role" or self.__cname == "MainRole" or self.__cname == "Robot" then
        self.name_container = RoleText()    -- 角色名字容器
    else
        self.name_container = SceneObjectText()    -- npc及其它名字容器
    end

    self:SetNameColor()
end

function SceneObject:InitData(object_id)
	object_id = object_id or self.object_id
	self.object_id = object_id
	if not self.object_id then
		return
	end
	self.object_info = SceneManager:GetInstance():GetObjectInfo(object_id)
	
	if self.object_info and self.object_info.name then
		self.parent_node.name = self.object_info.name
	end
	
	if not self.object_info or not self.object_info.coord then
	else
		local pos = self.object_info.coord
		self:SetPosition(pos.x, pos.y)
		self.position = { x = pos.x, y = pos.y, z = self:GetDepth(pos.y) }
	end

	self.server_pos.x = self.position.x
	self.server_pos.y = self.position.y
	
	if self.name_container then
		if self.object_info and self.object_info.name then
			self.name_container:SetName(self.object_info.name)
		end
	end
	
	if self.object_info.dest and (self.object_info.dest.x ~= self.position.x or self.object_info.dest.y ~= self.position.y) then
		-- self:SetMovePosition(self.object_info.dest, self.object_info.dir)
		self:SetServerPosition(self.object_info.dest, self.object_info.dir)
	end
end

function SceneObject:dctor()
	lua_resMgr:ClearClass(self)
	self:ClearFromScene()
	
	self:StopSlip()
	self:StopBeHitTime()
	
	self.target_effect_list = {}

	self:ClearNodeEffect()
	
	if self.machine then
		self.machine:destroy()
		self.machine = nil
	end
	
	if self.name_container then
		self.name_container:destroy()
		self.name_container = nil
	end
	
	if self.shadow_image then
		self.shadow_image:destroy()
		self.shadow_image = nil
	end
	
	if self.object_info then
		self.object_info:destroy()
		self.object_info = nil
	end
	
	self:ClearBoneNode()
	
	if self.gameObject then
		self:ResetAlpha()
		if not poolMgr:AddGameObject(self.abName, self.assetName, self.gameObject) then
			self:BeforeDestroyGameobject()
			destroy(self.gameObject)
		end
		self.gameObject = nil
	end
	self.gpu_player = nil
	self.animator = nil
	self.transform = nil
	
	self.material_shader_list = {}
	
	if self.advance_container then
		self.advance_container:destroy();
	end
	self.advance_container = nil;

	self.body_skin_renderer = nil
	self.default_texture = nil
	self.default_shader = nil
	self.cur_shader = nil

	self._default_res = nil
	self.default_res = nil

	self:StopDefalutResTime()

	if self.parent_node then
		if (self.__cname ~= "Role" and self.__cname ~= "MainRole") and PreloadManager:GetInstance():AddSceneObject(self.parent_node) then
			-- SetRotate(self.model_parent,0,0,0)
			-- SetRotation(self.model_parent,0,0,0)
			-- self.model_parent.rotation = Quaternion(0,0,0,0)
			SetLocalRotation(self.model_parent, 0, 0, 0)
		else
			destroy(self.parent_node)
		end
		self.parent_node = nil
	end
	self.parent_transform = nil
	self.model_parent = nil
	self.effect_parent = nil
end

function SceneObject:BeforeDestroyGameobject()
	if self.default_mat then
		destroy(self.default_mat)
	end
	self.default_mat = nil
	for mat,v in pairs(self.change_material_list) do
		destroy(mat)
	end
	self.change_material_list = nil
end

function SceneObject:ClearFromScene()
	self:RemoveDependObject()
	SceneManager:GetInstance():RemoveObject(self.object_id)
	EffectManager:GetInstance():RemoveAllSceneEffect(self)
end

-- over write
function SceneObject:AddEvent()
	
end

function SceneObject:SetTargetEffect(effect_name, is_loop, parent, pos, scale, speed)
	pos = pos or Vector3(0, 0, 0)
	scale = scale or 1
	speed = speed or 1
	local tab = {
		pos = pos, scale = scale, speed = speed, is_loop = is_loop,
	}
	parent = parent or self.effect_parent
	local effect = SceneTargetEffect(parent, effect_name, EffectManager.SceneEffectType.Target, self)
	effect:SetConfig(tab)
	if not self.is_loaded and parent ~= self.effect_parent then
		self:SaveTargetEffect()
	end
	return effect
end

-- 切换身体前，需要保存特效的引用
function SceneObject:SaveTargetEffect()
	local effect_list = EffectManager:GetInstance():GetTargetEffectList(self)
	if not table.isempty(effect_list) then
		self.target_effect_list = {}
		
		-- 目前只需要检查 transform 和 root下面的特效
		local check_list = {
			SceneConstant.BoneNode.Root,
			SceneConstant.BoneNode.Transform,
		}
		local check_node_map = {}
		for k, bone_name in pairs(check_list) do
			local node = self:GetBoneNode(bone_name)
			if node then
				check_node_map[node] = bone_name
			end
		end
		for k, effect in pairs(effect_list) do
			if effect.__cname == "SceneTargetEffect" then
				if check_node_map[effect.parent] then
					self.target_effect_list[#self.target_effect_list + 1] = { bone_name = check_node_map[effect.parent], effect = effect }
				end
			end
		end
	end
	
	-- 坐骑忽略，要特殊处理
	self:ClearBoneNode(SceneConstant.BoneNode.Ride_Root)
	-- self.boneRes_list = {}
	-- self.boneObject_list = {}
	self.boneNode_list = {}
end

-- 切换身体后，前一个身体用的特效要重新挂载
function SceneObject:ResetTargetEffect()
	-- if self.__cname == "Pet" then
	--     Yzprint('--LaoY SceneObject.lua,line 271--',data)
	--     for k,v in pairs(self.target_effect_list) do
	--         Yzprint('--LaoY SceneObject.lua,line 274--',v.bone_name,v.effect and v.effect.is_dctored)
	--     end
	--     traceback()
	-- end
	for k, info in pairs(self.target_effect_list) do
		local node = self:GetBoneNode(info.bone_name)
		local effect = info.effect
		if node and not effect.is_dctored then
			effect:ResetParent(node)
		end
	end
	self.target_effect_list = {}
end

-- 创建身体模型，也就是衣服层,这个特殊处理
-- 其他骨骼节点用 SetBoneResource
function SceneObject:CreateBodyModel(abName, assetName,is_inore_animator)
	if not abName or not assetName or #abName == 0 or #assetName == 0 then
		local str = string.format("abName = %s or assetName = %s Non-existent", abName or "", assetName or "")
		logWarn(str)
		return
	end
	if abName == self.abName and assetName == self.assetName then
		return
	end
	local last_abName, last_assetName = self.abName, self.assetName
	local function callback(objs, is_cache)
		if self.is_dctored or not objs or not objs[0] then
			return
		end
		local new_gameObject = objs[0]
		
		local new_call_back = function(obj)
			if self.is_dctored then
				if not poolMgr:AddGameObject(abName, assetName, obj) then
					destroy(obj)
				end
				return
			end

			self:StopDefalutResTime()
			if self.default_res then
				SetVisible(self.default_res,false)
			end

			if self.gameObject then
				self:ResetAlpha()
				self:SaveTargetEffect()
				if abName == self.abName then
					-- self:ClearBoneNode(SceneConstant.BoneNode.Ride_Root)
					self:RemoveDependObject()
					if not poolMgr:AddGameObject(self.last_abName, self.last_assetName, self.gameObject) then
						destroy(self.gameObject)
					end
					self.gameObject = nil
					if self.RemoveCache then
						self:RemoveCache()
					end
				else
					if not poolMgr:AddGameObject(abName, assetName, obj) then
						destroy(obj)
					end
					return
				end
			end
			self.last_abName = abName
			self.last_assetName = assetName
			self.is_loaded = true
			self.gameObject = obj;--newObject(new_gameObject)

			-- 设置父节点属性
			-- SetLocalPosition(self.parent_transform,0,0,0)
			SetLocalScale(self.parent_transform, 1)
			SetLocalRotation(self.parent_transform)
			
			-- 设置自己的属性
			self.transform = self.gameObject.transform
			if is_cache then
				SetChildLayer(self.transform, LayerManager.BuiltinLayer.Default)
			end
			
			local horse_info = self.boneObject_list[SceneConstant.BoneNode.Ride_Root]
			local horse_bone
			if horse_info then
				local boneName = "ride"
				horse_bone = GetComponentChildByName(horse_info.transform, boneName)
			end

			if horse_bone then
				self:SetMachineDefaultState(SceneConstant.ActionName.ride)
				self.transform:SetParent(horse_bone)
			else
				self:SetMachineDefaultState(SceneConstant.ActionName.idle)
				self.transform:SetParent(self.model_parent)
			end

			-- if self.transform_layer_is_self == nil then
			-- 	self.transform_layer_is_self = true
			-- end

			self:UpdateVisible()

			self.animator = self.gameObject:GetComponent('Animator')
			if self.animator then
				self.animator.speed = 1
				self.animator.cullingMode = UnityEngine.AnimatorCullingMode.AlwaysAnimate
			end
			self.gpu_player = self.gameObject:GetComponent('GPUSkinningPlayerMono')

			if not self.animator and not self.gpu_player and not is_inore_animator then
				if AppConfig.Debug then
					logError("该模型没有animator，资源ID:",self.abName)
				end
			end
			
			self:SetScale(self.scale)
			SetLocalPosition(self.transform, 0, 0, 0)
			SetLocalRotation(self.transform)
			
			-- SetVisible(self.transform, true)
			
			self.body_skin_renderer = self.gameObject:GetComponentInChildren(typeof(UnityEngine.SkinnedMeshRenderer))
			if self.body_skin_renderer then
				-- self.default_texture = self.body_skin_renderer.material.mainTexture
				self.default_mat = self.body_skin_renderer.material
				self.default_texture = GetMaterialTexture(self.default_mat)
				self.default_shader = self.default_mat.shader
				self.cur_shader = self.default_shader
				-- if self.__cname == "MainRole" then
				--  Yzprint('--LaoY SceneObject.lua,line 174-- data=',self.default_texture)
				-- end
			end
			--self:BeHit(0)
			
			local x, y, z = GetRenderBoundsSize(self.body_skin_renderer)
			if x then
				self.body_size.width = x * SceneConstant.PixelsPerUnit
			end
			if y then
				self.body_size.height = y * SceneConstant.PixelsPerUnit
			end
			if z then
				self.body_size.length = z * SceneConstant.PixelsPerUnit
			end
			-- self.
			
			if self.is_lock ~= nil then
				self:BeLock(self.is_lock)
			end
			
			-- self.model_parent:Rotate(Vector3(-30,0,0))
			
			-- self:SetRotateX(SceneConstant.SceneRotate.x)
			-- self:SetRotateZ(SceneConstant.SceneRotate.z)
			
			-- 强制性设置一次坐标 触发某些地块的效果
			self.block_pos.x = -1
			self.block_pos.y = -1
			self.last_shadow_state = nil
			self:SetPosition(self.position.x, self.position.y)
			
			if not self.move_pos then
				local angle = SceneConstant.SceneRotate.y
				if self.direction_angle then
					angle = self.direction_angle or angle
				elseif self.object_info and self.object_info.dir then
					angle = self.object_info.dir
				end
				self:SetRotateY(angle)
			end

			if self.cur_state_name ~= nil then
				self:OnEnterMachineState(self.cur_state_name)
			elseif self.default_state then
				self:ChangeMachineState(self.default_state,true)
			else
				-- 初始化完，切到默认状态
				self:ChangeToMachineDefalutState()
			end
			if self.LoadBodyCallBack then
				self:LoadBodyCallBack()
			end
			if self.__cname ~= "MainRole" and self.object_info and self.object_info.dest and (self.object_info.dest.x ~= self.position.x or self.object_info.dest.y ~= self.position.y) then
				self:SetServerPosition(self.object_info.dest, self.object_info.dir)
			end
			
			self:ResetTargetEffect()

			-- self:ShowBody(self.isShowBody);
			SetGameObjectActive(self.parent_transform, self.isShowBody);
			
			if self.is_first_time_load_body then
				GlobalEvent:Brocast(EventName.NewSceneObject, self)
				if self.object_info then
					self.object_info:InitBuff()
				end
			end
			self.is_first_time_load_body = false

			self:ClearNodeEffect()
			self:LoadNodeEffect()
		end
		
		if is_cache then
			local function step()
				if self.object_info then
					-- Yzprint('--LaoY SceneObject.lua,line 413--', self.object_info.name)
				end
				new_call_back(new_gameObject)
			end
			GlobalSchedule:StartOnce(step, 0.03)
		else
			lua_resMgr:GetPrefab("", "", new_gameObject, new_call_back);
		end
	end
	self.is_loaded = false
	self.abName, self.assetName = abName, assetName
	lua_resMgr:LoadPrefab(self, abName, assetName, callback, nil, self.load_level, true)

	self:StartDefalutResTime()

	return true
end

function SceneObject:ClearNodeEffect()
	if not self.model_effect_list then
		return
	end
	for k,v in pairs(self.model_effect_list) do
		v:destroy()
	end
	self.model_effect_list = {}
end

function SceneObject:LoadNodeEffect()
	self.model_effect_list = self.model_effect_list or {}
	local effect_list_cf = ModelEffectConfig[self.assetName]
	if not effect_list_cf then
		return
	end
	for node_name,effect_list in pairs(effect_list_cf) do
		for k,cf in pairs(effect_list) do
			local node = GetComponentChildByName(self.transform,node_name)
			if node then
				local effect = ModelEffect(node,cf.name,cf,self,false)
				self.model_effect_list[#self.model_effect_list+1] = effect
			end
		end
	end
end

function SceneObject:StartDefalutResTime()
	self:StopDefalutResTime()
	local function step()
		self:StopDefalutResTime()
		if self.default_res then
			SetVisible(self.default_res,true)
		end
	end
	self.defalut_time_id = GlobalSchedule:StartOnce(step,1.0)
end

function SceneObject:StopDefalutResTime()
	if self.defalut_time_id then
		GlobalSchedule:Stop(self.defalut_time_id)
		self.defalut_time_id = nil
	end
end

function SceneObject:ClearBoneNode(ingore_boneName)
	for boneName, info in pairs(self.boneObject_list) do
		if boneName ~= ingore_boneName then
			local res = self.boneRes_list[boneName]
			-- 添加到缓存
			if res then
				if not poolMgr:AddGameObject(res.abName, res.assetName, info.gameObject) then
					destroy(info.gameObject)
				else
					self:SetAlpha(1.0, info.gameObject)
				end
			else
				if info.gameObject then
					destroy(info.gameObject)
				end
			end
			self.boneObject_list[boneName] = nil
			self.boneRes_list[boneName] = nil
		end
	end
	-- self.boneObject_list = {}
	-- self.boneRes_list = {}
end

--[[
@author LaoY
@des    获取骨骼节点 放在C#获取，效率快4倍左右 再做个缓存
@param1 boneName string
@return Component
--]]
function SceneObject:GetBoneNode(boneName)
	-- GetComponentChildByName内部已经有判断
	-- if not self.transform then
	--  return
	-- end
	if not self.transform then
		return
	end
	if boneName == SceneConstant.BoneNode.Transform then
		return self.transform
	end
	
	if boneName == SceneConstant.BoneNode.EffectRoot then
		return self.effect_parent
	end
	
	if tostring(self.boneNode_list[boneName]) == "null" then
		self.boneNode_list[boneName] = nil
	end
	
	if not self.boneNode_list[boneName] then
		self.boneNode_list[boneName] = self.transform:Find(boneName)
		if not self.boneNode_list[boneName] then
			self.boneNode_list[boneName] = GetComponentChildByName(self.transform, boneName)
		end
	end
	
	if tostring(self.boneNode_list[boneName]) == "null" then
		self.boneNode_list[boneName] = nil
	end
	return self.boneNode_list[boneName]
end

function SceneObject:SetBoneVisible(boneName, flag)
	local bone = self:GetBoneNode(boneName)
	if bone then
		SetVisible(bone, flag)
	end
end

--[[
@author LaoY
@des    设置颜色
@param1 r,g,b,a 0-255
--]]
function SceneObject:SetColor(r, g, b, a)
	if not self.body_skin_renderer or not self.default_mat then
		return
	end
	if self.cur_shader.name ~= ShaderManager.ShaderNameList.Alpha_shader then
		local sd = ShaderManager:GetInstance():GetShaderByName(ShaderManager.ShaderNameList.Alpha_shader)
		if sd then
			self.default_mat.shader = sd
			self.cur_shader = sd
		end
	end
	SetColor(self.default_mat, r, g, b, a)
end

function SceneObject:GetSkinnedMeshRenderer(gameObject)
	gameObject = gameObject or self.gameObject
	if not gameObject then
		return {Length = 0}
	end
	return gameObject:GetComponentsInChildren(typeof(UnityEngine.SkinnedMeshRenderer))
end

--[[
@author LaoY
@des    设置透明度
@param1 a 0-1
--]]
function SceneObject:SetAlpha(a, gameObject)
	if not self.body_skin_renderer or not self.default_mat then
		return
	end

	-- if self.cur_shader.name ~= ShaderManager.ShaderNameList.Alpha_shader then
	--  local sd = ShaderManager:GetInstance():GetShaderByName(ShaderManager.ShaderNameList.Alpha_shader)
	--  if sd then
	--      self.default_mat.shader = sd
	--      self.cur_shader = sd
	--  end
	-- end
	
	--local outline_shader = ShaderManager:GetInstance():GetShaderByName(ShaderManager.ShaderNameList.Alpha_shader)
	
	local object = gameObject or self.gameObject
	if object == self.gameObject then
		if self.alpha == a then
			return
		end
		self.alpha = a
	end

	local outline_shader = ShaderManager:GetInstance():FindShaderByName("Custom/Outline2")
	if not object then
		return
	end
	-- local renders = object:GetComponentsInChildren(typeof(UnityEngine.SkinnedMeshRenderer))
	local renders = self:GetSkinnedMeshRenderer(object)

	Yzprint('--LaoY SceneObject.lua,line 719--',renders.Length)

	for i = 0, renders.Length - 1 do
		local is_body_mat = renders[i] == self.body_skin_renderer
		local material = renders[i].material
		Yzprint('--LaoY SceneObject.lua,line 724--',renders[i].name)
		-- self.change_material_list[material] = true
		if a < 1 then
			if is_body_mat then
				self.cur_shader = outline_shader
			end
			if not self.material_shader_list[material] then
				self.material_shader_list[material] = material.shader
			end
			material.shader = outline_shader
			--SetColor(material, 255, 255, 255, a * 255)
			---已经将如下值做为Shader的默认值，需要的时候再启用
			--SetMaterialColor(material,"_OutlineColor",0,255,0,255) ---描边颜色
			--SetMaterialFloat(material,"_OutlineWidth",0.036) ---描边宽度
			--SetMaterialFloat(material,"_BodyAlpha",0.45) ---角色透明度
		else
			if is_body_mat then
				self.cur_shader = self.default_shader
				material.shader = self.default_shader
			else
				-- material.shader = ShaderManager:GetInstance():GetShaderByName(ShaderManager.ShaderNameList.Default)
				material.shader = self.material_shader_list[material] or ShaderManager:GetInstance():GetShaderByName(ShaderManager.ShaderNameList.Default)
			end
			SetColor(material, 255, 255, 255, a * 255)
		end
	end
end

function SceneObject:GetBoneGameObject(boneName)
	if not self.boneObject_list[boneName] or not self.boneObject_list[boneName].gameObject then
		return nil
	end
	return self.boneObject_list[boneName].gameObject
end

function SceneObject:GetBoneTransform(boneName)
	if not self.boneObject_list[boneName] or not self.boneObject_list[boneName].transform then
		return nil
	end
	return self.boneObject_list[boneName].transform
end

-- over write
function SceneObject:SetNameColor()
	if self.name_container then
		self.name_container:SetColor(Color(234, 234, 50), Color(188, 0, 0))
	end
end

--[[
@author LaoY
@des    获取类型
--]]
function SceneObject:GetType()
	return self.object_type
end

--[[
@author LaoY
@des    按照一个方向移动
@param1 vec Vector2 方向向量
@return number
--]]
function SceneObject:SetDirection(vec, is_move)
	-- 后期要优化
	-- if not self:IsCanSwitchToMove() then
	--  self.move_pos = nil
	--  self.move_state = false
	--  return
	-- end
	if not vec then
		local action_name = SceneConstant.ActionName.idle
		if self:ChangeMachineState(action_name) then
			self.move_state = false
		end
	else
		local can_move = is_move == nil and true or is_move
		local action_name = SceneConstant.ActionName.run
		local dis = Vector2.SqrMagnitude(vec)
		if can_move and (self:IsRunning() or self:ChangeMachineState(action_name)) then
			self.move_state = true
			if dis > 0 then
				local angle = Vector2.GetAngle(vec)
				self:SetRotateY(angle, vec, nil, self.move_state)
			end
		elseif is_move == false then
			self.move_state = false
			if dis > 0 then
				local angle = Vector2.GetAngle(vec)
				self:SetRotateY(angle, vec, nil, self.move_state)
			end
		else
			self.move_state = false
			-- self.move_pos = nil
		end
	end
end

--[[
@author LaoY
@des    同步服务器坐标
--]]
function SceneObject:SetServerPosition(pos, dir, state)
	if state == SceneConstant.SynchronousType.Stop then
		local distance = Vector2.Distance(pos, self.position)
		if distance <= self.move_speed * 0.08 then
			self:SetMovePosition()
			self:SetPosition(pos.x, pos.y)
			self:SetRotateY(dir, nil, nil, false)
			return
		end
	end
	self:SetServerPosInfo(pos,state)
	self:SetMovePosition(pos, dir, state)
end

function SceneObject:SetServerPosInfo(pos,state)
	if self.server_pos and Vector2.DistanceNotSqrt(self.server_pos,pos) <=1e-5 then
		return
	end
	self.server_pos.x = pos.x
	self.server_pos.y = pos.y
	self.server_move_state = state
	self.server_pos_mask = OperationManager:GetInstance():GetMask(pos.x,pos.y)
	self.server_pos_is_block = self.server_pos_mask == SceneConstant.MaskBitList.Block
end

--[[
@author LaoY
@des    移动到点
@param1 pos     Vector2 移动到具体的点
@param2 dir     方向
@param3 state   行走的状态
--]]
function SceneObject:SetMovePosition(pos, dir, state)
	if pos then
		local vec = GetVector(self.position, pos)
		-- local angle = Vector2.GetAngle(vec)
		-- logWarn(self.object_info.name,"SetMovePosition",dir,math.getAngle(angle),Vector2.DistanceNotSqrt(pos, self.position),pos.x,pos.y,self.position.x,self.position.y)
		self.move_pos = { x = pos.x, y = pos.y }
		self.move_dir = dir
		self.server_move_state = state
		self:SetDirection(vec)
		if Vector2.DistanceNotSqrt(pos, self.position) <= 0 and self.move_dir then
			self:SetRotateY(self.move_dir, nil, nil)
		end
	else
		if self.move_pos then
			self.move_pos = nil
			self:SetDirection()
			if self.move_dir then
				self:SetRotateY(self.move_dir, nil, nil)
			end
			self.move_dir = nil
		end
	end
end

--[[
@author LaoY
@des    设置Y轴角度
@param1 rotateY         number  Y轴旋转角度
@param2 is_transition   bool    是否要有过渡action
--]]
function SceneObject:SetRotateY(rotateY, vec, is_rotating, is_transition)
	rotateY = math.getAngle(rotateY)
	
	if not is_rotating then
		local radian = rotateY / 180 * math.pi
		self.angele = rotateY
		self.direction.x = vec and vec.x or math_sin(radian)
		self.direction.y = vec and vec.y or math_cos(radian)
		self.direction:SetNormalize()
	end

	if not is_transition then
		self.all_rotate_off = nil
	else
		local curr_rotate_off = rotateY - self.direction_angle
		if not is_rotating and self.__cname == "Role" then
			if curr_rotate_off == 180 or curr_rotate_off == -180 then
				-- Yzprint('--LaoY SceneObject.lua,line 495-- data=', rotateY, self.direction_angle, curr_rotate_off)
			end
			-- Yzprint('--LaoY SceneObject.lua,line 497-- data=',rotateY,self.direction_angle,curr_rotate_off)
			-- Notify.ShowText(rotateY,self.direction_angle,curr_rotate_off)
		end
		if curr_rotate_off > 180 then
			curr_rotate_off = curr_rotate_off - 360
		elseif curr_rotate_off < -180 then
			curr_rotate_off = 360 + curr_rotate_off
		end
		if math.abs(curr_rotate_off) > 10 and not is_rotating then
			--转角大于一定角度 就要分帧旋转
			self.all_rotate_off = curr_rotate_off
			return
		elseif not is_rotating then
			self.all_rotate_off = nil
		end
	end
	
	self.direction_angle = rotateY
	
	local y_off = SceneConstant.SceneRotateOffset * math_sin(math.angle2radian((90 - rotateY) * SceneConstant.SceneRotateRate))
	local curRotate = 360 + rotateY
	if self.rotateY == curRotate then
		return
	end
	
	if self.model_parent then
		self.curr_rotate.y = curRotate - self.rotateY
		self.model_parent:Rotate(self.curr_rotate)
	end
	self.rotateY = curRotate
end

function SceneObject:AddRotateY(rotateY, is_rotating)
	self:SetRotateY(self.direction_angle - rotateY, nil, is_rotating, true)
end

function SceneObject:SetRotateX(rotateX)
	local curRotate = 360 + rotateX
	if self.model_parent then
		local x = curRotate - self.rotateX
		self.model_parent:Rotate(Vector3(x, 0, 0))
	end
	self.rotateX = curRotate
end

function SceneObject:SetRotateZ(rotateZ)
	local curRotate = 360 + rotateZ
	if self.model_parent then
		local z = curRotate - self.rotateZ
		self.model_parent:Rotate(Vector3(0, 0, z))
	end
	self.rotateZ = curRotate
end

function SceneObject:GetRotate()
	return { x = self.rotateX, y = self.rotateY, z = self.rotateZ }
end

function SceneObject:GetBodyHeight()
	return self.body_size.height
end

function SceneObject:GetBodyWidth()
	return self.body_size.width
end

function SceneObject:GetVolume()
	if not self.body_size.volume then
		self.body_size.volume = 0.5 * math.sqrt(self.body_size.height * self.body_size.height + self.body_size.width * self.body_size.width)
	end
	return self.body_size.volume
end

--[[
@author LaoY
@des    设置模型的全局坐标
@param1 x   number
@param2 y   number
--]]
function SceneObject:SetPosition(x, y)
	-- Yzprint('--LaoY SceneObject.lua,line 379-- x,y=',x,y)
	-- traceback()
	
	local bo, block_value = self:CheckNextBlock(x, y)
	if not bo then
		return false
	end
	
	self.last_block_pos.x = self.block_pos.x
	self.last_block_pos.y = self.block_pos.y
	local block_x, block_y = SceneManager:GetInstance():GetBlockPos(x, y)
	self.block_pos.x = block_x
	self.block_pos.y = block_y

	if self.block_info ~= block_value then
		self.is_in_safe = self:IsCurBlockContain(SceneConstant.MaskBitList.Safe,block_value)
	end

	if MapManager:GetInstance().is_loaded and block_value then
		self.last_block_info = self.block_info
		self.block_info = block_value
	end

	self.position.x = x
	self.position.y = y
	self.position.z = self:GetDepth(y)
	-- if self.is_loaded then
	local world_pos = { x = self.position.x / SceneConstant.PixelsPerUnit, y = self.position.y / SceneConstant.PixelsPerUnit }
	SetGlobalPosition(self.parent_transform, world_pos.x, world_pos.y, self.position.z)
	self:SetNameContainerPos()
	self:SetAdvanceItemPos();
	self:SetShadowImagePos()
	return true
	-- end
end

function SceneObject:IsInSafe()
    return self.is_in_safe
end

function SceneObject:SetNameContainerPos()
	if self.name_container then
		local world_pos = { x = self.position.x / SceneConstant.PixelsPerUnit, y = self.position.y / SceneConstant.PixelsPerUnit }
		local body_height = self:GetBodyHeight() + (self.body_pos.y <= 0 and 0 or self.body_pos.y + 30)
		self.name_container:SetGlobalPosition(world_pos.x, world_pos.y + body_height / SceneConstant.PixelsPerUnit, self.position.z * 1.1)
	end
end

function SceneObject:SetShadowImagePos()
	if self.shadow_image then
		local world_pos = { x = self.position.x / SceneConstant.PixelsPerUnit, y = self.position.y / SceneConstant.PixelsPerUnit }
		local z = LayerManager:GetInstance():GetSceneObjectDepth(MapManager:GetInstance().map_pixels_height - 10)
		self.shadow_image:SetGlobalPosition(world_pos.x, world_pos.y, z)
	end
end

function SceneObject:GetPosition()
	return self.position
end

function SceneObject:SetScale(scale)
	scale = scale or 1
	self.scale = scale
	if self.transform then
		SetLocalScale(self.transform, scale, scale, scale)
	end
end

function SceneObject:CheckNextBlock(x, y)
	local block_x, block_y = SceneManager:GetInstance():GetBlockPos(x, y)
	local block_value
	if self.block_pos.x ~= block_x or self.block_pos.y ~= block_y then
		block_value = MapManager:GetInstance():GetMask(block_x, block_y)
		local cur_block_is_shadow = self:IsCurBlockContain(SceneConstant.MaskBitList.Shadow, block_value)
		self:IsShadow(cur_block_is_shadow)
		if OperationManager:GetInstance():IsBlock(x, y) and not self:IsCorssBlock() then
			return false, block_value
		end
	end
	return true, block_value
end

function SceneObject:ResetAlpha()
	if not self.last_shadow_state then
		return
	end
	self:SetAlpha(1.0)
end

function SceneObject:IsShadow(flag)
	if not self.gameObject then
		return
	end
	if self.last_shadow_state == flag then
		return
	end
	self.last_shadow_state = flag
	local alpha = 1.0
	if flag then
		alpha = 0.7
	end
	if self.shadow_image then
		self.shadow_image:SetAlpha(alpha)
	end
	self:SetAlpha(alpha)
end

function SceneObject:IsCurBlockContain(state, block_info)
	if not self.block_info and not block_info then
		return false
	end
	return BitState.StaticContain(block_info or self.block_info, state)
end

function SceneObject:IsLastBlockContain(state)
	if not self.last_block_info then
		return false
	end
	return BitState.StaticContain(self.last_block_info, state)
end

function SceneObject:SetBodyPosition(x, y)
	self.body_pos.x = x
	self.body_pos.y = y
	SetLocalPosition(self.model_parent, x / SceneConstant.PixelsPerUnit, y / SceneConstant.PixelsPerUnit)
end

function SceneObject:GetBodyPosition()
	return self.body_pos
end

function SceneObject:IsCorssBlock()
	return false
end

--[[
@author LaoY
@des    根据Y轴坐标值 计算深度
@param1 y number unity世界坐标
@return number
--]]
function SceneObject:GetDepth(y)
	return LayerManager:GetInstance():GetSceneObjectDepth(y or 0)
end

function SceneObject:GetSpeed()
	return self.move_speed
end

--[[
@author LaoY
@des    进行攻击
--]]
function SceneObject:PlayAttack(skill_vo)
	local action_name = skill_vo.action_name
	-- 空动作不要处理
	if action_name == "empty" or not action_name then
		return
	end
	local action = self.action_list[action_name]
	if not action then
		-- logWarn(action_name .. " is not Register !!!!!!")
		if AppConfig.Debug then
			logError("战斗表现配置了没有处理的动作,",action_name)
		end
		return false
	end
	if self.cur_state_name == action_name then
		-- Notify.ShowText("11111111111111111111")
		self:ChangeToMachineDefalutState()
	end
	if self:ChangeMachineState(action_name, true) then
		-- 必须要切换成功才给状态赋值最新信息
		-- 如果两个技能动作相同，可以在退出上一个技能状态回调做处理，两个技能处理可以不受影响
		action.skill_vo = skill_vo
		if skill_vo.action_time then
			action.action_time = skill_vo.action_time
		end
		action.action_call_back = handler(self, self.AttackCallBack)
		return true
	end
	return false
end

--[[
@author LaoY
@over write 人物等可以重载，连续播放攻击
@des    攻击动作播放完后，默认切换到待机动作。
--]]
function SceneObject:AttackCallBack()
	if self.move_pos then
		return false
	end
	local is_fight = FightManager:GetInstance():CheckWaitAttack(self.object_id)
	if not is_fight then
		self:ChangeToMachineDefalutState()
	end
	return is_fight
end

function SceneObject:CheckWaitAttackCombo(skill_id)
	if self.move_pos then
		return false
	end
	local is_fight = FightManager:GetInstance():CheckWaitAttackCombo(self.object_id, skill_id)
	return is_fight
end

function SceneObject:Revive(force)
	if not force and not self:IsDeath() then
		return
	end
	self.is_death = false
	self:ChangeToMachineDefalutState()
	if self.animator then
		self.animator.speed = 1
	end
	self.object_info:Revive()
end

function SceneObject:RunOnEnter()
	self.is_runing = true
end

function SceneObject:OnExit()
	self.is_runing = false
end

function SceneObject:RunOnExit()
	self.move_pos_last_dis = nil
	self.move_pos = nil
	self.is_runing = false
end

function SceneObject:IsRunning()
	return self.is_runing
end

-- 不要用这个接口来处理血量相关
-- 侦听 object_info.hp的变化
function SceneObject:SetHp(hp, message_time)
	if self.is_death then
		return
	end
	if not self.object_info then
		return
	end
	self.object_info:SetHp(hp, message_time)
end

function SceneObject:PlayDeath(attack_object)
	if self.is_death then
		return false
	end
	if not self.is_loaded then
		-- self:destroy()
		return
	end
	self:SetHp(0)
	self:ChangeMachineState(SceneConstant.ActionName.death, true)
	return true
end

function SceneObject:DeathOnEnter()
	self.is_death = true
end

function SceneObject:DeathOnExit()
	if self.animator then
		self.animator.speed = 0
	end
	FightManager:GetInstance():RemoveObject(self.object_id)
end

function SceneObject:UpdateRunState(action_name, delta_time)
	if self.move_state then
		local x, y
		local cur_dis
		if self.move_pos then
			cur_dis = Vector2.DistanceNotSqrt(self.move_pos, self.position)
		end
		
		self.move_pos_last_dis = cur_dis
		-- local move_dir = Vector2(self.direction.x, self.direction.y)
		local move_speed = self.move_speed * GetSpeedRate(self.direction)
		if self.all_rotate_off then
			move_speed = move_speed * 1
		end
		x = self.position.x + self.direction.x * move_speed * delta_time
		y = self.position.y + self.direction.y * move_speed * delta_time
		-- 表示超过了
		if self.move_pos and Vector2.DistanceNotSqrt(Vector2(x, y), self.position) >= cur_dis then
			x = self.move_pos.x
			y = self.move_pos.y
			
			local is_need_change = false
			if not self.all_rotate_off then
				if self.__cname == "MainRole" then
					if not OperationManager:GetInstance():IsAutoWay() then
						is_need_change = true
					end
				else
					if self.server_move_state == nil or self.server_move_state == SceneConstant.SynchronousType.Move or
						self.server_move_state == SceneConstant.SynchronousType.Stop then
						is_need_change = true
					end
				end
			end
			
			if is_need_change then
				self:SetMovePosition()
			end
		end
		self:SetPosition(x, y)
	else
		local is_need_change = false
		if not self.all_rotate_off then
			if self.__cname == "MainRole" then
				if not OperationManager:GetInstance():IsAutoWay() then
					is_need_change = true
				end
			else
				if self.server_move_state == nil or self.server_move_state == SceneConstant.SynchronousType.Move or
					self.server_move_state == SceneConstant.SynchronousType.Stop then
					is_need_change = true
				end
			end
		end
		
		if is_need_change then
			self:ChangeToMachineDefalutState()
		end
	end
end

function SceneObject:AttackOnEnter(state_name)
	self.is_attacking = true
	local action = self.action_list[state_name]
	action.check_combo_skill = false
end

function SceneObject:UpdateAttack(state_name, delta_time)
	
end

function SceneObject:AttackOnExit(state_name)
	self.is_attacking = false
	local action = self.action_list[state_name]
	-- 如果攻击是施法前摇给打断的，要去除该技能的效果
	if action and action.skill_vo and action.skill_vo.forward_time and action.pass_time <= action.skill_vo.forward_time then
		FightManager:GetInstance():InterruptionSkill(self, action.skill_vo.skill_id)
	end
	if self.move_pos then
		self:SetMovePosition(self.move_pos)
	end
end

function SceneObject:AttackCheckInFunc()
	return true
end

function SceneObject:AttackCheckOutFunc()
	return not self.is_attacking
end

function SceneObject:GetCurStateInfo()
	if not self.cur_state_name then
		return
	end
	return self.action_list[self.cur_state_name]
end

function SceneObject:PlayHit()
end

function SceneObject:BeHit(color, scale, value, time)
	
end

function SceneObject:StopBeHitTime()
	if self.be_hit_time_id then
		GlobalSchedule:Stop(self.be_hit_time_id)
		self.be_hit_time_id = nil
	end
end

-- function SceneObject:SetFresnelColor(color, scale, value)
-- 	scale = scale or 0
-- 	value = value or 0
-- 	if value > 0 then
-- 		color = color or { 255, 255, 255, 255 }
-- 		color = Color(unpack(color))
-- 	end
-- 	if self.fresne_scale == scale and self.fresne_value == value then
-- 		if value > 0 and self.fresne_color and self.fresne_color == color then
-- 			return
-- 		end
-- 	end
-- 	self.fresne_scale = scale
-- 	self.fresne_value = value
-- 	self.fresne_color = color
-- 	local renders = self.gameObject:GetComponentsInChildren(typeof(UnityEngine.SkinnedMeshRenderer))
-- 	for i = 0, renders.Length - 1 do
-- 		local is_body_mat = renders[i] == self.body_skin_renderer
-- 		-- local material = renders[i].sharedMaterial
-- 		local material = renders[i].material
-- 		if value > 0 then
-- 			-- if is_body_mat and self.default_texture then
-- 			--  SetMaterialTexture(self.default_mat,self.default_texture)
-- 			-- end
-- 			-- self.cur_shader = ShaderManager:GetInstance():GetShaderByName(ShaderManager.ShaderNameList.AlphaBlending_Fresnel_fog)
-- 			self.cur_shader = ShaderManager:GetInstance():FindShaderByName("_self/AlphaBlend Fresnel")
			
-- 			-- material.shader = nil
-- 			material.shader = self.cur_shader
-- 			if material.shader.name ~= self.cur_shader.name then
-- 				-- SetColor(material, 255, 255, 255, 255)
-- 			end
			
-- 			SetMaterialColor(material,"_FresnelColor",color.r,color.g,color.b,color.a)
-- 			SetMaterialFloat(material,"_FresnelScale",scale)
-- 			SetMaterialFloat(material,"_FresnelBias", value)
-- 			-- SetMaterialFloat(material,"_Multiplier", 1)
-- 			-- SetMaterialFloat(material,"_AmbientScale", 0)
-- 			-- SetMaterialFloat(material,"_RealTimeLightScale", 0)
			
-- 			-- Yzprint('--LaoY SceneObject.lua,line 1325--',material.shader)
-- 			-- Yzprint('--LaoY SceneObject.lua,line 1325--',material.shader.name)
-- 			-- Yzprint('--LaoY SceneObject.lua,line 1325--',material:GetFloat("_FresnelScale"))
-- 			-- Yzprint('--LaoY SceneObject.lua,line 1326--',material:GetFloat("_FresnelBias"))
-- 			-- Yzprint('--LaoY SceneObject.lua,line 1327--',material:GetFloat("_Multiplier"))
-- 			-- Yzprint('--LaoY SceneObject.lua,line 1328--',material:GetFloat("_AmbientScale"))
-- 			-- Yzprint('--LaoY SceneObject.lua,line 1329--',material:GetFloat("_RealTimeLightScale"))
			
-- 			-- material:SetColorArray("_FresnelColor", { color })
-- 			-- --菲涅尔倍数
-- 			-- material:SetFloat("_FresnelScale", scale)
-- 			-- -- 菲涅尔范围 改变这个值
-- 			-- material:SetFloat("_FresnelBias", value)
-- 			-- -- 总亮度倍数
-- 			-- material:SetFloat("_Multiplier", 1)
-- 			-- material:SetFloat("_AmbientScale", 0)
-- 			-- material:SetFloat("_RealTimeLightScale", 0)
			
-- 		else
-- 			if is_body_mat then
-- 				self.cur_shader = self.default_shader
-- 				material.shader = self.default_shader
-- 			else
-- 				material.shader = ShaderManager:GetInstance():GetShaderByName(ShaderManager.ShaderNameList.Default)
-- 			end
-- 		end
-- 		renders[i].material = material
-- 	end
-- end

--给击退
function SceneObject:BeRepel()
	
end

function SceneObject:GetLockEffectName()
	return "effect_xuanzhong_npc"
end

function SceneObject:GetLockEffectScale()
	return 1
end

function SceneObject:BeLock(flag)
	-- if not self.is_loaded or not self.transform then
	-- 	return
	-- end
	self.is_lock = flag
	if flag then
		if not self.lock_effect then
			local effect_name = self:GetLockEffectName()
			local scale = self:GetLockEffectScale()
			self.lock_effect = self:SetTargetEffect(effect_name, true, self.parent_transform, { x = 0, y = 0, z = 0 }, scale)
		end
	else
		if self.lock_effect then
			self.lock_effect:destroy()
			self.lock_effect = nil
		end
	end
	--if self.name_container then
	--    self.name_container:ShowBlood(flag);
	--end
	if self.shadow_image then
		self.shadow_image:SetVisible(not flag)
	end
end

--[[
@author LaoY
@des    是否在攻击中
@return bool
--]]
function SceneObject:IsAttacking()
	return self.is_attacking
end

--[[
@author LaoY
@des    是否能打断施法 只判断是否可以打断攻击，其他状态不处理
@return bool
--]]
function SceneObject:IsCanInterruption()
	if self:IsDeath() then
		return false
	end
	if not self:IsAttacking() then
		return self:CheckExitCurAction()
	end
	local cur_action = self.action_list[self.cur_state_name]
	if not cur_action or not cur_action.skill_vo then
		return false
	end
	if cur_action.skill_vo.forward_time then
		return cur_action.pass_time < cur_action.skill_vo.forward_time
		or self:IsCanPlayNextAttack()
	end
	return self:IsCanPlayNextAttack()
end

function SceneObject:IsCanPlayNextAttack()
	if self:IsDeath() then
		return false
	end
	if not self:IsAttacking() then
		return self:CheckExitCurAction()
	end
	local cur_action = self.action_list[self.cur_state_name]
	if not cur_action.skill_vo then
		return false
	end
	return (cur_action.skill_vo.fuse_time and cur_action.skill_vo.fuse_time > 0 and cur_action.pass_time >= cur_action.skill_vo.fuse_time)
	or (cur_action.reset_time and (cur_action.action_time - cur_action.pass_time) <= cur_action.reset_time)
	-- return (cur_action.reset_time and (cur_action.action_time - cur_action.pass_time) <= cur_action.reset_time)
end

--[[
@author LaoY
@over write
@des    是否可以切换到攻击状态
@条件 
如果在施法状态，是否可以打断施法
其他状态是否可以打断
--]]
function SceneObject:IsCanSwitchToAttack(skill_vo)
	-- if not self.is_loaded then
	-- 	return false
	-- end
	return self:IsCanInterruption()
end

--[[
@author LaoY
@over write
@des    是否可以切换到移动状态
@条件 
如果在施法状态，是否可以打断施法
其他状态是否可以打断
--]]
function SceneObject:IsCanSwitchToMove()
	return self:IsCanInterruption()
end

--[[
@author LaoY
@des    设置状态机默认状态，子类如果不是统一的待机动作，必须要重新设置
@param1 state_name string
--]]
function SceneObject:SetMachineDefaultState(state_name)
	state_name = state_name or "idle"
	self.machine:SetDefaultState(state_name)
end

--[[
@author LaoY
@des    注册动作到状态机，一个状态对应一个动作，除了state_name，其他可以为空
@param1 state_name      string      动作名字也是状态名
@param2 is_loop         bool        动作是否循环
@param3 func_list       table       回调方法列表
@param1 OnEnter         function    进入状态机的回调
@param2 Update          function    每帧更新状态机的回调
@param3 OnExit          function    退出状态机的回调
@param4 CheckInFunc     function    是否可以切换到该状态          返回值：Bool
@param5 CheckOutFunc    function    是否可以从该状态切换到其他       返回值：Bool
@param6 action_call_back function   动作播放完后得回调。默认是切换到待机动作
@param4 reset_time      number      复位时间，默认0.1
@param5 reset_time      number      复位时间，默认0.1
--]]
function SceneObject:RegisterMachineState(state_name, is_loop, func_list, reset_time, true_action_name)
	-- if self.action_list[state_name] then
	--  logWarn(state_name .. " repeat install !!!!!!",state_name)
	--  return
	-- end
	func_list = func_list or {}
	local machine_state = self.machine:CreateState(state_name)
	local action = {
		is_loop = is_loop,
		OnEnter = func_list.OnEnter,
		Update = func_list.Update,
		OnExit = func_list.OnExit,
		CheckInFunc = func_list.CheckInFunc,
		CheckOutFunc = func_list.CheckOutFunc,
		action_time = false,
		pass_time = 0,
		is_playing = false,
		loop_count = 0,
		is_exit = false,
		reset_time = reset_time or 0.1,
		total_time = 0,
		action_name = true_action_name or state_name,
	}
	machine_state:SetCallBack(handler(self, self.OnEnterMachineState), handler(self, self.UpdateMachineState), handler(self, self.OnExitMachineState))
	self.action_list[state_name] = action
end

function SceneObject:OnEnterMachineState(state_name)
	local action = self.action_list[state_name]
	if not action then
		logWarn((state_name or "") .. " is not Register !!!!!! cname = " .. self.__cname)
		if AppConfig.Debug then
			logError(string.format("action = %s,state_name = %s",tostring(action),tostring(state_name)))
		end
		return
	end
	-- self.animator:Play(state_name)
	
	local reset_time = 0.1
	if self.cur_state_name and self.action_list[state_name] then
		reset_time = action.reset_time
	end
	-- reset_time = 0.3
	-- self.animator:CrossFade(state_name,reset_time,0,0)
	if self.gpu_player ~= nil then
		self.gpu_player:Play(action.action_name)
	else
		self.animator:CrossFadeInFixedTime(action.action_name, reset_time)
	end
	self.cur_state_name = state_name
	-- Yzprint('--LaoY SceneObject.lua,line 686-- data=',state_name)
	action.is_playing = true
	action.pass_time = 0
	action.loop_count = 0
	action.total_time = 0
	-- 用speed，每次时间必须重新拿
	-- self.animator.speed =  2

	if action.error_action_time then
		action.action_time = false
		action.error_action_time = false
	end

	if not action.action_time then
		-- 真正获取时间的方法
		-- 文件名必须是输出的动作名字
		if self.animator then
			action.action_time = GetClipLength(self.animator, action.action_name)
		else
			action.action_time = self.gpu_player:GetClipLength(action.action_name)
		end
		action.check_dynamic_time = false
		-- if state_name == SceneConstant.ActionName.collect2 then
		--     Yzprint('--LaoY ======>', state_name, action.action_name, action.action_time)
		-- end
		if action.action_time == 0 then
			-- 这个时间长度会受到speed影响
			-- local cur_state = self.animator:GetCurrentAnimatorStateInfo(0)
			-- action.action_time = cur_state.length
			-- 这个时间长度不会受到speed影响 因为动作融合，当前拿到的是上个动作时间
			-- 所以必须动态拿时间
			local count, ClipInfo
			if self.animator then
				count, ClipInfo = self.animator:GetCurrentAnimatorClipInfo(0)
				if count > 0 then
					action.action_time = ClipInfo[0].clip.length
				end
			end
			
			-- Yzprint('--LaoY SceneObject.lua,line 882-- data=',state_name,action.action_time)
			if self.last_state_name and self.action_list[self.last_state_name] then
				logWarn("动作控制器不存在该动作：", state_name, ",使用的类为：", self.__cname, ",名字为：", self.object_info and self.object_info.name or "空")
				local last_action = self.action_list[self.last_state_name]
				local reset_time = last_action.action_time - last_action.pass_time % last_action.action_time
				reset_time = reset_time > 0 and reset_time or 0
				action.check_dynamic_time = action.action_time > reset_time and reset_time or action.reset_time
				
			end
			if action.action_time == 0 then
				action.action_time = 0.6
			end
		end
	end
	if action.action_time == nil or type(action.action_time) ~= "number" then
		if AppConfig.Debug then
			logError("动作不能获取时间：", state_name, ",使用的类为：", self.__cname, ",名字为：", self.object_info and self.object_info.name or "空",",action.action_time = ",tostring(action.action_time))
		else
			logWarn("动作不能获取时间：", state_name, ",使用的类为：", self.__cname, ",名字为：", self.object_info and self.object_info.name or "空",",action.action_time = ",tostring(action.action_time))
		end
		action.action_time = 1.0
	end
	if action.OnEnter then
		action.OnEnter(state_name)
	end

	local depend_object_list = self:GetDependObjectList()
	if not table.isempty(depend_object_list) then
		for actor_type,list in pairs(depend_object_list) do
			for index,depend_object in pairs(list) do
				depend_object:OwnerEnterState(state_name)
			end
		end
	end
end

function SceneObject:UpdateMachineState(state_name, delta_time)
	local action = self.action_list[state_name]
	if action.check_dynamic_time and action.pass_time > action.check_dynamic_time then
		if self.animator then
			local count, ClipInfo = self.animator:GetCurrentAnimatorClipInfo(0)
			if count > 0 then
				action.action_time = ClipInfo[0].clip.length
			end
		end
		action.check_dynamic_time = false
	end
	
	action.pass_time = action.pass_time + delta_time
	action.total_time = action.total_time + delta_time
	if action.Update then
		action.Update(state_name, delta_time)
	end
	if self.cur_state_name and state_name ~= self.cur_state_name then
		return
	end
	if not action.action_time then
		if AppConfig.Debug then
			logError("====UpdateMachineState action time error , state_name = " .. state_name .. ", self.__cname = " .. self.__cname)
		end
		action.action_time = 1.0
		action.error_action_time = true
	end
	local action_time = action.reset_time and (action.action_time - action.reset_time) or action.action_time
	if action_time <= 0 then
		action_time = action.action_time
	end
	if state_name == SceneConstant.ActionName.death and action.pass_time >= action_time then
		-- print("state_name = ", state_name, action_time)
	end
	if action_time and action.pass_time >= action_time then
		-- 动作不循环，切动作时间已经完成，强制切换到默认状态
		if self:IsDeath() then
			self:OnExitMachine()
		elseif action.action_call_back then
			-- Yzprint('--LaoY SceneObject.lua,line 667-- data=',data)
			-- self:OnExitMachine()
			self:ChangeToMachineDefalutState()
			action.action_call_back()
		elseif not action.is_loop then
			self:ChangeToMachineDefalutState()
		else
			self:LoopActionOnceEnd()
			action.loop_count = action.loop_count + 1
		end
		-- action.pass_time = action.pass_time - action_time
		action.pass_time = 0
	end
end

function SceneObject:OnExitMachineState(state_name,last_state_name)
	local action = self.action_list[state_name]
	if not action.is_playing then
		return
	end
	self.last_state_name = state_name
	self.cur_state_name = nil
	action.is_playing = false
	if action.OnExit then
		action.OnExit(state_name,last_state_name)
	end
end

-- over write
function SceneObject:LoopActionOnceEnd()
end

function SceneObject:ChangeToMachineDefalutState()
	if self:IsDeath() then
		return
	end
	if not self.transform then
		return
	end
	if self.machine then
		self.machine:ChangeState()
	end
end

--[[
@author LaoY
@des    
@param1 state_name  名字
@param2 force       是否强制切换  播放攻击动作是强制切换
@return bool        是否切换成功（与上一个相同也算成功）
--]]
function SceneObject:ChangeMachineState(state_name, force)
	if IsNil(self.transform) then
		return false
	end
	if not self.animator and not self.gpu_player then
		self.default_state = state_name
		return false
	end
	if self:IsDeath() then
		return
	end
	if not force and self.machine:GetCurStateName() == state_name then
		return true
	end
	local cur_action
	if self.cur_state_name then
		cur_action = self.action_list[self.cur_state_name]
		if not cur_action then
			logWarn(self.cur_state_name .. " is not Register !!!!!!")
			return false
		end
	end
	if not force and cur_action and cur_action.CheckOutFunc and not cur_action.CheckOutFunc() then
		return false
	end
	local action = self.action_list[state_name]
	if not action then
		logWarn(state_name .. " is not Register !!!!!!")
		return false
	end
	if not force and action.CheckInFunc and not action.CheckInFunc() then
		return false
	end
	self.machine:ChangeState(state_name)
	return true
end

--[[
@author LaoY
@des    是否可以退出当前动作
@return Bool
--]]
function SceneObject:CheckExitCurAction()
	local cur_action = self.action_list[self.cur_state_name]
	if not cur_action then
		return true
	end
	if cur_action.CheckOutFunc then
		return cur_action.CheckOutFunc()
	end
	return true
end

function SceneObject:OnExitMachine()
	self.cur_state_name = nil
	self.machine:OnExit()
end

function SceneObject:IsDeath()
	return self.is_death
end

function SceneObject:CheckInBound(x, y)
	if x < (self.position.x - self.body_size.width / 2) or x > (self.position.x + self.body_size.width / 2) or
		y < self.position.y or y > self.position.y + self.body_size.height then
		return false
	end
	return true
end

--滑步、怪物死亡击飞
function SceneObject:PlaySlip(end_pos, speed, callback, rate_type, rate)
	if not end_pos then
		return
	end
	self:StopSlip()
	speed = speed or self.move_speed * GetSpeedRate(self.direction)
	self.slipping = true
	local start_pos = Vector2(self.position.x, self.position.y)
	-- start_pos:Mul(1)
	local distance = Vector2.Distance(start_pos, end_pos)
	local move_time = distance / speed
	local action = cc.MoveTo(move_time, end_pos.x, end_pos.y, end_pos.z)
	if rate_type and rate then
		if rate_type == 1 then
			action = cc.EaseOut(action, rate)
		elseif rate_type == 2 then
			action = cc.EaseBounceOut(action, rate)
		elseif rate_type == 3 then
			action = cc.EaseBackOut(action, rate)
		elseif rate_type == 4 then
			action = cc.EaseIn(action, rate)
		end
	end
	local function call_back()
		if callback then
			callback()
		end
	end
	local call_action_1 = cc.CallFunc(call_back)
	local delay_action = cc.DelayTime(move_time * 0.1)
	action = cc.Spawn(action, cc.Sequence(delay_action, call_action_1))
	local function call_back()
		-- if callback then
		--  callback()
		-- end
		self.slipping = false
		self.slip_action = nil
	end
	local call_action = cc.CallFunc(call_back)
	action = cc.Sequence(action, call_action)
	self.slip_action = cc.ActionManager:GetInstance():addAction(action, self)
end

function SceneObject:StopSlip()
	if self.slip_action then
		self.slipping = false
		cc.ActionManager:GetInstance():removeAction(self.slip_action)
		self.slip_action = nil
	end
end

function SceneObject:CreateDependObject(actor_type, index)
	if not self:GetDependObject(actor_type, index) then
		SceneManager:GetInstance():AddDependObjcet(self,self.object_id, actor_type, index)
	end
end

function SceneObject:GetDependObject(actor_type, index)
	return SceneManager:GetInstance():GetDependObject(self, actor_type, index)
end

-- actor_type 可以不填
function SceneObject:GetDependObjectList(actor_type)
	return SceneManager:GetInstance():GetDependObjectList(self,actor_type)
end

function SceneObject:RemoveDependObject(actor_type, index)
	SceneManager:GetInstance():RemoveDependObject(self, actor_type, index)
end

function SceneObject:Update(delta_time)
	if self.all_rotate_off then
		local per_frame_rotate = SceneConstant.TurnSpeed * delta_time
		--local per_frame_rotate = 1
		if self.all_rotate_off > 0 then
			if self.all_rotate_off > per_frame_rotate then
				self:AddRotateY(-per_frame_rotate, true)
				self.all_rotate_off = self.all_rotate_off - per_frame_rotate
			else
				self:AddRotateY(-self.all_rotate_off, true)
				self.all_rotate_off = nil
			end
		else
			if self.all_rotate_off < -per_frame_rotate then
				self:AddRotateY(per_frame_rotate, true)
				self.all_rotate_off = self.all_rotate_off + per_frame_rotate
			else
				self:AddRotateY(-self.all_rotate_off, true)
				self.all_rotate_off = nil
			end
		end
	end
	
	self:CheckServerPosition(delta_time)
end

function SceneObject:CheckServerPosition(delta_time)
	-- if not self.is_loaded then
		if not self:IsRunning() and self.server_pos and self.position and (self.server_pos.x ~= self.position.x or self.server_pos.y ~= self.position.y) and
			not BitState.StaticContain(self.server_pos_mask, SceneConstant.MaskBitList.Block) and
			not BitState.StaticContain(self.server_pos_mask, SceneConstant.MaskBitList.JumpPath) then
			-- local vec = GetVector(self.position,self.server_pos)
			-- vec:SetNormalize()
			-- local x,y
			-- x = self.position.x + self.move_speed * vec.x * delta_time
			-- y = self.position.y + self.move_speed * vec.y * delta_time
			-- if Vector2.DistanceNotSqrt(self.position,self.server_pos) < Vector2.DistanceNotSqrt(self.position,pos(x,y)) then
			-- 	x = self.server_pos.x
			-- 	y = self.server_pos.y
			-- end
			-- self:SetPosition(x,y)
			self:SetMovePosition(self.server_pos)
		end
	-- end
end

-- over write
function SceneObject:SignBeHit()
end

-- over write
function SceneObject:SignAttack()
end

-- over write
function SceneObject:OnClick()
	return false
end

-- over write
function SceneObject:OnMainRoleStop()
end

-- over write
function SceneObject:RemoveCache()
end

-- over write
function SceneObject:LoadBodyCallBack()
end
SceneObject.isShowBody = true;
function SceneObject:ShowBody(bool)
	bool = toBool(bool);
	if self.isShowBody == bool then
		return
	end
	if self.isShowBody ~= bool and bool then
		if self.resst_action_time_id then
			GlobalSchedule:Stop(self.resst_action_time_id)
			self.resst_action_time_id = nil
		end
		local function step()
			if self.is_dctored then
				return
			end
			self:ResetAction()
		end
		self.resst_action_time_id = GlobalSchedule:StartOnce(step, 0)
	end
	self.isShowBody = bool;
	SetGameObjectActive(self.parent_transform, bool);
end

function SceneObject:ResetAction()
	if self.gpu_player ~= nil then
		self.gpu_player:Play(self.cur_state_name)
	elseif self.animator ~= nil then
		self.animator:CrossFadeInFixedTime(self.cur_state_name, 0)
	end
end

--SceneObject.AdvanceHeight = 100;
function SceneObject:SetAdvanceItemPos()
	if self.advance_container then
		local world_pos = { x = self.position.x / SceneConstant.PixelsPerUnit, y = self.position.y / SceneConstant.PixelsPerUnit }
		local body_height = self:GetBodyHeight() + (self.body_pos.y <= 0 and 0 or self.body_pos.y + 30)
		self.advance_container:SetGlobalPosition(world_pos.x, world_pos.y + body_height / SceneConstant.PixelsPerUnit + 1, self.position.z * 1.1)
		--self.advance_container:SetGlobalPosition(world_pos.x, world_pos.y, z)
	end
end

function SceneObject:SetBuffImage(abName, res)
	if self.name_container then
		if self.__cname == "Monster" and self.creep_kind == enum.CREEP_KIND.CREEP_KIND_COLLECT then
			Yzprint('--LaoY SceneObject.lua,line 1857--', data)
			traceback()
		end
		self.name_container:SetBuffImage(abName, res)
	end
end

function SceneObject:HideBuffImage()
	if self.name_container then
		self.name_container:HideBuffImage()
	end
end

-- 是否能给攻击
function SceneObject:IsCanBeAttack()
	return false
end

-- 是否能给自动锁定
function SceneObject:AutoSelect()
	return self:IsCanBeAttack()
end

--[[
	@author LaoY
	@return bool 是否有变化
--]]
function SceneObject:SetTransformLayer(flag,layer)
	if flag == self.transform_layer_is_self then
		return false
	end
	
	local horse_info = self.boneObject_list[SceneConstant.BoneNode.Ride_Root]
	if not self.transform and not(horse_info and horse_info.transform) then
		return
	end
	
	self.transform_layer_is_self = flag
	local transform = horse_info and horse_info.transform or self.transform

	local bo = IsNil(transform)
	if transform and bo then
		local condition = string.format("[lua][gameObject is nil] SetTransformLayer,cname = %s,cur_state_name = %s,horse_info = %s",self.__cname,tostring(self.cur_state_name),horse_info)
		logError(condition)
		return
	end

	if self.transform_layer_is_self then
		-- if horse_info and horse_info.transform then
		-- 	horse_info.transform:SetParent(self.model_parent)
		-- else
		-- 	self.transform:SetParent(self.model_parent)
		-- end
		-- transform:SetParent(self.model_parent)
		SetCacheState(self.gameObject,false)

		SetLocalPosition(transform, 0, 0, 0)
		SetVisible(transform,true)

		if self.cur_state_name and self.cur_state_name ~= nil then
			-- self:OnEnterMachineState(self.cur_state_name)
			if self.gpu_player ~= nil then
				self.gpu_player:Play(self.cur_state_name)
			else
				self.animator:CrossFadeInFixedTime(self.cur_state_name, 0)
			end
		end

	else
    	-- layer = layer or LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.SceneObjCache)

		-- if horse_info and horse_info.transform then
		-- 	horse_info.transform:SetParent(layer)
		-- else
		-- 	self.transform:SetParent(layer)
		-- end

		-- transform:SetParent(layer)
		SetCacheState(self.gameObject,true)
		SetLocalPosition(transform, -1000, -1000, 0)
		SetVisible(transform,false)
	end

	local depend_object_list = self:GetDependObjectList()
	if not table.isempty(depend_object_list) then
		for actor_type,list in pairs(depend_object_list) do
			for index,depend_object in pairs(list) do
				depend_object:SetVisibleStateBit(not self.transform_layer_is_self,SceneManager.SceneObjectVisibleState.OwenState)
				depend_object:UpdateVisible()
			end
		end
	end

	if self.animator then
		if self.transform_layer_is_self then
			self.animator.cullingMode = UnityEngine.AnimatorCullingMode.AlwaysAnimate
		else
			self.animator.cullingMode = UnityEngine.AnimatorCullingMode.CullUpdateTransforms
		end
	end

	
	return true
end

function SceneObject:SetVisibleStateBit(is_add,state)
	self.visible_state = self.visible_state or BitState()

	if is_add then
		self.visible_state:Add(state)
	else
		self.visible_state:Remove(state)
	end
end

function SceneObject:UpdateVisible()
	local is_show = true
	if self.visible_state then
		is_show = not self.visible_state:Contain()
	end
	self:SetTransformLayer(is_show)
end