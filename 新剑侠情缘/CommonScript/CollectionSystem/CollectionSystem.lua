CollectionSystem.RARE_SAVEKEY = 1 --废弃
CollectionSystem.DATA_SESSION = 2
CollectionSystem.SAVE_LEN = 10
CollectionSystem.ITEM_RANK = 2 --道具排行
CollectionSystem.RANDOMFUBEN_ID = 1 --凌绝峰
CollectionSystem.JINXIUSHANHE = 2 --锦绣山河
CollectionSystem.RANKAWARD = {
    [CollectionSystem.RANDOMFUBEN_ID] = {
        {szTimeFrame = "", tbAwardInfo = {
                {1,    {{"Item", 223, 50}, {"AddTimeTitle", 402, 2592000}}},
                {10,   {{"Item", 223, 30}, {"AddTimeTitle", 401, 2592000}}},
                {30,   {{"Item", 223, 25}, {"AddTimeTitle", 400, 2592000}}},
                {100,  {{"Item", 223, 20}}},
                {200,  {{"Item", 223, 15}}},
                {300,  {{"Item", 223, 12}}},
                {500,  {{"Item", 223, 10}}},
                {1000, {{"Item", 223, 8}}},
                {1500, {{"Item", 223, 6}}},
                {9999, {{"Item", 223, 5}}},
            }
        },
        {szTimeFrame = "OpenLevel99", tbAwardInfo = {
                {1,    {{"Item", 224, 30}, {"AddTimeTitle", 402, 2592000}}},
                {5,    {{"Item", 224, 20}, {"AddTimeTitle", 401, 2592000}}},
                {10,   {{"Item", 224, 15}, {"AddTimeTitle", 400, 2592000}}},
                {20,   {{"Item", 224, 12}}},
                {30,   {{"Item", 224, 10}}},
                {50,   {{"Item", 224, 8}}},
                {100,  {{"Item", 223, 20}}},
                {200,  {{"Item", 223, 15}}},
                {300,  {{"Item", 223, 12}}},
                {500,  {{"Item", 223, 10}}},
                {1000, {{"Item", 223, 8}}},
                {9999, {{"Item", 223, 6}}},
            }
        },
        {szTimeFrame = "OpenLevel129", tbAwardInfo = {
                {1,    {{"Item", 225, 10}, {"AddTimeTitle", 402, 2592000}}},
                {5,    {{"Item", 225, 8},  {"AddTimeTitle", 401, 2592000}}},
                {10,   {{"Item", 225, 6},  {"AddTimeTitle", 400, 2592000}}},
                {20,   {{"Item", 224, 18}}},
                {30,   {{"Item", 224, 15}}},
                {50,   {{"Item", 224, 12}}},
                {100,  {{"Item", 223, 30}}},
                {200,  {{"Item", 223, 25}}},
                {300,  {{"Item", 223, 20}}},
                {500,  {{"Item", 223, 15}}},
                {1000, {{"Item", 223, 10}}},
                {9999, {{"Item", 223, 6}}},
            }
        },
    },
    [CollectionSystem.JINXIUSHANHE] = {
        {szTimeFrame = "", tbAwardInfo = {
                {1,    {{"Item", 223, 50}, {"AddTimeTitle", 405, -1}}},
                {10,   {{"Item", 223, 30}, {"AddTimeTitle", 404, -1}}},
                {30,   {{"Item", 223, 25}, {"AddTimeTitle", 403, -1}}},
                {100,  {{"Item", 223, 20}}},
                {200,  {{"Item", 223, 15}}},
                {300,  {{"Item", 223, 12}}},
                {500,  {{"Item", 223, 10}}},
                {1000, {{"Item", 223, 8}}},
                {1500, {{"Item", 223, 6}}},
                {9999, {{"Item", 223, 5}}},
            }
        },
    },
}
CollectionSystem.tbNewInfoKey = {
    [CollectionSystem.RANDOMFUBEN_ID] = "RandomFubenCollection",
    [CollectionSystem.JINXIUSHANHE] = "JXSH_Collection",
}
CollectionSystem.tbRankAwardMailInfo = {
    [CollectionSystem.RANDOMFUBEN_ID] = {
        Title      = "凌绝峰卡片收集",
        From       = "",
        nLogReazon = Env.LogWay_CollectionSystem,
        Text       = "少侠，上个月的凌绝峰卡片收集活动已结束，你的排名为第%d名，奖励已随附件发放，请查收。本月，新的收集活动已经开始，依然要继续努力收集哦！",
    },
    [CollectionSystem.JINXIUSHANHE] = {
        Title      = "锦绣山河集",
        From       = "",
        nLogReazon = Env.LogWay_CollectionSystem,
        Text       = "大侠，国庆“锦绣山河”收集活动已结束，您获得了第%d名，附件为奖励，请查收！",
    },
}

