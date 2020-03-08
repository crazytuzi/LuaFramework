local tbUi = Ui:CreateClass("PartnerDecompose");
tbUi.TYPE_PARTNER = 1
tbUi.TYPE_PARTNERCARD = 2
tbUi.tbSetting = 
{
	[tbUi.TYPE_PARTNER] = {
		szTabName = "BtnCompanionSeverance";
		fnUpdate = function (self)
			self:UpdatePartnerList()
		end;
		fnIsTabOpen = function ()
			return true
		end;
		szIntro = "遣散后有可能获得资质丹、洗髓丹、经验药水[c8ff00]资质丹、本命武器全部返还，技能折算成洗髓丹，被遣散的同伴可以在图鉴界面再次招募。[-]";
		szSeveranceTxt = "点击选择左侧列表中的同伴，进行遣散";
	};
	[tbUi.TYPE_PARTNERCARD] = {
		szTabName = "BtnEntourageSeverance";
		fnUpdate = function (self)
			self:UpdatePartnerCardList()
		end;
		fnIsTabOpen = function ()
			return PartnerCard:IsOpen()
		end;
		szIntro = "遣散后有可能获得资质丹、友好度道具。[c8ff00]友好度道具数量根据门客星级进行返还，被遣散的门客可以在图鉴界面再次招揽。[-]";
		szSeveranceTxt = "点击选择左侧列表中的门客，进行遣散";
	};
}

function tbUi:SwitchTab(nTabType)
	self.nTabType = nTabType or self.nTabType
	local tbInfo = self.tbSetting[self.nTabType]
	if not tbInfo then
		return
	end
	
	self.pPanel:Label_SetText("SeveranceAcquisition", tbInfo.szIntro)
	self.pPanel:Label_SetText("SeveranceTxt", tbInfo.szSeveranceTxt)
	for nType, v in pairs(self.tbSetting) do
		 self.pPanel:Toggle_SetChecked(v.szTabName,  nType == self.nTabType);
	end
	tbInfo.fnUpdate(self)
end

function tbUi:Update()
	for _, v in pairs(self.tbSetting) do
		self.pPanel:SetActive(v.szTabName, v.fnIsTabOpen())
	end
	self:SwitchTab(self.TYPE_PARTNER)
end

function tbUi:UpdatePartnerList()
	self.tbSelectInfo = {};
	self:UpdateDecomposeList();
end

function tbUi:OnSelectPartnerCard(nCardId, nLevel)
	if self.tbSelectInfo[nCardId] then
		self.tbSelectInfo[nCardId] = nil
	else
		self.tbSelectInfo[nCardId] = nLevel or 0;
	end
	self:UpdateCardDecomposeList();
end

function tbUi:UpdateCardDecomposeList()
	local tbOwnCard = PartnerCard:GetCanDimissCard()
	local function fnOnSelect(itemObj)
		if not itemObj.nCardId then
			return
		end
		self:OnSelectPartnerCard(itemObj.nCardId, itemObj.nLevel);
	end
	local fnSetItem = function(itemObj, index)
		local tbCardInfo = tbOwnCard[index]
		local nCardId = tbCardInfo.nCardId
		local nLevel = tbCardInfo.nLevel
		itemObj.nCardId = nCardId;
		itemObj.nLevel = nLevel;
		itemObj.pPanel:Label_SetText("Name", tbCardInfo.szName);
		itemObj.pPanel:Label_SetText("Fighting", string.format("战力：%s", tbCardInfo.nFightPower));
		itemObj.pPanel:SetActive("Mark", false);
		itemObj.PartnerHead:SetPartnerById(tbCardInfo.nPartnerTempleteId, nil, tbCardInfo.nFightPower, true);
		itemObj.BtnCheck:SetCheck(self.tbSelectInfo[nCardId] and true or false);
		itemObj.pPanel:Sprite_SetSprite("Main", self.tbSelectInfo[nCardId] and "BtnListThirdPress" or "BtnListThirdNormal");
		itemObj.BtnCheck.pPanel:SetActive("GuideTips", false);
		itemObj.BtnCheck.nCardId = nCardId;
		itemObj.BtnCheck.nLevel = nLevel;
		itemObj.BtnCheck.pPanel.OnTouchEvent = fnOnSelect;
		itemObj.pPanel.OnTouchEvent = fnOnSelect;
		itemObj.pPanel:SetActive("Star", true);
		itemObj["PartnerHead"].pPanel:SetActive("GrowthLevel", false);
		Ui:GetClass("PartnerCardItem"):SetLevel(itemObj, nLevel)
	end;
	self.PartnerListScrollView2:Update(tbOwnCard, fnSetItem);
end

function tbUi:UpdatePartnerCardList()
	self.tbSelectInfo = {};
	self:UpdateCardDecomposeList()
end

