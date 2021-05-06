local CTerrawarNpc = class("CTerrawarNpc", CMapTerrawarWalker)

function CTerrawarNpc.ctor(self)
	CMapTerrawarWalker.ctor(self)

	self.m_Eid = nil --场景中唯一的ID
	self.m_NpcAoi = nil	
	self.m_Actor:SetLocalRotation(Quaternion.Euler(0, 150, 0))
	self:SetCheckInScreen(true)	
end

function CTerrawarNpc.OnTouch(self)
	-- TODO >>> 点到Npc
	CMapTerrawarWalker.OnTouch(self, self.m_Eid)
	self:SetTouchTipsTag(1)
end

function CTerrawarNpc.Trigger(self)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSClickNpc"]) then
		netnpc.C2GSClickNpc(self.m_NpcAoi.npcid)	
	end
end

function CTerrawarNpc.SetData(self, d)
	self.m_NpcAoi = d
	self:SetTerrawarType(self.m_NpcAoi.block)
	local globalNpc = g_MapCtrl:GetGlobalNpc(self.m_NpcAoi.npctype)
	if globalNpc and  globalNpc.rotateY then
		self.m_Actor:SetLocalRotation(Quaternion.Euler(0, globalNpc.rotateY or 150, 0))
	else
		self.m_Actor:SetLocalRotation(Quaternion.Euler(0, 150, 0))
	end
end

function CTerrawarNpc.Destroy(self)
	if self.m_DialogAnimationId then
		g_DialogueAniCtrl:StopDialgueAni(self.dialogAnimationId, self.m_NpcAoi.npctype)
	end	
	CMapTerrawarWalker.Destroy(self)
end

return CTerrawarNpc
