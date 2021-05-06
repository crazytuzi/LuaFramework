local CAutoPath = class("CAutoPath", CDelayCallBase)


function CAutoPath.ctor(cls)

end

function CAutoPath.AutoWalk(cls, vPos, mapID, npcID)
	local function autowalk()
		local resID = nil
		if data.mapdata.DATA[mapID] then
			resID = data.mapdata.DATA[mapID]["resource_id"]
		end
		
		if g_MapCtrl:GetMapID() ~= mapID or g_MapCtrl.m_MapLoding or resID ~= g_MapCtrl.m_ResID then
			return true
		else
			g_MapTouchCtrl:WalkToPos(vPos, npcID, define.Walker.Npc_Talk_Distance + g_DialogueCtrl:GetTalkDistanceOffset(), function ()
				local pid = g_MapCtrl:GetNpcIdByNpcType(npcID)
				local oNpc = g_MapCtrl:GetNpc(pid)
				if oNpc and oNpc.Trigger then
					oNpc:Trigger()
				end
			end)
		end
	end
	
	local curMapID = g_MapCtrl:GetMapID()
	if g_MapCtrl:GetMapID() ~= mapID then
		local oHero = g_MapCtrl:GetHero()
		netscene.C2GSClickWorldMap(g_MapCtrl:GetSceneID(), oHero.m_Eid, mapID)
		if cls.m_AutoWalkTimer then
			Utils.DelTimer(cls.m_AutoWalkTimer)
		end
		cls.m_AutoWalkTimer = Utils.AddTimer(autowalk, 0, 0)
	else
		autowalk()
	end
end

function CAutoPath.WalkTo(cls, vPos, npcID)
	if npcID then
		g_MapTouchCtrl:WalkToPos(vPos, npcID, define.Walker.Npc_Talk_Distance + g_DialogueCtrl:GetTalkDistanceOffset())
	else
		g_MapTouchCtrl:WalkToPos(vPos)
	end
end

return CAutoPath