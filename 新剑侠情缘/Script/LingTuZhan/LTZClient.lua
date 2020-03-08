
local tbDefine = LingTuZhan.define;


function LingTuZhan:GetSynCommonData(  )
	if GetTimeFrameState(tbDefine.szOpenTimeFrame) == 1 then
		if not self.nSynRequestTimeCommon or GetTime() - self.nSynRequestTimeCommon > tbDefine.nRequestIntervalComon then
			self.nSynRequestTimeCommon = GetTime();
			RemoteServer.DoRequesLTZ_S("RequestCommonData")	
		end
		if self.tbSynCommonData then
			return self.tbSynCommonData
		end
	end

	--默认值，界面显示
	return {
		nOpenSeason = 0;
		nOpenRound  = 0;
	};
end

--所有地图的占领信息
function LingTuZhan:GetSynAllMapOwnerInfo(  )
	if not self.nSynRequestTimeALlMapOwn or GetTime() - self.nSynRequestTimeALlMapOwn > tbDefine.nRequestIntervalAllMapOwn then
		self.nSynRequestTimeALlMapOwn = GetTime()
		RemoteServer.DoRequesLTZ_S("RequestALlMapOwnData")	
	end
	if self.tbSynAllMapOwn then
		return self.tbSynAllMapOwn
	end
	return {};
end

--单个的地图信息, 城墙，龙珠，宣战等信息
function LingTuZhan:GetSynMapInfo( nMapTemplateId )
	local nSynRequestTime = self.tbSynRequestTimeMapInfo[nMapTemplateId]
	if not nSynRequestTime or GetTime() - nSynRequestTime > tbDefine.nRequestIntervalMapInfo then
		self.tbSynRequestTimeMapInfo[nMapTemplateId] = GetTime()
		RemoteServer.DoRequesLTZ_S("RequestMapInfo", nMapTemplateId)
	end
	local tbSynMapInfo = self.tbSynMapInfo[nMapTemplateId]
	if tbSynMapInfo then
		return tbSynMapInfo
	end
	return {};
end

function LingTuZhan:GetSynMyKinInfo()
	if me.dwKinId == 0 then
		return {}
	end
	if not self.nSynRequestTimeMyKinInfo or GetTime() - self.nSynRequestTimeMyKinInfo > tbDefine.nRequestIntervalKinfo then
		self.nSynRequestTimeMyKinInfo = GetTime()
		RemoteServer.DoRequesLTZ_S("RequestMyKinfo")
	end
	if self.tbSynMyKinInfo then
		return self.tbSynMyKinInfo
	end
	return {}
end

function LingTuZhan:GetMyRecoverMapIds(  )
	local tbSynMyKinInfo = self:GetSynMyKinInfo()
	if not tbSynMyKinInfo.nMasterMapId then
		return {}
	end
	local tbOwnMapIds = LingTuZhan:GetMyOwnMapIds()
	return LingTuZhan:GetRevoverMapList(tbSynMyKinInfo.nMasterMapId, tbOwnMapIds )
end

--客户端兼容com接口用的
function LingTuZhan:GetSynKinInfo( szKinKey )
	return self:GetSynMyKinInfo()
end

function LingTuZhan:GetMyOwnMapIds(  )
	--根据allmapOwn 计算出自己家族的地图 key-value
	local szMyKin = LingTuZhan:GetMyKinKey()
	return LingTuZhan:GetKinOwnMapIds( szMyKin )
end

function LingTuZhan:OnSynMyKinInfo( tbSynMyKinInfo)
	self.nSynRequestTimeMyKinInfo = GetTime()
	self.tbSynMyKinInfo = tbSynMyKinInfo
	UiNotify.OnNotify(UiNotify.emNOTIFY_LTZ_SYN_DATA, "MyKinInfo")
end

