local tbRefineNotice = Ui:CreateClass("RefineNotice");

local SHOW_HINT_TIME = 3 --显示强化、镶嵌成功提示的持续时间

function tbRefineNotice:OnOpen(szOrgDesc, szCurDesc, nOrgLevel, nCurLevel, nEquipLevel, nItemType)
    local bHasOrg = szOrgDesc ~= nil;
    self.pPanel:SetActive("TxtNone", not bHasOrg);
    self.pPanel:SetActive("TxtAttribOrg", bHasOrg);
    self.pPanel:Label_SetText("TxtAttribOrg", szOrgDesc or "");
    self.pPanel:Label_SetText("TxtAttribCur", szCurDesc);
    local nSrcQuality = Item.tbRefinement:GetAttribColor(nEquipLevel, nOrgLevel or 1, nItemType);
    local nTarQuality = Item.tbRefinement:GetAttribColor(nEquipLevel, nCurLevel or 1, nItemType);
    local szSrcColor = Item:GetQualityColor(nSrcQuality)
    local szTarColor = Item:GetQualityColor(nTarQuality)
    self.pPanel:Label_SetGradientColor("TxtAttribOrg", szSrcColor);
    self.pPanel:Label_SetGradientColor("TxtAttribCur", szTarColor);
end

tbRefineNotice.tbOnClick = 
{
    BtnOK = function (self)
        Ui:CloseWindow(self.UI_NAME);
    end,
}