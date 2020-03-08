Require("CommonScript/Help/StrongerDefine.lua")
Require("Script/Ui/Ui.lua")
Player.Stronger = Player.Stronger or {}
local Stronger = Player.Stronger
local tbUi = Ui:CreateClass("StrongerDetailsHelpPanel");

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi:OnScreenClick()
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OnOpen(nRank, nPos)
	if not Stronger:CheckVisible()  then
		me.CenterMsg("少侠已经不再需要这里的指引")
		return
	end

	self:RefreshContent(nPos)
end

function tbUi:RefreshContent(nPos)
	local tbCfg = Stronger:GetRecommendStoneByPos(nPos);
	if not tbCfg then
		return
	end
	local tbList = {}

	for i = 1, Stronger.MAX_RECOMMEND_STONE_COUNT do
		local nStoneId = tbCfg["StoneId"..i]
		if nStoneId and nStoneId > 0 then
			table.insert(tbList, nStoneId)
		end
	end

	local fnSetItem = function (itemObj, nIdx)
		local nStoneId = tbList[nIdx]
		local szName, _, _, _ = Item:GetItemTemplateShowInfo(nStoneId)
		itemObj.itemframe:SetGenericItem({"Item", nStoneId})
		itemObj.itemframe.fnClick = itemObj.itemframe.DefaultClick;
		itemObj.pPanel:Label_SetText("Text1", string.format("%d.", nIdx));
		itemObj.pPanel:Label_SetText("Text2", szName);
	end

	self.ScrollView:Update(tbList, fnSetItem);
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
