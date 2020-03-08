local tbUi = Ui:CreateClass("DreamlandDangerInfoPanel");

tbUi.tbItemClassPos = {
    ["IndifferAddBuff"] = { x = 266,y = 0 };
};

function tbUi:OnOpen()
    self:UpdateItemList()
end

function tbUi:OnOpenEnd()
	self.nTimer =  Timer:Register(Env.GAME_FPS , self.UpdateTimer, self);
    self:UpdateMain()
end

function tbUi:UpdateMain(szRefreshUi)
    local STATE_TRANS = InDifferBattle.tbSettingGroup.STATE_TRANS
	local tbState = STATE_TRANS[InDifferBattle.nState]
	self.pPanel:Label_SetText("TargetInfo", tbState.szDesc)
	self.pPanel:Label_SetText("Region", string.format("当前区域：%d", InDifferBattle.tbTeamRoomInfo[me.dwID])) 
    local nNowItemBagNpcId = InDifferBattle.tbServerPlayerInfo.nNowItemBagNpcId
    local tbItemBagLNpcGridCount = InDifferBattle:GetSettingTypeField(InDifferBattle.szBattleType, "tbItemBagLNpcGridCount")
    local tbBagInfo = tbItemBagLNpcGridCount[nNowItemBagNpcId]
    self.pPanel:Label_SetText("BagLevel", tbBagInfo.szDesc)

	if InDifferBattle.bMyIsDeath or InDifferBattle.nState == #STATE_TRANS then
		self.pPanel:SetActive("BtnLeave", true)
        self.pPanel:SetActive("BtnBattle", true)
	else
		self.pPanel:SetActive("BtnLeave", false)
        self.pPanel:SetActive("BtnBattle", false)
	end
    self.pPanel:SetActive("Dead", false)

    if szRefreshUi == "ItemList" then
        self:UpdateItemList()
    end
    if InDifferBattle.nLeftTeamNum then
        self.pPanel:SetActive("RemainingTeamInfo", true)
        self.pPanel:Label_SetText("RemainingTeamInfo",string.format("剩余队伍：%d", InDifferBattle.nLeftTeamNum))
    else
        self.pPanel:SetActive("RemainingTeamInfo", false)
    end
end

function tbUi:OnClose()
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil;
	end
end

function tbUi:UpdateTimer()
	local nLeftTime = InDifferBattle.nLeftTime
	self.pPanel:Label_SetText("Time", string.format("%02d:%02d", math.floor(nLeftTime / 60), nLeftTime % 60));
	return true;	
end

function tbUi:UpdateItemList()
    self.tbItemList = {}
    local tbItem = me.GetItemListInBag();
    local tbAllCanShowItemId = InDifferBattle:GetAllCanShowItemId()

    for nIdx, pItem in ipairs(tbItem) do
        if tbAllCanShowItemId[pItem.dwTemplateId] then
            local tbData = { nKey1 = pItem.nValue , nItemId = pItem.dwId, dwTemplateId = pItem.dwTemplateId};
            table.insert(self.tbItemList, tbData)
        end
    end
	-- 直接按sort 来就好了
    local fnSort = function (tbA, tbB)
        return tbA.nKey1 < tbB.nKey1
    end
    table.sort(self.tbItemList, fnSort)

    self.tbShowItem = {};
    local nNowItemBagCount = InDifferBattle:GetItemBagContainCount()
    for i=1,6 do
        local tbGrid = self["Item" .. i]
        self.pPanel:SetActive("NotActive" .. i, false)
        if i <= nNowItemBagCount then
            local tbData = self.tbItemList[i]
            if tbData then
                tbGrid:SetItem(tbData.nItemId)
                self.tbShowItem[tbData.nItemId] = tbGrid
                tbGrid.fnClick = function ()
                    local tbItembase = KItem.GetItemBaseProp(tbData.dwTemplateId)
                    local tbPos = self.tbItemClassPos[tbItembase.szClass]
                    Item:ShowItemDetail(tbGrid, tbPos);
                end;
                tbGrid.fnDoubleClick = function ()
                    RemoteServer.InDifferBattleRequestInst("UseItem", tbData.nItemId)
                end;
            else
                tbGrid:Clear();
            end
        else
           tbGrid:Clear();
           tbGrid.pPanel:SetActive("CDLayer", true)
           self.pPanel:SetActive("NotActive" .. i, true)
        end
    end
end

function tbUi:OnSyncItem(nItemId, bUpdateAll)
	if bUpdateAll == 1 then
        self:UpdateItemList();
    elseif nItemId then
        if self.tbShowItem[nItemId] and self.tbShowItem[nItemId].nItemId == nItemId then
            self.tbShowItem[nItemId]:SetItem(nItemId)
        end
    end
end

function tbUi:OnDelItem(nItemId)
    self:UpdateItemList();
end

tbUi.tbOnClick = {};

function tbUi.tbOnClick:BtnLeave()
	RemoteServer.InDifferBattleRequestInst("RequestLeave")
end

function tbUi.tbOnClick:BtnRole()
    Ui:OpenWindow("DreamlandCheatsPanel")
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_INDIFFER_BATTLE_UI,   self.UpdateMain},
        { UiNotify.emNOTIFY_SYNC_ITEM,			self.OnSyncItem },
        { UiNotify.emNOTIFY_DEL_ITEM,           self.OnDelItem },
    };

    return tbRegEvent;
end
