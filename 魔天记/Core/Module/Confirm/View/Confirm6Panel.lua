require "Core.Module.Confirm.View.BaseConfirmPanel"
Confirm6Panel = class("Confirm6Panel", BaseConfirmPanel);

function Confirm6Panel:New()
	self = {};
	setmetatable(self, {__index = Confirm6Panel});
	return self
end


function Confirm6Panel:_Init()
	self._luaBehaviour.canPool = true
	self:_InitReference();
	self:_InitListener();
end

function Confirm6Panel:_InitReference()
	self._txt_title = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_title");
	self._txt_label = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_label");
	self._txt_elTime = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_elTime");
	self._btn_ok = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_ok");
	self._btn_cancel = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_cancel");
	
	local chbs = UIUtil.GetComponentsInChildren(self._trsContent, "UIToggle");
	self.autoGensui = UIUtil.GetChildInComponents(chbs, "autoGensui");
	self.autoGensui.value = false;
end

function Confirm6Panel:_InitListener()
	self._onClickBtn_ok = function(go) self:_OnClickBtn_ok(self) end
	UIUtil.GetComponent(self._btn_ok, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_ok);
	self._onClickBtn_cancel = function(go) self:_OnClickBtn_cancel(self) end
	UIUtil.GetComponent(self._btn_cancel, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_cancel);
end

function Confirm6Panel:_OnClickBtn_ok()
	
	FriendProxy.AnswerLdAskGenShui(1, 1)
	
	AutoFightManager.autoGensui = self.autoGensui.value;
	AutoFightManager.Save();
	
	self:ClosePanel(ConfirmNotes.CLOSE_CONFIRM6PANEL);
	
end

function Confirm6Panel:_OnClickBtn_cancel()
	FriendProxy.AnswerLdAskGenShui(0, 1)
	AutoFightManager.autoGensui = self.autoGensui.value;
	AutoFightManager.Save();
	self:ClosePanel(ConfirmNotes.CLOSE_CONFIRM6PANEL);
	
end
-- {id,n}
function Confirm6Panel:SetData(data)
	
	self._txt_label.text = LanguageMgr.Get("Confirm/Confirm6Panel/label1", {n = data.n});
	self._txt_elTime.text = LanguageMgr.Get("Confirm/Confirm6Panel/label2", {n = 15});
	
	self._totalTime = 15;
	if(self._sec_timer == nil) then
		self._sec_timer = Timer.New(function()
			
			local tstr = GetTimeByStr1(self._totalTime);
			self._totalTime = self._totalTime - 1;
			self._txt_elTime.text = LanguageMgr.Get("Confirm/Confirm6Panel/label2", {n = self._totalTime});
			
			if self._totalTime <= 0 then
				if self._sec_timer ~= nil then
					self._sec_timer:Stop();
					self._sec_timer = nil;
				end
				self:_OnClickBtn_ok()
				
			end
			
		end, 1, self._totalTime, false);
		self._sec_timer:Start();
	else
		self._sec_timer:Stop();
		self._sec_timer:Start();
	end
end

function Confirm6Panel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function Confirm6Panel:_DisposeListener()
	UIUtil.GetComponent(self._btn_ok, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_ok = nil;
	UIUtil.GetComponent(self._btn_cancel, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_cancel = nil;
end

function Confirm6Panel:_DisposeReference()
	self._btn_ok = nil;
	self._btn_cancel = nil;
	self._txt_title = nil;
	self._txt_label = nil;
	self._txt_elTime = nil;
	
	if self._sec_timer ~= nil then
		self._sec_timer:Stop();
		self._sec_timer = nil;
	end
end

