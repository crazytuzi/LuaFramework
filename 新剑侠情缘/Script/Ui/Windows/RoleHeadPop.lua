local tbUi = Ui:CreateClass("RoleHeadPop")

tbUi.tbForbitMapList = {
    [XinShouLogin.tbDef.nFubenMapID] = 1;
    [Activity.DanceMatch.tbSetting.FIGHT_MAP_ID] = 1;
};

tbUi.tbOpenRightTypeMapList = {
    [DrinkHouse.tbDef.NORMAL_MAP] = {"DrinkHouseRoleSelect", -520} ;
};

function tbUi:OnOpen(tbInfo, bIsNpc, bNotClickClose)
    self.bNotClickClose = bNotClickClose
    local tran = self.pPanel:FindChildTransform("Main");
    if tran then
        local Com = tran:GetComponent("MainPanel");
        if bNotClickClose then
            Com.m_bScreenClickNotify = false
        else
            Com.m_bScreenClickNotify = true
        end
    end
            
    if bIsNpc then
        return self:OpenNpcHead(unpack(tbInfo));
    else
        return self:OpenPlayerHead(unpack(tbInfo));
    end
end

function tbUi:OpenNpcHead(nNpcID)
    local pNpc = KNpc.GetById(nNpcID)
    if not pNpc then
        return 0;
    end

    local nTemplateId = pNpc.nTemplateId
    if CommerceTask:IsCommerceGather(nTemplateId) and not CommerceTask:GatherThingInTask(me, nTemplateId) then
        return 0
    end
    if KinDinnerParty:IsTaskGather(nTemplateId) and not KinDinnerParty:GatherThingInTask(me, nTemplateId) then
        return 0
    end

    self.nNpcID = nNpcID;
    self.nPlayerID = nil;

    Operation:SetNpcSelected(nNpcID);

    self.BgSprite.pPanel:SetActive("SpFaction", false);
    self.BgSprite.pPanel:SetActive("lbLevel", false);

    local nFaceId = KNpc.GetNpcShowInfo(pNpc.nTemplateId);
    local szAtlas, szSprite = Npc:GetFace(nFaceId);
    self.BgSprite.pPanel:Sprite_SetSprite("SpRoleHead", szSprite, szAtlas);

    self.BgSprite.pPanel.OnTouchEvent = function ()
        self:OnClickNpc()
    end
end

function tbUi:OnClickNpc()
    if InDifferBattle:IsJueDiVersion() then
        local tbNpcs, nCount = KNpc.GetAroundNpcList(me.GetNpc(), InDifferBattle.tbDefine.nShowAroundNpcDistance)
        if nCount > 1 then
            local tbPos = self.pPanel:GetPosition("Main")
            Ui:SwitchWindowAtPos("DreamlandDangerCollectionPanel", tbPos.x - 80,tbPos.y)    
        else
            Operation.SimpleTap(self.nNpcID);
        end
    else
        Operation.SimpleTap(self.nNpcID);    
    end
end

function tbUi:OpenPlayerHead(nPlayerID, nNpcID, szName, nLevel, nFaction, nProtrait)
    if self.tbForbitMapList[me.nMapTemplateId] then
        return 0
    end

    local pNpc = KNpc.GetById(nNpcID)
    szName = szName or pNpc and pNpc.szName
    nLevel = nLevel or pNpc and pNpc.nLevel
    nFaction = nFaction or pNpc and pNpc.nFaction
    local nSex = Player:Faction2Sex(nFaction)  
    if pNpc then
        nSex = pNpc.nSex
    end


    if not nFaction then
        return 0;
    end

    self.nPlayerID = nPlayerID;
    self.nNpcID = nil;

    local szFaction = Faction:GetIcon(nFaction)
    if not nProtrait then
        nProtrait = PlayerPortrait:GetDefaultId(nFaction, nSex);
    end
    local szIcon, szAtlas = PlayerPortrait:GetSmallIcon(nProtrait)
    self.BgSprite.pPanel:Sprite_SetSprite("SpRoleHead", szIcon, szAtlas);

    self.BgSprite.pPanel:SetActive("SpFaction", true);
    self.BgSprite.pPanel:Sprite_SetSprite("SpFaction", szFaction)

    self.BgSprite.pPanel:SetActive("lbLevel", true);
    self.BgSprite.pPanel:Label_SetText("lbLevel", nLevel)

    self.BgSprite.pPanel.OnTouchEvent = function ()
        local tbData = { dwRoleId = nPlayerID, szName = szName, nNpcID = nNpcID,nLevel = nLevel}
        local tbPos = self.pPanel:GetRealPosition("Main")
        local szType = "RoleSelect"
        local nY = tbPos.y - 380
        local tbChangeType = self.tbOpenRightTypeMapList[me.nMapTemplateId]
        if tbChangeType then
            szType = tbChangeType[1]
            nY = tbPos.y + (tbChangeType[2] or 0)
        end
        Ui:OpenWindowAtPos("RightPopup", tbPos.x - 232, nY, szType, tbData)
    end
end

function tbUi:OnScreenClick()
        self:CloseWindow()
end

function tbUi:OnClose()
    Operation:UnselectNpc();
end


function tbUi:OnCloseToNpc(nCurNpcId, nLastNpcId)
    if nCurNpcId == 0 and self.nNpcID and self.nNpcID == nLastNpcId then
        self:CloseWindow()
        return;
    end

    if nCurNpcId and nCurNpcId > 0 and nCurNpcId ~= self.nNpcID then
        self:OpenNpcHead(nCurNpcId);
        return;
    end
end

function tbUi:CloseWindow()
    Ui:CloseWindow("DreamlandDangerCollectionPanel")
    Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OnMapLoaded()
    self:CloseWindow()
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_CLOSE_TO_NCP,       self.OnCloseToNpc },
        { UiNotify.emNOTIFY_MAP_LOADED,         self.OnMapLoaded },
    };

    return tbRegEvent;
end