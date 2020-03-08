local tbUi = Ui:CreateClass("WaiYiTryPanel")
tbUi.tbOnClick =
{
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,

    BtnPurchase = function(self)
        Ui:OpenWindow("CommonShop", "Dress")
    end,

    BtnReceive = function(self)
        if (self.nSelectedType or 0) <= 0 or (self.nSelectedIdx or 0) <= 0 then
            me.CenterMsg("请选择外装")
            return
        end
        RemoteServer.WaiYiTryReq("Claim", self.nSelectedType, self.nSelectedIdx)
    end,
}

tbUi.tbOnDrag =
{
    ShowRole = function (self, szWnd, nX, nY)
        self.pPanel:NpcView_ChangeDir("ShowRole", -nX, true)
    end,
}

local tbSubMenuStatus = {
    Hide = 1,
    Show = 2,
}

function tbUi:RegisterEvent()
    return {
        { UiNotify.emNOTIFY_ON_NPC_DIALOG, self.ForceClose, self },
        { UiNotify.emNOTIFY_SHOW_DIALOG, self.ForceClose, self },
    }
end

function tbUi:OnOpenEnd()
	self.pPanel:NpcView_Open("ShowRole", me.nFaction, me.nSex);
    self:ChangeFeatrue()

    self:Select(1, 1)
end

function tbUi:ForceClose()
    Ui:CloseWindow(self.UI_NAME)
end

function tbUi:OnClose()
    self:CloseTimer()
    self.pPanel:NpcView_Close("ShowRole");
end

function tbUi:_UpdateMenuData()
    local tbMenuItems = {}
    for nType, szName in ipairs(WaiYiTry.Def.tbTypeNames) do
        local tb = {
            nType = nType,
            szName = szName,
            bShowSubmenu = self.nSelectedType == nType,
        }
        table.insert(tbMenuItems, tb)
        if self.nSelectedType == nType then
            tb.nSubMenuStatus = tbSubMenuStatus.Show
            for i, nId in ipairs(WaiYiTry.tbSetting[me.nFaction][me.nSex][nType]) do
                local szName = Item:GetItemTemplateShowInfo(nId, me.nFaction, me.nSex)
                table.insert(tbMenuItems, {
                    bSubmenu = true,
                    nType = nType,
                    szName = szName,
                    nIdx = i,
                })
            end
        else
            tb.nSubMenuStatus = tbSubMenuStatus.Hide
        end
    end
    self.tbMenuItems = tbMenuItems
end

