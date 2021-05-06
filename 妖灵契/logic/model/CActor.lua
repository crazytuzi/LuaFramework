local CActor = class("CActor", CObject)

--多个model的容器
function CActor.ctor(self)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/ActorNode.prefab")
	CObject.ctor(self, obj)
	self.m_OffsetScale = 1
	self.m_IsIgnoreTimescale = false
	self.m_PriorLoad = false
	self.m_ConfigObjs = {}
	self:InitValue()
end

function CActor.InitValue(self)
	self.m_Shape = nil
	self.m_Speed = 1
	self.m_ActID = 0
	self.m_MainModel = nil
	self.m_ParentModel = nil
	self.m_ChangeDoneCb = nil
	self.m_DefaultState = "idleCity"
	self.m_CurState = nil
	self.m_ParentLoadingShape = nil
	self.m_CurDesc = {}
	self.m_MainModelCbList = {}
	self.m_HeightInfo = {}
	--  size_obj, collider, head_trans, waist_trans, waist_trans, waist_trans, foot_trans 
	--  self.m_ConfigObjs = {}
	self.m_MaterialColor = nil
	
	--组合动作
	self.m_ComboHitEvent = {}
	self.m_ComboActList = nil
	--动作映射
	self.m_StateMaps = {} --key: main dizzy
	--模型信息
	self.m_ModelInfos = {} --key: main ,
	self.m_MatColor = Color.white
	self.m_SubModels = {}
	self.m_ModelOutline = 0.01
	self.m_FixedPos = nil
	self.m_LockState = nil
	self.m_DefaultAngles = Vector3.zero
	self.m_Effects = {}
	self.m_ModelConfig = nil
end

function CActor.SetOffsetScale(self, iScale)
	self.m_OffsetScale = iScale
end

function CActor.LockState(self, state)
	self.m_LockState = state
end

--getter setter
function CActor.SetPriorLoad(self, b)
	self.m_PriorLoad = b
end

function CActor.SetConfigObjs(self, tObjs)
	self.m_ConfigObjs = tObjs
end

function CActor.SetColliderEnbled(self, b)
	local collider = self.m_ConfigObjs.collider
	if collider then
		collider.enabled = b
	end
end

function CActor.SetHeightInfo(self, tHeightInfo)
	if not tHeightInfo then
		return
	end
	for k, v in pairs(tHeightInfo) do
		if k == "fly_height" then
			self:SetLocalPos(Vector3.New(0,v,0))
		elseif k == "head_height" then
			if self.m_ConfigObjs["head_trans"] then
				self.m_ConfigObjs["head_trans"].localPosition = Vector3.New(0,v,0)
			end
		elseif k == "waist_height" then
			if self.m_ConfigObjs["waist_trans"] then
				self.m_ConfigObjs["waist_trans"].localPosition = Vector3.New(0,v,0)
			end
		elseif k == "foot_height" then
			if self.m_ConfigObjs["foot_trans"] then
				self.m_ConfigObjs["foot_trans"].localPosition = Vector3.New(0,v,0)
			end
		end
	end
	self.m_HeightInfo = tHeightInfo
end

function CActor.SetModelOutline(self, i)
	self.m_ModelOutline = i
	self:AllModelCall(CModel.SetOutline, i)
end

function CActor.SetMatColor(self, color)
	self.m_MatColor = color
	self:AllModelCall(CModel.SetMatColor, color)
end

function CActor.GetMatColor(self)
	return self.m_MatColor
end

function CActor.SetFixedPos(self, pos)
	self.m_FixedPos = pos
end

function CActor.SetDefaultAnlge(self, angles)
	self.m_DefaultAngles = angles
end

function CActor.SetRoot(self, oRoot)
	self.m_Root = oRoot
end

function CActor.GetShape(self)
	return self.m_Shape
end

