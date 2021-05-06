local CSameScreenHandler = class("CSameScreenHandler")

CSameScreenHandler.g_Open = true
CSameScreenHandler.g_MaxPlayerCnt = 50

--处理同频人数
function CSameScreenHandler.ctor(self)
	self.m_PlayerCnt = 0
	self.m_PlayerInfos = {}
end

function CSameScreenHandler.ChangePlayerCnt(self, i)
	self.m_PlayerCnt = self.m_PlayerCnt + i
end

function CSameScreenHandler.IsCanAddPlayer(self)
	if not CSameScreenHandler.g_Open then
		return true
	end
	return self.m_PlayerCnt < CSameScreenHandler.g_MaxPlayerCnt
end

--队友优先加载
function CSameScreenHandler.IsProirPlayer(self, aoi)
	local oHero = g_MapCtrl:GetHero()
	if not oHero then
		return true
	end
	local iHeroTeamID = oHero.m_TeamID
	if not iHeroTeamID then
		iHeroTeamID = g_MapCtrl.m_TeamMissPlayers[oHero.m_Pid]
	end
	if iHeroTeamID then
		local iTeamID = g_MapCtrl.m_TeamMissPlayers[aoi.pid]
		if iTeamID then
			return iHeroTeamID == iTeamID
		end
	end
	return false
end

function CSameScreenHandler.AddAoi(self, eid, aoi)
	if not self.m_PlayerInfos[eid] then
		self.m_PlayerInfos[eid] = {eid=eid, aoi=nil, block_list={}, pos=nil, change_time = g_TimeCtrl:GetTimeMS()}
	end
	self.m_PlayerInfos[eid].aoi = aoi
end

function CSameScreenHandler.IsContainAoi(self, eid)
	return self.m_PlayerInfos[eid] ~= nil
end

function CSameScreenHandler.RemoveAoi(self, eid)
	self.m_PlayerInfos[eid] = nil
end

function CSameScreenHandler.AddBlock(self, eid, block)
	local dInfo = self.m_PlayerInfos[eid]
	if dInfo then
		dInfo.change_time = g_TimeCtrl:GetTimeMS()
		table.insert(dInfo.block_list, block)
	end
end

function CSameScreenHandler.SetPos(self, eid, pos)
	local dInfo = self.m_PlayerInfos[eid]
	if dInfo then
		dInfo.change_time = g_TimeCtrl:GetTimeMS()
		dInfo.pos = pos
	end 
end

function CSameScreenHandler.GetDistance(self, dInfo)
	local pos = dInfo.pos
	if not pos then
		pos = dInfo.aoi.pos_info
	end
	local x = pos.x or 0
	local y = pos.y or 0
	local oHero = g_MapCtrl:GetHero()
	local vHeroPos = oHero:GetLocalPos()
	local dis =  math.sqrt((vHeroPos.x - x)^2 + (vHeroPos.y - y)^2)
	return dis
end

function CSameScreenHandler.CheckAddPlayer(self)
	if not self:IsCanAddPlayer() then
		return
	end
	if not next(self.m_PlayerInfos) then
		return
	end
	local dNearestInfo, dInfo, iNearDis
	for k, v in pairs(self.m_PlayerInfos) do
		local pid = v.aoi.pid
		if g_FriendCtrl:IsMyFriend(pid) or --好友
		g_MapCtrl.m_TeamMissPlayers[pid] then --队伍中
			dInfo = v
			break
		end
		--找一个在屏幕范围内，且最近有移动的显示, 否则找最近的
		local dis = self:GetDistance(v)
		if dInfo then
			if dis < 4 and dInfo.change_time < v.change_time then
				dInfo = v
			end
		else
			if dNearestInfo then
				if dis < iNearDis then
					dNearestInfo = v
					iNearDis = dis
				end
			else
				dNearestInfo = v
				iNearDis = dis
			end
			
		end
	end
	dInfo = dInfo or dNearestInfo
	if not dInfo then
		return
	end
	self:AddPlayer(dInfo)
end

function CSameScreenHandler.AddPlayer(self, dInfo)
	self.m_PlayerInfos[dInfo.eid] = nil
	local oPlayer = g_MapCtrl:AddPlayer(dInfo.eid, dInfo.aoi)
	for i, block in ipairs(dInfo.block_list) do
		oPlayer:SyncBlockInfo(dInfo.eid, block)
	end

	if dInfo.pos then
		oPlayer:WalkTo(dInfo.pos.x, dInfo.pos.y)
	end
end

function CSameScreenHandler.AddTeamPlayers(self)
	for k, v in pairs(self.m_PlayerInfos) do
		if self:IsProirPlayer(v.aoi) then
			self:AddPlayer(v)
		end
	end
end

function CSameScreenHandler.Clear(self)
	self.m_PlayerCnt = 0
	self.m_PlayerInfos = {}
end

return CSameScreenHandler