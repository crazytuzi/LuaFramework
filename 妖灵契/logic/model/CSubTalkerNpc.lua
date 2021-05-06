local CSubTalkerNpc = class("CSubTalkerNpc", CMapWalker)

function CSubTalkerNpc.ctor(self)
	CMapWalker.ctor(self)

	self.m_ClientNpc = nil

	self.m_Timer = {}
end

function CSubTalkerNpc.SetData(self, clientNpc)
	self.m_ClientNpc = clientNpc
	local taskNpc = g_TaskCtrl:GetTaskNpc(clientNpc.npctype)
	-- self.m_Actor:SetLocalRotation(Quaternion.Euler(0, taskNpc.rotateY or 150, 0))
end

function CSubTalkerNpc.OnTouch(self)
	-- TODO >>> CSubTalkerNpc
end

function CSubTalkerNpc.Trigger(self)

end

function CSubTalkerNpc.Trigger(self)

end

function CSubTalkerNpc.TalkBegin(self)
	--table.print(self.m_ClientNpc)
	if self.m_ClientNpc.face_pos and self.m_ClientNpc.end_pos then		
		local function wrap()	
			if Utils.IsNil(self) then
				return false
			end
			self:WalkTo(self.m_ClientNpc.end_pos.x , self.m_ClientNpc.end_pos.y)
			local function wrap2()
				if Utils.IsNil(self) then
					return false
				end
				if self:IsWalking() then
					return true
				else
					self:FaceToPos(self.m_ClientNpc.face_pos)
					return false
				end				
			end 
			self.m_Timer[2] = Utils.AddTimer(wrap2, 0.1, 0.4)
		end	
		self.m_Timer[1] = Utils.AddTimer(wrap, 0, 0)		
	end
end

function CSubTalkerNpc.TalkEnd(self)
	if self.m_ClientNpc.pos_info then
		local function wrap()
			g_MapCtrl:DelSubTalkerNpc(self.m_ClientNpc.npctype)
		end
		self.m_Timer[3] = Utils.AddTimer(wrap, 0, 0.2)
		self:WalkTo(self.m_ClientNpc.pos_info.x , self.m_ClientNpc.pos_info.y)
	end
end

function CSubTalkerNpc.Destroy(self)
	for k, v in pairs(self.m_Timer) do
		Utils.DelTimer(v)			
	end
	self.m_Timer = {}
	CMapWalker.Destroy(self)
end

return CSubTalkerNpc