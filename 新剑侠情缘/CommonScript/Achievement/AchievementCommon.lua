Achievement.MAINDATA_GROUD_ID      = 29;
Achievement.TB_COUNT_DATA_ID       = { 30, 52 };
Achievement.TB_COUNT_DATA_ID_APP10 = { 70, 71 };

Achievement.KIND_MAXLEVEL          = 5;  --一个大的成就最多有5个等级

Achievement.GAIN_AWARD_GROUP       = 174;
Achievement.DATA_GROUP             = 175;
Achievement.VERSION                = 1;

Achievement.LIKE_GROUP             = 182;
Achievement.LIKE_MAXCOUNT          = 8;
Achievement.LIKE_ASYNC_BEGIN       = 63;

Achievement.tbLegal = { 
    Chat_Private       = true;
    Chat_Voice         = true;
    Angry_Normal       = true;
    Chat_World         = true;
    Chat_Emotion       = true;
    Chat_Color         = true;
    Chat_Kin           = true;
    Chat_School        = true;
};

Achievement.tbSetting = {}
function Achievement:LoadSetting()
    local tbKey = {"Kind", "KeyID", "Hide",
        "NotVersion_tx",
        "NotVersion_vn",
        "NotVersion_hk",
        "NotVersion_xm",
        "NotVersion_en",
        "NotVersion_kor",
        "NotVersion_th",}
    local szKey = "sddddddddd"
    if MODULE_GAMECLIENT then
        self.tbUiSetting  = {}
        self.tbHideList   = {}
        self.tbFirstTitle = {}
        table.insert(tbKey, "SubTitle")
        table.insert(tbKey, "BigTitle")
        szKey = szKey .. "ss"
    end
    local tbFile      = LoadTabFile("Setting/Achievement/Achievement_New.tab", szKey, nil, tbKey)
    local tbMain      = {}
    local tbTitleTmp  = {}
    local nGroupCount = 0
    for _, tbInfo in ipairs(tbFile) do
        local szKind = tbInfo.Kind
        tbMain[szKind] = tbInfo
        if MODULE_GAMECLIENT and not Lib:CheckNotVersion(tbInfo) then
            if tbInfo.Hide > 0 then
                table.insert(self.tbHideList, szKind)
            else
                if not tbTitleTmp[tbInfo.BigTitle] then
                    nGroupCount = nGroupCount + 1
                    tbTitleTmp[tbInfo.BigTitle] = {nGroupIdx = nGroupCount, nCount = 1, tbSubTitle = {[tbInfo.SubTitle] = 1}}
                    table.insert(self.tbFirstTitle, tbInfo.BigTitle)
                end
                if not tbTitleTmp[tbInfo.BigTitle].tbSubTitle[tbInfo.SubTitle] then
                    tbTitleTmp[tbInfo.BigTitle].nCount = tbTitleTmp[tbInfo.BigTitle].nCount + 1
                    tbTitleTmp[tbInfo.BigTitle].tbSubTitle[tbInfo.SubTitle] = tbTitleTmp[tbInfo.BigTitle].nCount
                end
                local nGroupIdx = tbTitleTmp[tbInfo.BigTitle].nGroupIdx
                local nSubIdx   = tbTitleTmp[tbInfo.BigTitle].tbSubTitle[tbInfo.SubTitle]
                self.tbUiSetting[nGroupIdx] = self.tbUiSetting[nGroupIdx] or {}
                if not self.tbUiSetting[nGroupIdx][nSubIdx] then
                    self.tbUiSetting[nGroupIdx][nSubIdx] = {szTitle = tbInfo.SubTitle, tbList = {szKind}}
                else
                    table.insert(self.tbUiSetting[nGroupIdx][nSubIdx].tbList, szKind)
                end
            end
        end
    end

    tbKey = {"szKind", "nCount", "nPoint", "szAward", "nKinMsg", "nWorldMsg", "szName"}
    szKey = "sddsdds"
    if MODULE_GAMECLIENT then
        table.insert(tbKey, "szDesc")
        szKey = szKey .. "s"
    end
    local tbLevelSetting = LoadTabFile("Setting/Achievement/AchievementLevel_New.tab", szKey, nil, tbKey)
    local tbCheckOldData = {}
    for _, tbInfo in ipairs(tbLevelSetting) do
        local szKind = tbInfo.szKind
        assert(tbMain[szKind], "[Achievement] LoadSetting, MainInfo Not Found:" .. szKind)
        if not Lib:CheckNotVersion(tbMain[szKind]) then
            if not self.tbSetting[szKind] then
                self.tbSetting[szKind] = {nKeyId = tbMain[szKind].KeyID, tbLevel = {}}
                if MODULE_GAMECLIENT then
                    self.tbSetting[szKind].bHide      = tbMain[szKind].Hide > 0
                    self.tbSetting[szKind].szSubTitle = tbMain[szKind].SubTitle
                    self.tbSetting[szKind].szBigTitle = tbMain[szKind].BigTitle
                end
            end
            local nCurCount = #self.tbSetting[szKind].tbLevel
            if nCurCount > 0 and self.tbSetting[szKind].tbLevel[nCurCount].nCount >= tbInfo.nCount then
                assert(false, "[Achievement] LoadSetting, Sort Error:" .. szKind)
            end
            table.insert(self.tbSetting[szKind].tbLevel, tbInfo)

            tbCheckOldData[szKind] = tbCheckOldData[szKind] or {}
            tbCheckOldData[szKind][tbInfo.nCount] = nCurCount + 1
        end
    end

    local tbSetting = Lib:LoadTabFile("Setting/Achievement/Achievement.tab", {KeyID = 1})
    local tbMainSaveKey = {}
    for _, tbInfo in pairs(tbSetting) do
        assert(not tbMainSaveKey[tbInfo.Kind], "[Achievement] LoadSetting, MainKind repeat " .. tbInfo.Kind)
        if not Lib:CheckNotVersion(tbInfo) then
            tbMainSaveKey[tbInfo.Kind] = tbInfo.KeyID
        end
    end

    local MAX_BIT = 255
    tbSetting = Lib:LoadTabFile("Setting/Achievement/AchievementLevel.tab", {Level = 1, FinishCount = 1})
    local tbSubKindTmp = {}
    for _, tbInfo in ipairs(tbSetting) do
        local szMainKind = tbInfo.ParentKind
        local szSubKind  = tbInfo.SubKind
        tbSubKindTmp[szMainKind] = tbSubKindTmp[szMainKind] or {tbSubKind = {}, nCount = 0}
        if not tbSubKindTmp[szMainKind].tbSubKind[szSubKind] then
            tbSubKindTmp[szMainKind].tbSubKind[szSubKind] = true
            tbSubKindTmp[szMainKind].nCount = tbSubKindTmp[szMainKind].nCount + 1
        end
        if tbCheckOldData[szSubKind] then
            local nKeyId = tbMainSaveKey[tbInfo.ParentKind]
            if not self.tbSetting[szSubKind].tbOldData then
                local nKeyIdx   = tbSubKindTmp[szMainKind].nCount
                local nValueKey = (nKeyId - 1) * self.KIND_MAXLEVEL + nKeyIdx
                local nGroupIdx = nKeyId > (MAX_BIT/self.KIND_MAXLEVEL) and 2 or 1
                if nKeyIdx > self.KIND_MAXLEVEL then
                    nValueKey = nValueKey - self.KIND_MAXLEVEL
                    nGroupIdx = self.TB_COUNT_DATA_ID_APP10[nGroupIdx]
                else
                    nGroupIdx = self.TB_COUNT_DATA_ID[nGroupIdx]
                end
                if nValueKey > MAX_BIT then
                    nValueKey = nValueKey%MAX_BIT
                end
                self.tbSetting[szSubKind].tbOldData = {
                    nDataGroup = nGroupIdx,
                    nDataKey   = nValueKey
                }
            end
            local nNewLv = tbCheckOldData[szSubKind][tbInfo.FinishCount]
            if nNewLv then
                self.tbSetting[szSubKind].tbLevel[nNewLv].tbGainData = {
                    nGainKey   = nKeyId,
                    nGainLevel = tbInfo.Level,
                }
            end
        end
    end