function LingTuZhan:OnSynCommonData( tbSynCommonData)
	self.nSynRequestTimeCommon = GetTime();	
	self.tbSynCommonData = tbSynCommonData;
	UiNotify.OnNotify(UiNotify.emNOTIFY_LTZ_SYN_DATA ,"Common")
	if not self.nRegisterLginEvent then
		self.nRegisterLginEvent = PlayerEvent:RegisterGlobal("OnLogin",LingTuZhan.OnLogin, LingTuZhan);
	end
end

function LingTuZhan:OnSynAllMapOwnData( tbSynAllMapOwn)
	self.tbSynAllMapOwn = tbSynAllMapOwn
	self.tbKinOwnMapIds = nil; --这个是反算的，数据源更新后重算
	self.nSynRequestTimeALlMapOwn = GetTime()
	UiNotify.OnNotify(UiNotify.emNOTIFY_LTZ_SYN_DATA,"AllMapOwn")
end

function LingTuZhan:OnSynMapInfo( nMapTemplateId, tbData )
	self.tbSynMapInfo[nMapTemplateId] = tbData
	self.tbSynRequestTimeMapInfo[nMapTemplateId] = GetTime()
	UiNotify.OnNotify(UiNotify.emNOTIFY_LTZ_SYN_DATA, "SynMapInfo")
end

function LingTuZhan:OnLogin(  )
	--cd 较长的这里清掉
	self.nSynRequestTimeCommon = nil;
	self.nSynRequestTimeALlMapOwn = nil;
end

function LingTuZhan:RequestControlStable( nMapTemplateId )
    local szMyKin = LingTuZhan:GetMyKinKey()
    local bRet,szMsg,nCostFound = self:IsCanControlStable(me, szMyKin, nMapTemplateId )
    if not bRet then
    	me.CenterMsg(szMsg)
    	return
    end
    local fnYes = function ( )
    	RemoteServer.DoRequesLTZ("RequestControlStable",nMapTemplateId)	
    end
    me.MsgBox(string.format("是否消耗[FFFE0D]%d领土资金[-]提高[FFFE0D]%d[-]点稳定度？",nCostFound, tbDefine.nControlAddStable),{
		{"确认",fnYes},
		{"取消"},
	})
	
end

function LingTuZhan:RequestSetKinMasterMap( nMapTemplateId )
	if me.dwKinId == 0 then
 		return
 	end
    local szMyKin = LingTuZhan:GetMyKinKey()
    local bRet,szMsg = LingTuZhan:IsCanSetMasterMap(me, szMyKin, nMapTemplateId )
    if not bRet then
    	me.CenterMsg(szMsg, true)
    	return
    end
    local fnYes = function ( )
    	RemoteServer.DoRequesLTZ("RequestSetKinMasterMap",nMapTemplateId)	
    end
	me.MsgBox("每次领土战后可设置一次主城\n设置后[FFFE0D]无法更改[-]\n是否确定？",{
		{"确认",fnYes},
		{"取消"},
	})

end

function LingTuZhan:RequestDeclaerMap( nMapTemplateId )
 	if me.dwKinId == 0 then
 		me.CenterMsg("您没有家族")
 		return
 	end

    local szMyKin = LingTuZhan:GetMyKinKey()
    local bRet,szMsg = LingTuZhan:IsMapCanDeclareWar(me, nMapTemplateId ,szKinKey)
    if not bRet then
    	me.CenterMsg(szMsg, true)
    	return
    end
    local tbSynMyKinInfo = LingTuZhan:GetSynMyKinInfo()
    local fnYes = function ()
    	RemoteServer.DoRequesLTZ("RequestDeclaerMap",nMapTemplateId)	
    end
    local szMsg;
    if tbSynMyKinInfo.nManulDeclareMapId then
    	szMsg = string.format("确定要将宣战地图由[FFFE0D]%s[-]改为[FFFE0D]%s[-]吗？\n（活动开始前，可随时更改宣战地图）",  Map:GetMapName(tbSynMyKinInfo.nManulDeclareMapId), Map:GetMapName(nMapTemplateId))
    else
    	szMsg =	string.format("确定要对[FFFE0D]%s[-]进行宣战吗？\n（活动开始前，可随时更改宣战地图）", Map:GetMapName(nMapTemplateId))
    end
	me.MsgBox(szMsg,{
			{"确认",fnYes},
			{"取消"},
		})
