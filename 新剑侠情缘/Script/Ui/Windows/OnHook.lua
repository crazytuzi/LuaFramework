local OnHookPanel = Ui:CreateClass("OnHook");
OnHookPanel.szBasePanel = "Panel1";
OnHookPanel.szTipPanel = "Panel2";
OnHookPanel.tbSpecialPayUI = 
{
	["SpecialRemainingTime1"] = true,
	["Toggle3"] = true,
	["IconTips1"] = true,
	["SpecialRemainingTime2"] = true,
	["IconTips3"] = true,
}

OnHookPanel.nBaiJuWanIconId = 1021
OnHookPanel.nSpecialBaiJuWanIconId = 1022

function OnHookPanel:OnOpen()
	Ui:ClearRedPointNotify("OnHook_GetExp");
	self:Update();
end

function OnHookPanel:Update()
	local nExpTime = OnHook:ExpTime(me);
	local nBaiJuWanTime = OnHook:BaiJuWanTime(me);
	local nSpecialBaiJuWanTime = OnHook:SpecialBaiJuWanTime(me);
	local nOnHookTime = OnHook:GetOnHookTime(me); 
	
	 self.pPanel:Label_SetText("RemaindHostingTime", string.format("%s",Lib:TimeDesc8(nOnHookTime)));
	 self.pPanel:Label_SetText("HostingTime", string.format("%s",Lib:TimeDesc8(nExpTime)));
	 self.pPanel:Label_SetText("RemainingTime1", string.format("%s",Lib:TimeDesc8(nBaiJuWanTime)));
	 self.pPanel:Label_SetText("SpecialRemainingTime1", string.format("%s",Lib:TimeDesc8(nSpecialBaiJuWanTime)));

	 local nSpecialBJWExpTime = OnHook:CheckSpecialPayType(me) and (nSpecialBaiJuWanTime > nExpTime and nExpTime or nSpecialBaiJuWanTime)
	 local nAddSpecialPayExp = OnHook:NowExp(me,OnHook.OnHookType.SpecialPay,nSpecialBJWExpTime)
	 nAddSpecialPayExp = me.TrueChangeExp(nAddSpecialPayExp, true);
	 local szSpecialPayTip = string.format("特效白驹丸托管（[FFFE0D]%s倍经验[-]）获得经验：[ff4cfd]%d[-]",OnHook.fSpecialPayGetExpRate,math.floor(nAddSpecialPayExp))
	 if OnHook:CheckIsShowSpecialTip(me) then
	 	szSpecialPayTip = szSpecialPayTip ..OnHook:PayTips(me,OnHook.OnHookType.SpecialPay);
	 end

	 local nAddPayExp = OnHook:NowExp(me,OnHook.OnHookType.Pay)
	 nAddPayExp = me.TrueChangeExp(nAddPayExp, true);
	 local szPayTip = string.format("白驹丸托管（[FFFE0D]%s倍经验[-]）获得经验：[ff4cfd]%d[-]",OnHook.fPayGetExpRate,math.floor(nAddPayExp))
	 szPayTip = szPayTip ..OnHook:PayTips(me,OnHook.OnHookType.Pay);

	 local nAddFreeExp = OnHook:NowExp(me,OnHook.OnHookType.Free)
	 nAddFreeExp = me.TrueChangeExp(nAddFreeExp, true);
	 local szFreeTip = string.format("免费托管（[FFFE0D]%s倍经验[-]）获得经验：[ff4cfd]%d[-]",OnHook.fFreeGetExpRate,math.floor(nAddFreeExp));

	 self.pPanel:Label_SetText("ToggleTxt1", szPayTip);
	 self.pPanel:Label_SetText("ToggleTxt2", szFreeTip);
	 self.pPanel:Label_SetText("ToggleTxt3", szSpecialPayTip);

	 self.pPanel:SetActive(self.szTipPanel,false)
	 self.pPanel:SetActive(self.szBasePanel,true)
	 self.pPanel:SetActive("RemaindHostingTime",OnHook.OnHookTimePerDay < 24 * 60 * 60)

	 local bIsSpecialBaiJuWanOpen = OnHook:CheckSpecialBaiJuWanIsOpen(me);
	 for szUIName,_ in pairs(self.tbSpecialPayUI) do
	 	self.pPanel:SetActive(szUIName,bIsSpecialBaiJuWanOpen)
	 end

	 local nOnHookToggle = Client:GetFlag("nOnHookToggle")
	 nOnHookToggle = nOnHookToggle or 2 							-- 默认免费

	 -- 目前特效白驹丸的显示规则会导致特效选项时而显示时而隐藏，显示领取之后隐藏默认选中免费
	 if nOnHookToggle == 3 and not OnHook:CheckSpecialBaiJuWanIsOpen(me) then
	 	nOnHookToggle = 2
	 end

	 self.pPanel:Toggle_SetChecked("Toggle2",  nOnHookToggle == 2);  -- 免费
	 self.pPanel:Toggle_SetChecked("Toggle1",  nOnHookToggle == 1);  -- 白驹
	 self.pPanel:Toggle_SetChecked("Toggle3",  nOnHookToggle == 3);	 -- 特效白驹

	 local szBaiJuWanIconAtlas, szBaiJuWanIconSprite = Item:GetIcon(self.nBaiJuWanIconId);
	 local szSpecialBaiJuWanIconAtlas, szSpecialBaiJuWanIconSprite = Item:GetIcon(self.nSpecialBaiJuWanIconId);

	 self.pPanel:Sprite_SetSprite("ItemLayer",szBaiJuWanIconSprite, szBaiJuWanIconAtlas)
	 self.pPanel:Sprite_SetSprite("ItemLayer1",szSpecialBaiJuWanIconSprite, szSpecialBaiJuWanIconAtlas)
	 self.pPanel:Sprite_SetSprite("ItemLayer2",szBaiJuWanIconSprite, szBaiJuWanIconAtlas)
	 self.pPanel:Sprite_SetSprite("ItemLayer3",szSpecialBaiJuWanIconSprite, szSpecialBaiJuWanIconAtlas)

	 local _, _, _, nQuality = Item:GetItemTemplateShowInfo(OnHook.nBaiJuWanId, me.nFaction, me.nSex);
	 local szIcon   = Item.tbQualityColor[nQuality] or Item.DEFAULT_COLOR;
     self.pPanel:Sprite_SetSprite("Color", szIcon);

     local _, _, _, nQuality1 = Item:GetItemTemplateShowInfo(OnHook.nSpecialBaiJuWanId, me.nFaction, me.nSex);
     local szIcon1   = Item.tbQualityColor[nQuality1] or Item.DEFAULT_COLOR;
     self.pPanel:Sprite_SetSprite("Color1", szIcon1);

	 local bIsHaveExpTime = OnHook:IsHaveExpTime(me);
	 self.pPanel:SetActive(self.szBasePanel,bIsHaveExpTime);
	 self.pPanel:SetActive(self.szTipPanel,not bIsHaveExpTime);

	 local nHave = me.GetItemCountInAllPos(Activity.Winter:GetJiaoZiItemId())
	 self.pPanel:SetActive("SpecialTips",nHave > 0);

	 -- local nVipAddition = OnHook:GetVipAddition(me)
	 -- local nPercent = nVipAddition - 1
	 -- local szPercent = (nPercent * 100) .."%"
	 -- local szVipAddition = string.format("剑侠尊享%d离线托管经验增加%s",me.GetVipLevel(),szPercent)
	 local szDesc = Recharge:GetVipPrivilegeDesc("OnHook")
	 self.pPanel:SetActive("VipExp", szDesc or false)
	 self.pPanel:Label_SetText("VipExp", szDesc or "")

	 self:UpdateTip();
