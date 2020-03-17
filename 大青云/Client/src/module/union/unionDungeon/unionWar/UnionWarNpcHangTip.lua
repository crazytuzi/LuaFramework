--[[
战场守卫挂了，提示窗口
wangshuai
]]

_G.UIUnionWarNpc = BaseUI:new("UIUnionWarNpc")

UIUnionWarNpc.timerKey = nil;
UIUnionWarNpc.timer = 5;
function UIUnionWarNpc:Create()
	self:AddSWF("unionWarNpcHang.swf",true,"center")
end;
function UIUnionWarNpc:OnLoaded(objSwf)
	objSwf.time.textField.htmlText = string.format(StrConfig["unionwar209"],UIUnionWarNpc.timer);

end;
function UIUnionWarNpc:OnShow()
	self.timer = 5;
	local objSwf = self.objSwf;
	objSwf.time.textField.htmlText = string.format(StrConfig["unionwar209"],UIUnionWarNpc.timer);
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(self.OnTimer,1000,5);

end;
function UIUnionWarNpc:OnTimer()
	local objSwf = UIUnionWarNpc.objSwf;
	UIUnionWarNpc.timer = UIUnionWarNpc.timer - 1;
	objSwf.time.textField.htmlText = string.format(StrConfig["unionwar209"],UIUnionWarNpc.timer);
	if UIUnionWarNpc.timer == 0 then 
		UIUnionWarNpc:Hide();
	end;
end;

function UIUnionWarNpc:OnHide()

end;