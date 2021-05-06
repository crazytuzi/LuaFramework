local CModel = class("CModel", CRenderObject, CGameObjContainer)
--处理动作，装饰武器加载
function CModel.ctor(self, obj)
	CRenderObject.ctor(self, obj) 
	CGameObjContainer.ctor(self, obj)
	self.m_Animator = self:GetComponent(classtype.Animator)
	self.m_OriRuntimeAnimatorController = self.m_Animator.runtimeAnimatorController
	if not self.m_OriRuntimeAnimatorController then
		error("没有设置动作Animator·, "..self:GetName())
		return
	end
	if Utils.IsEditor() then
		self.m_DataContainer = self:GetMissingComponent(classtype.DataContainer)
	end
	self.m_Animator.runtimeAnimatorController = self.m_OriRuntimeAnimatorController:Instantiate()
	self.m_IsIgnoreTimescale = false
	self:InitValue()
	self:InitAnimEffectInfo()
	self:UpdateMaterials()
end

function CModel.FindWeapon(self)
	self.m_WeaponObj = nil
	if data.modeldata.NeedFindWeapon[self.m_Shape] then
		local oWeapen = self:Find("GameObject/weapon")
		if oWeapen then
			self.m_WeaponObj = oWeapen.gameObject
		end
	end
end

function CModel.InitValue(self)
	CRenderObject.InitValue(self)
	self.m_ShowWeapon = true
	self.m_WeaponObj = nil
	self.m_ShareAnimatorController = nil
	self.m_AnimEffectInfos = {}
	self.m_CurEffectAnim = nil
	self.m_AnimEffects = {}
	self.m_Shape = nil
	self.m_MountType = nil
	self.m_Layer = 0
	self.m_Info = {}
	self.m_MountObjs = {}
	self.m_Type2IDs = {}
	self.m_State = "idleCity"
	self.m_MaterialAddFunc = nil
	self.m_PriorLoad = false
	self.m_AnimType = 1
	self.m_AnimLoadedFrames = {}
	self.m_BakAnimatorInfo = {controller = nil, clips={}}
	self.m_ValidLoadID = {}
end

function CModel.SetRuntimeAnimator(self, oAnimator)
	self.m_Animator.runtimeAnimatorController = oAnimator
end

function CModel.GetRuntimeAnimator(self)
	return self.m_Animator.runtimeAnimatorController
end

function CModel.SetPriorLoad(self, b)
	self.m_PriorLoad = b
end

function CModel.GetHeights(self)
	local v1, v2, v3
	local t = self:Find("Mount_HUD")
	if t then
		v1 = t.position
	end
	t = self:Find("Mount_Hit")
	if t then
		v2 = t.position
	end
	t = self:Find("Mount_Shadow")
	if t then
		v3 = t.position
	end
	return v1, v2, v3
end

function CModel.InitAnimEffectInfo(self)
	local comps = self:GetComponents(classtype.AnimEffect)
	local data = {}
	if comps then
		for i=0, comps.Length-1 do
			local comp = comps[i]
			local list = {}
			for j=0 , comp.EffectLength-1 do
				local info = comp.infoArray[j]
				table.insert(list, {transform=info.gameObject.transform,path=info.path})
			end
			data[comp.animName] = list
		end
	end
	self.m_AnimEffectInfos = data
end

function CModel.GetEffectMountType(self, sState)
	return "animeff_"..sState
end

function CModel.CheckAnimEffect(self, sState)
	if self.m_CurEffectAnim == sState then
		return
	end
	local sType = self:GetEffectMountType(sState)
	if self.m_CurEffectAnim then
		self:DelObjType(self:GetEffectMountType(self.m_CurEffectAnim))
	end
	local list = self.m_AnimEffectInfos[sState]
	if list and #list > 0 then
		self.m_CurEffectAnim = sState
		for i, info in ipairs(list) do
			g_ResCtrl:LoadCloneAsync(info.path, callback(self, "OnEffectLoadDone", sState, sType, info.transform), self.m_PriorLoad)
		end
	else
		self.m_CurEffectAnim = nil
	end
end

function CModel.OnEffectLoadDone(self, sState, sType, transform, oClone, sPath)
	if self.m_CurEffectAnim ~= sState then
		g_ResCtrl:PutCloneInCache(sPath, oClone)
		return
	end
	local obj = CObject.New(oClone)
	obj:SetCacheKey(sPath)
	obj:ReActive()
	self:MountObj(obj, transform, sType)
