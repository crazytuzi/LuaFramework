local tbUi = Ui:CreateClass("QQVipPrivilege");

function tbUi:OnOpen()
	self:Update();
end

function tbUi:Update()
	local tbAwardsMap = {
		Sdk.Def.tbQQVipEveryDayAward,
		Sdk.Def.tbQQVipOpenAward,
		Sdk.Def.tbQQSVipEveryDayAward,
		Sdk.Def.tbQQSvipOpenAward};

	for i =1 ,4 do
		local tbReward = tbAwardsMap[i];
		if tbReward[1] == "item" then
			self["itemframe"..i]:SetItemByTemplate(tbReward[2], tbReward[3] or 1, me.nFaction);
		else
			self["itemframe"..i]:SetDigitalItem(tbReward[1], tbReward[2] or 1);
		end
		self["itemframe"..i].fnClick = self["itemframe"..i].DefaultClick;
	end

	local nQQVip = me.GetQQVipInfo();
	if nQQVip == Player.QQVIP_VIP then
		self.pPanel:SetActive("BtnMember1", true);
		self.pPanel:SetActive("BtnMember2", true);
		self.pPanel:Label_SetText("MemberTet1", "续费会员");
		self.pPanel:Label_SetText("MemberTet2", "升级超级会员");
	elseif nQQVip == Player.QQVIP_SVIP then
		self.pPanel:SetActive("BtnMember1", true);
		self.pPanel:SetActive("BtnMember2", true);
		self.pPanel:Label_SetText("MemberTet1", "续费会员");
		self.pPanel:Label_SetText("MemberTet2", "续费超级会员");
	else
		self.pPanel:SetActive("BtnMember1", true);
		self.pPanel:SetActive("BtnMember2", true);
		self.pPanel:Label_SetText("MemberTet1", "开通会员");
		self.pPanel:Label_SetText("MemberTet2", "开通超级会员");
	end

	local bAllowDay, bAllowOpen, nOpenVip = Sdk:GetQQVipRewardState(me);
	local bVipDay = (nQQVip == Player.QQVIP_VIP and bAllowDay);
	local bVipOpen = (nOpenVip == Player.QQVIP_VIP and bAllowOpen);
	local bSVipDay = (nQQVip == Player.QQVIP_SVIP and bAllowDay);
	local bSVipOpen = (nOpenVip == Player.QQVIP_SVIP and bAllowOpen);

	self.pPanel:Button_SetEnabled("BtnGet1", bVipDay);
	self.pPanel:Button_SetEnabled("BtnGet2", bVipOpen);
	self.pPanel:Button_SetEnabled("BtnGet3", bSVipDay);
	self.pPanel:Button_SetEnabled("BtnGet4", bSVipOpen);
end

tbUi.tbOnClick = {};

function tbUi.tbOnClick:BtnMember1()
	Sdk:PayQQVip("VIP");
end

function tbUi.tbOnClick:BtnMember2()
	Sdk:PayQQVip("SVIP");
end

local tbBtn2Op = {
	BtnGet1 = {Player.QQVIP_VIP, "day"},
	BtnGet2 = {Player.QQVIP_VIP, "open"},
	BtnGet3 = {Player.QQVIP_SVIP, "day"},
	BtnGet4 = {Player.QQVIP_SVIP, "open"},
};

for szBtnName, tbinfo in pairs(tbBtn2Op) do
	tbUi.tbOnClick[szBtnName] = function (self)
		Sdk:Ask4QQVipAward(tbinfo[1], tbinfo[2]);
	end
end
