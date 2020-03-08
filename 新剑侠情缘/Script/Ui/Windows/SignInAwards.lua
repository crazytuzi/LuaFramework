local tbUi 		= Ui:CreateClass("SignInAwards");
local tbItem 	= Ui:CreateClass("SignInAwardsItem");

local ITEM_NUM = 6;	--一行有几个道具格子
local tbDayNum = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
local function GetDayNumOfMonth(nCurTime)
	local tbCurTime = os.date("*t", nCurTime - SignInAwards.TIME_OFFSET);
	if (tbCurTime.month == 2) and (tbCurTime.year == 2016 or tbCurTime.year == 2020) then
		return tbDayNum[2] + 1;
	end

	return tbDayNum[tbCurTime.month];
end

local function GetAwards(nIdx)
	if type(nIdx) ~= "number" or nIdx < 1 or nIdx > me.GetUserValue(SignInAwards.SIGNIN_AWARD_GROUP, SignInAwards.LOGIN_DAYS) then
		return;
	end

	local bGetAvailable = SignInAwards:CheckState(nIdx);
	if not bGetAvailable then
		return;
	end

	Log("SignInAwards TrygetAwards", nIdx)
	local nLaunchPlatform = Sdk:GetValidLaunchPlatform();
	RemoteServer.GetSignInAwards(nIdx, nLaunchPlatform);
end

function tbUi:OnOpen()
	self:Refresh();
end

function tbUi:Refresh()
	local tbTemp = {};

	local fnSetItem = function(itemObj, nIdx)
		itemObj:Update(nIdx);
	end

	local nCellNum = math.ceil(GetDayNumOfMonth(GetTime()) / ITEM_NUM);
	self.ScrollView:Update(nCellNum, fnSetItem);
	self:SetSignInNum();

	local nQQVip = me.GetQQVipInfo();
	if nQQVip == Player.QQVIP_SVIP then
		self.pPanel:Sprite_SetSprite("MemberIcon", "VQQIcon");
		self.pPanel:Label_SetText("MemberTxt", "超级会员每日可获得额外登录礼包");
	elseif nQQVip == Player.QQVIP_VIP then
		self.pPanel:Sprite_SetSprite("MemberIcon", "QQIcon");
		self.pPanel:Label_SetText("MemberTxt", "QQ会员每日可获得额外登录礼包");
	end
	self.pPanel:SetActive("MemberTxt", nQQVip ~= Player.QQVIP_NONE and not IOS and not Sdk:IsOuterChannel());

	local nLaunchPlat = Sdk:GetValidLaunchPlatform();
	self.pPanel:SetActive("GameCenterTxt1", nLaunchPlat ~= Sdk.ePlatform_None);
	if Sdk.Def.tbPlatformIcon[nLaunchPlat] then
		self.pPanel:Sprite_SetSprite("GameCenterIcon1", Sdk.Def.tbPlatformIcon[nLaunchPlat]);
		local _, szEmo = Shop:GetMoneyName("Contrib");
		local szTips = "手Q游戏中心启动专享，额外奖励: 50";
		if nLaunchPlat == Sdk.ePlatform_Weixin then
			szTips = "微信游戏特权专享，额外奖励: 50";
		elseif nLaunchPlat == Sdk.ePlatform_Guest then
			szTips = "游客登录专享，额外奖励: 50";
		end
		self.pPanel:Label_SetText("GameCenterTxt1", szTips .. szEmo);
	end
end

function tbUi:SetSignInNum()
	local nSignInNum = 0;
	local nDays = me.GetUserValue(SignInAwards.SIGNIN_AWARD_GROUP, SignInAwards.LOGIN_DAYS);
	local nFlag = me.GetUserValue(SignInAwards.SIGNIN_AWARD_GROUP, SignInAwards.NORMAL_FLAG);
	for idx = 1, nDays do
		if Lib:LoadBits(nFlag, idx - 1, idx - 1) == 1 then
			nSignInNum = nSignInNum + 1;
		end
	end
	self.pPanel:Label_SetText("Title", string.format("[-]本月累积签到 [5AE800]%d[-] 次", nSignInNum));

	local nCurCell = math.ceil(nDays/ITEM_NUM)
	self.ScrollView.pPanel:ScrollViewGoToIndex("Main", nCurCell)
end

-------------------------------------------ScrollViewItem-------------------------------------------
tbItem.tbOnClick = {};
for i = 1, ITEM_NUM do
	tbItem.tbOnClick["Awards" .. i] = function (self)
		GetAwards((self.nIdx - 1) * ITEM_NUM + i);
	end
end

function tbItem:Update(nIdx)
	self.nIdx 		= nIdx;

	self:UpdateCell();
end

function tbItem:UpdateCell()
	local nDayNum = GetDayNumOfMonth(GetTime());
	local nBeginIdx = (self.nIdx - 1) * ITEM_NUM;

	for nIdx = 1, ITEM_NUM do
		local nTrueIdx = nBeginIdx + nIdx;
		if nTrueIdx > nDayNum then
			self.pPanel:SetActive(string.format("Awards%d", nIdx), false);
		else
			self.pPanel:SetActive(string.format("Awards%d", nIdx), true);
			self:UpdateItemFrame(nTrueIdx, nIdx);
		end
	end
end

function tbItem:UpdateItemFrame(nTrueIdx, nIdx)
	local tbAwardsInfo = SignInAwards:GetAwardInfo(nTrueIdx);
	local bGetAvailable, bToday, bMark = SignInAwards:CheckState(nTrueIdx);

	if bGetAvailable then
		self["itemframe" .. nIdx].fnClick = function ()
			GetAwards(nTrueIdx);
		end
	else
		self["itemframe" .. nIdx].fnClick = self["itemframe" .. nIdx].DefaultClick;
	end
	self.pPanel:SetActive(string.format("Available%d", nIdx), bToday and bGetAvailable);	--今日可领特效
	self.pPanel:SetActive(string.format("TagGeted%d", nIdx), bMark);
	self.pPanel:SetActive(string.format("mask%d", nIdx), bMark);
	self.pPanel:SetActive(string.format("VipTag%d", nIdx), tbAwardsInfo.nVipLevel > 0);
	if tbAwardsInfo.nVipLevel > 0 then
		if version_vn then
			self.pPanel:Label_SetText(string.format("VipLabel%d", nIdx), string.format("KH%d", tbAwardsInfo.nVipLevel));
		else
			self.pPanel:Label_SetText(string.format("VipLabel%d", nIdx), string.format("尊%d", tbAwardsInfo.nVipLevel));
		end
	end

	self["itemframe" .. nIdx]:SetGenericItem(tbAwardsInfo.tbAwards);
end

