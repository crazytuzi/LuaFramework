local RepresentMgr = luanet.import_type("RepresentMgr");
local AvatarHeadInfoMgr = luanet.import_type("AvatarHeadInfoMgr");
local nFollowTDistance = 650;
local nNextFollowAttackEnemeyTime = 0;
Wedding.tbTableNpc = Wedding.tbTableNpc or {} 					-- 所有需要倒计时的喜宴npc
Wedding.tbSchedule = Wedding.tbSchedule or {} 					-- 行程
Wedding.tbAllWedding = Wedding.tbAllWedding or {}      			-- 所有正在举行的婚礼
Wedding.tbAllWeddingApply = Wedding.tbAllWeddingApply or {}		-- 所有申请进入婚礼的信息
Wedding.nWelcomeCount = Wedding.nWelcomeCount or 0 				-- 请柬数量
Wedding.tbHadWelcome = Wedding.tbHadWelcome or {} 				-- 已经邀请过的玩家
--[[
	行程结构 
	Wedding.tbSchedule = {}
	local tbSchedule = Wedding.tbSchedule
	local tbPlayerBookInfo = 
	{
		nBookTime = 123456789; 															-- 预订举办婚礼的时间戳
		tbPlayerInfo[nSex] = {dwID = dwID, szName = szName};							-- 主角
		nOpenTime = 123456789; 															-- 开启时间		
		nSendMailTime = 123456789; 														-- 发送提醒邮件的时间
		nSendOverdueMailTime = 123456789; 												-- 发送婚礼过期邮件时间
	}
	local tbDetail = {tbPlayerBookInfo} 												-- 以这种方式存主要是为了防止
	tbSchedule.tbAllSchedule = {
		[nOpen] = tbDetail
	}
	local tbMyPlayerBookInfo = 
	{
		nBookTime = 123456789; 															-- 预订举办婚礼的时间戳
		tbPlayer = {[男主角id] = nSex, [女主角id] = nSex};								-- 主角
		nOpenTime = 123456789; 															-- 开启时间		
		nSendMailTime = 123456789; 														-- 发送提醒邮件的时间
		nSendOverdueMailTime = 123456789; 												-- 发送婚礼过期邮件时间
	}
	tbSchedule.tbMySchedule = {}
	tbSchedule.tbMySchedule.nBookLevel = nBookLevel
	tbSchedule.tbMySchedule.nOpen = nOpen
	tbSchedule.tbMySchedule.tbPlayerBookInfo = tbMyPlayerBookInfo

	婚礼信息结构
	local tbMapInfo = {}
	tbMapInfo.nMapId = nMapId
	tbMapInfo.nLevel = nLevel
	tbMapInfo.nStartWeddingTime = nStartWeddingTime
	tbMapInfo.tbPlayer = {[nSex] = {dwID = dwID;szName = szName}}
	table.insert(Wedding.tbAllWedding, tbMapInfo)

	申请信息结构
	local tbApplyInfo = {
		nPlayerId = dwID;
		szName = v.szName;
		nHonorLevel = v.nHonorLevel;
		nPortrait = v.nPortrait;
		szKinName = v.szKinName;
		nApplyTime = v.nApplyTime;
		nFaction = v.nFaction;
		nLevel = v.nLevel;
		nVipLevel = v.nVipLevel
	}
	table.insert(Wedding.tbAllWeddingApply, tbApplyInfo)

	-- 请柬数据结构
	local tbWelcomeInfo = {}
	tbWelcomeInfo.nMapId = self.nMapId
	tbWelcomeInfo.nLevel = self.nWeddingLevel
	tbWelcomeInfo.tbPlayer = {
		[Gift.Sex.Boy] = {
			nPlayerId = self.nBoyPlayerId;
			szName = self:ManName();
		};
		[Gift.Sex.Girl] = {
			nPlayerId = self.nGirlPlayerId;
			szName = self:FemaleName();
		};
	}
]]

local emPLAYER_STATE_NORMAL = 2 --正常在线状态

function Wedding:RoleStartWedding(nWelcomeCount)
	Wedding.tbAllWeddingApply = {}
	Wedding.tbHadWelcome = {}
	Wedding.nWelcomeCount = nWelcomeCount
end
-- 花轿游城相关
local function GetPositionInRay(orgX, orgY, desX, desY, nLength)
	local nBevelLen = math.sqrt((orgX - desX)^2 + (orgY - desY)^2);
	local nUnitLenX = (desX - orgX) / nBevelLen;
	local nUnitLenY = (desY - orgY) / nBevelLen;

	return orgX + nUnitLenX * nLength, orgY + nUnitLenY * nLength;
