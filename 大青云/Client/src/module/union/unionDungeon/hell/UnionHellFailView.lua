--[[
帮派副本-地宫炼狱挑战失败提示界面
2015年1月9日15:53:11
haohu
]]

_G.UIUnionHellFail = BaseUI:new("UIUnionHellFail");

function UIUnionHellFail:Create()
	self:AddSWF("unionHellFailPanel.swf", true, "center");
end

function UIUnionHellFail:OnLoaded(objSwf)
	objSwf.txtPrompt.htmlText = StrConfig['unionhell041']
	objSwf.btnQuit.click = function() self:OnBtnQuitClick(); end
	objSwf.btnRetry.click = function() self:OnBtnRetryClick(); end
	objSwf.btnClose.click = function() self:OnBtnQuitClick(); end
end

function UIUnionHellFail:OnShow()
	self:InitShow();
	self:StartTimer();
end

function UIUnionHellFail:InitShow()
	
end

function UIUnionHellFail:OnHide()
	self:StopTimer();
end

function UIUnionHellFail:OnBtnQuitClick()
	self:Quit()
end

function UIUnionHellFail:Quit()
	UnionDungeonHellController:Quit();
end

function UIUnionHellFail:Retry()
	UnionDungeonHellController:Retry();
end

function UIUnionHellFail:OnBtnRetryClick()
	self:Retry()
end

local timerKey;
local time;
function UIUnionHellFail:StartTimer()
	time = UnionHellConsts.ResultPanelTime;
	local cb = function(count)
		self:OnTimer(count);
	end
	timerKey = TimerManager:RegisterTimer( cb, 1000, 0 );
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.txtCountDown.htmlText = string.format( StrConfig['babel012'], UnionHellConsts.ResultPanelTime );
end

function UIUnionHellFail:OnTimer(count)
	time = time - 1;
	if time == 0 then
		self:OnTimeUp();
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.txtCountDown.htmlText = string.format( StrConfig['babel012'], time );
end

function UIUnionHellFail:OnTimeUp()
	self:StopTimer();
	self:Quit()
end

function UIUnionHellFail:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer(timerKey);
		timerKey = nil;
	end
end

---------------------------------------------------
function UIUnionHellFail:Open()
	if self:IsShow() then
		self:InitShow();
	else
		self:Show();
	end
end