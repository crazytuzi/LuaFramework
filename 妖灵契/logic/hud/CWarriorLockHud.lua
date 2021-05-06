local CWarriorLockHud = class("CWarriorLockHud", CAsyncHud)

function CWarriorLockHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/FightLockHud.prefab", cb, true)
end

function CWarriorLockHud.OnCreateHud(self)
	self.m_Label = self:NewUI(2, CLabel)
end

function CWarriorLockHud.SetLevel(self, iLevel)
	iLevel = iLevel or 0
	self.m_Label:SetText(string.format("%d级后解锁", iLevel))
end

return CWarriorLockHud