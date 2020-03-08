
local tbUi = Ui:CreateClass("FubenItem");

function tbUi:OnOpen()
	self.nSectionIdx = 0;
	self.nFubenLevel = 0;
	self.nSubSectionIdx = 0;
	self.pPanel:Label_SetText("Fubenname", "--");
end

tbUi.tbOnClick = {};
tbUi.tbOnClick.BtnSelect = function (self)
	Ui:SwitchWindow("PersonalFubenEntrance", self.nSectionIdx, self.nFubenLevel, self.nSubSectionIdx);
	Ui:CloseWindow("FubenMapPanel");
end

function tbUi:Update(bIsFirst)
	if not self.tbSectionInfo then
		self.pPanel:SetActive("Main", false);
		return;
	end
	
	if bIsFirst then
		Timer:Register(1, function() self.pPanel:Button_SetSprite("BtnSelect", self.tbSectionInfo.szUiTypeName, 0) end);
	else
		self.pPanel:Button_SetSprite("BtnSelect", self.tbSectionInfo.szUiTypeName, 0);
	end

	self.pPanel:Label_SetText("Fubenname", string.format("%d_%d %s", self.nSectionIdx, self.nSubSectionIdx, self.tbSectionInfo.szTitle));

	local nStarLevel = PersonalFuben:GetFubenStarLevel(me, self.nSectionIdx, self.nSubSectionIdx, self.nFubenLevel) or 0;
	for i = 1, 3 do
		local szSprite = "star_n";
		if i <= nStarLevel then
			szSprite = "star_y";
		end

		self.pPanel:Sprite_SetSprite("star_" .. i, szSprite);
	end

	--self.pPanel:ChangePosition("Main", self.tbSectionInfo.nUiPosX, self.tbSectionInfo.nUiPosY);

	local bCanShowItem = PersonalFuben:CanCreateFubenCommon(me, self.nSectionIdx, self.nSubSectionIdx, self.nFubenLevel);
	self.pPanel:SetActive("Main", bCanShowItem);
end

function tbUi:SetData(nSectionIdx, nFubenLevel, nSubSectionIdx, tbSectionInfo, bIsFirst)
	self.nSectionIdx = nSectionIdx;
	self.nFubenLevel = nFubenLevel;
	self.nSubSectionIdx = nSubSectionIdx;
	self.tbSectionInfo = tbSectionInfo;
	self:Update(bIsFirst);
end