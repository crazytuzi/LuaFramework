local tbUi = Ui:CreateClass("ShowOffPanel");

function tbUi:OnOpen()
	if Sdk:IsLoginByGuest() then
		me.CenterMsg("暂时无法进行分享");
		return 0;
	end
end

function tbUi:OnOpenEnd(szShareTag)
	self:UpdateUserInfo();
	self:SetButtonState(true);

	if Sdk:IsMsdk() then
		local bLoginByQQ = Sdk:IsLoginByQQ();
		self.pPanel:Label_SetText("TxtShareFriend", bLoginByQQ and "分享给QQ好友" or "分享给微信好友");
		self.pPanel:Label_SetText("TxtShareCircle", bLoginByQQ and "分享到QQ空间" or "分享到朋友圈");
	elseif Sdk:CanShowOffShare() then
		self.pPanel:Label_SetText("TxtShareCircle", "分享到Facebook");
		if version_kor then
			self.pPanel:ChangePosition("BtnShareCircle", 0, -283, 0);
		end
	end
end

function tbUi:UpdateUserInfo()
	local pNpc = me.GetNpc();
	if not pNpc then
		return;
	end

	local nFightPower = pNpc.GetFightPower()
	self.pPanel:Label_SetText("FightingNumber", nFightPower);
	self.pPanel:Label_SetText("Name", me.szName);
	if version_tx then
		self.pPanel:Label_SetText("Level", string.format("%d级", me.nLevel));
	else
		self.pPanel:Label_SetText("Level", string.format("Lv.%d", me.nLevel));
	end

	local tbEquip = me.GetEquips();
	for i = 1, Item.EQUIPPOS_MAIN_NUM do
		local tbEqiptGrid = self["Equip"..i]
		tbEqiptGrid.nEquipPos = i - 1;
		tbEqiptGrid.szItemOpt = "PlayerEquip"
		tbEqiptGrid.fnClick = tbEqiptGrid.DefaultClick;
		tbEqiptGrid:SetItem(tbEquip[i-1])
	end

	self.pPanel:NpcView_Open("ShowRole", me.nFaction);
	local tbNpcRes, tbEffectRes = me.GetNpcResInfo();
	local tbFactionScale = {0.92, 1, 1.15, 1}	-- 贴图缩放比例
	local fScale = tbFactionScale[me.nFaction] or 1
	for nPartId, nResId in pairs(tbNpcRes) do
		local nCurResId = nResId
		if nPartId == Npc.NpcResPartsDef.npc_part_horse then
			nCurResId = 0;
		end

		self.pPanel:NpcView_ChangePartRes("ShowRole", nPartId, nCurResId);
	end

	for nPartId, nResId in pairs(tbEffectRes) do
		self.pPanel:NpcView_ChangePartEffect("ShowRole", nPartId, nResId);
	end

	self.pPanel:NpcView_SetScale("ShowRole", fScale);
end

tbUi.tbOnDrag =
{
	ShowRole = function (self, szWnd, nX, nY)
		self.pPanel:NpcView_ChangeDir("ShowRole", -nX, true)
	end
}

function tbUi:OnClose()
	self.pPanel:NpcView_Close("ShowRole");
end

function tbUi:SetButtonState(bShow)
	self.pPanel:SetActive("BtnShareFriend", bShow and Sdk:IsMsdk());
	self.pPanel:SetActive("BtnShareCircle", bShow);
	self.pPanel:SetActive("BtnBack", bShow);
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnShareFriend()
	local szType = Sdk:IsLoginByQQ() and "QQ" or "WX";
	if not Sdk:CheckShareType(szType) then
		return;
	end

	self:SetButtonState(false);
	UiNotify.OnNotify(UiNotify.emNOTIFY_SHARE_PHOTO);
	Sdk:TlogShare("ShowOff");
	Timer:Register(3, function ()
		Sdk:SharePhoto(szType, self.szShareTag or "MSG_SHARE_FRIEND_HIGH_SCORE");
	end)

	Timer:Register(7, function ()
		Ui:CloseWindow(self.UI_NAME);
	end)
end

function tbUi.tbOnClick:BtnShareCircle()
	if Sdk:IsMsdk() then
		local szType = Sdk:IsLoginByQQ() and "QZone" or "WXMo";
		if not Sdk:CheckShareType(szType) then
			return;
		end

		self:SetButtonState(false);
		UiNotify.OnNotify(UiNotify.emNOTIFY_SHARE_PHOTO);
		Sdk:TlogShare("ShowOff");
		Timer:Register(3, function ()
			Sdk:SharePhoto(szType, self.szShareTag or "MSG_SHARE_MOMENT_HIGH_SCORE");
		end)
	elseif Sdk:IsEfunHKTW() then
		local szHKUrl = "http://www.jxqy.org";
		local szTWUrl = "http://www.jxqy.org";

		self:SetButtonState(false);
		UiNotify.OnNotify(UiNotify.emNOTIFY_SHARE_PHOTO);
		Timer:Register(3, function ()
			Sdk:XGSharePhoto(
				"剑侠情缘手游",
				"",
				"二十载江湖路，谁与我生死与共！再战情义，剑侠邀你相逢叙义！",
				"二十载江湖路，谁与我生死与共！再战情义，剑侠邀你相逢叙义！",
				version_hk and szHKUrl or szTWUrl);
		end)
	elseif version_xm then
		self:SetButtonState(false);
		UiNotify.OnNotify(UiNotify.emNOTIFY_SHARE_PHOTO);
		Timer:Register(3, function ()
			Sdk:XGSharePhoto(
				"剑侠情缘手游",
				"",
				"二十载江湖路，谁与我生死与共！再战情义，剑侠邀你相逢叙义！",
				"二十载江湖路，谁与我生死与共！再战情义，剑侠邀你相逢叙义！",
				"http://www.jxqy.org");
		end)
	elseif version_kor then
		Sdk:XGShareInfo(
			"剑侠情缘手游",
			"https://image.kingsoftgame.com/image/jxqykr-share.jpg",
			"二十载江湖路，谁与我生死与共！再战情义，剑侠邀你相逢叙义！",
			"二十载江湖路，谁与我生死与共！再战情义，剑侠邀你相逢叙义！",
			"http://www.jxqy.org");
	end

	Timer:Register(7, function ()
		Ui:CloseWindow(self.UI_NAME);
	end)
end

function tbUi.tbOnClick:BtnBack()
	Ui:CloseWindow(self.UI_NAME);
end
