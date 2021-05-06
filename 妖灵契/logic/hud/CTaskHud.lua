local CTaskHud = class("CTaskHud", CAsyncHud)

function CTaskHud.ctor(self, cb)
	self.m_NpcId = nil
	CAsyncHud.ctor(self, "UI/Hud/TaskHud.prefab", cb, true)
end

function CTaskHud.OnCreateHud(self)
	self.m_TaskSpr = self:NewUI(1, CSprite)
	self.m_TaskBtn = self:NewUI(2, CButton)
	self.m_TaskBtn:AddUIEvent("click", callback(self, "ClickTaskBtn"))
end

function CTaskHud.SetTaskMark(self, spriteName)
	self.m_NpcId = nil
	self.m_TaskSpr:SetSpriteName(spriteName)
	self.m_TaskSpr:MakePixelPerfect()
end

function CTaskHud.SetNpcId(self, npcId)
	self.m_NpcId = npcId
end

function CTaskHud.ClickTaskBtn(self)
	if self.m_NpcId then
		local oNpc = g_MapCtrl:GetNpc(self.m_NpcId)
		if not oNpc then
			oNpc = g_MapCtrl:GetDynamicNpc(self.m_NpcId)
		end
		if oNpc then
			local pos = oNpc:GetPos()
			g_MapTouchCtrl:WalkToPos(pos, self.m_NpcId, define.Walker.Npc_Talk_Distance + g_DialogueCtrl:GetTalkDistanceOffset(), function()										
					if not Utils.IsNil(oNpc) then
						oNpc:Trigger()
					end												
				end)			
		end

	end
end

return CTaskHud