function CActor.GetMainModelPath(self, iShape, dModelInfo)
	if dModelInfo.weapon then
		local idx = ModelTools.GetAnimatorIdx(iShape, dModelInfo.weapon)
		if idx and idx > 1 then
			local sPosfix = "_"..tostring(idx)
			local path = string.format("Model/Character/%d/Prefabs/model%d%s.prefab", iShape, iShape, sPosfix)
			if g_ResCtrl:IsExist(path) then
				return path
			end
		end
	end
	return self:GetPath(iShape)
end

function CActor.GetPath(self, iShape)
	local path = string.format("Model/Character/%d/Prefabs/model%d.prefab", iShape, iShape)
	return path
end

function CActor.GetMainModel(self)
	return self.m_MainModel
end

function CActor.GetModelInfo(self, sType)
	sType = sType or "main"
	return self.m_ModelInfos[sType]
end

function CActor.IsFly(self)
	return self.m_HeightInfo.fly_height and self.m_HeightInfo.fly_height > 0 or false
end

--model相关start--
--每个挂上去的model都这样设置
function CActor.SetupModel(self, oModel, iShape, sPath)
	oModel:SetCacheKey(sPath)
	oModel:SetModelShape(iShape)
	oModel:SetPriorLoad(self.m_PriorLoad)
	oModel:SetSpeed(self.m_Speed)
	oModel:SetMatColor(self.m_MatColor)
	oModel:SetOutline(self.m_ModelOutline)
	-- oModel:SetLocalEulerAngles(Vector3.zero)
end

function CActor.SetModelConfig(self, dConfig)
	self.m_ModelConfig = dConfig
end

function CActor.Resize(self)
	if self.m_Shape then
		local dConfig = self.m_ModelConfig or ModelTools.GetModelConfig(self.m_Shape)
		local collider =  self.m_ConfigObjs.collider
		if collider then
			collider.center = Vector3.New(0, dConfig.collider_y, 0)
			collider.radius = dConfig.collider_r
			collider.height = dConfig.collider_h
		end
		
		local size = dConfig.size * (self:GetModelInfo().scale or 1) * self.m_OffsetScale
		local oSizeObj =  self.m_ConfigObjs.size_obj or self
		oSizeObj:SetLocalScale(Vector3.New(size, size, size))
	end
end

function CActor.MainModelCall(self, func, ...)
	if self.m_MainModel then
		func(self.m_MainModel, ...)
	else
		local args = {...}
		local len = select("#", ...)
		table.insert(self.m_MainModelCbList, objcall(self, function(obj) 
				if obj.m_MainModel then
					func(obj.m_MainModel, unpack(args, 1, len))
				end
			end))
	end
end

function CActor.AllModelCall(self, func, ...)
	self:DebugPrint(...)
	local list = {self.m_MainModel, self.m_ParentModel}
	for i, dInfo in pairs(self.m_SubModels) do
		table.insert(list, dInfo.model)
	end
	for i, oModel in pairs(list) do
		func(oModel, ...)
	end
end

function CActor.LoadMaterial(self, sMatPath, dInfo)
	self:MainModelCall(CRenderObject.LoadMaterial, sMatPath, dInfo)
end

function CActor.DelMaterial(self, sMatPath)
	if self.m_MainModel then
		self.m_MainModel:DelMaterial(sMatPath)
	end
end

function CActor.ChekcShape(self, iShape)
	local sPath = self:GetPath(iShape)
	if not g_ResCtrl:IsExist(sPath) then
		printc(string.format("没有%d模型资源,用默认造型301.",iShape))
		iShape = 301
	end
	return iShape
end