end

function OnHookPanel:OnClose()

end

function OnHookPanel:UpdateFlag()
	local nOnHookToggle
	if self.pPanel:Toggle_GetChecked("Toggle1") then
		nOnHookToggle = 1
	elseif self.pPanel:Toggle_GetChecked("Toggle2") then
		nOnHookToggle = 2
	elseif self.pPanel:Toggle_GetChecked("Toggle3") then
		nOnHookToggle = 3
	end
	if nOnHookToggle then
		Client:SetFlag("nOnHookToggle", nOnHookToggle)
	end
end

function OnHookPanel:UpdateTip()
	
	local nOnHookTime = OnHook:GetOnHookTime(me); 
	self.pPanel:Label_SetText("TodayHostingTime", string.format("%s",Lib:TimeDesc8(nOnHookTime)));

	local nBaiJuWanTime = OnHook:BaiJuWanTime(me);
	self.pPanel:Label_SetText("RemainingTime2", string.format("%s",Lib:TimeDesc8(nBaiJuWanTime)));

	local nSpecialBaiJuWanTime = OnHook:SpecialBaiJuWanTime(me);
	self.pPanel:Label_SetText("SpecialRemainingTime2", string.format("%s",Lib:TimeDesc8(nSpecialBaiJuWanTime)));

	local szTip = string.format("[FFFFFF]1、离线[-][FFFE0D]%s钟[-][FFFFFF]后自动进行离线托管，持续累积离线时间\n",Lib:TimeDesc8(OnHook.nDelayTime))
	szTip = szTip ..string.format("2、离线托管时间最多可累积至[-][FFFE0D]%d小时[-][FFFFFF]\n", OnHook.MaxExpTime/3600)
	szTip = szTip ..string.format("[FFFFFF]3、达到[FFFE0D]等级上限且经验100%%[-][FFFFFF]后领取仅可获得所领取离线经验的[FFFE0D]50%%[-]");
	self.pPanel:Label_SetText("LabelRules", szTip);

	 local _, _, _, nQuality2 = Item:GetItemTemplateShowInfo(OnHook.nBaiJuWanId, me.nFaction, me.nSex);
	 local szIcon2   = Item.tbQualityColor[nQuality2] or Item.DEFAULT_COLOR;
     self.pPanel:Sprite_SetSprite("Color2", szIcon2);

     local _, _, _, nQuality3 = Item:GetItemTemplateShowInfo(OnHook.nSpecialBaiJuWanId, me.nFaction, me.nSex);
     local szIcon3   = Item.tbQualityColor[nQuality3] or Item.DEFAULT_COLOR;
     self.pPanel:Sprite_SetSprite("Color3", szIcon3);
	
