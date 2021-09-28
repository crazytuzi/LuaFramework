require "Core.Module.Common.Panel"

local CashGiftsPanel = class("CashGiftsPanel", Panel);
local CashGiftsItem = require "Core.Module.CashGift.View.CashGiftsItem"
function CashGiftsPanel:New()
	self = {};
	setmetatable(self, {__index = CashGiftsPanel});
	return self
end


function CashGiftsPanel:_Init()
	CashGiftProxy.SendGetClashGiftsInfo()
	self:_InitReference();
	self:_InitListener();
	self:UpdatePanel()
end

function CashGiftsPanel:_InitReference()
	self._txtTime = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtTime");	
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");	
	
	self._items = {}
	for i = 1, 3 do
		local temp = UIUtil.GetChildByName(self._trsContent, "item" .. i)
		self._items[i] = CashGiftsItem:New()
		self._items[i]:Init(temp)
	end
	
end

function CashGiftsPanel:_InitListener()
	self:_AddBtnListen(self._btn_close.gameObject)
end

function CashGiftsPanel:_OnBtnsClick(go)
	if go == self._btn_close.gameObject then
		self:_OnClickBtn_close()
	end
end

function CashGiftsPanel:_OnClickBtn_close()
	ModuleManager.SendNotification(CashGiftNotes.CLOSE_CASHGIFTSPANEL)
end
local _GetTimeByStr = GetTimeByStr
function CashGiftsPanel:UpdatePanel()
	
	local config = CashGiftsManager.GetTodayConfig()
	
	self._txtTime.text = os.date("%Y-%m-%d %H:%M:%S", config.startTime) .. "--" .. os.date("%Y-%m-%d %H:%M:%S", config.endTime)
	for i = 1, 3 do		
		self._items[i]:UpdateItem(config.rechargeItem[i])
	end
end

function CashGiftsPanel:_Dispose()
	self:_DisposeReference();
	for i = 1, 3 do
		self._items[i]:Dispose()
	end
	self._items = nil
end

function CashGiftsPanel:_DisposeReference()
	self._btn_close = nil;
	self._btncharge = nil;
	self._btncharge = nil;
	self._btncharge = nil;
	self._txtTime = nil;
end
return CashGiftsPanel 