function CActor.ChangeShape(self, iShape, dModelInfo, cb)
	if not iShape then
		editor.error("CActor.ChangeShape iShape is nil")
		return
	end
	iShape = self:ChekcShape(iShape)
	dModelInfo = table.copy(dModelInfo) or {}
	local oldinfo = self.m_ModelInfos["main"] or {}
	self.m_ModelInfos["main"] = dModelInfo
	if self.m_Shape == iShape and oldinfo.weapon == dModelInfo.weapon then
		if cb then
			Utils.AddScaledTimer(cb, 0, 0)
		end
		if self.m_MainModel then
			self.m_MainModel:SetInfo(self.m_ModelInfos["main"])
		end
	else
		self:DestroyAllModel()
		self.m_Shape = iShape
		self.m_ChangeDoneCb = cb
		local sPath = self:GetMainModelPath(iShape, dModelInfo)
		g_ResCtrl:LoadCloneAsync(sPath, callback(self, "OnChangeDone", iShape), self.m_PriorLoad)
	end
	local iDefaultHorse = data.horsedata.DEFALUT[iShape]
	dModelInfo.horse = iDefaultHorse
	if dModelInfo.horse then
		self:AddHorse(iShape)
	else
		self:DelHorse(iShape)
	end
end

function CActor.OnChangeDone(self, iShape, oClone, sPath)
	if self.m_Shape ~= iShape then
		g_ResCtrl:PutCloneInCache(sPath, oClone)
		return
	end
	if self.m_MainModel then
		print("Actor:已存在MainModel")
		self.m_MainModel:Recycle()
		self.m_MainModel = nil
	end
	-- self:SetName(string.format("Actor_%d", iShape))
	self:Resize()
	self:LoadSubModels()
	if oClone then
		self.m_MainModel = CModel.New(oClone)
		if not self:MountToParentModel() then
			self.m_MainModel:SetParent(self.m_Transform)
		end
		self:SetupModel(self.m_MainModel, iShape, sPath)
		self.m_MainModel:SetInfo(self.m_ModelInfos["main"])
		self:Play(self:GetState())
		self:SetLayerDeep(self:GetLayer())
		
		local v1, v2, v3 = self.m_MainModel:GetHeights()
		local tHeightInfo = {
			head_height = v1 and self:InverseTransformPoint(v1).y or nil,
			waist_height = v2 and self:InverseTransformPoint(v2).y or nil,
			foot_height = v3 and self:InverseTransformPoint(v3).y or nil,
		}
		self:SetHeightInfo(tHeightInfo)
		for i, cb in pairs(self.m_MainModelCbList) do
			cb()
		end
		self.m_MainModelCbList = {}
	end
	if self.m_ChangeDoneCb then
		self.m_ChangeDoneCb()
		self.m_ChangeDoneCb = nil
	end
end

function CActor.LoadSubModels(self)
	local dData = data.modeldata.SUB_MODELS[self.m_Shape]
	if not dData then
		return
	end
	for iSubShape, dSubData in pairs(dData) do
		local sPath = self:GetPath(iSubShape)
		g_ResCtrl:LoadCloneAsync(sPath, callback(self, "OnSubLoadDone", self.m_Shape, iSubShape, dSubData.parent_type), self.m_PriorLoad)
	end
end

function CActor.OnSubLoadDone(self, iMainShape, iSubShape, sParentType, oClone, sPath)
	if self.m_Shape ~= iMainShape then
		oClone:Destroy()
		return
	end
	local oModel = CModel.New(oClone)
	local oParent = self
	if sParentType == "root" and self.m_Root then
		oParent = self.m_Root
	end
	self:SetupModel(oModel, iSubShape, sPath)
	oModel:SetParent(oParent.m_Transform)
	oModel:SetLayerDeep(oParent:GetLayer())
	oModel:SetEulerAngles(self.m_DefaultAngles)
	if self.m_FixedPos then
		oModel:SetPos(self.m_FixedPos)
	end
	local obj = self.m_ConfigObjs.size_obj or self
	local comp = oModel:GetMissingComponent(classtype.DataContainer)
	comp.gameObjectValue = obj.m_GameObject
	oModel:SetName(obj:GetName().."_SubModel")
	self:Play(self:GetState())
	if self:GetLayer() == define.Layer.Hide then
		Utils.HideObject(oModel)
	end
	self.m_SubModels[iSubShape] = {model=oModel, parent_type=sParentType}
end

function CActor.UpdateSubModels(self)
	for i, dSub in pairs(self.m_SubModels) do
		if dSub.parent_type == "root" then
			if self.m_FixedPos then
				dSub.model:SetPos(self.m_FixedPos)
			end
			dSub.model:SetEulerAngles(self.m_DefaultAngles)
		end
	end