end

function LingTuZhan:GetCacheKinMsg(  )
	if not self:IsOpenSeason() then
		return
	end
	if not self.nSynRequestTimeKinMsg or GetTime() - self.nSynRequestTimeKinMsg > tbDefine.nRequestIntervalKinMsg then
		self.nSynRequestTimeKinMsg = GetTime();
		RemoteServer.DoRequesLTZ_S("RequestGetCacheKinMsg", self.nDataVersionKinMsg)	
	else
		if not self.tbSynCacheKinMsg then
			me.CenterMsg("当前没有战报信息")
		end
	end
	if self.tbSynCacheKinMsg then
		return self.tbSynCacheKinMsg
	end
end

function LingTuZhan:RequestOpenCacheKinMsgUI(  )
	local tbMsg = self:GetCacheKinMsg()
	if not tbMsg then
		return
	end
	local szMsg = table.concat( tbMsg, "\n")
	Ui:OpenWindow("AnniversaryTipPanel", {szText = szMsg})
end

function LingTuZhan:OnSynCacheKinMsg( tbSynCacheKinMsg, nDataVersion )
	self.tbSynCacheKinMsg = tbSynCacheKinMsg
	self.nSynRequestTimeKinMsg = GetTime()
	self.nDataVersionKinMsg = nDataVersion
	UiNotify.OnNotify(UiNotify.emNOTIFY_LTZ_SYN_DATA, "CacheKinMsg")
end


function LingTuZhan:OnSynGameTime( nTime )
	self:SetClientLeftTime(nTime)
end

function LingTuZhan:OnStartFight( nSchedulePos )
	me.CenterMsg("战斗开始了！", true)
	Ui:OpenWindow("LTZHomeBattleInfo",  nSchedulePos )
end

function LingTuZhan:SighGameFightMap( nMapTemplateId )
	local bRet, szMsg = self:IsCanEnterBattle(me)
	if not bRet then
		me.CenterMsg(szMsg, true)
		return
	end
	local szKinKey = LingTuZhan:GetMyKinKey(  )
	local bRet, szMsg = LingTuZhan:IsCanPlayerEnterFromMap( me, nMapTemplateId ,szKinKey)
	if not bRet then
		me.CenterMsg(szMsg, true)
		return
	end
	Ui:CloseWindow("TerritorialWarTips")
	RemoteServer.DoRequesLTZ("RequestSighGameFight", nMapTemplateId)  
end

function LingTuZhan:PlayerSighGameFight(  )
    local bRet, szMsg = LingTuZhan:IsCanEnterBattle(me)
    if not bRet then
        me.CenterMsg(szMsg, true)
        return
    end
    local szKinKey = LingTuZhan:GetMyKinKey()
    local tbSynMyKinInfo = LingTuZhan:GetSynKinInfo( szKinKey )
    if tbSynMyKinInfo.nManulDeclareMapId then
        LingTuZhan:SighGameFightMap( tbSynMyKinInfo.nManulDeclareMapId )
    else
        local tbOwnMapIds = LingTuZhan:GetKinOwnMapIds( szKinKey )
        local tbMapsList = {};
       	for k,v in pairs(tbOwnMapIds) do
       		table.insert(tbMapsList, k)
       	end
       	if #tbMapsList == 1 then
       		LingTuZhan:SighGameFightMap(tbMapsList[1])
       	elseif #tbMapsList > 1 then
       		local fnSelCallBack = function (index)
		        LingTuZhan:SighGameFightMap(tbMapsList[index])
		    end
		    local tbMapNames = {};
		    for i,v in ipairs(tbMapsList) do
		    	table.insert(tbMapNames, Map:GetMapName(v))
		    end
		    Ui:OpenWindowAtPos("SelectScrollView", 263, 32, tbMapNames, fnSelCallBack)
       	else
       		me.CenterMsg("您的家族没有领土，需要先对某一领土进行宣战才可进入")
       	end
    end
