require "Core.Module.Common.Panel"
require "Core.Module.Lottery.View.Item.LotteryRewardItem"
require "Core.Module.Common.CoinBar"

local BuyIconItem = require "Core.Module.Lottery.View.Item.BuyIconItem"
local LotteryRecorderItem = require "Core.Module.Lottery.View.Item.LotteryRecorderItem"


LotteryPanel = class("LotteryPanel", Panel);
local free = LanguageMgr.Get("Lottery/LotteryPanel/free")
local buyFree = LanguageMgr.Get("Lottery/LotteryPanel/buyFree")

local freeNotice = LanguageMgr.Get("Lottery/LotteryPanel/freeNotice")
local BaseIconItem = require "Core.Module.Common.BaseIconItem"
function LotteryPanel:New()
	self = {};
	setmetatable(self, {__index = LotteryPanel});
	return self
end


function LotteryPanel:_Init()
	self._isInit = true
	self._recorder = {}
	self:_InitReference();
	self:_InitListener();
	self:_InitLotteryItem()
end

local xAdd = {0, 1, 2, 3, 4, 4, 4, 3, 2, 1, 0, 0}
local yAdd = {0, 0, 0, 0, 0, 1, 2, 2, 2, 2, 2, 1}
function LotteryPanel:_InitLotteryItem()
	local count = 12
	local xSpace = 200
	local ySpace = 125
	local originPos = self._lotteryItemPrefab.transform.localPosition
	
	self._items = {}
	local itemConfig = LotteryManager.GetLotteryShowReward()
	for i = 1, count do
		local item = NGUITools.AddChild(self._goItemParent, self._lotteryItemPrefab)
		item.transform.localPosition = originPos + Vector3.right * xSpace * xAdd[i] + Vector3.down * ySpace * yAdd[i]
		self._items[i] = BaseIconItem:New()
		self._items[i]:Init(item, itemConfig[i])
	end
	
	self._lotteryItemPrefab:SetActive(false)
end


function LotteryPanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
	self._txtSliderValue = UIUtil.GetChildInComponents(txts, "txtSliderValue");
	self._txtLottery10 = UIUtil.GetChildInComponents(txts, "txtLottery10");
	self._txtLottery = UIUtil.GetChildInComponents(txts, "txtLottery");
	self._txtLottery50 = UIUtil.GetChildInComponents(txts, "txtLottery50");
	
	self._txtLotteryDes = UIUtil.GetChildInComponents(txts, "txtLotteryDes");
	self._txtBuyNotice = UIUtil.GetChildInComponents(txts, "txtBuyNotice");
	self._txtNotice = UIUtil.GetChildInComponents(txts, "notice")
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
	self._btnLottery10 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnLottery10");
	self._btnLottery = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnLottery");
	self._btnLottery50 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnLottery50");
	
	
	self._sliderLucky = UIUtil.GetChildByName(self._trsContent, "UISlider", "sliderLuckyPoint")
	self._trsCoinBar = UIUtil.GetChildByName(self._trsContent, "Transform", "trsCoinBar");
	-- self._trsItem = UIUtil.GetChildByName(self._trsContent, "item")
	-- self._item = LotteryRewardItem:New()
	-- self._item:Init(self._trsItem.gameObject)
	local itemConfigs = LotteryManager.GetShowItemConfig()
	local item1 = UIUtil.GetChildByName(self._trsContent, "item1").gameObject
	self._item1 = BuyIconItem:New()
	self._item1:Init(item1, itemConfigs[1])
	
	local item2 = UIUtil.GetChildByName(self._trsContent, "item2").gameObject	
	self._item2 = BuyIconItem:New()
	self._item2:Init(item2, itemConfigs[2])
	
	self._coinBarCtrl = CoinBar:New(self._trsCoinBar)
	self._timer = Timer.New(function(val) self:_OnUpdata(val) end, 1, - 1, false);
	self._cdTime = LotteryManager.GetCdTime()
	self._lotteryItemPrefab = UIUtil.GetChildByName(self._trsContent, "itemParent/item").gameObject
	self._goItemParent = UIUtil.GetChildByName(self._trsContent, "itemParent").gameObject
	self:_OnUpdata()
	
	self._phalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "textListBg/phalanx")
	self._phalanx = Phalanx:New()
	self._phalanx:Init(self._phalanxInfo, LotteryRecorderItem)
end

