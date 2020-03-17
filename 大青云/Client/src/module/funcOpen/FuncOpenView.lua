--[[
新功能开启
lizhuangzhuang
2014年11月4日22:33:54
]]

_G.UIFuncOpen = BaseUI:new("UIFuncOpen");

UIFuncOpen.funcId = nil;
UIFuncOpen.callBack = nil;
UIFuncOpen.timerKey = nil;

function UIFuncOpen:Create()
	self:AddSWF("funcOpenV.swf",true,"top");
end

function UIFuncOpen:OnLoaded(objSwf)
	objSwf.hitArea.click = function() self:OnHitAreaClick(); end
	-- objSwf.nameloader.loaded = function() self:OnNameLoaded(); end
end

function UIFuncOpen:OnResize()
	self:ShowMask();
end

function UIFuncOpen:GetWidth()
	return 502;
end

function UIFuncOpen:GetHeight()
	return 344;
end

function UIFuncOpen:Open(funcId,callBack)
	self.funcId = funcId;
	self.callBack = callBack;
	if self:IsShow() then
		self:ShowInfo();
	else
		self:Show();
	end
end

function UIFuncOpen:OnShow()
	self:ShowInfo();
	self:ShowMask();
	if self.objSwf then
		self.objSwf:gotoAndPlay(1);
		self.objSwf.panel:gotoAndPlay(1)
	end
end

function UIFuncOpen:OnHide()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
	end
	if self.callBack and self.objSwf then
		self.callBack(UIManager:PosLtoG(self.objSwf.panel.loader));
	end
	self.funcId = nil;
	self.callBack = nil;
	-- if self.objSwf then
	-- 	self.objSwf:gotoAndStop(1);
	-- end
end

function UIFuncOpen:ShowInfo()
	SoundManager:PlaySfx(2032);
	local objSwf = self:GetSWF();
	if not objSwf then return; end
	local func = FuncManager:GetFunc(self.funcId);
	if not func then 
		self:Hide();
		return;
	end
	objSwf.panel.nameloader.loaded = function()
													objSwf.panel.nameloader._x = (-objSwf.panel.nameloader._width/2);
												end
	objSwf.panel.nameloader.source = ResUtil:GetFuncNameUrl(func:GetCfg().nameIcon);
	objSwf.panel.loader.source = ResUtil:GetFuncIconUrl(func:GetCfg().icon);
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
	end
	TimerManager:RegisterTimer(function()
		self:Hide();
	end,FuncConsts.AutoOpenTime,1);
end

-- function UIFuncOpen:OnNameLoaded()
-- 	local objSwf = self.objSwf;
-- 	if not objSwf then return; end
-- 	objSwf.nameloader._x = objSwf.mcCenter._x - objSwf.nameloader.content._width/2;
-- end

function UIFuncOpen:OnHitAreaClick()
	self:Hide();
end

function UIFuncOpen:ShowMask()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local x,y = self:GetPos();
	local wWidth,wHeight = UIManager:GetWinSize();
	objSwf.mask._x = -x;
	objSwf.mask._y = -y;
	objSwf.mask._width = wWidth;
	objSwf.mask._height = wHeight;
end