end

function LingTuZhan:ClearCacheData(  )
	self.nSynRequestTimeCommon = nil;
	self.nSynRequestTimeALlMapOwn = nil	
	self.nSynRequestTimeMyKinInfo = nil;
	self.nSynRequestTimeKinMsg = nil
	self.tbSynRequestTimeMapInfo = {};
end

function LingTuZhan:ClearData()
	self.tbSynRequestTimeMapInfo = {};
	self.tbSynMapInfo = {};
	if self.nSynRequestTimeCommon then
		self.tbSynCommonData = nil;
		self.nSynRequestTimeCommon = nil;

		self.tbSynAllMapOwn = nil
		self.nSynRequestTimeALlMapOwn = nil	

		self.tbSynMyKinInfo = nil;
		self.nSynRequestTimeMyKinInfo = nil;

		self.tbKinOwnMapIds = nil;

		self.nSynRequestTimeKinMsg = nil;
		self.tbSynCacheKinMsg = nil;
		self.nDataVersionKinMsg = nil
	end
end

function LingTuZhan:ClearFightData(  )
	if self.nClientLeftTime then
		self.nClientLeftTime = nil;
		self.tbKinBattleFightData = nil
		self.nSynRequestTimeFightData = nil;

		self.tbSynMapKinPower = nil;
		self.tbAllKinName = nil;
		self.nSynRequestTimeMapKinPower = nil;

		self.tbSynMyFihtRoleInfo = nil
		self.nSynRequestTimeMyRoleInfo = nil

		self.tbSynKinAllRoleRank = nil
		self.nDataVersionAllRoleRank = nil
		self.nSynRequestTimeAllRoleRank = nil;		
	end
end


function LingTuZhan:SetClientLeftTime(nSetTime, nAddTime)
	if nSetTime == 0 then --只用定时设到0 的，不然同时同步和定时设可能时序上有问题
		return
	end
	if nSetTime then
		self.nClientLeftTime = nSetTime
	end
	if nAddTime then
		self.nClientLeftTime = self.nClientLeftTime + nAddTime
	end
end

function LingTuZhan:GetClientLeftTime()
	return self.nClientLeftTime
end

--获取物资使用，是否搭建了前线营地等信息
function LingTuZhan:GetSynKinBattleFightData(  )
	if not self.nSynRequestTimeFightData or GetTime() - self.nSynRequestTimeFightData > tbDefine.nRequestIntervalFightData then
		self.nSynRequestTimeFightData = GetTime();
		RemoteServer.DoRequesLTZ_S("RequestKinBattleFightData")	
	end

	if self.tbKinBattleFightData then
		return self.tbKinBattleFightData
	end
	return {}, true;	
end

function LingTuZhan:OnSynKinBattleFightData( tbKinFightData )
	self.tbKinBattleFightData = tbKinFightData
	self.nSynRequestTimeFightData = GetTime()
	UiNotify.OnNotify(UiNotify.emNOTIFY_LTZ_SYN_DATA, "FightData")
end

--快速前往营地
function LingTuZhan:QuckGotoCamp()
	local bRet, szMsg = LingTuZhan:IsCanEnterBattle(me)
    if not bRet then
        me.CenterMsg(szMsg, true)
        return
    end
    local tbKinFightData, bNoData = self:GetSynKinBattleFightData()
    if not tbKinFightData.tbQuickCampInfo then
    	if not bNoData then
    		me.CenterMsg("当前场上没有前线旗帜，无法传送")
    	end
    	return
    end
    RemoteServer.DoRequesLTZ("RequestQuickGotoCamp")
