
local tbUi = Ui:CreateClass("PartnerItemInfo")

function tbUi:Clear(tbResult)
	self.nItemId = nil;
	self.nType = nil;
	self.tbResult = tbResult or {};

	self.tbResult.nCurCount = 0;
	self.nMaxCount = 0;
	self.nSpace = 0;

	self.pPanel:SetActive("BtnReduce", false);
	self.pPanel:Label_SetText("CurCount", "");
	self.itemframe:Clear();
end

function tbUi:Update()
	self.nMaxCount = self.nMaxCount or 0;
	self.tbResult.nCurCount = self.tbResult.nCurCount or 0;

	if self.nItemId then
		self.itemframe:SetItem(self.nItemId);
		self.itemframe.pPanel:SetActive("LabelSuffix", false);
	elseif self.nType then
		self.itemframe:Clear();
		local szAtlas, szSprite = Partner:GetStoneIcon(self.nType);
		if szAtlas then
			self.itemframe.pPanel:SetActive("ItemLayer", true);
			self.itemframe.pPanel:Sprite_SetSprite("ItemLayer", szSprite, szAtlas);
		else
			self:Clear();
			return;
		end
	else
		self:Clear();
		return;
	end

	self.pPanel:SetActive("BtnReduce", self.tbResult.nCurCount > 0);
	self.pPanel:Label_SetText("CurCount", string.format("%s/%s", self.tbResult.nCurCount, self.nMaxCount));
end

function tbUi:SetValue(tbInfo, tbResult, fnOnChange)
	self:Clear(tbResult);
	self.fnOnChange = fnOnChange;
	self.tbResult.tbValue = tbInfo;
	self.nSpace = 1;
	if tbInfo.szType == "PartnerStone" then
		self.nType = tbInfo[1];
		self.nMaxCount = tbInfo[2];
		self.nSpace = 10;
	else
		self.nItemId = tbInfo[1];
		self.nMaxCount = tbInfo[2];
	end

	self:Update();
end

tbUi.tbOnClick = {};
tbUi.tbOnClick.BtnReduce = function (self)
	self.tbResult.nCurCount = math.max(self.tbResult.nCurCount - self.nSpace, 0);
	self:Update();
	if self.fnOnChange then
		self.fnOnChange();
	end
end

tbUi.tbOnClick.BtnAdd = function (self)
	self.nMaxCount = self.nMaxCount or 0;
	self.tbResult.nCurCount = math.min(self.tbResult.nCurCount + self.nSpace, self.nMaxCount);
	self:Update();
	if self.fnOnChange then
		self.fnOnChange();
	end
end
