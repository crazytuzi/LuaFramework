local robRevengeChoice = class( "robRevengeChoice", layout );

global_event.ROBREVENGECHOICE_SHOW = "ROBREVENGECHOICE_SHOW";
global_event.ROBREVENGECHOICE_HIDE = "ROBREVENGECHOICE_HIDE";
global_event.ROBREVENGECHOICE_UPDATE = "ROBREVENGECHOICE_UPDATE";

function robRevengeChoice:ctor( id )
	robRevengeChoice.super.ctor( self, id );
	self:addEvent({ name = global_event.ROBREVENGECHOICE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.ROBREVENGECHOICE_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.ROBREVENGECHOICE_UPDATE, eventHandler = self.updateItemInfo});
end

function robRevengeChoice:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	
	function onRobRevengeChoiceClose()
		self:onHide();
	end
	
	local robRevengeChoice_close = self:Child("robRevengeChoice-close");
	robRevengeChoice_close:subscribeEvent("ButtonClick", "onRobRevengeChoiceClose");
	
	self:updateItemInfo();
	
end

function robRevengeChoice:updateItemInfo()
	
	if not self._show then
		return;
	end
	
	function onRobRevengeChoiceClickRevenge(args)
		local window = LORD.toWindowEventArgs(args).window;
		
		local primalType = window:GetUserData();
		
		dataManager.idolBuildData:onRevengeEnterBattlePrepare(primalType);
		
	end
	
	local targetInfo = dataManager.idolBuildData:getCurrentSelectTargetInfo();
	
	dump(targetInfo);
	
	for i=1, 4 do
		
		local robthing_image = LORD.toStaticImage(self:Child("robRevengeChoice-robthing"..i.."-image"));
		local robthing_shadow = self:Child("robRevengeChoice-robthing"..i.."-shadow");
		local robthing_button = self:Child("robRevengeChoice-robthing"..i);
		
		local primalItemInfo = dataManager.idolBuildData:getPrimalItemInfo(i-1);
		robthing_image:SetImage(primalItemInfo.icon);
		
		robthing_button:removeEvent("ButtonClick");
		
		if targetInfo and targetInfo.primals and targetInfo.primals[i] then
			
			robthing_shadow:SetVisible(targetInfo.primals[i] <= 0);
			
			if targetInfo.primals[i] > 0 then
				robthing_button:SetUserData(i-1);
				robthing_button:subscribeEvent("ButtonClick", "onRobRevengeChoiceClickRevenge");
			end
		end

	end
		
end

function robRevengeChoice:onHide(event)
	self:Close();
end

return robRevengeChoice;
