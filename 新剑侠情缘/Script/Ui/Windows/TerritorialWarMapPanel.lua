local tbUi = Ui:CreateClass("TerritorialWarMapPanel")
local tbDefine = LingTuZhan.define;

function tbUi:OnOpen(  )
    --注意执行的先后会不会有影响
    Kin:GetPlayerCareer()    

    self:UpdateMain();
    self:UpdateKinfo();
end

function tbUi:OnOpenEnd( ... )
    self.pPanel:Toggle_SetChecked("BtnLTZ", true)
    self.pPanel:Toggle_SetChecked("BtnWorldMap", false)
end

function tbUi:UpdateMain(  )
    local tbAllMapOwn = LingTuZhan:GetSynAllMapOwnerInfo()
    --根据上面的计算出top10的家族，剩余的都用其他
    local tbKinMapList = {}; --[nServerId ..  dwKinId] = { nMapId1,nMapId2, ... }
    local tbKinName = {}; --[nServerId ..  dwKinId] = szKinName
    local tbKinList = {};--不含自己的家族，为了找出占领领土前10的家族

    for nMapId,tnOwn in pairs(tbAllMapOwn) do
        local nServerId, dwKinId, szKinName  = unpack(tnOwn)
        local szKey = LingTuZhan:GetCombineKinKey(nServerId, dwKinId)
        tbKinMapList[szKey] = tbKinMapList[szKey] or {}
        table.insert(tbKinMapList[szKey], nMapId)
        tbKinName[szKey] = szKinName
    end
    local bHasNoneKinMap = false;
    for nMapId,v in pairs(tbDefine.tbMapSeting) do
        if not tbAllMapOwn[nMapId] then
            bHasNoneKinMap = true
            break;
        end
    end
    local szMyKin = LingTuZhan:GetMyKinKey()
    for szKeyKin,v in pairs(tbKinName) do
        if szKeyKin ~=  szMyKin then
            table.insert(tbKinList, szKeyKin)
        end
    end
    table.sort( tbKinList, function (a, b)
        return #tbKinMapList[a] > #tbKinMapList[b]
    end )

    local tbMapColor = {}; --有占领的才显示，其他的显示null

    local tbKinOwnMapListMy = tbKinMapList[szMyKin]
    if tbKinOwnMapListMy then
        self.pPanel:SetActive("FamilyTerritoryTxt", true)
        for _, nMapId in ipairs(tbKinOwnMapListMy) do
            tbMapColor[nMapId] = tbDefine.tbUiMapNameColorMy;
        end
        local r,g,b = unpack(tbDefine.tbUiMapNameColorMy)
        self.pPanel:Sprite_SetColor("FamilyTerritoryColor", r,g,b)
    else
        self.pPanel:SetActive("FamilyTerritoryTxt", false)
    end

    local nTopNum = #tbDefine.tbUiMapNameColorTop10;
    local tbTop10Kins = { unpack(tbKinList,1, nTopNum)}
    local tbScrollViewData = {}; --{tbColor,szDesc}
    for i,v in ipairs(tbTop10Kins) do
        local tbColor = tbDefine.tbUiMapNameColorTop10[i] 
        local tbData = { tbColor };
        local szKeyKin = tbTop10Kins[i]
        local tbKinOwnMapList = tbKinMapList[szKeyKin]
        for _, nMapId in ipairs(tbKinOwnMapList) do
            tbMapColor[nMapId] = tbColor;
        end

        local szKinName =  tbKinName[szKeyKin]
        local nServerId, dwKinId = LingTuZhan:GetSplitKinKey(szKeyKin)
        local szShowKinName = szKinName;
        if nServerId ~= Sdk:GetTrueServerId() then
            szShowKinName = string.format("%s(%s)", szShowKinName,Sdk:GetServerDesc(nServerId, true))
        end
        tbData[2] = szShowKinName
        table.insert(tbScrollViewData, tbData)
    end
    if #tbKinList > nTopNum then
        local tbColor = tbDefine.tbUiMapNameColorOther
        table.insert(tbScrollViewData, {tbColor,"其他家族" } )
        for i=nTopNum + 1,#tbKinList do
            local szKeyKin = tbKinList[i]
            local tbKinOwnMapList = tbKinMapList[szKeyKin]
            for _, nMapId in ipairs(tbKinOwnMapList) do
                tbMapColor[nMapId] = tbColor;
            end
        end
    end
    self.tbMapColor = tbMapColor;

    if bHasNoneKinMap then
        table.insert(tbScrollViewData, { tbDefine.tbUiMapNameColorNone, "中立" })
    end
    
    local fnSetItem = function ( itemObj, index )
        local tbColor, szDesc = unpack(tbScrollViewData[index])
        itemObj.pPanel:Sprite_SetColor("Color", unpack(tbColor))
        itemObj.pPanel:Label_SetText("FamilyNameTxt", szDesc)
    end
    self.ScrollView:Update(tbScrollViewData, fnSetItem)

    --左边地图列表
    local tbSynCommonData = LingTuZhan:GetSynCommonData()
    if tbSynCommonData.nOpenRound > 0 then
        self.pPanel:Label_SetText("RotationText", string.format("当前轮数：第[FFFE0D]%s[-]轮", (tbSynCommonData.nOpenRound)))
    else    
        self.pPanel:Label_SetText("RotationText", "")
    end
    
    local tbMyKinInfo = LingTuZhan:GetSynMyKinInfo()
    local tbRecoverMapIds = LingTuZhan:GetMyRecoverMapIds();
    for nKey,nMapId in pairs(tbDefine.tbUiOrderToMapId) do
        local szMapName = Map:GetMapName(nMapId)
        local tbMapInfo = tbDefine.tbMapSeting[nMapId]
        self.pPanel:Label_SetText("FieldTxt" .. nKey, szMapName)
        local bOpenMap = false
        if tbSynCommonData.nOpenRound >= tbDefine.tbMapTypeOpenRound[tbMapInfo.nType] then
            bOpenMap = true
        end
        local tbColor = self.tbMapColor[nMapId] or tbDefine.tbUiMapNameColorNone
        self.pPanel:Sprite_SetColor("BtnField" .. nKey, unpack(tbColor))
        self.pPanel:SetActive("Sign" .. nKey, false)
        local tbMapSprite = tbDefine.tbUiMapTypeSprite[tbMapInfo.nType]
        if bOpenMap then
            self.pPanel:Sprite_SetSprite("BtnField" .. nKey, tbMapSprite[1])
            local szState;
            if nMapId == tbMyKinInfo.nManulDeclareMapId then
                szState = "DeclareWar"
            elseif tbMyKinInfo.nMasterMapId and nMapId == tbMyKinInfo.nMasterMapId then
                szState = "MainCity";
            elseif tbRecoverMapIds[nMapId] then
                szState = "WaitRecover";
            end

            if szState then
                -- DeclareWar, MainCity ,Stationed
                self.pPanel:SetActive("Sign" .. nKey, true)
                self.pPanel:Sprite_SetSprite("Sign" .. nKey, szState)
            end
        else
            self.pPanel:Sprite_SetSprite("BtnField" .. nKey, tbMapSprite[2])
        end
    end
