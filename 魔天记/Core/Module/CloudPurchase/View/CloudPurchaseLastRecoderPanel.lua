require "Core.Module.Common.Panel"

local CloudPurchaseLastRecoderPanel = class("CloudPurchaseLastRecoderPanel", Panel);
local CloudPurchaseRewardItem = require "Core.Module.CloudPurchase.View.Item.CloudPurchaseRewardItem"
local CloudPurchaseRecoderItem = require "Core.Module.CloudPurchase.View.Item.CloudPurchaseRecoderItem"


function CloudPurchaseLastRecoderPanel:New()
	self = {};
	setmetatable(self, {__index = CloudPurchaseLastRecoderPanel});
	return self
end


function CloudPurchaseLastRecoderPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function CloudPurchaseLastRecoderPanel:_InitReference()
	
	self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
	local myphalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "phalanx")
	self._myPhalanx = Phalanx:New()
	self._myPhalanx:Init(myphalanxInfo, CloudPurchaseRewardItem)
	
	local recoderPhalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "scrollview/phalanx")
	self.recoderPhalanx = Phalanx:New()
	self.recoderPhalanx:Init(recoderPhalanxInfo, CloudPurchaseRecoderItem)
end

function CloudPurchaseLastRecoderPanel:_InitListener()
	self:_AddBtnListen(self._btnClose.gameObject)
end

function CloudPurchaseLastRecoderPanel:_OnBtnsClick(go)
	if go == self._btnClose.gameObject then
		self:_OnClickBtnClose()
	end
end

function CloudPurchaseLastRecoderPanel:_OnClickBtnClose()
	ModuleManager.SendNotification(CloudPurchaseNotes.CLOSE_CLOUDPURCHASERECODERPANEL)
end

function CloudPurchaseLastRecoderPanel:_Dispose()
	self:_DisposeReference();
end

function CloudPurchaseLastRecoderPanel:_DisposeReference()
	self._btnClose = nil;
	self.recoderPhalanx:Dispose()
	self.recoderPhalanx = nil
	
	self._myPhalanx:Dispose()
	self._myPhalanx = nil	
end

function CloudPurchaseLastRecoderPanel:UpdatePanel(data)
	if(data) then
		if(data.my and #data.my > 0) then
			self._myPhalanx:Build(1, #data.my, data.my)
		end
		
		if(data.other and #data.other > 0) then
			self.recoderPhalanx:Build(#data.other, 1, data.other)
		end
	end
end

return CloudPurchaseLastRecoderPanel 