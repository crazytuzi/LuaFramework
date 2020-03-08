local MoneyTreePanel = Ui:CreateClass("MoneyTreePanel");
function MoneyTreePanel:OnOpen()
	self:Update();
	self:UpdateVipPrivilegeDesc()

	self.bNpcOpen = true;
	self.pPanel:NpcView_Open("ShowTree");
	self.pPanel:NpcView_ShowNpc("ShowTree", 379);
end

function MoneyTreePanel:OnClose()
	if self.bNpcOpen then
		self.bNpcOpen = false;
		self.pPanel:NpcView_Close("ShowTree");
	end
	if self.nTreeAniTimer then
		Timer:Close(self.nTreeAniTimer)
		self.nTreeAniTimer = nil
	end
	if self.nMoneyAniTimer then
		Timer:Close(self.nMoneyAniTimer)
		self.nMoneyAniTimer = nil
	end
	self.bShaking = false
	self:CloseTXNode()
end

function MoneyTreePanel:Update()
	local nFree = me.GetUserValue(MoneyTree.Def.SAVE_GROUP, MoneyTree.Def.FREE_SHAKE)
	local bHaveFree = nFree == 0

	local szText = string.format("免费摇动次数%d/1", bHaveFree and 1 or 0);
	self.pPanel:Label_SetText("Times", szText);

	self.pPanel:SetActive("Free", bHaveFree);
	self.pPanel:SetActive("OncePrice", not bHaveFree);
	if not bHaveFree then
		local nPrice = MoneyTree:GetShakePrice()
		self.pPanel:Label_SetText("OncePrice_Label", nPrice)
	end

	local nMultiPrice = MoneyTree:GetShakePrice(true, true)
	self.pPanel:Label_SetText("Price_Label", string.format("%d", nMultiPrice));

	local nLaunchPlat = Sdk:GetValidLaunchPlatform();
	self.pPanel:SetActive("GameCenterTxt2", nLaunchPlat ~= Sdk.ePlatform_None);
	if Sdk.Def.tbPlatformIcon[nLaunchPlat] then
		self.pPanel:Sprite_SetSprite("GameCenterIcon2", Sdk.Def.tbPlatformIcon[nLaunchPlat]);
		local szTips = "手Q游戏中心启动专享，额外多5%";
		if nLaunchPlat == Sdk.ePlatform_Weixin then
			szTips = "微信游戏特权专享，额外多5%"
		elseif nLaunchPlat == Sdk.ePlatform_Guest then
			szTips = "游客登录专享，额外多5%";
		end
		self.pPanel:Label_SetText("GameCenterTxt2", szTips);
	end

	local bHaveDiscount = me.GetUserValue(MoneyTree.Def.SAVE_GROUP, MoneyTree.Def.DISCOUNT_TIMES) > 0
	self.pPanel:SetActive("DiscountPrice", bHaveDiscount)
	self.pPanel:ChangePosition("Price", bHaveDiscount and -60 or -25, -13)
	self.pPanel:SetActive("Price_Dis_Sprite", bHaveDiscount)
end

function MoneyTreePanel:UpdateVipPrivilegeDesc()
	local szDesc = Recharge:GetVipPrivilegeDesc("MoneyTree") or ""
	self.pPanel:Label_SetText("MoneyTreeVip", szDesc)
end

function MoneyTreePanel:OnRespond(tbGainCoin)
	self.tbAwardList = self.tbAwardList or {}
	table.insert(self.tbAwardList, tbGainCoin)

	self:ShakeTree();
	self:Update()
end

function MoneyTreePanel:PlayTreeNormalAnimation()
	if not self.pPanel then
		self.nTreeAniTimer = nil
		return
	end
	self.pPanel:NpcView_PlayAnimation("ShowTree", "st", 2, true);
	self.nTreeAniTimer = nil
end

