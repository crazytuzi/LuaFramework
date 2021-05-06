local CWarMagicNameBox = class("CWarMagicNameBox", CBox)

function CWarMagicNameBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_NameLabel = self:NewUI(1, CLabel)
	self.m_HideTime = nil
end

function CWarMagicNameBox.Display(self, name, duration, warrior)
	if not (type(duration) == "number" and duration >=0) then
		return
	end
	self.m_NameLabel:SetText(name)
	local pos = WarTools.WarToUIPos(warrior.m_HeadTrans.position)
	self:SimulateOnEnable()
	self:SetPos(pos)
	if self.m_HideTime then
		Utils.DelTimer(self.m_HideTime)
	end
	self.m_HideTime = Utils.AddTimer(callback(self, "SetActive", false), duration, duration)
end

return CWarMagicNameBox