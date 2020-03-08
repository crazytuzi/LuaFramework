local tbUi = Ui:CreateClass("TeamMatchPanel");

function tbUi:OnOpenEnd(nActivityId)
	self.tbSelect = {};
	if nActivityId then
		self.tbSelect[nActivityId] = true;
	end



	self:UpdateScrollView();
end

function tbUi:UpdateScrollView()
	self.bSelectAll = false;
	local tbItems = TeamMgr:GetActivityList() or {};
	for _, tbItem in pairs(tbItems) do
		local bCanJoin = TeamMgr:GetTeamActivityCountInfo(tbItem.szType, me) > 0;
		if self.tbSelect[tbItem.nActivityId] and not bCanJoin then
			self.tbSelect[tbItem.nActivityId] = nil;
		end

		if not self.tbSelect[tbItem.nActivityId] and bCanJoin then
			self.bSelectAll = true;
		end
	end
	self.pPanel:Label_SetText("TxtAllSelect", self.bSelectAll and "全选" or "反选");

	local tbItems = TeamMgr:GetActivityList() or {};
	local fnSetItem = function (itemObj, idx)
		local tbItem1, tbItem2 = tbItems[idx*2-1], tbItems[idx*2];
		itemObj:Init(tbItem1, tbItem2, self);
	end

	self.ScrollViewMatchingItem:Update(math.ceil(#tbItems/2), fnSetItem);
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnAllSelect()
	local tbItems = TeamMgr:GetActivityList() or {};
	for _, tbItem in pairs(tbItems) do
		if TeamMgr:GetTeamActivityCountInfo(tbItem.szType, me) > 0 then
			self.tbSelect[tbItem.nActivityId] = self.bSelectAll;
		else
			self.tbSelect[tbItem.nActivityId] = nil;
		end
	end

	self:UpdateScrollView();
end

function tbUi.tbOnClick:BtnMatching()
	local tbSelect = {};
	for k, v in pairs(self.tbSelect) do
		if v then
			tbSelect[k] = true;
		end
	end

	TeamMgr:QuickMatch(tbSelect);
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME);
end

local tbItem = Ui:CreateClass("TeamMatchItem");

function tbItem:Init(tbItem1, tbItem2, root)
	self.rootPanel = root;
	self.tbSelect = root.tbSelect;
	self.tbItem1 = tbItem1;
	self.tbItem2 = tbItem2;

	self.pPanel:SetActive("Btn1", tbItem1 and true or false);
	self.pPanel:SetActive("Btn2", tbItem2 and true or false);

	if tbItem1 then
		local szName1 = TeamMgr:GetActivityInfo(tbItem1.nActivityId);
		self.pPanel:Label_SetText("Name1", szName1);
		local nCurCount, nMaxCount = TeamMgr:GetTeamActivityCountInfo(tbItem1.szType, me);
		self.pPanel:Label_SetText("Time1", nMaxCount > 0 and string.format("次数：%d/%d", nCurCount, nMaxCount) or "");
		self.pPanel:Toggle_SetChecked("Btn1", self.tbSelect[tbItem1.nActivityId]);
	end

	if tbItem2 then
		local szName2 = TeamMgr:GetActivityInfo(tbItem2.nActivityId);
		self.pPanel:Label_SetText("Name2", szName2);
		local nCurCount, nMaxCount = TeamMgr:GetTeamActivityCountInfo(tbItem2.szType, me);
		self.pPanel:Label_SetText("Time2", nMaxCount > 0 and string.format("次数：%d/%d", nCurCount, nMaxCount) or "");
		self.pPanel:Toggle_SetChecked("Btn2", self.tbSelect[tbItem2.nActivityId]);
	end
end

tbItem.tbOnClick = tbItem.tbOnClick or {};

function tbItem.tbOnClick:Btn1()
	self.tbSelect[self.tbItem1.nActivityId] = self.pPanel:Toggle_GetChecked("Btn1");
	local nCurCount = TeamMgr:GetTeamActivityCountInfo(self.tbItem1.szType, me);
	if nCurCount <= 0 then
		self.tbSelect[self.tbItem1.nActivityId] = nil;
		local szName = TeamMgr:GetActivityInfo(self.tbItem1.nActivityId);
		me.CenterMsg(string.format("%s剩余次数不足", szName));
	end

	self.rootPanel:UpdateScrollView();
end

function tbItem.tbOnClick:Btn2()
	self.tbSelect[self.tbItem2.nActivityId] = self.pPanel:Toggle_GetChecked("Btn2");
	local nCurCount = TeamMgr:GetTeamActivityCountInfo(self.tbItem2.szType, me);
	if nCurCount <= 0 then
		self.tbSelect[self.tbItem2.nActivityId] = nil;
		local szName = TeamMgr:GetActivityInfo(self.tbItem2.nActivityId);
		me.CenterMsg(string.format("%s剩余次数不足", szName));
	end

	self.rootPanel:UpdateScrollView();
end

