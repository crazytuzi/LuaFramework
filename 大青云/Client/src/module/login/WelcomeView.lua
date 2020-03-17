--[[
游戏进入时欢迎界面
lizhuangzhuang
2015年8月1日17:09:10
]]

_G.UIWelcome = BaseUI:new("UIWelcome");

UIWelcome.callback = nil;
UIWelcome.timerKey = nil;

UIWelcome.TweenScale = 10;

function UIWelcome:Create()
	self:AddSWF("welcome.swf",true,"center");
end

function UIWelcome:OnLoaded(objSwf)
	objSwf.button.click = function() self:OnBtnClick(); end
	objSwf.mask.click = function() self:OnBtnClick(); end
end

function UIWelcome:GetWidth()
	return 812;
end

function UIWelcome:GetHeight()
	return 538;
end

function UIWelcome:OnResize(dwWidth,dwHeight)
	self:ShowMask();
end

function UIWelcome:ShowMask()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local x,y = self:GetPos();
	local wWidth,wHeight = UIManager:GetWinSize();
	objSwf.mask._x = -x;
	objSwf.mask._y = -y;
	objSwf.mask._width = wWidth;
	objSwf.mask._height = wHeight;
end

function UIWelcome:IsTween()
	return true;
end

function UIWelcome:DoTweenShow()
	self:TweenShowEff(function()
		self:DoShow();
	end);
end

function UIWelcome:DoTweenHide()
	self:DoHide();
end

function UIWelcome:TweenShowEff(callback)
	local objSwf = self.objSwf;
	local endX,endY = self:GetCfgPos();
	local startX = endX + self:GetWidth()/2 - self:GetWidth()*self.TweenScale/100/2;
	local startY = endY + self:GetHeight()/2 - self:GetHeight()*self.TweenScale/100/2;
	--
	objSwf._x = startX;
	objSwf._y = startY;
	objSwf._alpha = 50;
	objSwf._xscale = self.TweenScale;
	objSwf._yscale = self.TweenScale;
	--
	Tween:To( self.objSwf, 0.3, {_alpha = 100,_xscale=100,_yscale=100,_x=endX,_y=endY,ease=Back.easeInOut},
			{onComplete=callback});
end

local autoCloseTime = 10;
function UIWelcome:OnShow()
	self:ShowMask();
	self.objSwf.timetext.htmlText = string.format(StrConfig["quest1000"], autoCloseTime);
	self.timerKey = TimerManager:RegisterTimer(function(curTimes)
		if self.objSwf then
			self.objSwf.timetext.htmlText = string.format(StrConfig["quest1000"], autoCloseTime - curTimes);
		end
		if curTimes >= autoCloseTime then
			self.timerKey = nil;
			self:OnBtnClick(true);
		end
	end,1000,autoCloseTime);
end

function UIWelcome:OnHide()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
	self.callback = nil;
end

function UIWelcome:Open(callback)
	self.callback = callback;
	self:Show();
end

function UIWelcome:OnBtnClick(isAuto)
	if self.callback then
		self.callback();
	end
	ClickLog:Send(ClickLog.T_Welcome,isAuto and 1 or 0);
	self:Hide();
end