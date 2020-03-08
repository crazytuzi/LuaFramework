
local tbUi = Ui:CreateClass("TeamFubenEntrance");

function tbUi:OnOpen(nSectionIdx, nSubSectionIdx)
	self.nSectionIdx = nSectionIdx;
	self.nSubSectionIdx = nSubSectionIdx;
	self:ClearInfo();
	self:Update();
end

function tbUi:ClearInfo()
	self.pPanel:Label_SetText("FubenDesc", "");
	self.pPanel:Label_SetText("FubenName", "出错了");
	self.pPanel:Label_SetText("RecommendEdge", "--");
	self.pPanel:Label_SetText("TimeLimite", "--");
end

function tbUi:Update()
	local tbFubenSetting = TeamFuben:GetFubenSetting(self.nSectionIdx, self.nSubSectionIdx);
	if not tbFubenSetting then
		self:ClearInfo();
		return;
	end

	self.pPanel:Label_SetText("FubenDesc", tbFubenSetting.szFubenDesc);
	self.pPanel:Label_SetText("FubenName", tbFubenSetting.szName);
	self.pPanel:Label_SetText("RecommendEdge", "--");
	self.pPanel:Label_SetText("TimeLimite", "--");

	for i = 1, 6 do
		if i < #tbFubenSetting.tbShowItem then
			self["itemframe" .. i]:SetGenericItem(tbFubenSetting.tbShowItem[i]);
		else
			self["itemframe" .. i]:Clear();
		end
	end
end

tbUi.tbOnClick = {
	BtnBack = function (self)
		Ui:CloseWindow("TeamFubenEntrance");
	end,

	BtnClose = function (self)
		Ui:CloseWindow("TeamFubenEntrance");
	end,
}
