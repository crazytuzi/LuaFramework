require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Ride.RideNotes"
require "Core.Module.Ride.View.RidePanel"
local RideRenewPanel = require "Core.Module.Ride.View.RideRenewPanel"
local RideRenewShowPanel = require "Core.Module.Ride.View.RideRenewShowPanel"



RideMediator = Mediator:New();
function RideMediator:OnRegister()
	
end
local _notification = {
	RideNotes.OPEN_RIDEPANEL,
	RideNotes.CLOSE_RIDEPANEL,
	RideNotes.UPDATE_RIDEPANEL,
	RideNotes.UPDATE_RIDEPANELALLPROPERTY,
	RideNotes.OPEN_RIDEBECOMEEXPIRED,
	RideNotes.OPEN_RIDEEXPIRED,
	RideNotes.OPEN_RIDEREUSEPANEL,
	RideNotes.CLOSE_RIDEREUSEPANEL,
	RideNotes.UPDATE_RIDEREUSEPANEL,
	
	RideNotes.OPEN_RIDERENEWSHOWPANEL,
	RideNotes.CLOSE_RIDERENEWSHOWPANEL,
	RideNotes.SHOW_RIDEFEED_UPDATEEFFECT
	
	
};
function RideMediator:_ListNotificationInterests()
	return _notification
end

function RideMediator:_HandleNotification(notification)
	local notificationName = notification:GetName()
	if notificationName == RideNotes.OPEN_RIDEPANEL then
		if(self._ridePanel == nil) then
			self._ridePanel = PanelManager.BuildPanel(ResID.UI_RIDEPANEL, RidePanel, true);
			
			local p = notification:GetBody();
			if p then
				self._ridePanel:SetOpenVal(p);
			end
			self._ridePanel:ChangePanel(1)
			--            self._ridePanel:InitData();
		end
	elseif notificationName == RideNotes.CLOSE_RIDEPANEL then
		if(self._ridePanel) then
			PanelManager.RecyclePanel(self._ridePanel, ResID.UI_RIDEPANEL)
			self._ridePanel = nil
		end
	elseif notificationName == RideNotes.UPDATE_RIDEPANEL then
		if(self._ridePanel) then
			self._ridePanel:UpdateRidePanel()
		end
	elseif notificationName == RideNotes.UPDATE_RIDEPANELALLPROPERTY then
		if(self._ridePanel) then
			self._ridePanel:UpdateRidePanelAllProperty()
		end
		-- elseif notificationName == RideNotes.OPEN_RIDEEXPIRED then