end
Achievement:LoadSetting()

function Achievement:IsAllFinish(pPlayer, szKind)
    local nCompleted = self:GetCompletedLevel(pPlayer, szKind)
    local nMaxLevel  = self:GetMaxLevel(szKind)
    return nCompleted >= nMaxLevel
end

function Achievement:GetCompletedLevel(pPlayer, szKind)
    if not pPlayer or not szKind then
        return 0
    end

    if not self.tbSetting[szKind] then
        return 0
    end
 
    local nCompleted = 0
    local nCurCount  = self:GetSubKindCount(pPlayer, szKind)
    for nLevel, tbInfo in ipairs(self.tbSetting[szKind].tbLevel) do
        if nCurCount < tbInfo.nCount then
            break
        end
        nCompleted = nLevel
    end
    return nCompleted
end

function Achievement:CheckCanGainAward(pPlayer, szKind, nGainLevel)
    if not pPlayer or not szKind or not nGainLevel then
        return;
    end

    local nGroupID = self:GetGroupKey(szKind)
    if not nGroupID then
        Log("Achievement:SetGainLevel >>>>", szKind, nGainLevel)
        return
    end

    local nGainFlag = pPlayer.GetUserValue(self.GAIN_AWARD_GROUP, nGroupID)
    local nLvFlag   = KLib.GetBit(nGainFlag, nGainLevel)
    return nLvFlag == 0, nLvFlag, nGainFlag
