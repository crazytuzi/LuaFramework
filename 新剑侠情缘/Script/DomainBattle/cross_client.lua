Require("CommonScript/DomainBattle/define.lua");
Require("CommonScript/DomainBattle/cross_common.lua");

DomainBattle.tbCross = DomainBattle.tbCross or {};
local tbCross = DomainBattle.tbCross
local tbCrossDef = DomainBattle.tbCrossDef
local tbDefine = DomainBattle.define

function tbCross:GetCrossOpenTime()
	return self.nOpenTime or 0
end

function tbCross:SyncOpenTime(nOpenTime)
	self.nOpenTime = nOpenTime
end

function tbCross:SyncAidSignUpState(bAidSignUp)
	self.bAidSignUp = bAidSignUp
end

function tbCross:SyncAidBriefInfo(nVersion, tbAidBriefList, nAidKinId)
	self.nAidBriefVersion = nVersion
	self.tbAidBriefList = tbAidBriefList
	self.nAidKinId = nAidKinId
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_AID_BRIEF, nAidKinId, tbAidBriefList)
end

function tbCross:GetAidBriefInfo()
	RemoteServer.CrossDomainSyncAidBriefReq(self.nAidBriefVersion)

	return self.nAidKinId, self.tbAidBriefList
end

function tbCross:GetAidList()
	RemoteServer.CrossDomainSyncAidListReq(self.nAidListVersion)

	return self.tbAidList
end

function tbCross:SyncAidList(nVersion, tbAidList)
	self.nAidListVersion = nVersion
	self.tbAidList = tbAidList
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_AID_LIST, tbAidList)
end

function tbCross:UseSupplysRequest(nItemId)
	if not self.bCanUse then
		return
	end

	RemoteServer.CrossDomainUseSupplysReq(nItemId)
end

function tbCross:SyncSupplyRequest()
	RemoteServer.CrossDomainSyncSupplyReq(self.nSupplyVersion)
end

function tbCross:SyncKingTransferCountInfo(nCount)
	self.nKingTranferCount = nCount
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_KING_TRANSFER_COUNT, nCount)
end

function tbCross:GetKingTransferCountInfo()
	RemoteServer.CrossDomainKingTransferCountReq(self.nKingTranferCount)
	return self.nKingTranferCount or 0
end

function tbCross:SyncKingTransferRightInfo(tbKingTransferList)
	self.tbKingTransferList = tbKingTransferList
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_KING_TRANSFER_RIGHT, tbKingTransferList)
end

function tbCross:GetKingTransferRightInfo()
	RemoteServer.CrossDomainKingTransferRightReq()
	return self.tbKingTransferList or {}
end

function tbCross:SyncOuterOccupyInfo(nVersion, tbOuterOccupyList)
	self.nOuterOccupyVersion = nVersion
	self.tbOuterOccupyList = tbOuterOccupyList
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_OUTER_OCCUPY_INFO, tbOuterOccupyList)
end

function tbCross:GetOuterOccupyInfo()
	RemoteServer.CrossDomainOuterOccupyReq(self.nOuterOccupyVersion)
	return self.tbOuterOccupyList or {}
end

function tbCross:SyncKingOccupyInfo(nVersion, tbKingOccupyList)
	self.nKingOccupyVersion = nVersion
	self.tbKingOccupyList = tbKingOccupyList
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_KING_OCCUPY_INFO, tbKingOccupyList)
end

function tbCross:GetKingOccupyInfo()
	RemoteServer.CrossDomainKingOccupyReq(self.nKingOccupyVersion)
	return self.tbKingOccupyList or {}
end

function tbCross:SyncTopKinInfo(tbTopKinSyncInfo, nTopKinSyncVersion)
	self.tbTopKinSyncInfo = tbTopKinSyncInfo
	self.nTopKinSyncVersion = nTopKinSyncVersion
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_TOP_KIN_INFO, tbTopKinSyncInfo)
end

function tbCross:GetTopKinInfo()
	RemoteServer.CrossDomainTopKinReq(self.nTopKinSyncVersion)
	return self.tbTopKinSyncInfo or {}
end

function tbCross:SyncTopPlayerInfo(tbTopPlayerSyncInfo, nTopPlayerSyncVersion)
	self.tbTopPlayerSyncInfo = tbTopPlayerSyncInfo
	self.nTopPlayerSyncVersion = nTopPlayerSyncVersion
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_TOP_PLAYER_INFO, tbTopPlayerSyncInfo)
end

function tbCross:GetTopPlayerInfo()
	RemoteServer.CrossDomainTopPlayerReq(self.nTopPlayerSyncVersion)
	return self.tbTopPlayerSyncInfo or {}
end

function tbCross:SyncSelfInfo(bSelfAid, tbSelfInfo, tbSelfKinInfo)
	self.bSelfAid = bSelfAid
	self.tbSelfInfo = tbSelfInfo
	self.tbSelfKinInfo = tbSelfKinInfo
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_SELF_INFO, tbSelfInfo, tbSelfKinInfo)
end

function tbCross:GetSelfInfo()
	return self.bSelfAid, self.tbSelfInfo, self.tbSelfKinInfo
end

function tbCross:OnSyncKingCampInfo(nKingCampIndex, bCanChangeCamp)
	self.nKingCampIndex = nKingCampIndex
	self.bCanChangeCamp = bCanChangeCamp
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_CAMP_INFO, self.nKingCampIndex, self.bCanChangeCamp)
end

function tbCross:GetKingCampInfo()
	return self.nKingCampIndex or 1, self.bCanChangeCamp
