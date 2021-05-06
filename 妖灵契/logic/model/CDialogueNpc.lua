local CDialogueNpc = class("CDialogueNpc", CMapWalker)

function CDialogueNpc.ctor(self)
	CMapWalker.ctor(self)
	self.m_ClientNpc = nil
	self:SetCheckInScreen(true)
end

function CDialogueNpc.SetData(self, clientNpc)
	self.m_ClientNpc = clientNpc
	self.m_Actor:SetLocalRotation(Quaternion.Euler(0, clientNpc.rotateY or 150, 0))
	if clientNpc.haveMagic then
		self:SetTouchTipsTag(1)
	end
end

function CDialogueNpc.OnTouch(self)

end

function CDialogueNpc.Trigger(self)

end

function CDialogueNpc.Destroy(self)
	CMapWalker.Destroy(self)
end

function CDialogueNpc.SetVisible(self, b)
	self.m_Actor:SetActive(b)
	self:SetNeedShadow(b)
	self.m_Actor:SetColliderEnbled(b)	
	if b then	
		self:SetNameHud("")	
		--self:SetNameHud(string.format("[FF00FF]%s", self.m_Name))
	else
		self:SetNameHud("")
	end
end


--技能特效相关函数重载
function CDialogueNpc.SetPlayMagicID(self, id)
	
end

function CDialogueNpc.IsAlive(self)
	return true
end

function CDialogueNpc.GetDefalutRotateAngle(self)
	-- if self:IsAlly() then
	-- 	return Vector3.New(0, -45, 0)
	-- else
	-- 	return Vector3.New(0, 135, 0)
	-- end	
	return Vector3.New(0, -45, 0)
end

function CDialogueNpc.ShowWarSkillByClient(self, iMagic, alive_time)
	-- local trans = self:GetBindTrans("head")
	-- self:AddHud("warrior_skill", CWarriorMagicHud, trans, function(oHud) oHud:ShowWarSkillByClient(iMagic, alive_time) end, false)
end

function CDialogueNpc.GetDefalutRotateAngle(self)
	-- if self:IsAlly() then
	-- 	return Vector3.New(0, -45, 0)
	-- else
	-- 	return Vector3.New(0, 135, 0)
	-- end	
	return Vector3.New(0, -45, 0)
end

function CDialogueNpc.GetMatColor(self)
	return self.m_Actor.m_MatColor
end

function CDialogueNpc.IsAlly(self)
	return true
end

function CDialogueNpc.HasDontHitBuff(self)
	return false
end

--技能特效相关函数重载

return CDialogueNpc