end

function CActor.HideSubModels(self)
	for i, dSub in pairs(self.m_SubModels) do
		if dSub.parent_type == "root" then
			Utils.HideObject(dSub.model)
		end
	end
end

function CActor.ShowSubModels(self)
	for i, dSub in pairs(self.m_SubModels) do
		if dSub.parent_type == "root" then
			Utils.ShowObject(dSub.model)
		end
	end
end

function CActor.AddHorse(self, iShape)
	local model_info = self.m_ModelInfos["main"]
	if not model_info then
		return
	end
	local iHorseType = model_info.horse
	if not iHorseType then
		return
	end
	local dData = data.horsedata.DATA[iHorseType]
	if not dData then
		print("不存在坐骑数据"..tostring(iHorseType))
		return
	end
	local iHorseShape = dData.shape
	if dData.fixed_pos and self.m_Root then
		local sPath = self:GetPath(iHorseShape)
		g_ResCtrl:LoadCloneAsync(sPath, callback(self, "OnSubLoadDone", iShape, iHorseShape, "root"), self.m_PriorLoad)
	else
		local bLoadSame = self.m_ParentModel and self.m_ParentModel:GetModelShape() ~= iHorseShape
		if bLoadSame or self.m_ParentLoadingShape ~= iHorseShape then
			self.m_ParentLoadingShape = iHorseShape	
			local dModelInfo = {}
			local path = self:GetPath(iHorseShape)
			g_ResCtrl:LoadCloneAsync(path, callback(self, "OnParentLoadDone", iShape, iHorseShape, "rider", dModelInfo, dData.height_info, dData.anim_map), self.m_PriorLoad)
		end
	end
end

function CActor.DelHorse(self)
	if self.m_ParentModel then
		self.m_ParentModel:Destroy()
		self.m_ParentModel = nil
	end
	self.m_StateMaps["main"] = nil
	self:SetHeightInfo(nil)
	if self.m_MainModel then
		self.m_MainModel:SetParent(self.m_Transform)
	end
end

function CActor.OnParentLoadDone(self, iMainShape, iParentShape, sMountType, dModelInfo, dHeightInfo, dAnimMap, oClone, sPath)
	if iParentShape ~= self.m_ParentLoadingShape or iMainShape ~= self.m_Shape then
		g_ResCtrl:PutCloneInCache(sPath, oClone)
		if self.m_ParentLoadingShape == iParentShape then
			self.m_ParentLoadingShape = nil
		end
		return
	end
	self.m_ParentLoadingShape = nil
	if oClone then
		if self.m_ParentModel then
			self.m_ParentModel:Destroy()
		end
		self.m_ParentModel = CModel.New(oClone)
		self:SetupModel(self.m_ParentModel, iParentShape, sPath)
		self.m_ParentModel:SetName(string.format("ParentModel_%d", iParentShape))
		self.m_ParentModel:SetMountType(sMountType)
		self.m_ParentModel:SetInfo(dModelInfo)
		self.m_ParentModel:SetParent(self.m_Transform)
		self:MountToParentModel()
		self:Play(self:GetState())
		self:SetLayerDeep(self:GetLayer())
		self:SetHeightInfo(dHeightInfo)
		self.m_StateMaps["main"] = dAnimMap
	end
end

function CActor.MountToParentModel(self)
	if self.m_MainModel and self.m_ParentModel then
		local trans = self.m_ParentModel:GetMountTransform()
		if trans then
			self.m_MainModel:SetParent(trans)
			return true
		end
	end
	return false
end

