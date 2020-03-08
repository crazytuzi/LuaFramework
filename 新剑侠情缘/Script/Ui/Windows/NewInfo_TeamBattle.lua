
local tbNewInfoUi = Ui:CreateClass("NewInfo_TeamBattle");

tbNewInfoUi.tbTitleSetting = {
	TeamBattle = {
		[TeamBattle.TYPE_MONTHLY]  	 = { 1, "月度通天塔优胜豪侠" };
		[TeamBattle.TYPE_QUARTERLY]  = { 2, "季度通天塔优胜豪侠" };
		[TeamBattle.TYPE_YEAR]  = { 3, "年度通天塔优胜豪侠" };
	};
	InDifferBattle = {
		Month 	= { 1, "月度心魔幻境优胜豪侠" };
		Season 	= { 2, "季度心魔幻境优胜豪侠" };
		Year 	= { 3, "年度心魔幻境优胜豪侠" };
	};
	QYHCROSS = {
		[QunYingHuiCross.TYPE_NORMAL]  	 = { 1, "群英会精锐豪侠" };
	}

}

tbNewInfoUi.tbLabelSetting = 
{
	Default = {Label = "门派", Label1 = "名字", Label2 = "家族", Label3 = "等级", Label4 = "战力"};
	QYHCROSS = {Label = "所选门派", Label3 = "胜率", Label4 = "时间"};
}
function tbNewInfoUi:OnOpen(tbDataAll)
	self:Update(tbDataAll);
end


function tbNewInfoUi:Update(tbDataAll)
	local tbDefaultLabel = self.tbLabelSetting.Default
	for szLabelName, szLabel in pairs(tbDefaultLabel) do
		self.pPanel:Label_SetText(szLabelName, szLabel)
	end
	local tbDefineLabel = self.tbLabelSetting[tbDataAll.Type1]
	if tbDefineLabel then
		for szLabelName, szLabel in pairs(tbDefineLabel) do
			self.pPanel:Label_SetText(szLabelName, szLabel)
		end
	end
	local tbTitleSet = self.tbTitleSetting[tbDataAll.Type1][tbDataAll.Type2]
	local nIndex, szTitle = unpack(tbTitleSet)
	for i=1,3 do
		self.pPanel:SetActive("StarTowerTitle" .. i, i == nIndex)
	end
	self.pPanel:Label_SetText("Txt" .. nIndex, szTitle)
	local tbData = tbDataAll.tbList
	local function fnSetItem(itemObj, i)
		local tbInfo = tbData[i];
		itemObj.pPanel:Label_SetText("Name", tbInfo.szName);
		itemObj.pPanel:Label_SetText("Fight", tbInfo.nFightPower);
		itemObj.pPanel:Label_SetText("Level", tbInfo.nLevel);
		itemObj.pPanel:Label_SetText("FamilyName", tbInfo.szKinName);

		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbInfo.nHonorLevel)
		if ImgPrefix then
			itemObj.pPanel:SetActive("PlayerTitle", true);
			itemObj.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
		else
			itemObj.pPanel:SetActive("PlayerTitle", false);
		end
		itemObj.pPanel:Sprite_SetSprite("FactionIcon", Faction:GetIcon(tbInfo.nFaction) or "faction_hammer");
	end
	self.ScrollViewStarTowerItem:Update(tbData, fnSetItem);
end