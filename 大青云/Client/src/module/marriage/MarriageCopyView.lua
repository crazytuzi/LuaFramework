
--[[
结婚副本，追踪退出
wangshuai
]]

_G.UIMarryCopy = BaseUI:new("UIMarryCopy")

function UIMarryCopy:Create()
	self:AddSWF("marryCopyPanel.swf",true,"center")
end;

function UIMarryCopy:OnLoaded(objSwf)
	objSwf.out.click = function() self:OnOkClick()end;
	objSwf.openEat.mcTimeOver._visible = false;
	objSwf.openEat.mcTime._visible = true;
end;

function UIMarryCopy:GetWidth()
	return 187;
end

function UIMarryCopy:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	objSwf.openEat._visible = false;
	self:UpdateButton();
end;

function UIMarryCopy:OnHide()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
end;

function UIMarryCopy:UpdateButton()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.openEat._x = -wWidth/2+self:GetWidth();
end

function UIMarryCopy:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
	self:UpdateButton();
end


function UIMarryCopy:OnOkClick()
	local func = function() 
		MarriagController:ReqOutMarryCopy()
		self:Hide()
	end;
	UIConfirm:Open(StrConfig['marriage209'],func)
end;


UIMarryCopy.timerKey = nil;
UIMarryCopy.time = 0;
function UIMarryCopy:Ontimer()
	if not self.bShowState then return; end
	
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local year, month, day, hour, minute, second = CTimeFormat:todate(self.time,true);
	print("--------------",self.time)
	local at,as,am  = CTimeFormat:sec2format(self.time);
	objSwf.openEat.mcTime.time_txt.htmlText = string.format('%02d:%02d:%02d',at,as,am);
	if self.time <= 0 then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
		objSwf.openEat.mcTimeOver._visible = true;
		objSwf.openEat.mcTime._visible = false;
	else
		objSwf.openEat.mcTimeOver._visible = false;
		objSwf.openEat.mcTime._visible = true;
	end

	self.time = self.time - 1;
end;

function UIMarryCopy:SetEatOpen(time)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	self.time = time
	if self.time <= 0 then
		objSwf.openEat.mcTimeOver._visible = true;
		objSwf.openEat.mcTime._visible = false;
	else
		objSwf.openEat.mcTimeOver._visible = false;
		objSwf.openEat.mcTime._visible = true;
		--
		local at,as,am  = CTimeFormat:sec2format(self.time);
		objSwf.openEat.mcTime.time_txt.htmlText = string.format('%02d:%02d:%02d',at,as,am);
	end
	
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(function()self:Ontimer() end,1000,0);
	objSwf.openEat._visible = true;
end;