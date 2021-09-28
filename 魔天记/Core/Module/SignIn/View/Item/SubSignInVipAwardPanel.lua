require "Core.Module.Common.UISubPanel";
require "Core.Module.Common.PropsItem";
require "Core.Module.Common.Phalanx";

SubSignInVipAwardPanel = class("SubSignInVipAwardPanel", UISubPanel);

--对接signPanel接口
function SubSignInVipAwardPanel:UpdatePanel()

end

function SubSignInVipAwardPanel:SetEnable(bool)
	if bool then
		self:Enable();
	else
		self:Disable();
	end
end

function SubSignInVipAwardPanel:_InitReference()

	self._trsNext = UIUtil.GetChildByName(self._transform, "Transform", "trsNext");
	self._trsNow = UIUtil.GetChildByName(self._transform, "Transform", "trsNow");

	self._txtVipNext = UIUtil.GetChildByName(self._trsNext, "UILabel", "txtVip");
	self._txtVipNow = UIUtil.GetChildByName(self._trsNow, "UILabel", "txtVip");

    self._trsPhalanx1 = UIUtil.GetChildByName(self._trsNext, "LuaAsynPhalanx", "phalanx");
    self._phalanx1 = Phalanx:New();
    self._phalanx1:Init(self._trsPhalanx1, PropsItem);

    self._trsPhalanx2 = UIUtil.GetChildByName(self._trsNow, "LuaAsynPhalanx", "phalanx");
    self._phalanx2 = Phalanx:New();
    self._phalanx2:Init(self._trsPhalanx2, PropsItem);

    self._btnGetAward = UIUtil.GetChildByName(self._trsNow, "UIButton", "btnGetAward");
    self._onClickBtn = function(go) self:_OnClickGetAwrad() end
    UIUtil.GetComponent(self._btnGetAward, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);

    self._icoStatus = UIUtil.GetChildByName(self._trsNow, "UISprite", "icoStatus");
    self._icoStatus.alpha = 0;
end

function SubSignInVipAwardPanel:_DisposeReference()
    self._phalanx1:Dispose();
    self._phalanx2:Dispose();

    UIUtil.GetComponent(self._btnGetAward, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;
end

function SubSignInVipAwardPanel:_InitListener()
    MessageManager.AddListener(SignInNotes, SignInNotes.ENV_VIP_DAILY_AWARD_RSP, SubSignInVipAwardPanel.UpdateDisplay, self);
end

function SubSignInVipAwardPanel:_DisposeListener()
    MessageManager.RemoveListener(SignInNotes, SignInNotes.ENV_VIP_DAILY_AWARD_RSP, SubSignInVipAwardPanel.UpdateDisplay);
end

function SubSignInVipAwardPanel:_OnEnable()
	self:UpdateDisplay();
end

function SubSignInVipAwardPanel:UpdateDisplay()
	local myVip = VIPManager.GetSelfVIPLevel();
	if myVip < 0 then
		myVip = 0;
	end
	
	local myVipCfg = VIPManager.GetConfigByLevel(myVip);
	local nextVipCfg = VIPManager.GetConfigByLevel(myVip+1) or myVipCfg;

	local nextAwards = TaskUtils.GetItemsByStrArr(nextVipCfg.daily_gift);
	self._phalanx1:Build(1, #nextAwards, nextAwards);
	self._txtVipNext.text = nextVipCfg.lev;

	if myVip > 0 then
		local nowAwards = TaskUtils.GetItemsByStrArr(myVipCfg.daily_gift);
		self._txtVipNow.text = myVipCfg.lev;
		self._phalanx2:Build(1, #nowAwards, nowAwards);
		self._trsNow.gameObject:SetActive(true);

		local canGet = VIPManager.CanGetDailyAward();
		self._btnGetAward.gameObject:SetActive(canGet);
		self._icoStatus.alpha = canGet and 0 or 1;

		if myVip < VIPManager.GetMaxVipLevel() then
			Util.SetLocalPos(self._trsNow, 117, -47, 0);
			self._trsNext.gameObject:SetActive(true);
		else
			Util.SetLocalPos(self._trsNow, 117, 205, 0);
			self._trsNext.gameObject:SetActive(false);
		end
	else
		self._trsNow.gameObject:SetActive(false);
	end
end

function SubSignInVipAwardPanel:_OnClickGetAwrad()
	SignInProxy.ReqGetVipDailyAward();
end