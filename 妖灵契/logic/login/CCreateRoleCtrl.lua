local CCreateRoleCtrl = class("CCreateRoleCtrl", CCtrlBase)

define.CreateRole = {
	Event = {
		SexChange = 1,
	}
}

function CCreateRoleCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_CreateData = {}
	self.m_InstanceID2Warrior = {}
	self.m_CreateRoleRoot = nil
	self.m_IsInCreateRole = false
	self.m_IsInitDone = false
	self.m_SwipeVal = 0
	self.m_BranchWarrior = nil
	self.m_IsLock = false
	self.m_StartTime = 0
	self.m_MapObj = nil
	self.m_StateInfo = nil
	self.m_Layer = UnityEngine.LayerMask.NameToLayer("CreateRole")
	self.m_LayerMask = UnityEngine.LayerMask.GetMask("CreateRole")
end

function CCreateRoleCtrl.GetLayer(self)
	return self.m_Layer
end

function CCreateRoleCtrl.GetRoot(self)
	return self.m_CreateRoleRoot
end

function CCreateRoleCtrl.IsInCreateRole(self)
	return self.m_IsInCreateRole
end


function CCreateRoleCtrl.SetLock(self, bLock)
	local oCam = g_CameraCtrl:GetCreateRoleCamera()
	if bLock then
		self.m_LockInfo = {pos=oCam:GetLocalPos(), rotate=oCam:GetLocalEulerAngles()}
	else
		if self.m_LockInfo then
			DOTween.DOKill(oCam.m_Transform, true)
			oCam:SetPos(self.m_LockInfo.pos)
			oCam:SetLocalEulerAngles(self.m_LockInfo.rotate)
			self.m_LockInfo = nil
		end
	end
	self.m_IsLock = bLock
end

function CCreateRoleCtrl.SetCreateData(self, k, v)
	local oldv = self.m_CreateData[k]
	if oldv ~= v then
		self.m_CreateData[k] = v
		if k == "sex" then
			self.m_BranchWarrior:SetSex(v)
			g_UploadDataCtrl:CreateRoleUpload({time=self.m_StartTime, click= string.format("性别%s", v)})
		elseif k == "school" then
			self.m_BranchWarrior:SetSchool(v)
			g_UploadDataCtrl:CreateRoleUpload({time=self.m_StartTime, click= string.format("职业%s", v)})
		elseif k == "branch" then
			self.m_BranchWarrior:SetBranch(v)
			self:ResetState()
			g_UploadDataCtrl:CreateRoleUpload({time=self.m_StartTime, click= string.format("流派%s", v)})
		elseif k == "mode" then
			self:ResetState()
			if v == "branch" then
				self.m_SwipeVal = 0
				self.m_BranchWarrior:OutScene()
			else
				self.m_BranchWarrior.m_RotateObj:SetLocalEulerAngles(Vector3.zero)
				self.m_BranchWarrior:RefreshShape()
				self.m_BranchWarrior:CrossFade("idleCity")
			end
		end
	end
end

function CCreateRoleCtrl.GetCreateData(self, k)
	return self.m_CreateData[k]
end

function CCreateRoleCtrl.CreateRole(self, sName)
	if g_LoginCtrl:HasLoginRole() then
		printerror("CreateRole err: HasLoginRole")
		return
	end
	
	local iSex = (self:GetCreateData("sex")=="male") and 1 or 2
	local iRoleType = data.roletypedata.MAP[iSex][self:GetCreateData("school")]
	print("CreateRole", iRoleType, sName)
	if g_LoginCtrl:GetLoginInfo("account") then
		if not g_NetCtrl:IsValidSession(1003) then
			return 
		end
		netlogin.C2GSCreateRole(g_LoginCtrl:GetAccount(), iRoleType, sName) 
	else
		g_LoginCtrl:SetLoginAccountCb(function() netlogin.C2GSCreateRole(g_LoginCtrl:GetAccount(), iRoleType, sName) end)
		g_LoginCtrl:ConnectServer()
	end
end

