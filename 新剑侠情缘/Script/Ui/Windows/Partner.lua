local tbPartnerListItem = Ui:CreateClass("PartnerSelect");
local tbUi = Ui:CreateClass("Partner");

tbUi.MAIN_PANEL = "PartnerMainPanel";
tbUi.GRALLERY_PANEL = "PartnerGralleryPanel";
tbUi.DECOMPOSE_PANEL = "PartnerDecomposePanel";
tbUi.CARDPICKING_PANEL = "CardPickingPanel";
tbUi.PARTNER_CARD_PANEL = "PartnerCardPanel";

tbUi.tbAllPanel = {

}

tbUi.tbTitleInfo =
{
	[tbUi.MAIN_PANEL] = "同伴";
	[tbUi.GRALLERY_PANEL] = "图鉴";
	[tbUi.DECOMPOSE_PANEL] = "遣散";
	[tbUi.CARDPICKING_PANEL] = "招募";
	[tbUi.PARTNER_CARD_PANEL] = "门客";
}

tbUi.tbHelpInfo =
{
	[tbUi.PARTNER_CARD_PANEL] = "PartnerCardHelp";
}

local tbToggleButton =
{
	BtnCompanion = 1,
	BtnGrallery = 2,
	BtnDecompose = 3,
	BtnCardPicking = 4,
	BtnPartnerCard = 5,
}

function Partner:SetFace(tbObj, szChildName, nNpcTemplateId)
	local nFaceId = KNpc.GetNpcShowInfo(nNpcTemplateId);
	local szAtlas, szSprite = Npc:GetFace(nFaceId);
	tbObj.pPanel:Sprite_SetSprite(szChildName, szSprite, szAtlas);
end

function tbUi:OnOpen()
    local pNpc = me.GetNpc();
    if pNpc.nShapeShiftNpcTID > 0 then
    	me.CenterMsg("变身状态时不能操作", true);
        return 0;
    end

end

function tbUi:OnOpenEnd(szPageType, szSubType)
	self.szPageType = szPageType or self.MAIN_PANEL;

	self.PartnerMainPanel.pPanel:NpcView_Open("PartnerView");

	self.pPanel:SetActive("BtnCardPicking", me.nLevel >= CardPicker.Def.OpenLevel);
	self.pPanel:SetActive("BtnDecompose", me.nLevel >= CardPicker.Def.OpenLevel);
	self.pPanel:SetActive("BtnGrallery", me.nLevel >= CardPicker.Def.OpenLevel);
	self.pPanel:SetActive("BtnPartnerCard", PartnerCard:IsOpen());

	self:Update(self.szPageType, szSubType);
	RemoteServer.CallPartnerFunc("CheckReinitResult", true);
	RemoteServer.PartnerCardOnClientCall("SynCardHouseData")
	PartnerCard:CheckPartnerCardPanelRedPoint()
end

function tbUi:OnClose()
	self.PartnerMainPanel.pPanel:NpcView_Close("PartnerView");
	self.CardPickingPanel:OnClose();
	self.PartnerCardPanel:OnClose();
	Partner:UpdateRedPoint();
	Ui:CloseWindow("SkillShow");

	self.PartnerMainPanel:DoSyncPartnerPos();
	RemoteServer.CallPartnerFunc("SetPartnerPos", self.PartnerMainPanel.tbPosInfo);
	RemoteServer.ConfirmPartnerPos();
	Partner:CloseOtherUi();
	Ui:SetDebugInfo("");
	Ui.UiManager.DisableDragSprite()
end

function tbUi:Update(szMainType, szSubType)
	self.szPageType = szMainType or self.szPageType;

	Partner:CloseOtherUi();
	local szUpdateFunc = self.szPageType .. "Update";
	if not self[szUpdateFunc] then
		self.szPageType = self.MAIN_PANEL;
	end

	self.pPanel:Label_SetText("Title", self.tbTitleInfo[self.szPageType] or "同伴");
	self.pPanel:SetActive(self.MAIN_PANEL, false);
	self.pPanel:SetActive(self.GRALLERY_PANEL, false);
	self.pPanel:SetActive(self.DECOMPOSE_PANEL, false);
	self.pPanel:SetActive(self.CARDPICKING_PANEL, false);
	self.pPanel:SetActive(self.PARTNER_CARD_PANEL, false);

	self:SelectPageShow("BtnCompanion");

	self.PartnerMainPanel.pPanel:NpcView_ShowNpc("PartnerView", 0);
	self.PartnerMainPanel.pPanel:NpcView_Close("PartnerView");

	self[szUpdateFunc](self, szSubType);
	if szSubType ~= self.MAIN_PANEL then
		self.PartnerMainPanel:DoSyncPartnerPos();
	end
	local bPartnerCardOpen = PartnerCard:IsOpen()
	if not bPartnerCardOpen then
		self.pPanel:SetActive(self.PARTNER_CARD_PANEL, false);
	end
