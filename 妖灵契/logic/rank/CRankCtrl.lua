local CRankCtrl = class("CRankCtrl", CCtrlBase)
--[[
1.排行榜数据分为基础数据m_NetDataDic、特殊数据m_NetExtraDataDic（非必须）、自身排行m_PlayerRankInfo
2.数据按分页获取，每分页20（具体看rank表）个数据
3.数据有效期用时间戳做标记，每次获取数据时记录下次刷新时间，请求前对比时间戳再请求
]]--
function CRankCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:ResetCtrl()
end

function CRankCtrl.ResetCtrl(self)
	self.m_TimeLimitInfo = {}
	self.m_MaxTimeLimit = 0
	self:Clear()
end

function CRankCtrl.Clear(self)
	self.m_NeedRefresh = false
	self.m_RankCount = {}
	self.m_NextRefreshTime = {}
	self.m_PlayerRankInfo = {}
	self.m_NetDataDic = {}
	self.m_NetExtraDataDic = {}
	self.m_NetExtraDataRecord = {}
	self.m_DefaultRankPartner = nil
end

function CRankCtrl.OnReceiveClearAll(self, iRanklistId)
	--清榜时限时排行榜和普通榜一起清
	if iRanklistId == define.Rank.RankId.Partner then
		local sRankId = string.format("%s_", iRanklistId)
		for k,v in pairs(self.m_NextRefreshTime) do
			if string.find(k, sRankId) then
				self.m_NextRefreshTime[k] = 0
			end
		end
	elseif iRanklistId ~= 0 then
		self.m_NextRefreshTime[self:GetDataKey(iRanklistId, nil, define.Rank.SubType.Common)] = 0
		self.m_NextRefreshTime[self:GetDataKey(iRanklistId, nil, define.Rank.SubType.TimeLimit)] = 0
	else
		for k,v in pairs(self.m_NextRefreshTime) do
			self.m_NextRefreshTime[k] = 0
		end
	end
end

function CRankCtrl.ClearExtraData(self)
	self.m_NetExtraDataDic = {}
	self.m_NetExtraDataRecord = {}
end

function CRankCtrl.GetExtraData(self, iRanklistId, partnerType, iSubType)
	return self.m_NetExtraDataDic[self:GetDataKey(iRanklistId, partnerType, iSubType)] or {}
end

function CRankCtrl.GetRankData(self, iRanklistId, partnerType, iSubType)
	return self.m_NetDataDic[self:GetDataKey(iRanklistId, partnerType, iSubType)] or {}
end

function CRankCtrl.GetRankInfo(self, iRanklistId)
	return data.rankdata.DATA[iRanklistId]
end

function CRankCtrl.GetPlayerRankData(self, iRanklistId, partnerType, iSubType)
	return self.m_PlayerRankInfo[self:GetDataKey(iRanklistId, partnerType, iSubType)]
end

function CRankCtrl.GetRankCount(self, iRanklistId, partnerType, iSubType)
	if not self.m_NetDataDic[self:GetDataKey(iRanklistId, partnerType, iSubType)] then
		return 0
	end
	return self.m_RankCount[self:GetDataKey(iRanklistId, partnerType, iSubType)] or 0
end

function CRankCtrl.UpdateTimeLimitRankInfo(self, oInfo)
	self.m_TimeLimitInfo = {}
	self.m_MaxTimeLimit = 0
	for k,v in pairs(oInfo) do
		self.m_TimeLimitInfo[v.idx] = v
		if self.m_MaxTimeLimit < v.show_endtime then
			self.m_MaxTimeLimit = v.show_endtime
		end
	end
	-- printc("UpdateTimeLimitRankInfo")
	-- table.print(oInfo)
	self:OnEvent(define.Rank.Event.UpdateTimeLimitRankInfo)
end

function CRankCtrl.HasTimeLimitRank(self)
	return self.m_MaxTimeLimit > g_TimeCtrl:GetTimeS()
end