function CActor.BindObjByIdx(self, idx, fGet)
	local all = {}
	if self.m_MainModel then
		all = {self.m_MainModel}
		for _, v in pairs(self.m_MainModel.m_MountObjs) do
			table.insert(all, v)
		end
	end
	for _, v in pairs(self.m_SubModels) do
		table.insert(all, v)
	end
	local objs = {}
	for _, v in pairs(all) do
		if v.GetContainTransform then
			local trans = v:GetContainTransform(idx)
			if trans then
				local oClone = fGet()
				oClone:SetParent(trans, false)
				v:AddDestroyOnRecycle(oClone)
				table.insert(objs, oClone)
			end
		end
	end
	return objs
end

function CActor.BindObjByFind(self, sName, fGet)
	local oWasitTans = self.m_ConfigObjs["waist_trans"]
	self:MainModelCall(function(oModel) 
			local oClone = fGet()
			local trans = oModel:Find(sName) or oWasitTans
			if trans then
				oClone:SetParent(trans, false)
				oModel:AddDestroyOnRecycle(oClone)
			end
		end)
end

function CActor.DestroyAllModel(self)
	if self.m_MainModel then
		self.m_MainModel:Recycle()
		self.m_MainModel = nil
	end
	if self.m_ParentModel then
		self.m_ParentModel:Destroy()
		self.m_ParentModel = nil
	end
	for _, dInfo in pairs(self.m_SubModels) do
		dInfo.model:Destroy()
	end
	self.m_SubModels = {}
	for _, oEff in pairs(self.m_Effects) do
		oEff:Destroy()
	end
	self.m_Effects = {}
end
--model相关end-

function CActor.Clear(self)
	self:DestroyAllModel()
	self:InitValue()
end

function CActor.Destroy(self)
	self:DestroyAllModel()
	CObject.Destroy(self)
end

--组合动作combo
function CActor.PlayCombo(self, actname)
	local shape = self.m_Shape
	if not data.comboactdata.DATA[shape] then
		return false
	end
	local list = data.comboactdata.DATA[shape][actname]
	if not list then
		return false
	end
	self.m_ComboActList = list
	self.m_ComboIdx = 1
	self:ComboStep()
	return true
end

function CActor.IsComboing(self)
	return self.m_ComboActList ~= nil
end

function CActor.ComboStep(self)
	if not self.m_ComboActList then
		return
	end
	local act = self.m_ComboActList[self.m_ComboIdx]
	if not act then
		self.m_ComboHitEvent = {}
		self.m_ComboActList = nil
		return
	end
	local speed = act.speed
	self.m_ComboIdx = self.m_ComboIdx + 1
	if act.action == "pause" then
		self:Pause(act.hit_frame-act.start_frame, callback(self, "ComboStep"))
	else
		self:PlayInFrame(act.action, act.start_frame/speed, act.end_frame/speed, callback(self, "ComboStep"))
		act.hit_frame = tonumber(act.hit_frame)
		self:SetSpeed(speed)
		if act.hit_frame then
			self:FrameEvent(act.action, (act.hit_frame-act.start_frame)/speed, callback(self, "NotifyComboHit"))
		end
	end
end

function CActor.SetComboHitEvent(self, cb)
	table.insert(self.m_ComboHitEvent, cb)
end

function CActor.NotifyComboHit(self)
	for i, cb in ipairs(self.m_ComboHitEvent) do
		cb()
	end
end

--animator
function CActor.SetStateMap(self, key, dMap)
	self.m_StateMaps[key] = dMap
	local d = self:GetAnimMap()
	if d[self.m_CurState] then
		self:AllModelCall(CModel.Play, d[self.m_CurState], 1)
	end
end

function CActor.GetAnimMap(self)
	local t1 = table.copy(self.m_StateMaps["main"]) or {}
	local t2 = table.copy(self.m_StateMaps["dizzy"]) or {}
	table.update(t1, t2)
	return t1
end

function CActor.SetDefaultState(self, sState)
	self.m_DefaultState = sState
end

function CActor.GetState(self)
	return self.m_CurState or self.m_DefaultState
end
function CActor.NormalSpeed(self)
	self:SetSpeed(1)
end

function CActor.SetSpeed(self, iSpeed)
	if self.m_Speed ~= iSpeed then
		self.m_Speed = iSpeed
		if self.m_MainModel then
			self.m_MainModel:SetSpeed(iSpeed)
		end
	end
