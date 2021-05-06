local CWarRoot = class("CWarRoot", CObject)

function CWarRoot.ctor(self)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/WarRoot.prefab")
	CObject.ctor(self, obj)
	self.m_LookAtTarget = self:Find("Target")
	g_MapCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMapEvent"))
end

function CWarRoot.OnMapEvent(self, oCtrl)
	if not g_WarCtrl:IsWar() then
		return
	end
	if oCtrl.m_EventID == define.Map.Event.MapLoadDone then
		local obj = oCtrl.m_EventData
		obj:SetParent(self.m_Transform)
		self:CheckObj()
	end
end

function CWarRoot.CheckObj(self)
	-- local mapObj = g_MapCtrl:GetCurMapObj()
	-- if mapObj then
	-- 	if g_WarCtrl:IsGuideBoss() then
	-- 		local t = mapObj:Find("Model/Model/suilie")
	-- 		if t then
	-- 			t.gameObject:SetActive(false)
	-- 		end
	-- 	end
	-- end
end

function CWarRoot.SetOriginPos(self, pos)
	self.m_OriginPos = pos
	local oWarCam = g_CameraCtrl:GetWarCamera()
	local p = oWarCam:GetParent()
	p.position = pos
	self:SetPos(pos)
end

function CWarRoot.GetOriginPos(self)
	return self.m_OriginPos
end

function CWarRoot.GetLookAtTarget(self)
	return self.m_LookAtTarget
end

return CWarRoot