local CAnLeiTimeHud = class("CAnLeiTimeHud", CAsyncHud)

function CAnLeiTimeHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/AnLeiTimeHud.prefab", cb, true)
	self.m_Timer = nil
	self.m_NpcId = nil
	self.m_StartTime = nil
	self.m_EndTime = nil
end

function CAnLeiTimeHud.OnCreateHud(self)
	self.m_TimeLabel = self:NewUI(1, CLabel)
end

function CAnLeiTimeHud.SetTime(self, sTime, eTime, npcId)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
	local time = g_AnLeiCtrl:GetMonsterHudLeftTimeByNpcId(npcId, eTime)
	self.m_NpcId = npcId
	self.m_EndTime = eTime
	self.m_StartTime = sTime
	if time ~= "" then
		self.m_TimeLabel:SetText(time)
		self.m_TimeLabel:SetActive(true)
		local update = function ()
			time = g_AnLeiCtrl:GetMonsterHudLeftTimeByNpcId(npcId, eTime)
			if time == "" or Utils.IsNil(self) then
				self.m_TimeLabel:SetActive(false)
				return false
			end
			self.m_TimeLabel:SetText(time)
			return true
		end
		self.m_Timer = Utils.AddTimer(update, 1, 1)
	else
		self.m_TimeLabel:SetActive(false)
	end
end

function CAnLeiTimeHud.Destroy(self)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
	CObject.Destroy(self)
end

return CAnLeiTimeHud