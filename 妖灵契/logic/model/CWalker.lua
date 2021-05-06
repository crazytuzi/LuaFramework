local CWalker = class("CWalker", CObject)

define.Walker = {
	Move_Speed = 2.4,
	CrossFade_Time = 0.01,
	Follow_Distance = 0.7,
	Npc_Talk_Distance = 1,
	Npc_Dialogue_Dalta_Time = 0.25,
}

function CWalker.ctor(self, obj)
	CObject.ctor(self, obj)
	self.m_Actor = CActor.New()
	self.m_Actor:SetParent(self.m_Transform)
	self.m_NeedShadow = false
	self.m_Shadow = nil
	self.m_WalkEventHandler = self:GetComponent(classtype.WalkerEventHandler)
	self.m_Delegate = nil
	self.m_Speed = define.Walker.Move_Speed
	self:InitValue()
end

function CWalker.InitValue(self)
	self.m_Walker = nil
	self.m_Path = nil
	self.m_IsWalking = false
	self.m_IsFollowing = false
	self.m_TargetPos = nil
	self.m_Is3D = false
	self.m_Shape = nil
	self.m_ModelInfo = nil
	self.m_CheckInScreen = false
	self.m_IsInScreen = true
	self.m_Timer = nil
	self.m_WalkCompleteCb = nil
	self.m_WalkerStartCb = nil
	self.m_IdleActionName = "idleCity"
	self.m_WalkActionName = "run"
	self.m_PlayingSociaty = false
	self.m_SociatyTargetID = 0
	self.m_ChangeDoneCb = nil
	self.m_WalkConfig = {}
end

function CWalker.SetNeedShadow(self, b)
	self.m_NeedShadow = b
	self:CheckShodow()
end

function CWalker.CheckShodow(self)
	if self.m_NeedShadow and not self.m_Shadow and not self.m_ShadowLoading then
		self.m_ShadowLoading = true
		g_ResCtrl:LoadCloneAsync("Effect/Prefabs/footshadow.prefab", callback(self, "OnShadowLoadDone"), true)
	elseif not self.m_NeedShadow and self.m_Shadow then
		self:RecycleShadow()
	end
end

function CWalker.OnShadowLoadDone(self, oClone, path)
	self.m_ShadowLoading = false
	if self.m_NeedShadow then
		self.m_Shadow = CObject.New(oClone)
		self.m_Shadow:SetLayer(self:GetLayer())
		self.m_Shadow:SetParent(self.m_Transform)
		self.m_Shadow:SetCacheKey(path)
		return true
	else
		return false
	end
end

function CWalker.CheckVisibleEvent(self)
	if self.m_WalkEventHandler then
		if self.m_CheckInScreen then
			self.m_Delegate = g_DelegateCtrl:NewDelegate(callback(self, "OnBecameVisible"))
			self.m_WalkEventHandler:StartCheckVisible(self.m_Delegate:GetID(), 1.1, g_CameraCtrl:GetMainCamera().m_Camera)
		else
			self.m_WalkEventHandler:StopCheckVisible()
		end
	end
end

function CWalker.OnBecameVisible(self, b)
	if b then
		if not self.m_IsInScreen then
			self.m_IsInScreen = true
			self:CheckShodow()
			if self.m_Shape ~= self.m_Actor:GetShape() or
				self.m_ModelInfo ~= self.m_Actor:GetModelInfo() then
				if not self.m_Is3D then
					self.m_Actor:MainModelCall(objcall(self, function(obj, oModel)
						obj.m_Walker:AddRenderObjectHandler(oModel.m_RenderHandler)
					end))
				end
				self.m_Actor:ChangeShape(self.m_Shape, self.m_ModelInfo, callback(self, "OnChangeDone"))
			end
		end
	else
		if self.m_IsInScreen then
			self.m_IsInScreen = false
			self:RecycleShadow()
			self.m_Actor:Clear()
			if not self.m_Is3D then
				self.m_Walker:ClearRenderObjectHandler()
			end
		end
	end
end

function CWalker.SetCheckInScreen(self, b)
	self.m_CheckInScreen = b
	self.m_IsInScreen = not b
	self:CheckVisibleEvent()
end

function CWalker.IsPlayingSociaty(self)
	return self.m_PlayingSociaty
end

function CWalker.PlaySociaty(self, sMotion, startNormalized, targetID)
	self:ResetSociaty()
	self.m_SociatyTargetID = targetID or 0
	self.m_PlayingSociaty = true
	self.m_Actor:SetWeaponActive(false)
	self:StopMove()
	self.m_Actor:CrossFadeLoop(sMotion, 0.01, startNormalized, 1, false)