function CCreateRoleCtrl.OnMapEvent(self, oCtrl)
	if self.m_CreateRoleRoot then
		if oCtrl.m_EventID == define.Map.Event.MapLoadDone then
			local obj = oCtrl.m_EventData
			obj:SetParent(self.m_CreateRoleRoot.m_Transform)
			self.m_MapObj = obj
			local rootw, rooth = UITools.GetRootSize()
			local scaleW = rootw / 1334
			local scaleH = rooth / 750
			if scaleW > scaleH and scaleW > 1 then
				self.m_MapObj:SetLocalScale(Vector3.New(scaleW, scaleW, scaleW))
				local transform = obj:Find("Model/Model/Scene_6100_01/Scene_6100_shuimian")
				if transform then
					local baseScale = transform.localPosition
					transform.localPosition = Vector3.New(baseScale.x / scaleW, baseScale.y / scaleW, baseScale.z / scaleW)
				end
			end
			self.m_AnimEffect:SyncBg()
		end
	end
end

function CCreateRoleCtrl.MapLoadDoneProcess(self, oEffect, cb)
	if self.m_IsInCreateRole then
		Utils.SetShaderLight("createrole")
		self.m_StartTime = g_TimeCtrl:GetTimeMS()
		self.m_AnimEffect = oEffect
		self.m_CreateRoleRoot = CObject.New(UnityEngine.GameObject.New("CreateRoleRoot"))
		oEffect:SetParent(self.m_CreateRoleRoot.m_Transform)
		self.m_BranchWarrior = CCreateRoleWarrior.New(oEffect)
		self.m_BranchWarrior:SetActive(false)
		self.m_BranchWarrior:SetParent(self.m_CreateRoleRoot.m_Transform)
		self.m_InstanceID2Warrior[self.m_BranchWarrior:GetInstanceID()] = self.m_BranchWarrior
		g_EasyTouchCtrl:AddTouch("createroletouch", self)
		g_MapCtrl:AddCtrlEvent(self.m_CreateRoleRoot:GetInstanceID(), callback(self, "OnMapEvent"))
		CCreateRoleView:ShowView()
		local function done()
			if self.m_IsInCreateRole then
				self.m_IsInitDone = true
				self.m_BranchWarrior:SetActive(true)
				self.m_BranchWarrior:InitPosType("mid", {"mid"})
				if cb then cb() end
			end
		end
		g_NotifyCtrl:HideConnect()
		-- if not IOTools.GetClientData("cg_played") then
		-- 	IOTools.SetClientData("cg_played", 1)
		-- 	Utils.PlayCG(done)
		-- else
			done()
		-- end
	end
end

function CCreateRoleCtrl.IsInitDone(self)
	return self.m_IsInitDone
end

function CCreateRoleCtrl.StartCreateRole(self, cb)
	self:EndCreateRole()
	self.m_IsInCreateRole = true
	self.m_IsInitDone = false
	CCreateRoleAnimEffect.New(function(oEffect) 
		if self.m_IsInCreateRole then
			g_MapCtrl:AddLoadDoneCb(function() 
				self:MapLoadDoneProcess(oEffect, cb)
			end)
			g_MapCtrl:Load(6100, 1)
		else
			oEffect:Destroy()
		end
	end)
end

function CCreateRoleCtrl.EndCreateRole(self)
	-- -- body
	if self.m_IsInCreateRole then
		CCreateRoleView:CloseView()
		g_EasyTouchCtrl:DelTouch("createroletouch")
		g_MapCtrl:DelCtrlEvent(self.m_CreateRoleRoot:GetInstanceID(), callback(self, "OnMapEvent"))
		if self.m_MapObj then
			self.m_MapObj:SetParent(nil)
			self.m_MapObj = nil
		end
		self.m_AnimEffect = nil
		self.m_CreateRoleRoot:Destroy()
		self.m_CreateData = {}
		self.m_CreateRoleRoot = nil
		self.m_IsInCreateRole = false
		self.m_IsInitDone = false
		self.m_InstanceID2Warrior = {}
		self.m_StateInfo = nil
	end
end