end


--使用，不是建造
function LingTuZhan:UseSupplyItem( nItemId )
	local szKinKey = self:GetMyKinKey()
	local bRet, szMsg, nCount = self:CanUseSupplyItem(me, nItemId, szKinKey)
	if not bRet then
		me.CenterMsg(szMsg, true)
		return
	end
	local fnYes = function ( )
		RemoteServer.DoRequesLTZ_S("RequestUseSuppplyItem", nItemId)
	end
	local szMsg = tbDefine.tbBattleApplyUseConfirmMsg[nItemId]
	if not szMsg then
		fnYes()
	else
		me.MsgBox(string.format(szMsg, nCount),{
			{"确认",fnYes},
			{"取消"},
		})
	end
	
end

function LingTuZhan:BuildSupplyItem( nItemId )
	local szKinKey = self:GetMyKinKey()
	local bRet, szMsg = self:CanBuildSupplyItem(me, nItemId, szKinKey)
	if not bRet then
		me.CenterMsg(szMsg, true)
		return
	end
	RemoteServer.DoRequesLTZ_S("RequestBuildSuppplyItem", nItemId)
end

function LingTuZhan:RequestLevelUpWall( nMapTemplateId )
	local szKinKey = LingTuZhan:GetMyKinKey()
	local bRet, szMsg, nCostFound = self:CanLevelUpWall(me, szKinKey, nMapTemplateId)
	if not bRet then
		me.CenterMsg(szMsg)
		return
	end
	local fnYes = function (  )
		RemoteServer.DoRequesLTZ("RequestLevelUpWall", nMapTemplateId)
	end
	me.MsgBox(string.format("您确认要花费[FFFE0D]%d[-]领土资金升级城门吗？", nCostFound),{
			{"确认",fnYes},
			{"取消"},
		})
	
end

function LingTuZhan:RequestLevelUpDragonFlag( nMapTemplateId )
	local bRet, szMsg, nCostFound = self:CanLevelUpDragonFlag(me, nMapTemplateId)
	if not bRet then
		me.CenterMsg(szMsg)
		return
	end
	local fnYes = function ( )
		RemoteServer.DoRequesLTZ("RequestLevelUpDragonFlag", nMapTemplateId)	
	end
	me.MsgBox(string.format("您确认要花费[FFFE0D]%d[-]领土资金升级龙柱吗？", nCostFound),{
			{"确认",fnYes},
			{"取消"},
		})
	
end

function LingTuZhan:GetMapKinPower(  )
	--战斗期间
	if not tbDefine.tbMapSeting[me.nMapTemplateId] then
		me.CenterMsg("当前不可获取战报")
		return {}
	end
	if not self.nSynRequestTimeMapKinPower or GetTime() - self.nSynRequestTimeMapKinPower > tbDefine.nRequestIntervalMapKinPower then
		self.nSynRequestTimeMapKinPower = GetTime();
		RemoteServer.DoRequesLTZ("RequestGetMapKinPower")	
	end
	if self.tbSynMapKinPower then
		return self.tbSynMapKinPower, self.tbAllKinName
	end
	return {}
end

function LingTuZhan:OnSyncMapKinPower( tbSynMapKinPower, tbAllKinName )
	self.tbSynMapKinPower = tbSynMapKinPower;
	self.nSynRequestTimeMapKinPower = GetTime()
	self.tbAllKinName = tbAllKinName;
	UiNotify.OnNotify(UiNotify.emNOTIFY_LTZ_SYN_DATA, "MapKinPower")
end