function CollectionSystem:LoadSetting()
    self.tbCollection = {}
    self.tbCard = {}
    self.tbNpcDrop = {}

    local tbCollectionInfo = Lib:LoadTabFile("Setting/CollectionSystem/CollectionConfig.tab", {nCollectionId = 1, nGroupId = 1, nRankBoard = 1, nItemTemplateId = 1})
    for _, tbInfo in ipairs(tbCollectionInfo) do
        self.tbCollection[tbInfo.nCollectionId] = {nSaveGroupId = tbInfo.nGroupId, bRankBoard = tbInfo.nRankBoard > 0, nItemTemplateId = tbInfo.nItemTemplateId}
        assert(tbInfo.nGroupId > 0, "[CollectionSystem LoadSetting] SaveGroup Is 0", tbInfo.nCollectionId)
    end

    local tbSetting = Lib:LoadTabFile("Setting/CollectionSystem/Collection.tab", {nCollectionId = 1, nCardTemplateId = 1, nRare = 1})
    assert(tbSetting, "[CollectionSystem File Not Found]")

    for _, tbInfo in ipairs(tbSetting) do
        local nCollectionId = tbInfo.nCollectionId
        self.tbCollection[nCollectionId].tbCard = self.tbCollection[nCollectionId].tbCard or {}
        table.insert(self.tbCollection[nCollectionId].tbCard, {nCard = tbInfo.nCardTemplateId, szName = tbInfo.szName})

        self.tbCard[tbInfo.nCardTemplateId] = {nCollectionId = nCollectionId, szTimeFrame = tbInfo.szTimeFrame, nRare = tbInfo.nRare}
        self.tbCard[tbInfo.nCardTemplateId].tbAward = Lib:GetAwardFromString(tbInfo.szAward)

        for i = 1, 5 do
            local szDrop = tbInfo["szDropNpc" .. i]
            if Lib:IsEmptyStr(szDrop) then
                break
            end

            local tbDropInfo = Lib:SplitStr(szDrop, "|")
            local nNpc = tonumber(tbDropInfo[1])
            local nRate = tonumber(tbDropInfo[2])
            self.tbNpcDrop[nNpc] = self.tbNpcDrop[nNpc] or {}
            table.insert(self.tbNpcDrop[nNpc], {tbInfo.nCardTemplateId, nRate})
        end
    end
end

function CollectionSystem:GetCardPosition(nCollectionId, nCardTemplateId)
    if not nCollectionId or not nCardTemplateId or not self.tbCollection[nCollectionId] then
        Log("[CollectionSystem GetCardPosition] Err", nCollectionId, nCardTemplateId)
        return
    end

    for nIdx, tbInfo in ipairs(self.tbCollection[nCollectionId].tbCard) do
        if tbInfo.nCard == nCardTemplateId then
            return nIdx
        end
    end
end

function CollectionSystem:GetSaveInfo(nCollectionId, nPos)
    local tbInfo = self.tbCollection[nCollectionId]
    if not tbInfo then
        return
    end

    if not nPos then
        return tbInfo.nSaveGroupId
    end

    nPos = nPos - 0.1
    local nSaveKey = math.ceil(nPos/10) + self.DATA_SESSION
    local nSavePos = math.ceil(nPos%10)
    return tbInfo.nSaveGroupId, nSaveKey, nSavePos
end

function CollectionSystem:GetCollectionLength(nCollectionId)
    if not nCollectionId or not self.tbCollection[nCollectionId] then
        return 0
    end

    return #self.tbCollection[nCollectionId].tbCard
end

function CollectionSystem:GetCompletion(nCollectionId)
    if not nCollectionId or not self.tbCollection[nCollectionId] then
        return
    end

    local nLen = self:GetCollectionLength(nCollectionId)
    local nCompletion = 0
    for i = 1, nLen do
        if self:IsPosActivate(nCollectionId, i) then
            nCompletion = nCompletion + 1
        end
    end
    return nCompletion
end

function CollectionSystem:IsPosActivate(nCollectionId, nPos)
    local nSaveGroup, nSaveKey, nSavePos = self:GetSaveInfo(nCollectionId, nPos)
    local nFlag = me.GetUserValue(nSaveGroup, nSaveKey)
    nFlag = self:GetDecimalBits(nFlag, nSavePos)
    return nFlag > 0
end

