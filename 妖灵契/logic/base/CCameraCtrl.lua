local CCameraCtrl = class("CCameraCtrl")

function CCameraCtrl.ctor(self)
	self.m_UICamera = nil
	self.m_MainCamera = nil
	self.m_NGUICamera = nil
	self.m_MapCamera = nil
	self.m_WarCamera = nil
	self.m_HouseCamera = nil
	self.m_CreateRoleCamera = nil
	self.m_BakCamera = nil
	self.m_ChoukaCamera = nil

	self.mm_CameraPathRoot = nil
	self.m_CameraPath = nil
	self.m_CameraAnimator = nil
	self.m_IsInit = false
	self.m_ModelCamPool = {}
	self.m_SpineCamPool = {}
	self.m_UIEffectCamPool = {}
	self.m_CurCamPosIdx = 0
	self.m_CachedCams = {}
	self.m_CameraGroup = {}
	self.m_WarStartPercent = nil
	Utils.AddTimer(callback(self, "CheckAll"), 0, 0.5)
end

function CCameraCtrl.InitCtrl(self)
	if self.m_IsInit == false then
		self.m_IsInit = true
		local obj = UnityEngine.GameObject.New()
		obj.name = "CameraPath"
		self.m_CameraPathRoot = obj
		self.m_CameraPath = self.m_CameraPathRoot:GetMissingComponent(classtype.CameraPath)
		self.m_CameraAnimator = self.m_CameraPathRoot:GetMissingComponent(classtype.CameraPathAnimator)
		self.m_CameraAnimator.playOnStart = false
		self.m_CameraAnimator.animationObject = self:GetWarCamera().m_Transform
		local oBakCamera = self:GetBakCamera()
		if Utils.IsIOS() then
			oBakCamera:SetEnabled(false)
		end
	end
end

function CCameraCtrl.SetMapCameraSize(self, iSize)
	local oCam = self:GetMainCamera()
	oCam:SetOrthographicSize(iSize)
	local oMapCam = self:GetMapCamera()
	oMapCam:UpdateCameraSize()
end

function CCameraCtrl.GetBakCamera(self)
	if not self.m_BakCamera then
		self.m_BakCamera = CCamera.New(UnityEngine.GameObject.Find("GameRoot/BakCamera"))
	end
	return self.m_BakCamera
end

function CCameraCtrl.GetNGUICamera(self)
	if not self.m_NGUICamera then
		self.m_NGUICamera = UnityEngine.GameObject.Find("GameRoot/UICamera"):GetComponent(classtype.UICamera)
	end
	return self.m_NGUICamera
end

function CCameraCtrl.LoadPath(self, sType)
	if Utils.IsScreen1024() and (sType == "CameraPath_War") then
		sType = sType.."1024"
	end
	local path = string.format("Config/%s.bytes", sType)
	self.m_CameraPath:FromXML(path)
end

function CCameraCtrl.GetAnimatorPercent(self)
	return self.m_AnimatorPercent
end

function CCameraCtrl.SetAnimatorPercent(self, iVal)
	if g_WarCtrl:GetWarType() == define.War.Type.BossKing then
		return
	end
	local iVal = math.max(math.min(1, iVal), 0)
	-- if bRestore and not self.m_RestorePercnt then
	-- 	self.m_RestorePercnt = self.m_AnimatorPercent
	-- end
	self.m_AnimatorPercent = iVal
	self.m_CameraAnimator:Seek(iVal)
end

function CCameraCtrl.RestorePercent(self)
	if self.m_RestorePercnt then
		self:SetAnimatorPercent(self.m_RestorePercnt)
		self.m_RestorePercnt = nil
	end
end

function CCameraCtrl.GetMapCamera(self)
	if not self.m_MapCamera then
		local maingo = UnityEngine.GameObject.Find("GameRoot/MainCamera")
		self.m_MapCamera = maingo:GetMissingComponent(classtype.Map2DCamera)
	end
	return self.m_MapCamera
end

function CCameraCtrl.GetUICamera(self)
	if not self.m_UICamera then
		self.m_UICamera = CCamera.New(UnityEngine.GameObject.Find("GameRoot/UICamera"))
	end
	return self.m_UICamera
end

function CCameraCtrl.GetEffectCamera(self)
	if not self.m_EffectCamera then
		self.m_EffectCamera = CCamera.New(UnityEngine.GameObject.Find("GameRoot/EffectCamera"))
	end
	return self.m_EffectCamera
end

function CCameraCtrl.GetWarCamera(self)
	if not self.m_WarCamera then
		self.m_WarCamera = CCamera.New(UnityEngine.GameObject.Find("GameRoot/WarCamera"))
		local oTerrianCam = self.m_WarCamera:NewAttachCamera(UnityEngine.LayerMask.GetMask("MapTerrain"), self.m_WarCamera:GetDepth() - 1)
		self.m_WarCamera:NewAttachCamera(UnityEngine.LayerMask.GetMask("Magic"), self.m_WarCamera:GetDepth() + 1)
		self.m_WarCamera:SetRenderCam(CCamera.New(oTerrianCam))
		self:AddGroup(self.m_WarCamera, "main")
	end
	return self.m_WarCamera