end

function Wedding:IsRoleWeddingTouring()
	return self.nRoleWeddingState
end

function Wedding:OnPlayerState()
	self:CloseAllWeddingWnd()
	self.nRoleWeddingState = true
	Timer:Register(Env.GAME_FPS, self.DoPlayerState, self)
end

function Wedding:DoPlayerState()
	Ui:ChangeUiState(Ui.STATE_WeddingTour);
	Operation:DisableWalking()
	local pNpc = me.GetNpc()
	if pNpc then
		pNpc.SetHideNpc(1)
	end
end

function Wedding:OnRemovePlayerState()
	self.nRoleWeddingState = nil
	Operation:EnableWalking()
	Ui:ChangeUiState(Ui.STATE_DEFAULT, true)
	-- 显示自己
	local pNpc = me.GetNpc()
	if pNpc then
		pNpc.SetHideNpc(0)
	end
end

function Wedding:StartWatchState(nNpcId)
	RepresentMgr.AddShowRepNpc(nNpcId)
	BindCameraToNpc(nNpcId, 220)
end

function Wedding:EndWatchState(nNpcId)
	BindCameraToNpc(0, 220)
	RepresentMgr.ClearShowRepNpc()
	self:CloseFollowTimer()
end

function Wedding:StartFollow(nNpcId)
	self:CloseFollowTimer()
	self.nFollowTimer = Timer:Register(3, self.DoStartFollow, self, nNpcId);
end

function Wedding:CloseFollowTimer()
	 if self.nFollowTimer then
        Timer:Close(self.nFollowTimer)
        self.nFollowTimer = nil
    end
end

function Wedding:DoStartFollow(nNpcId)
	local pFollowNpc = KNpc.GetById(nNpcId);
	if not pFollowNpc then
		self.nFollowTimer = nil
		RemoteServer.WeddingCheckNpc(nNpcId);
		return
	end

	local nMapId, nMyPosX, nMyPosY = me.GetWorldPos();
	local _, nFollowX, nFollowY = pFollowNpc.GetWorldPos();
	local nDisSquare = Lib:GetDistsSquare(nMyPosX, nMyPosY, nFollowX, nFollowY);
	if nDisSquare > (nFollowTDistance^2) then
		local nX, nY = GetPositionInRay(nFollowX, nFollowY, nMyPosX, nMyPosY, nFollowTDistance * 0.3);
		if GetBarrierInfo(nMapId, nX, nY) == 0 then
			me.GotoPosition(nX, nY);
		else
			me.GotoPosition(nFollowX, nFollowY);
		end
	end

	return true;
end

function Wedding:TryBubbleTalk(nNpcId, nNpcTID)
	local szBubble = Wedding.tbBubbleMsg[nNpcTID]
	if szBubble then
		self:DoBubbleTalk(nNpcId, Wedding.szBubbleTime, szBubble)
	end
end

function Wedding:DoBubbleTalk(nNpcId, szBubbleTime, szMsg)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return
	end
	pNpc.BubbleTalk(szMsg, szBubbleTime)
end

function Wedding:OnLogin(bReconnect)
	if me.nMapTemplateId ~= Wedding.nTourMapTemplateId then
		return
	end
	if self.nRoleWeddingState and Ui.nChangeUiState == Ui.STATE_WeddingTour then
		Ui:ChangeUiState(Ui.STATE_DEFAULT, true)
	end
end

function Wedding:GetTourPlayer()
	return Wedding.tbTourPlayer
end

function Wedding:OnMapLoaded(nMapTemplateID)
	if me.nMapTemplateId ~= nMapTemplateID then
		return
	end
	self:MapDecorate()
end

function Wedding:MapDecorate()
	if self.bWedding then
		Wedding:ShowWeddingDecorate()
	else
		Wedding:HideWeddingDecorate()
	end
	local tbForce
	-- 正在游城的时候不显示巡逻兵
	if self.bWedding and not self.bTouring then
		tbForce = {["WeddingNpc"] = true}
	end
	ClientNpc:OnEnterMap(me.nMapTemplateId, tbForce)
end

