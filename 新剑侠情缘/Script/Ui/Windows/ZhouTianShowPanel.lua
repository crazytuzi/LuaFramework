local tbUi = Ui:CreateClass("ZhouTianShowPanel");
tbUi.BG_ITEM_MINI_HEIGHT = 100;
tbUi.BG_ITEM_WEIDHT = 500;
tbUi.LA_ITEM_MINI_HEIGHT = 40;
tbUi.LA_ITEM_WEIDHT = 496;
tbUi.tbPanelPos = {155.3, 140};
function tbUi:OnOpen(nJingMaiId, nLevel)
	self:Update(nJingMaiId, nLevel)
end

function tbUi:Update(nJingMaiId, nLevel)
	nLevel = nLevel or 0
	if not JingMai.tbJingMaiSetting[nJingMaiId] or nLevel <= 0 then
		return 
	end
	
	self.pPanel:SetActive("BtnLevelUp", false)
	local szName = JingMai:GetJingMaiLevelName(nJingMaiId) or ""
	local nMaxLevel = JingMai:GetMaxJingMaiLevel(nJingMaiId) or 0

	self.pPanel:Label_SetText("SkillName", szName)
	self.pPanel:Label_SetText("TxtLevel", string.format("%s/%s", nLevel or 0, nMaxLevel))
	local tbAttrib = JingMai:GetXueWeiAddInfo(nil, nJingMaiId, nLevel);
	local szDsc, nLine = JingMai:GetXueWeiAttribDesc(JingMai:GetAttribInfo(tbAttrib.tbExtAttrib));
	local szContent = nLine > 0 and "[FFFE0D]护主：[-]\n" .. szDsc or "[FFFE0D]护主：[-]";
	szDsc, nLine = JingMai:GetXueWeiAttribDesc(JingMai:GetAttribInfo(tbAttrib.tbExtPartnerAttrib));
	szContent = szContent ..(nLine > 0 and "\n[FFFE0D]同伴：[-]\n" .. szDsc or "\n[FFFE0D]同伴：[-]")
	self.pPanel:Label_SetText("AttackDamage1", szContent);

	local fSizeY = 0;
    local LabelSize = self.pPanel:Label_GetSize("AttackDamage1");
    fSizeY = fSizeY + LabelSize.y;
    self.pPanel:ChangePosition("PanelPos", self.tbPanelPos[1], self.tbPanelPos[2]);
    self.pPanel:Widget_SetSize("Bg", self.BG_ITEM_WEIDHT, self.BG_ITEM_MINI_HEIGHT + fSizeY);
    self.pPanel:Widget_SetSize("LabelBg", self.LA_ITEM_WEIDHT, self.LA_ITEM_MINI_HEIGHT + fSizeY);
end

function tbUi:OnScreenClick()
	Ui:CloseWindow("ZhouTianShowPanel");
end