end

function tbUi:CloseAll()

end

function tbUi:CardPickingPanelUpdate()
	self:SelectPageShow("BtnCardPicking");
	self.pPanel:SetActive(self.CARDPICKING_PANEL, true);
	self.CardPickingPanel:Init();
end

function tbUi:PartnerMainPanelUpdate(szSubType)
	self:SelectPageShow("BtnCompanion");
	self.pPanel:SetActive(self.MAIN_PANEL, true);
	self.PartnerMainPanel.pPanel:NpcView_Open("PartnerView");
	self.PartnerMainPanel.pPanel:NpcView_ShowNpc("PartnerView", 0);
	self.PartnerMainPanel:Update(szSubType);
end

function tbUi:PartnerGralleryPanelUpdate()
	self:SelectPageShow("BtnGrallery");
	self.pPanel:SetActive(self.GRALLERY_PANEL, true);
	self.PartnerGralleryPanel:Update();
end

function tbUi:PartnerDecomposePanelUpdate()
	self:SelectPageShow("BtnDecompose");
	self.pPanel:SetActive(self.DECOMPOSE_PANEL, true);
	self.PartnerDecomposePanel:Update();
end

function tbUi:PartnerCardPanelUpdate()
	self:SelectPageShow("BtnPartnerCard");
	self.pPanel:SetActive(self.PARTNER_CARD_PANEL, true);
	self.PartnerCardPanel:Update(nil, true);
end

function tbUi:OnAddPartner(nPartnerId)
end

function tbUi:OnDeletePartner(nPartnerId)
	if self.pPanel:IsActive(self.DECOMPOSE_PANEL) then
		self.PartnerDecomposePanel:OnDeletePartner(nPartnerId);
	end
end

function tbUi:OnUpdatePartner(nPartnerId)
	if self.pPanel:IsActive(self.MAIN_PANEL) then
		self.PartnerMainPanel:OnUpdatePartner(nPartnerId);
	end
end

function tbUi:OnAwareness(nPartnerId)
	if self.pPanel:IsActive(self.MAIN_PANEL) then
		self.PartnerMainPanel:UpdatePartnerList();
	end
end

function tbUi:OnSyncItem(nItemId, bUpdateAll)
	if self.pPanel:IsActive(self.MAIN_PANEL) then
		self.PartnerMainPanel:OnSyncItem(nItemId, bUpdateAll);
	end
end

function tbUi:OnSyncPartnerPos()
	if self.pPanel:IsActive(self.MAIN_PANEL) then
		self.PartnerMainPanel:UpdatePartnerPosInfo();
	end
	if self.pPanel:IsActive(self.PARTNER_CARD_PANEL) then
		self.PartnerCardPanel:Update();
	end
end

function tbUi:SelectPageShow(szBtnName)
    for szName, _ in pairs(tbToggleButton) do
    	self.pPanel:Toggle_SetChecked(szName, szBtnName == szName);
    end
end

function tbUi:CardPickingUpdate()
	self.CardPickingPanel:Update()
end

function tbUi:OnNotifyReinitData(bHasData)
	self.PartnerMainPanel.bHasReinitData = bHasData;
	self.PartnerMainPanel.pPanel:Label_SetText("TxtSeverance", bHasData and "洗髓结果" or "洗髓");
end

function tbUi:OnPartnerGradeLevelup(nPartnerId, nOldGradeLevel, nNewGradeLevel)
	if self.pPanel:IsActive(self.MAIN_PANEL) then
		self.PartnerMainPanel:OnPartnerGradeLevelup(nPartnerId, nOldGradeLevel, nNewGradeLevel);
	end
end

function tbUi:OnPartnerCardUpGrade()
	if self.pPanel:IsActive(self.PARTNER_CARD_PANEL) then
		self.PartnerCardPanel:Update();
	end
end

function tbUi:OnPartnerCardUpPos()
	if self.pPanel:IsActive(self.PARTNER_CARD_PANEL) then
		self.PartnerCardPanel:Update();
	end
end

function tbUi:OnPartnerCardDownPos()
	if self.pPanel:IsActive(self.PARTNER_CARD_PANEL) then
		self.PartnerCardPanel:Update();
	end
end

function tbUi:OnPartnerCardChangeExp()
	if self.pPanel:IsActive(self.PARTNER_CARD_PANEL) then
		self.PartnerCardPanel:Update();
	end