function MoneyTreePanel:ShakeTree()
	if self.bShaking then
		return
	end

	self.tbAward = table.remove(self.tbAwardList, 1)
	if not self.tbAward then
		return
	end

	self.bMultiShake = #self.tbAward > 1
	self.bShaking = true
	self.pPanel:NpcView_PlayAnimation("ShowTree", "at01", 2, true);
	self:PlayMoneyAnimation()
	if self.bMultiShake then
		self.pPanel:SetActive("texiao1", true)
		self.pPanel:SetActive("texiao", false)
		self.nMoneyAniTimer = Timer:Register(Env.GAME_FPS * 0.7, self.PlayMoneyAnimation, self)
		self.nTreeAniTimer = Timer:Register(Env.GAME_FPS * 4.5, self.PlayTreeNormalAnimation, self)
	else
		self.pPanel:SetActive("texiao1", false)
		self.pPanel:SetActive("texiao", true)
		self.nMoneyAniTimer = Timer:Register(Env.GAME_FPS * 2, self.PlayMoneyAnimation, self)
		self.nTreeAniTimer = Timer:Register(Env.GAME_FPS * 2, self.PlayTreeNormalAnimation, self)
	end
end

function MoneyTreePanel:PlayMoneyAnimation()
	if not self.pPanel then --self.pPanel可能会销毁，这里加个保护
		self.nMoneyAniTimer = nil
		return
	end
	if #self.tbAward == 0 then
		self.bShaking = false
		self:CloseTXNode()
		self.nMoneyAniTimer = nil
		if #self.tbAwardList > 0 then
			self:ShakeTree()
		end
		return
	end

	local nAward = table.remove(self.tbAward, 1)
	local nIdx = MoneyTree:GetMoneyIdx(nAward) or 1
	for i = 1, 3 do
		self.pPanel:SetActive("p" .. i, nIdx == i)
		if nIdx == i then
			self.pPanel:Label_SetText("Txt_P" .. i, "+" .. nAward)
		end
	end

	self.pPanel:Tween_Reset("p" .. nIdx)
	self.pPanel:Tween_Play("p" .. nIdx)
	return true
end

local function fnShakeMoneyTree(bMultiShake)
	local nShakeIdx = me.GetUserValue(MoneyTree.Def.SAVE_GROUP, MoneyTree.Def.SHAKE_TIMES)
	local bLaunchExtra = Sdk:GetValidLaunchPlatform() ~= Sdk.ePlatform_None;
	RemoteServer.MoneyTreeShake(bMultiShake, nShakeIdx, bLaunchExtra)
	Log("MoneyTree TryShakeTree", tostring(bMultiShake), nShakeIdx)
end

function MoneyTreePanel:ShakePayOnce()
	local OnOk = function ()
	    fnShakeMoneyTree()
	end
	local bHad = Ui:CheckNotShowTips("MoneyTree_Once");
	if bHad then
		OnOk();
	else
		local _, szEmotion = Shop:GetMoneyName("Gold")
		local nPrice = MoneyTree:GetShakePrice()
		local szMsg = string.format("确定要花费 [FFFE0D]%d%s[-] 摇动一次吗？", nPrice, szEmotion);
		Ui:OpenWindow("MessageBox", szMsg, {{OnOk},{}}, nil, "MoneyTree_Once");
	end
end

function MoneyTreePanel:CloseTXNode()
	for i = 1, 3 do
		self.pPanel:SetActive("p" .. i, false)
	end
	self.pPanel:SetActive("texiao1", false)
	self.pPanel:SetActive("texiao", false)
end

MoneyTreePanel.tbOnClick = {
	["Once"] = function (self)
		local nFree = me.GetUserValue(MoneyTree.Def.SAVE_GROUP, MoneyTree.Def.FREE_SHAKE)
		if nFree == 0 then
			fnShakeMoneyTree()
		else
			self:ShakePayOnce();
		end
	end,

	["TenTimes"] = function (self)
		local OnOk = function ()
		    fnShakeMoneyTree(true)
		end

		local bHad = Ui:CheckNotShowTips("MoneyTree_Ten");
		if bHad then
			OnOk();
		else
			local _, szEmotion = Shop:GetMoneyName("Gold")
			local nPrice = MoneyTree:GetShakePrice(true)
			local szMsg = string.format("确定要花费 [FFFE0D]%d%s[-] 摇动 [FFFE0D]10次[-] 吗？", nPrice, szEmotion)
			Ui:OpenWindow("MessageBox", szMsg, {{OnOk},{}}, nil, "MoneyTree_Ten");
		end
	end
};
