require "Core.Module.Common.Panel"

local CloudPurchaseBuyPanel = class("CloudPurchaseBuyPanel", Panel);
function CloudPurchaseBuyPanel:New()
	self = {};
	setmetatable(self, {__index = CloudPurchaseBuyPanel});
	return self
end


function CloudPurchaseBuyPanel:_Init()
	
	self:_InitReference();
	self:_InitListener();
	self._count = 1
	self._money = MoneyDataManager.Get_gold()
	self._txtXianyu.text = MoneyDataManager.Get_gold()
	self._cost = CloudPurchaseManager.GetTodayConfig().cost	
	self._txtPrice.text = self._cost
	self._txtUsenum.text = tostring(self._count)
end

function CloudPurchaseBuyPanel:_InitReference()
	
	self._txtXianyu = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtXianyu");
	self._txtPrice = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtPrice");
	self._txtUsenum = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtUsenum");
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
	self._btn_min = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_min");
	self._btn_sub = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_sub");
	self._btn_add = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_add");
	self._btn_max = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_max");
	self._btnOk = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnOk");
end

function CloudPurchaseBuyPanel:_InitListener()
	self:_AddBtnListen(self._btn_close.gameObject)
	self:_AddBtnListen(self._btn_min.gameObject)
	self:_AddBtnListen(self._btn_sub.gameObject)
	self:_AddBtnListen(self._btn_add.gameObject)
	self:_AddBtnListen(self._btn_max.gameObject)
	self:_AddBtnListen(self._btnOk.gameObject)
	self:_AddBtnListen(self._txtUsenum.gameObject)
	
end

function CloudPurchaseBuyPanel:_OnBtnsClick(go)
	if go == self._btn_close.gameObject then
		self:_OnClickBtn_close()
	elseif go == self._btn_min.gameObject then
		self:_OnClickBtn_min()
	elseif go == self._btn_sub.gameObject then
		self:_OnClickBtn_sub()
	elseif go == self._btn_add.gameObject then
		self:_OnClickBtn_add()
	elseif go == self._btn_max.gameObject then
		self:_OnClickBtn_max()
	elseif go == self._btnOk.gameObject then
		self:_OnClickBtnOk()
	elseif go == self._txtUsenum.gameObject then
		self:_OnClickBtnTxt()
	end
end

function CloudPurchaseBuyPanel:_OnClickBtnTxt()
	local res = {};
	res.hd = CloudPurchaseBuyPanel._NumberKeyHandler;
	res.confirmHandler = CloudPurchaseBuyPanel._ConfirmHandler;
	res.hd_target = self;
	res.x = 0;
	res.y = 55;
	res.label = self._txtUsenum
	
	ModuleManager.SendNotification(NumInputNotes.OPEN_NUMINPUT, res);
end

function CloudPurchaseBuyPanel:_NumberKeyHandler(v)
	self._count = tonumber(v)
	self:_CheckBuyCount()
	self._txtUsenum.text = tostring(self._count)
end

function CloudPurchaseBuyPanel:_ConfirmHandler(v)
	self._count = tonumber(v)
	self:_CheckBuyCount()
	self._txtUsenum.text = tostring(self._count)
end

function CloudPurchaseBuyPanel:_OnClickBtn_close()
	ModuleManager.SendNotification(CloudPurchaseNotes.CLOSE_CLOUDPURCHASEBUYPANEL)
end

function CloudPurchaseBuyPanel:_OnClickBtn_min()
	self._count = 1
	self._txtUsenum.text = tostring(self._count)
end

function CloudPurchaseBuyPanel:_OnClickBtn_sub()
	self._count = self._count - 1
	self:_CheckBuyCount()
	self._txtUsenum.text = tostring(self._count)
	
	
end

function CloudPurchaseBuyPanel:_OnClickBtn_add()
	self._count = self._count + 1
	self:_CheckBuyCount()
	self._txtUsenum.text = tostring(self._count)
end

function CloudPurchaseBuyPanel:_OnClickBtn_max()
	self._count = math.floor(self._money / self._cost)
	self._txtUsenum.text = tostring(self._count)
end

function CloudPurchaseBuyPanel:_CheckBuyCount()
	if(self._count < 1) then
		self._count = 1
	elseif self._count > math.floor(self._money / self._cost) then
		self._count = math.floor(self._money / self._cost)
	end
end

function CloudPurchaseBuyPanel:_OnClickBtnOk()
	CloudPurchaseProxy.SendCloudPurchaseBuy(self._count)
end

function CloudPurchaseBuyPanel:_Dispose()
	self:_DisposeReference();
end

function CloudPurchaseBuyPanel:_DisposeReference()
	self._btn_close = nil;
	self._btn_min = nil;
	self._btn_sub = nil;
	self._btn_add = nil;
	self._btn_max = nil;
	self._btnOk = nil;
	self._txtTitle = nil;
	self._txtXianyu = nil;
	self._txtPrice = nil;
	self._txtUsenum = nil;
end
return CloudPurchaseBuyPanel 