function LotteryPanel:_OnUpdata(val)
	if(self._cdTime > 0) then
		self._cdTime = self._cdTime - 1
		self._txtBuyNotice.text = string.format(freeNotice, GetTimeByStr(self._cdTime))
	else
		self._txtBuyNotice.text = buyFree
		self._timer:Stop()
	end
end

function LotteryPanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
	self._onClickBtnLottery10 = function(go) self:_OnClickBtnLottery10(self) end
	UIUtil.GetComponent(self._btnLottery10, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnLottery10);
	self._onClickBtnLottery = function(go) self:_OnClickBtnLottery(self) end
	UIUtil.GetComponent(self._btnLottery, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnLottery);
	self._onClickBtnLottery50 = function(go) self:_OnClickBtnLottery50(self) end
	UIUtil.GetComponent(self._btnLottery50, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnLottery50);
	MessageManager.AddListener(LotteryManager, LotteryManager.LOTTERY_RECORDER, LotteryPanel.AddLotteryRecorder, self)
end

function LotteryPanel:_OnClickBtn_close()
	ModuleManager.SendNotification(LotteryNotes.CLOSE_LOTTERYPANEL)
end

function LotteryPanel:_OnClickBtnLottery10()
	LotteryProxy.SendLottry(1, LotteryManager.GetSpendGoldTenLottery())
end

function LotteryPanel:_OnClickBtnLottery()
	
	LotteryProxy.SendLottry(0, LotteryManager.GetSpendGoldOneLottery())
end

function LotteryPanel:_OnClickBtnLottery50()
	LotteryProxy.SendLottry(2, LotteryManager.GetSpendGoldFiftyLottery())
end

function LotteryPanel:_Dispose()
	if(self._timer) then
		self._timer:Stop()
		self._timer = nil
	end
	
	self:_DisposeListener();
	self:_DisposeReference();
	self._coinBarCtrl:Dispose()
	self._coinBarCtrl = nil
	-- self._item:Dispose()
end

function LotteryPanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
	UIUtil.GetComponent(self._btnLottery10, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnLottery10 = nil;
	UIUtil.GetComponent(self._btnLottery, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnLottery = nil;
	UIUtil.GetComponent(self._btnLottery50, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnLottery50 = nil;
	
	
	MessageManager.RemoveListener(LotteryManager, LotteryManager.LOTTERY_RECORDER, LotteryPanel.AddLotteryRecorder, self)
	
end

function LotteryPanel:_DisposeReference()
	self._btn_close = nil;
	self._btnLottery10 = nil;
	self._btnLottery = nil;
	self._txtSliderValue = nil;
	self._txtSliderTitle = nil;
	self._txtLottery10 = nil;
	self._txtLottery = nil;
	self._txtBuyNotice = nil
	self._txtName = nil;
	
	self._trsCoinBar = nil;
	self._sliderLucky = nil
	
	for k, v in pairs(self._items) do
		local go = v.gameObject
		v:Dispose()
		Resourcer.Recycle(go, false)		
	end
	
	self._items = nil
end

function LotteryPanel:UpdatePanelInfo()
	if(self._isInit) then
		self._isInit = false
		local recoders = LotteryManager.GetLotteryRecorder()
		
		self._recorder = recoders
		self._phalanx:Build(#self._recorder, 1, self._recorder)
	end
	
	local luckyPoint = LotteryManager.GetLuckyPoint()
	local max = LotteryManager.GetLuckyPointUpper()
	luckyPoint = math.min(luckyPoint, max)
	self._txtSliderValue.text = luckyPoint .. "/" .. max
	self._sliderLucky.value = luckyPoint / max
	self._txtNotice.text = LanguageMgr.Get("Lottery/LotteryPanel/buyNotice", {name = LotteryManager.GetItemConfig().name})
	self._txtLottery10.text = LotteryManager.GetSpendGoldTenLottery()
	self._txtLottery50.text = LotteryManager.GetSpendGoldFiftyLottery()	
	self._txtLottery.text = LotteryManager.GetSpendGoldOneLottery()	
	self._cdTime = LotteryManager.GetCdTime()
	if(self._timer and not self._timer.running) then
		self._timer:Start()
	end
end

function LotteryPanel:AddLotteryRecorder(txt)
	if(self._recorder and(#self._recorder >= 30)) then
		table.remove(self._recorder, #self._recorder)	
	end
	table.insert(self._recorder, 1, txt)
	self._phalanx:Build(#self._recorder, 1, self._recorder)
end
