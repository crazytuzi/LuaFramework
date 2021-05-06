local CEqualArenaCtrl = class("CEqualArenaCtrl", CCtrlBase)

function CEqualArenaCtrl.ctor(self, ob)
	CCtrlBase.ctor(self, ob)
	self.m_TimeStr = {
		{value = 1, desc = "秒前"},
		{value = 60, desc = "分钟前"},
		{value = 60, desc = "小时前"},
		{value = 24, desc = "天前"},
		{value = 30, desc = "月前"},
		{value = 999, desc = "年前"},
	}
	self:ResetCtrl()
end

function CEqualArenaCtrl.ResetCtrl(self)
	self.m_ArenaPoint = 0
	self.m_WeekyMedal = 0
	self.m_ResultPoint = 0
	self.m_ResultMedal = 0
	self.m_Result = define.EqualArena.WarResult.NotReceive
	self.m_LeftTime = 0
	self.m_EnemyInfo = {}
	self.m_PlayerInfo = {}
	self.m_UsedPartnerID = {}
	self.m_ViewSide = 0
	self.m_WaitingResult = false
end

function CEqualArenaCtrl.GetGradeDataByPoint(self, point)
	for i,v in ipairs(data.equalarenadata.SortId) do
		if point >= data.equalarenadata.DATA[v].basescore then
			return data.equalarenadata.DATA[v]
		end
	end
	return data.equalarenadata.DATA[data.equalarenadata.SortId[#data.equalarenadata.SortId]]
end

function CEqualArenaCtrl.GetSortIds(self)
	return data.equalarenadata.SortId
end

function CEqualArenaCtrl.GetArenaGradeData(self, id)
	return data.equalarenadata.DATA[id]
end

function CEqualArenaCtrl.ShowArena(self)
	if g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.equalarena.open_grade then
		netarena.C2GSOpenEqualArena()
	else
		g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级开启功能", data.globalcontroldata.GLOBAL_CONTROL.equalarena.open_grade))
	end
	-- self:OnShowArena(0,0,false, {0,0})
end

function CEqualArenaCtrl.OnShowArena(self, point, weekyMedal, openWatch, parid)
	self.m_ArenaPoint = point
	self.m_WeekyMedal = weekyMedal
	self.m_OpenWatch = openWatch
	self.m_ParIds = parid or {}
	self:MarkUsedParter()
	local oView = CArenaView:GetView()
	if oView then
		oView:ShowEqualArenaPage()
	else
		CArenaView:ShowView(function (oView)
			oView:ShowEqualArenaPage()
		end)
	end
end

function CEqualArenaCtrl.GetParByPos(self, pos)
	if self.m_ParIds[pos] then
		return g_PartnerCtrl:GetPartner(self.m_ParIds[pos])
	end
end

function CEqualArenaCtrl.Match(self)
	if g_TeamCtrl:GetMemberSize() > 1 then
		g_NotifyCtrl:FloatMsg("组队状态下禁止匹配")
	else
		self.m_Result = define.EqualArena.WarResult.NotReceive
		netarena.C2GSEqualArenaMatch()
	end
end

--匹配操作反馈
function CEqualArenaCtrl.OnReceiveMatchResult(self, result)
	self:OnEvent(define.EqualArena.Event.ReceiveMatchResult, result)
end

--匹配成功对手信息
function CEqualArenaCtrl.OnReceiveMatchPlayer(self, data)
	self.m_EnemyInfo = data
	self:OnEvent(define.EqualArena.Event.ReceiveMatchPlayer, data)
end

--获取观战数据
function CEqualArenaCtrl.OpenWatch(self)
	netarena.C2GSEqualArenaOpenWatch()
end

--打开观战界面
function CEqualArenaCtrl.OnReceiveWatch(self, data)
	self.m_WatchInfo = {}
	for k,v in pairs(data) do
		self.m_WatchInfo[v.stage] = v
	end
	-- self:OnEvent(define.EqualArena.Event.OpenWatchPage)
	CEqualArenaWatchView:ShowView()
end

--打开回放记录界面
function CEqualArenaCtrl.GetArenaHistory(self)
	netarena.C2GSEqualArenaHistory()
end

function CEqualArenaCtrl.OnReceiveArenaHistory(self, historyInfo, historyOnShow)
	self.m_HistoryInfo = {}
	self.m_HistoryInfoSort = {}
	for k,v in pairs(historyInfo) do
		self.m_HistoryInfo[v.fid] = v
		self.m_HistoryInfoSort[k] = v.fid
	end

	self.m_ShowingHistory = historyOnShow
	-- self:OnEvent(define.EqualArena.Event.OpenReplay)
	CEqualArenaHistoryView:ShowView()
end

function CEqualArenaCtrl.OnReceiveFightResult(self, point, medal, result, currentpoint, weekyMedal, infoList)
	-- printc(string.format("OnReceiveFightResult: %s point %s medal %s result", point, medal, result))
	self.m_ArenaPoint = currentpoint
	self.m_WeekyMedal = weekyMedal
	self.m_ResultPoint = point
	self.m_ResultMedal = medal
	self.m_PlayerInfo = nil
	self.m_EnemyInfo = nil

	for k,v in pairs(infoList) do
		if self.m_ViewSide ~= 0 and v.camp == self.m_ViewSide and self.m_PlayerInfo == nil then
			self.m_PlayerInfo = v
		elseif v.pid == g_AttrCtrl.pid and self.m_PlayerInfo == nil then
			self.m_PlayerInfo = v
		else
			self.m_EnemyInfo = v
		end
	end
	if self.m_PlayerInfo.camp == result then
		self.m_Result = define.EqualArena.WarResult.Win
	else
		self.m_Result = define.EqualArena.WarResult.Fail
	end

	if self.m_Result == define.EqualArena.WarResult.Win then
		self.m_ArenaPoint = self.m_ArenaPoint + self.m_ResultPoint
	else
		self.m_ArenaPoint = self.m_ArenaPoint - self.m_ResultPoint
	end

	self:OnEvent(define.EqualArena.Event.OnWarEnd)
end

function CEqualArenaCtrl.OnReceiveSetShowing(self, fid)
	self.m_ShowingHistory = self.m_HistoryInfo[fid]
	self:OnEvent(define.EqualArena.Event.SetShowing, fid)
end

function CEqualArenaCtrl.OnReceiveLeftTime(self, ileft)
	self.m_LeftTime = ileft + g_TimeCtrl:GetTimeS()
	self:OnEvent(define.EqualArena.Event.OnReceiveLeftTime)
end

function CEqualArenaCtrl.GetLeftTimeText(self)
	local leftTime = self.m_LeftTime - g_TimeCtrl:GetTimeS()
	if leftTime <= 0 then
		return nil
	end
	local hour = math.modf(leftTime / 3600)
	local min = math.modf((leftTime % 3600) / 60)
	local sec = leftTime % 60
	return string.format("%02d:%02d:%02d", hour, min, sec)
end

function CEqualArenaCtrl.ShowWarStartView(self, infoList)
	--结算用缓存

	local oPlayerInfo = nil
	local oEnemyInfo = nil
	if (self.m_ViewSide ~= 0 and infoList[2].camp == self.m_ViewSide) 
		or (infoList[2].pid == g_AttrCtrl.pid) then
		oPlayerInfo = infoList[2]
		oEnemyInfo = infoList[1]
	else
		oPlayerInfo = infoList[1]
		oEnemyInfo = infoList[2]
	end

	self.m_PlayerInfo = self:CopyStartInfo(oPlayerInfo)
	self.m_EnemyInfo = self:CopyStartInfo(oEnemyInfo)
	CArenaWarStartView:ShowView(function (oView)
		oView:SetData({oPlayerInfo, oEnemyInfo})
	end)
end

function CEqualArenaCtrl.CopyStartInfo(self, oInfo)
	local dInfo = {
		name = oInfo.name,
		shape = oInfo.shape,
		pid = oInfo.pid,
	}
	return dInfo
end

--主界面替换伙伴
function CEqualArenaCtrl.ChangePartner(self, tPos, tParid)
	self.m_ParIds[tPos] = tParid
	if table.count(self.m_ParIds) < 2 then
		netarena.C2GSSetEqualArenaPartner({tParid})
	else
		netarena.C2GSSetEqualArenaPartner(self.m_ParIds)
	end
end
--主界面替换伙伴
function CEqualArenaCtrl.OnChangePartner(self, parids)
	self.m_ParIds = parids or {}
	self:MarkUsedParter()
	self:OnEvent(define.EqualArena.Event.OnChangePartner)
end

function CEqualArenaCtrl.MarkUsedParter(self)
	self.m_UsedPartnerID = {}
	for k,v in pairs(self.m_ParIds) do
		self.m_UsedPartnerID[v] = true
	end
	table.print(self.m_UsedPartnerID, "MarkUsedParter----------------->")
end

function CEqualArenaCtrl.IsPartnerUsed(self, parid)
	return self.m_UsedPartnerID[parid]
end

function CEqualArenaCtrl.OnSelectSection(self, info, fuwen, partner, operater, limit_partner, limit_fuwen, left_time)
	-- printc("OnSelectSection")
	self.m_WaitingResult = false
	self.m_PlayerInfos = {}
	self.m_SelectingPartnerList = {}
	self.m_SelectingEquipList = {}
	self.m_SelectedPartnerList = {}
	self.m_SelectedEquipList = {}
	self.m_SelectingPartnerCount = 0
	self.m_SelectingEquipCount = 0
	self.m_SelectingPartnerRecord = {}
	self.m_SelectingEquipRecord = {}
	for k,v in pairs(info) do
		self.m_SelectingPartnerRecord[v.info.pid] = {}
		self.m_SelectingEquipRecord[v.info.pid] = {}
		self.m_PlayerInfos[v.info.pid] = v
		if v.info.pid == operater then
			for iPos,parID in ipairs(v.select_par) do
				self.m_SelectingPartnerRecord[v.info.pid][iPos] = parID
				self.m_SelectingPartnerList[parID] = true
				self.m_SelectingPartnerCount = self.m_SelectingPartnerCount + 1
			end
			for iPos,equipID in ipairs(v.select_item) do
				self.m_SelectingEquipRecord[v.info.pid][iPos] = equipID
				self.m_SelectingEquipList[equipID] = true
				self.m_SelectingEquipCount = self.m_SelectingEquipCount + 1
			end
		end
		for _,parID in pairs(v.selected_partner) do
			self.m_SelectedPartnerList[parID] = true
		end
		for _,equipID in pairs(v.selected_fuwen) do
			self.m_SelectedEquipList[equipID] = true
		end
	end
	self.m_PartnerEquipList = fuwen

	self.m_PartnerList = {}
	for i,v in ipairs(partner) do
		self.m_PartnerList[i] = v
	end

	self.m_CurrentOperater = operater
	self.m_CurrentNeedPartner = limit_partner
	self.m_CurrentNeedEquip = limit_fuwen
	self.m_OverTime = g_TimeCtrl:GetTimeS() + left_time

	local viewObj = CEqualArenaPrepareView:GetView()
	self:OnEvent(define.EqualArena.Event.OnSelectSection)
	
	if not viewObj then
		CEqualArenaPrepareView:ShowView(function (oView)
			oView:ShowSelectPage()
		end)
	end
end

function CEqualArenaCtrl.GetRestSelectTime(self)
	return self.m_OverTime - g_TimeCtrl:GetTimeS()
end

function CEqualArenaCtrl.IsMyTurn(self)
	return self.m_CurrentOperater == g_AttrCtrl.pid
end

function CEqualArenaCtrl.SetSelecting(self, index, itemType)
	if self.m_WaitingResult then
		-- g_NotifyCtrl:FloatMsg("操作过快")
		return
	end
	-- printc(string.format("SetSelecting index = %s, itemType = %s", index, itemType))
	-- table.print(self.m_SelectedEquipList, "self.m_SelectedEquipList")
	if g_EqualArenaCtrl:IsMyTurn() then
		if itemType == define.EqualArena.SelectingType.Partner then
			if self.m_SelectedPartnerList[index] then
				g_NotifyCtrl:FloatMsg("不可重复选择")
				return
			end
			if self.m_SelectingPartnerList[index] then
				if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSSyncSelectInfo"]) then
					self.m_WaitingResult = true
					netarena.C2GSSyncSelectInfo(itemType, index, define.EqualArena.MarkType.None)
				end
			else
				if self.m_SelectingPartnerCount < self.m_CurrentNeedPartner then
					if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSSyncSelectInfo"]) then
						self.m_WaitingResult = true
						netarena.C2GSSyncSelectInfo(itemType, index, define.EqualArena.MarkType.Selecting)
					end
				else
					g_NotifyCtrl:FloatMsg("超出可选数")
				end
			end
		elseif itemType == define.EqualArena.SelectingType.Equip then
			if self.m_SelectedEquipList[index] then
				g_NotifyCtrl:FloatMsg("不可重复选择")
				return
			end
			if self.m_SelectingEquipList[index] then
				if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSSyncSelectInfo"]) then
					self.m_WaitingResult = true
					netarena.C2GSSyncSelectInfo(itemType, index, define.EqualArena.MarkType.None)
				end
			else
				if self.m_SelectingEquipCount < self.m_CurrentNeedEquip then
					if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSSyncSelectInfo"]) then
						self.m_WaitingResult = true
						netarena.C2GSSyncSelectInfo(itemType, index, define.EqualArena.MarkType.Selecting)
					end
				else
					g_NotifyCtrl:FloatMsg("超出可选数")
				end
			end
		end
	else
		g_NotifyCtrl:FloatMsg("还没轮到你噢")
	end
end

function CEqualArenaCtrl.OnSetSelecting(self, operater, select_type, index, handle_type)
	-- printc(string.format("OnSetSelecting operater = %s, select_type = %s, index = %s, handle_type = %s", operater, select_type, index, handle_type))
	if select_type == define.EqualArena.SelectingType.Partner then
		if handle_type == define.EqualArena.MarkType.None then
			self.m_SelectingPartnerList[index] = nil
			self.m_SelectingPartnerCount = self.m_SelectingPartnerCount - 1
			for i,v in ipairs(self.m_SelectingPartnerRecord[operater]) do
				if v == index then
					table.remove(self.m_SelectingPartnerRecord[operater], i)
					break
				end
			end
		else
			table.insert(self.m_SelectingPartnerRecord[operater], index)
			self.m_SelectingPartnerCount = self.m_SelectingPartnerCount + 1
			self.m_SelectingPartnerList[index] = true
		end
	elseif select_type == define.EqualArena.SelectingType.Equip then
		if handle_type == define.EqualArena.MarkType.None then
			self.m_SelectingEquipList[index] = nil
			for i,v in ipairs(self.m_SelectingEquipRecord[operater]) do
				if v == index then
					table.remove(self.m_SelectingEquipRecord[operater], i)
					break
				end
			end
			self.m_SelectingEquipCount = self.m_SelectingEquipCount - 1
		else
			table.insert(self.m_SelectingEquipRecord[operater], index)
			self.m_SelectingEquipCount = self.m_SelectingEquipCount + 1
			self.m_SelectingEquipList[index] = true
		end
	end
	self.m_WaitingResult = false
	self:OnEvent(define.EqualArena.Event.OnSetSelecting, {pid = operater, selectType = select_type, idx = index, handleType = handle_type})
end

function CEqualArenaCtrl.SubmitSelecting(self)
	if not self:IsMyTurn() then
		g_NotifyCtrl:FloatMsg("请耐心等候对方选择")
		return
	end
	local selectPar = {}
	local selectEquip = {}
	for k,v in pairs(self.m_SelectingPartnerList) do
		if v then
			table.insert(selectPar, k)
		end
	end
	for k,v in pairs(self.m_SelectingEquipList) do
		if v then
			table.insert(selectEquip, k)
		end
	end

	if #selectPar < self.m_CurrentNeedPartner or #selectEquip < self.m_CurrentNeedEquip then
		local msgStr = "选择未完成，是否随机选择剩余选项"
		local t = {
			msg = msgStr,
			okStr = "是",
			cancelStr = "否",
			okCallback = callback(self, "RandomSelect", selectPar, selectEquip),
		}
		g_WindowTipCtrl:SetWindowConfirm(t)
	else
		netarena.C2GSSelectEqualArena(selectPar, selectEquip)
	end
end

function CEqualArenaCtrl.RandomSelect(self, selectPar, selectEquip)
	local parList = self:GetRandomList(selectPar, self.m_CurrentNeedPartner)
	local equipList = self:GetRandomList(selectEquip, self.m_CurrentNeedEquip)
	netarena.C2GSSelectEqualArena(parList, equipList)
end

function CEqualArenaCtrl.GetRandomList(self, list, count)
	local bRepeat = false
	while (#list < count) do
		local idx = Utils.RandomInt(1, 8)
		bRepeat = false
		for k,v in pairs(list) do
			if v == idx then
				bRepeat = true
			end
		end
		if not bRepeat then
			table.insert(list, idx)
		end
	end
	return list
end

function CEqualArenaCtrl.OnCombineStart(self, pInfo, leftTime)
	self.m_CombineInfo = {}
	for k,v in pairs(pInfo) do
		self.m_CombineInfo[v.info.pid] = v
	end
	self.m_CombineOverTime = g_TimeCtrl:GetTimeS() + leftTime
	if CEqualArenaPrepareView:GetView() then
		self:OnEvent(define.EqualArena.Event.OnCombineStart)
	else
		CEqualArenaPrepareView:ShowView(function (oView)
			oView:ShowCombinePage()
		end)
	end
end

function CEqualArenaCtrl.OnCombineSubmit(self, selectPar, selectItem)
	self:OnEvent(define.EqualArena.Event.OnCombineSubmit)
end

function CEqualArenaCtrl.GetRestCombineTime(self)
	return self.m_CombineOverTime - g_TimeCtrl:GetTimeS()
end

function CEqualArenaCtrl.OnCombineDone(self, pid)
	self:OnEvent(define.EqualArena.Event.OnCombineDone, pid)
end

function CEqualArenaCtrl.ShowWarResult(self, oCmd)
	if CArenaWarResultView:GetView() == nil then
		CArenaWarResultView:ShowView()
	end
end
return CEqualArenaCtrl