end

function CCameraCtrl.GetCreateRoleCamera(self)
	if not self.m_CreateRoleCamera then
		self.m_CreateRoleCamera = CCamera.New(UnityEngine.GameObject.Find("GameRoot/CreateRoleCamera"))
		self:AddGroup(self.m_CreateRoleCamera, "main")
	end
	return self.m_CreateRoleCamera
end

function CCameraCtrl.GetChoukaCamera(self)
	if not self.m_ChoukaCamera then
		self.m_ChoukaCamera = CCamera.New(UnityEngine.GameObject.Find("GameRoot/ChoukaCamera"))
		self:AddGroup(self.m_ChoukaCamera, "main")
	end
	return self.m_ChoukaCamera
end

function CCameraCtrl.GetHouseCamera(self)
	if not self.m_HouseCamera then
		self.m_HouseCamera = CCamera.New(UnityEngine.GameObject.Find("GameRoot/HouseCamera"))
		self:AddGroup(self.m_HouseCamera, "main")
	end
	return self.m_HouseCamera
end

function CCameraCtrl.GetMainCamera(self)
	if not self.m_MainCamera then
		self.m_MainCamera = CCamera.New(UnityEngine.GameObject.Find("GameRoot/MainCamera"))
		self:AddGroup(self.m_MainCamera, "main")
	end
	return self.m_MainCamera
end

function CCameraCtrl.AddGroup(self, oCam, sGroupName)
	local dGroup = self.m_CameraGroup[sGroupName] or {}
	oCam.m_CameraGroup = sGroupName
	dGroup[oCam:GetInstanceID()] = oCam
	self.m_CameraGroup[sGroupName] = dGroup
end

function CCameraCtrl.AutoActive(self)
	local oCam
	if g_WarCtrl:IsWar() then
		oCam = self:GetWarCamera()
	elseif g_HouseCtrl:IsInHouse() then
		oCam = self:GetHouseCamera()
	elseif g_CreateRoleCtrl:IsInCreateRole() then
		oCam = self:GetCreateRoleCamera()
	elseif g_ChoukaCtrl:IsInChouka() then
		oCam = self:GetChoukaCamera()
	else
		oCam = self:GetMainCamera()
	end
	self:GroupActive(oCam)
end

function CCameraCtrl.GroupActive(self, oCam)
	for id, oGroupCam in pairs(self.m_CameraGroup[oCam.m_CameraGroup]) do
		oGroupCam:SetEnabled((oGroupCam == oCam))
	end
end

function CCameraCtrl.GetSpineCamra(self)
	local oCam = self:GetInRecycle("CSpineCamera", function (oCam)
		return not oCam:GetOwner() and not oCam.m_Path
	end)
	if not oCam then
		oCam = CSpineCamera.New()
		local pos = self:GetNewPos()
		oCam:SetPos(pos)
	end
	self.m_SpineCamPool[oCam:GetInstanceID()] = oCam
	return oCam
end

function CCameraCtrl.RecycleSpineCam(self, oCam)
	self.m_SpineCamPool[oCam:GetInstanceID()] = nil
	local list = self.m_CachedCams[oCam.classname] or {}
	if #list < 5 then
		if not table.index(list, oCam) then
			table.insert(list, oCam)
			self.m_CachedCams[oCam.classname] = list
		end
		oCam:ClearSpine()
		oCam:SetOwner(nil)
		oCam:SetActive(false)
	else
		oCam:Destroy()
	end
end

function CCameraCtrl.GetActorCamra(self, iShape)
	local oCam = self:GetInRecycle("CActorCamera", function(oCam)
		return oCam:GetShape() == iShape
	end)
	if oCam then
		oCam:ResetActor()
	else
		oCam = CActorCamera.New()
		local pos = self:GetNewPos()
		oCam:SetPos(pos)
	end
	self.m_ModelCamPool[oCam:GetInstanceID()] = oCam
	return oCam
end

