_G.UIFirstRechargeWindow = BaseUI:new('UIFirstRechargeWindow');

function UIFirstRechargeWindow:Create()
	self.isAbsSize = true;
	self:AddSWF('firstRechargeWindow.swf',true,'popup');
end

function UIFirstRechargeWindow:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:Hide(); end;
end

function UIFirstRechargeWindow:OnShow()
	self:ShowWindow();
end

function UIFirstRechargeWindow:ShowWindow()
	if not self.objSwf then
		return;
	end
	
	local anchor = self.objSwf.anchor;
	
	local newurl = Version:GetFirstCharge(self.amount);
	if newurl ~= self.url then
		self.url = newurl;
		if self.window then
			_sys:closeWebWindow(self.window);
			self.window = nil;
		end
	end
	
	if not self.window then
		print('FirstCharge:'..tostring(self.url));
		if self.url and #self.url>0 then
			self.window = _sys:openWebWindow(0,0,anchor._width,anchor._height, self.url);
			print('FirstCharge Handle:'..tostring(self.window));
		end
	end
	
	if not self.window then
		return;
	end
	
	local winW,winH = UIManager:GetEWinSize();
	_sys:moveWebWindow(self.window, toint((winW-self.objSwf._width)/2 + anchor._x,-1), toint((winH-self.objSwf._height)/2 + anchor._y,-1), anchor._width,anchor._height);
	
end

function UIFirstRechargeWindow:OnResize(dwWidth,dwHeight)
	self:ShowWindow();
end 

function UIFirstRechargeWindow:OnHide()
	if self.window then
		_sys:closeWebWindow(self.window);
		self.window = nil;
	end
	self.amount = nil;
	self.url = nil;
end

function UIFirstRechargeWindow:Open(amount,failback)
	local firstUrl = Version:GetFirstCharge(self.amount);
	if not firstUrl or #firstUrl<1 then
		if failback then
			failback(nil);
		end
		return;
	end
	
	if not _sys.openWebWindow then
		if failback then
			failback(firstUrl);
		end
		return;
	end
	
	self.amount = amount;
	local result = self.bShowState and self:ShowWindow() or self:Show();
	return true;
end