function tbUi:UpdateDecomposeList()
	self.tbPartnerList, self.tbAllPartner = Partner:GetSortedPartnerList(me);
	for i = #self.tbPartnerList, 1, -1 do
		local tbPartner = self.tbAllPartner[self.tbPartnerList[i]];
		if tbPartner.nPos then
			table.remove(self.tbPartnerList, i);
		end
	end

	self.tbSelectInfo = self.tbSelectInfo or {};

	local function fnOnSelect(itemObj)
		if Ui.bShowDebugInfo then
			local tbPartnerInfo = self.tbAllPartner[itemObj.nPartnerId]
			if tbPartnerInfo then
				Ui:SetDebugInfo("TemplateId: " .. tbPartnerInfo.nTemplateId);
			end
		end
		self:OnSelectPartner(itemObj.nPartnerId);
	end

	local fnSetItem = function(itemObj, index)
		local nPartnerId = self.tbPartnerList[index];
		local tbPartner = self.tbAllPartner[nPartnerId];

		itemObj.pPanel:SetActive("Star", false);
		itemObj.pPanel:SetActive("Star", false);
		itemObj.nPartnerId = nPartnerId;
		itemObj.PartnerHead:SetPartnerInfo(tbPartner);
		itemObj.pPanel:Label_SetText("Name", tbPartner.szName);
		itemObj.pPanel:Label_SetText("Fighting", string.format("战力：%s", tbPartner.nFightPower));
		itemObj.pPanel:SetActive("Mark", tbPartner.nIsNormal == 0);

		itemObj.pPanel:Sprite_SetSprite("Main", self.tbSelectInfo[nPartnerId] and "BtnListThirdPress" or "BtnListThirdNormal");
		itemObj.BtnCheck.pPanel:SetActive("GuideTips", false);
		itemObj.BtnCheck.nPartnerId = nPartnerId;
		itemObj.BtnCheck:SetCheck(self.tbSelectInfo[nPartnerId] and true or false);
		itemObj.BtnCheck.pPanel.OnTouchEvent = fnOnSelect;
		itemObj.pPanel.OnTouchEvent = fnOnSelect;
	end

	self.PartnerListScrollView2:Update(self.tbPartnerList, fnSetItem);
end

function tbUi:OnSelectPartner(nPartnerId)
	if self.tbSelectInfo[nPartnerId] then
		self.tbSelectInfo[nPartnerId] = nil
	else
		self.tbSelectInfo[nPartnerId] = true;
	end
	self:UpdateDecomposeList();
end

function tbUi:OnDeletePartner(nPartnerId)
	self:Update();
end

tbUi.tbOnClick = {};
tbUi.tbOnClick.BtnDoDecompose = function (self)
	if self.nTabType == self.TYPE_PARTNER then
		if not self.tbSelectInfo or Lib:CountTB(self.tbSelectInfo) <= 0 then
			me.CenterMsg("当前没有同伴");
			return;
		end

		local bRet, szMsg = Partner:CheckCanDecomposePartner(me, self.tbSelectInfo);
		if not bRet then
			me.CenterMsg(szMsg);
			return;
		end

		local bNeedNote = false;
		for nPartnerId in pairs(self.tbSelectInfo) do
			local tbPartner = me.GetPartnerInfo(nPartnerId);
			if tbPartner.nLevel > 1 or tbPartner.nQualityLevel <= 3 then
				bNeedNote = true;
				break;
			end
		end

		if bNeedNote then
			me.MsgBox(string.format("当前选中同伴含有[FFFE0D]甲级[-]以上或[FFFE0D]等级大于1级[-]，是否要遣散？\n[FFFE0D]（遣散后的同伴将会消失）[-]"),
				{
					{"确认", function () RemoteServer.CallPartnerFunc("DecomposePartner", self.tbSelectInfo); end },
					{"取消"}
				});
		else
			RemoteServer.CallPartnerFunc("DecomposePartner", self.tbSelectInfo);
		end
	elseif self.nTabType == self.TYPE_PARTNERCARD then

		local bNeedNote = false;
		for nCardId, nLevel in pairs(self.tbSelectInfo) do
			local nQualityLevel = PartnerCard:GetQualityByCardId(nCardId)
			if nLevel > 1 or (nQualityLevel >= 1 and nQualityLevel <= 3) then
				bNeedNote = true;
				break;
			end
		end

		if bNeedNote then
			me.MsgBox(string.format("当前选中门客含有[FFFE0D]甲级[-]以上或[FFFE0D]等级大于1级[-]，是否要遣散？\n[FFFE0D]（遣散后的门客将会消失）[-]"),
				{
					{"确认", function () RemoteServer.PartnerCardOnClientCall("DismissCardBatch", self.tbSelectInfo); end },
					{"取消"}
				});
		else
			RemoteServer.PartnerCardOnClientCall("DismissCardBatch", self.tbSelectInfo)
		end
	end
end

tbUi.tbOnClick.BtnCompanionSeverance = function (self)
	self:SwitchTab(self.TYPE_PARTNER)
end
tbUi.tbOnClick.BtnEntourageSeverance = function (self)
	self:SwitchTab(self.TYPE_PARTNERCARD)
end

