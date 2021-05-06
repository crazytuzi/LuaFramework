local CYJFubenCtrl = class("CYJFubenCtrl", CCtrlBase)

define.RJFuben = {
	Event = {
		EnterFuben = 1,
		CloseFuben = 2,
	},
}

function CYJFubenCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:ResetCtrl()
end

function CYJFubenCtrl.ResetCtrl(self)
	self.m_State = 0
	self.m_NpcList = {}
end

function CYJFubenCtrl.EnterFuben(self, iEndtime, npcList, autowar, sTitle)
	self.m_State = 1
	self.m_EndTime = iEndtime
	self.m_NpcList = npcList
	self.m_AutoWar = autowar
	self.m_Title = sTitle
	self:OnEvent(define.RJFuben.Event.EnterFuben)
	g_WarCtrl:SetLockPreparePartner(define.War.Type.YjFuben, autowar)
	g_MapCtrl:UpdateMiniMapData(self:GetMiniMapData())
end

function CYJFubenCtrl.CloseFuben(self)
	self.m_State = 0
	self:OnEvent(define.RJFuben.Event.CloseFuben)
end

function CYJFubenCtrl.GetEndTime(self)
	return self.m_EndTime
end

function CYJFubenCtrl.StopAutoFuben(self)
	if (g_TeamCtrl:IsLeader() or not g_TeamCtrl:IsJoinTeam()) and self.m_AutoWar then
		nethuodong.C2GSYJFubenOp(3)
	end
end

function CYJFubenCtrl.IsInFuben(self)
	return self.m_State == 1
end

function CYJFubenCtrl.IsAutoWar(self)
	return self.m_State == 1 and self.m_AutoWar
end

function CYJFubenCtrl.GetTitle(self)
	return self.m_Title or ""
end

function CYJFubenCtrl.GetNpcList(self)
	return self.m_NpcList
end

function CYJFubenCtrl.IsLiveNpc(self, iNpcID)
	for _, oNpc in ipairs(self.m_NpcList) do
		if oNpc.idx == iNpcID and oNpc.dead == false then
			return true
		end
	end
	return false
end

function CYJFubenCtrl.GetNpcName(self, iNpcID)
	for _, oNpc in ipairs(self.m_NpcList) do
		if oNpc.idx == iNpcID then
			return oNpc.name
		end
	end
end

function CYJFubenCtrl.GetMiniMapData(self)
	local result = {}
	for id, v in pairs(data.yjfubendata.MINIMAP) do
		result[v.mapId] = result[v.mapId] or {}
		result[v.mapId]["yjfuben"] = result[v.mapId]["yjfuben"] or {}
		if v.type == "npc" and self:IsLiveNpc(v.id) then
			v.name = self:GetNpcName(v.id) or v.name
			table.insert(result[v.mapId]["yjfuben"], v)
		end
	end
	return result
end


function CYJFubenCtrl.OnWarEnd(self)
	Utils.AddTimer(function ()
		nethuodong.C2GSYJFubenOp(4)
	end, 0, 5)
end

function CYJFubenCtrl.ShowWarResult(self, oCmd)
	CWarResultView:ShowView(function(oView)
		oView:SetWarID(oCmd.war_id)
		oView:SetWin(oCmd.win)
		if self:IsAutoWar() then
			oView:SetDelayCloseView()
		end
		self:OnWarEnd()
	end)
end

--获取当前组队目标
function CYJFubenCtrl.GetDefaultType(self)
	local iType = 1
	local d = g_TeamCtrl:GetTeamTargetInfo()
	if d then
		--地狱
		if d.auto_target == 1163 then			
			iType = 3

		--困难
		elseif d.auto_target == 1162 then
			iType = 2

		--普通
		else
			iType = 1
		end
	end
	return iType 
end
return CYJFubenCtrl