function CollectionSystem:GetAllRare(nCollectionId, tbPosData)
    local nAllRare = 0
    local tbCard = self.tbCollection[nCollectionId].tbCard
    for nPos, tbInfo in ipairs(tbCard) do
        nPos = nPos - 0.1
        local nSaveKey = math.ceil(nPos/10)
        local nSavePos = math.ceil(nPos%10)
        local nFlag = tbPosData[nSaveKey] or 0
        if self:GetDecimalBits(nFlag, nSavePos) > 0 then
            local nCardRare = self.tbCard[tbInfo.nCard].nRare
            nAllRare = nAllRare + nCardRare
        end
    end
    return nAllRare
end

function CollectionSystem:GetCardRare(nCardTemplateId)
    if not nCardTemplateId or not self.tbCard[nCardTemplateId] then
        return 0
    end

    return self.tbCard[nCardTemplateId].nRare
end

function CollectionSystem:GetCollectionItemId(nCollectionId)
    local tbInfo = self.tbCollection[nCollectionId]
    return tbInfo.nItemTemplateId
end

function CollectionSystem:GetDecimalBits(nInt32, nPos)
    if nPos <= 0 or nPos > 10 then
        return 0
    end

    nInt32 = nInt32%(10^nPos)
    nInt32 = nInt32/(10^(nPos-1))
    return math.floor(nInt32)
end

function CollectionSystem:SetDecimalBits(nInt32, nBits, nPos)
    if nPos <= 0 or nPos > 10 or nBits < 0 or nBits >= 10 then
        return nInt32
    end

    local nQuotient = nInt32 - nInt32%(10^nPos)
    local nRemainder = nInt32%(10^(nPos-1))
    nBits = nBits*(10^(nPos-1))
    local nResult = nQuotient + nBits + nRemainder
    return nResult
end

function CollectionSystem:CalcValidDate()
    local tbDate = os.date("*t", GetTime())
    local nYear = tbDate.year
    local nMonth = tbDate.month
    if nMonth == 12 then
        nYear = nYear + 1
        nMonth = 1
    else
        nMonth = nMonth + 1
    end
    return string.format("%d-%02d-01-00-00-00", nYear, nMonth)
end

function CollectionSystem:CalcBookValidDate(nCollectionId)
    if nCollectionId == self.JINXIUSHANHE then
        return self:GetJinXiuShanHeEndTime()
    end
    return self:CalcValidDate()
end

function CollectionSystem:CalcCardValidDate(nItemTId)
    local nCollectionId = self:GetCollectionByCard(nItemTId)
    if nCollectionId == self.JINXIUSHANHE then
        local nEndTime = GetTime() + 24*60*60
        local nActEndTime = self:GetJinXiuShanHeEndTime()
        return math.min(nEndTime, nActEndTime)
    end
    return self:CalcValidDate()
end

function CollectionSystem:OnActJxshStart(nEndTime)
    self.nJxshEndTime = nEndTime
end

function CollectionSystem:OnActJxshEnd()
    self.nJxshEndTime = nil
end

function CollectionSystem:GetJinXiuShanHeEndTime()
    return self.nJxshEndTime or 0
end

function CollectionSystem:RandomAward(tbDrop)
    local nMaxProbability = 1000000
    local nRate = MathRandom(1, nMaxProbability)
    local nRateSum = 0
    local tbCard = {}
    for _, tbInfo in ipairs(tbDrop) do
        if tbInfo[2] == -1 then
            table.insert(tbCard, tbInfo[1])
        else
            nRateSum = nRateSum + tbInfo[2]
            if nRate <= nRateSum then
                table.insert(tbCard, tbInfo[1])
                break
            end
        end
    end
    return tbCard
end

function CollectionSystem:IsHaveRankBoard(nCollectionId)
    local tbInfo = self.tbCollection[nCollectionId]
    if not tbInfo then
        return
    end

    return tbInfo.bRankBoard
end

function CollectionSystem:GetCollectionByCard(nCardTemplateId)
    local tbInfo = self.tbCard[nCardTemplateId] or {}
    return tbInfo.nCollectionId
end

function CollectionSystem:GetNotCompleteCardList(nCollectionId)
    if not nCollectionId or not self.tbCollection[nCollectionId] then
        return
    end

    local tbNotCom = {}
    local nCompletion = 0
    for nPos, tbInfo in ipairs(self.tbCollection[nCollectionId].tbCard) do
        local nCard = tbInfo.nCard
        local tbCardInfo = self.tbCard[nCard]
        if Lib:IsEmptyStr(tbCardInfo.szTimeFrame) or GetTimeFrameState(tbCardInfo.szTimeFrame) == 1 then
            if self:IsPosActivate(nCollectionId, nPos) then
                nCompletion = nCompletion + 1
            else
                table.insert(tbNotCom, nCard)
            end
        end
    end
    return nCompletion, tbNotCom
end

CollectionSystem:LoadSetting()