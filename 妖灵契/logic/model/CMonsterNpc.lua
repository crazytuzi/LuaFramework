local CMonsterNpc = class("CMonsterNpc", CMapWalker)

function CMonsterNpc.ctor(self)
	CMapWalker.ctor(self)

	self.m_Eid = nil --场景中唯一的ID
	self.m_NpcAoi = nil	
	self.m_Actor:SetLocalRotation(Quaternion.Euler(0, 150, 0))
	self:SetCheckInScreen(true)	

end

function CMonsterNpc.OnTouch(self)
	-- TODO >>> 点到Npc
	CMapWalker.OnTouch(self, self.m_Eid)
	self:SetTouchTipsTag(1)
end

function CMonsterNpc.Trigger(self)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSFightAttackMoster"]) then
		nethuodong.C2GSFightAttackMoster(self.m_NpcAoi.npcid)	
	end
end

function CMonsterNpc.SetData(self, d)
	self.m_NpcAoi = d
	self.m_NpcId = self.m_NpcAoi.npcid	
end

function CMonsterNpc.SetFace(self, x, y)
	local startpos = self.m_Actor:GetPos()
	local endpos = Vector3.New(x, y, startpos.z)
	local dir = endpos - startpos
	local newRotation = Quaternion.LookRotation(Vector3.New(dir.x, 0, dir.y))
	self.m_Actor:SetLocalRotation(newRotation)
end

function CMonsterNpc.Destroy(self)
	CMapWalker.Destroy(self)
end

return CMonsterNpc
