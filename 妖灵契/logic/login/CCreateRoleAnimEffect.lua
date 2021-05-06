local CCreateRoleAnimEffect = class("CCreateRoleAnimEffect", CObject)

function CCreateRoleAnimEffect.ctor(self, cb)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/EffectNode.prefab")
	CObject.ctor(self, obj)
	g_ResCtrl:LoadCloneAsync("Effect/UI/ui_eff_createrole/Prefabs/ui_eff_createrole_anim.prefab", callback(self, "OnEffLoad"), true)
	self.m_Callback = cb
	self.m_Effect = nil
	self.m_Animator = nil
	self.m_Bg = nil
	self.m_WarroiorNode = nil
	self.m_HasSyncBg = false
end

function CCreateRoleAnimEffect.OnEffLoad(self, oClone, sPath)
	if oClone then
		self.m_Eff = CBox.New(oClone)
		self.m_Eff:SetCacheKey(sPath)
		self.m_Eff:SetParent(self.m_Transform, false)
		self.m_Eff:SetActive(true)
		self.m_Animator = self.m_Eff:GetComponent(classtype.Animator)
		local oCam = g_CameraCtrl:GetCreateRoleCamera()
		local oHandler = oCam:GetComponent(classtype.FrameSyncHandler)
		local syncgo = self.m_Eff:GetObject(1)
		oHandler:SetTarget(syncgo)
		syncgo:SetActive(false)
		
		self.m_WarroiorNode = self.m_Eff:GetObject(2)
		self.m_Bg = self.m_Eff:GetObject(3)
		
		if self.m_Callback then
			self.m_Callback(self)
			self.m_Callback = nil
		end
		return true
	else
		return false
	end
end

function CCreateRoleAnimEffect.SyncWarriorPos(self, oWarrior)
	local oHandler = oWarrior:GetMissingComponent(classtype.FrameSyncHandler)
	oHandler:SetTarget(self.m_WarroiorNode)
end

function CCreateRoleAnimEffect.ShowupAnim(self, iShape)
	if iShape and iShape > 0 then
		local sState = "showup"..tostring(iShape)
		local iHash = ModelTools.StateToHash(sState)
		self.m_Animator:Play(iHash, 0, 0)
	end
end

function CCreateRoleAnimEffect.SyncBg(self)
	if not self.m_HasSyncBg then
		local mapgo = g_MapCtrl:GetCurMapObj()
		if mapgo then
			local comp = mapgo:GetComponentInChildren(classtype.DataContainer)
			if comp then
				local oHandler = comp.gameObjectValue:GetMissingComponent(classtype.FrameSyncHandler)
				oHandler:SetTarget(self.m_Bg)
				self.m_HasSyncBg = true
			end
		end
	end
end

function CCreateRoleAnimEffect.OutSceneAnim(self)
	local sState = "jump"
	local iHash = ModelTools.StateToHash(sState)
	self.m_Animator:Play(iHash, 0, 0)
end

function CCreateRoleAnimEffect.Destroy(self)
	local oCam = g_CameraCtrl:GetCreateRoleCamera()
	local oHandler = oCam:GetComponent(classtype.FrameSyncHandler)
	oHandler:SetTarget(nil)
	CObject.Destroy(self)
end

return CCreateRoleAnimEffect