end

function tbUi:UpdateKinfo(  )
    local tbMyKinInfo = LingTuZhan:GetSynMyKinInfo()
    if tbMyKinInfo.szActTarget then
        self.pPanel:Label_SetText("TargetText", string.format("领土任务：%s", Calendar:GetActivityNameByKey(tbMyKinInfo.szActTarget)))
    else
        self.pPanel:Label_SetText("TargetText", "")
    end
    self.pPanel:Label_SetText("TerritorialFundsText", string.format("领土资金：%d", tbMyKinInfo.nFound or 0))
end

function tbUi:OnSynData( szDataType )
    if szDataType == "Common" or szDataType == "AllMapOwn" then
        self:UpdateMain()
    elseif szDataType == "MyKinInfo" then
        self:UpdateMain()
        self:UpdateKinfo()
    end
end

function tbUi:RegisterEvent()
    return 
    {
        { UiNotify.emNOTIFY_LTZ_SYN_DATA, self.OnSynData, self },
    };
end

function tbUi:OnClickBtnMap( nMapId )
    Ui:OpenWindow("TerritorialWarTips", nMapId)
end

tbUi.tbOnClick = {};

for nKey,nMapId in pairs(tbDefine.tbUiOrderToMapId) do
    tbUi.tbOnClick["BtnField" .. nKey] = function ( self )
        self:OnClickBtnMap(nMapId)
    end
end

function tbUi.tbOnClick:BtnClose()
    Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:BtnWorldMap()
    Ui:CloseWindow(self.UI_NAME)
    Ui:OpenWindow("WorldMap")
end

function tbUi.tbOnClick:BtnWarReport(  )
    LingTuZhan:RequestOpenCacheKinMsgUI(  )
end

function tbUi.tbOnClick:BtnEnterAWar(  )
    LingTuZhan:PlayerSighGameFight(  )
end

function tbUi.tbOnClick:BtnGoTo()
    LingTuZhan:QuckGotoCamp()
end

function tbUi.tbOnClick:BtnRetract( )
    self.bFolded = not self.bFolded
    self.pPanel:PlayUiAnimation(self.bFolded and "TerritorialWarMapPanelDelete" or "TerritorialWarMapPanelOpen", false, false, {});
    self.pPanel:Button_SetSprite("BtnRetract", self.bFolded and  "ChtaCloes2" or "ChtaCloes")
end