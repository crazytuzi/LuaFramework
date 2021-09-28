require "Core.Module.Common.UIItem"

SignInTypeItem = class("SignInTypeItem", UIItem);



function SignInTypeItem:New()
	self = {};
	setmetatable(self, {__index = SignInTypeItem});
	return self
end


function SignInTypeItem:_Init()
	self._toggle = UIUtil.GetComponent(self.transform, "UIToggle")
	self._txtTitle = UIUtil.GetChildByName(self.transform, "UILabel", "title")
	self._goTip = UIUtil.GetChildByName(self.transform, "tip").gameObject
	self._onClickItem = function(go) self:_OnClickItem() end
	UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem);
	self:UpdateItem(self.data)
	
	
	
end

function SignInTypeItem:_OnClickItem()
	
	-- log("--_OnClickItem--> " .. self.transform.gameObject.name);
	if(self.data.code_id == 1) then
		LogHttp.SendOperaLog("每日签到")
	elseif self.data.code_id == 2 then
		LogHttp.SendOperaLog("在线奖励")
	elseif self.data.code_id == 3 then
		LogHttp.SendOperaLog("奖励找回")
	elseif self.data.code_id == 6 then
		LogHttp.SendOperaLog("VIP礼包")
	end
	ModuleManager.SendNotification(SignInNotes.CHANGE_SIGNINPANEL, self.data.code_id)
end

function SignInTypeItem:_Dispose()
	UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickItem = nil;
end

function SignInTypeItem:UpdateItem(data)
	self.data = data
	if(self.data) then
		self._txtTitle.text = self.data.title_name
		
		self.transform.gameObject.name = self.data.code_id;
		
	end
end

function SignInTypeItem:SetToggleActive(active)
	self._toggle.value = active
	if(active) then
		self:_OnClickItem()
	end
	
end

function SignInTypeItem:UpdateTipState()
	if(self.data) then
		local b = false;
		if(self.data.code_id == 1) then
			b = not SignInManager.GetIsSignToday();
		elseif self.data.code_id == 2 then
			b = SubInLinePanel.ins:GetCanGetAwards();
		elseif self.data.code_id == 3 then
			b = SignInManager.CanRevertAward()
		elseif self.data.code_id == 4 then
			b = SubSevenDayItem.needTip;
		elseif self.data.code_id == 5 then
			b = Login7RewardManager.IsCanGetAward();
		elseif self.data.code_id == 6 then
			b = VIPManager.CanGetDailyAward();
		elseif self.data.code_id == 7 then
			b = false;
		end
		self._goTip:SetActive(b);
	end
end