require "Core.Module.Common.Panel"
require "Core.Module.Lottery.View.Item.LotteryRewardItem"

LotteryResultPanel = class("LotteryResultPanel", Panel);
function LotteryResultPanel:New()
	self = {};
	setmetatable(self, {__index = LotteryResultPanel});
	return self
end

function LotteryResultPanel:GetUIOpenSoundName()
	return ""
end

function LotteryResultPanel:IsPopup()
	return false
end

function LotteryResultPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function LotteryResultPanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
	self._txtNotice = UIUtil.GetChildInComponents(txts, "txtNotice");
	self._txtContinueLottery = UIUtil.GetChildInComponents(txts, "txtContinueLottery");
	self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
	self._btnContinueLottery = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnContinueLottery");
	self._trsProduct = UIUtil.GetChildByName(self._trsContent, "Transform", "trsProduct");
	self._phalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "scrollview/reward_phalanx");
	self._phalanx = Phalanx:New()
	self._phalanx:Init(self._phalanxInfo, LotteryRewardItem)
	self._rewardItem = LotteryRewardItem:New()
	self._rewardItem:Init(self._trsProduct)
	self._scrollview = UIUtil.GetChildByName(self._trsContent, "UIScrollView", "scrollview")
	
end

function LotteryResultPanel:_InitListener()
	self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
	self._onClickBtnContinueLottery = function(go) self:_OnClickBtnContinueLottery(self) end
	UIUtil.GetComponent(self._btnContinueLottery, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnContinueLottery);
end

function LotteryResultPanel:_OnClickBtnClose()
	ModuleManager.SendNotification(LotteryNotes.CLOSE_LOTTERYRESULTPANEL)
end

function LotteryResultPanel:_OnClickBtnContinueLottery()
	local count = LotteryManager.GetGetLotteryRewardNum()
	if(count == 1) then
		LotteryProxy.SendLottry(0, LotteryManager.GetSpendGoldOneLottery())
	elseif count == 10 then
		LotteryProxy.SendLottry(1, LotteryManager.GetSpendGoldTenLottery())
	elseif count == 50 then
		LotteryProxy.SendLottry(2, LotteryManager.GetSpendGoldFiftyLottery())		
	end
end

function LotteryResultPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
	self._phalanx:Dispose()
	self._rewardItem:Dispose()
end

function LotteryResultPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;
	UIUtil.GetComponent(self._btnContinueLottery, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnContinueLottery = nil;
end

function LotteryResultPanel:_DisposeReference()
	self._btnClose = nil;
	self._btnContinueLottery = nil;
	self._txtNotice = nil;
	self._txtContinueLottery = nil;
	self._trsProduct = nil;
end

function LotteryResultPanel:UpdatePanel()
	self._scrollview:ResetPosition()
	self._scrollview:UpdatePosition()
	
	local rewards = LotteryManager.GetGetLotteryReward()
	self._txtNotice.text = LanguageMgr.Get("Lottery/LotteryResultPanel/buyNotice", {num = count, name = LotteryManager.GetItemConfig().name})
	local count = #rewards
	
	if(count == 1) then
		self._phalanx:Build(0, 0, {})
		self._trsProduct.gameObject:SetActive(true)
		self._rewardItem:UpdateItem(rewards[1])
		self._txtContinueLottery.text = LotteryManager.GetSpendGoldOneLottery()
	elseif count == 10 then
		self._trsProduct.gameObject:SetActive(false)
		self._phalanx:Build(2, 5, rewards)
		self._txtContinueLottery.text = LotteryManager.GetSpendGoldTenLottery()
	elseif count == 50 then		
		self._trsProduct.gameObject:SetActive(false)
		self._phalanx:Build(10, 5, rewards)
		self._txtContinueLottery.text = LotteryManager.GetSpendGoldFiftyLottery()
	end
end

function LotteryResultPanel:MoveNext()
	self._scrollview:MoveRelative(Vector3.up * 480)
end 