-- bWedding 是判断是否显示氛围的标准 bTouring 是判断正在游城中的标准 tbTourPlayer 是举行游城玩家的诗句
function Wedding:SynData(tbData, bWedding, tbTourPlayer, bTouring)
	if me.nMapTemplateId ~= Wedding.nTourMapTemplateId then
		return
	end
	Wedding.tbTourPlayer = tbTourPlayer
	tbData = tbData or {}
	Map:UpdateExtraSound(Wedding.nTourMapTemplateId, tbData.tbSound or {}, tbData.tbOverdueSound or {})
	Map:RestartPlayMapSound()
	self.bWedding = bWedding
	self.bTouring = bTouring
	self:MapDecorate()
	if not bTouring then
		self.tbTourPosInfo = nil
	end
end

function Wedding:OnJoinWedding(nMapTID)
	self:CloseAllWeddingWnd()
	AutoFight:StopFollowTeammate();
end

function Wedding:CloseAllWeddingWnd()
	for _, v in ipairs(Wedding.tbAllWeddingWnd) do
		Ui:CloseWindow(v)
	end
end

-- 拜堂相关
function Wedding:OnStateMarryCeremonyState(bChangeUiState)
	Operation:DisableWalking()
	if bChangeUiState then
		Timer:Register(1, function () Ui:ChangeUiState(Ui.STATE_ASYNC_BATTLE); end)
	end
	self:CloseAllWeddingWnd()
end

function Wedding:OnEndMarryCeremonyState()
	Operation:EnableWalking()
	if Ui.nChangeUiState ~= Ui.STATE_WeddingFuben then
		Ui:ChangeUiState(Ui.STATE_WeddingFuben)
	end
end

function Wedding:OnRoleStartMarryCeremonyState()
	-- 隐藏自己
	local pNpc = me.GetNpc()
	if pNpc then
		pNpc.SetHideNpc(1)
	end
end

function Wedding:OnRoleEndMarryCeremonyState()
	-- 显示自己
	local pNpc = me.GetNpc()
	if pNpc then
		pNpc.SetHideNpc(0)
	end
end

function Wedding:OnPlayMarryCeremonySceneAnim(tbRoleData, nLevel)
	local tbMapSetting = Wedding.tbWeddingLevelMapSetting[nLevel]
	RepresentMgr.SetSceneObjActive(tbMapSetting.szWeddingScene, true)
	
	-- RepresentMgr.SetSceneObjActive(tbMapSetting.tbMarryCeremonyGirlRolePath.Woman, false)
	-- RepresentMgr.SetSceneObjActive(tbMapSetting.tbMarryCeremonyGirlRolePath.Loli, true)
	Ui:OpenWindow("WeddingHeadPointPanel", tbRoleData, nLevel)
	local nSoundID = Wedding.tbWeddingLevelMapSetting[nLevel] and Wedding.tbWeddingLevelMapSetting[nLevel].nMarryCeremonySound
	if nSoundID then
		Map:PlaySceneOneSound(nSoundID)
	end
end


function Wedding:OnStopMarryCeremonySceneAnim(nLevel)
	local tbMapSetting = Wedding.tbWeddingLevelMapSetting[nLevel]
	RepresentMgr.SetSceneObjActive(tbMapSetting.szWeddingScene, false)
	Ui:CloseWindow("WeddingHeadPointPanel")
	Map:RestartPlayMapSound()
end

function Wedding:TryDestroyUi(szUiName)
	Ui:CloseWindow(szUiName)
	Ui.UiManager.DestroyUi(szUiName)
end

function Wedding:ShowWeddingDecorate()
	RepresentMgr.SetSceneObjActive(Wedding.szWeddingDecorateUiName, true)
end

function Wedding:HideWeddingDecorate()
	RepresentMgr.SetSceneObjActive(Wedding.szWeddingDecorateUiName, false)
end

function Wedding:OnLeaveMap()
	Ui:CloseWindow("HomeScreenFuben")
	Ui:CloseWindow("MessageBox")
	-- 恢复正常游戏速度
	SetGameWorldScale(1);
	self:CloseTableNpcTimer()
	self:CloseAllWeddingWnd()
	RepresentMgr.ClearShowRepNpc()
end