end


function CModel.SetMountType(self, sType)
	self.m_MountType = sType
end

function CModel.GetMountTransform(self)
	if self.m_MountTrans then
		return self.m_MountTrans[self.m_MountType]
	end
end

function CModel.SetInfo(self, dInfo)
	if table.equal(self.m_Info, dInfo) then
		return
	end
	self.m_Info = dInfo or {}
	self:RefreshInfo()
end

function CModel.RefreshInfo(self)
	if self.m_Info.weapon then
		self:MountWeapon(self.m_Shape, self.m_Info.weapon)
	else
		self:DelObjType("weapon")
	end
end

function CModel.MountWeapon(self, iShape, iWeapon)
	self:DelObjType("weapon")
	self:ResetAnimTypeByWeapon(iShape, iWeapon)
	self:ReloadAdornByWeapon(iShape, iWeapon)
	local mounts = ModelTools.GetMountList(iShape, iWeapon)
	local iUniqueID = Utils.GetUniqueID()
	local sMountType = "weapon"
	self.m_ValidLoadID[sMountType] = iUniqueID
	if mounts then
		for k, iMoutIdx in pairs(mounts) do
			local path = ""
			if type(k) == "string" then
				path= string.format("Model/Weapon/%d/Prefabs/weapon%d_%s.prefab",iWeapon, iWeapon, k)
			else
				path= string.format("Model/Weapon/%d/Prefabs/weapon%d.prefab",iWeapon, iWeapon)
			end
			g_ResCtrl:LoadCloneAsync(path, callback(self,  "OnMountObjDone", iMoutIdx, sMountType, iUniqueID), self.m_PriorLoad)
		end
	else
		print("造型:",iShape,",没有武器", iWeapon)
	end
end

function CModel.SetWeaponActive(self, bValue)
	self.m_ShowWeapon = bValue
	local list = self.m_Type2IDs["weapon"]
	if list then
		for i, id in pairs(list) do
			local obj = self.m_MountObjs[id]
			if obj then
				obj.m_GameObject:SetActive(bValue)
			end
		end
	end
	if self.m_WeaponObj then
		self.m_WeaponObj:SetActive(bValue)
	end
end

function CModel.ReloadAdornByWeapon(self, iShape, iWeapon)
	local dAdornInfo = data.modeldata.ADORN[iShape]
	if dAdornInfo then
		local sWeaponKey = ModelTools.GetWeaponKey(iWeapon)
		local lShow = dAdornInfo[sWeaponKey] or {}
		for _, idx in ipairs(dAdornInfo.adorns) do
			local s = "adorn_"..tostring(idx)
			local transform = self:Find(s)
			if transform then
				transform.gameObject:SetActive(table.index(lShow, idx) ~= nil)
			end
		end
	end
end

function CModel.ResetAnimTypeByWeapon(self, iShape, iWeapon)
	local idx = ModelTools.GetAnimatorIdx(iShape, iWeapon)
	if self.m_AnimType ~= idx then
		self.m_AnimType = idx
		self.m_AnimLoadedFrames = {}
		self.m_BakAnimatorInfo.clips={}
	end
	self:Play(self:GetState(), 1)
end

function CModel.GetAnimTypeString(self, iAnimType)
	return iAnimType == 1 and "" or "_"..tostring(iAnimType)
end

function CModel.CheckLoadAnim(self, sAnim)
	if self.m_AnimLoadedFrames[sAnim] then
		if self.m_AnimLoadedFrames[sAnim] == UnityEngine.Time.frameCount then
			-- printc("这一帧才load的，等下一帧才播放", sAnim)
			return true
		else
			return false
		end
	end
	if not self.m_BakAnimatorInfo.controller then
		self.m_BakAnimatorInfo.controller = self.m_Animator.runtimeAnimatorController:Instantiate()
		if self.m_DataContainer then
			self.m_DataContainer.animatorOverrideController = self.m_BakAnimatorInfo.controller
		end
	end
	--搜索并加载全部依赖动作
	local clip = nil
	local count = 0
	local dependencyMark = {}--防循环标记
	local dependencyList = {}
	local sLoadAnim = sAnim
	while (sLoadAnim) do
		if not self.m_AnimLoadedFrames[sLoadAnim]then
			clip = self:LoadAnim(sLoadAnim)
			if not clip and sLoadAnim == sAnim then
				return false
			end
			local tempData = data.modeldata.AnimDependency[sLoadAnim]
			if tempData then
				for i = 1, #tempData do
					if not dependencyMark[tempData[i]] then
						dependencyMark[tempData[i]] = true
						table.insert(dependencyList, tempData[i])
					end
				end
			end
		end
		count = count + 1
		sLoadAnim = dependencyList[count]
	end
	return true
