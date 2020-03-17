--[[
新功能开启,带模型的
ly
2015年5月6日11:41:25
]]

_G.UIFuncOpenLinshouModel = BaseUI:new("UIFuncOpenLinshouModel");
UIFuncOpenLinshouModel.callBack = nil;
UIFuncOpenLinshouModel.timerKey = nil;
UIFuncOpenLinshouModel.modelDraw = nil;

function UIFuncOpenLinshouModel:Create()
	self:AddSWF("funcOpenStoryModel.swf",true,"top");
end

function UIFuncOpenLinshouModel:OnLoaded(objSwf)
	objSwf.hitArea.click = function() self:OnHitAreaClick(); end
end

function UIFuncOpenLinshouModel:GetHeight()
	return 370;
end

function UIFuncOpenLinshouModel:GetWidth()
	return 353;
end

function UIFuncOpenLinshouModel:Open(callBack)
	self.callBack = callBack;
	if self:IsShow() then
		self:ShowInfo();
	else
		self:Show();
	end
end

function UIFuncOpenLinshouModel:OnShow()
	self:ShowInfo();
end

function UIFuncOpenLinshouModel:OnHide()
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
	self.callBack = nil;
end

function UIFuncOpenLinshouModel:ShowInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	self.modelDraw = FuncOpenLingshouDraw
	self.modelDraw:Enter(objSwf.modelLoader);
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
	end
	TimerManager:RegisterTimer(function()
		self:Hide();
	end,FuncConsts.AutoOpenTime,1);
end

function UIFuncOpenLinshouModel:OnHitAreaClick()
	self:Hide();
end

function UIFuncOpenLinshouModel:Update()
	if not self.bShowState then return; end
	if self.modelDraw then
		self.modelDraw:Update();
	end
end