function CCreateRoleCtrl.GetTouchWarrior(self, x, y)
	local lTouch = C_api.EasyTouchHandler.SelectMultiple(g_CameraCtrl:GetCreateRoleCamera().m_Camera, x, y, self.m_LayerMask)
	if not lTouch or #lTouch == 0 then
		return
	end
	local iCnt = #lTouch / 2
	for i=1, iCnt do
		local go, point = lTouch[i*2-1], lTouch[i*2]
		local oWarrior = self.m_InstanceID2Warrior[go:GetInstanceID()]
		if oWarrior then
			return oWarrior
		end
	end
end

function CCreateRoleCtrl.OnTouchUp(self, touchPos)
	if self:GetCreateData("mode") == "school" then
		local oWarrior = self:GetTouchWarrior(touchPos.x, touchPos.y)
		if oWarrior then
			local sSex = oWarrior:GetSex()
			if sSex ~= self:GetCreateData("sex") then
				self:SetCreateData("sex", sSex)
				self:OnEvent(define.CreateRole.Event.SexChange, sSex)
			end
		end
	end
end

function CCreateRoleCtrl.OnSwipeStart(self)
	if self:GetCreateData("mode") == "school" then
		self.m_SwipeVal = 0
	else

	end
end

function CCreateRoleCtrl.OnSwipe(self, swipePos)
	if self.m_IsLock then
		return
	end
	if self.m_BranchWarrior:GetState() == "showup" then
		return
	end
	self.m_SwipeVal = self.m_SwipeVal - swipePos.x / 500
	self.m_BranchWarrior.m_RotateObj:SetLocalEulerAngles(Vector3.New(0, self.m_SwipeVal * 360, 0))
end

function CCreateRoleCtrl.OnSwipeEnd(self)
end

function CCreateRoleCtrl.GetBranchWarrior(self)
	return self.m_BranchWarrior
end

function CCreateRoleCtrl.DisplaySkill(self, iSkill)
	local sScveneName = Utils.GetActiveSceneName()
	self:ResetState()
	self:SaveState()
	if sScveneName == "editorMagic" or g_MagicCtrl:TryGetFile(define.Magic.SpcicalID.CreateRole, iSkill) then
		local requiredata = {
			refAtkObj = weakref(self.m_BranchWarrior),
			refVicObjs = {weakref(self.m_BranchWarrior)},
		}
		local oMagicUnit = g_MagicCtrl:NewMagicUnit(define.Magic.SpcicalID.CreateRole, iSkill, requiredata)
		oMagicUnit:SetLayer(self.m_Layer)
		oMagicUnit:SetEndCallback(function()
				self:ResetState()
			end)
		oMagicUnit:Start()
	else
		self.m_BranchWarrior.m_Actor:CrossFade("attack"..tostring(iSkill%10), 0.1, 0, 1, function()
				if self.m_BranchWarrior then
					self.m_BranchWarrior:CrossFade("idleWar", 0.2)
				end
			end)
	end
end

function CCreateRoleCtrl.SaveState(self)
	local t = {}
	t.pos = self.m_BranchWarrior:GetPos()
	t.rotation = self.m_BranchWarrior:GetRotation()
	t.actor_rotation = self.m_BranchWarrior.m_RotateObj:GetRotation()
	self.m_StateInfo = t
end

function CCreateRoleCtrl.ResetState(self)
	g_MagicCtrl:Clear("createrole")
	local oMapObj = g_MapCtrl:GetCurMapObj()
	if oMapObj then
		oMapObj:SetActive(true)
	end
	self:SetLock(false)
	local oCam = g_CameraCtrl:GetCreateRoleCamera()
	if oCam then
		g_ActionCtrl:StopTarget(oCam)
		oCam:SetFieldOfView(32)
	end
	if Utils.IsExist(self.m_BranchWarrior) then
		DOTween.DOKill(self.m_BranchWarrior.m_Transform, true)
		g_ActionCtrl:StopTarget(self.m_BranchWarrior)
		self.m_BranchWarrior:SetMatColor(Color.white)
		local t = self.m_StateInfo
		if t then
			self.m_BranchWarrior:SetPos(t.pos)
			self.m_BranchWarrior:SetRotation(t.rotation)
			self.m_BranchWarrior.m_RotateObj:SetRotation(t.actor_rotation)
		end
	else
		self.m_BranchWarrior = nil
	end
	self.m_StateInfo =nil
end


return CCreateRoleCtrl