function CRankCtrl.GetDefualtLimitRankID(self)
	for i,v in ipairs(data.rankdata.RushSort) do
		if self.m_TimeLimitInfo[v] and self.m_TimeLimitInfo[v].show_endtime > g_TimeCtrl:GetTimeS() then
			return v
		end
	end
	-- printc("now:" .. g_TimeCtrl:GetTimeS())
	-- table.print(self.m_TimeLimitInfo, "self.m_TimeLimitInfo")
	return nil
end

function CRankCtrl.GetDefaultPartner(self, iSubType)
	local defaultParID = nil
	if iSubType == define.Rank.SubType.TimeLimit then
		defaultParID = IOTools.GetRoleData("DefaultTimeLimitRankPartner")
	else
		defaultParID = IOTools.GetRoleData("DefaultRankPartner")
	end
	if defaultParID == nil then
		defaultParID = 0
	end
	-- printc("defaultParID: " .. defaultParID)
	return defaultParID
end

function CRankCtrl.OpenRank(self, iRanklistId, iPartner, iSubType)
	iSubType = iSubType or define.Rank.SubType.Common
	if (iSubType == define.Rank.SubType.TimeLimit and not g_ActivityCtrl:ActivityBlockContrl("TimeLimitRank")) 
		or iSubType == define.Rank.SubType.Common and not g_ActivityCtrl:ActivityBlockContrl("rank") then
		return
	end
	self.m_IsOpenLimitRank = iSubType == define.Rank.SubType.TimeLimit
	if g_AttrCtrl.grade < data.globalcontroldata.GLOBAL_CONTROL.rank.open_grade then
		g_NotifyCtrl:FloatMsg(data.globalcontroldata.GLOBAL_CONTROL.rank.open_grade .. "级开启该功能")
		return
	end
	local rankId = iRanklistId
	if rankId == nil then
		if not self.m_IsOpenLimitRank then
			local iType = data.rankdata.RankTypeSort[1]
				local index = data.rankdata.RankType[iType].subid[1]
				rankId = data.rankdata.DATA[index].id
		else
			rankId = self:GetDefualtLimitRankID()
		end
	end
	if self.m_IsOpenLimitRank and rankId == nil then
		g_NotifyCtrl:FloatMsg("活动已经结束")
		return
	end
	local partnerType = iPartner
	if rankId == define.Rank.RankId.Partner then
		if partnerType == nil then
			partnerType = self:GetDefaultPartner(iSubType)
		else
			if not self.m_IsOpenLimitRank then
				IOTools.SetRoleData("DefaultRankPartner", partnerType)
			else
				IOTools.SetRoleData("DefaultTimeLimitRankPartner", partnerType)
			end
		end
	end
	self.m_DefaultRankPartner = partnerType
	if not self:GetDataFromServer(rankId, 1, partnerType, iSubType) then
		self:OnEvent(define.Rank.Event.ReceiveData, {ranklistId = rankId, page = 1, partnerType = partnerType, isNewData = false})
		if self.m_IsOpenLimitRank then
			if CTimeLimitRankView:GetView() == nil then
				CTimeLimitRankView:ShowView(function (oView)
					oView:OnChangeTab(rankId, partnerType)
				end)
			end
		elseif CRankView:GetView() == nil then
			CRankView:ShowView(function (oView)
				oView:OnChangeTab(rankId, partnerType)
			end)
		end
	end
end

