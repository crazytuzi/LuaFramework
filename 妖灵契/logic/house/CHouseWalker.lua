local CHouseWalker = class("CHouseWalker", CWalker, CBindObjBase)

function CHouseWalker.ctor(self)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/HouseWalker.prefab")
	-- CWalker.ctor(self, obj)
	CObject.ctor(self, obj)
	self.m_Actor = CHouseActor.New()
	self.m_Actor:SetParent(self.m_Transform)
	CWalker.InitValue(self)
	CBindObjBase.ctor(self, obj)
	self.m_IsHouseWalker = true
	self:Init3DWalker()
	self.m_IdleActionName = "idleHouse"
	self.m_WalkActionName = "walkHouse"
	self:SetDefaultState("idleHouse")
	self:SetMoveSpeed(data.housedata.HouseDefine.walk_speed.value)
end

function CHouseWalker.Destroy(self)
	self:ClearBindObjs()
	CWalker.Destroy(self)
end

function CHouseWalker.RecycleShadow(self)

end

function CHouseWalker.GetHudCamera(self)
	return g_CameraCtrl:GetHouseCamera()
end

function CHouseWalker.SetName(self, sName)
	-- self:SetNameHud(sName)
	CWalker.SetName(self, sName)
end

function CHouseWalker.ChangePartShape(self, iPart, iShape, dModelInfo, cb)
	-- printc(string.format("ChangePartShape iPart: %s, iShape: %s,", iPart, iShape))
	self.m_Actor:ChangePartShape(iPart, iShape, dModelInfo, cb)
end

return CHouseWalker