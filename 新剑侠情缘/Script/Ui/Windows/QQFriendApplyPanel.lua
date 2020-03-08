local tbUi = Ui:CreateClass("QQFriendApplyPanel");

function tbUi:OnOpen()
	
end

function tbUi:OnOpenEnd()
	self:Update();
end

function tbUi:Update()
	local tbAllFriend = FriendShip:GetAllFriendData();
	local tbSelectFriend = {};
	for i, tbFriendInfo in ipairs(tbAllFriend) do
		if FriendShip:GetImityLevel(tbFriendInfo.nImity) >= Sdk.Def.nAddQQFriendImityLine then
			table.insert(tbSelectFriend, tbFriendInfo);
		end
	end

	local fnSort = function (a, b)
		if a.nState == emPLAYER_STATE_NORMAL and b.nState ~= emPLAYER_STATE_NORMAL then
			return true;
		elseif a.nState ~= emPLAYER_STATE_NORMAL and b.nState == emPLAYER_STATE_NORMAL then
			return false;
		end
		return a.nImity > b.nImity;
	end
	table.sort(tbSelectFriend, fnSort);

	local fnSetFriend = function (itemClass, nIdx)
		local tbData = tbSelectFriend[nIdx];
		itemClass:Init(tbData);
	end

	self.ScrollView:Update(tbSelectFriend, fnSetFriend);

	local bSelected = Sdk:IsQQAddFriendAvailable(me);
	self.pPanel:Toggle_SetChecked("Toggle", not bSelected);
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi.tbOnClick:Toggle()
	local bSelected = self.pPanel:Toggle_GetChecked("Toggle");
	Sdk:SetQQAddFriendAvailable(not bSelected);
end

local tbItem = Ui:CreateClass("QQFriendApplyList")

function tbItem:Init(tbRoleInfo)
	local nVipLevel = tbRoleInfo.nVipLevel
	local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbRoleInfo.nHonorLevel)
	if ImgPrefix then
		self.pPanel:SetActive("lbRoleName", true)
		self.pPanel:SetActive("lbRoleName2", false)
		self.pPanel:Label_SetText("lbRoleName", tbRoleInfo.szName)
		self.pPanel:SetActive("PlayerTitle", true);
		self.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
		if not nVipLevel or nVipLevel == 0 then
			self.pPanel:SetActive("VIP", false)
		else
			self.pPanel:SetActive("VIP", true)
			self.pPanel:Sprite_Animation("VIP",  Recharge.VIP_SHOW_LEVEL[nVipLevel]);
		end
	else
		self.pPanel:SetActive("lbRoleName", false)
		self.pPanel:SetActive("lbRoleName2", true)
		self.pPanel:Label_SetText("lbRoleName2", tbRoleInfo.szName)
		self.pPanel:SetActive("PlayerTitle", false);
		if not nVipLevel or nVipLevel == 0 then
			self.pPanel:SetActive("VIP2", false)
		else
			self.pPanel:SetActive("VIP2", true)
			self.pPanel:Sprite_Animation("VIP2",  Recharge.VIP_SHOW_LEVEL[nVipLevel]);
		end
	end

	self.pPanel:Label_SetText("lbIntimacy", string.format("%d级", tbRoleInfo.nImityLevel));
	self.pPanel:Label_SetText("lbLevel", tbRoleInfo.nLevel);
	local SpFaction = Faction:GetIcon(tbRoleInfo.nFaction);
	local szPortrait, szAltas = PlayerPortrait:GetSmallIcon(tbRoleInfo.nPortrait);
	self.pPanel:Sprite_SetSprite("SpFaction", SpFaction);
	if tbRoleInfo.nState == 2 then
		self.pPanel:Sprite_SetSprite("SpRoleHead",  szPortrait, szAltas);
		self.pPanel:Button_SetSprite("Main", "BtnListFourthNormal", 1)
	else
		self.pPanel:Sprite_SetSpriteGray("SpRoleHead",  szPortrait, szAltas);
		self.pPanel:Button_SetSprite("Main", "BtnListFourthDisabled", 1)
	end

	self.dwFriendId = tbRoleInfo.dwID;
end

tbItem.tbOnClick = tbItem.tbOnClick or {};

function tbItem.tbOnClick:BtnAdd()
	Sdk:RequestAddQQFriend(self.dwFriendId);
end

