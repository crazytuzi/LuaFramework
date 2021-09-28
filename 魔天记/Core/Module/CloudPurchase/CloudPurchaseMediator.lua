require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.CloudPurchase.CloudPurchaseNotes"
local CloudPurchasePanel = require "Core.Module.CloudPurchase.View.CloudPurchasePanel"
local CloudPurchaseBuyPanel = require "Core.Module.CloudPurchase.View.CloudPurchaseBuyPanel"
local CloudPurchaseLastRecoderPanel = require "Core.Module.CloudPurchase.View.CloudPurchaseLastRecoderPanel"

local CloudPurchaseMediator = Mediator:New();
local notes = {
	CloudPurchaseNotes.OPEN_CLOUDPURCHASEPANEL,
	CloudPurchaseNotes.CLOSE_CLOUDPURCHASEPANEL,
	CloudPurchaseNotes.UPDATE_CLOUDPURCHASEPANEL,
	
	CloudPurchaseNotes.OPEN_CLOUDPURCHASEBUYPANEL,
	CloudPurchaseNotes.CLOSE_CLOUDPURCHASEBUYPANEL,
	CloudPurchaseNotes.UPDATE_CLOUDPURCHASEBUYPANEL,
	
	CloudPurchaseNotes.OPEN_CLOUDPURCHASERECODERPANEL,
	CloudPurchaseNotes.CLOSE_CLOUDPURCHASERECODERPANEL,
	CloudPurchaseNotes.UPDATE_CLOUDPURCHASERECODERPANEL,
	CloudPurchaseNotes.UPDATE_CLOUDPURCHASEPANEL_RECORDER,
	
}
function CloudPurchaseMediator:OnRegister()
	
end

function CloudPurchaseMediator:_ListNotificationInterests()
	return notes
end

function CloudPurchaseMediator:_HandleNotification(notification)
	local notificationName = notification:GetName()
	if(notificationName == CloudPurchaseNotes.OPEN_CLOUDPURCHASEPANEL) then
		if(self._cloudPurchasePanel == nil) then
			self._cloudPurchasePanel = PanelManager.BuildPanel(ResID.UI_CLOUDPURCHASEPANEL, CloudPurchasePanel, false);			
		end
	elseif notificationName == CloudPurchaseNotes.CLOSE_CLOUDPURCHASEPANEL then
		if(self._cloudPurchasePanel) then
			PanelManager.RecyclePanel(self._cloudPurchasePanel, ResID.UI_CLOUDPURCHASEPANEL)
			self._cloudPurchasePanel = nil;
			CloudPurchaseManager.SetRedPoint(false)
		end
	elseif notificationName == CloudPurchaseNotes.UPDATE_CLOUDPURCHASEPANEL then
		if(self._cloudPurchasePanel) then
			self._cloudPurchasePanel:UpdatePanel()
		end
	elseif(notificationName == CloudPurchaseNotes.OPEN_CLOUDPURCHASEBUYPANEL) then
		if(self._cloudPurchaseBuyPanel == nil) then
			self._cloudPurchaseBuyPanel = PanelManager.BuildPanel(ResID.UI_CLOUDPURCHASEBUYPANEL, CloudPurchaseBuyPanel, false);			
		end
	elseif notificationName == CloudPurchaseNotes.CLOSE_CLOUDPURCHASEBUYPANEL then
		if(self._cloudPurchaseBuyPanel) then
			PanelManager.RecyclePanel(self._cloudPurchaseBuyPanel, ResID.UI_CLOUDPURCHASEBUYPANEL)
			self._cloudPurchaseBuyPanel = nil;
		end
	elseif notificationName == CloudPurchaseNotes.UPDATE_CLOUDPURCHASEBUYPANEL then
		if(self._cloudPurchasePanel) then
			
		end
	elseif(notificationName == CloudPurchaseNotes.OPEN_CLOUDPURCHASERECODERPANEL) then
		if(self._cloudPurchaseRecoderPanel == nil) then
			self._cloudPurchaseRecoderPanel = PanelManager.BuildPanel(ResID.UI_CLOUDPURCHASELASTRECODERPANEL, CloudPurchaseLastRecoderPanel, false);
			self._cloudPurchaseRecoderPanel:UpdatePanel(notification:GetBody())			
		end
	elseif notificationName == CloudPurchaseNotes.CLOSE_CLOUDPURCHASERECODERPANEL then
		if(self._cloudPurchaseRecoderPanel) then
			PanelManager.RecyclePanel(self._cloudPurchaseRecoderPanel, ResID.UI_CLOUDPURCHASELASTRECODERPANEL)
			self._cloudPurchaseRecoderPanel = nil;
		end
	elseif notificationName ==	CloudPurchaseNotes.UPDATE_CLOUDPURCHASERECODERPANEL then
		if(self._cloudPurchaseRecoderPanel) then			
			self._cloudPurchaseRecoderPanel:UpdatePanel()
		end
		
	elseif notificationName == CloudPurchaseNotes.UPDATE_CLOUDPURCHASEPANEL_RECORDER then
		if(self._cloudPurchasePanel) then
			log(notificationName)			
			self._cloudPurchasePanel:UpdateMotifyInfo()			
		end			
	end
end

function CloudPurchaseMediator:OnRemove()
	
end

return CloudPurchaseMediator 