--获取数据:C2GSMyRank+C2GSRankUpvoteInfo(非必经)+C2GSGetRankInfo
function CRankCtrl.GetDataFromServer(self, iRanklistId, page, iPartner, iSubType)
	iSubType = iSubType or define.Rank.SubType.Common
	local iPage = page
	self.m_IsOpenLimitRank = iSubType == define.Rank.SubType.TimeLimit
	if self.m_IsOpenLimitRank then
		local iLeaveTime = self:GetRushShowTime(iRanklistId)
		if iLeaveTime <= 0 then
			g_NotifyCtrl:FloatMsg("活动已经结束")
			return true
		end
	end
	local partnerType = iPartner
	if iRanklistId == define.Rank.RankId.Partner then
		if partnerType == nil then
			partnerType = self:GetDefaultPartner(iSubType)
		else
			if not self.m_IsOpenLimitRank then
				IOTools.SetRoleData("DefaultRankPartner", partnerType)
			else
				IOTools.SetRoleData("DefaultTimeLimitRankPartner", partnerType)
			end
		end
	end
	self.m_DefaultRankPartner = partnerType
	local sRanklistId = self:GetDataKey(iRanklistId, partnerType, iSubType)
	-- printc("GetDataFromServer: " .. sRanklistId)
	self.m_Need = {}
	self.m_Need[sRanklistId] = 0
	local infoList = {}
	if self.m_NextRefreshTime[sRanklistId] == nil then
		-- printc("第一次获取")
		iPage = 1
		self.m_Need[sRanklistId] = self.m_Need[sRanklistId] + 1
		if self:IsTerraWarOrgRank(iRanklistId) then
			netrank.C2GSMyOrgRank(iRanklistId, g_AttrCtrl.org_id)
		else
			table.insert(infoList, "my_rank")
		end
		
	elseif self.m_NextRefreshTime[sRanklistId] < g_TimeCtrl:GetTimeS() then
		-- printc("超时: " .. g_TimeCtrl:GetTimeS())
		self.m_NeedRefresh = true
		iPage = 1
		self.m_Need[sRanklistId] = self.m_Need[sRanklistId] + 1
		if self:IsTerraWarOrgRank(iRanklistId) then
			netrank.C2GSMyOrgRank(iRanklistId, g_AttrCtrl.org_id)
		else
			table.insert(infoList, "my_rank")
		end
	end
	if self:IsNeedExtraData(iRanklistId) and (self.m_NeedRefresh or self.m_NetExtraDataDic[sRanklistId] == nil or self.m_NetExtraDataRecord[sRanklistId][page] == nil) then
		self.m_Need[sRanklistId] = self.m_Need[sRanklistId] + 1
		table.insert(infoList, "upvote_info")
	end
	if self.m_NeedRefresh or not self:HasData(iRanklistId, iPage, partnerType, iSubType) then
		self.m_Need[sRanklistId] = self.m_Need[sRanklistId] + 1
		if self:IsTerraWarOrgRank(iRanklistId) then
			netrank.C2GSGetOrgRankInfo(iRanklistId, iPage, g_AttrCtrl.org_id)
		else
			table.insert(infoList, "rank_info")
		end
	else
		self:GetMyOrgRankInfo(sRanklistId)
	end
	if self.m_Need[sRanklistId] == 0 then
		self:AfterGetAllData(iRanklistId, iPage, false)
		return false
	elseif #infoList > 0 then
		netrank.C2GSOpenRankUI(iRanklistId, iPage, infoList, partnerType, (self.m_IsOpenLimitRank and 1 or 0))
	end
	return true
end

function CRankCtrl.OnReceiveLike(self, result, pid)
	if result == 0 then
	else
		for k,v in pairs(self.m_NetExtraDataDic) do
			if v ~= nil and v[pid] ~= nil then
				v[pid].count = v[pid].count + 1
				v[pid].status = 1
			end
		end
		self:OnEvent(define.Rank.Event.LikeSuccess, pid)
	end
end

