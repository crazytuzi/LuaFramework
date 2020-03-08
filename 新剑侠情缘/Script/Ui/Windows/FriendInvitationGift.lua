local tbUi = Ui:CreateClass("FriendInvitationGift");

function tbUi:OnOpen()
	self.pPanel:SetActive("itemframe1", false);
	self.pPanel:SetActive("itemframe2", false);
	self.pPanel:SetActive("itemframe3", false);
	self.pPanel:SetActive("GuideTips", false);
	self.tbCurUnRegFriends = self.tbCurUnRegFriends or {};
	self.tbSelect = {};

	self:Update();
end

function tbUi:OnClose()
	
end

tbUi.nBoxCount = 4;
tbUi.tbStage = {2, 5, 10, 20};
tbUi.nShowCount = 8;

function tbUi:Update()
	local nInvitedCount, nAwardStep = Sdk:GetQQInviteFriendPlayerInfo(me);
	self.pPanel:Label_SetText("ActiveValueNumber", nInvitedCount);

	local nBarFillPercent = 0;
	local nLastCount = 0;
	self.nMaxAwardStep = 0; -- 最大可领取的奖励
	for nIdx , nCount in ipairs(tbUi.tbStage) do
		local bGet = (nInvitedCount >= nCount);
		if bGet then
			nBarFillPercent = nBarFillPercent + (1/tbUi.nBoxCount);
			self.nMaxAwardStep = nIdx;
		elseif nInvitedCount > nLastCount and nInvitedCount < nCount then
			nBarFillPercent = nBarFillPercent + (nInvitedCount - nLastCount)/(nCount - nLastCount)/4;
		end

		self.pPanel:SetActive("BoxMark" .. nIdx, not bGet);
		self.pPanel:SetActive("texiao_1" .. nIdx, bGet and nIdx > nAwardStep);
		self.pPanel:SetActive("texiao_2" .. nIdx, bGet and nIdx > nAwardStep);
		self.pPanel:SetActive("Get" .. nIdx, bGet);
		self.pPanel:Label_SetText("Get" .. nIdx, nIdx > nAwardStep and "点击领取" or "已领取");

		nLastCount = nCount;
	end
	self.pPanel:Sprite_SetFillPercent("Bar", nBarFillPercent);


	self:UpdateFriendsInfo();
end

function tbUi:UpdateFriendsInfo()
	local tbUnRegistInfo, tbInvitedIds = Sdk:GetQQUnregistFrindInfo();

	if not next(self.tbCurUnRegFriends) then
		for _, tbFriend in ipairs(tbUnRegistInfo) do
			if not tbInvitedIds[tbFriend.openid] then
				table.insert(self.tbCurUnRegFriends, tbFriend);
			end
		end
	end

	local bHasSelect = false;
	for i = 1, self.nShowCount do
		local tbFriend = self.tbCurUnRegFriends[i];
		if tbFriend then
			self.pPanel:SetActive("Friend" .. i, true);
			self.pPanel:Texture_SetUrlTexture("Head" .. i, tbFriend.head_img_url or "");

			local szName = tbFriend.nick_name or "";
			if Lib:Utf8Len(szName) > 6 then
				szName = Lib:CutUtf8(szName, 5) .. "…";
			end

			self.pPanel:Label_SetText("Name" .. i, szName);
			self.pPanel:Toggle_SetChecked("Friend" .. i, self.tbSelect[i] and true or false);
			if self.tbSelect[i] then
				bHasSelect = true;
			end
		else
			self.pPanel:SetActive("Friend" .. i, false);
		end
	end

	self.pPanel:SetActive("Btn2", not bHasSelect);
	self.pPanel:SetActive("Btn3", bHasSelect);
	self.pPanel:SetActive("NoFriendstxt", not next(self.tbCurUnRegFriends));
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

for i = 1, tbUi.nBoxCount do
	tbUi.tbOnClick["Box" .. i] = function (self)
		local tbAward = Sdk.Def.tbQQInviteFriendAward[i].tbAward;
		self.pPanel:SetActive("itemframe1", #tbAward == 2);
		self.pPanel:SetActive("itemframe2", #tbAward == 2);
		self.pPanel:SetActive("itemframe3", #tbAward == 1);
		if #tbAward == 1 then
			self.itemframe3:SetGenericItem(tbAward[1]);
		elseif #tbAward == 2 then
			self.itemframe1:SetGenericItem(tbAward[1]);
			self.itemframe2:SetGenericItem(tbAward[2]);
		end

		local nInvitedCount, nAwardStep = Sdk:GetQQInviteFriendPlayerInfo(me);
		if nAwardStep < self.nMaxAwardStep then
			if i == (nAwardStep + 1) then
				Sdk:TakeInviteQQAward(i);
			else
				me.CenterMsg("请先领取上一级奖励");
			end
		end
	end

	tbUi.tbOnClick["BoxMark" .. i] = tbUi.tbOnClick["Box" .. i];
end

for i = 1, tbUi.nShowCount do
	tbUi.tbOnClick["Friend" .. i] = function (self)
		self.tbSelect[i] = not self.tbSelect[i];
		self:UpdateFriendsInfo();
	end
end

function tbUi.tbOnClick:Btn1()
	for i = 1, tbUi.nShowCount do
		if self.tbCurUnRegFriends[1] then
			table.remove(self.tbCurUnRegFriends, 1);
		end
	end
	self.tbSelect = {};
	self:UpdateFriendsInfo();
end

function tbUi.tbOnClick:Btn2()
	me.CenterMsg("请先选择好友");
end

function tbUi.tbOnClick:Btn3()
	local tbOpenIds = {};
	for i = 1, tbUi.nShowCount do
		if self.tbSelect[i] and self.tbCurUnRegFriends[i] then
			table.insert(tbOpenIds, self.tbCurUnRegFriends[i].openid);
		end
	end

	if not next(tbOpenIds) then
		me.CenterMsg("您没有邀请好友");
		return;
	end

	local fnYes = function ()
		Sdk:InviteQQUnregistFriends(tbOpenIds);
		self.tbOnClick.Btn1(self);
	end

	me.MsgBox("是否向好友发送QQ消息？", {{"是", fnYes},{"否"}});
end