-- 	local rideInfo = RideManager.GetExpiredRideInfo()
-- 	-- local fuc = function()		
-- 	-- 	RideManager.SetIsRideExpired(false, nil)
-- 	-- 	if(RideManager.GetIsRideBecomeExpired()) then
-- 	-- 		ModuleManager.SendNotification(RideNotes.OPEN_RIDEBECOMEEXPIRED)
-- 	-- 	end			
-- 	-- end
-- 	local handleFun = function()
-- 		ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {		
-- 		msg = LanguageMgr.Get("ride/rideItem/expired", {name = rideInfo.name, gold = rideInfo.gold}),
-- 		hander = function()		
-- 			RideProxy.SendRideRenewal(rideInfo.id)
-- 			RideManager.SetIsRideExpired(false, nil)
-- 		end
-- 		,
-- 		-- cancelHandler = fuc
-- 		});
-- 	end
-- elseif notificationName == RideNotes.OPEN_RIDEBECOMEEXPIRED then
-- 	-- local fuc = function()		
-- 	-- 	RideManager.SetIsRideBecomeExpired(false, nil)
-- 	-- end
-- 	local handleFun = function()
-- 		ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {		
-- 		msg = LanguageMgr.Get("ride/rideItem/becomeExpired", {name = rideInfo.name, time = TimeTranslate(rideInfo:GetTimeLimit()), gold = rideInfo.gold}),
-- 		hander = function()		
-- 			RideProxy.SendRideRenewal(rideInfo.id)
-- 			RideManager.SetIsRideBecomeExpired(false, nil)
-- 		end
-- 		,
-- 		-- cancelHandler = fuc
-- 		});
-- 	end
	elseif notificationName == RideNotes.OPEN_RIDEREUSEPANEL then
		
		local fun = nil
		local rideInfo = nil
		if(RideManager.GetIsRideExpired()) then
			rideInfo = RideManager.GetExpiredRideInfo()			
			fun = function()
				ModuleManager.SendNotification(RideNotes.OPEN_RIDERENEWSHOWPANEL, {
					rideInfo = rideInfo,		
					msg = LanguageMgr.Get("ride/rideItem/expired", {name = rideInfo.name, gold = rideInfo.gold}),
					hander = function()		
						RideProxy.SendRideRenewal(rideInfo.id)
						RideManager.SetIsRideExpired(false, nil)
						ModuleManager.SendNotification(RideNotes.CLOSE_RIDERENEWSHOWPANEL)
					end
					,
					
				});
			end
		elseif RideManager.GetIsRideBecomeExpired() then
			rideInfo = RideManager.GetBecomeExpiredInfo()
			fun = function()
				
				ModuleManager.SendNotification(RideNotes.OPEN_RIDERENEWSHOWPANEL, {	
				rideInfo = rideInfo,	
				msg = LanguageMgr.Get("ride/rideItem/becomeExpired", {name = rideInfo.name, time = TimeTranslate(rideInfo:GetTimeLimit()), gold = rideInfo.gold}),
				hander = function()		
					RideProxy.SendRideRenewal(rideInfo.id)
					RideManager.SetIsRideBecomeExpired(false, nil)
					ModuleManager.SendNotification(RideNotes.CLOSE_RIDERENEWSHOWPANEL)
				end
				,
				
				});
			end
		end
		if(rideInfo and self._rideRenewPanel == nil) then
			self._rideRenewPanel = PanelManager.BuildPanel(ResID.UI_RIDERENEWPANEL, RideRenewPanel, false, RideNotes.CLOSE_RIDEREUSEPANEL);
			self._rideRenewPanel:UpdatePanel(rideInfo, fun)
		end
		
	elseif notificationName == RideNotes.CLOSE_RIDEREUSEPANEL then		
		if(self._rideRenewPanel) then
			PanelManager.RecyclePanel(self._rideRenewPanel, ResID.UI_RIDERENEWPANEL)
			self._rideRenewPanel = nil
		end
	elseif notificationName == RideNotes.UPDATE_RIDEREUSEPANEL then
		if(self._rideRenewPanel ~= nil) then
			
		end	
	elseif notificationName == RideNotes.OPEN_RIDERENEWSHOWPANEL then
		if(self._rideRenewShowPanel == nil) then
			self._rideRenewShowPanel = PanelManager.BuildPanel(ResID.UI_RIDERENEWSHOWPANEL, RideRenewShowPanel, false, RideNotes.CLOSE_RIDEREUSEPANEL);
			self._rideRenewShowPanel:UpdatePanel(notification:GetBody())
		end
	elseif notificationName == RideNotes.CLOSE_RIDERENEWSHOWPANEL then
		if(self._rideRenewShowPanel) then
			PanelManager.RecyclePanel(self._rideRenewShowPanel, ResID.UI_RIDERENEWPANEL)
			self._rideRenewShowPanel = nil
		end
	elseif notificationName == RideNotes.SHOW_RIDEFEED_UPDATEEFFECT then
		if(self._ridePanel) then
			 self._ridePanel:ShowUpdateEffect()
		end
	end
	
end

function RideMediator:OnRemove()
	if(self._ridePanel) then
		PanelManager.RecyclePanel(self._ridePanel, ResID.UI_RIDEPANEL)
		self._ridePanel = nil
	end
end