function CRankCtrl.AfterGetAllData(self, iRanklistId, page, isNewData)
	local iSubType = self.m_IsOpenLimitRank and define.Rank.SubType.TimeLimit or define.Rank.SubType.Common
	local partnerType = nil
	if iRanklistId == define.Rank.RankId.Partner then
		partnerType = self.m_DefaultRankPartner
	end
	local sRanklistId = self:GetDataKey(iRanklistId, partnerType, iSubType)
	-- printc("AfterGetAllData: " .. sRanklistId)
	if self.m_Need[sRanklistId] then
		self.m_Need[sRanklistId] = self.m_Need[sRanklistId] - 1
		if self.m_Need[sRanklistId] > 0 then
			return
		end
	end
	-- printc("AfterGetAllData partnerType: " .. sRanklistId)
	if self:IsTerraWarRank(iRanklistId) then
		local oPage = g_TerrawarCtrl:GetTerraWarOrgPage()
		local oView = CTerraWarMainView:GetView()
		if self.m_NeedRefresh then
			self:OnEvent(define.Rank.Event.RefreshData, {ranklistId = iRanklistId})
		else
			self:OnEvent(define.Rank.Event.ReceiveData, {ranklistId = iRanklistId, page = page, isNewData = isNewData})
		end
	else
		if self.m_IsOpenLimitRank then
			if CTimeLimitRankView:GetView() == nil then
				CTimeLimitRankView:ShowView(function (oView)
					oView:OnChangeTab(iRanklistId, partnerType)
				end)
			end
		elseif CRankView:GetView() == nil then
			CRankView:ShowView(function (oView)
				oView:OnChangeTab(iRanklistId, partnerType)
			end)
		end
		if self.m_NeedRefresh then
			self:OnEvent(define.Rank.Event.RefreshData, {ranklistId = iRanklistId, partnerType = partnerType})
		else
			self:OnEvent(define.Rank.Event.ReceiveData, {ranklistId = iRanklistId, page = page, partnerType = partnerType, isNewData = isNewData})
		end
	end
	self.m_NeedRefresh = false
end

