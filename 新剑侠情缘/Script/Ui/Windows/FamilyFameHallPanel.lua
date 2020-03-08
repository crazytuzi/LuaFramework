local tbUi = Ui:CreateClass("FamilyFameHallPanel")
local NpcViewMgr = Ui.NpcViewMgr

tbUi.tbPosInfo = {

    {60.53, -4.12, -0.005999997, 0,-95.47351,0};
    {61.8, -5.53, 1.793, 0, -95.47351, 0};
    {61.8,-5.53,-1.83,0,-95.47351,0  };
    {61.05,-6.68,3.39,0,-95.47351,0};
    {61.05,-6.68,-3.46,0,-95.47351,0};
    {55.42,-6.82,4.51,0,-95.47351,0};
    {55.42,-6.82,-4.55,0,-95.47351,0};
    {50.76,-6.88,5.7,0,-95.47351,0};
    {50.76, -6.88, -5.72, 0,-95.47351,0};
    {50.98,-7.47,1.92,0,-95.47351,0};
    {50.98, -7.47, -1.9, 0,-95.47351,0};
}


tbUi.tbScale = {
    1;    
    1;    
    1;    
    1;    
    1;    
    1;    
    1;    
    1;    
    1;    
    1;    
    1;    
}

tbUi.tbCameraParam = {
            0, 0, 0, 5,90, 0,15.5
}

function tbUi:OnCreate()
    self.tbViewModelIds = {} -- {id1,id2}
end

tbUi.tbCityMapName = {"BtnXY", "BtnLA"};
function tbUi:OnOpenEnd(  )
    local tbMapIds = LingTuZhan:GetCityMapIds();
    for i,v in ipairs(tbMapIds) do
        self.pPanel:Toggle_SetChecked(tbUi.tbCityMapName[i],v == self.nMapTemplateId);
    end
end

function tbUi:OnOpen(nMapTemplateId)
    if not self.nMapTemplateId then
        local tbNpcViewUis =  NpcViewMgr.GetCurViewListUiParent()
        for i=1,tbNpcViewUis.Count do
            local szUiName = tbNpcViewUis[i - 1]
            Ui:CloseWindow(szUiName);
        end
        self.tbOldTextureSize = NpcViewMgr.SetRenderTextureSize(1280,1280)
        self.pPanel:NpcView_BindTexture("ShowRole")
        local cameraObj = Ui.GameObject.Find("UI Root/UiModelCamera")
        if cameraObj then
            local cameraCom = cameraObj:GetComponent("Camera")
            if cameraCom then
                cameraCom.nearClipPlane = 46.84
                cameraCom.farClipPlane = 64.6;
            end
        end
        self.tbOldUiCameraParam = NpcViewMgr.SetCameraWorldPos(unpack(self.tbCameraParam))
    end
    local tbMapIds = LingTuZhan:GetCityMapIds();
    if not nMapTemplateId then
        nMapTemplateId = tbMapIds[1];
    end
    self.nMapTemplateId = nMapTemplateId;

    local tbShowInfo = LingTuZhan:GetCityShowKinInfo( nMapTemplateId )
    if not tbShowInfo then
        for i,v in pairs(self.tbViewModelIds) do
            NpcViewMgr.SetUiViewFeatureActive(v, false)
        end
        for i=1,11 do
            self.pPanel:SetActive("Shadow" .. i,false)
            self.pPanel:SetActive("Name" ..i,false)
        end
        self.pPanel:Label_SetText("FamilyName", "");
        return
    end

    self:Update(tbShowInfo)
end