end

function tbUi:OnPartnerCardDismissCard()
	if self.pPanel:IsActive(self.PARTNER_CARD_PANEL) then
		self.PartnerCardPanel:Update(nil, true);
	end
	if self.pPanel:IsActive(self.DECOMPOSE_PANEL) then
		self.PartnerDecomposePanel:SwitchTab();
	end
end

function tbUi:OnPartnerCardAdd()
	self.PartnerGralleryPanel:Update();
end

function tbUi:OnPartnerCardPosUnlock()
	if self.pPanel:IsActive(self.PARTNER_CARD_PANEL) then
		self.PartnerCardPanel:Update();
	end
end

function tbUi:OnPartnerCardPickDataUpdate()
	if self.pPanel:IsActive(self.CARDPICKING_PANEL) then
		self.CardPickingPanel:Update();
	end
end

function tbUi:OnPartnerCardDataChange(nCardId)
	self.PartnerCardPanel:Update(nCardId);
end

function tbUi:OnRefreshPartnerGrallery(nQualityLevel)
	self.PartnerGralleryPanel:Update(nQualityLevel);
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_PARTNER_POS,		self.OnSyncPartnerPos },
		{ UiNotify.emNOTIFY_SYNC_PARTNER_ADD,		self.OnAddPartner},
		{ UiNotify.emNOTIFY_SYNC_PARTNER_UPDATE,	self.OnUpdatePartner},
		{ UiNotify.emNOTIFY_SYNC_PARTNER_DELETE,	self.OnDeletePartner},
		{ UiNotify.emNOTIFY_PG_PARTNER_AWARENESS,	self.OnAwareness},
		{ UiNotify.emNOTIFY_CARD_PICKING,			self.CardPickingUpdate},
		{ UiNotify.emNOTIFY_SYNC_ITEM,				self.OnSyncItem},
		{ UiNotify.emNOTIFY_DEL_ITEM,				self.OnSyncItem},
		{ UiNotify.emNOTIFY_PARTNER_REINITDATA,		self.OnNotifyReinitData},
		{ UiNotify.emNOTIFY_PARTNER_GRADE_LEVELUP,	self.OnPartnerGradeLevelup},
		{ UiNotify.emNOTIFY_PARTNER_CARD_UP_GRADE,	self.OnPartnerCardUpGrade},
		{ UiNotify.emNOTIFY_PARTNER_CARD_POS_UNLOCK,	self.OnPartnerCardPosUnlock},
		{ UiNotify.emNOTIFY_PARTNER_CARD_UP_POS,	self.OnPartnerCardUpPos},
		{ UiNotify.emNOTIFY_PARTNER_CARD_DWON_POS,	self.OnPartnerCardDownPos},
		{ UiNotify.emNOTIFY_PARTNERCARD_CHANGE_EXP,	self.OnPartnerCardChangeExp},
		{ UiNotify.emNOTIFY_PARTNER_CARD_DISMISS_CARD,	self.OnPartnerCardDismissCard, self},
		{ UiNotify.emNOTIFY_PARTNER_CARD_SYN_PICK_DATA,	self.OnPartnerCardPickDataUpdate},
		{ UiNotify.emNOTIFY_PARTNER_CARD_DATA_CHANGE,	self.OnPartnerCardDataChange},
		{ UiNotify.emNOTIFY_PARTNER_CARD_ADD,	self.OnPartnerCardAdd},
		{ UiNotify.emNOTIFY_REFRESH_PARTNER_GRALLERY,	self.OnRefreshPartnerGrallery},
	};

	return tbRegEvent;
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow("Partner");
end

tbUi.tbOnClick.BtnCompanion = function (self)
	self:Update(self.MAIN_PANEL);
end

tbUi.tbOnClick.BtnGrallery = function (self)
	self:Update(self.GRALLERY_PANEL);
	PartnerCard:CheckPartnerGralleryGuide()
end

tbUi.tbOnClick.BtnDecompose = function (self)
	self:Update(self.DECOMPOSE_PANEL);
end

tbUi.tbOnClick.BtnCardPicking = function (self)
	self:Update(self.CARDPICKING_PANEL);
end

tbUi.tbOnClick.BtnPartnerCard = function (self)
	self:Update(self.PARTNER_CARD_PANEL);
	Guide.tbNotifyGuide:ClearNotifyGuide("PartnerCardTab")
end

tbUi.tbOnClick.BtnInfo = function (self)
	local szHelpKey = self.tbHelpInfo[self.szPageType] or "PartnerHelp"
	Ui:OpenWindow("GeneralHelpPanel", szHelpKey)
end