end

function Achievement:GetGainLevel(pPlayer, szKind)
    if not pPlayer or not szKind then
        return;
    end

    local tbInfo = self.tbSetting[szKind];
    if not tbInfo then
        Log("Achievement:GetGainLevel >>>>", szKind)
        return;
    end
    
    local nMaxLevel  = #tbInfo.tbLevel
    local nGainFlag  = pPlayer.GetUserValue(self.GAIN_AWARD_GROUP, tbInfo.nKeyId)
    local nGainLevel = 0
    for i = 1, nMaxLevel do
        local nBit = KLib.GetBit(nGainFlag, i)
        if nBit == 0 then
            break
        end
        nGainLevel = i
    end
    return nGainLevel
end

function Achievement:GetGroupKey(szKind)
    local tbInfo = self.tbSetting[szKind];
    if not tbInfo then
        Log("Achievement:GetGroupKey >>>>", szKind)
        return;
    end

    return tbInfo.nKeyId;
end

function Achievement:GetCountSaveKey(szKind)
    local tbInfo  = self.tbSetting[szKind];
    if not tbInfo then
        Log("Achievement:GetCountSaveKey, not found such subkind >>>>", szKind);
        return;
    end

    return self.DATA_GROUP, tbInfo.nKeyId
end

function Achievement:GetSubKindCount(pPlayer, szKind)
    if not pPlayer or not szKind then
        return;
    end

    local nGroupKey, nValueKey = self:GetCountSaveKey(szKind);
    if not nGroupKey or not nValueKey then
        Log("Achievement:GetSubKindCount, not fount such subkind >>>>", szKind);
        Log(debug.traceback())
        return 0;
    end

    local nCount = pPlayer.GetUserValue(nGroupKey, nValueKey);
    return nCount;
end

function Achievement:GetMaxLevel(szKind)
    if not self.tbSetting[szKind] then
        return 99999
    end
    return #(self.tbSetting[szKind].tbLevel)
end

function Achievement:GetLevelInfo(szKind, nLevel)
    local tbInfo = self.tbSetting[szKind];
    if not tbInfo then
        return;
    end

    return tbInfo.tbLevel[nLevel];
end

function Achievement:GetAwardInfo(szKind, nLevel)
	local tbInfo  = self:GetLevelInfo(szKind, nLevel);
    if not tbInfo then
        return;
    end

    if not tbInfo.tbAward then
        tbInfo.tbAward = Lib:GetAwardFromString(tbInfo.szAward)
        local szTitle = string.match(tbInfo.szAward, "AddTimeTitle|(%d+)")
        if szTitle then
            tbInfo.nAwardTitle = tonumber(szTitle)
        end
	    for _, award in ipairs(tbInfo.tbAward) do
		    if Player.AwardType[award[1]] == Player.award_type_money then
			    award[2] = award[2] * 10
		    end
	    end
    end
	return tbInfo.tbAward, tbInfo.nAwardTitle
end

function Achievement:GetFinishCount(szKind, nLevel)
    local tbInfo = self:GetLevelInfo(szKind, nLevel) or {}
	return tbInfo.nCount or 99999
end

-- 当前成就是否完成到该等级
function Achievement:CheckCompleteLevel(pPlayer, szKind, nLevel)
    if not pPlayer or not szKind then
        return
    end
    
    local tbInfo = self.tbSetting[szKind]
    if not tbInfo then
        return
    end

    local tbLevelInfo = tbInfo.tbLevel[nLevel]
    if not tbLevelInfo then
        return
    end

    local nFinCount = tbLevelInfo.nCount
    local nCurCount = pPlayer.GetUserValue(self.DATA_GROUP, tbInfo.nKeyId);
    return nCurCount >= nFinCount
end

function Achievement:GetKindById(nId)
    if not self.tbKindById then
        self.tbKindById = {}
        for szKind, tbInfo in pairs(self.tbSetting) do
            self.tbKindById[tbInfo.nKeyId] = szKind
        end
    end
    return self.tbKindById[nId]
end

function Achievement:GetIdByKind(szKind)
    return self.tbSetting[szKind].nKeyId
end

function Achievement:GetLikeList(pPlayer)
    local tbList = {}
    local nCount = 0
    for i = 1, self.LIKE_MAXCOUNT do
        local nValue = pPlayer.GetUserValue(self.LIKE_GROUP, i)
        if nValue == 0 then
            break
        end
        tbList[nValue] = true
        nCount = nCount + 1
    end
    return tbList, nCount
