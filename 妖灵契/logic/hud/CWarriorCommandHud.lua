local CWarriorCommandHud = class("CWarriorCommandHud", CAsyncHud)

function CWarriorCommandHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/WarriorCommandHud.prefab", cb, true)
end

function CWarriorCommandHud.OnCreateHud(self)
	self.m_CommandLabel = self:NewUI(1, CLabel)
end

function CWarriorCommandHud.SetWarriorCommand(self, sCommand, bAlly)
	if sCommand and sCommand ~= "" then
		if bAlly then
			sCommand = "[7fff29]"..sCommand
		else
			sCommand = sCommand
		end
		self.m_CommandLabel:SetActive(true)
		self.m_CommandLabel:SetText(sCommand)
	else
		self.m_CommandLabel:SetActive(false)
	end
end

function CWarriorCommandHud.Recycle(self)
	self.m_CommandLabel:SetActive(false)
end

return CWarriorCommandHud