end

OnHookPanel.tbOnClick = {
	BtnGet = function (self)
		local bCheckToggle1 = self.pPanel:Toggle_GetChecked("Toggle1");
		local nGetType = bCheckToggle1 and OnHook.OnHookType.Pay or OnHook.OnHookType.Free;
		local bCheckToggle3 = self.pPanel:Toggle_GetChecked("Toggle3");
		if bCheckToggle3 and OnHook:CheckSpecialBaiJuWanIsOpen(me) then
			nGetType = OnHook.OnHookType.SpecialPay;
		end
		local bRet,szMsg = OnHook:CheckCommond(me);
		if not bRet then
			me.CenterMsg(szMsg);
			return 
		end

		local fnGet = function ()
			RemoteServer.GetOnHookExp(nGetType);
			self:UpdateFlag()
		end

		if OnHook:CheckIsMaxOpenLevel(me) then
			me.MsgBox(string.format("[FFFE0D]少侠已达到等级上限，领取的经验将减半。[-]\n确定要领取离线经验吗？"), {{"确认", fnGet, self}, {"取消"}});
			return
		end

		RemoteServer.GetOnHookExp(nGetType);
		self:UpdateFlag()
	end,
	IconTips = function(self)
		Ui:OpenWindow("ItemTips", "Item", nil, OnHook.nBaiJuWanId);
	end,
	IconTips1 = function(self)
		Ui:OpenWindow("ItemTips", "Item", nil, OnHook.nSpecialBaiJuWanId);
	end,
	IconTips2 = function(self)
		Ui:OpenWindow("ItemTips", "Item", nil, OnHook.nBaiJuWanId);
	end,
	IconTips3 = function(self)
		Ui:OpenWindow("ItemTips", "Item", nil, OnHook.nSpecialBaiJuWanId);
	end,

}