function Wedding:CheckBeforeChangeTitle(szHusbandTitle, szWifeTitle)
	if not TeamMgr:HasTeam() then
		return false, "你没有组队"
	end
	local nMyId = me.dwID
	if not TeamMgr:IsCaptain(nMyId) then
		return false, "此等大事还是让[FFFE0D]队长[-]来操作吧"
	end
	local tbMembers = TeamMgr:GetTeamMember()
	if #tbMembers~=1 then
		return false, "必须夫妻双方组队"
	end
	local nOtherId = tbMembers[1].nPlayerID
	if not Wedding:IsLover(nMyId, nOtherId) then
		return false, "你们不是夫妻关系"
	end
	if me.GetMoney("Gold")<self.nChangeTitleCost then
		return false, "元宝不足"
	end

	local nLen1 = Lib:Utf8Len(szHusbandTitle)
	local nLen2 = Lib:Utf8Len(szWifeTitle)
	if math.max(nLen1, nLen2)>self.nTitleNameMax or math.min(nLen1, nLen2)<self.nTitleNameMin then
		return false, string.format("可输入的后缀长度需要在%d~%d个汉字内", self.nTitleNameMin, self.nTitleNameMax)
	end
	if not CheckNameAvailable(szHusbandTitle) or not CheckNameAvailable(szWifeTitle) then
		return false, "含有非法字符，请修改后重试"
	end
	return true
end

function Wedding:ChangeTitleReq(szHusbandTitle, szWifeTitle)
	local bOk, szErr = self:CheckBeforeChangeTitle(szHusbandTitle, szWifeTitle)
	if not bOk then
		return false, szErr
	end

	RemoteServer.OnWeddingRequest("ChangeTitleReq", szHusbandTitle, szWifeTitle)
	return true
end


function Wedding:Propose(nBeProposeId, nBeProposeNpcId, szOtherName, nProposeIndex)
	Ui:OpenWindow("MarriageRequestPanel", nil, nBeProposeId, szOtherName, nProposeIndex)
	self:HideNpcBeside({me.GetNpc().nId, nBeProposeNpcId})
	self:ProposeState()
end

function Wedding:BePropose(nProposeId, nProposeNpcId, szOtherName, nProposeIndex)
	Ui:OpenWindow("MarriageRequestPanel", nProposeId, nil, szOtherName, nProposeIndex)
	self:HideNpcBeside({me.GetNpc().nId, nProposeNpcId})
	self:ProposeState()
end

function Wedding:ProposeState()
	self.nWeddingProposeState = Ui.nChangeUiState
	Operation:DisableWalking()
	Ui:ChangeUiState(Ui.STATE_WeddingEngaged)
	for _, v in ipairs(Wedding.tbProposeCloseWnd) do
		Ui:CloseWindow(v)
	end
end

function Wedding:EndProposeState()
	Operation:EnableWalking()
	Ui.Effect.ShowAllRepresentObj(1)
	Wedding:TryDestroyUi("MarriageRequestPanel")
	if self.nWeddingProposeState and self.nWeddingProposeState ~= Ui.nChangeUiState then
		Ui:ChangeUiState(self.nWeddingProposeState, true)
	end
end

function Wedding:OnProposeResult(bOk)
	self:EndProposeState()
	if bOk then
		Ui:OpenWindow("YanHuaAniPanel")
	end
end

function Wedding:OnCancelPropose()
	self:EndProposeState()
end

-- 对方在求婚过程中打断了（切地图或者下线）
function Wedding:BeProposeBreak(szOtherName)
	self:EndProposeState()
	me.CenterMsg(string.format(Wedding.szProposeBeBreakTip, szOtherName), true)
end

-- 自己在求婚过程中打断了（切地图或者下线）
function Wedding:ProposeBreak()
	self:EndProposeState()
	me.CenterMsg(Wedding.szProposeBreakTip, true)
end

function Wedding:HideNpcBeside(tbNpcId)
	Ui.Effect.ShowAllRepresentObj(0)
	for _, nNpcId in pairs(tbNpcId or {}) do
		Ui.Effect.ShowNpcRepresentObj(nNpcId, true)
	end
end

-- 祝福完成
function Wedding:OnBlessEnd()
	Ui:CloseWindow("WeddingBlessingPanel")
end	

local tbOtherUi = {ItemBox=false, HomeScreenTask=true}
function Wedding:SetOtherUiVisable(bShow)
	self.tbHideUi = self.tbHideUi or {}
	if not bShow then
		for szUi, bAutoShow in pairs(tbOtherUi) do
			if Ui:WindowVisible(szUi)==1 and Ui(szUi).pPanel:IsActive("Main") then
				if bAutoShow then
					self.tbHideUi[szUi] = true
				end
				Ui:CloseWindow(szUi)
			end
		end
	else
		for szUi in pairs(self.tbHideUi) do
			Ui:OpenWindow(szUi)
		end
		self.tbHideUi = {}
	end
end

