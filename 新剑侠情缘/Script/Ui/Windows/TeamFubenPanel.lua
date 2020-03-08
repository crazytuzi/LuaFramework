
local tbUi = Ui:CreateClass("TeamFubenPanel");

function tbUi:OnOpen()
	self:Update();
end

function tbUi:Update()
	local nIdx = 0;
	local tbInfo = {};
	for i = 1, 10 do
		for j = 1, 10 do
			local tbSetting = TeamFuben:GetFubenSetting(i, j);
			if tbSetting then
				if GetTimeFrameState(tbSetting.szOpenTimeFrame) == 1 then
					nIdx = nIdx + 1;
				end
				table.insert(tbInfo, {i, j});
			end
		end
	end

	local function fnSelect(itemObj)
		if itemObj.pPanel:IsActive("lock") then
			return;
		end

		Ui:OpenWindow("TeamPanel", "TeamActivity", "TeamFuben", string.format("%s_%s", itemObj.nMSIdx, itemObj.nSSIdx));
		Ui:CloseWindow(self.UI_NAME);
	end

	local function fnSetItem(itemObj, index)
		local nMSIdx, nSSIdx = unpack(tbInfo[index]);
		local tbFubenSetting = TeamFuben:GetFubenSetting(nMSIdx, nSSIdx);

		itemObj.pPanel:Label_SetText("Title", tbFubenSetting.szName);
		itemObj.pPanel:Sprite_SetSprite("Pic", tbFubenSetting.szSprite, tbFubenSetting.szAtlas);

		for i = 1, 3 do
			local tbAward = tbFubenSetting.tbShowItem[i];
			if tbAward then
				itemObj["itemframe" .. i]:SetGenericItem(tbAward);
				itemObj["itemframe" .. i].fnClick = itemObj["itemframe" .. i].DefaultClick;
			else
				itemObj["itemframe" .. i]:Clear();
				itemObj["itemframe" .. i].fnClick = nil;
			end
		end

		if TeamFuben:CanEnterFubenCommon(me, nMSIdx, nSSIdx) then
			itemObj.pPanel:SetActive("lock", false);
		else
			itemObj.pPanel:Label_SetText("LockInfo", "暂未开放");
			itemObj.pPanel:SetActive("lock", true);
		end

		itemObj.nMSIdx = nMSIdx;
		itemObj.nSSIdx = nSSIdx;
		itemObj.pPanel.OnTouchEvent = fnSelect;
	end

	local nDegree = DegreeCtrl:GetDegree(me, "TeamFuben")
	self.pPanel:Label_SetText("Times", math.max(nDegree, 0));
	self.ScrollView:Update(tbInfo, fnSetItem);
	self.ScrollView.pPanel:ScrollViewGoToIndex("Main", math.max(nIdx, 1));
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME);
end
