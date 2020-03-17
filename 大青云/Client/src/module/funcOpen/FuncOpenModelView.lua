--[[
新功能开启,带模型的
lizhuangzhuang
2014年11月6日11:41:25
]]

_G.UIFuncOpenModel = BaseUI:new("UIFuncOpenModel");

UIFuncOpenModel.funcId = nil;
UIFuncOpenModel.callBack = nil;
UIFuncOpenModel.timerKey = nil;

UIFuncOpenModel.modelDraw = nil;

function UIFuncOpenModel:Create()
	self:AddSWF("funcOpenModel.swf",true,"top");
end

function UIFuncOpenModel:OnLoaded(objSwf)
	objSwf.hitArea.click = function() self:OnHitAreaClick(); end
end

function UIFuncOpenModel:OnResize()
	self:ShowMask();
end

function UIFuncOpenModel:GetHeight()
	return 370;
end

function UIFuncOpenModel:GetWidth()
	return 353;
end

function UIFuncOpenModel:Open(funcId,callBack)
	self.funcId = funcId;
	self.callBack = callBack;
	QuestGuideManager:StopGuide();
	if self:IsShow() then
		self:ShowInfo();
	else
		self:Show();
	end
end

function UIFuncOpenModel:OnShow()
	self:ShowMask();
	self:ShowInfo();
end

function UIFuncOpenModel:ShowMask()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local x,y = self:GetPos();
	local wWidth,wHeight = UIManager:GetWinSize();
	objSwf.mask._x = -x;
	objSwf.mask._y = -y;
	objSwf.mask._width = wWidth;
	objSwf.mask._height = wHeight;
end

function UIFuncOpenModel:OnHide()
	if self.modelDraw then
		self.modelDraw:Exit();
		self.modelDraw = nil;
	end
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
	end
	if self.callBack and self.objSwf then
		self.callBack(UIManager:PosLtoG(self.objSwf,self:GetWidth()/2,self:GetHeight()/2));
	end
	self.funcId = nil;
	self.callBack = nil;
	QuestGuideManager:RecoverGuide();
end

function UIFuncOpenModel:ShowInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local func = FuncManager:GetFunc(self.funcId);
	if not func then 
		self:Hide();
		return;
	end
	if _G[func:GetCfg().model] then
		self.modelDraw = _G[func:GetCfg().model];
		self.modelDraw:Enter(objSwf);
	end
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
	end
	self.timerKey = TimerManager:RegisterTimer(function()
		self:Hide();
	end,FuncConsts.AutoOpenTime,1);
end

function UIFuncOpenModel:OnHitAreaClick()
	self:Hide();
end

function UIFuncOpenModel:Update()
	if not self.bShowState then return; end
	if self.modelDraw then
		self.modelDraw:Update();
	end
end