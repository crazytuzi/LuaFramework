local tbUi = Ui:CreateClass("CompanionShow");

tbUi.tbShowCompanion = tbUi.tbShowCompanion or {};
tbUi.tbLowLevelCompanion = tbUi.tbLowLevelCompanion or {};
tbUi.tbHighLevelCompanion = tbUi.tbHighLevelCompanion or {};
tbUi.tbShowPartnerCard = tbUi.tbShowPartnerCard or {}

function tbUi:RegisterEvent()
    return
    {
        {UiNotify.emNOTIFY_LOAD_RES_FINISH,self.ControlsPlay},
        {UiNotify.emNOTIFY_WND_OPENED, self.WndOpened, self},
        {UiNotify.emNOTIFY_WND_CLOSED, self.WndClosed, self},
        { UiNotify.emNOTIFY_PLAT_SHARE_RESULT, self.OnShareResult, self},
    };
end

function tbUi:OnShareResult(bSucc, szShareType)
	if bSucc and szShareType == "WXMo" then
	    self.szOpenShareTag = "ForbidWXMo";
	end
end

function tbUi:WndOpened(szUiName)
    if szUiName == "SharePanel" then
        self.pPanel:SetActive("BtnShowOff", false);
        self.pPanel:SetActive("BtnSure", false);
    end
end

function tbUi:WndClosed(szUiName)
    if szUiName == "SharePanel" then
        self.pPanel:SetActive("BtnShowOff", true);
        self.pPanel:SetActive("BtnSure", true);
    end
end

function tbUi:OnOpen(nPartnerId, nType, nCardId)
	self.szOpenShareTag = nil;
	self.nType = 0;
	self.nPartnerId = nPartnerId;
	self.nType = nType;
	self.nCardId = nCardId;

	self.pPanel:SetActive("Code", false);

	if nCardId then
		self.pPanel:SetActive("BtnShowOff", false);
		self.pPanel:SetActive("Mark", true);
		self.pPanel:Sprite_SetSprite("Mark", "Quality_Guest")
		local tbCardInfo = PartnerCard:GetCardInfo(nCardId)
		if tbCardInfo then
			self.pPanel:NpcView_Open("PartnerView");
			self.pPanel:NpcView_SetScale("PartnerView", 0.8)
			local nNpcTemplateId = tbCardInfo.nNpcTempleteId
			self.nTimer =Timer:Register(Env.GAME_FPS * 1, self.ShowCompanion,self, nNpcTemplateId);
			self.pPanel:Label_SetText("Name", tbCardInfo.szName);
			self.pPanel:Label_SetText("TitleLaber", "恭喜您获得新门客" .. tbCardInfo.szName);
			local _, nQualityLevel = GetOnePartnerBaseInfo(tbCardInfo.nPartnerTempleteId); 
			self.pPanel:Sprite_SetSprite("QualityLevel", Partner.tbQualityLevelToSpr[nQualityLevel] or "");
		end
	else
		local tbPartnerInfo = me.GetPartnerInfo(self.nPartnerId);
		self.pPanel:NpcView_Open("PartnerView");
		self.pPanel:NpcView_SetScale("PartnerView", 0.8)
		self.pPanel:SetActive("Mark", not nCardId and tbPartnerInfo.nIsNormal == 0);
		self.pPanel:Sprite_SetSprite("Mark", "Quality_Special")
		self.nTimer =Timer:Register(Env.GAME_FPS * 1, self.ShowCompanion,self, tbPartnerInfo.nNpcTemplateId);
		self.pPanel:Label_SetText("Name", tbPartnerInfo.szName);
		self.pPanel:Label_SetText("TitleLaber", "恭喜您获得新同伴" .. tbPartnerInfo.szName);
		self.pPanel:Sprite_SetSprite("QualityLevel", Partner.tbQualityLevelToSpr[tbPartnerInfo.nQualityLevel]);
		if Sdk:CanShowOffShare() then
			self.pPanel:SetActive("BtnShowOff", not Client:IsCloseIOSEntry());
		else
			self.pPanel:SetActive("BtnShowOff", false);
		end
	end
	self:Update();
end

function tbUi:ShowCompanion(nNpcTemplateId)
	local _, nResId = KNpc.GetNpcShowInfo(nNpcTemplateId);
	self.pPanel:NpcView_ShowNpc("PartnerView", nResId);
	self.pPanel:NpcView_SetWeaponState("PartnerView", 0);
	self.nTimer = nil;
end

function tbUi:ControlsPlay()
	self.pPanel:NpcView_PlayAnimation("PartnerView", "at01", 0.1, false);
	Timer:Register(5, function ()
		self.pPanel:NpcView_PlayAnimation("PartnerView", "sta", 0, true);
	end);
end

function tbUi:Update()

end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnSure()
	self.pPanel:NpcView_ShowNpc("PartnerView", 0);
	self.pPanel:NpcView_Close("PartnerView");

	Ui:CloseWindow("CompanionShow");
	self:CloseTimer();
	if self.nType == 0 then
		if #self.tbShowCompanion > 0 then
			table.remove(self.tbShowCompanion,1);
			Ui:CloseCompanion(self.tbShowCompanion,0);
		end
	end
	if self.nType == 1 then
		if #self.tbLowLevelCompanion > 0 then
			table.remove(self.tbLowLevelCompanion,1);
			Ui:CloseCompanion(self.tbLowLevelCompanion,self.nType);
		end
	end
	if self.nType == 2 then
		if Ui:WindowVisible("CardPickingResult") == 1 and Ui:GetClass("CardPickingResult").bClose == true then
			Ui:CloseWindow("CardPickingResult");
		end
	end
	if self.nType == 3 or self.nType == 4 then
		if #self.tbShowPartnerCard > 0 then
			for i = #self.tbShowPartnerCard, 1, -1 do
				if self.tbShowPartnerCard[i] == self.nCardId then
					table.remove(self.tbShowPartnerCard, i)
					break
				end
			end
			if self.nType == 3 then
				if Ui:WindowVisible("CardPickingResult") == 1 and Ui:GetClass("CardPickingResult").bClose == true then
					Ui:CloseWindow("CardPickingResult");
				end
			elseif self.nType == 4 then
				Ui:CloseCardCompanion(self.tbShowPartnerCard,self.nType);
			end
			
		end
	end
end

function tbUi.tbOnClick:BtnShowOff()
	local tbPartnerInfo = me.GetPartnerInfo(self.nPartnerId or 0) or {};
	Ui:OpenWindow("SharePanel", "Companion", self.szOpenShareTag, "Companion", tbPartnerInfo.nNpcTemplateId);
end

tbUi.tbOnDrag = {}
tbUi.tbOnDrag =
{
	PartnerView = function (self, szWnd, nX, nY)
		self.pPanel:NpcView_ChangeDir("PartnerView", -nX, true)
	end,
}

function tbUi:CloseTimer()
    if self.nTimer then
        Timer:Close(self.nTimer);
        self.nTimer = nil;
    end
end