end

function Achievement:GetKindMaxCount(szKind)
    local tbInfo = self.tbSetting[szKind]
    if not tbInfo then
        return 9999999
    end
    local nMaxLevel = #tbInfo.tbLevel
    return tbInfo.tbLevel[nMaxLevel].nCount
end

function Achievement:GetKindLevelValue(nKindId, nLevel)
    return nKindId * 10000 + nLevel
end

function Achievement:GetKindAndLevel(nValue)
    local nKindId = math.floor(nValue / 10000)
    local nValue = nValue % 10000
    return nKindId, nValue
end

function Achievement:GetPushMsg(szMainKind, nLevel)
--[[
    local tbLevelInfo = self:GetLevelInfo(szMainKind, nLevel) or {}
    if tbLevelInfo.NeedPush == 1 then
        local szMsg = string.format("达成了<成就：%s>", tbLevelInfo.Title)
        return szMsg
    end
]]

	return "888888888888888888"
end

Achievement.tbSpecialCheck = {
    "EnhanceMaster_1" ,
    "EnhanceMaster_2" ,
    "EnhanceMaster_3" ,
    "EnhanceMaster_4" ,
    "EnhanceMaster_5" ,
    "EnhanceMaster_6" ,
    "InsetMaster_1"   ,
    "InsetMaster_2"   ,
    "InsetMaster_3"   ,
    "InsetMaster_4"   ,
    "InsetMaster_5"   ,
    "InsetMaster_6"   ,
}

function Achievement:SpCheckEnhanceMaster( pPlayer,nLevel )
    local nNeedLevel = Strengthen.tbAchievementLevel[nLevel];
    if not nNeedLevel then
        return;
    end

    local tbStrengthen = pPlayer.GetStrengthen();
    local nCount = 0
    for nEquipPos=Item.EQUIPPOS_HEAD, Item.EQUIPPOS_PENDANT do
        local nNowLevel = tbStrengthen[nEquipPos + 1]
        if nNowLevel >= nNeedLevel then
            nCount = nCount + 1;
        else
            break;
        end
    end
    if nCount >= 10 then
        return true, nCount
    end
end

function Achievement:SpCheckInsetMaster( pPlayer, nLevel )
    local tbInsetLv = StoneMgr:GetInsetLevelCount(pPlayer);
    local nLimitCount = StoneMgr.tbAcheiveNeedInsetNum[nLevel];
    if not nLimitCount then
        return;
    end
    return tbInsetLv[nLevel] and tbInsetLv[nLevel] >= nLimitCount;
end

Achievement.tbSpecilCheck = {
    ["EnhanceMaster_1"]= function ( pPlayer )
        return Achievement:SpCheckEnhanceMaster(pPlayer, 1)
    end;
    ["EnhanceMaster_2"]= function ( pPlayer )
        return Achievement:SpCheckEnhanceMaster(pPlayer, 2)
    end;
    ["EnhanceMaster_3"]= function ( pPlayer )
        return Achievement:SpCheckEnhanceMaster(pPlayer, 3)
    end;
    ["EnhanceMaster_4"]= function ( pPlayer )
        return Achievement:SpCheckEnhanceMaster(pPlayer, 4)
    end;
    ["EnhanceMaster_5"]= function ( pPlayer )
        return Achievement:SpCheckEnhanceMaster(pPlayer, 5)
    end;
    ["EnhanceMaster_6"]= function ( pPlayer )
       return Achievement:SpCheckEnhanceMaster(pPlayer, 6) 
    end;
    ["InsetMaster_1"]= function ( pPlayer )
        return Achievement:SpCheckInsetMaster(pPlayer, 1)
    end;
    ["InsetMaster_2"]= function ( pPlayer )
        return Achievement:SpCheckInsetMaster(pPlayer, 2)
    end;
    ["InsetMaster_3"]= function ( pPlayer )
        return Achievement:SpCheckInsetMaster(pPlayer, 3)
    end;
    ["InsetMaster_4"]= function ( pPlayer )
        return Achievement:SpCheckInsetMaster(pPlayer, 4)
    end;
    ["InsetMaster_5"]= function ( pPlayer )
        return Achievement:SpCheckInsetMaster(pPlayer, 5)
    end;
    ["InsetMaster_6"]= function ( pPlayer )
        return Achievement:SpCheckInsetMaster(pPlayer, 6)
    end;
}

function Achievement:CheckSpecilAchievementFinish(pPlayer, szKind)
    local fnFunc = self.tbSpecilCheck[szKind]
    if not fnFunc then
        return
    end
    return fnFunc(pPlayer)
end