end

function CModel.LoadAnim(self, sAnim)
	self.m_AnimLoadedFrames[sAnim] = UnityEngine.Time.frameCount
	local iShape = data.modeldata.SHARE_ANIM[self.m_Shape] or self.m_Shape
	local iAnimType = self.m_AnimType
	if data.modeldata.COMMON_ANI[sAnim] then
		if data.modeldata.SOCIAL_SELF[self.m_Shape] then
			iShape = self.m_Shape
			iAnimType = data.modeldata.SOCIAL_SELF[self.m_Shape][self.m_AnimType]
		else
			iShape = data.modeldata.COMMON_ANI[sAnim]
			iAnimType = 1
		end
	end
	local sType = self:GetAnimTypeString(iAnimType)
	local sFileName = string.format("%s%s", sAnim, sType)
	local path
	-- printc(string.format("iShape: %s, iAnimType: %s, sFileName: %s", iShape, iAnimType, sFileName))
	if data.animclipdata.DATA[iShape] then
		if not data.animclipdata.DATA[iShape][iAnimType] or 
			not data.animclipdata.DATA[iShape][iAnimType][sFileName] then
			iAnimType = 1
			sFileName = string.format("%s%s", sAnim, sType)
		end
		path = string.format("Model/Character/%d/Anim/%d_%s.anim", iShape, iShape, sFileName)
		if not data.animclipdata.DATA[iShape][iAnimType] or 
			not data.animclipdata.DATA[iShape][iAnimType][sFileName] then
			print(string.format("%d没有这个动作%s", iShape, sFileName))
			return nil
		end
	else
		print(string.format("%d没有动作时间文件", iShape))
		return nil
	end
	local clip = g_ResCtrl:Load(path)
	self.m_BakAnimatorInfo.controller:set_Item(sAnim, clip)
	self.m_BakAnimatorInfo.clips[sAnim] = clip
	return clip
end

function CModel.OnMountObjDone(self, iMoutIdx, sMountType, iUniqueID, oClone, sPath)
	if oClone then
		if self.m_ValidLoadID[sMountType] == iUniqueID then
			local obj = CContainerObject.New(oClone)
			obj:SetCacheKey(sPath)
			local mounTrans = self:GetContainTransform(iMoutIdx)
			self:MountObj(obj, mounTrans, sMountType)
			-- self:DelayCall(0, "UpdateMaterials")
			if sMountType == "weapon"and not self.m_ShowWeapon then
				oClone:SetActive(false)
			end
			self:SetWeaponActive(self.m_ShowWeapon)
		else
			print("与Load ID不符合", sMountType, self.m_ValidLoadID[sMountType], iUniqueID)
			return false
		end
	end
end

function CModel.SetModelShape(self, iShape)
	self.m_Shape = iShape
	if self.m_Shape then
		self:FindWeapon()
	end
end

function CModel.GetModelShape(self)
	return self.m_Shape
end

function CModel.Destroy(self)
	for k, v in pairs(self.m_MountObjs) do
		v:Destroy()
	end
	CRenderObject.Destroy(self)
end

function CModel.Recycle(self)
	xxpcall(CModel.SafeRecycle, self)
end

function CModel.SafeRecycle(self)
	CRenderObject.Recycle(self)
	self:SetLocalScale(Vector3.one)
	for _, v in pairs(self.m_MountObjs) do
		v:Recycle()
		g_ResCtrl:PutCloneInCache(v:GetCacheKey(), v.m_GameObject)
	end
	self.m_Animator.runtimeAnimatorController:Destroy()
	if self.m_BakAnimatorInfo.controller then
		self.m_BakAnimatorInfo.controller:Destroy()
	end
	self.m_Animator.runtimeAnimatorController = self.m_OriRuntimeAnimatorController
	g_ResCtrl:PutCloneInCache(self:GetCacheKey(), self.m_GameObject)
	self:InitValue()