function CCameraCtrl.GetUIEffectCamera(self)
	for i,oCam in ipairs(self.m_UIEffectCamPool) do
		if not oCam:GetOwner() then
			oCam:ClearTexture()
			oCam:SetActive(true)
			return oCam
		end
	end

	local oCam = CUIEffectCamera.New()  
	table.insert(self.m_UIEffectCamPool, oCam)
	local cb = function ()
		oCam:SetPos(Vector3.New(0, #self.m_UIEffectCamPool*10+2000,0))	
	end
	Utils.AddTimer(cb, 0, 0)	
	return oCam
end

function CCameraCtrl.GetInRecycle(self, classname, checkfunc)
	local list = self.m_CachedCams[classname]
	local idx = nil
	if list and #list > 0 then
		for i, oCam in ipairs(list) do
			if not checkfunc or checkfunc(oCam) then
				idx = i
				break
			end
		end
		if not idx then
			idx = 1
		end
	end
	if idx then
		local recycle = list[idx]
		table.remove(list, idx)
		recycle:SetActive(true)
		return recycle
	end
end

function CCameraCtrl.RecycleModelCam(self, oCam)
	self.m_ModelCamPool[oCam:GetInstanceID()] = nil
	local list = self.m_CachedCams[oCam.classname] or {}
	if #list < 5 then
		if not table.index(list, oCam) then
			table.insert(list, oCam)
			self.m_CachedCams[oCam.classname] = list
		end
		oCam:ClearActor()
		oCam:SetOwner(nil)
		oCam:SetActive(false)
	else
		oCam:Destroy()
	end
end

function CCameraCtrl.GetNewPos(self)
	local i = self.m_CurCamPosIdx
	local pos = Vector3.New(i*50 + 1000, 0, 0)
	self.m_CurCamPosIdx = i + 1
	return pos
end

function CCameraCtrl.CheckCachedCam(self)
	local checklist = {
		{self.m_ModelCamPool, self.RecycleModelCam},
		{self.m_SpineCamPool, self.RecycleSpineCam},
	}
	for i, v in ipairs(checklist) do
		local camPool, recycleFunc = v[1], v[2]
		for i, oCam in pairs(camPool) do
			local owner = oCam:GetOwner()
			if owner then
				oCam:SetActive(owner:GetActiveHierarchy())
			else
				recycleFunc(self, oCam)
			end
		end
	end

	-- for i, oCam in ipairs(self.m_UIEffectCamPool) do
	-- 	if not oCam:GetOwner() then
	-- 		oCam:ClearTexture()
	-- 		oCam:SetActive(false)
	-- 	end
	-- end
end


function CCameraCtrl.CheckAll(self)
	self:CheckCachedCam()
	return true
end

--移动相机
function CCameraCtrl.GetCameraInfo(self, type, key)
	local tInfo
	if type == "war" and key == "current" then
		local oCam = g_CameraCtrl:GetWarCamera()
		local p = oCam:GetLocalPos()
		local r = oCam:GetLocalEulerAngles()
		tInfo = {
			pos = oCam:GetLocalPos(),
			rotate = oCam:GetLocalEulerAngles(),
		}
	else
		local tData = data.cameradata.INFOS[type][key]
		if tData then
			tInfo = {
			pos= Vector3.New(tData.pos.x, tData.pos.y, tData.pos.z),
			rotate= Vector3.New(tData.rotate.x, tData.rotate.y, tData.rotate.z)}
		end
	end
	return tInfo
end

function CCameraCtrl.GetWarStartPercent(self)
	if not self.m_WarStartPercent then
		local iDesign = 1334/750 
		local iFactor = 0.4 / (iDesign - 1024/768)
		local w, h = UITools.GetRootSize()
		self.m_WarStartPercent = math.min(0.5, math.max(0, (iDesign - w/h) * iFactor))
	end
	return self.m_WarStartPercent
end

function CCameraCtrl.PlayAction(self, sType)
	self:InitCtrl()
	local oCamera, info, vLookPos, vLookUp, iMoveTime
	if sType == "war_default" then
		local oRoot = g_WarCtrl:GetRoot()
		self.m_CameraAnimator.orientationTarget = oRoot:GetLookAtTarget()
		self:LoadPath("CameraPath_War")
		-- self:SetAnimatorPercent(0.534)
		self:SetAnimatorPercent(self:GetWarStartPercent())
	elseif sType == "house" then
		self:LoadPath(sType)
	-- elseif sType == "war_replace" then
	-- 	oCamera = g_CameraCtrl:GetWarCamera()
	-- 	info = self:GetCameraInfo("war", "replace")
	elseif sType == "war_replace_end" then
		self:SetAnimatorPercent(self:GetWarStartPercent())
	elseif sType == "war_win" then
		-- oCamera = g_CameraCtrl:GetWarCamera()
		-- info = self:GetCameraInfo("war", "war_win")
		-- iMoveTime = 1
		-- vLookPos = MagicTools.GetCommonPos("ally_team_center")
		-- vLookPos.y = 1
		-- vLookUp = g_WarCtrl:GetRoot().m_Transform.up
	elseif sType == "guide_boss" then
		oCamera = g_CameraCtrl:GetWarCamera()
		-- oCamera:SetFieldOfView(48)
		info = self:GetCameraInfo("war", "guide_boss")
	end
	if oCamera and info then
		local pos = Vector3.New(info.pos.x, info.pos.y, info.pos.z)
		if iMoveTime then
			local oAction1 = CCircleMove.New(oCamera, iMoveTime, oCamera:GetPos(), pos)
			g_ActionCtrl:AddAction(oAction1)
			if vLookPos then
				local oAction2 = CLookAt.New(oCamera, iMoveTime, vLookPos, vLookUp)
				g_ActionCtrl:AddAction(oAction2)
			end
		else
			oCamera:SetLocalPos(pos)
			oCamera:SetEulerAngles(info.rotate)
		end
	end
end

function CCameraCtrl.SetGrayScene(self, bGray)
	if Utils.IsIOS() and main.g_DllVer <= 13 then
		return
	end
	local mainCamera = self:GetMainCamera()
	local handler = mainCamera:GetMissingComponent(classtype.GraySceneHandler)
	if handler then
		handler:SetGrayScene(bGray)
	end
end

return CCameraCtrl