function Wedding:OnDressChange(bOn)
	self.bOn = bOn
	self:SetOtherUiVisable(not bOn)
	UiNotify.OnNotify(UiNotify.emNOTIFY_WEDDING_DRESS_CHANGE, bOn)
end

function Wedding:OnSynTableNpcData(tbData)
	Wedding.tbTableNpc = tbData
	self:TryStartTableNpcTimer()
end

function Wedding:TryStartTableNpcTimer()
	self:CloseTableNpcTimer()
	self:ArrangeTableNpc()
	if next(Wedding.tbTableNpc) then
		self.nTableNpcTimer = Timer:Register(Env.GAME_FPS, self.SetTableNpcName, self);
	end
end

function Wedding:SetTableNpcName()
	local nNowTime = GetTime()
	for nNpcId, v in pairs(Wedding.tbTableNpc or {}) do
		local pNpc = KNpc.GetById(nNpcId)
		if pNpc then
			local nCountDown = v[1] - nNowTime
			if nCountDown >= 0 then
				pNpc.SetName(string.format("%s:%s", v[2] or "", nCountDown))
			end
		end
	end
	return true
end

function Wedding:ArrangeTableNpc()
	local nNowTime = GetTime()
	for nNpcId, v in pairs(Wedding.tbTableNpc or {}) do
		if v[1] <= nNowTime then
			Wedding.tbTableNpc[nNpcId] = nil
		end
	end
end

function Wedding:CloseTableNpcTimer()
	if self.nTableNpcTimer then
        Timer:Close(self.nTableNpcTimer)
        self.nTableNpcTimer = nil
    end
end

function Wedding:RequestSynSchedule()
	RemoteServer.OnWeddingRequest("SynSchedule");
end

function Wedding:OnSynSchedule(tbData)
	Wedding.tbSchedule = tbData
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_WEDDING_SCHEDULE);
end

function Wedding:GetMySchdule()
	return Wedding.tbSchedule and Wedding.tbSchedule.tbMySchedule
end

-- 但会各档次没人预订的日期
function Wedding:GetCanBookSchdule(nWeddingLevel)
	local tbCan = {}
	local tbMapSetting = Wedding.tbWeddingLevelMapSetting[nWeddingLevel]
	if not tbMapSetting or not tbMapSetting.bBook then
		return tbCan 
	end
	local tbSchedule = Wedding.tbSchedule or {}
	local tbAllSchedule = tbSchedule.tbAllSchedule or {}
	local nStartOpen = Wedding:GetStartOpen(tbMapSetting)
	for i = 0, tbMapSetting.nPre - 1 do
		local nOpen = i + nStartOpen
		if not tbAllSchedule[nOpen] then
			local nBookTime = 0
			if nWeddingLevel == Wedding.Level_2 then
				nBookTime = Lib:GetTimeByLocalDay(nOpen)
			elseif nWeddingLevel == Wedding.Level_3 then
				--nBookTime = Lib:GetTimeByWeek(nOpen, 7, 0, 0, 0)
				nBookTime = Lib:GetTimeByLocalDay(nOpen)
			end
			if self:CheckOpen(nWeddingLevel, nBookTime) then
				table.insert(tbCan, nBookTime)
			end
		end
	end
	return tbCan
end

function Wedding:GetHadBook(nWeddingLevel)

	local tbHad = {}
	local tbMapSetting = Wedding.tbWeddingLevelMapSetting[nWeddingLevel]
	if not tbMapSetting or not tbMapSetting.bBook then
		return tbHad
	end
	local tbSchedule = Wedding.tbSchedule or {}
	local tbAllSchedule = tbSchedule.tbAllSchedule or {}
	local nStartOpen = Wedding:GetStartOpen(tbMapSetting)
	for i = 0, tbMapSetting.nPre - 1 do
		local nOpen = i + nStartOpen
		local tbDetail = tbAllSchedule[nOpen]
		if tbDetail then
			local nTime
			if nWeddingLevel == Wedding.Level_2 then
				nTime = Lib:GetTimeByLocalDay(nOpen)
			elseif nWeddingLevel == Wedding.Level_3 then
				--nTime = Lib:GetTimeByWeek(nOpen, 7, 0, 0, 0)
				nTime = Lib:GetTimeByLocalDay(nOpen)
			end
			if nTime then
				local tbInfo = {}
				tbInfo.nTime = nTime
				tbInfo.tbDetail = tbDetail
				table.insert(tbHad, tbInfo)
			end
		end
	end
	return tbHad
end

function Wedding:RequestWeddingMap()
	RemoteServer.OnWeddingRequest("TrySynWeddingMap");