function LingTuZhan:GetMyFightRoleInfo(  )
	if not tbDefine.tbMapSeting[me.nMapTemplateId] then
		me.CenterMsg("当前不可获取战报")
		return {}
	end
	if not self.nSynRequestTimeMyRoleInfo or GetTime() - self.nSynRequestTimeMyRoleInfo > tbDefine.nRequestIntervalMyRoleInfo then
		self.nSynRequestTimeMyRoleInfo = GetTime();
		RemoteServer.DoRequesLTZ("RequestGetMyFightRoleInfo")	
	end
	if self.tbSynMyFihtRoleInfo then
		return self.tbSynMyFihtRoleInfo
	end
	return {}
end

function LingTuZhan:OnSyncMyFightRoleInfo(tbSynMyFihtRoleInfo )
	self.tbSynMyFihtRoleInfo = tbSynMyFihtRoleInfo
	self.nSynRequestTimeMyRoleInfo = GetTime()
	UiNotify.OnNotify(UiNotify.emNOTIFY_LTZ_SYN_DATA, "MyRoleInfo")
end

function LingTuZhan:GetKinAllRoleRank(  )
	if not tbDefine.tbMapSeting[me.nMapTemplateId] then
		me.CenterMsg("当前不可获取战报")
		return {}
	end
	if not self.nSynRequestTimeAllRoleRank or GetTime() - self.nSynRequestTimeAllRoleRank > tbDefine.nRequestIntervalAllRoleRank then
		self.nSynRequestTimeAllRoleRank = GetTime();
		RemoteServer.DoRequesLTZ("RequestGetKinAllRoleRank", self.nDataVersionAllRoleRank)	
	end
	if self.tbSynKinAllRoleRank then
		return self.tbSynKinAllRoleRank
	end
	return {}
end

function LingTuZhan:OnSyncKinAllRoleRank( tbSynKinAllRoleRank , nDataVersionAllRoleRank)
	self.tbSynKinAllRoleRank = tbSynKinAllRoleRank
	self.nDataVersionAllRoleRank = nDataVersionAllRoleRank
	UiNotify.OnNotify(UiNotify.emNOTIFY_LTZ_SYN_DATA, "KinAllRoleRank")
end

function LingTuZhan:EnterFightMap( nSchedulePos, nClientLeftTime, szKinKey)
	self.szKinKey = szKinKey
	Ui:OpenWindow("LTZHomeBattleInfo",  nSchedulePos, nClientLeftTime)
	Ui:CloseWindow("TerritorialWarMapPanel")
	if not self.bRegistNotofy then
		UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_ENTER, self.OnEnterNewMap, self)  --进新的非战场图， 正常离开或重连超时时
		UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self.OnLeaveCurMap, self)  --离开战场图  返回登录时
		self.bRegistNotofy = true;
	end
end

function LingTuZhan:OnLeaveCurMap(nMapTemplateId)
	self:OnCloseBattleMap();
end

function LingTuZhan:OnEnterNewMap(nMapTemplateId)
	if not tbDefine.tbMapSeting[nMapTemplateId] then
		self:OnCloseBattleMap();
	end
end

function LingTuZhan:OnCloseBattleMap()
	Ui:CloseWindow("LTZHomeBattleInfo")
	if self.bRegistNotofy then
		UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_ENTER, self)
		UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self)
		self.bRegistNotofy = nil;
	end
	self.szKinKey = nil;
	self:ClearFightData();
end

function LingTuZhan:GetMyKinKey(  )
	--因为在跨服时客户端的家族id不是本服的，所以这里缓存了一份
	if self.szKinKey then
		return self.szKinKey
	end
	return LingTuZhan:GetCombineKinKey(Sdk:GetTrueServerId(), me.dwKinId)
end

function LingTuZhan:ShowComboKillCount(nComboCount)

	if Ui:WindowVisible("LTZHomeBattleInfo") == 1 then
		local tbWndUi = Ui("LTZHomeBattleInfo");
		tbWndUi:PlayComboAni(nComboCount);
	end
end

if not LingTuZhan.tbSynRequestTimeMapInfo then
	LingTuZhan:ClearData(  )
end

