local tbUi = Ui:CreateClass("DreamlandInfoPanel");

function tbUi:OnOpen()
	self.pPanel:Label_SetText("CurrentLocationTitle", "当前区域：")
	self:UpdateItemType();
    self:UpdateItemList()
end

function tbUi:OnOpenEnd()
	self.nTimer =  Timer:Register(Env.GAME_FPS , self.UpdateTimer, self);
    self:UpdateMain()
end

function tbUi:UpdateMain()
	self.pPanel:Label_SetText("Magatama", me.GetMoney(InDifferBattle.tbDefine.szMonoeyType))
	local tbState = InDifferBattle.tbDefine.STATE_TRANS[InDifferBattle.nState]
	self.pPanel:Label_SetText("TargetInfo", tbState.szDesc)
	self.pPanel:Label_SetText("CurrentLocation", InDifferBattle.tbTeamRoomInfo[me.dwID])

	if InDifferBattle:IsInDangerRoom() then
		self.pPanel:Label_SetText("TargetInfo", "离开此区域")
	end

	if InDifferBattle.bMyIsDeath or InDifferBattle.nState == #InDifferBattle.tbDefine.STATE_TRANS then
		self.pPanel:SetActive("BtnLeave", true)
        self.pPanel:SetActive("BtnBattle", true)
        self.pPanel:SetActive("BtnStrengthen", false)
	else
		self.pPanel:SetActive("BtnLeave", false)
        self.pPanel:SetActive("BtnBattle", false)
        self.pPanel:SetActive("BtnStrengthen", true)
	end
    self.pPanel:SetActive("Dead", false)
    self:CheckCanEnhance()
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

local ITEM_CLASS_SORT = 
{
    IndifferScrollEnhance 	= 1;
    IndifferScrollHorse 	= 2;
    IndifferScrollBook 		= 3;
}

function tbUi:UpdateItemType()
    self.tbItemList = {}
    local nCount = 0;
    local tbItem = me.GetItemListInBag();
    
    local tbAllCanShowItemId = InDifferBattle:GetAllCanShowItemId()

    for nIdx, pItem in ipairs(tbItem) do
        if tbAllCanShowItemId[pItem.dwTemplateId] then
            local szClass = pItem.szClass;
            local nSort = ITEM_CLASS_SORT[szClass] or 500
            local tbClass = Item:GetClass(szClass)
            if tbClass.CheckUsable then
                if tbClass:CheckUsable(pItem) == 0 then
                    nSort = nSort + 500;
                end
            end
            local tbData = { nKey1 = nSort, nItemId = pItem.dwId, dwTemplateId = pItem.dwTemplateId};
            table.insert(self.tbItemList, tbData)
        end
    end
end

function tbUi:UpdateItemList()
	-- 直接按sort 来就好了
    local fnSort = function (tbA, tbB)
        return tbA.nKey1 < tbB.nKey1
    end

    table.sort(self.tbItemList, fnSort)

    self.tbShowItem = {};
    local tbGridParams = {bShowTip = true}
    local fnSetItem = function(tbItemGrid, index)
        local tbItem = self.tbItemList[index];
        local nItemId = tbItem and tbItem.nItemId;
        tbItemGrid:SetItem(nItemId, tbGridParams);
        tbItemGrid.szItemOpt = "InDifferBattle"
        tbItemGrid.fnClick = tbItemGrid.DefaultClick;
        if nItemId then
            self.tbShowItem[nItemId] = tbItemGrid;
        end
    end

    self.ScrollView:Update(math.max(#self.tbItemList, 6) , fnSetItem);    -- 至少显示5行
end

function tbUi:OnSyncItem(nItemId, bUpdateAll)
	if bUpdateAll == 1 then
        self:UpdateItemType();
        self:UpdateItemList();
    else
        if self.tbShowItem[nItemId] and self.tbShowItem[nItemId].nItemId == nItemId then
            self.tbShowItem[nItemId]:SetItem(nItemId, {bShowTip = true})
        end
    end
    self:CheckCanEnhance()
end

function tbUi:CheckCanEnhance()
    local tbDefine = InDifferBattle.tbDefine
    local tbStrengthen = me.GetStrengthen();
    local nHasCount = me.GetItemCountInBags(tbDefine.nEnhanceItemId)
    local bShowArrow = false
    for i,v in ipairs(tbDefine.tbEnhanceScroll) do
        local nEquipPos = v.tbEquipPos[1]
        local nCost = v.tbEnhanceCost[tbStrengthen[nEquipPos + 1] + tbDefine.nStrengthStep]
        if  nCost and  nHasCount >= nCost then
            bShowArrow = true
            break;
        end
    end
    self.BtnStrengthen.pPanel:SetActive("UpgradeFlag", bShowArrow)
end

function tbUi:OnDelItem(nItemId)
	self:UpdateItemType();
    self:UpdateItemList();
    self:CheckCanEnhance()
end

tbUi.tbOnClick = {};

function tbUi.tbOnClick:BtnGive()
    if me.nFightMode == 2 then
        me.CenterMsg("您已阵亡，无法赠送")
        return
    end
	Ui:OpenWindow("DreamlandGivePanel")
end

function tbUi.tbOnClick:BtnLeave()
	RemoteServer.InDifferBattleRequestInst("RequestLeave")
end

function tbUi.tbOnClick:BtnCheck()
    Ui:OpenWindow("DreamlandMapPanel")
    Ui:ClearRedPointNotify("IndifferMapRed")
end

function tbUi.tbOnClick:BtnRole()
    Ui:OpenWindow("DreamlandCheatsPanel")
end

function tbUi.tbOnClick:BtnStrengthen()
    Ui:OpenWindow("DreamlandStrengthenPanel")
end

function tbUi.tbOnClick:BtnBattle()
    Ui:OpenWindow("DreamlandReportPanel")
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_INDIFFER_BATTLE_UI,   self.UpdateMain},
        { UiNotify.emNOTIFY_SYNC_ITEM,			self.OnSyncItem },
        { UiNotify.emNOTIFY_DEL_ITEM,           self.OnDelItem },
		{ UiNotify.emNOTIFY_CHANGE_MONEY,			self.UpdateMain },
    };

    return tbRegEvent;
end
