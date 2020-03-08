
local tbUi = Ui:CreateClass("BiWuZhaoQinList");

function tbUi:OnOpen(tbShowInfo)
	self.tbShowInfo = {};
	local nHour, nMin = string.match(BiWuZhaoQin.szOpenTime, "(%d+):(%d+)");
	nHour = tonumber(nHour);
	nMin = tonumber(nMin);
	self.nOpenTime = nHour * 3600 + nMin * 60;

	for _, tbOpenInfo in ipairs(tbShowInfo) do
		local nStartIdx = #self.tbShowInfo + 1;
		local nOpenDay = tbOpenInfo.nOpenDay;
		for nId, tbInfo in pairs(tbOpenInfo.tbOpenPlayerInfo) do
			tbInfo.nOpenDay = nOpenDay;
			local bCanJoin = true;
			if tbInfo.nTypeId ~= 0 and tbInfo.nTypeId ~= me.dwKinId then
				bCanJoin = false;
			end

			if tbInfo.nMinLevel > me.nLevel or tbInfo.nMinHonor > me.nHonorLevel then
				bCanJoin = false;
			end

			if me.dwID == tbInfo.nId then
				bCanJoin = true;
			end

			tbInfo.bCanJoin = bCanJoin;
			if not tbInfo.bFinish then
				table.insert(self.tbShowInfo, tbInfo);
			end
		end
	end

	table.sort(self.tbShowInfo, function (tbA, tbB)
		if tbA.nOpenDay ~= tbB.nOpenDay then
			return tbA.nOpenDay < tbB.nOpenDay;
		end

		if tbA.nTypeId == 0 or tbB.nTypeId == 0 then
			return tbA.nTypeId == 0;
		end

		if tbA.nTypeId == me.dwKinId or tbB.nTypeId == me.dwKinId then
			return tbA.nTypeId == me.dwKinId;
		end

		return tbA.nTypeId < tbB.nTypeId;
	end)
	self:Update();
end

function tbUi:Update()
	self.nSelect = 0;
	self.pPanel:SetActive("BtnCancel", false);
	local function fnSetItem(itemObj, index)
		local tbInfo = self.tbShowInfo[index];

		itemObj.bCanJoin = tbInfo.bCanJoin;
		itemObj.pPanel:Sprite_SetGray("Main", not tbInfo.bCanJoin);
		itemObj.pPanel:Toggle_SetChecked("Main", self.nSelect == index);

		itemObj.pPanel:SetActive("State", tbInfo.bIsRuning and true or false);
		itemObj.pPanel:SetActive("Mark", tbInfo.bHasJoin and true or false);

		if tbInfo.nVipLevel and tbInfo.nVipLevel > 0 then
			itemObj.pPanel:SetActive("VIP", true)
			itemObj.pPanel:Sprite_Animation("VIP",  Recharge.VIP_SHOW_LEVEL[tbInfo.nVipLevel]);
		else
			itemObj.pPanel:SetActive("VIP", false)
		end

		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbInfo.nHonorLevel)
		if ImgPrefix then
			itemObj.pPanel:SetActive("PlayerTitle", true);
			itemObj.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
		else
			itemObj.pPanel:SetActive("PlayerTitle", false);
		end

		itemObj.pPanel:Label_SetText("Time", os.date("%Y年%m月%d日%H:%M", Lib:GetTodayZeroHour(tbInfo.nOpenDay * 3600 * 24) + self.nOpenTime));

		itemObj.pPanel:Label_SetText("RoleName", tbInfo.szName);
		itemObj.pPanel:Label_SetText("Fighting", string.format("战力：%s", tbInfo.nFightPower));
		itemObj.pPanel.OnTouchEvent = function (itemObj)
			self.nSelect = index;
		end

		itemObj.nId = tbInfo.nId;
		itemObj.Head.nId = tbInfo.nId;

		local szHead, szAtlas = PlayerPortrait:GetSmallIcon(tbInfo.nPortrait);
		itemObj.Head.pPanel:Sprite_SetSprite("SpRoleHead", szHead, szAtlas);
		itemObj.Head.pPanel:Label_SetText("lbLevel", tbInfo.nLevel);
		itemObj.Head.pPanel:Sprite_SetSprite("SpFaction", Faction:GetIcon(tbInfo.nFaction));
		itemObj.Head.pPanel.OnTouchEvent = function (itemObj)
			if itemObj.nId ~= me.dwID then
				ViewRole:OpenWindow("ViewRolePanel", itemObj.nId);
			end
		end

		itemObj.BtnTip.tbInfo = tbInfo;
		itemObj.BtnTip.pPanel.OnTouchEvent = function (btnObj)
			local tbSize = btnObj.pPanel:Widget_GetSize("Main");
			local tbPos = btnObj.pPanel:GetRealPosition("Main");
			Ui:OpenWindowAtPos("TxtTipPanel", tbPos.x - 150, tbPos.y,
				string.format("参与范围：%s\n参与最低等级：%s级\n参与最低头衔：%s", tbInfo.nTypeId == 0 and "全服" or "[FFFE0D]" .. tbInfo.szKinName .. "[-]家族", tbInfo.nMinLevel, Player.tbHonorLevelSetting[tbInfo.nMinHonor].Name));
		end
	end

	self.ScrollView:Update(self.tbShowInfo, fnSetItem);
end

function tbUi:GetSelectedInfo()
	return self.tbShowInfo[self.nSelect];
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.BtnEnter = function (self)
	local tbSelect = self:GetSelectedInfo();
	if not tbSelect then
		me.CenterMsg("请选择要参与的场次！");
		return;
	end

	RemoteServer.BiWuZhaoQinAct("JoinFight", tbSelect.nOpenDay, tbSelect.nTypeId);
end

tbUi.tbOnClick.BtnCancel = function (self)

end

tbUi.tbOnClick.BtnInfo = function (self)
	Ui:OpenWindow("NewInformationPanel", "BiWuZhaoQin");
end

tbUi.tbOnClick.BtnMatch = function (self)
	local tbSelect = self:GetSelectedInfo();
	if not tbSelect then
		me.CenterMsg("请选择要参与的场次！");
		return;
	end
	RemoteServer.BiWuZhaoQinAct("GoToMatch", tbSelect.nOpenDay, tbSelect.nTypeId);
end