local tbUi = Ui:CreateClass("TerritorialWarTips")
local tbDefine = LingTuZhan.define;

function tbUi:OnOpen( nMapTemplateId )
    local tbMapInfo = tbDefine.tbMapSeting[nMapTemplateId] 
    local tbSynCommonData = LingTuZhan:GetSynCommonData()
    local nNeedRound = tbDefine.tbMapTypeOpenRound[tbMapInfo.nType] 
    if tbSynCommonData.nOpenRound < nNeedRound then
        me.CenterMsg(string.format("%s领土在第%d轮开放", tbDefine.tbMapTypeName[tbMapInfo.nType], nNeedRound))
        return 0
    end

    Kin:GetPlayerCareer()    

    self.nMapTemplateId = nMapTemplateId
    self:UpdateFix();
    self:UpdateMain();
    self:UpdateBtnState();
end

function tbUi:UpdateFix(  )
    local tbMapInfo = tbDefine.tbMapSeting[self.nMapTemplateId]
    local szMapName = Map:GetMapName(self.nMapTemplateId)
    self.pPanel:Label_SetText("NameTxt", szMapName)
    for i=1,5 do
        self.pPanel:SetActive("Star" .. i, tbMapInfo.nStar >= i)
    end
end

function tbUi:UpdateMain(  )
    -- { tbDeclareKinList, nWallLevel,nDragonFlagLevel,nStable };
    local tbSynMapInfo = LingTuZhan:GetSynMapInfo(self.nMapTemplateId)
    local tbMapSeting = tbDefine.tbMapSeting[self.nMapTemplateId]
    if tbMapSeting.Doors and next(tbMapSeting.Doors) then
        self.pPanel:SetActive("WallTxt",true)
        self.pPanel:Label_SetText("WallNumberTxt", (tbSynMapInfo.nWallLevel or 1))
    else
        self.pPanel:SetActive("WallTxt",false)
    end
    
    self.pPanel:Label_SetText("LoongColumnNumberTxt", (tbSynMapInfo.nDragonFlagLevel or 1))
    self.pPanel:Label_SetText("StableNumberTxt", (tbSynMapInfo.nStable or 50))
    local tbAllMapOwn = LingTuZhan:GetSynAllMapOwnerInfo()
    local tbOwnKin = tbAllMapOwn[self.nMapTemplateId]
    local szShowName = "中立";
    if tbOwnKin then
        local nServerId, dwkinId, szKinName = unpack(tbOwnKin)
        szShowName = string.format("%s(%s)", szKinName, Sdk:GetServerDesc(nServerId))
    end
    self.pPanel:Label_SetText("AscriptionNumberTxt", (szShowName))
        
    local szDesc = "宣战家族\n"
    if tbSynMapInfo.tbDeclareKinList then
        local tbKinList = {}
        for i,v in ipairs(tbSynMapInfo.tbDeclareKinList) do
            local nServerId ,dwkinId, szKinName = unpack(v)
            table.insert(tbKinList, string.format("%s(%s)", szKinName, Sdk:GetServerDesc(nServerId)) )
        end
        szDesc = szDesc .. table.concat( tbKinList, "、")
    else
        szDesc = szDesc .. "无"
    end

    self.TextDesc:SetLinkText(szDesc)
    local tbTextSize = self.pPanel:Label_GetPrintSize("TextDesc");
    local tbSize = self.pPanel:Widget_GetSize("datagroup");
    self.pPanel:Widget_SetSize("datagroup", tbSize.x, 50 + tbTextSize.y);
    self.pPanel:DragScrollViewGoTop("datagroup");
    self.pPanel:UpdateDragScrollView("datagroup");    
end

function tbUi:UpdateBtnState()
    self.pPanel:SetActive("BtnGroup", false)
    self.pPanel:SetActive("BtnEnterAWar", false)
    --区别是直接参战状态还是其他状态
    local tbSynCommonData = LingTuZhan:GetSynCommonData()
    local tbGetMyOwnMapIds = LingTuZhan:GetMyOwnMapIds();
    local tbSynMyKinInfo = LingTuZhan:GetSynMyKinInfo()
    if tbSynCommonData.bOpenWar and (next(tbGetMyOwnMapIds) or tbSynMyKinInfo.nManulDeclareMapId) then
        --可参战
        self.pPanel:SetActive("BtnEnterAWar", true)
    else

        self.pPanel:SetActive("BtnGroup", true)
        -- local bShowDeclareWar = false
        -- if not next(tbGetMyOwnMapIds) and (tbSynCommonData.bOpenDeclareWar or (tbSynCommonData.bOpenWar and not tbSynMyKinInfo.nManulDeclareMapId)) then
        --     --可宣战
        --     bShowDeclareWar = true
        -- end
        self.pPanel:SetActive("BtnDeclareWar", true)
        local bOwnMap = tbGetMyOwnMapIds[self.nMapTemplateId] and true or false
        self.pPanel:SetActive("BtnStable", bOwnMap)
        self.pPanel:SetActive("BtnUpgrade", bOwnMap)
        self.pPanel:SetActive("BtnrEinforce", bOwnMap)
        self.pPanel:SetActive("BtnMainCity", bOwnMap)
        self.pPanel:SetActive("BtnBeStationed", false)
    end
    
end

function tbUi:OnSynData( szDataType )
    if szDataType == "SynMapInfo" or szDataType == "MyKinInfo" then
        self:UpdateMain()
    elseif szDataType == "Common" or szDataType == "AllMapOwn" then
        self:UpdateBtnState()
    end
end

function tbUi:OnSynKinData( szDataType )
    if szDataType == "MemberCareer" then
        self:UpdateBtnState()
    end
end

function tbUi:RegisterEvent()
    return 
    {
        { UiNotify.emNOTIFY_LTZ_SYN_DATA, self.OnSynData, self },
        { UiNotify.emNOTIFY_SYNC_KIN_DATA, self.OnSynKinData, self },
    };
end

function tbUi:OnScreenClick(szClickUi)
    Ui:CloseWindow(self.UI_NAME)
end

tbUi.tbOnClick = {};

function tbUi.tbOnClick:BtnDeclareWar(  )
    LingTuZhan:RequestDeclaerMap( self.nMapTemplateId )
end

function tbUi.tbOnClick:BtnStable(  )
    LingTuZhan:RequestControlStable( self.nMapTemplateId )
end

function tbUi.tbOnClick:BtnUpgrade(  )
    LingTuZhan:RequestLevelUpDragonFlag( self.nMapTemplateId )
end

function tbUi.tbOnClick:BtnrEinforce(  )
    LingTuZhan:RequestLevelUpWall(self.nMapTemplateId)
end

function tbUi.tbOnClick:BtnMainCity(  )
    LingTuZhan:RequestSetKinMasterMap( self.nMapTemplateId )
end

function tbUi.tbOnClick:BtnEnterAWar(  )
    LingTuZhan:SighGameFightMap( self.nMapTemplateId )
end