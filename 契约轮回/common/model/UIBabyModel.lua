UIBabyModel = UIBabyModel or class("UIBabyModel",UIModel)
local this = UIBabyModel

function UIBabyModel:ctor(parent,npc_id,load_call_back, showid)
    self.abName = npc_id;--"model_monster_" ..
    self.assetName = npc_id;--"model_monster_" ..
    self.load_call_back = load_call_back
	self.boneNode_list = {}
	self.boneObject_list = {}
	if showid and showid > 9999 then
		self.is_showWing = true
		self.id = showid
	end
	
    UIBabyModel.super.Load(self)
end

function UIBabyModel:dctor()
	self:ClearBoneNode()
	AnimationManager:GetInstance():RemoveAnimation(self)
	if self.gameObject then
		LayerManager.RecycleUnUseUIModelLayer(self.gameObject.layer)
	end
	self.parentLayer = nil;
	
	self:ClearBoneEffect()
end

function UIBabyModel:LoadCallBack()
    self:AddAnimation({"idle"},false,"idle",0)--,"casual"
    local pos = self.transform.localPosition;
    SetLocalPosition(self.transform , pos.x , pos.y , -200);
    --SetLocalRotation(self.transform , 0,0,0);
    if self.load_call_back then
        self.load_call_back()
    end
	if self.is_showWing then
		local id  = Config.db_baby_wing_morph[self.id].res
		self:LoadWing(id)
	end
	
end

function UIBabyModel:AddEvent()
end

function UIBabyModel:SetData(data)

end

function UIBabyModel:PlayAnimation(actionName,isLoop)
    AnimationManager:GetInstance():AddAnimation(self, self.animator, actionName, isLoop, "idle", 0.1)
end

function UIBabyModel:LoadWing(wing_res_id)
	
	local boneName = SceneConstant.BoneNode.Wing
	
	--[[if (not self.data.is_show_wing) then
		self:RemoveBoneResource(boneName)
		return
	end--]]
	
	local res_id = wing_res_id or 0
	
	if res_id == 0 then
		--self:RemoveBoneResource(boneName)
		return
	else
		local abName = "model_child_" .. res_id
		local assetName = "model_child_" .. res_id
		
		local function load_callback()
			
			if not self.boneObject_list[boneName] then
				return
			end
			
			local info = self.boneObject_list[boneName]
			info.animator = info.gameObject:GetComponent('Animator')
		end
		self:SetBoneResource(boneName, abName, assetName, load_callback, nil)
	end
end

function UIBabyModel:SetBoneResource(boneName, abName, assetName, load_func, remove_cache_func)
	if not self.is_loaded then
		logWarn("The time is wrong to call SetBoneResource , the res is " .. abName)
		return
	end
	self.boneRes_list = {}
	local last_res = self.boneRes_list[boneName]
	local function load_callback(objs, is_cache)
		if self.is_dctored or not objs or not objs[0] then
			logWarn("load", boneName, "is failed", "the res is", abName)
			return
		end
		local function new_call_back(obj)
			if self.is_dctored then
				if not poolMgr:AddGameObject(abName, assetName, obj) then
					destroy(obj)
				end
				return
			end
			local bone = self:GetBoneNode(boneName)
			if not bone then
				logWarn("can not find the bone , the name is " .. boneName)
				return
			end
			local new_gameObject = obj
			local bone_object = self.boneObject_list[boneName]
			if bone_object and bone_object.gameObject then
				local res = self.boneRes_list[boneName]
				if abName == res.abName and assetName == res.assetName then
					if not last_res or not poolMgr:AddGameObject(last_res.abName, last_res.assetName, bone_object.gameObject) then
						destroy(bone_object.gameObject)
					end
					-- 不要置为nil
					self.boneObject_list[boneName].gameObject = false
					self.boneObject_list[boneName].transform = false
					if remove_cache_func then
						remove_cache_func()
					end
				else
					if not poolMgr:AddGameObject(abName, assetName, new_gameObject) then
						destroy(new_gameObject)
					end
					return
				end
			end
			
			-- 保存gameObject和transform，不要频繁和C#交互
			local transform = new_gameObject.transform
			self.boneObject_list[boneName] = { gameObject = new_gameObject, transform = transform }
			transform:SetParent(bone)
			
			if boneName == SceneConstant.BoneNode.Head then
				self.boneObject_list[boneName].animator = new_gameObject:GetComponent('Animator')
			end
			SetChildLayer(transform, self.parentLayer or LayerManager.BuiltinLayer.UI)
			SetLocalPosition(transform)
			SetLocalRotation(transform)
			SetLocalScale(transform)
			
			if load_func then
				load_func()
			end
			
			self:ClearBoneEffect(boneName)
			self:LoadBoneNodeEffect(transform,boneName,assetName)
		end
		
		if is_cache then
			new_call_back(objs[0])
		else
			lua_resMgr:GetPrefab("", "", objs[0], new_call_back);
		end
	end
	self.boneRes_list[boneName] = { abName = abName, assetName = assetName }
	lua_resMgr:LoadPrefab(self, abName, assetName, load_callback, nil, Constant.LoadResLevel.High, true)
end

function UIBabyModel:GetBoneNode(boneName)
	if not self.boneNode_list[boneName] then
		self.boneNode_list[boneName] = GetComponentChildByName(self.transform, boneName)
	end
	return self.boneNode_list[boneName]
end
function UIBabyModel:ClearBoneEffect(boneName)
	if not self.model_bone_effect_list then
		return
	end
	if boneName then
		if self.model_bone_effect_list[boneName] then
			for k,v in pairs(self.model_bone_effect_list[boneName]) do
				v:destroy()
			end
			self.model_bone_effect_list[boneName] = {}
		end
	else
		for _boneName,boneList in pairs(self.model_bone_effect_list) do
			for k,v in pairs(boneList) do
				v:destroy()
			end
		end
		self.model_bone_effect_list = nil
	end
end

function UIBabyModel:LoadBoneNodeEffect(transform,boneName,assetName)
	self.model_bone_effect_list = self.model_bone_effect_list or {}
	self.model_bone_effect_list[boneName] = self.model_bone_effect_list[boneName] or {}
	
	local effect_list_cf = ModelEffectConfig[assetName]
	if not effect_list_cf then
		return
	end
	for node_name,effect_list in pairs(effect_list_cf) do
		for k,cf in pairs(effect_list) do
			local node = GetComponentChildByName(transform,node_name)
			if node then
				local effect = ModelEffect(node,cf.name,cf,self,true)
				self.model_bone_effect_list[boneName][#self.model_bone_effect_list[boneName]+1] = effect
			end
		end
	end
end

function UIBabyModel:ClearBoneNode()
	for boneName, info in pairs(self.boneObject_list) do
		local res = self.boneRes_list[boneName]
		-- 添加到缓存
		if not info.gameObject then
			return
		end
		if res then
			if not poolMgr:AddGameObject(res.abName, res.assetName, info.gameObject) then
				destroy(info.gameObject)
			end
		end
	end
	self.boneObject_list = {}
	self.boneRes_list = {}
	---Parent Transform 要清除，以免将模型挂到上个模型上
	self.boneNode_list = {}
	
	self.effect_list = {}
end