end


function CWalker.ResetSociaty(self)
	if self.m_PlayingSociaty then
		if self.m_SociatyTargetID ~= 0 then
			local oTarget = g_MapCtrl:GetPlayer(self.m_SociatyTargetID)
			self.m_SociatyTargetID = 0
			if oTarget then
				oTarget.m_SociatyTargetID = 0
				oTarget:StopSociaty()
			end
		end
		self:StopSociaty()
	end
end
function CWalker.StopSociaty(self)
	if self.m_PlayingSociaty and not self:IsWalking()then
		self.m_Actor:CrossFadeLoop(self.m_IdleActionName, 0.01, 0, 1, false)
	end
	self.m_PlayingSociaty = false
	self.m_Actor:SetWeaponActive(true)
end

function CWalker.IsInScreen(self)
	return self.m_IsInScreen
end

function CWalker.Init3DWalker(self)
	self.m_Walker = self:GetMissingComponent(classtype.Map3DWalker)
	self.m_Is3D = true
	self.m_Walker.moveTransform = self.m_Transform
	self.m_Walker.rotateTransform = self.m_Actor.m_Transform
	self:InitWalkCB()
end

function CWalker.SetDefaultState(self, sState)
	self.m_Actor:SetDefaultState(sState)
end

function CWalker.SetMoveSpeed(self, iSpeed)
	if self.m_Speed ~= iSpeed then
		self.m_Speed = iSpeed 
		self.m_Walker.moveSpeed = iSpeed
	end
end

function CWalker.Init2DWalker(self)
	self.m_Walker = self:GetMissingComponent(classtype.Map2DWalker)
	self.m_Is3D = false
	self.m_Walker.moveTransform = self.m_Transform
	self.m_Walker.rotateTransform = self.m_Actor.m_Transform
	self:InitWalkCB()
end

function CWalker.ResetHeight(self)
	local vPos = self:GetPos()
	if self.m_Is3D then
		if g_MapCtrl.m_CurMapObj then
			vPos.y = g_MapCtrl.m_CurMapObj.m_MapCompnent:GetHeight(vPos.x, vPos.z)
		end
	end
	self:SetPos(vPos)
end

function CWalker.SetMapID(self, mapid)
	mapid = mapid or 0
	if not Utils.IsNil(self) then
		self.m_Walker:SetMapID(mapid)
	end
end

function CWalker.Destroy(self)
	self:RecycleShadow()
	if self.m_Actor then
		self.m_Actor:Destroy()
		self.m_Actor = nil
	end
	CObject.Destroy(self)
end

function CWalker.InitWalkCB(self)
	self.m_Walker:SetWalkEndCallback(callback(self, "OnStopPath"))
	self.m_Walker:SetWalkStartCallback(callback(self, "OnStartPath"))
end

function CWalker.ReleaseWalkCB(self)
	self.m_Walker:SetWalkEndCallback(function() end)
	self.m_Walker:SetWalkStartCallback(function() end)
end

function CWalker.WalkTo(self, x, yORz, completeCb, startCb, walkconfig)
	self.m_Path = nil
	self.m_WalkConfig = walkconfig
	if self.m_StopTimer then
		Utils.DelTimer(self.m_StopTimer)
		self.m_StopTimer = nil
	end
	if g_MapCtrl:GetCurMapObj() then
		if self:IsCanWalk() then
			self.m_TargetPos = Vector2.New(x, yORz)
			self.m_WalkerStartCb = startCb
			self.m_WalkCompleteCb = completeCb
			self.m_Walker:WalkTo(x, yORz, true)
			--引导检查
			if self.classname == "CHero" then
				g_GuideCtrl:CheckTaskNvGuide(true, true)
			end
		else
			self:OnStartWalk()
			if startCb then
				startCb(self)
			end
			if completeCb then
				completeCb(self)
			end
		end
	else
		print("没有地图，直接设置位置")
		if self.m_Is3D then
			self:SetLocalPos(Vector3.New(x, 0, yORz))
		else
			self:SetLocalPos(Vector3.New(x, yORz, 0))
		end
		if startCb then
			startCb(self)
		end
		if completeCb then
			completeCb(self)
		end
	end
end

function CWalker.IsCanWalk(self)
	return not self.m_IsFollowing
end

function CWalker.StopWalk(self)
	self:StopMove()
	self.m_WalkConfig = {}
	self:CrossFade(self.m_IdleActionName, define.Walker.CrossFade_Time)
end

function CWalker.StopMove(self)
	self.m_Path = nil
	self.m_TargetPos = nil
	self.m_IsWalking = false
	self.m_Walker:StopWalk()
	self:DelBindObj("auto_find")