end

function Wedding:OnSynWeddingMap(tbData, bMerge)
	if not bMerge then
		Wedding.tbAllWedding = tbData
	else
		Lib:MergeTable(Wedding.tbAllWedding, tbData)
	end
end

-- 所有WeddingMap同步完成
function Wedding:OnSynWeddingMapFinish()
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_WEDDING_MAP);
end

-- 返回所有婚礼信息
function Wedding:GetWeddingMap()
	Wedding:SortWeddingMap()
	return Wedding.tbAllWedding
end

function Wedding:SortWeddingMap()
	if #Wedding.tbAllWedding > 1 then
		local fnSort = function (a, b)

			if a.nLevel == b.nLevel then
				-- 次而优先最新开启婚礼
				return a.nStartWeddingTime > b.nStartWeddingTime
			end
			-- 优先高档次婚礼
			return a.nLevel > b.nLevel
		end
		table.sort(Wedding.tbAllWedding, fnSort)
	end
end

-- 请求邀请函相关数据
function Wedding:RequestWelcome()
	RemoteServer.OnWeddingRequest("SynWelcome");
end

-- 邀请函相关数据同步完成
function Wedding:OnSynWelcome()
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_WEDDING_WELCOME);
end

-- 有新的玩家申请
function Wedding:OnNewApply()
	Ui:SetRedPointNotify("Wedding_ApplyWelcome");
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_WEDDING_WELCOME);
end
-- 清理玩家申请
function Wedding:OnClearApply()
	Ui:ClearRedPointNotify("Wedding_ApplyWelcome");
end

-- 同步申请信息
function Wedding:OnSynWeddingApply(tbData, bMerge)
	if not bMerge then
		Wedding.tbAllWeddingApply = tbData
	else
		Lib:MergeTable(Wedding.tbAllWeddingApply, tbData)
	end
end

-- 返回所有申请信息
function Wedding:GetWeddingMapApply()
	local tbList = {}
	for _, v in pairs(Wedding.tbAllWeddingApply) do
		-- 筛掉已经发过的
		if not self.tbHadWelcome[v.nPlayerId] then
			table.insert(tbList, v)
		end
	end
	if #tbList > 1 then
		local fnSort = function (a, b)
			-- 先申请的优先
			return a.nApplyTime < b.nApplyTime
		end
		table.sort(tbList, fnSort)
	end
	return tbList
end

-- 返回所有家族成员
function Wedding:GetKinMember()
	local tbList = {}
	local nLove = Wedding:GetLover(me.dwID)
	if not nLove then
		return tbList 
	end
	local tbOnlineMembers = Kin:GetMemberState() or {};
	local tbMembers = Kin:GetMemberList() or {}
	for _, v in pairs(tbMembers) do
		-- 刷掉离线的和已发过请柬的和自己和爱侣
		if tbOnlineMembers[v.nMemberId] and not Wedding.tbHadWelcome[v.nMemberId] and v.nMemberId ~= me.dwID and v.nMemberId ~= nLove then
			table.insert(tbList, v)
		end
	end
	local fnSort  =function (a, b)
		-- 按职位高低排序
		if a.nCareer == b.nCareer then
			-- 次而贡献度
			return a.nContribution > b.nContribution;
		else
			local nOrderA = Kin.Def.tbCareersOrder[a.nCareer] or math.huge
			local nOrderB = Kin.Def.tbCareersOrder[b.nCareer] or math.huge
			return nOrderA < nOrderB
		end
	end
	if #tbList > 1 then
		table.sort(tbList, fnSort)
	end
	return tbList
end

-- 返回好友列表
function Wedding:GetFriendList()
	local tbList = {}
	local nLove = Wedding:GetLover(me.dwID)
	if not nLove then
		return tbList 
	end
	local tbAllFriend = FriendShip:GetAllFriendData() or {}
	for _, v in pairs(tbAllFriend) do
		-- 刷掉离线和已发过请柬的和自己和爱侣
		if v.nState  == emPLAYER_STATE_NORMAL and not Wedding.tbHadWelcome[v.dwID] and v.dwID ~= me.dwID and v.dwID ~= nLove then
			table.insert(tbList, v)
		end
	end
	local fnSort = function (a, b)
		-- 按亲密度从高到底
		return a.nImity > b.nImity
	end
	if #tbList > 1 then
		table.sort(tbList, fnSort)
	end
	return tbList
end