--接收到自己的排行数据
function CRankCtrl.ReceiveMyRank(self, iRanklistId, nextRefreshTime, rankCount, oData, iSubType)
	local partnerType = nil
	if iRanklistId == define.Rank.RankId.Partner then
		partnerType = self.m_DefaultRankPartner
	end
	local sRanklistId = self:GetDataKey(iRanklistId, partnerType, iSubType)
	self.m_RankCount[sRanklistId] = rankCount
	if rankCount == 0 then
		if self:IsTerraWarRank(iRanklistId) then
			local oPage = g_TerrawarCtrl:GetTerraWarOrgPage()
			if oPage then
				oPage:OnChangeTab(iRanklistId)
			elseif CTerraWarMainView:GetView() == nil then
				CTerraWarMainView:ShowView(function (oView)
					oView:OnChangeTab(iRanklistId)
				end)
			else
				self:OnEvent(define.Rank.Event.ReceiveEmptyData, {ranklistId = iRanklistId})
			end
		else
			if self.m_IsOpenLimitRank then
				if CTimeLimitRankView:GetView() == nil then
					CTimeLimitRankView:ShowView(function (oView)
						oView:OnChangeTab(iRanklistId, partnerType)
					end)
				end
			elseif CRankView:GetView() == nil then
				CRankView:ShowView(function (oView)
					oView:OnChangeTab(iRanklistId, partnerType)
				end)
			end
			self:OnEvent(define.Rank.Event.ReceiveEmptyData, {ranklistId = iRanklistId, partnerType = partnerType})
		end
		return
	end
	--默认值
	self.m_PlayerRankInfo[sRanklistId] = {}
	if iRanklistId == define.Rank.RankId.Partner then
		if oData and oData.partner then
			for k,v in pairs(oData.partner) do
				self.m_PlayerRankInfo[sRanklistId][k] = v
			end
		end
	else
		if oData then
			for k,v in pairs(oData) do
				self.m_PlayerRankInfo[sRanklistId][k] = v
			end
		end
	end

	self.m_PlayerRankInfo[sRanklistId].pid = self.m_PlayerRankInfo[sRanklistId].pid or g_AttrCtrl.pid
	self.m_PlayerRankInfo[sRanklistId].shape = self.m_PlayerRankInfo[sRanklistId].shape or g_AttrCtrl.model_info.shape
	self.m_PlayerRankInfo[sRanklistId].name = self.m_PlayerRankInfo[sRanklistId].name or g_AttrCtrl.name
	self.m_PlayerRankInfo[sRanklistId].grade = self.m_PlayerRankInfo[sRanklistId].grade or g_AttrCtrl.grade
	self.m_PlayerRankInfo[sRanklistId].warpower = self.m_PlayerRankInfo[sRanklistId].warpower or g_AttrCtrl:GetTotalPower()

	self.m_PlayerRankInfo[sRanklistId].point = self.m_PlayerRankInfo[sRanklistId].point or 0
	self.m_PlayerRankInfo[sRanklistId].segment = self.m_PlayerRankInfo[sRanklistId].segment or data.arenadata.SortId[#data.arenadata.SortId]
	self.m_PlayerRankInfo[sRanklistId].level = self.m_PlayerRankInfo[sRanklistId].level or 0

	self.m_PlayerRankInfo[sRanklistId].personal_points = self.m_PlayerRankInfo[sRanklistId].personal_points or 0 --据点战个人积分
	self.m_PlayerRankInfo[sRanklistId].position = self.m_PlayerRankInfo[sRanklistId].position or g_AttrCtrl.org_pos
	self.m_PlayerRankInfo[sRanklistId].school = self.m_PlayerRankInfo[sRanklistId].school or g_AttrCtrl.school
	self.m_PlayerRankInfo[sRanklistId].consume = self.m_PlayerRankInfo[sRanklistId].consume or 0
	self:GetMyOrgRankInfo(sRanklistId)
	if oData and oData.my_rank and oData.my_rank <= data.rankdata.DATA[iRanklistId].count and oData.my_rank ~= 0 then
		self.m_PlayerRankInfo[sRanklistId].rank = tonumber(oData.my_rank or 0)
	else
		self.m_PlayerRankInfo[sRanklistId].rank = "未上榜"
	end

	self.m_NextRefreshTime[sRanklistId] = nextRefreshTime
	-- self.m_NextRefreshTime[sRanklistId] = g_TimeCtrl:GetTimeS() + 999999999
	printc("nextRefreshTime: " .. os.date("%Y/%m/%d %H:%M:%S", nextRefreshTime))
	self:AfterGetAllData(iRanklistId, 1, true)
end

function CRankCtrl.GetDataKey(self, iRanklistId, partnerType, iSubType)
	return string.format("%s_%s_%s", iRanklistId, (partnerType or ""), (iSubType or 0))
end

function CRankCtrl.GetMyOrgRankInfo(self, sRanklistId)
	if not self.m_PlayerRankInfo[sRanklistId] then
		self.m_PlayerRankInfo[sRanklistId] = {}
	end
	if g_OrgCtrl:HasOrg() then
		local dOrgData = g_OrgCtrl:GetMyOrgInfo()
		self.m_PlayerRankInfo[sRanklistId].orgid = g_AttrCtrl.org_id --据点战全服排行公会id
		self.m_PlayerRankInfo[sRanklistId].org_points = self.m_PlayerRankInfo[sRanklistId].org_points or 0 --据点战公会积分
		self.m_PlayerRankInfo[sRanklistId].org_name = dOrgData.name
		self.m_PlayerRankInfo[sRanklistId].flag = dOrgData.sflag --公会字号
		self.m_PlayerRankInfo[sRanklistId].flagbgid = dOrgData.flagbgid --公会字号
		self.m_PlayerRankInfo[sRanklistId].leader = dOrgData.leadername
		self.m_PlayerRankInfo[sRanklistId].prestige = dOrgData.prestige
	end
end

--接收到额外数据
function CRankCtrl.ReceiveExtraData(self, iRanklistId, page, oData, iSubType)
	local partnerType = nil
	if iRanklistId == define.Rank.RankId.Partner then
		partnerType = self.m_DefaultRankPartner
	end
	local sRanklistId = self:GetDataKey(iRanklistId, partnerType, iSubType)
	if self.m_NetExtraDataDic[sRanklistId] == nil or self.m_NeedRefresh then
		self.m_NetExtraDataDic[sRanklistId] = {}
		self.m_NetExtraDataRecord[sRanklistId] = {}
	end
	self.m_NetExtraDataRecord[sRanklistId][page] = true

	for k,v in pairs(oData) do
		self.m_NetExtraDataDic[sRanklistId][v.key] = self:CopyUpvoteInfo(v)
	end
	self:AfterGetAllData(iRanklistId, page, true)
end

function CRankCtrl.CopyUpvoteInfo(self, oInfo)
	local dInfo = {
		key = oInfo.key,
		count = oInfo.count,
		status = oInfo.status,
	}
	return dInfo
end

--接收到排行榜数据
function CRankCtrl.ReceiveData(self, iRanklistId, page, firstStub, oData, iSubType)
	local partnerType = nil
	if iRanklistId == define.Rank.RankId.Partner then
		partnerType = self.m_DefaultRankPartner
	end
	local sRanklistId = self:GetDataKey(iRanklistId, partnerType, iSubType)
	if self.m_NetDataDic[sRanklistId] == nil or self.m_NeedRefresh then
		self.m_NetDataDic[sRanklistId] = {}
	end
	if sRanklistId == "115_0" then
		for k,v in pairs(oData) do
			table.insert(self.m_NetDataDic[sRanklistId], v)
		end
		local function sortFunc(v1, v2)
			local oData1 = data.partnerdata.DATA[v1.partype]
			local oData2 = data.partnerdata.DATA[v2.partype]
			if oData1.rare == oData2.rare then
				return oData1.partner_type < oData2.partner_type
			else
				return oData1.rare > oData2.rare
			end
		end
		table.sort(self.m_NetDataDic[sRanklistId], sortFunc)
	else
		local baseIndex = (page - 1) * data.rankdata.DATA[iRanklistId].per_page
		local index = 1
		for k,v in pairs(oData) do
			index = baseIndex + k
			self.m_NetDataDic[sRanklistId][index] = oData[k]
		end
	end
	self:AfterGetAllData(iRanklistId, page, true)
end

--判断数据是否存在
function CRankCtrl.HasData(self, iRanklistId, page, partnerType, iSubType)
	local sRanklistId = self:GetDataKey(iRanklistId, partnerType, iSubType)
	local index = data.rankdata.DATA[iRanklistId].per_page * (page - 1) + 1
	if self.m_NetDataDic[sRanklistId] == nil or self.m_NetDataDic[sRanklistId][index] == nil then
		return false
	end
	return true
end

--判断是否需要额外数据，如点赞等
function CRankCtrl.IsNeedExtraData(self, iRanklistId)
	local handleType = data.rankdata.DATA[iRanklistId].handle_id
	if handleType == define.Rank.HandleType.Like or handleType == define.Rank.HandleType.ReplayAndLike 
	or handleType == define.Rank.HandleType.DetailAndLike then
		return true
	else
		return false
	end
end

function CRankCtrl.OnReceivePowerDetail(self, oData)
	if CDetailPowerView:GetView() ~= nil then
		CDetailPowerView:CloseView()
	end
	CDetailPowerView:ShowView(function (oView)
		oView:SetData(oData)
	end)
end

--判断是否据点战排行
function CRankCtrl.IsTerraWarRank(self, iRanklistId)
	local terraWarRanks = {
		--据点的排行榜另外处理
		define.Rank.RankId.TerrawarOrg, 
		define.Rank.RankId.TerrawarServer,
	}
	return table.index(terraWarRanks, iRanklistId)
end

function CRankCtrl.IsTerraWarOrgRank(self, iRanklistId)
	return define.Rank.RankId.TerrawarOrg == iRanklistId
end

function CRankCtrl.IsTerraWarServerRank(self, iRanklistId)
	return define.Rank.RankId.TerrawarServer == iRanklistId
end

function CRankCtrl.GetRushLeaveTime(self, iRanklistId)
	if self.m_TimeLimitInfo[iRanklistId] and self.m_TimeLimitInfo[iRanklistId].endtime then
		return self.m_TimeLimitInfo[iRanklistId].endtime - g_TimeCtrl:GetTimeS()
	end
	return 0
end

function CRankCtrl.GetRushShowTime(self, iRanklistId)
	if self.m_TimeLimitInfo[iRanklistId] and self.m_TimeLimitInfo[iRanklistId].show_endtime then
		return self.m_TimeLimitInfo[iRanklistId].show_endtime - g_TimeCtrl:GetTimeS()
	end
	return 0
end

function CRankCtrl.ShowPartnerDetail(self, oParData)
	CPartnerLinkView:ShowView(function (oView)
		oView:Refresh(oParData)
	end)
end

return CRankCtrl