end

function CWalker.GetWayPointIndex(self)
	local index = self.m_Walker:GetWayPointIndex()
	return index
end

--当前寻路关键点
function CWalker.GetWayPoint(self)
	local x, y = self.m_Walker:GetWayPoint()
	return x, y
end

--当前路径
function CWalker.GetPath(self)
	if self.m_IsWalking then
		if not self.m_Path then
			local t = self.m_Walker:GetPath()
			local pathlist = {}
			for i = 1, #t/2 do
				table.insert(pathlist, Vector3.New(t[i*2 - 1], t[i*2], 0))
			end
			if #pathlist == 1 and self:GetPos() ~= pathlist[1] then
				table.insert(pathlist, 1, self:GetPos())
			end
			self.m_Path = pathlist
		end
		return self.m_Path
	end
end

function CWalker.IsWalking(self)
	return self.m_IsWalking
end

function CWalker.OnStartPath(self)
	self.m_IsWalking = true
	self:ResetSociaty()
	if self:GetState() ~= self.m_WalkActionName then
		self:CrossFade(self.m_WalkActionName, define.Walker.CrossFade_Time)
	end
	self:OnStartWalk(self.m_WalkConfig)
	if self.m_WalkerStartCb then
		self.m_WalkerStartCb(self)
		self.m_WalkerStartCb = nil
	end
end

function CWalker.OnStopPath(self)
	local targetPos = self.m_TargetPos
	self.m_Path = nil
	self.m_IsWalking = false
	self.m_TargetPos = nil

	if self.m_WalkCompleteCb then
		local oPos = self:GetPos()
		if self.m_Is3D then
			oPos.y = 0
			if targetPos then
				targetPos.y = 0
			end
		end
		local cb = self.m_WalkCompleteCb
		self.m_WalkCompleteCb = nil
		if UITools.CheckInDistanceXY(oPos, targetPos, 0.01) then
			cb(self)
		end
	end
	if not self.m_IsWalking then
		local stop = objcall(self, function (obj)
			if not obj.m_IsWalking and obj:GetState() ~= obj.m_IdleActionName then
				obj:CrossFade(obj.m_IdleActionName, define.Walker.CrossFade_Time)
			end
		end)
		if self.m_IsFollowing then
			self.m_StopTimer = Utils.AddTimer(stop, 0, 0.1)
		else
			stop()
		end
	end
end

function CWalker.ChangeShape(self, iShape, tDesc, func)
	self.m_ChangeDoneCb = func
	self.m_Shape = iShape
	self.m_ModelInfo = tDesc
	if self.m_CheckInScreen and not self.m_IsInScreen then
		
	else
		if not self.m_Is3D then
			self.m_Actor:MainModelCall(objcall(self, function(obj, oModel)
						obj.m_Walker:AddRenderObjectHandler(oModel.m_RenderHandler)
					end))
		end
		self.m_Actor:ChangeShape(iShape, tDesc, callback(self, "OnChangeDone"))
	end
end


function CWalker.GetState(self)
	return self.m_Actor:GetState()
end

function CWalker.OnChangeDone(self)
	local iShape = self.m_Actor:GetShape()
	self.m_Actor:SetModelOutline(data.modeldata.Outline[iShape]  or 0.01)
	self:SetLayerDeep(self.m_GameObject.layer)
	if self.m_ChangeDoneCb then
		self.m_ChangeDoneCb()
		self.m_ChangeDoneCb = nil
	end
end

function CWalker.ChangeFollow(self, oWalker, distance)
	distance = distance or define.Walker.Follow_Distance
	if oWalker == nil then
		self.m_IsFollowing = false
		self.m_Walker:Follow(nil, distance)
	else
		self.m_IsFollowing = true
		self.m_Walker:Follow(oWalker.m_Walker, distance)
	end
end

function CWalker.Follow(self, oWalker)
	self:ResetSociaty()
	self:StopWalk()
	self:ChangeFollow(oWalker)
end

function CWalker.Play(self, state, normalizedTime)
	self.m_Actor:Play(state, normalizedTime)
end

function CWalker.RePlay(self)
	self.m_Actor:RePlay()
end

function CWalker.CrossFade(self, state, duration, normalizedTime, endNormalized, cb)
	self.m_Actor:CrossFade(state, duration, normalizedTime, endNormalized, cb)
end

function CWalker.GetMainModel(self)
	return self.m_Actor:GetMainModel()
end

function CWalker.OnStartWalk(self, walkConfig)
	--override
end

return CWalker