end

function CActor.GetFinalState(self, sState)
	local map = self:GetAnimMap()
	local sState = map[sState] or sState
	return sState
end

function CActor.GetAnimClipInfo(self, sState)
	return ModelTools.GetAnimClipInfo(self.m_Shape, sState, self:GetAnimatorIdx())
end

function CActor.GetAnimatorIdx(self)
	if self.m_MainModel then
		return self.m_MainModel.m_AnimatorIdx
	else
		return 1
	end
end

function CActor.CheckLockState(self, sState)
	if (self.m_LockState ~= nil) and self.m_MainModel and  
		(self.m_MainModel:GetState() == self.m_LockState) then
		print(string.format("%s已动作锁定:%s, 取消播放:%s", self:GetName(), self.m_LockState, sState))
		return true
	else
		return false
	end
end

function CActor.AdjustSpeedPlay(self, sState, iAdjustTime)
	if self:CheckLockState(sState) then
		return
	end
	self:PlayInFixedTime(sState)
	sState = self:GetFinalState(sState)
	local dClipInfo = self:GetAnimClipInfo(sState)
	self:SetSpeed(dClipInfo.length / iAdjustTime)
end

function CActor.AdjustSpeedPlayInFrame(self, sState, iAdjustTime, iStartFrame, iEndFrame, func)
	if self:CheckLockState(sState) then
		return
	end
	sState = self:GetFinalState(sState)
	if not iEndFrame then
		local dClipInfo = self:GetAnimClipInfo(sState)
		iEndFrame = dClipInfo.frame
	end
	local iTime = ModelTools.FrameToTime(iEndFrame-iStartFrame)
	local iSpeed = iAdjustTime and (iTime / iAdjustTime) or 1
	self:PlayInFrame(sState, iStartFrame, iStartFrame+(iEndFrame-iStartFrame)/iSpeed, func)
	self:SetSpeed(iSpeed)
end

function CActor.Play(self, sState, startNormalized, endNormalized, func)
	if self:CheckLockState(sState) then
		return
	end
	self:ResetState()
	sState = self:GetFinalState(sState)
	self.m_CurState = sState
	self.m_ActID = self.m_ActID + 1
	self:AllModelCall(CModel.Play, sState, startNormalized)
	if endNormalized then
		local fixedTime = ModelTools.NormalizedToFixed(self.m_Shape, self:GetAnimatorIdx(),sState, endNormalized-startNormalized)
		self:FixedEvent(sState, fixedTime, func)
	end
end

function CActor.PlayInFixedTime(self, sState, startFixed, endFixed, func)
	if self:CheckLockState(sState) then
		return
	end
	self:ResetState()
	sState = self:GetFinalState(sState)
	self.m_CurState = sState
	self.m_ActID = self.m_ActID + 1
	self:AllModelCall(CModel.PlayInFixedTime, sState, startFixed)
	if endFixed then
		self:FixedEvent(sState, startFixed-endFixed, func)
	end
end

function CActor.CrossFade(self, sState, duration, startNormalized, endNormalized, func)
	if self:CheckLockState(sState) then
		return
	end
	self:ResetState()
	sState = self:GetFinalState(sState)
	self.m_CurState = sState
	self.m_ActID = self.m_ActID + 1
	self:AllModelCall(CModel.CrossFade, sState, duration, startNormalized)

	if endNormalized then
		local fixedTime = ModelTools.NormalizedToFixed(self.m_Shape, self:GetAnimatorIdx(), sState, endNormalized-startNormalized)
		self:FixedEvent(sState, fixedTime, func)
	end
end

function CActor.CrossFadeInFixedTime(self, sState, duration, startFixed, endFixed, func)
	if self:CheckLockState(sState) then
		return
	end
	self:ResetState()
	sState = self:GetFinalState(sState)
	self.m_CurState = sState
	self.m_ActID = self.m_ActID + 1
	self:AllModelCall(CModel.CrossFadeInFixedTime, sState, duration, startFixed)
	if endFixed then
		self:FixedEvent(sState, endFixed-startFixed, func)
	end
