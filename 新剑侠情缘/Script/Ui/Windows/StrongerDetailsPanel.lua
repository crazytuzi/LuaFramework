Require("CommonScript/Help/StrongerDefine.lua")
Require("Script/Ui/Ui.lua")
Player.Stronger = Player.Stronger or {}
local Stronger = Player.Stronger
local tbUi = Ui:CreateClass("StrongerDetailsPanel");

tbUi.pfnPartnerLevelDesc = function (nLevel)
	local szDesc = Partner.tbQualityLevelDes[nLevel] or ""
	if version_tx then
		szDesc = szDesc .. "级"
	end
	return szDesc
end

tbUi.pfnZhenYuanLevelDesc = function (nLevel)
	return string.format("%d阶", nLevel)
end

tbUi.pfnZhenYuanQualityDesc = function (nQuality)
	if nQuality >= 6 then
		return "稀有"
	elseif nQuality >= 4 then
		return "传承"
	else
		return "普通"
	end
end

tbUi.pfnJingMaiLevelDesc = function (nLevel)
	return string.format("周天:%d", nLevel)
end

tbUi.pfnJingMaiQualityDesc = function (nQuality)
	return string.format("经脉技能:%d", nQuality)
end

tbUi.pfnSkillBookLevelDesc = function (nLevel)
	if nLevel >= 5 then
		return "高级"
	elseif nLevel >= 4 then
		return "中级"
	else
		return "初级"
	end
end

tbUi.tbTypeCfg =
{
	[Stronger.Type.Strengthen] = {szName="强化", bEquipPart = true},
	[Stronger.Type.Stone] = {szName="镶嵌", bEquipPart = true},
	[Stronger.Type.Refine] = {szName="装备基础", bEquipPart = true},
	[Stronger.Type.Horse] = {szName="坐骑", bEquipPart = true},
	[Stronger.Type.Partner] = {szName="同伴", bEquipPart = false, pfnLevelDesc = tbUi.pfnPartnerLevelDesc},
	[Stronger.Type.PartnerCard] = {szName="门客", bEquipPart = false},
	[Stronger.Type.ZhenYuan] = {szName="真元", bEquipPart = false, pfnLevelDesc = tbUi.pfnZhenYuanLevelDesc, pfnQualityDesc = tbUi.pfnZhenYuanQualityDesc},
	[Stronger.Type.JingMai] = {szName="经脉", bEquipPart = false, pfnLevelDesc = tbUi.pfnJingMaiLevelDesc, pfnQualityDesc = tbUi.pfnJingMaiQualityDesc},
	[Stronger.Type.ZhenFa] = {szName="阵法", bEquipPart = false},
	[Stronger.Type.SkillBook] = {szName="秘籍", bEquipPart = false, pfnLevelDesc = tbUi.pfnSkillBookLevelDesc},
	[Stronger.Type.JueXue] = {szName="绝学", bEquipPart = false},
	[Stronger.Type.SkillPoint] = {szName="修为", bEquipPart = false},
}

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi.tbOnClick:BtnGo()
	local szAction = self.tbCfg.Action
	if szAction and szAction ~= "" then
		Ui:CloseWindow(self.UI_NAME);
		szAction =  string.gsub(szAction, "\"", "");
		loadstring("return " .. szAction)();
	end
end

function tbUi:OnScreenClick()
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OnOpen(tbCfg)
	if not Stronger:CheckVisible()  then
		me.CenterMsg("少侠已经不再需要这里的指引")
		return
	end

	self.tbCfg = tbCfg
	local nType = Stronger.Type[tbCfg.Desc]
	if not nType then
		return
	end

	self.pPanel:Label_SetText("Title", self.tbTypeCfg[nType].szName);

	self:RefreshContent(nType)
end