-- 返回请柬数量
function Wedding:GetWelcomeCount()
	return Wedding.nWelcomeCount or 0
end

-- 同步请柬数量
function Wedding:OnSynWelcomeCount(nCount)
	Wedding.nWelcomeCount = nCount
end

-- 同步已经邀请过的玩家
function Wedding:OnSynHadWelcome(tbData)
	for k, v in pairs(tbData or {}) do
		Wedding.tbHadWelcome[k] = v
	end
end

-- 同步请柬主角数据
function Wedding:OnSynWelcomeInfo(tbWelcomeInfo)
	-- 打开请柬界面
	Ui:OpenWindow("WeddingWelcomePanel", tbWelcomeInfo)
end

--[[
tbData = {
	nVer = version,
	tbList = {
		{name1, gold1},
		{name2, gold2},
		{name3, gold3},
		...
	},
	bCanGive = boolean,
	nRemain = 123,
}
]]
function Wedding:OnUpdateCashGift(nHost1, nHost2, tbData)
	nHost1, nHost2 = self:NormalizeIds(nHost1, nHost2)

	self.tbCashGiftData = self.tbCashGiftData or {}
	self.tbCashGiftData[nHost1] = self.tbCashGiftData[nHost1] or {}
	self.tbCashGiftData[nHost1][nHost2] = tbData
	UiNotify.OnNotify(UiNotify.emNOTIFY_WEDDING_CASHGIFT_CHANGE)
end

function Wedding:UpdateCashGiftData(nHost1, nHost2)
	local tbData = self:GetCashGiftData(nHost1, nHost2)
	RemoteServer.OnWeddingRequest("UpdateCashGiftReq", nHost1, nHost2, tbData.nVer or 0)
end

function Wedding:OnLogout()
	self.tbCashGiftData = nil
end

function Wedding:GetCashGiftData(nHost1, nHost2)
	nHost1, nHost2 = self:NormalizeIds(nHost1, nHost2)

	self.tbCashGiftData = self.tbCashGiftData or {}
	if not self.tbCashGiftData[nHost1] or not self.tbCashGiftData[nHost1][nHost2] then
		return {bCanGive=true, nRemain=math.huge}
	end
	return self.tbCashGiftData[nHost1][nHost2]
end

function Wedding:GiveCashGiftReq(nHost1, nHost2, nGold)
	local nMyId = me.dwID
	if nMyId==nHost1 or nMyId==nHost2 then
		return false, "不能送给自己"
	end

	if not nHost1 or not nHost2 or not nGold then
		return false, "请选择赠送金额"
	end

	if not self.tbCashGiftSettings[nGold] then
		return false, "赠送金额不合法"
	end

	if me.GetMoney("Gold")<nGold then
		return false, "元宝不足", "not_enough_gold"
	end
	me.MsgBox(string.format("确定要赠送[FFFE0D]%d元宝[-]作为礼金吗？", nGold),
		{
			{"确定", function ()
					RemoteServer.OnWeddingRequest("GiveCashGiftReq", nHost1, nHost2, nGold)
			end};
			{"取消"};
		});
	return true
end

function Wedding:OnFinishPromise()
	Wedding:TryDestroyUi("WeddingSendPromisePanel")
end

function Wedding:OnRolePromiseState(nTime)
	self:CloseAllWeddingWnd()
	Ui:OpenWindow("WeddingSendPromisePanel", nTime or Wedding.nPromiseEndTime)
end

function Wedding:OnChoosePropose(szName)
	Ui:CloseWindow("ItemTips")
    Ui:CloseWindow("ItemBox")
    Ui:OpenWindow("WeddingChoosePromisePanel", szName)
end

function Wedding:PlayWeddingFubenFirework(nId)
	local tbFirework = Wedding.tbPlayFireworkSetting[nId]
	if not tbFirework then
		return
	end
	for _, v in ipairs(tbFirework) do
		Ui:PlayEffect(unpack(v))
	end
end

function Wedding:PlayWeddingTourFirework(nId)
	local tbFirework = Wedding.tbTourPlayFireworkSetting[nId]
	if not tbFirework then
		return
	end
	for _, v in ipairs(tbFirework) do
		Ui:PlayEffect(unpack(v))
	end
end

function Wedding:TryEatFood(nNpcId)
	self:BreakEatFood()
	self.nEatFoodTimerId = Timer:Register(Wedding.nDinnerWaitTime * Env.GAME_FPS, function () 
		self.nEatFoodTimerId = nil
		RemoteServer.OnWeddingRequest("TryEatTableFood", nNpcId); 
		end)
	Ui:StartProcess("食用中", Wedding.nDinnerWaitTime * Env.GAME_FPS)