function tbUi:Update( tbShowInfo )
    local tbDatas = tbShowInfo.tbDatas;
    -- tbDatas = { 
        -- szName = "";
    -- nFaction = 1;
    -- nSex =1;
    -- tbItems = tbItems;
    -- }
    self.pPanel:Label_SetText("FamilyName", string.format("[%s]%s", Sdk:GetServerDesc(tbShowInfo.nServerId), tbShowInfo.szKinName))
    local tbShowKinMemberCareersList = LingTuZhan.define.tbShowKinMemberCareersList
    for i,v in ipairs(tbDatas) do
        if next(v) then
            self.pPanel:SetActive("Shadow" .. i,true)
            self.pPanel:SetActive("Name" ..i,true)
            self.pPanel:Label_SetText("Name" .. i, v.szName)
            if i > 3 then
                local nCareer = tbShowKinMemberCareersList[i];
                local szCareer = Kin.Def.Career_Name[nCareer]
                self.pPanel:Label_SetText("Title" .. i, szCareer)
            end
            local nX, nY,nZ, rX, rY, rZ = unpack(self.tbPosInfo[i])
            local nShowId = self.tbViewModelIds[i]
            if nShowId then
                NpcViewMgr.SetUiViewFeatureActive(nShowId, true)    
                NpcViewMgr.ChangeAllDir(nShowId, rX, rY, rZ,false)
            else
                nShowId = NpcViewMgr.CreateUiViewFeature(nX, nY,nZ, rX, rY, rZ)
                self.tbViewModelIds[i] = nShowId
            end
            NpcViewMgr.SetModePosWorld(nShowId, nX, nY,nZ)
            -- NpcViewMgr.SetScale(nShowId, self.tbScale[i]);

            NpcViewMgr.ChangeUiViewFeatureFaction(nShowId, v.nFaction, v.nSex)

            local tbNpcRes = ViewRole:GetShowResInfo( v.nFaction, v.nSex, v.tbItems )
            for nPartId,nResId in pairs(tbNpcRes) do
                if nPartId ~= Npc.NpcResPartsDef.npc_part_body then
                    NpcViewMgr.ChangeNpcPart(nShowId, nPartId, nResId);
                else
                    NpcViewMgr.ChangePartBody(nShowId, nResId);
                end
            end
        else
            local nShowId = self.tbViewModelIds[i]
            if nShowId then
                NpcViewMgr.SetUiViewFeatureActive(nShowId, false)   
            end
            self.pPanel:SetActive("Shadow" .. i,false)
            self.pPanel:SetActive("Name" ..i,false)
        end
        
    end
    -- for i=#tbDatas + 1,#self.tbViewModelIds do
    --     local nShowId = self.tbViewModelIds[i]
    --     if nShowId then
    --         NpcViewMgr.SetUiViewFeatureActive(nShowId, false)   
    --     end
    -- end
    -- for i=#tbDatas + 1, 11 do
    --     self.pPanel:SetActive("Shadow" .. i,false)
    -- end
    
end

function tbUi:OnClose()
    for i,v in pairs(self.tbViewModelIds) do
        NpcViewMgr.SetUiViewFeatureActive(v, false)
    end
    if self.tbOldTextureSize then
        NpcViewMgr.SetRenderTextureSize(self.tbOldTextureSize.x, self.tbOldTextureSize.y)
        self.tbOldTextureSize = nil;
    end
    local cameraObj = Ui.GameObject.Find("UI Root/UiModelCamera")
    if cameraObj then
        local cameraCom = cameraObj:GetComponent("Camera")
        if cameraCom then
            cameraCom.nearClipPlane = 0.3
            cameraCom.farClipPlane = 100;
        end
    end
    NpcViewMgr.RestoreLastNode()
    if self.tbOldUiCameraParam then
        NpcViewMgr.SetCameraWorldPos(self.tbOldUiCameraParam[0],self.tbOldUiCameraParam[1], self.tbOldUiCameraParam[2],self.tbOldUiCameraParam[3],self.tbOldUiCameraParam[4],self.tbOldUiCameraParam[5],self.tbOldUiCameraParam[6])     
        self.tbOldUiCameraParam = nil;
    end
    self.nMapTemplateId = nil;
end

function tbUi:OnDestroyUi()
    for i,v in pairs(self.tbViewModelIds) do
        NpcViewMgr.DestroyUiViewFeature(v)
    end
    self.tbViewModelIds = {}
end

function tbUi:OnSynData( szDataType )
    if szDataType == "CityShowKin" then
        local tbShowInfo = LingTuZhan:GetCityShowKinInfo( self.nMapTemplateId )
        if tbShowInfo then
            self:Update(tbShowInfo)
        end
    end
end
    
tbUi.tbOnClick = {}

tbUi.tbOnClick.BtnClose = function (self)
    Ui:CloseWindow(self.UI_NAME)
end

tbUi.tbOnClick.BtnXY = function ( self )
    local tbMapIds = LingTuZhan:GetCityMapIds();
    self:OnOpen(tbMapIds[1])
end

tbUi.tbOnClick.BtnLA = function ( self )
    local tbMapIds = LingTuZhan:GetCityMapIds();
    self:OnOpen(tbMapIds[2])
end

function tbUi:RegisterEvent()
    return 
    {
        { UiNotify.emNOTIFY_LTZ_SYN_DATA, self.OnSynData, self },
    };
end