function tbUi:RefreshContent(nType)
	local nRank, _, tbData = Stronger:GetRecommendDataByType(nType)
	local tbUiCfg = self.tbTypeCfg[nType];
	if not nRank or not tbUiCfg then
		return
	end

	local pfnFormatDesc = function ( tbAvg, nFP, tbValueInfo )
		if tbAvg and tbAvg.nLvl then
			tbValueInfo.szLvl = (tbUiCfg.pfnLevelDesc and tbUiCfg.pfnLevelDesc(tbAvg.nLvl)) or string.format("等级:%d", tbAvg.nLvl);
		end
		if tbAvg and tbAvg.nQuality then
			tbValueInfo.szQuality = (tbUiCfg.pfnLevelDesc and tbUiCfg.pfnQualityDesc(tbAvg.nQuality)) or string.format("品质:%d", tbAvg.nQuality);
		end
		if nFP then
			tbValueInfo.szFP = string.format("[FFCA09FF]%s:%s[-]", "战力", tostring(nFP or 0));
		end
	end

	local tbContentList = {};
	local tbMyTotalAvg, tbMyDetailAvg, nMyFP =  Stronger:GetMyDataByType(nType);
	if Lib:CountTB(tbData.tbDetailAvg) <= 0 then
		--没有分部件显示
		local tbInfo =
		{
			szName = tbUiCfg.szName,
			tbAvg ={},
			tbMy = {},
		}

		pfnFormatDesc(tbData.tbOtherTotalAvg, tbData.nTotalFPAvg,tbInfo.tbAvg);
		pfnFormatDesc(tbMyTotalAvg, nMyFP or Stronger:GetFightPowerByType(nType), tbInfo.tbMy);

		table.insert(tbContentList, tbInfo);
	else
		for nPos, tbDetail in pairs( tbData.tbDetailAvg ) do
			local tbInfo =
			{
				szName = tbUiCfg.szName .. tostring(nPos),
				tbAvg ={},
				tbMy = {},
				nRank = nRank,
				nPos = nPos,
				tbDetail = tbDetail,
			}
			if tbUiCfg.bEquipPart then
				tbInfo.szName = Item.EQUIPPOS_NAME[nPos];
			end

			local nReccomendFP = 0
			if type(tbDetail) == "table" then
				pfnFormatDesc(tbDetail, tbDetail.nFP, tbInfo.tbAvg);
				nReccomendFP = tbDetail.nFP
			else
				pfnFormatDesc(nil, tbDetail, tbInfo.tbAvg);
				nReccomendFP = tbDetail
			end

			if tbMyDetailAvg[nPos] then
				if type(tbMyDetailAvg[nPos]) == "table" then
					pfnFormatDesc(tbMyDetailAvg[nPos], tbMyDetailAvg[nPos].nFP, tbInfo.tbMy);
				else
					pfnFormatDesc(nil, tbMyDetailAvg[nPos], tbInfo.tbMy);
				end
			end

			if nReccomendFP > 0 then
				table.insert(tbContentList, tbInfo);
			end
		end
	end

	local fnStoneRecommendClick = function (buttonObj)
		local tbInfo = buttonObj.tbInfo
		if tbInfo and tbInfo.nRank and tbInfo.nPos then
			Ui:OpenWindow("StrongerDetailsHelpPanel", tbInfo.nRank, tbInfo.nPos)
		end
	end

	local fnSetItem = function (itemObj, nIdx)
		local tbInfo = tbContentList[nIdx]

		itemObj.pPanel:Label_SetText("PositionTxt", tbInfo.szName or "");

		local szAvgDesc
		local szMyDesc
		if tbInfo.tbAvg.szLvl then
			szAvgDesc = tbInfo.tbAvg.szLvl
		end

		if tbInfo.tbAvg.szQuality then
			szAvgDesc = string.format("%s%s" , (szAvgDesc and szAvgDesc.."\n") or "",tbInfo.tbAvg.szQuality)
		end

		if tbInfo.tbAvg.szFP then
			szAvgDesc = string.format("%s%s" , (szAvgDesc and szAvgDesc.."\n") or "",tbInfo.tbAvg.szFP)
		end

		if tbInfo.tbMy.szLvl then
			szMyDesc = tbInfo.tbMy.szLvl
		end

		if tbInfo.tbMy.szQuality then
			szMyDesc = string.format("%s%s" , (szMyDesc and szMyDesc.."\n") or "",tbInfo.tbMy.szQuality)
		end

		if tbInfo.tbMy.szFP then
			szMyDesc = string.format("%s%s" , (szMyDesc and szMyDesc.."\n") or "",tbInfo.tbMy.szFP)
		end

		itemObj.pPanel:Label_SetText("AverageGradeTxt", szAvgDesc or "");
		itemObj.pPanel:Label_SetText("MyGradeTxt", szMyDesc or "");

		itemObj.pPanel:SetActive("BtnPosition",nType == Stronger.Type.Stone);
		itemObj.BtnPosition.pPanel.OnTouchEvent = fnStoneRecommendClick
		itemObj.BtnPosition.tbInfo = tbInfo;
	end

	self.ScrollView:Update(tbContentList, fnSetItem);
end

function tbUi:OnEnterMap()
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{UiNotify.emNOTIFY_MAP_ENTER, self.OnEnterMap},
	};

	return tbRegEvent;
end
