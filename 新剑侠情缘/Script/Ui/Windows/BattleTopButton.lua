local tbUi = Ui:CreateClass("BattleTopButton")

function tbUi:OnOpenEnd()
    self:CheckRedPoint()
    self:Refresh();
end

function tbUi:CheckRedPoint()
    local tbTopUi = Ui:GetClass("TopButton")
    if tbTopUi then
        tbTopUi:CheckHasCanEquipItem()
    end
end

function tbUi:Refresh()
    local bShowDealButton = false;
    local tbMapSetting = Map:GetMapSetting(me.nMapTemplateId);
    if tbMapSetting and tbMapSetting.UiTopButtonType == Ui.TOPBUTTON_TYPE_DEAL then
        bShowDealButton = true;
    end

    local bShowAuction = bShowDealButton and me.nLevel >= Kin.AuctionDef.nAuctionLevelLimit;
    self.pPanel:SetActive("BtnAuction", bShowAuction);

    local bShowMarketStall = bShowDealButton and me.nLevel >= 20;
    self.pPanel:SetActive("BtnMarketStall", bShowMarketStall);

    if bShowMarketStall then
        MarketStall:UiCheckMarketStallTime(self);
    end
end

function tbUi:OnClose()
    MarketStall:UiCloseMarketStallTime(self);
end

tbUi.tbOnClick = {}
tbUi.tbOnClick.BtnBag = function ()
    Ui:OpenWindow("ItemBox")
end

tbUi.tbOnClick.BtnTopFold = function (self)
    self.BtnTopFoldState = not self.BtnTopFoldState;
    if self.BtnTopFoldState then
        self.pPanel:PlayUiAnimation("HomeScreenButtonRetract", false, false, {});
    else
        self.pPanel:PlayUiAnimation("HomeScreenButtonStretch", false, false, {});
    end
end

tbUi.tbOnClick.BtnMarketStall = function ()
    Ui:OpenWindow("MarketStallPanel");
end

tbUi.tbOnClick.BtnAuction = function ()
    Ui:OpenWindow("AuctionPanel"); 
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_ITEM,		 	self.CheckRedPoint},
		{ UiNotify.emNOTIFY_DEL_ITEM, 			self.CheckRedPoint},
	}
	return tbRegEvent;
end
