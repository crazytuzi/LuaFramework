local RepresentSetting = luanet.import_type("RepresentSetting");

function PlayerTitle:OnSyncAllData(tbAllData)
    me.tbPlayerTitleData = tbAllData;
    for k,v in pairs(tbAllData.tbAllTitle) do
        local tbTitleTemp = self:GetTitleTemplate(k);
        if not tbTitleTemp then
            if tbAllData.nActivateTitle == k then
                tbAllData.nActivateTitle = 0
            end
            PlayerTitle:DeleteTitle(k)
        end
    end
    local pNpc = me.GetNpc();
    if tbAllData.nActivateTitle > 0 then
        pNpc.SetTitleID(tbAllData.nActivateTitle);
    end
end

function PlayerTitle:GetPlayerTitleData()
    local  tbData = me.tbPlayerTitleData;
    if not tbData then
        me.tbPlayerTitleData = {};
        tbData = me.tbPlayerTitleData;
    end

    tbData.nActivateTitle = tbData.nActivateTitle or 0;
    tbData.tbAllTitle =  tbData.tbAllTitle or {};
    return tbData;
end

function PlayerTitle:GetPlayerTitleByID(nTitleID)
    local tbData = self:GetPlayerTitleData();
    return tbData.tbAllTitle[nTitleID];
end

function PlayerTitle:AddTitle(nTitleID, nEndTime, szText)
    local tbData = self:GetPlayerTitleData();
    local tbTitleData = {};
    tbTitleData.nTitleID = nTitleID;
    tbTitleData.nEndTime = nEndTime;
    tbTitleData.szText = szText;
    tbData.tbAllTitle[nTitleID] = tbTitleData;
    UiNotify.OnNotify(UiNotify.emNOTIFY_UPDATE_TITLE);
end

function PlayerTitle:GetPlayerTempData(pPlayer)
    if not pPlayer.tbPlayerTitleTempData then
        pPlayer.tbPlayerTitleTempData = {};
    end
    
    return pPlayer.tbPlayerTitleTempData;    
end

function PlayerTitle:SetShowTitle(nTitleID, szText)
    local tbTempData = self:GetPlayerTempData(me);
    tbTempData.tbShowTitle = {};
    tbTempData.tbShowTitle.nTitleID = nTitleID;
    tbTempData.tbShowTitle.szText = szText;
end

function PlayerTitle:ActiveTitle(nTitleID)
    local tbData = self:GetPlayerTitleData();
    tbData.nActivateTitle = nTitleID;
    local pNpc = me.GetNpc();

    local szText = "";
    if tbData.nActivateTitle > 0 then
        local tbTitleData = self:GetPlayerTitleByID(tbData.nActivateTitle);
        if tbTitleData and not Lib:IsEmptyStr(tbTitleData.szText) then
            szText = tbTitleData.szText;
        end
    end

    pNpc.SetTitleID(tbData.nActivateTitle);
    if not Lib:IsEmptyStr(szText) then
        pNpc.SetTitle(szText);
    else
        pNpc.SetTitle("");   
    end  

    UiNotify.OnNotify(UiNotify.emNOTIFY_UPDATE_TITLE);
end

function PlayerTitle:DeleteTitle(nTitleID)
    local tbData = self:GetPlayerTitleData();
    tbData.tbAllTitle[nTitleID] = nil;
    UiNotify.OnNotify(UiNotify.emNOTIFY_UPDATE_TITLE);   
end    

function PlayerTitle:SetTitleLabel(tbWnd, szLabel, nTitleID)
    local pNpc = me.GetNpc();
    local szTitleName = nil;
    if not nTitleID then
        nTitleID = nTitleID or pNpc.nTitleID;
        
        local tbTitleData = self:GetPlayerTitleByID(nTitleID);
        if tbTitleData and not Lib:IsEmptyStr(tbTitleData.szText) then
            szTitleName = tbTitleData.szText;
        end

        local tbTempData = self:GetPlayerTempData(me);
        local tbShowTitle = tbTempData.tbShowTitle;
        if tbShowTitle and tbShowTitle.nTitleID == nTitleID and not Lib:IsEmptyStr(tbShowTitle.szText) then
            szTitleName = tbShowTitle.szText;
        end    
    end

    if nTitleID <= 0 then
        tbWnd.pPanel:Label_SetText(szLabel, "");
        return;
    end

    local tbTitleTemp = PlayerTitle:GetTitleTemplate(nTitleID);
    local MainColor = RepresentSetting.GetColorSet(tbTitleTemp.ColorID);
    if not szTitleName then
        szTitleName = tbTitleTemp.Name;
    end    

    tbWnd.pPanel:Label_SetText(szLabel, szTitleName);
    tbWnd.pPanel:Label_SetColor(szLabel, MainColor.r * 255, MainColor.g * 255, MainColor.b * 255);

    if tbTitleTemp.GTopColorID > 0 and tbTitleTemp.GBottomColorID > 0 then
        local GTopColor = RepresentSetting.GetColorSet(tbTitleTemp.GTopColorID);
        local GTBottomColor = RepresentSetting.GetColorSet(tbTitleTemp.GBottomColorID);
        tbWnd.pPanel:Label_SetGradientByColor(szLabel, GTopColor, GTBottomColor);
    else
        tbWnd.pPanel:Label_SetGradientActive(szLabel, false);
    end    

    local ColorOuline = RepresentSetting.CreateColor(0.0, 0.0, 0.0, 1.0);
    if tbTitleTemp.OutlineColorID > 0 then
        ColorOuline = RepresentSetting.GetColorSet(tbTitleTemp.OutlineColorID);
    end

    tbWnd.pPanel:Label_SetOutlineColor(szLabel, ColorOuline);    
end