end

function Wedding:BreakEatFood()
	if not Wedding:GetWeddingMapLevel(me.nMapTemplateId) then
		return
	end
	if Ui:WindowVisible("NpcStrip") == 1 then
		Ui:CloseProcess()
	end
	if self.nEatFoodTimerId then
		Timer:Close(self.nEatFoodTimerId)
        self.nEatFoodTimerId = nil
	end
end

function Wedding:HideAllName(bActive)
	Ui.UiManager.m_HeadUiPanel.gameObject:SetActive(not bActive);
end

function Wedding:FormatTourNpcTalk(szTalk)
	local tbTourPlayer = Wedding:GetTourPlayer() or {}
	local tbBoyInfo = tbTourPlayer[Gift.Sex.Boy] or {}
	local szBoyName = tbBoyInfo.szName or ""
	local tbGirlInfo = tbTourPlayer[Gift.Sex.Girl] or {}
	local szGirlName = tbGirlInfo.szName or ""
	return string.format(szTalk or "", szBoyName or "", szGirlName or "")
end

function Wedding:OnSynMapNpcPos(tbPosInfo)
	self.tbTourPosInfo = tbPosInfo
end

function Wedding:GetMapNpcPos()
	if not next(self.tbTourPosInfo or {}) then
		return
	end
	return self.tbTourPosInfo[1], self.tbTourPosInfo[2], self.tbTourPosInfo[3]
end

function Wedding:OnJoinWeddingReplay()
	self:CloseAllWeddingWnd()
end

function Wedding:OnForceShowNpc(tbNpcId)
	for _, nNpcId in ipairs(tbNpcId) do
		RepresentMgr.AddShowRepNpc(nNpcId);
	end
end

-- 开始双飞
function Wedding:StartDoubleFly()
	Ui.Effect.ShowAllRepresentObj(0)
	Wedding:HideAllName(true)
	self.nDoubleFlyBeforeUiState = Ui.nChangeUiState
	UiNotify.OnNotify(UiNotify.emNOTIFY_DOUBLE_FLY_BTN_CHANGE, false)
	Ui:ChangeUiState(Ui.STATE_ViewPhoto);
	Operation:DisableClickMap()
	CameraAnimation:PlaySceneCameraAnimation(Wedding.szDoubleFlyCameraAnimationObjectName, "lian_twofly_cam1", 1)
	Ui:PlayEffect(9219, 0, 0, 0, 0, 0);
end

function Wedding:OnSceneCameraAnimationFinish(szObjectName)
	if szObjectName == Wedding.szDoubleFlyCameraAnimationObjectName then
		self:OnFinishDoubleFlySceneCameraState()
	end
end

function Wedding:OnFinishDoubleFlySceneCameraState()
	Ui.Effect.ShowAllRepresentObj(1)
	Wedding:HideAllName(false)
	if not Operation:CheckAdjustView() then
        Operation:EnableClickMap()
        Ui:ChangeUiState(Ui.STATE_DEFAULT, true);
    end
	self:OnDoubleFlyTrapOut()
end

-- 自己请求双飞回调
function Wedding:OnRequestDoubleFly()
	UiNotify.OnNotify(UiNotify.emNOTIFY_DOUBLE_FLY_COUNTDOWN)
end

-- 被请求双飞回调
function Wedding:OnBeRequestDoubleFly()
	UiNotify.OnNotify(UiNotify.emNOTIFY_DOUBLE_FLY_COUNTDOWN)
end

-- 进入双飞trap
function Wedding:OnDoubleFlyTrapIn()
	me.bInDoubleFlyTrap = true
	UiNotify.OnNotify(UiNotify.emNOTIFY_DOUBLE_FLY_BTN_CHANGE, true)
	self:PreLoadDoubleFlyAnim()
end

-- 退出双飞trap
function Wedding:OnDoubleFlyTrapOut()
	me.bInDoubleFlyTrap = false
	UiNotify.OnNotify(UiNotify.emNOTIFY_DOUBLE_FLY_BTN_CHANGE, false)
end

-- 进入trap点加载双飞动画
function Wedding:PreLoadDoubleFlyAnim()
	local nLoverId = Wedding:GetLover(me.dwID)
	if nLoverId then
		PreloadResource:AddPreloadRes(15, "Effect/Prefabs/ChangJing/shuangrenqinggong.prefab")
	end
end