end

function tbCross:GetStateLeftTime()
	if not self.nStatEndTime then
		return 0
	end
	return math.max(self.nStatEndTime - GetTime(), 0)
end

function tbCross:GetTotalLeftTime()
	if not self.nEndTime then
		return 0
	end

	return math.max(self.nEndTime - GetTime(), 0)
end

function tbCross:GetSelfKinName()
	return self.szKinName or ""
end

function tbCross:OnSyncStateChange(nState, nStatEndTime)
	self.nState = nState
	self.nStatEndTime = nStatEndTime
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_STATE, nState, nStatEndTime)
end

function tbCross:OnSyncSupplyInfo(bCanUse, tbSupply, nVersion)
	self.bCanUse = bCanUse
	self.tbSupply = tbSupply
	self.nSupplyVersion = nVersion
	UiNotify.OnNotify(UiNotify.emNOTIFY_ONSYNC_DOMAIN_SUPPLY)
end

function tbCross:GetCanUseBattleSupplys()
	if not self.tbSupply then
		self:SyncSupplyRequest()
	end

	if not self.bCanUse then
		return
	end

	self:SyncSupplyRequest(self.nSupplyVersion)

	return self.tbSupply
end

function tbCross:MiniMapInfoReq()
	RemoteServer.CrossDomainMiniMapInfoReq(self.nMiniMapVersion)
end

function tbCross:OnSynMiniMapInfo(nMiniMapVersion, tbMiniMapInfo)
	self.nMiniMapVersion = nMiniMapVersion
	self.tbMiniMapInfo = tbMiniMapInfo

	local tbMapTextPosInfo = Map:GetMapTextPosInfo(me.nMapTemplateId)
	for _,tbPosInfo in ipairs(tbMapTextPosInfo) do
		local szNewName = tbMiniMapInfo[tbPosInfo.Index]
		if szNewName then
			tbPosInfo.Text = szNewName ;
		end
	end
end

function tbCross:SyncCityMiniMapStatue(bCityStatue)
	local tbMapTextPosInfo = Map:GetMapTextPosInfo(15)
	for _,tbPosInfo in ipairs(tbMapTextPosInfo) do
		if tbPosInfo.Index == "LT_chengzhu" then
			tbPosInfo.Text = bCityStatue and "临安城主" or "";
		end
	end
end

function tbCross:OnEnterMap(nState, nStatEndTime, nEndTime, tbBloodSyncNpcList, nKinId, szKinName)
	self.nState = nState
	self.nStatEndTime = nStatEndTime
	self.nEndTime = nEndTime
	self.nKinId = nKinId
	self.szKinName = szKinName

	self.nMiniMapVersion = nil
	self.tbMiniMapInfo = nil

	Ui:OpenWindow("BloodPanel", tbBloodSyncNpcList)
	Ui:OpenWindow("DomainBattleHomeInfo", nState, self:GetStateLeftTime(), true)
	Ui:OpenWindow("CrossDomainBattleInfo")
	local nMapTemplateId = me.nMapTemplateId;
	local nUiState, bHide = Map:GetMapUiState(nMapTemplateId); --因为 重连时没 切地图客户端也调用了  map:onLeave
	Ui:ChangeUiState(nUiState, bHide);

	DomainBattle:OnMapLoaded()

	if not self.bRegMapEvent then
		UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_ENTER, self.OnEnterNewMap, self)  --进新的非战场图， 正常离开或重连超时时
		UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self.OnLeaveCurMap, self)  --离开战场图  返回登录时
		UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LOADED, DomainBattle.OnMapLoaded, DomainBattle)
		self.bRegMapEvent = true;
	end
end

function tbCross:OnLeaveCurMap(_)
	self:OnCloseBattleMap();
end

function tbCross:OnEnterNewMap(nMapTemplateId)
	

	if not self:IsDomainMap(nMapTemplateId)  then
		self:OnCloseBattleMap();
	end
end

function tbCross:OnCloseBattleMap()
	Ui:ChangeUiState(0, true)
	Ui:CloseWindow("DomainBattleHomeInfo")
	Ui:CloseWindow("CrossDomainBattleInfo")
	if self.bRegMapEvent then
		UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_ENTER, self)
		UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self)
		UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_LOADED, DomainBattle)
		self.bRegMapEvent = nil;
	end
end

function tbCross:ClearData()
	self.nOpenTime = nil
	self.bAidSignUp = false
	self.nState = nil
	self.nStatEndTime = nil
	self.nEndTime = nil
	self.nKinId = nil
	self.szKinName = nil
	self.bCanUse = nil
	self.tbSupply = nil
	self.nSupplyVersion = nil

	self.nAidBriefVersion = nil
	self.tbAidBriefList = nil
	self.nAidKinId = nil

	self.nAidListVersion = nil
	self.tbAidList = nil

	self.nKingTranferCount = nil
	self.tbKingTransferList = nil
	self.nOuterOccupyVersion = nil
	self.tbOuterOccupyList = nil
	self.nKingOccupyVersion = nil
	self.tbKingOccupyList = nil

	self.nMiniMapVersion = nil
	self.tbMiniMapInfo = nil

	self.tbTopPlayerSyncInfo = nil
	self.nTopPlayerSyncVersion = nil

	self.tbTopKinSyncInfo = nil
	self.nTopKinSyncVersion = nil

	self.bSelfAid = nil
	self.tbSelfInfo = nil
	self.tbSelfKinInfo = nil

	self.nKingCampIndex = nil
	self.bCanChangeCamp = nil
end