local tbUi = Ui:CreateClass("NewInfo_BeautySelection2")

local MAX_SHOW_AWARD = 20 					-- 每行奖励最多十个
local MAX_STATE = 3 						-- 最大显示三个模块
local MAX_AWARD_LINE = 5 					-- 奖励最大显示5行
local PER_AWARD_ITEM_HEIGHT = 114 			-- 每个奖励item的高度
-- 高度偏移调整配[模块] = {content高度偏移，itemroup高度偏移}
tbUi.tbOffsetY =
{
	[2] = {20, 20};
	[3] = {40, 30};
}

function tbUi:OnOpen(tbData)
	local tbAct = Activity.KinElect;
	local nAllContentSizeY = 0 				-- 所有content文本的高度
	local nAllItemGroupY = 0 					-- 所有ItemGroup加起来的高度
	for i = 1, MAX_STATE do
		local nShowItemCount = 0 				-- 显示出来奖励行数
		local szContentUi = "Content" ..i
		local ItemGroupUi = "ItemGroup" ..i
		local tbData = tbAct.tbShowAward[i]
		if tbData then
			local tbOffsetY = self.tbOffsetY[i] or {}
			local nContentOffsetY = tbOffsetY[1] or 0
			local nItemGroupOffsetY = tbOffsetY[2] or 0
			local tbPos = self.pPanel:GetPosition(szContentUi);
			self.pPanel:ChangePosition(szContentUi, tbPos.x, -(nAllContentSizeY + nAllItemGroupY + nContentOffsetY))
			self.pPanel:SetActive(szContentUi, true)
			self.pPanel:SetActive(ItemGroupUi, true)
			self[szContentUi]:SetLinkText(tbData.szContent);
			local tbContentSize = self.pPanel:Label_GetPrintSize(szContentUi);
			nAllContentSizeY = nAllContentSizeY + tbContentSize.y
			for nIndex = 1, MAX_AWARD_LINE do
				local szWndName = string.format("BeautyItem%s", nIndex)
				local tbWnd = self[ItemGroupUi][szWndName]
				local tbAwardData = tbData.tbAllAward[nIndex]
				self:SetWinnerAward(tbWnd, tbAwardData, nIndex)
				if tbAwardData then
					nShowItemCount = nShowItemCount + 1
				end
			end

			local tbPos = self.pPanel:GetPosition(ItemGroupUi);
			self.pPanel:ChangePosition(ItemGroupUi, tbPos.x, -(nAllContentSizeY + nAllItemGroupY + nItemGroupOffsetY))
			local nItemGroupY = nShowItemCount * PER_AWARD_ITEM_HEIGHT
			nAllItemGroupY = nAllItemGroupY + nItemGroupY
			local tbItemGroupSize = self.pPanel:Widget_GetSize(ItemGroupUi);
			self.pPanel:Widget_SetSize(ItemGroupUi, tbItemGroupSize.x, nItemGroupY)
		else
			self.pPanel:SetActive(szContentUi, false)
			self.pPanel:SetActive(ItemGroupUi, false)
		end

	end
	local tbSize = self.pPanel:Widget_GetSize("datagroup3");
	self.pPanel:Widget_SetSize("datagroup3", tbSize.x, 60 + nAllContentSizeY + nAllItemGroupY);
	self.pPanel:DragScrollViewGoTop("datagroup3");
	self.pPanel:UpdateDragScrollView("datagroup3");
end

function tbUi:SetWinnerAward(tbWnd, tbAwardList, nIndex)
	if tbAwardList then
		tbWnd.pPanel:SetActive("Main", true);
		local szTitle = tbAwardList.szTitle or ""
		tbWnd.pPanel:Label_SetText("BeautyTitle" ..nIndex, szTitle);
		local tbAllAward = tbAwardList.tbAward or {}
		for i=1, MAX_SHOW_AWARD do
			if not tbWnd["itemframe" .. i] then
				break
			end
			local tbAward = tbAllAward[i]
			if tbAward then
				tbWnd["itemframe" .. i].pPanel:SetActive("Main", true);
				tbWnd["itemframe" .. i]:SetGenericItem(tbAward);
				tbWnd["itemframe" .. i].fnClick = tbWnd["itemframe" .. i].DefaultClick;
			else
				tbWnd["itemframe" .. i].pPanel:SetActive("Main", false);
			end
		end
	else
		tbWnd.pPanel:SetActive("Main", false);
	end
end


tbUi.tbOnClick = {};