function tbUi:RefreshMenu()
    self:_UpdateMenuData()
    local fnSetItem = function(pGrid, nIdx)
        local tbData = self.tbMenuItems[nIdx]

        local bSubmenuItem = not not tbData.bSubmenu
        local nSubMenuStatus = tbData.nSubMenuStatus
        pGrid.BaseClass.pPanel:SetActive("BtnStatus", not not nSubMenuStatus)
        if nSubMenuStatus then
            local nX = nSubMenuStatus==tbSubMenuStatus.Hide and 1 or -1
            pGrid.BaseClass.pPanel:ChangeScale("BtnStatus", nX, 1, 1)
        end
        pGrid.BaseClass.pPanel:SetActive("Main", not bSubmenuItem)
        pGrid.SubClass.pPanel:SetActive("Main", bSubmenuItem)
        if bSubmenuItem then
            local szIcon = (tbData.nType==self.nSelectedType and tbData.nIdx==self.nSelectedIdx) and "BtnListSecondPress" or "BtnListSecondNormal"
            pGrid.SubClass.pPanel:Button_SetSprite("Main", szIcon)

            pGrid.SubClass.pPanel:Label_SetText("Label", tbData.szName or "??")
            pGrid.SubClass.pPanel.OnTouchEvent = function()
                self:Select(tbData.nType, tbData.nIdx)
            end
        else
            local bFocus = tbData.nType==self.nSelectedType
            local szIcon = bFocus and "BtnListMainPress" or "BtnListMainNormal"
            pGrid.BaseClass.pPanel:Button_SetSprite("Main", szIcon)
            pGrid.BaseClass.pPanel:Label_SetText("LabelLight", tbData.szName)
            pGrid.BaseClass.pPanel:Label_SetText("LabelDark", tbData.szName)
            pGrid.BaseClass.pPanel:SetActive("LabelDark", not bFocus)
            pGrid.BaseClass.pPanel:SetActive("LabelLight", bFocus)
            pGrid.BaseClass.pPanel.OnTouchEvent = function()
                self:Select(tbData.nType)
            end
        end
    end
    self.ScrollViewBtn:Update(#self.tbMenuItems, fnSetItem)
end

local tbShowBuyBtn = {
    [3] = true,
}
function tbUi:CanShowBuyBtn()
    if not tbShowBuyBtn[self.nSelectedType or 0] then
        return false
    end
    return me.nLevel >= Shop.SHOW_LEVEL
end

function tbUi:Select(nType, nIdx)
    self.nSelectedType = nType
    self.nSelectedIdx = nIdx
    self:RefreshMenu()

    if nType and nType > 0 and nIdx and nIdx > 0 then
        local nTempalteId = WaiYiTry:GetTemplateId(me, nType, nIdx)
        local tbInfo = KItem.GetItemBaseProp(nTempalteId)
        if tbInfo then
            self:Try(nTempalteId)
            local szIntro = string.gsub(tbInfo.szIntro, "\\n", "\n")
            self.pPanel:Label_SetText("ProductProfileTxt", szIntro)
        end
    end
    self.pPanel:SetActive("BtnPurchase", self:CanShowBuyBtn())
end

function tbUi:CanPreViewTargetWaiyi(nTemplateId)
    local tbTargetWaiyis = Shop:CanPreViewTargetWaiyiListFromItemPack(nTemplateId, me.nFaction)
    return tbTargetWaiyis[1], tbTargetWaiyis
end

function tbUi:Try(nTemplateId)
	local nTargetWaiyi, tbTargetWaiyis = self:CanPreViewTargetWaiyi(nTemplateId)
	if not nTargetWaiyi then
        me.CenterMsg("当前道具不能试穿", true)
        return
    end

	local tbChanePartParams = {}
    local tbChanePartParamsEffect = {};
    for i,_nTargetWaiyi in ipairs(tbTargetWaiyis) do
        local nPart = Item.tbChangeColor:GetChangePart(_nTargetWaiyi)
        local nRes,nEffectResId;
        if nPart == Npc.NpcResPartsDef.npc_part_horse then
            nRes = _nTargetWaiyi;
        else
            nRes, nEffectResId = Item.tbChangeColor:GetWaiZhuanRes(_nTargetWaiyi, me.nFaction, me.nSex)
        end
        tbChanePartParams[nPart] = nRes
        tbChanePartParamsEffect[nPart] = nEffectResId
    end
    self:ChangeFeatrue(tbChanePartParams,tbChanePartParamsEffect)
end

function tbUi:CloseTimer()
	if self.nTimerChangeFeatrue then
        Timer:Close(self.nTimerChangeFeatrue)
        self.nTimerChangeFeatrue = nil
    end
end

function tbUi:ChangeFeatrue(tbChanePartParams, tbChanePartParamsEffect)
    self:CloseTimer()
    self.nTimerChangeFeatrue = Timer:Register(1, self.OnTimerChangeFeatrue, self, tbChanePartParams, tbChanePartParamsEffect)
end

function tbUi:OnTimerChangeFeatrue(tbChanePartParams,tbChanePartParamsEffect)
    if self.nTimerChangeFeatrue then
        Timer:Close(self.nTimerChangeFeatrue);
        self.nTimerChangeFeatrue = nil;
    end

    local tbNpcRes, tbEffectRes = me.GetNpcResInfo();
    local nViewHorseTemplate = nil;
    if tbChanePartParams and tbChanePartParamsEffect then
        self.tbPart = self.tbPart or {};
        self.tbPartEffect = self.tbPartEffect or {};

        for nChangePart, nWaiZhuanRes in pairs(tbChanePartParams) do
            self.tbPart[nChangePart] = nWaiZhuanRes;
            if nChangePart == Npc.NpcResPartsDef.npc_part_horse then
                nViewHorseTemplate = nWaiZhuanRes
            end
        end
        for nChangePart, nWaiZhuanResEffect in pairs(tbChanePartParamsEffect) do
            self.tbPartEffect[nChangePart] = nWaiZhuanResEffect;
        end
        if nViewHorseTemplate then
            self.tbPart = {};
            self.tbPartEffect = {};
            self.tbPart[Npc.NpcResPartsDef.npc_part_horse] = nViewHorseTemplate;
        else
            self.tbPart[Npc.NpcResPartsDef.npc_part_horse] = nil;
        end
    else
        self.tbPart = {}
        self.tbPartEffect = {};
    end

    if nViewHorseTemplate then
        local nNpcRes = Item:GetHorseShoNpc(nViewHorseTemplate)
        if nNpcRes then
            self.szRideActionName = KNpc.GetRideActionName(nNpcRes) or "hst";
            self.pPanel:SetActive("ShowRole", true);
            self.pPanel:NpcView_ShowNpc("ShowRole", nNpcRes);
            self.pPanel:NpcView_ChangePartRes("ShowRole", Npc.NpcResPartsDef.npc_part_weapon, 0);
            self.pPanel:NpcView_ChangePartRes("ShowRole", Npc.NpcResPartsDef.npc_part_head, 0);
            self.pPanel:NpcView_SetScale("ShowRole", 0.7);
        else
            self.pPanel:SetActive("ShowRole", false);
        end
    else
        local tbNpcRes, tbEffectRes = me.GetNpcResInfo();
        local tbFactionScale =  Ui:GetClass("ItemBox").tbFactionScale;
        local fScale = tbFactionScale[me.nFaction] or 1
        self.pPanel:SetActive("ShowRole", true);

        for nPartId, nResId in pairs(tbNpcRes) do
            local nCurResId = nResId
            if nPartId == Npc.NpcResPartsDef.npc_part_horse then
                nCurResId = 0;
            elseif self.tbPart[nPartId] then
                nCurResId = self.tbPart[nPartId];
            end

            self.pPanel:NpcView_ChangePartRes("ShowRole", nPartId, nCurResId);
        end
        for nPartId, nResId in pairs(tbEffectRes) do
            if self.tbPartEffect[nPartId] then
                nResId = self.tbPartEffect[nPartId]
            end
            self.pPanel:NpcView_ChangePartEffect("ShowRole", nPartId, nResId);
        end

        self.pPanel:NpcView_SetScale("ShowRole", fScale);
    end
end