end

function CModel.MountObj(self, obj, trans, sType)
	if trans then
		obj:SetParent(trans, false)
		obj:SetLocalPos(Vector3.zero)
	end
	obj:SetLayerDeep(self:GetLayer())
	local id = obj:GetInstanceID()
	self.m_MountObjs[id] = obj
	local list = self.m_Type2IDs[sType] or {}
	table.insert(list, id)
	self.m_Type2IDs[sType] = list
	if self:IsManageRenderType(sType) then
		self:AddRenderObj(obj.m_GameObject)
	end
	
	self:DelayCall(0, "SetLayer", self:GetLayer(), true)
end

function CModel.IsManageRenderType(self, sType)
	if sType == "weapon" then
		return true
	end
end

function CModel.DelObjType(self, sType)
	local list = self.m_Type2IDs[sType]
	if list then
		for i, id in pairs(list) do
			local obj = self.m_MountObjs[id]
			if obj then
				if self:IsManageRenderType(sType) then
					self:DelRenderObj(obj.m_GameObject)
				end
				g_ResCtrl:PutCloneInCache(obj:GetCacheKey(), obj.m_GameObject)
				self.m_MountObjs[id] = nil
			end
		end
		self.m_Type2IDs[sType] = nil
	end
end

function CModel.SetSpeed(self, iSpeed)
	self.m_Animator.speed = iSpeed
end

function CModel.Play(self, sState, normalizedTime)
	self:LoadAndAction(sState, function(oAnimator, layer)
		local iHash = ModelTools.StateToHash(sState)
		normalizedTime = normalizedTime or 0
		oAnimator:Play(iHash, layer, normalizedTime)
	end)
end

function CModel.PlayInFixedTime(self, sState, fixedTime)
	self:LoadAndAction(sState, function(oAnimator, layer)
		local iHash = ModelTools.StateToHash(sState)
		fixedTime = fixedTime or 0
		oAnimator:PlayInFixedTime(iHash, layer, fixedTime)
	end)
end

function CModel.CrossFade(self, sState, iDuration, normalizedTime)
	self:LoadAndAction(sState, function(oAnimator, layer)
		iDuration = iDuration or 0
		normalizedTime = normalizedTime or 0
		local iHash = ModelTools.StateToHash(sState)
		oAnimator:CrossFade(iHash, iDuration, layer, normalizedTime)
	end)
end

function CModel.CrossFadeInFixedTime(self, sState, iDuration, fixedTime)
	self:LoadAndAction(sState, function(oAnimator, layer)
		local iHash = ModelTools.StateToHash(sState)
		iDuration = iDuration or 0
		fixedTime = fixedTime or 0
		oAnimator:CrossFadeInFixedTime(iHash, iDuration, layer, fixedTime)
	end)
end

function CModel.LoadAndAction(self, sState, action)
	self:SetState(sState)

	if self:CheckLoadAnim(sState) then --第一次设置要延迟一帧才能生效
		self:DelayCall(0, "DoAction", sState, action)
	else
		self:StopDelayCall("DoAction")
		self:DoAction(sState, action)
	end
end

function CModel.ProcessBakAnimatorInfo(self)
	if next(self.m_BakAnimatorInfo.clips) then
		local oAnimatorController = self.m_Animator.runtimeAnimatorController
		self.m_Animator.runtimeAnimatorController = self.m_BakAnimatorInfo.controller
		for k, v in pairs(self.m_BakAnimatorInfo.clips) do
			oAnimatorController:set_Item(k, v)
		end
		self.m_BakAnimatorInfo.clips = {}
		self.m_BakAnimatorInfo.controller = oAnimatorController
		if self.m_DataContainer then
			self.m_DataContainer.animatorOverrideController = oAnimatorController
		end
	end
end

function CModel.DoAction(self, sState, action)
	self:ProcessBakAnimatorInfo()
	action(self.m_Animator, self.m_Layer)
end

function CModel.SetState(self, sState)
	self.m_State = sState
	self:CheckAnimEffect(sState)
end

function CModel.GetState(self)
	return self.m_State
end

function CModel.SetParent(self, parent, bWorldPositionStays)
	CRenderObject.SetParent(self, parent, bWorldPositionStays)
end

function CModel.DebugPrint(self, ...)

end

return CModel