end

function CActor.PlayInFrame(self, sState, startFrame, endFrame, func)
	if self:CheckLockState(sState) then
		return
	end
	local dClipInfo = self:GetAnimClipInfo(sState)
	local startNormalized = startFrame / dClipInfo.frame
	self:Play(sState, startNormalized)
	if endFrame then
		local fixedTime = ModelTools.FrameToTime(endFrame-startFrame)
		self:FixedEvent(sState, fixedTime, func)
	end
end

function CActor.CrossFadeInFrame(self, sState, duration, startFrame, endFrame, func)
	if self:CheckLockState(sState) then
		return
	end
	local dClipInfo = self:GetAnimClipInfo(sState)
	local startNormalized = startFrame / dClipInfo.frame
	self:CrossFade(sState, duration, startNormalized)
	if endFrame then
		local fixedTime = ModelTools.FrameToTime(endFrame-startFrame)
		self:FixedEvent(sState, fixedTime, func)
	end
end

function CActor.Pause(self, frame, cb)
	self:ResetState()
	self.m_ActID = self.m_ActID + 1
	self:SetSpeed(0)
	self:FrameEvent("pause", frame, cb)
end

function CActor.ResetState(self)
	if self.m_EventTimer then
		Utils.DelTimer(self.m_EventTimer)
		self.m_EventTimer = nil
	end
	if not self:IsComboing() then
		self:NormalSpeed()
	end
end

function CActor.FixedEvent(self, sState, fixedTime, func)
	fixedTime = (fixedTime or 1) - 0.01
	local iActID = self.m_ActID
	self.m_EventTimer = Utils.AddScaledTimer(callback(self, "OnEvent", iActID, func, fixedTime), 0, fixedTime)
end

function CActor.NomallizedEvent(self, sState, normalizedTime, func)
	local dClipInfo = self:GetAnimClipInfo(sState)
	self:FixedEvent(sState, dClipInfo.length, func)
end

function CActor.FrameEvent(self, sState, frame, func)
	local fixedTime = ModelTools.FrameToTime(frame)
	self:FixedEvent(sState, fixedTime, func)
end

function CActor.OnEvent(self, actid, func, fixedTime)
	if self.m_ActID == actid and func then
		func(self)
	end
	self.m_EventTimer = nil
end

function CActor.DebugPrint(self, ...)
	if self:GetInstanceID() == CWarrior.g_TestActorID then
		printerror(...)
	end
end

function CActor.GetHitKeyFrame(self)
	local d = self:GetAnimClipInfo("hit1")
	return d.frame
end

function CActor.CrossFadeLoop(self, sState, duration, startNormalized, endNormalized, isLoop, func)
	self:ResetState()
	sState = self:GetFinalState(sState)
	self.m_CurState = sState
	self.m_ActID = self.m_ActID + 1
	self:AllModelCall(CModel.CrossFade, sState, duration, startNormalized)

	if endNormalized then
		self:StopCrossFadeLoop()
		local fixedTime = ModelTools.NormalizedToFixed(self.m_Shape, self:GetAnimatorIdx(), sState, endNormalized-startNormalized)
		local function loop(obj)
			if func then
				func()
			end
			obj:AllModelCall(CModel.CrossFade, sState, duration, startNormalized)
			if isLoop then
				return true
			else
				return false
			end
		end
		self.m_EventLoopTimer = Utils.AddScaledTimer(objcall(self, loop), fixedTime , 0)
	end
end

function CActor.StopCrossFadeLoop(self)
	if self.m_EventLoopTimer then
		Utils.DelTimer(self.m_EventLoopTimer)
		self.m_EventLoopTimer = nil
	end
end

function CActor.RePlay(self)
	self:Play(self:GetState())
end

function CActor.SetWeaponActive(self, bValue)
	self:MainModelCall(CModel.SetWeaponActive, bValue)
end

return CActor